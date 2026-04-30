#include <iostream>
#include <string>
#include <malloc.h>
#include <time.h>
#include <sys/time.h>
#include <chrono>
#include <fstream>
#include <fcntl.h>
#include <unistd.h>
#include <iomanip>
#include <signal.h>
#ifdef EN_AVX
#include <x86intrin.h>
#endif
#include <boost/program_options.hpp>
#include <any>
#include <cmath>
#include <random>
#include <vector>
#include "cBench.hpp"
#include "cThread.hpp"

using namespace std;
using namespace std::chrono;
using namespace fpga;

std::atomic<bool> stalled(false);
void gotInt(int) {
    stalled.store(true);
}

constexpr auto const defDevice = 0;
constexpr auto const targetVfid = 0;
constexpr auto const defReps = 1;
constexpr auto const defSize = 32;
constexpr auto const defDW = 4;
constexpr float const sampleRate = 44100.0f;

float generateSineValue(int index) {
    const float amplitude = 1000.0f;
    const float frequency = 1378.125f;
    const float phase = 0.0f;

    float t = (float)index / sampleRate;
    return amplitude * sin(2.0f * M_PI * frequency * t + phase);
}

// Wide uniform distribution drives the input across every quantization bin
// (<1, <100, <1000, <10000, >=10000) so the downstream RLE has variety to compress.
void generateCompressibleAudio(float* audio_data, uint32_t input_size) {
    std::cout << "\nGenerating random audio for quantization testing..." << std::endl;

    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<float> dist(-15000.0f, 15000.0f);

    for (uint32_t sample_idx = 0; sample_idx < input_size; ++sample_idx) {
        float real = dist(gen);
        audio_data[2*sample_idx]     = real;
        audio_data[2*sample_idx + 1] = 0.00f;
    }
}

void printRawOutput(uint8_t* output_ptr, int size) {
    std::cout << "\nRaw Pipeline Output:" << std::endl;
    std::cout << "Hex (first 64 bytes): ";
    for(int i = 0; i < min(64, size); i++) {
        std::cout << std::hex << std::setw(2) << std::setfill('0')
                  << static_cast<int>(output_ptr[i]) << " ";
        if ((i + 1) % 16 == 0) std::cout << std::endl << "                      ";
    }
    std::cout << std::dec << std::endl;

    std::cout << "ASCII (first 64 bytes): ";
    for(int i = 0; i < min(64, size); i++) {
        if (output_ptr[i] >= 'A' && output_ptr[i] <= 'Z') {
            std::cout << static_cast<char>(output_ptr[i]);
        } else {
            std::cout << ".";
        }
    }
    std::cout << std::endl;
}

void printLatencyStats(double avg_latency_ns, uint32_t data_size_bytes, uint32_t n_reps) {
    std::cout << std::fixed << std::setprecision(2);
    std::cout << "\nLatency Measurements:" << std::endl;
    std::cout << "Processing started at: 0 ns" << std::endl;
    std::cout << "Processing completed at: " << avg_latency_ns << " ns" << std::endl;
    std::cout << "Total latency: " << avg_latency_ns << " ns (" << (avg_latency_ns / 1000) << " us)" << std::endl;
    std::cout << "Average latency per KB: " << (avg_latency_ns * 1024 / data_size_bytes) << " ns" << std::endl;
    std::cout << "Throughput: " << std::setw(8)
              << (1000.0 * data_size_bytes) / avg_latency_ns
              << " MB/s" << std::endl;
}

