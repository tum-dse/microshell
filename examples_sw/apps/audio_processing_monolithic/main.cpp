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
#include <boost/program_options.hpp>
#include <any>
#include <cmath>
#include <random>
#include <vector>
#include <cstring>

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
constexpr auto const nRegions = 3;
constexpr auto const defHuge = true;
constexpr auto const defMapped = true;
constexpr auto const defStream = 1;
constexpr auto const nRepsThr = 1;
constexpr auto const nRepsLat = 1;
constexpr auto const defSize = 32;
constexpr auto const nBenchRuns = 1;
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

void printRLEOutput(uint8_t* output_ptr, int size) {
    std::cout << "\nRLE Pipeline Output:" << std::endl;

    int pair_count = 0;
    int total_chars = 0;
    int data_chars = 0;
    int padding_chars = 0;

    std::cout << "RLE pairs (count, value):" << std::endl;
    for(int i = 0; i < size - 1; i += 2) {
        uint8_t count = output_ptr[i];
        uint8_t value = output_ptr[i + 1];

        if (count == 0) break;

        pair_count++;
        total_chars += count;

        if (value == 0x00) {
            padding_chars += count;
        } else {
            data_chars += count;
        }

        std::cout << "  [" << std::setw(2) << pair_count-1 << "] ("
                  << std::setw(3) << (int)count << ", ";

        if (value >= 'A' && value <= 'Z') {
            std::cout << "'" << (char)value << "')";
            switch(value) {
                case 'A': std::cout << " - Very Low"; break;
                case 'B': std::cout << " - Low"; break;
                case 'C': std::cout << " - Medium"; break;
                case 'D': std::cout << " - High"; break;
                case 'P': std::cout << " - Peak"; break;
            }
        } else if (value == 0x00) {
            std::cout << "pad) - Padding";
        } else {
            std::cout << "0x" << std::hex << std::setw(2) << std::setfill('0')
                      << (int)value << std::dec << ")";
        }
        std::cout << std::endl;

        if (pair_count >= 20) {
            std::cout << "  ... (showing first 20 pairs)" << std::endl;
            break;
        }
    }

    std::cout << "\nCompression summary:" << std::endl;
    std::cout << "  Total RLE pairs: " << pair_count << std::endl;
    std::cout << "  Data chars: " << data_chars << std::endl;
    std::cout << "  Padding chars: " << padding_chars << std::endl;
    std::cout << "  Total chars: " << total_chars << std::endl;
    std::cout << "  Compressed size: " << (pair_count * 2) << " bytes" << std::endl;
    std::cout << "  Compression ratio: " << std::fixed << std::setprecision(1)
              << (pair_count * 2 * 100.0 / total_chars) << "%" << std::endl;
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

void print_header(const std::string& header) {
    std::cout << "\n-- \033[31m\e[1m" << header << "\033[0m\e[0m" << std::endl;
    std::cout << "-----------------------------------------------" << std::endl;
}

int main(int argc, char *argv[]) {
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    boost::program_options::options_description programDescription("Audio Processing Pipeline Options:");
    programDescription.add_options()
        ("bitstream,b", boost::program_options::value<string>(), "Shell bitstream")
        ("device,d", boost::program_options::value<uint32_t>(), "Target device")
        ("regions,g", boost::program_options::value<uint32_t>(), "Number of vFPGAs")
        ("size,s", boost::program_options::value<uint32_t>(), "Audio samples (must be multiple of 32)")
        ("reps,r", boost::program_options::value<uint32_t>(), "Number of reps")
        ("freq,f", boost::program_options::value<float>(), "Input signal frequency (Hz)")
        ("hugepages,h", boost::program_options::value<bool>(), "Use hugepages (default: true)")
        ("mapped,m", boost::program_options::value<bool>(), "Use mapped memory (default: true)")
        ("stream,t", boost::program_options::value<bool>(), "Use streaming interface (default: true)")
        ("help", "Show help message");

    boost::program_options::variables_map commandLineArgs;
    boost::program_options::store(boost::program_options::parse_command_line(argc, argv, programDescription), commandLineArgs);
    boost::program_options::notify(commandLineArgs);

    if(commandLineArgs.count("help")) {
        std::cout << programDescription << std::endl;
        return EXIT_SUCCESS;
    }

    string bstream_path = "";
    uint32_t cs_dev = defDevice;
    uint32_t n_regions = nRegions;
    uint32_t n_reps = nRepsLat;
    uint32_t size = defSize;
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
    if(commandLineArgs.count("size") > 0) size = commandLineArgs["size"].as<uint32_t>();
    if(commandLineArgs.count("reps") > 0) n_reps = commandLineArgs["reps"].as<uint32_t>();
    if(commandLineArgs.count("hugepages") > 0) huge = commandLineArgs["hugepages"].as<bool>();
    if(commandLineArgs.count("mapped") > 0) mapped = commandLineArgs["mapped"].as<bool>();
    if(commandLineArgs.count("stream") > 0) stream = commandLineArgs["stream"].as<bool>();

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

    uint32_t fft_output_size = input_buffer_size;
    uint32_t quantized_size = input_size;

    uint32_t rle_chunks = (input_size + 63) / 64;
    uint32_t output_buffer_size = rle_chunks * 64;

    print_header("AUDIO PROCESSING PIPELINE");
    std::cout << "Pipeline: FFT → Quantization → RLE Compression" << std::endl;
    std::cout << "Number of regions: " << n_regions << std::endl;
    std::cout << "Audio samples: " << size << " (" << num_ffts << " x 32-point FFTs)" << std::endl;
    std::cout << "Input buffer: " << input_buffer_size << " bytes" << std::endl;
    std::cout << "FFT output: " << fft_output_size << " bytes" << std::endl;
    std::cout << "Quantized size: " << quantized_size << " bytes" << std::endl;
    std::cout << "RLE output buffer: " << output_buffer_size << " bytes" << std::endl;
    std::cout << "Number of reps: " << n_reps << std::endl;
    std::cout << "Sample rate: " << sampleRate << " Hz" << std::endl;
    std::cout << "Hugepages: " << huge << std::endl;
    std::cout << "Mapped: " << mapped << std::endl;
    std::cout << "Streaming: " << (stream ? "HOST" : "CARD") << std::endl;

    try {
        print_header("DATAFLOW SETUP");

        Dataflow audio_dataflow("audio_processing_pipeline");

        Task& fft_processor = audio_dataflow.add_task("fft_processor", "fft");
        Task& quantizer = audio_dataflow.add_task("quantizer", "quantization");
        Task& rle_compressor = audio_dataflow.add_task("rle_compressor", "compression");

        Buffer& audio_input_buffer = audio_dataflow.add_buffer(input_buffer_size, "audio_input_buffer");
        Buffer& fft_output_buffer = audio_dataflow.add_buffer(fft_output_size, "fft_output_buffer");
        Buffer& quantized_buffer = audio_dataflow.add_buffer(quantized_size, "quantized_buffer");
        Buffer& compressed_buffer = audio_dataflow.add_buffer(output_buffer_size, "compressed_buffer");

        audio_dataflow.to(audio_input_buffer, fft_processor.in)
                     .to(fft_processor.out, fft_output_buffer)
                     .to(fft_output_buffer, quantizer.in)
                     .to(quantizer.out, quantized_buffer)
                     .to(quantized_buffer, rle_compressor.in)
                     .to(rle_compressor.out, compressed_buffer);

        std::cout << "Creating audio processing dataflow:" << std::endl;
        std::cout << "  audio_input_buffer → fft_processor → fft_output_buffer → quantizer → quantized_buffer → rle_compressor → compressed_buffer" << std::endl;

        if (!audio_dataflow.check()) {
            throw std::runtime_error("Failed to validate dataflow");
        }

        print_header("DATA GENERATION");

        std::vector<float> audio_data(complex_size, 0.0f);

        generateCompressibleAudio(audio_data.data(), input_size);

        std::cout << "\nFirst 32 audio values:" << std::endl;
        for (uint32_t i = 0; i < min(32U, input_size); ++i) {
            std::cout << std::fixed << std::setprecision(6)
                     << audio_data[2*i] << " " << audio_data[2*i + 1] << " ";
            if ((i + 1) % 4 == 0) std::cout << "\n";
        }
        std::cout << "\n";

        std::vector<std::vector<uint8_t>> result_data(n_reps);
        for(int i = 0; i < n_reps; i++) {
            result_data[i].resize(output_buffer_size);
        }

        print_header("PROCESSING");

        cBench bench(n_reps);

        auto benchmark_thr = [&]() {
            for(int i = 0; i < n_reps; i++) {
                write_dataflow_buffer(audio_input_buffer, audio_data.data(), input_buffer_size);
                audio_dataflow.clear_completed();
                audio_dataflow.execute(input_buffer_size);
                read_dataflow_buffer(compressed_buffer, result_data[i].data(), output_buffer_size);
            }
        };

        bench.runtime(benchmark_thr);

        print_header("LATENCY MEASUREMENTS");
        printLatencyStats(bench.getAvg() / n_reps, input_size, n_reps);

        print_header("RESULTS");
        for(int i = 0; i < n_reps; i++) {
            std::cout << "\n--- Pipeline Run #" << (i + 1) << " ---";
            printRLEOutput(result_data[i].data(), output_buffer_size);
        }

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }

    print_header("AUDIO PROCESSING COMPLETE");
    std::cout << "Audio processing pipeline executed successfully!" << std::endl;

    return EXIT_SUCCESS;
}
