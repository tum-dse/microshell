/**
 * Audio Processing — CPU-sync variant (FFT → Quantize → RLE).
 *
 * Drives the audio_processing_cpusync bitstream where each module sits on
 * its own vFPGA. The host CPU sequentially invokes each stage and shuttles
 * intermediate buffers between them, modelling the natural Coyote pattern
 * the µShell paper compares against in Figure 3 (direct_comm_effectiveness).
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
#include <random>
#include <cmath>

#include "cBench.hpp"
#include "cThread.hpp"

using namespace std;
using namespace fpga;

std::atomic<bool> stalled(false);
void gotInt(int) { stalled.store(true); }

constexpr auto const defDevice = 0;
constexpr auto const defReps   = 1;
// One Quantize chunk = 64 complex samples (512 B). Going below that hangs
// the cpu_sync pipeline at the Quantize stage because the host DMA can't
// flush a partial chunk out — unlike the composed app where AXI-stream
// TLAST handles tail data on-chip. Default to 64; user -s rounds up.
constexpr auto const defSize   = 64;
constexpr auto const N_STAGES  = 3;        // FFT, Quantize, RLE

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
        ("size,s", boost::program_options::value<uint32_t>(), "Audio samples (multiple of 64)")
        ("reps,r", boost::program_options::value<uint32_t>(), "Number of reps");
    boost::program_options::variables_map vm;
    boost::program_options::store(boost::program_options::parse_command_line(argc, argv, opts), vm);
    boost::program_options::notify(vm);

    uint32_t size   = vm.count("size") ? vm["size"].as<uint32_t>() : defSize;
    uint32_t n_reps = vm.count("reps") ? vm["reps"].as<uint32_t>() : defReps;
    // Round up to a multiple of 64 — that's the Quantize chunk size in
    // complex samples (64 × 8 B/sample = 512 B). Any smaller and the host
    // DMA can't flush the tail out of Quantize → pipeline stalls.
    if (size % 64 != 0) size = ((size + 63) / 64) * 64;

    // Per-stage byte sizes match the composed-pipeline contract:
    //   FFT:      complex floats in/out (2 * size * 4 B)
    //   Quantize: complex floats in, 1 byte/sample out (size B)
    //   RLE:      bytes in, 64 B per chunk out
    uint32_t fft_buf  = 2 * size * sizeof(float);
    uint32_t quant_buf = size;
    uint32_t rle_buf   = ((size + 63) / 64) * 64;

    uint32_t n_pages_fft   = (fft_buf  + hugePageSize - 1) / hugePageSize;
    uint32_t n_pages_quant = (quant_buf + hugePageSize - 1) / hugePageSize;
    uint32_t n_pages_rle   = (rle_buf   + hugePageSize - 1) / hugePageSize;

    PR_HEADER("PARAMS (CPU-sync)");
    std::cout << "Pipeline: FFT(vFPGA0) -> Quantize(vFPGA1) -> RLE(vFPGA2)" << std::endl;
    std::cout << "Audio samples:    " << size << std::endl;
    std::cout << "FFT buffer:       " << fft_buf  << " bytes" << std::endl;
    std::cout << "Quant buffer:     " << quant_buf << " bytes" << std::endl;
    std::cout << "RLE buffer:       " << rle_buf   << " bytes" << std::endl;
    std::cout << "Reps:             " << n_reps << std::endl;

    try {
        // One cThread per stage: each owns its vFPGA region and host-pinned buffers.
        std::vector<std::unique_ptr<cThread<std::any>>> cthread;
        for (int i = 0; i < N_STAGES; i++)
            cthread.emplace_back(new cThread<std::any>(i, getpid(), defDevice));
        for (auto& t : cthread) t->start();

        // Stage 0 (FFT): in/out are complex floats (same byte count).
        // Stage 1 (Quantize): consumes FFT output (fft_buf bytes), emits quant_buf bytes.
        // Stage 2 (RLE):     consumes quant_buf bytes, emits rle_buf bytes.
        auto* fft_in   = (float*) cthread[0]->getMem({CoyoteAlloc::HPF, n_pages_fft});
        auto* fft_out  = (float*) cthread[0]->getMem({CoyoteAlloc::HPF, n_pages_fft});
        auto* q_in     = (float*) cthread[1]->getMem({CoyoteAlloc::HPF, n_pages_fft});
        auto* q_out    = (uint8_t*) cthread[1]->getMem({CoyoteAlloc::HPF, n_pages_quant});
        auto* rle_in   = (uint8_t*) cthread[2]->getMem({CoyoteAlloc::HPF, n_pages_quant});
        auto* rle_out  = (uint8_t*) cthread[2]->getMem({CoyoteAlloc::HPF, n_pages_rle});

        // Random complex audio input — same generator as the composed app.
        std::random_device rd; std::mt19937 gen(rd());
        std::uniform_real_distribution<float> dist(-15000.0f, 15000.0f);
        for (uint32_t i = 0; i < size; i++) {
            fft_in[2*i]     = dist(gen);
            fft_in[2*i + 1] = 0.0f;
        }
        memset(fft_out, 0, fft_buf);
        memset(q_out,   0, quant_buf);
        memset(rle_out, 0, rle_buf);

        sgEntry sg[N_STAGES];
        for (int i = 0; i < N_STAGES; i++) memset(&sg[i], 0, sizeof(localSg));

        // Stage 0: FFT (fft_in -> fft_out)
        sg[0].local.src_addr = fft_in;  sg[0].local.src_len = fft_buf;
        sg[0].local.src_stream = strmHost; sg[0].local.src_dest = 0;
        sg[0].local.dst_addr = fft_out; sg[0].local.dst_len = fft_buf;
        sg[0].local.dst_stream = strmHost; sg[0].local.dst_dest = 0;
        // Stage 1: Quantize (q_in -> q_out)
        sg[1].local.src_addr = q_in;    sg[1].local.src_len = fft_buf;
        sg[1].local.src_stream = strmHost; sg[1].local.src_dest = 0;
        sg[1].local.dst_addr = q_out;   sg[1].local.dst_len = quant_buf;
        sg[1].local.dst_stream = strmHost; sg[1].local.dst_dest = 0;
        // Stage 2: RLE (rle_in -> rle_out)
        sg[2].local.src_addr = rle_in;  sg[2].local.src_len = quant_buf;
        sg[2].local.src_stream = strmHost; sg[2].local.src_dest = 0;
        sg[2].local.dst_addr = rle_out; sg[2].local.dst_len = rle_buf;
        sg[2].local.dst_stream = strmHost; sg[2].local.dst_dest = 0;

        cBench bench(n_reps);
        for (auto& t : cthread) t->clearCompleted();

        // Sequential CPU-driven invocation. Each stage waits for the previous
        // to complete, then a memcpy hands the data off to the next stage's
        // pinned input buffer — modelling host-shuttled pipelining.
        auto benchmark_thr = [&]() {
            for (uint32_t r = 0; r < n_reps; r++) {
                cthread[0]->invoke(CoyoteOper::LOCAL_TRANSFER, &sg[0], {true, true, false});
                while (cthread[0]->checkCompleted(CoyoteOper::LOCAL_WRITE) != r + 1) {
                    if (stalled.load()) throw std::runtime_error("Stalled at FFT");
                }
                memcpy(q_in, fft_out, fft_buf);

                cthread[1]->invoke(CoyoteOper::LOCAL_TRANSFER, &sg[1], {true, true, false});
                while (cthread[1]->checkCompleted(CoyoteOper::LOCAL_WRITE) != r + 1) {
                    if (stalled.load()) throw std::runtime_error("Stalled at Quantize");
                }
                memcpy(rle_in, q_out, quant_buf);

                cthread[2]->invoke(CoyoteOper::LOCAL_TRANSFER, &sg[2], {true, true, false});
                while (cthread[2]->checkCompleted(CoyoteOper::LOCAL_WRITE) != r + 1) {
                    if (stalled.load()) throw std::runtime_error("Stalled at RLE");
                }
            }
        };
        bench.runtime(benchmark_thr);

        PR_HEADER("LATENCY MEASUREMENTS");
        // Throughput is reported relative to the input audio (fft_buf bytes),
        // matching the composed-app convention so the two are comparable.
        printLatencyStats(bench.getAvg() / n_reps, fft_buf, n_reps);

        for (auto& t : cthread) t->printDebug();
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}
