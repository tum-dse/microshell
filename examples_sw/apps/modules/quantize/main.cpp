/**
 * Quantizer module bring-up: feeds synthetic FFT-style data into the
 * standalone quantizer vFPGA and inspects the quantization-bin histogram.
 */

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
#include <complex>
#include <cmath>
#include <vector>
#ifdef EN_AVX
#include <x86intrin.h>
#endif
#include <boost/program_options.hpp>
#include <any>
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
constexpr auto const defSize = 512;

// Helper function to print latency statistics.
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

// Mix of fundamental + first two harmonics so the resulting magnitudes span
// every quantization bin (A..P).
void generateFFTData(int32_t* data, uint32_t num_samples, float freq = 1000.0f, float sample_rate = 44100.0f) {
    for(uint32_t i = 0; i < num_samples; i++) {
        float t = i / sample_rate;

        float real = 100.0f * sin(2 * M_PI * freq * t) +
                     50.0f * sin(2 * M_PI * freq * 2 * t) +
                     10.0f * sin(2 * M_PI * freq * 4 * t);

        float imag = 100.0f * cos(2 * M_PI * freq * t) +
                     50.0f * cos(2 * M_PI * freq * 2 * t) +
                     10.0f * cos(2 * M_PI * freq * 4 * t);

        data[2*i]     = (int32_t)real;
        data[2*i + 1] = (int32_t)imag;
    }
}

// Map an output byte from the quantizer back to its bin label.
std::string interpretQuantizedByte(uint8_t byte) {
    switch(byte) {
        case 0x41: return "A (Very Low)";
        case 0x42: return "B (Low)";
        case 0x43: return "C (Medium)";
        case 0x44: return "D (High)";
        case 0x50: return "P (Peak)";
        default: return "Unknown";
    }
}

