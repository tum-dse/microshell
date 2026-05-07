/**
 * Secure Storage Pipeline (monolithic / single-binary version).
 *
 * Single µShell Dataflow Task (secure_processor) wired between an input
 * Buffer and an output Buffer. The fused vFPGA performs RLE compression
 * on the first chunk and RLE+AES on subsequent chunks, exercising the
 * full secure-storage path from a single binary.
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
constexpr auto const defSize = 64 * 1024;
constexpr auto const maxSize = 1024 * 1024;
constexpr auto const nBenchRuns = 1;

enum PatternType {
    PATTERN_REGULAR = 0,
    PATTERN_RANDOM = 1,
    PATTERN_LONG_RUNS = 2
};

// Three input distributions exercise different RLE compression regimes:
// REGULAR repeats every 4 bytes (~2:1), RANDOM defeats RLE entirely, and
// LONG_RUNS produces 16-64 byte runs for best-case compression.
void generatePattern(uint8_t* buffer, size_t size, PatternType pattern) {
    switch(pattern) {
        case PATTERN_REGULAR:
            for (size_t i = 0; i < size; i++) {
                buffer[i] = 'A' + ((i / 4) % 16);
            }
            break;

        case PATTERN_RANDOM:
            srand(time(NULL));
            for (size_t i = 0; i < size; i++) {
                buffer[i] = rand() % 256;
            }
            break;

        case PATTERN_LONG_RUNS:
            srand(time(NULL));
            for (size_t pos = 0; pos < size; ) {
                uint8_t value = 'A' + (rand() % 26);
                int run_len = 16 + (rand() % 48);
                if (pos + run_len > size) run_len = size - pos;
                memset(buffer + pos, value, run_len);
                pos += run_len;
            }
            break;
    }
}

// Heuristic check: first 64 bytes look like RLE pairs (count, value), and the
// remaining bytes look random (no repeating 16-byte blocks) suggesting AES output.
void analyzePipelineOutput(uint8_t* buffer, size_t buffer_size, size_t input_size) {
    std::cout << "\nPipeline Output Analysis:" << std::endl;

    std::cout << "  First chunk (RLE output):" << std::endl;
    bool first_chunk_is_rle = false;
    int rle_pairs = 0;

    for (int i = 0; i < 64 && i < buffer_size; i += 2) {
        uint8_t count = buffer[i];
        uint8_t value = buffer[i + 1];

        if (count > 0 && count <= 64) {
            if (rle_pairs < 8) {
                std::cout << "    RLE pair: (" << (int)count << ", ";
                if (value >= 32 && value <= 126) {
                    std::cout << "'" << (char)value << "'";
                } else {
                    std::cout << "0x" << std::hex << (int)value << std::dec;
                }
                std::cout << ")" << std::endl;
            }
            rle_pairs++;
            first_chunk_is_rle = true;
        }
    }

    if (first_chunk_is_rle) {
        std::cout << "    Total RLE pairs in first chunk: " << rle_pairs << std::endl;
    }

    std::cout << "\n  Subsequent chunks (encrypted data):" << std::endl;
    std::cout << "    Bytes 64-127: ";

    int encrypted_bytes = 0;
    bool looks_random = true;

    for (int i = 64; i < std::min((int)buffer_size, 128); i++) {
        if (i % 16 == 0 && i > 64) std::cout << std::endl << "                   ";
        std::cout << std::hex << std::setw(2) << std::setfill('0') << (int)buffer[i] << " ";

        if (buffer[i] != 0) encrypted_bytes++;

        if (i >= 80 && i % 16 == 15) {
            if (memcmp(&buffer[i-15], &buffer[i-31], 16) == 0) {
                looks_random = false;
            }
        }
    }
    std::cout << std::dec << std::endl;

    size_t total_non_zero = 0;
    for (size_t i = 0; i < buffer_size; i++) {
        if (buffer[i] != 0) total_non_zero++;
    }

    std::cout << "\n  Pipeline behavior:" << std::endl;
    std::cout << "    First chunk: " << (first_chunk_is_rle ? "RLE compression" : "Unknown") << std::endl;
    std::cout << "    Rest: " << (encrypted_bytes > 0 ? "Encrypted" : "Empty") << std::endl;
    std::cout << "    Encryption quality: " << (looks_random ? "Good (random-looking)" : "Poor (patterns detected)") << std::endl;
    std::cout << "    Total output bytes: " << total_non_zero << std::endl;
    std::cout << "    Compression ratio: " << std::fixed << std::setprecision(2)
              << (double)input_size / total_non_zero << ":1" << std::endl;
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

int main(int argc, char *argv[]) {
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    boost::program_options::options_description programDescription("Secure Storage Pipeline Test:");
    programDescription.add_options()
        ("help,h", "Show help")
        ("bitstream,b", boost::program_options::value<string>(), "Shell bitstream")
        ("device,d", boost::program_options::value<uint32_t>(), "Target device")
        ("regions,g", boost::program_options::value<uint32_t>(), "Number of vFPGAs")
        ("size,s", boost::program_options::value<uint32_t>(), "Data size in bytes (default: 64KB)")
        ("reps,r", boost::program_options::value<uint32_t>(), "Number of repetitions (default: 1)")
        ("pattern,p", boost::program_options::value<int>(),
         "Pattern: 0=regular (2:1), 1=random, 2=long runs (default: 0)")
        ("hugepages,h", boost::program_options::value<bool>(), "Use hugepages (default: true)")
        ("mapped,m", boost::program_options::value<bool>(), "Use mapped memory (default: true)")
        ("stream,t", boost::program_options::value<bool>(), "Use streaming interface (default: true)")
        ("verbose,v", "Show detailed output");

    boost::program_options::variables_map commandLineArgs;
    boost::program_options::store(
        boost::program_options::parse_command_line(argc, argv, programDescription),
        commandLineArgs);
    boost::program_options::notify(commandLineArgs);

    if(commandLineArgs.count("help")) {
        std::cout << programDescription << std::endl;
        std::cout << "\nPipeline characteristics:" << std::endl;
        std::cout << "  - First 64-byte chunk: RLE compression only" << std::endl;
        std::cout << "  - Remaining chunks: RLE compression + AES encryption" << std::endl;
        std::cout << "  - No explicit descriptor handling needed" << std::endl;
        return EXIT_SUCCESS;
    }

    string bstream_path = "";
    uint32_t cs_dev = defDevice;
    uint32_t n_regions = nRegions;
    uint32_t data_size = commandLineArgs.count("size") ?
        commandLineArgs["size"].as<uint32_t>() : defSize;
    uint32_t n_reps = commandLineArgs.count("reps") ?
        commandLineArgs["reps"].as<uint32_t>() : nRepsLat;
    PatternType pattern = static_cast<PatternType>(
        commandLineArgs.count("pattern") ? commandLineArgs["pattern"].as<int>() : 0);
    bool huge = defHuge;
    bool mapped = defMapped;
    bool stream = defStream;
    bool verbose = commandLineArgs.count("verbose") > 0;

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

    if (data_size == 0 || data_size > maxSize) {
        std::cerr << "Error: Invalid size (max: " << maxSize << " bytes)" << std::endl;
        return EXIT_FAILURE;
    }

    data_size = ((data_size + 63) / 64) * 64;
    uint32_t chunks = data_size / 64;

    uint32_t pipeline_output_size = data_size;

    print_header("SECURE STORAGE PIPELINE TEST");
    std::cout << "Pipeline: RLE Compression → RSA Encryption" << std::endl;
    std::cout << "Number of regions: " << n_regions << std::endl;
    std::cout << "Input size: " << data_size << " bytes (" << chunks << " chunks)" << std::endl;
    std::cout << "Pattern: " << (pattern == PATTERN_REGULAR ? "Regular (2:1 compression)" :
                                pattern == PATTERN_RANDOM ? "Random (no compression)" :
                                "Long runs (best compression)") << std::endl;
    std::cout << "Output buffer size: " << pipeline_output_size << " bytes" << std::endl;
    std::cout << "Repetitions: " << n_reps << std::endl;
    std::cout << "Hugepages: " << huge << std::endl;
    std::cout << "Mapped: " << mapped << std::endl;
    std::cout << "Streaming: " << (stream ? "HOST" : "CARD") << std::endl;

    try {
        print_header("DATAFLOW SETUP");

        Dataflow secure_dataflow("secure_pipeline");

        // Monolithic pipeline: both RLE and AES happen in the same vFPGA.
        Task& secure_processor = secure_dataflow.add_task("secure_processor", "secure");

        Buffer& input_buffer = secure_dataflow.add_buffer(data_size, "input_buffer");
        Buffer& output_buffer = secure_dataflow.add_buffer(pipeline_output_size, "output_buffer");

        secure_dataflow.to(input_buffer, secure_processor.in)
                              .to(secure_processor.out, output_buffer);

        std::cout << "Creating secure storage dataflow:" << std::endl;
        std::cout << "  input_buffer → secure_processor → output_buffer" << std::endl;

        if (!secure_dataflow.check()) {
            throw std::runtime_error("Failed to validate dataflow");
        }

        print_header("DATA GENERATION");

        std::vector<std::vector<uint8_t>> test_data(n_reps);
        std::vector<std::vector<uint8_t>> result_data(n_reps);

        for(int i = 0; i < n_reps; i++) {
            test_data[i].resize(data_size);
            result_data[i].resize(pipeline_output_size);

            generatePattern(test_data[i].data(), data_size, pattern);
        }

        if (verbose) {
            print_header("INPUT DATA SAMPLE");
            std::cout << "First 128 bytes:" << std::endl;
            for(int i = 0; i < std::min(data_size, 128u); i++) {
                if (i % 64 == 0) std::cout << std::endl << "Chunk " << (i/64) << ": ";
                uint8_t val = test_data[0][i];
                std::cout << (char)((val >= 32 && val <= 126) ? val : '.');
            }
            std::cout << std::endl;
        }

        print_header("EXECUTING PIPELINE");

        cBench bench(n_reps);

        std::cout << "Starting transfers..." << std::endl;

        auto benchmark_thr = [&]() {
            for(int i = 0; i < n_reps; i++) {
                write_dataflow_buffer(input_buffer, test_data[i].data(), data_size);
                secure_dataflow.clear_completed();
                secure_dataflow.execute(data_size);
                read_dataflow_buffer(output_buffer, result_data[i].data(), pipeline_output_size);
            }
        };

        bench.runtime(benchmark_thr);
        std::cout << "All transfers completed!" << std::endl;

        print_header("RESULTS");

        for(int i = 0; i < n_reps; i++) {
            if (n_reps > 1) std::cout << "\n--- Repetition " << (i+1) << " ---" << std::endl;
            analyzePipelineOutput(result_data[i].data(), pipeline_output_size, data_size);
        }

        print_header("LATENCY MEASUREMENTS");
        printLatencyStats(bench.getAvg() / n_reps, data_size, n_reps);

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }

    print_header("SECURE STORAGE COMPLETE");
    std::cout << "Secure storage pipeline executed successfully!" << std::endl;

    return EXIT_SUCCESS;
}
