/**
 * Secure Storage — CPU-sync variant (RLE → AES-CTR).
 *
 * Drives the secure_storage_cpusync bitstream where each module sits on its
 * own vFPGA. The host CPU sequentially invokes the RLE compressor and AES
 * encryptor, copying the compressed buffer between them — modelling the
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

constexpr auto const defDevice = 0;
constexpr auto const defReps   = 1;
constexpr auto const defSize   = 64 * 1024;     // 64 KB plaintext (matches composed app)
constexpr auto const N_STAGES  = 2;

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
        ("size,s", boost::program_options::value<uint32_t>(), "Plaintext bytes (multiple of 64)")
        ("reps,r", boost::program_options::value<uint32_t>(), "Number of reps");
    boost::program_options::variables_map vm;
    boost::program_options::store(boost::program_options::parse_command_line(argc, argv, opts), vm);
    boost::program_options::notify(vm);

    uint32_t size   = vm.count("size") ? vm["size"].as<uint32_t>() : defSize;
    uint32_t n_reps = vm.count("reps") ? vm["reps"].as<uint32_t>() : defReps;
    if (size % 64 != 0) size = ((size + 63) / 64) * 64;

    // RLE compresses 64-byte chunks down to 32 bytes worst-case (count,value)
    // pairs; AES output equals its input size.
    uint32_t rle_in_buf  = size;
    uint32_t rle_out_buf = size;
    uint32_t aes_buf     = size;

    uint32_t n_pages = (size + hugePageSize - 1) / hugePageSize;

    PR_HEADER("PARAMS (CPU-sync)");
    std::cout << "Pipeline: RLE(vFPGA0) -> AES-CTR(vFPGA1)" << std::endl;
    std::cout << "Plaintext: " << size << " bytes" << std::endl;
    std::cout << "Reps:      " << n_reps << std::endl;

    try {
        std::vector<std::unique_ptr<cThread<std::any>>> cthread;
        for (int i = 0; i < N_STAGES; i++)
            cthread.emplace_back(new cThread<std::any>(i, getpid(), defDevice));
        for (auto& t : cthread) t->start();

        auto* in        = (uint8_t*) cthread[0]->getMem({CoyoteAlloc::HPF, n_pages});
        auto* compressed = (uint8_t*) cthread[0]->getMem({CoyoteAlloc::HPF, n_pages});
        auto* aes_in    = (uint8_t*) cthread[1]->getMem({CoyoteAlloc::HPF, n_pages});
        auto* aes_out   = (uint8_t*) cthread[1]->getMem({CoyoteAlloc::HPF, n_pages});

        // Compressible regular pattern (4-byte runs cycling A..P) — gives
        // a roughly 2:1 RLE ratio just like the composed app.
        for (uint32_t i = 0; i < size; i++) in[i] = 'A' + ((i / 4) % 16);
        memset(compressed, 0, rle_out_buf);
        memset(aes_out,    0, aes_buf);

        sgEntry sg[N_STAGES];
        for (int i = 0; i < N_STAGES; i++) memset(&sg[i], 0, sizeof(localSg));

        sg[0].local.src_addr = in;         sg[0].local.src_len = rle_in_buf;
        sg[0].local.src_stream = strmHost; sg[0].local.src_dest = 0;
        sg[0].local.dst_addr = compressed; sg[0].local.dst_len = rle_out_buf;
        sg[0].local.dst_stream = strmHost; sg[0].local.dst_dest = 0;

        sg[1].local.src_addr = aes_in;     sg[1].local.src_len = rle_out_buf;
        sg[1].local.src_stream = strmHost; sg[1].local.src_dest = 0;
        sg[1].local.dst_addr = aes_out;    sg[1].local.dst_len = aes_buf;
        sg[1].local.dst_stream = strmHost; sg[1].local.dst_dest = 0;

        cBench bench(n_reps);
        for (auto& t : cthread) t->clearCompleted();

        auto benchmark_thr = [&]() {
            for (uint32_t r = 0; r < n_reps; r++) {
                cthread[0]->invoke(CoyoteOper::LOCAL_TRANSFER, &sg[0], {true, true, false});
                while (cthread[0]->checkCompleted(CoyoteOper::LOCAL_WRITE) != r + 1) {
                    if (stalled.load()) throw std::runtime_error("Stalled at RLE");
                }
                memcpy(aes_in, compressed, rle_out_buf);

                cthread[1]->invoke(CoyoteOper::LOCAL_TRANSFER, &sg[1], {true, true, false});
                while (cthread[1]->checkCompleted(CoyoteOper::LOCAL_WRITE) != r + 1) {
                    if (stalled.load()) throw std::runtime_error("Stalled at AES");
                }
            }
        };
        bench.runtime(benchmark_thr);

        PR_HEADER("LATENCY MEASUREMENTS");
        printLatencyStats(bench.getAvg() / n_reps, size, n_reps);

        for (auto& t : cthread) t->printDebug();
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}
