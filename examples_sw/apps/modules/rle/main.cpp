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
constexpr auto const defSize = 64;
constexpr auto const maxSize = 1024 * 1024;

// AAAABBBB...PPPP — every char repeated 4 times so RLE compresses 4:1 to ABCD..P.
void generateRLEPattern(uint8_t* buffer, size_t size) {
    memset(buffer, 0, size);

    for (size_t pos = 0; pos < size; pos++) {
        char base_char = 'A' + ((pos / 4) % 16);
        buffer[pos] = base_char;
    }
}

void analyzeRLEOutput(uint8_t* buffer, size_t buffer_size, uint32_t input_chunks) {
    std::cout << "RLE Output Analysis:" << std::endl;

    size_t hex_display_size = std::min(buffer_size, size_t(64));
    std::cout << "  Raw output (hex): ";
    for (size_t i = 0; i < hex_display_size; i++) {
        std::cout << std::hex << std::setw(2) << std::setfill('0')
                  << static_cast<int>(buffer[i]) << " ";
    }
    std::cout << std::dec << std::endl;

    std::string compressed_string = "";
    size_t valid_chars = 0;

    for (size_t i = 0; i < buffer_size; i++) {
        uint8_t byte_val = buffer[i];
        if (byte_val >= 'A' && byte_val <= 'P') {
            compressed_string += static_cast<char>(byte_val);
            valid_chars++;
        } else if (byte_val == 0 && valid_chars > 0) {
            break;
        }
    }

    std::cout << "  Compressed output: \"" << compressed_string << "\" (" << valid_chars << " chars)" << std::endl;

    std::string expected = "";
    for (uint32_t i = 0; i < input_chunks; i++) {
        expected += "ABCDEFGHIJKLMNOP";
    }

    if (compressed_string == expected) {
        std::cout << "  Pattern CORRECT: " << input_chunks << " chunks compressed successfully" << std::endl;
    } else {
        std::cout << "  Pattern MISMATCH" << std::endl;
        std::cout << "  Expected: \"" << expected << "\"" << std::endl;
        std::cout << "  Got:      \"" << compressed_string << "\"" << std::endl;
    }

    size_t expected_size = input_chunks * 16;
    std::cout << "  Compression: " << (input_chunks * 64) << " → " << valid_chars << " bytes";
    if (valid_chars == expected_size) {
        std::cout << " (4:1 ratio)" << std::endl;
    } else {
        std::cout << " (expected " << expected_size << ")" << std::endl;
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

int main(int argc, char *argv[]) {
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    boost::program_options::options_description programDescription("RLE Compression Test:");
    programDescription.add_options()
        ("bitstream,b", boost::program_options::value<string>(), "Shell bitstream")
        ("device,d", boost::program_options::value<uint32_t>(), "Target device")
        ("size,s", boost::program_options::value<uint32_t>(), "Data size in bytes (default: 64)")
        ("help", "Show help");

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
    uint32_t input_size = defSize;

    if(commandLineArgs.count("bitstream") > 0) {
        bstream_path = commandLineArgs["bitstream"].as<string>();

        std::cout << std::endl << "Shell loading (path: " << bstream_path << ") ..." << std::endl;
        cRnfg crnfg(cs_dev);
        crnfg.shellReconfigure(bstream_path);
    }
    if(commandLineArgs.count("device") > 0) cs_dev = commandLineArgs["device"].as<uint32_t>();

    if(commandLineArgs.count("size") > 0) {
        input_size = commandLineArgs["size"].as<uint32_t>();
        if (input_size == 0 || input_size > maxSize) {
            std::cerr << "Error: Invalid size (max: " << maxSize << " bytes)" << std::endl;
            return EXIT_FAILURE;
        }
    }

    uint32_t input_chunks = (input_size + 63) / 64;
    uint32_t expected_compressed_size = input_chunks * 16;
    uint32_t output_buffer_size = std::max(((expected_compressed_size + 63) / 64) * 64, 64u);

    print_header("RLE COMPRESSION TEST");
    std::cout << "Input: " << input_size << " bytes (" << input_chunks << " chunks)" << std::endl;
    std::cout << "Expected output: " << expected_compressed_size << " bytes (4:1 compression)" << std::endl;

    try {
        print_header("DATAFLOW SETUP");

        Dataflow rle_dataflow("rle_compression_pipeline");

        Task& rle_compressor = rle_dataflow.add_task("rle_compressor", "compression");

        Buffer& input_buffer = rle_dataflow.add_buffer(input_size, "input_buffer");
        Buffer& output_buffer = rle_dataflow.add_buffer(output_buffer_size, "output_buffer");

        rle_dataflow.to(input_buffer, rle_compressor.in)
                    .to(rle_compressor.out, output_buffer);

        std::cout << "Creating RLE dataflow:" << std::endl;
        std::cout << "  input_buffer → rle_compressor → output_buffer" << std::endl;

        if (!rle_dataflow.check()) {
            throw std::runtime_error("Failed to validate dataflow");
        }

        print_header("DATA GENERATION");

        std::vector<uint8_t> test_data(input_size);
        generateRLEPattern(test_data.data(), input_size);

        std::cout << "Input pattern: ";
        for(size_t i = 0; i < std::min(input_size, 64u); i++) {
            std::cout << static_cast<char>(test_data[i]);
        }
        std::cout << std::endl;

        print_header("RLE COMPRESSION");

        cBench bench(1);

        write_dataflow_buffer(input_buffer, test_data.data(), input_size);

        rle_dataflow.clear_completed();

        auto benchmark_thr = [&]() {
            rle_dataflow.execute(input_size);

            if(stalled.load()) throw std::runtime_error("Stalled, SIGINT caught");
        };

        bench.runtime(benchmark_thr);

        print_header("RESULTS");

        std::vector<uint8_t> output_data(output_buffer_size);
        read_dataflow_buffer(output_buffer, output_data.data(), output_buffer_size);

        analyzeRLEOutput(output_data.data(), output_buffer_size, input_chunks);

        print_header("LATENCY MEASUREMENTS");
        printLatencyStats(bench.getAvg(), input_size, 1);

        if (rle_dataflow.get_debug_level() > 1) {
            print_header("DEBUG INFO");
            rle_dataflow.print_graph();
            rle_dataflow.print_connections();
            rle_dataflow.print_capability_tree();
        }

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }

    print_header("RLE COMPRESSION COMPLETE");
    std::cout << "RLE compression pipeline executed successfully!" << std::endl;

    return EXIT_SUCCESS;
}
