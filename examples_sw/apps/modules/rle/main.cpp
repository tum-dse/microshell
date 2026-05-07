/**
 * RLE module bring-up: drives the standalone RLE encoder vFPGA with one
 * of three input patterns and reports compression ratio + correctness.
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
constexpr auto const defSize = 64;
constexpr auto const maxSize = 1024 * 1024;
constexpr auto const defHuge = true;
constexpr auto const defMapped = true;
constexpr auto const defStream = 1;
constexpr auto const defReps = 1;

enum PatternType {
    PATTERN_REGULAR = 0,
    PATTERN_RANDOM = 1,
    PATTERN_LONG_RUNS = 2
};

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

// Three test patterns: REGULAR (4-byte runs of A..P, ~4:1 compressible),
// RANDOM (no runs, worst-case for RLE), LONG_RUNS (16..63-byte runs).
void generatePattern(uint8_t* buffer, size_t size, PatternType pattern) {
    switch(pattern) {
        case PATTERN_REGULAR:
            for (size_t i = 0; i < size; i++) {
                buffer[i] = 'A' + ((i / 4) % 16);
            }
            break;

        case PATTERN_RANDOM:
            for (size_t i = 0; i < size; i++) {
                buffer[i] = rand() % 256;
            }
            break;

        case PATTERN_LONG_RUNS:
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

struct CompressionStats {
    size_t input_bytes;
    size_t compressed_bytes;
    size_t num_pairs;
    double ratio;
};

// Walk the encoder output and tally compressed bytes / pair count / ratio.
CompressionStats analyzeOutput(uint8_t* buffer, size_t buffer_size, uint32_t chunks) {
    CompressionStats stats = {0};
    stats.input_bytes = chunks * 64;

    // Each output chunk is up to 32 (count, value) pairs; the encoder writes a
    // zero count to mark the end of valid pairs in the chunk.
    for (size_t chunk = 0; chunk < chunks; chunk++) {
        size_t offset = chunk * 64;

        for (size_t i = 0; i < 64 && (offset + i + 1) < buffer_size; i += 2) {
            uint8_t count = buffer[offset + i];
            if (count == 0) break;

            stats.num_pairs++;
            stats.compressed_bytes += 2;
        }
    }

    stats.ratio = (stats.compressed_bytes * 100.0) / stats.input_bytes;
    return stats;
}

void printSamplePairs(uint8_t* buffer, int max_pairs = 8) {
    std::cout << "Sample RLE pairs: ";
    int shown = 0;

    for (size_t i = 0; i < 64 && shown < max_pairs; i += 2) {
        uint8_t count = buffer[i];
        uint8_t value = buffer[i + 1];

        if (count == 0) break;

        if (value >= 32 && value <= 126) {
            std::cout << "(" << (int)count << "," << (char)value << ") ";
        } else {
            std::cout << "(" << (int)count << ",0x" << std::hex << (int)value << std::dec << ") ";
        }
        shown++;
    }

    if (shown == max_pairs) std::cout << "...";
    std::cout << std::endl;
}

int main(int argc, char *argv[]) {
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    boost::program_options::options_description programDescription("RLE Compression Test:");
    programDescription.add_options()
        ("help", "Show help")
        ("size,s", boost::program_options::value<uint32_t>(), "Data size in bytes (default: 64)")
        ("reps,r", boost::program_options::value<uint32_t>(), "Number of repetitions (default: 1)")
        ("pattern,p", boost::program_options::value<int>(),
         "Pattern: 0=regular (2:1), 1=random, 2=long runs (default: 0)")
        ("verbose,v", "Show detailed output")
        ("hugepages", boost::program_options::value<bool>(), "Use hugepages (default: true)")
        ("mapped", boost::program_options::value<bool>(), "Use mapped memory (default: true)")
        ("stream", boost::program_options::value<bool>(), "Use streaming (default: true)");

    boost::program_options::variables_map commandLineArgs;
    boost::program_options::store(
        boost::program_options::parse_command_line(argc, argv, programDescription),
        commandLineArgs);
    boost::program_options::notify(commandLineArgs);

    if(commandLineArgs.count("help")) {
        std::cout << programDescription << std::endl;
        return EXIT_SUCCESS;
    }

    uint32_t input_size = commandLineArgs.count("size") ?
        commandLineArgs["size"].as<uint32_t>() : defSize;
    uint32_t n_reps = commandLineArgs.count("reps") ?
        commandLineArgs["reps"].as<uint32_t>() : defReps;
    PatternType pattern = static_cast<PatternType>(
        commandLineArgs.count("pattern") ? commandLineArgs["pattern"].as<int>() : 0);
    bool verbose = commandLineArgs.count("verbose") > 0;
    bool huge = commandLineArgs.count("hugepages") ?
        commandLineArgs["hugepages"].as<bool>() : defHuge;
    bool mapped = commandLineArgs.count("mapped") ?
        commandLineArgs["mapped"].as<bool>() : defMapped;
    bool stream = commandLineArgs.count("stream") ?
        commandLineArgs["stream"].as<bool>() : defStream;

    if (input_size == 0 || input_size > maxSize) {
        std::cerr << "Error: Invalid size (max: " << maxSize << " bytes)" << std::endl;
        return EXIT_FAILURE;
    }

    uint32_t chunks = (input_size + 63) / 64;
    uint32_t output_size = chunks * 64;

    PR_HEADER("PARAMS");
    std::cout << "vFPGA ID: " << targetVfid << std::endl;
    std::cout << "Input size: " << input_size << " bytes (" << chunks << " chunks)" << std::endl;
    std::cout << "Pattern: " << (pattern == PATTERN_REGULAR ? "Regular (2:1 compression)" :
                                pattern == PATTERN_RANDOM ? "Random (worst case)" :
                                "Long runs (best case)") << std::endl;
    std::cout << "Repetitions: " << n_reps << std::endl;

    try {
        std::unique_ptr<cThread<std::any>> cthread(
            new cThread<std::any>(targetVfid, getpid(), defDevice));

        std::vector<void*> input_buffers(n_reps);
        std::vector<void*> output_buffers(n_reps);

        for(int i = 0; i < n_reps; i++) {
            if (mapped) {
                input_buffers[i] = cthread->getMem(
                    {huge ? CoyoteAlloc::HPF : CoyoteAlloc::REG,
                     std::max(input_size, static_cast<uint32_t>(hugePageSize))});
                output_buffers[i] = cthread->getMem(
                    {huge ? CoyoteAlloc::HPF : CoyoteAlloc::REG,
                     std::max(output_size, static_cast<uint32_t>(hugePageSize))});
            } else {
                size_t alloc_size_in = std::max(input_size, static_cast<uint32_t>(hugePageSize));
                size_t alloc_size_out = std::max(output_size, static_cast<uint32_t>(hugePageSize));

                if (huge) {
                    input_buffers[i] = mmap(NULL, alloc_size_in,
                        PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);
                    output_buffers[i] = mmap(NULL, alloc_size_out,
                        PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);
                } else {
                    input_buffers[i] = malloc(input_size);
                    output_buffers[i] = malloc(output_size);
                }
            }

            if (!input_buffers[i] || !output_buffers[i]) {
                throw std::runtime_error("Memory allocation failed");
            }

            generatePattern((uint8_t*)input_buffers[i], input_size, pattern);
            memset(output_buffers[i], 0, output_size);
        }

        if (verbose) {
            std::cout << "\nInput sample (first 64 bytes): ";
            for(size_t i = 0; i < std::min(input_size, 64u); i++) {
                uint8_t val = ((uint8_t*)input_buffers[0])[i];
                std::cout << (char)((val >= 32 && val <= 126) ? val : '.');
            }
            std::cout << std::endl;
        }

        PR_HEADER("RLE COMPRESSION");

        sgEntry sg;
        sgFlags sg_flags = {true, true, false};
        cBench bench(n_reps);
        cthread->clearCompleted();

        auto benchmark_thr = [&]() {
            for(int i = 0; i < n_reps; i++) {
                memset(&sg, 0, sizeof(localSg));
                sg.local.src_addr = input_buffers[i];
                sg.local.src_len = input_size;
                sg.local.src_stream = stream;
                sg.local.dst_addr = output_buffers[i];
                sg.local.dst_len = output_size;
                sg.local.dst_stream = stream;

                sg_flags.last = (i == n_reps - 1);
                cthread->invoke(CoyoteOper::LOCAL_TRANSFER, &sg, sg_flags);
            }

            while(cthread->checkCompleted(CoyoteOper::LOCAL_TRANSFER) != n_reps) {
                if(stalled.load()) throw std::runtime_error("Stalled");
            }
        };

        bench.runtime(benchmark_thr);

        PR_HEADER("LATENCY MEASUREMENTS");
        printLatencyStats(bench.getAvg() / n_reps, input_size, n_reps);

        PR_HEADER("RESULTS");
        CompressionStats stats = analyzeOutput((uint8_t*)output_buffers[0], output_size, chunks);

        std::cout << "Input: " << stats.input_bytes << " bytes" << std::endl;
        std::cout << "Compressed: " << stats.compressed_bytes << " bytes "
                  << "(" << stats.num_pairs << " pairs)" << std::endl;
        std::cout << "Compression ratio: " << std::fixed << std::setprecision(1)
                  << stats.ratio << "%" << std::endl;

        if (verbose) {
            printSamplePairs((uint8_t*)output_buffers[0]);
        }

        if (n_reps > 1) {
            bool consistent = true;
            for(int i = 1; i < n_reps; i++) {
                if (memcmp(output_buffers[0], output_buffers[i], output_size) != 0) {
                    consistent = false;
                    break;
                }
            }
            std::cout << "Consistency: " << (consistent ? "PASS" : "FAIL") << std::endl;
        }

        for(int i = 0; i < n_reps; i++) {
            if (mapped) {
                cthread->freeMem(input_buffers[i]);
                cthread->freeMem(output_buffers[i]);
            } else {
                if (huge) {
                    munmap(input_buffers[i], std::max(input_size, static_cast<uint32_t>(hugePageSize)));
                    munmap(output_buffers[i], std::max(output_size, static_cast<uint32_t>(hugePageSize)));
                } else {
                    free(input_buffers[i]);
                    free(output_buffers[i]);
                }
            }
        }

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
