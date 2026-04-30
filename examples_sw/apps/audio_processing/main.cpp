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
#include <random>
#include <cmath>

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
constexpr auto const nRegions = 2;
constexpr auto const defHuge = true;
constexpr auto const defMapped = true;
constexpr auto const defStream = 1;
constexpr auto const nRepsThr = 1;
constexpr auto const nRepsLat = 1;
constexpr auto const defMinSize = 4 * 1024;
constexpr auto const defMaxSize = 4 * 1024;
constexpr auto const nBenchRuns = 1;
constexpr float const sampleRate = 44100.0f;

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
        audio_data[2*sample_idx + 1] = 0.0f;
    }
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

int main(int argc, char *argv[])
{
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    boost::program_options::options_description programDescription("Options:");
    programDescription.add_options()
        ("bitstream,b", boost::program_options::value<string>(), "Shell bitstream")
        ("device,d", boost::program_options::value<uint32_t>(), "Target device")
        ("regions,g", boost::program_options::value<uint32_t>(), "Number of vFPGAs")
        ("hugepages,h", boost::program_options::value<bool>(), "Hugepages")
        ("mapped,m", boost::program_options::value<bool>(), "Mapped / page fault")
        ("stream,t", boost::program_options::value<bool>(), "Streaming interface")
        ("repst,r", boost::program_options::value<uint32_t>(), "Number of repetitions (throughput)")
        ("repsl,l", boost::program_options::value<uint32_t>(), "Number of repetitions (latency)")
        ("min_size,n", boost::program_options::value<uint32_t>(), "Starting transfer size")
        ("max_size,x", boost::program_options::value<uint32_t>(), "Ending transfer size");

    boost::program_options::variables_map commandLineArgs;
    boost::program_options::store(boost::program_options::parse_command_line(argc, argv, programDescription), commandLineArgs);
    boost::program_options::notify(commandLineArgs);

    string bstream_path = "";
    uint32_t cs_dev = defDevice;
    uint32_t n_regions = nRegions;
    bool huge = defHuge;
    bool mapped = defMapped;
    bool stream = defStream;
    uint32_t n_reps_thr = nRepsThr;
    uint32_t n_reps_lat = nRepsLat;
    uint32_t curr_size = defMinSize;
    uint32_t max_size = defMaxSize;

    uint32_t complex_size = 2 * defMaxSize;
    uint32_t input_buffer_size = complex_size * sizeof(float);
    uint32_t output_buffer_size = input_buffer_size / 4;

    if(commandLineArgs.count("bitstream") > 0) {
        bstream_path = commandLineArgs["bitstream"].as<string>();

        std::cout << std::endl << "Shell loading (path: " << bstream_path << ") ..." << std::endl;
        cRnfg crnfg(cs_dev);
        crnfg.shellReconfigure(bstream_path);
    }
    if(commandLineArgs.count("device") > 0) cs_dev = commandLineArgs["device"].as<uint32_t>();
    if(commandLineArgs.count("regions") > 0) n_regions = commandLineArgs["regions"].as<uint32_t>();
    if(commandLineArgs.count("hugepages") > 0) huge = commandLineArgs["hugepages"].as<bool>();
    if(commandLineArgs.count("mapped") > 0) mapped = commandLineArgs["mapped"].as<bool>();
    if(commandLineArgs.count("stream") > 0) stream = commandLineArgs["stream"].as<bool>();
    if(commandLineArgs.count("repst") > 0) n_reps_thr = commandLineArgs["repst"].as<uint32_t>();
    if(commandLineArgs.count("repsl") > 0) n_reps_lat = commandLineArgs["repsl"].as<uint32_t>();
    if(commandLineArgs.count("min_size") > 0) curr_size = commandLineArgs["min_size"].as<uint32_t>();
    if(commandLineArgs.count("max_size") > 0) max_size = commandLineArgs["max_size"].as<uint32_t>();

    print_header("PARAMS");
    std::cout << "Number of regions: " << n_regions << std::endl;
    std::cout << "Hugepages: " << huge << std::endl;
    std::cout << "Mapped pages: " << mapped << std::endl;
    std::cout << "Streaming: " << (stream ? "HOST" : "CARD") << std::endl;
    std::cout << "Number of repetitions (thr): " << n_reps_thr << std::endl;
    std::cout << "Number of repetitions (lat): " << n_reps_lat << std::endl;
    std::cout << "Input buffer size: " << input_buffer_size << " bytes" << std::endl;
    std::cout << "Output buffer size: " << output_buffer_size << " bytes" << std::endl;
    std::cout << "Audio samples: " << max_size << std::endl;

    try {
        print_header("DATAFLOW SETUP");

        Dataflow audio_dataflow("audio_quantization_dataflow");

        Task& audio_preprocessor = audio_dataflow.add_task("audio_preprocessor", "processing");
        Task& quantizer_compressor = audio_dataflow.add_task("quantizer_compressor", "processing");

        Buffer& audio_input_buffer = audio_dataflow.add_buffer(input_buffer_size, "audio_input_buffer");
        Buffer& intermediate_buffer = audio_dataflow.add_buffer(input_buffer_size, "intermediate_buffer");
        Buffer& compressed_output_buffer = audio_dataflow.add_buffer(output_buffer_size, "compressed_output_buffer");

        audio_dataflow.to(audio_input_buffer, audio_preprocessor.in)
                     .to(audio_preprocessor.out, intermediate_buffer)
                     .to(intermediate_buffer, quantizer_compressor.in)
                     .to(quantizer_compressor.out, compressed_output_buffer);

        std::cout << "Creating audio dataflow:" << std::endl;
        std::cout << "  audio_input_buffer → audio_preprocessor → intermediate_buffer → quantizer_compressor → compressed_output_buffer" << std::endl;

        if (!audio_dataflow.check()) {
            throw std::runtime_error("Failed to validate dataflow");
        }

        print_header("AUDIO DATA GENERATION");

        std::vector<float> audio_data(complex_size, 0.0f);
        generateCompressibleAudio(audio_data.data(), max_size);

        write_dataflow_buffer(audio_input_buffer, audio_data.data(), input_buffer_size);
        std::cout << "Initialized audio input buffer with " << max_size << " complex samples" << std::endl;

        print_header("AUDIO PROCESSING PERFORMANCE");

        cBench bench(nBenchRuns);

        // Sweep transfer sizes from curr_size to max_size, doubling each iteration.
        uint32_t current_byte_size = 2 * curr_size * sizeof(float);
        uint32_t max_byte_size = 2 * max_size * sizeof(float);

        while (current_byte_size <= max_byte_size) {
            audio_dataflow.clear_completed();

            auto benchmark_lat = [&]() {
                for (int i = 0; i < n_reps_lat; i++) {
                    audio_dataflow.execute(current_byte_size);
                }
            };

            bench.runtime(benchmark_lat);

            std::cout << "\nSize: " << current_byte_size << " bytes ("
                      << (current_byte_size / (sizeof(float) * 2)) << " samples)";
            printLatencyStats(bench.getAvg() / n_reps_lat, current_byte_size, n_reps_lat);

            current_byte_size *= 2;
        }

        print_header("RESULTS VERIFICATION");

        std::vector<uint8_t> compressed_data(output_buffer_size);
        read_dataflow_buffer(compressed_output_buffer, compressed_data.data(), output_buffer_size);

        float compression_ratio = (float)input_buffer_size / (float)output_buffer_size;
        std::cout << "Input size: " << input_buffer_size << " bytes" << std::endl;
        std::cout << "Compressed size: " << output_buffer_size << " bytes" << std::endl;
        std::cout << "Compression ratio: " << std::fixed << std::setprecision(2)
                  << compression_ratio << ":1" << std::endl;

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }

    print_header("AUDIO PROCESSING COMPLETE");
    std::cout << "Audio quantization and compression dataflow executed successfully!" << std::endl;

    return EXIT_SUCCESS;
}
