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
constexpr auto const nRegions = 2;
constexpr auto const defHuge = true;
constexpr auto const defMapped = true;
constexpr auto const defStream = 1;
constexpr auto const nRepsThr = 1;
constexpr auto const nRepsLat = 1;
constexpr auto const defSize = 64;
constexpr auto const maxSize = 1024 * 1024;
constexpr auto const RSA_OUTPUT_SIZE = 32;
constexpr auto const nBenchRuns = 1;

// AAAABBBB...PPPP — every char repeated 4 times so RLE compresses 4:1 to ABCD..P.
void generateStreamingRLEPattern(uint8_t* buffer, size_t size) {
    memset(buffer, 0, size);

    for (size_t pos = 0; pos < size; pos++) {
        char base_char = 'A' + ((pos / 4) % 16);
        buffer[pos] = base_char;
    }
}

void printBuffer(uint8_t* buffer, size_t size, const char* label) {
    std::cout << label << ": ";
    for(size_t i = 0; i < std::min(size, size_t(64)); i++) {
        std::cout << static_cast<char>(buffer[i]);
        if ((i + 1) % 16 == 0) std::cout << std::endl << "               ";
    }
    std::cout << std::endl;
}

void printHexBuffer(uint32_t* buffer, size_t words, const char* label) {
    std::cout << label << ": 0x";
    for(int i = words-1; i >= 0; i--) {
        std::cout << std::hex << std::setw(8) << std::setfill('0') << buffer[i];
    }
    std::cout << std::dec << std::endl;
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

    boost::program_options::options_description programDescription("Signed Compression Pipeline Options:");
    programDescription.add_options()
        ("bitstream,b", boost::program_options::value<string>(), "Shell bitstream")
        ("device,d", boost::program_options::value<uint32_t>(), "Target device")
        ("regions,g", boost::program_options::value<uint32_t>(), "Number of vFPGAs")
        ("size,s", boost::program_options::value<uint32_t>(), "RLE input size in bytes (default: 64, max: 1MB)")
        ("custom,c", "Use custom input pattern instead of default RLE pattern")
        ("hugepages,h", boost::program_options::value<bool>(), "Use hugepages (default: true)")
        ("mapped,m", boost::program_options::value<bool>(), "Use mapped memory (default: true)")
        ("stream,t", boost::program_options::value<bool>(), "Use streaming interface (default: true)")
        ("repst,r", boost::program_options::value<uint32_t>(), "Number of repetitions (throughput)")
        ("repsl,l", boost::program_options::value<uint32_t>(), "Number of repetitions (latency)")
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
    uint32_t input_size = defSize;
    bool huge = defHuge;
    bool mapped = defMapped;
    bool stream = defStream;
    uint32_t n_reps_thr = nRepsThr;
    uint32_t n_reps_lat = nRepsLat;

    if(commandLineArgs.count("bitstream") > 0) {
        bstream_path = commandLineArgs["bitstream"].as<string>();

        std::cout << std::endl << "Shell loading (path: " << bstream_path << ") ..." << std::endl;
        cRnfg crnfg(cs_dev);
        crnfg.shellReconfigure(bstream_path);
    }
    if(commandLineArgs.count("device") > 0) cs_dev = commandLineArgs["device"].as<uint32_t>();
    if(commandLineArgs.count("regions") > 0) n_regions = commandLineArgs["regions"].as<uint32_t>();
    if(commandLineArgs.count("size") > 0) {
        input_size = commandLineArgs["size"].as<uint32_t>();

        if (input_size == 0) {
            std::cerr << "Error: Size must be greater than 0" << std::endl;
            return EXIT_FAILURE;
        }
        if (input_size > maxSize) {
            std::cerr << "Error: Size too large (max: " << maxSize << " bytes)" << std::endl;
            return EXIT_FAILURE;
        }
    }
    if(commandLineArgs.count("hugepages") > 0) huge = commandLineArgs["hugepages"].as<bool>();
    if(commandLineArgs.count("mapped") > 0) mapped = commandLineArgs["mapped"].as<bool>();
    if(commandLineArgs.count("stream") > 0) stream = commandLineArgs["stream"].as<bool>();
    if(commandLineArgs.count("repst") > 0) n_reps_thr = commandLineArgs["repst"].as<uint32_t>();
    if(commandLineArgs.count("repsl") > 0) n_reps_lat = commandLineArgs["repsl"].as<uint32_t>();

    uint32_t input_chunks = (input_size + 63) / 64;
    uint32_t expected_rle_compressed = input_chunks * 16;
    uint32_t output_size = RSA_OUTPUT_SIZE;

    print_header("PARAMS");
    std::cout << "Pipeline: Signed Compression (RLE → RSA)" << std::endl;
    std::cout << "Number of regions: " << n_regions << std::endl;
    std::cout << "RLE input size: " << input_size << " bytes";
    if (input_size >= 1024) {
        std::cout << " (" << std::fixed << std::setprecision(1) << (input_size / 1024.0) << " KB)";
    }
    std::cout << std::endl;
    std::cout << "Input chunks: " << input_chunks << " (64-byte chunks)" << std::endl;
    std::cout << "Expected RLE compressed: " << expected_rle_compressed << " bytes (4:1 ratio)" << std::endl;
    std::cout << "Final RSA output: " << output_size << " bytes (256-bit encrypted)" << std::endl;
    std::cout << "Pattern: " << (commandLineArgs.count("custom") ? "Custom" : "True 4:1 RLE (AAAABBBB...PPPP)") << std::endl;
    std::cout << "Hugepages: " << huge << std::endl;
    std::cout << "Mapped: " << mapped << std::endl;
    std::cout << "Streaming: " << (stream ? "HOST" : "CARD") << std::endl;

    try {
        print_header("DATAFLOW SETUP");

        Dataflow signcomp_dataflow("signcomp_dataflow");

        Task& rle_compressor = signcomp_dataflow.add_task("rle_compressor", "compression");
        Task& rsa_encryptor = signcomp_dataflow.add_task("rsa_encryptor", "encryption");

        Buffer& raw_input_buffer = signcomp_dataflow.add_buffer(input_size, "raw_input_buffer");
        Buffer& compressed_buffer = signcomp_dataflow.add_buffer(expected_rle_compressed, "compressed_buffer");
        Buffer& encrypted_output_buffer = signcomp_dataflow.add_buffer(output_size, "encrypted_output_buffer");

        signcomp_dataflow.to(raw_input_buffer, rle_compressor.in)
                        .to(rle_compressor.out, compressed_buffer)
                        .to(compressed_buffer, rsa_encryptor.in)
                        .to(rsa_encryptor.out, encrypted_output_buffer);

        std::cout << "Creating signed compression dataflow:" << std::endl;
        std::cout << "  raw_input_buffer → rle_compressor → compressed_buffer → rsa_encryptor → encrypted_output_buffer" << std::endl;

        if (!signcomp_dataflow.check()) {
            throw std::runtime_error("Failed to validate dataflow");
        }

        print_header("DATA GENERATION");

        std::vector<uint8_t> input_data(input_size);

        if (!commandLineArgs.count("custom")) {
            generateStreamingRLEPattern(input_data.data(), input_size);
        } else {
            std::cout << "Generating custom alternating pattern..." << std::endl;
            for (uint32_t i = 0; i < input_size; i++) {
                input_data[i] = 'A' + (i % 26);
            }
        }

        if (input_size <= 256) {
            printBuffer(input_data.data(), input_size, "RLE Input");
        } else {
            std::cout << "RLE Input (first 64 bytes): ";
            for(size_t i = 0; i < 64; i++) {
                std::cout << static_cast<char>(input_data[i]);
                if ((i + 1) % 16 == 0) std::cout << std::endl << "                            ";
            }
            std::cout << std::endl;

            std::cout << "RLE Input (last 64 bytes):  ";
            for(size_t i = input_size - 64; i < input_size; i++) {
                std::cout << static_cast<char>(input_data[i]);
                if ((i - (input_size - 64) + 1) % 16 == 0) std::cout << std::endl << "                            ";
            }
            std::cout << std::endl;
        }

        write_dataflow_buffer(raw_input_buffer, input_data.data(), input_size);
        std::cout << "Initialized input buffer with " << input_size << " bytes of RLE data" << std::endl;

        print_header("SIGNED COMPRESSION PERFORMANCE");

        cBench bench(nBenchRuns);

        signcomp_dataflow.clear_completed();

        auto benchmark_thr = [&]() {
            for (int i = 0; i < n_reps_lat; i++) {
                signcomp_dataflow.execute(input_size);
            }
        };

        bench.runtime(benchmark_thr);

        print_header("RESULTS");

        std::vector<uint8_t> encrypted_result(output_size);
        read_dataflow_buffer(encrypted_output_buffer, encrypted_result.data(), output_size);

        printHexBuffer((uint32_t*)encrypted_result.data(), output_size/4, "RSA Output");

        print_header("LATENCY MEASUREMENTS");
        printLatencyStats(bench.getAvg() / n_reps_lat, input_size, n_reps_lat);

        double space_efficiency = static_cast<double>(input_size) / output_size;
        std::cout << "\nPipeline metrics:" << std::endl;
        std::cout << "  Space efficiency: " << std::fixed << std::setprecision(1)
                  << space_efficiency << ":1 (input:output ratio)" << std::endl;

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }

    print_header("SIGNED COMPRESSION COMPLETE");
    std::cout << "Signed compression (RLE + RSA) dataflow executed successfully!" << std::endl;

    return EXIT_SUCCESS;
}