int main(int argc, char *argv[])
{
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    boost::program_options::options_description programDescription("Options:");
    programDescription.add_options()
        ("size,s", boost::program_options::value<uint32_t>(), "Buffer size in bytes (must be multiple of 512)")
        ("reps,r", boost::program_options::value<uint32_t>(), "Number of reps")
        ("freq,f", boost::program_options::value<float>(), "Test frequency in Hz (default 1000)");

    boost::program_options::variables_map commandLineArgs;
    boost::program_options::store(boost::program_options::parse_command_line(argc, argv, programDescription),
                                commandLineArgs);
    boost::program_options::notify(commandLineArgs);

    uint32_t size_bytes = defSize;
    uint32_t n_reps = defReps;
    float test_freq = 1000.0f;

    if(commandLineArgs.count("size") > 0) size_bytes = commandLineArgs["size"].as<uint32_t>();
    if(commandLineArgs.count("reps") > 0) n_reps = commandLineArgs["reps"].as<uint32_t>();
    if(commandLineArgs.count("freq") > 0) test_freq = commandLineArgs["freq"].as<float>();

    // 64 complex int32 pairs per chunk (512 bytes).
    constexpr uint32_t min_chunk_bytes = 64 * 2 * sizeof(int32_t);
    if(size_bytes % min_chunk_bytes != 0) {
        uint32_t adjusted_size = ((size_bytes + min_chunk_bytes - 1) / min_chunk_bytes) * min_chunk_bytes;
        std::cout << "Warning: Size must be multiple of " << min_chunk_bytes
                  << " bytes. Adjusting " << size_bytes << " to " << adjusted_size << " bytes" << std::endl;
        size_bytes = adjusted_size;
    }

    uint32_t input_buffer_size = size_bytes;
    uint32_t num_complex_samples = input_buffer_size / (2 * sizeof(int32_t));
    uint32_t output_buffer_size = num_complex_samples;

    if(output_buffer_size % 64 != 0) {
        output_buffer_size = ((output_buffer_size + 63) / 64) * 64;
    }

    uint32_t n_pages_input = (input_buffer_size + hugePageSize - 1) / hugePageSize;
    uint32_t n_pages_output = (output_buffer_size + hugePageSize - 1) / hugePageSize;

    PR_HEADER("PARAMS");
    std::cout << "vFPGA ID: " << targetVfid << std::endl;
    std::cout << "Input buffer size: " << input_buffer_size << " bytes" << std::endl;
    std::cout << "Output buffer size: " << output_buffer_size << " bytes" << std::endl;
    std::cout << "Number of complex samples: " << num_complex_samples << std::endl;
    std::cout << "Test frequency: " << test_freq << " Hz" << std::endl;
    std::cout << "Number of reps: " << n_reps << std::endl;

    try {
        std::unique_ptr<cThread<std::any>> cthread(new cThread<std::any>(targetVfid, getpid(), defDevice));
        cthread->start();

        std::vector<int32_t*> input_data(n_reps, nullptr);
        std::vector<uint8_t*> output_data(n_reps, nullptr);

        for(int i = 0; i < n_reps; i++) {
            input_data[i] = (int32_t*) cthread->getMem({CoyoteAlloc::HPF, n_pages_input});
            output_data[i] = (uint8_t*) cthread->getMem({CoyoteAlloc::HPF, n_pages_output});

            if (!input_data[i] || !output_data[i]) {
                throw std::runtime_error("Memory allocation failed");
            }

            // Slight per-rep frequency offset so reps don't produce identical inputs.
            float freq_multiplier = 1.0f + (i * 0.1f);
            generateFFTData(input_data[i], num_complex_samples, test_freq * freq_multiplier);

            memset(output_data[i], 0, output_buffer_size);
        }

        std::cout << "\nInput data samples (first 8 complex values):\n";
        for(int i = 0; i < std::min(8u, num_complex_samples); i++) {
            int32_t real = input_data[0][2*i];
            int32_t imag = input_data[0][2*i + 1];
            int32_t mag_approx = std::abs(real) + std::abs(imag);

            std::cout << "Sample " << i << ": Real=" << std::setw(6) << real
                      << ", Imag=" << std::setw(6) << imag
                      << ", Mag≈" << std::setw(6) << mag_approx;

            if (mag_approx < 500) std::cout << " -> A";
            else if (mag_approx < 5000) std::cout << " -> B";
            else if (mag_approx < 25000) std::cout << " -> C";
            else if (mag_approx < 100000) std::cout << " -> D";
            else std::cout << " -> P";

            std::cout << std::endl;
        }
        std::cout << std::endl;

        sgEntry sg;
        sgFlags sg_flags = { true, true, false };

        cBench bench(n_reps);
        PR_HEADER("FFT QUANTIZATION");

        cthread->clearCompleted();

        auto benchmark_thr = [&]() {
            for(int i = 0; i < n_reps; i++) {
                memset(&sg, 0, sizeof(localSg));
                sg.local.src_addr = input_data[i];
                sg.local.src_len = input_buffer_size;
                sg.local.src_stream = strmHost;
                sg.local.src_dest = targetVfid;

                sg.local.dst_addr = output_data[i];
                sg.local.dst_len = output_buffer_size;
                sg.local.dst_stream = strmHost;
                sg.local.dst_dest = targetVfid;

                sg_flags.last = (i == n_reps-1);

                cthread->invoke(CoyoteOper::LOCAL_TRANSFER, &sg, sg_flags);
            }

            while(cthread->checkCompleted(CoyoteOper::LOCAL_TRANSFER) != n_reps) {
                if(stalled.load()) throw std::runtime_error("Stalled");
            }
        };

        bench.runtime(benchmark_thr);

        PR_HEADER("LATENCY MEASUREMENTS");
        printLatencyStats(bench.getAvg() / n_reps, input_buffer_size, n_reps);

        double samples_per_sec = (1000000000.0 * num_complex_samples) / (bench.getAvg() / n_reps);
        std::cout << "Sample rate: " << std::setw(10) << (samples_per_sec / 1000000.0) << " MSamples/s" << std::endl;

        PR_HEADER("RESULTS SUMMARY");

        std::map<uint8_t, int> quant_counts;
        for(int i = 0; i < n_reps; i++) {
            for(int j = 0; j < num_complex_samples; j++) {
                if(output_data[i][j] != 0) {
                    quant_counts[output_data[i][j]]++;
                }
            }
        }

        std::cout << "Quantization distribution:\n";
        for(const auto& [byte, count] : quant_counts) {
            std::cout << "  " << interpretQuantizedByte(byte)
                      << ": " << count << " samples ("
                      << std::fixed << std::setprecision(1)
                      << (100.0 * count / (n_reps * num_complex_samples)) << "%)"
                      << std::endl;
        }

        std::cout << "\nFirst 64 quantized outputs:\n";
        for(int i = 0; i < std::min(64u, num_complex_samples); i += 16) {
            std::cout << "  [" << std::setw(3) << i << "-"
                      << std::setw(3) << std::min(i+15, (int)num_complex_samples-1) << "]: ";

            for(int j = 0; j < 16 && (i+j) < num_complex_samples; j++) {
                char c = (char)output_data[0][i+j];
                if(c >= 'A' && c <= 'P') {
                    std::cout << c;
                } else {
                    std::cout << ".";
                }
            }
            std::cout << std::endl;
        }

        for(int i = 0; i < n_reps; i++) {
            if(input_data[i]) {
                cthread->freeMem(input_data[i]);
                input_data[i] = nullptr;
            }
            if(output_data[i]) {
                cthread->freeMem(output_data[i]);
                output_data[i] = nullptr;
            }
        }

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