int main(int argc, char *argv[]) {
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    boost::program_options::options_description programDescription("Options:");
    programDescription.add_options()
        ("size,s", boost::program_options::value<uint32_t>(), "Audio samples (must be multiple of 32)")
        ("reps,r", boost::program_options::value<uint32_t>(), "Number of reps")
        ("freq,f", boost::program_options::value<float>(), "Input signal frequency (Hz)");

    boost::program_options::variables_map commandLineArgs;
    boost::program_options::store(boost::program_options::parse_command_line(argc, argv, programDescription), commandLineArgs);
    boost::program_options::notify(commandLineArgs);

    uint32_t n_reps = defReps;
    uint32_t size = defSize;

    if(commandLineArgs.count("size") > 0) size = commandLineArgs["size"].as<uint32_t>();
    if(commandLineArgs.count("reps") > 0) n_reps = commandLineArgs["reps"].as<uint32_t>();

    // The FFT IP is fixed at 32-point, so size must be a multiple of 32.
    if(size % 32 != 0) {
        std::cout << "Warning: Size must be multiple of 32. Adjusting " << size
                  << " to " << ((size + 31) / 32) * 32 << std::endl;
        size = ((size + 31) / 32) * 32;
    }

    uint32_t input_size = size;
    uint32_t complex_size = 2 * input_size;
    uint32_t input_buffer_size = complex_size * sizeof(float);
    uint32_t num_ffts = size / 32;

    uint32_t rle_chunks = (input_size + 63) / 64;
    uint32_t output_buffer_size = rle_chunks * 64;

    uint32_t n_pages_input = (input_buffer_size + hugePageSize - 1) / hugePageSize;
    uint32_t n_pages_output = (output_buffer_size + hugePageSize - 1) / hugePageSize;

    PR_HEADER("PARAMS");
    std::cout << "vFPGA ID: " << targetVfid << std::endl;
    std::cout << "Audio samples: " << size << " (" << num_ffts << " x 32-point FFTs)" << std::endl;
    std::cout << "Input buffer: " << input_buffer_size << " bytes" << std::endl;
    std::cout << "Output buffer: " << output_buffer_size << " bytes" << std::endl;
    std::cout << "Number of reps: " << n_reps << std::endl;
    std::cout << "Sample rate: " << sampleRate << " Hz" << std::endl;

    try {
        std::unique_ptr<cThread<std::any>> cthread(new cThread<std::any>(targetVfid, getpid(), defDevice));
        cthread->start();

        std::vector<float*> input_buffers(n_reps, nullptr);
        std::vector<uint8_t*> output_buffers(n_reps, nullptr);

        std::vector<float> audio_data(complex_size, 0.0f);

        generateCompressibleAudio(audio_data.data(), input_size);

        std::cout << "\nFirst 32 audio values:" << std::endl;
        for (uint32_t i = 0; i < min(32U, input_size); ++i) {
            std::cout << std::fixed << std::setprecision(6)
                     << audio_data[2*i] << " " << audio_data[2*i + 1] << " ";
            if ((i + 1) % 4 == 0) std::cout << "\n";
        }
        std::cout << "\n";

        for(int i = 0; i < n_reps; i++) {
            input_buffers[i] = (float*) cthread->getMem({CoyoteAlloc::HPF, n_pages_input});
            output_buffers[i] = (uint8_t*) cthread->getMem({CoyoteAlloc::HPF, n_pages_output});

            if (!input_buffers[i] || !output_buffers[i]) {
                throw std::runtime_error("Memory allocation failed");
            }

            memcpy(input_buffers[i], audio_data.data(), input_buffer_size);
            memset(output_buffers[i], 0, output_buffer_size);
        }

        sgEntry sg;
        sgFlags sg_flags = { true, true, false };

        cBench bench(n_reps);

        cthread->clearCompleted();

        auto benchmark_thr = [&]() {
            for(int i = 0; i < n_reps; i++) {
                memset(&sg, 0, sizeof(localSg));

                sg.local.src_addr = input_buffers[i];
                sg.local.src_len = input_buffer_size;
                sg.local.src_stream = strmHost;
                sg.local.src_dest = targetVfid;

                sg.local.dst_addr = output_buffers[i];
                sg.local.dst_len = output_buffer_size;
                sg.local.dst_stream = strmHost;
                sg.local.dst_dest = targetVfid;

                sg_flags.last = (i == n_reps-1);

                cthread->invoke(CoyoteOper::LOCAL_TRANSFER, &sg, sg_flags);
            }

            while(cthread->checkCompleted(CoyoteOper::LOCAL_WRITE) != 1) {
                if(stalled.load()) throw std::runtime_error("Stalled");
            }
        };

        bench.runtime(benchmark_thr);

        PR_HEADER("LATENCY MEASUREMENTS");
        printLatencyStats(bench.getAvg() / n_reps, input_buffer_size, n_reps);

        PR_HEADER("RESULTS");
        for(int i = 0; i < n_reps; i++) {
            std::cout << "\n--- Pipeline Run #" << (i + 1) << " ---";
            printRawOutput(output_buffers[i], output_buffer_size);
        }

        cthread->printDebug();

        for(int i = 0; i < n_reps; i++) {
            if(input_buffers[i]) {
                cthread->freeMem(input_buffers[i]);
                input_buffers[i] = nullptr;
            }
            if(output_buffers[i]) {
                cthread->freeMem(output_buffers[i]);
                output_buffers[i] = nullptr;
            }
        }

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
