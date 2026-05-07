/**
 * Speech Recognition — CPU-sync variant (FFT → SVM).
 *
 * Drives the speech_recognition_cpusync bitstream where each module sits on
 * its own vFPGA. The host CPU sequentially invokes FFT then SVM, copying
 * the FFT magnitudes into the SVM input buffer — modelling the Coyote
 * pattern compared in Figure 3 (direct_comm_effectiveness).
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
constexpr auto const defSize   = 32;       // complex samples (must be %32)
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
        ("size,s", boost::program_options::value<uint32_t>(), "Audio samples (multiple of 32)")
        ("reps,r", boost::program_options::value<uint32_t>(), "Number of reps");
    boost::program_options::variables_map vm;
    boost::program_options::store(boost::program_options::parse_command_line(argc, argv, opts), vm);
    boost::program_options::notify(vm);

    uint32_t size   = vm.count("size") ? vm["size"].as<uint32_t>() : defSize;
    uint32_t n_reps = vm.count("reps") ? vm["reps"].as<uint32_t>() : defReps;
    if (size % 32 != 0) size = ((size + 31) / 32) * 32;

    uint32_t num_ffts = size / 32;
    uint32_t fft_buf  = 2 * size * sizeof(float);          // complex floats
    uint32_t svm_out_buf = num_ffts * sizeof(float);       // one classification per 32 samples

    uint32_t n_pages_fft = (fft_buf + hugePageSize - 1) / hugePageSize;
    uint32_t n_pages_svm = (svm_out_buf + hugePageSize - 1) / hugePageSize;

    PR_HEADER("PARAMS (CPU-sync)");
    std::cout << "Pipeline: FFT(vFPGA0) -> SVM(vFPGA1)" << std::endl;
    std::cout << "Audio samples: " << size << " (" << num_ffts << " classifications)" << std::endl;
    std::cout << "FFT buffer:    " << fft_buf << " bytes" << std::endl;
    std::cout << "SVM output:    " << svm_out_buf << " bytes" << std::endl;
    std::cout << "Reps:          " << n_reps << std::endl;

    // Reference 32-sample magnitude pattern that produces a known SVM result
    // — same as the composed speech_recognition app.
    static const float base_pattern[32] = {
        36257662.0f, 70308074.0f, 162763557.0f, 109956489.0f, 86125933.0f,
        35535698.0f, 5473712.0f, 2191429.0f, 1655529.0f, 1427210.0f,
        1819290.0f, 2594503.0f, 2649694.0f, 849597.0f, 765175.0f,
        890647.0f, 1405332.0f, 1132804.0f, 5776375.0f, 18372118.0f,
        6724989.0f, 7313762.0f, 1469345.0f, 1744257.0f, 1631652.0f,
        823229.0f, 1018674.0f, 639273.0f, 601445.0f, 630083.0f,
        678854.0f, 636897.0f
    };

    try {
        std::vector<std::unique_ptr<cThread<std::any>>> cthread;
        for (int i = 0; i < N_STAGES; i++)
            cthread.emplace_back(new cThread<std::any>(i, getpid(), defDevice));
        for (auto& t : cthread) t->start();

        auto* fft_in  = (float*) cthread[0]->getMem({CoyoteAlloc::HPF, n_pages_fft});
        auto* fft_out = (float*) cthread[0]->getMem({CoyoteAlloc::HPF, n_pages_fft});
        auto* svm_in  = (float*) cthread[1]->getMem({CoyoteAlloc::HPF, n_pages_fft});
        auto* svm_out = (float*) cthread[1]->getMem({CoyoteAlloc::HPF, n_pages_svm});

        for (uint32_t f = 0; f < num_ffts; f++) {
            for (uint32_t s = 0; s < 32; s++) {
                uint32_t idx = (f * 32 + s) * 2;
                fft_in[idx]     = base_pattern[s] + (f * 1000.0f);
                fft_in[idx + 1] = 0.0f;
            }
        }
        memset(fft_out, 0, fft_buf);
        memset(svm_out, 0, svm_out_buf);

        sgEntry sg[N_STAGES];
        for (int i = 0; i < N_STAGES; i++) memset(&sg[i], 0, sizeof(localSg));

        sg[0].local.src_addr = fft_in;  sg[0].local.src_len = fft_buf;
        sg[0].local.src_stream = strmHost; sg[0].local.src_dest = 0;
        sg[0].local.dst_addr = fft_out; sg[0].local.dst_len = fft_buf;
        sg[0].local.dst_stream = strmHost; sg[0].local.dst_dest = 0;

        sg[1].local.src_addr = svm_in;  sg[1].local.src_len = fft_buf;
        sg[1].local.src_stream = strmHost; sg[1].local.src_dest = 1;
        sg[1].local.dst_addr = svm_out; sg[1].local.dst_len = svm_out_buf;
        sg[1].local.dst_stream = strmHost; sg[1].local.dst_dest = 1;

        cBench bench(n_reps);
        for (auto& t : cthread) t->clearCompleted();

        auto benchmark_thr = [&]() {
            for (uint32_t r = 0; r < n_reps; r++) {
                cthread[0]->invoke(CoyoteOper::LOCAL_TRANSFER, &sg[0], {true, true, false});
                while (cthread[0]->checkCompleted(CoyoteOper::LOCAL_WRITE) != r + 1) {
                    if (stalled.load()) throw std::runtime_error("Stalled at FFT");
                }
                memcpy(svm_in, fft_out, fft_buf);

                cthread[1]->invoke(CoyoteOper::LOCAL_TRANSFER, &sg[1], {true, true, false});
                while (cthread[1]->checkCompleted(CoyoteOper::LOCAL_WRITE) != r + 1) {
                    if (stalled.load()) throw std::runtime_error("Stalled at SVM");
                }
            }
        };
        bench.runtime(benchmark_thr);

        PR_HEADER("LATENCY MEASUREMENTS");
        printLatencyStats(bench.getAvg() / n_reps, fft_buf, n_reps);

        for (auto& t : cthread) t->printDebug();
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}
