/**
 * Quantizer module bring-up (DFG version): drives the standalone
 * quantizer vFPGA with synthetic FFT data and analyses the bin histogram.
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
#include <map>
#include <cstring>
#include <boost/program_options.hpp>
#include <any>

#include "dfg.hpp"
#include "ushell.hpp"

using namespace std;
using namespace std::chrono;
using namespace fpga;
using namespace ushell;

std::atomic<bool> stalled(false);
void gotInt(int) {
    stalled.store(true);
}

constexpr auto const defDevice = 0;
constexpr auto const nRegions = 1;
constexpr auto const defHuge = true;
constexpr auto const defMapped = true;
constexpr auto const defStream = 1;
constexpr auto const nRepsThr = 1;
constexpr auto const nRepsLat = 1;
constexpr auto const defSize = 512;
constexpr auto const nBenchRuns = 1;

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

// Coloured red bold section banner.
void print_header(const std::string& header) {
    std::cout << "\n-- \033[31m\e[1m" << header << "\033[0m\e[0m" << std::endl;
    std::cout << "-----------------------------------------------" << std::endl;
}

int main(int argc, char *argv[])
{
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    boost::program_options::options_description programDescription("FFT Quantization Pipeline Options:");
    programDescription.add_options()
        ("bitstream,b", boost::program_options::value<string>(), "Shell bitstream")
        ("device,d", boost::program_options::value<uint32_t>(), "Target device")
        ("regions,g", boost::program_options::value<uint32_t>(), "Number of vFPGAs")
        ("size,s", boost::program_options::value<uint32_t>(), "Buffer size in bytes (must be multiple of 512)")
        ("reps,r", boost::program_options::value<uint32_t>(), "Number of reps")
        ("freq,f", boost::program_options::value<float>(), "Test frequency in Hz (default 1000)")
        ("hugepages,h", boost::program_options::value<bool>(), "Use hugepages (default: true)")
        ("mapped,m", boost::program_options::value<bool>(), "Use mapped memory (default: true)")
        ("stream,t", boost::program_options::value<bool>(), "Use streaming interface (default: true)")
        ("help", "Show help message");

    boost::program_options::variables_map commandLineArgs;
    boost::program_options::store(boost::program_options::parse_command_line(argc, argv, programDescription),
                                commandLineArgs);
    boost::program_options::notify(commandLineArgs);

    if(commandLineArgs.count("help")) {
        std::cout << programDescription << std::endl;
        return EXIT_SUCCESS;
    }

    string bstream_path = "";
    uint32_t cs_dev = defDevice;
    uint32_t n_regions = nRegions;
    uint32_t size_bytes = defSize;
    uint32_t n_reps = nRepsLat;
    float test_freq = 1000.0f;
    bool huge = defHuge;
    bool mapped = defMapped;
    bool stream = defStream;

    if(commandLineArgs.count("bitstream") > 0) {
        bstream_path = commandLineArgs["bitstream"].as<string>();

        std::cout << std::endl << "Shell loading (path: " << bstream_path << ") ..." << std::endl;
        cRnfg crnfg(cs_dev);
        crnfg.shellReconfigure(bstream_path);
    }
    if(commandLineArgs.count("device") > 0) cs_dev = commandLineArgs["device"].as<uint32_t>();
    if(commandLineArgs.count("regions") > 0) n_regions = commandLineArgs["regions"].as<uint32_t>();
    if(commandLineArgs.count("size") > 0) size_bytes = commandLineArgs["size"].as<uint32_t>();
    if(commandLineArgs.count("reps") > 0) n_reps = commandLineArgs["reps"].as<uint32_t>();
    if(commandLineArgs.count("freq") > 0) test_freq = commandLineArgs["freq"].as<float>();
    if(commandLineArgs.count("hugepages") > 0) huge = commandLineArgs["hugepages"].as<bool>();
    if(commandLineArgs.count("mapped") > 0) mapped = commandLineArgs["mapped"].as<bool>();
    if(commandLineArgs.count("stream") > 0) stream = commandLineArgs["stream"].as<bool>();

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

    print_header("PARAMS");
    std::cout << "Pipeline: FFT Quantization" << std::endl;
    std::cout << "Number of regions: " << n_regions << std::endl;
    std::cout << "Input buffer size: " << input_buffer_size << " bytes" << std::endl;
    std::cout << "Output buffer size: " << output_buffer_size << " bytes" << std::endl;
    std::cout << "Number of complex samples: " << num_complex_samples << std::endl;
    std::cout << "Test frequency: " << test_freq << " Hz" << std::endl;
    std::cout << "Number of reps: " << n_reps << std::endl;
    std::cout << "Hugepages: " << huge << std::endl;
    std::cout << "Mapped: " << mapped << std::endl;
    std::cout << "Streaming: " << (stream ? "HOST" : "CARD") << std::endl;

    try {
        print_header("DATAFLOW SETUP");

        Dataflow quant_dataflow("fft_quantization_pipeline");

        Task& fft_quantizer = quant_dataflow.add_task("fft_quantizer", "quantization");

        Buffer& fft_input_buffer = quant_dataflow.add_buffer(input_buffer_size, "fft_input_buffer");
        Buffer& quantized_buffer = quant_dataflow.add_buffer(output_buffer_size, "quantized_buffer");

        quant_dataflow.to(fft_input_buffer, fft_quantizer.in)
                     .to(fft_quantizer.out, quantized_buffer);

        std::cout << "Creating FFT quantization dataflow:" << std::endl;
        std::cout << "  fft_input_buffer → fft_quantizer → quantized_buffer" << std::endl;

        if (!quant_dataflow.check()) {
            throw std::runtime_error("Failed to validate dataflow");
        }

        print_header("DATA GENERATION");

        std::vector<std::vector<int32_t>> test_data(n_reps);
        std::vector<std::vector<uint8_t>> result_data(n_reps);

        for(int i = 0; i < n_reps; i++) {
            test_data[i].resize(input_buffer_size / sizeof(int32_t));
            result_data[i].resize(output_buffer_size);

            // Slight per-rep frequency offset so reps don't produce identical inputs.
            float freq_multiplier = 1.0f + (i * 0.1f);
            generateFFTData(test_data[i].data(), num_complex_samples, test_freq * freq_multiplier);
        }

        std::cout << "\nInput data samples (first 8 complex values):\n";
        for(int i = 0; i < std::min(8u, num_complex_samples); i++) {
            int32_t real = test_data[0][2*i];
            int32_t imag = test_data[0][2*i + 1];
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

        print_header("FFT QUANTIZATION");

        cBench bench(n_reps);

        auto benchmark_thr = [&]() {
            for(int i = 0; i < n_reps; i++) {
                write_dataflow_buffer(fft_input_buffer, test_data[i].data(), input_buffer_size);
                quant_dataflow.clear_completed();
                quant_dataflow.execute(input_buffer_size);
                read_dataflow_buffer(quantized_buffer, result_data[i].data(), output_buffer_size);
            }
        };

        bench.runtime(benchmark_thr);

        print_header("LATENCY MEASUREMENTS");
        printLatencyStats(bench.getAvg() / n_reps, input_buffer_size, n_reps);

        print_header("RESULTS SUMMARY");

        std::map<uint8_t, int> quant_counts;
        for(int i = 0; i < n_reps; i++) {
            for(int j = 0; j < num_complex_samples; j++) {
                if(result_data[i][j] != 0) {
                    quant_counts[result_data[i][j]]++;
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
                char c = (char)result_data[0][i+j];
                if(c >= 'A' && c <= 'P') {
                    std::cout << c;
                } else {
                    std::cout << ".";
                }
            }
            std::cout << std::endl;
        }

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }

    print_header("FFT QUANTIZATION COMPLETE");
    std::cout << "FFT quantization pipeline executed successfully!" << std::endl;

    return EXIT_SUCCESS;
}
