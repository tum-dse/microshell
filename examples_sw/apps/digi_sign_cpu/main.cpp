/**
 * Digital Signature — CPU-sync variant (SHA-256 → RSA).
 *
 * Drives the digital_signature_cpusync bitstream where each module sits on
 * its own vFPGA. The host CPU sequentially invokes each stage and copies
 * the SHA-256 digest into the RSA stage's input buffer, modelling the
 * Coyote pattern compared in Figure 3 (direct_comm_effectiveness).
 */

#include <iostream>
#include <string>
#include <malloc.h>
#include <chrono>
#include <unistd.h>
#include <iomanip>
#include <signal.h>
#include <boost/program_options.hpp>
#include <any>
#include <vector>

#include "cBench.hpp"
#include "cThread.hpp"

using namespace std;
using namespace fpga;

std::atomic<bool> stalled(false);
void gotInt(int) { stalled.store(true); }

constexpr auto const defDevice    = 0;
constexpr auto const defReps      = 1;
constexpr auto const defInputSize = 64;       // bytes (one 512-bit SHA block)
constexpr auto const HASH_SIZE    = 32;       // 256-bit digest
constexpr auto const SIG_SIZE     = 32;       // 256-bit RSA output
constexpr auto const N_STAGES     = 2;

void printLatencyStats(double avg_latency_ns, uint32_t data_size_bytes, uint32_t n_reps) {
    std::cout << std::fixed << std::setprecision(2);
    std::cout << "\nLatency Measurements:" << std::endl;
    std::cout << "Total latency: " << avg_latency_ns << " ns ("
              << (avg_latency_ns / 1000) << " us)" << std::endl;
    std::cout << "Throughput: " << std::setw(8)
              << (1000.0 * data_size_bytes) / avg_latency_ns
              << " MB/s" << std::endl;
}

int main(int argc, char *argv[]) {
    struct sigaction sa{}; sa.sa_handler = gotInt; sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    boost::program_options::options_description opts("Options:");
    opts.add_options()
        ("size,s", boost::program_options::value<uint32_t>(), "Input bytes (multiple of 64)")
        ("reps,r", boost::program_options::value<uint32_t>(), "Number of reps");
    boost::program_options::variables_map vm;
    boost::program_options::store(boost::program_options::parse_command_line(argc, argv, opts), vm);
    boost::program_options::notify(vm);

    uint32_t input_size = vm.count("size") ? vm["size"].as<uint32_t>() : defInputSize;
    uint32_t n_reps     = vm.count("reps") ? vm["reps"].as<uint32_t>() : defReps;
    if (input_size % 64 != 0) input_size = ((input_size + 63) / 64) * 64;

    uint32_t n_pages_in   = (input_size + hugePageSize - 1) / hugePageSize;
    uint32_t n_pages_hash = (HASH_SIZE  + hugePageSize - 1) / hugePageSize;
    uint32_t n_pages_sig  = (SIG_SIZE   + hugePageSize - 1) / hugePageSize;

    PR_HEADER("PARAMS (CPU-sync)");
    std::cout << "Pipeline: SHA-256(vFPGA0) -> RSA(vFPGA1)" << std::endl;
    std::cout << "Input:  " << input_size << " bytes" << std::endl;
    std::cout << "Hash:   " << HASH_SIZE  << " bytes" << std::endl;
    std::cout << "Sig:    " << SIG_SIZE   << " bytes" << std::endl;
    std::cout << "Reps:   " << n_reps << std::endl;

    try {
        std::vector<std::unique_ptr<cThread<std::any>>> cthread;
        for (int i = 0; i < N_STAGES; i++)
            cthread.emplace_back(new cThread<std::any>(i, getpid(), defDevice));
        for (auto& t : cthread) t->start();

        auto* in       = (uint32_t*) cthread[0]->getMem({CoyoteAlloc::HPF, n_pages_in});
        auto* hash_out = (uint32_t*) cthread[0]->getMem({CoyoteAlloc::HPF, n_pages_hash});
        auto* rsa_in   = (uint32_t*) cthread[1]->getMem({CoyoteAlloc::HPF, n_pages_hash});
        auto* sig_out  = (uint32_t*) cthread[1]->getMem({CoyoteAlloc::HPF, n_pages_sig});

        // Constant 512-bit chunk (FEDCBA9876543210 × 8) — same input the
        // composed digital_signature app uses.
        for (uint32_t j = 0; j < input_size/4; j += 2) {
            in[j]   = 0x76543210;
            if (j+1 < input_size/4) in[j+1] = 0xFEDCBA98;
        }
        memset(hash_out, 0, HASH_SIZE);
        memset(sig_out,  0, SIG_SIZE);

        sgEntry sg[N_STAGES];
        for (int i = 0; i < N_STAGES; i++) memset(&sg[i], 0, sizeof(localSg));

        sg[0].local.src_addr = in;       sg[0].local.src_len = input_size;
        sg[0].local.src_stream = strmHost; sg[0].local.src_dest = 0;
        sg[0].local.dst_addr = hash_out; sg[0].local.dst_len = HASH_SIZE;
        sg[0].local.dst_stream = strmHost; sg[0].local.dst_dest = 0;

        sg[1].local.src_addr = rsa_in;   sg[1].local.src_len = HASH_SIZE;
        sg[1].local.src_stream = strmHost; sg[1].local.src_dest = 0;
        sg[1].local.dst_addr = sig_out;  sg[1].local.dst_len = SIG_SIZE;
        sg[1].local.dst_stream = strmHost; sg[1].local.dst_dest = 0;

        cBench bench(n_reps);
        for (auto& t : cthread) t->clearCompleted();

        auto benchmark_thr = [&]() {
            for (uint32_t r = 0; r < n_reps; r++) {
                cthread[0]->invoke(CoyoteOper::LOCAL_TRANSFER, &sg[0], {true, true, false});
                while (cthread[0]->checkCompleted(CoyoteOper::LOCAL_WRITE) != r + 1) {
                    if (stalled.load()) throw std::runtime_error("Stalled at SHA");
                }
                memcpy(rsa_in, hash_out, HASH_SIZE);

                cthread[1]->invoke(CoyoteOper::LOCAL_TRANSFER, &sg[1], {true, true, false});
                while (cthread[1]->checkCompleted(CoyoteOper::LOCAL_WRITE) != r + 1) {
                    if (stalled.load()) throw std::runtime_error("Stalled at RSA");
                }
            }
        };
        bench.runtime(benchmark_thr);

        PR_HEADER("LATENCY MEASUREMENTS");
        printLatencyStats(bench.getAvg() / n_reps, input_size, n_reps);

        for (auto& t : cthread) t->printDebug();
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}
