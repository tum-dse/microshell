/**
 * RSA module bring-up: drives the standalone RSA vFPGA with one of three
 * test patterns and prints the 256-bit signature.
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
constexpr auto const defReps = 1;
constexpr auto const defSize = 32;
constexpr auto const RSA_OUTPUT_SIZE = 32;
constexpr auto const maxSize = 1024 * 1024;

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

// Print a buffer as one big hex word, MSB-first.
void printHexBuffer(uint32_t* buffer, size_t words, const char* label) {
    std::cout << label << ": 0x";
    for(int i = words-1; i >= 0; i--) {
        std::cout << std::hex << std::setw(8) << std::setfill('0') << buffer[i];
    }
    std::cout << std::dec << std::endl;
}

// Print the first 64 bytes of a buffer as hex (16 per line).
void printBufferPreview(uint8_t* buffer, size_t size, const char* label) {
    std::cout << label << " (first 64 bytes): ";
    for(size_t i = 0; i < std::min(size, size_t(64)); i++) {
        if (i > 0 && i % 16 == 0) std::cout << std::endl << "                       ";
        std::cout << std::hex << std::setw(2) << std::setfill('0') << (int)buffer[i] << " ";
    }
    std::cout << std::dec << std::endl;
}

// Three test patterns: counter (0x00..0xff), random (fixed seed 42), or
// a fixed 8-byte tile.
void generateTestPattern(uint8_t* buffer, size_t size, const std::string& pattern_type) {
    if (pattern_type == "counter") {
        for (size_t i = 0; i < size; i++) {
            buffer[i] = i & 0xFF;
        }
    } else if (pattern_type == "random") {
        // Fixed seed for reproducibility across runs.
        srand(42);
        for (size_t i = 0; i < size; i++) {
            buffer[i] = rand() & 0xFF;
        }
    } else {
        uint8_t pattern[] = {0xE5, 0xA5, 0x5A, 0x3C, 0xF0, 0x0F, 0xAA, 0x55};
        for (size_t i = 0; i < size; i++) {
            buffer[i] = pattern[i % 8];
        }
    }
}

int main(int argc, char *argv[]) {
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    boost::program_options::options_description programDescription("Options:");
    programDescription.add_options()
        ("size,s", boost::program_options::value<uint32_t>(), "Input size in bytes (must be multiple of 32)")
        ("pattern,p", boost::program_options::value<std::string>(), "Pattern type: default, counter, random")
        ("reps,r", boost::program_options::value<uint32_t>(), "Number of repetitions")
        ("help,h", "Show help message");

    boost::program_options::variables_map commandLineArgs;
    boost::program_options::store(boost::program_options::parse_command_line(argc, argv, programDescription),
                                commandLineArgs);
    boost::program_options::notify(commandLineArgs);

    if(commandLineArgs.count("help")) {
        std::cout << programDescription << std::endl;
        return EXIT_SUCCESS;
    }

    uint32_t input_size = defSize;
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
        if (input_size % 32 != 0) {
            uint32_t old_size = input_size;
            input_size = ((input_size + 31) / 32) * 32;
            std::cout << "Adjusting input size from " << old_size << " to " << input_size
                      << " bytes (multiple of 32 bytes)" << std::endl;
        }
    }

    uint32_t n_reps = defReps;
    if(commandLineArgs.count("reps") > 0) n_reps = commandLineArgs["reps"].as<uint32_t>();

    std::string pattern_type = "default";
    if(commandLineArgs.count("pattern") > 0) {
        pattern_type = commandLineArgs["pattern"].as<std::string>();
    }

    uint32_t n_pages_host = (input_size + hugePageSize - 1) / hugePageSize;
    uint32_t n_pages_rslt = (RSA_OUTPUT_SIZE + pageSize - 1) / pageSize;

    PR_HEADER("RSA STREAMING TEST");
    std::cout << "Input size: " << input_size << " bytes";
    if (input_size >= 1024) {
        std::cout << " (" << std::fixed << std::setprecision(1) << (input_size / 1024.0) << " KB)";
    }
    std::cout << std::endl;
    std::cout << "Input chunks: " << (input_size / 32) << " (32-byte chunks)" << std::endl;
    std::cout << "Output size: " << RSA_OUTPUT_SIZE << " bytes (256-bit)" << std::endl;
    std::cout << "Pattern type: " << pattern_type << std::endl;
    std::cout << "Repetitions: " << n_reps << std::endl;

    try {
        std::unique_ptr<cThread<std::any>> cthread(new cThread<std::any>(targetVfid, getpid(), defDevice));
        cthread->start();

        uint8_t* inputData = (uint8_t*) cthread->getMem({CoyoteAlloc::HPF, n_pages_host});
        uint8_t* outputData = (uint8_t*) cthread->getMem({CoyoteAlloc::HPF, n_pages_rslt});

        if (!inputData || !outputData) {
            throw std::runtime_error("Memory allocation failed");
        }

        generateTestPattern(inputData, input_size, pattern_type);

        if (input_size <= 256) {
            printBufferPreview(inputData, input_size, "Input");
        } else {
            printBufferPreview(inputData, 64, "Input");
            if (input_size > 128) {
                std::cout << "..." << std::endl;
                printBufferPreview(inputData + input_size - 64, 64, "Input (last 64 bytes)");
            }
        }

        sgEntry sg;
        sgFlags sg_flags = { true, true, false };

        cBench bench(n_reps);
        cthread->clearCompleted();

        PR_HEADER("PROCESSING");

        auto benchmark_thr = [&]() {
            for(uint32_t i = 0; i < n_reps; i++) {
                memset(outputData, 0, RSA_OUTPUT_SIZE);

                memset(&sg, 0, sizeof(localSg));

                sg.local.src_addr = inputData;
                sg.local.src_len = input_size;
                sg.local.src_stream = strmHost;
                sg.local.src_dest = targetVfid;

                sg.local.dst_addr = outputData;
                sg.local.dst_len = RSA_OUTPUT_SIZE;
                sg.local.dst_stream = strmHost;
                sg.local.dst_dest = targetVfid;

                sg_flags.last = (i == n_reps-1);
                cthread->invoke(CoyoteOper::LOCAL_TRANSFER, &sg, sg_flags);
            }

            // 30s wall-clock guard in case the FPGA hangs without raising SIGINT.
            auto start_time = std::chrono::high_resolution_clock::now();
            while(cthread->checkCompleted(CoyoteOper::LOCAL_TRANSFER) != n_reps) {
                if(stalled.load()) throw std::runtime_error("Stalled, SIGINT caught");

                auto current_time = std::chrono::high_resolution_clock::now();
                auto elapsed = std::chrono::duration_cast<std::chrono::seconds>(current_time - start_time).count();

                if (elapsed > 30) {
                    throw std::runtime_error("Transfer timeout after 30 seconds");
                }
            }
        };

        bench.runtime(benchmark_thr);

        PR_HEADER("LATENCY MEASUREMENTS");
        printLatencyStats(bench.getAvg() / n_reps, input_size, n_reps);

        PR_HEADER("RESULTS");
        printHexBuffer((uint32_t*)outputData, RSA_OUTPUT_SIZE/4, "RSA Output");

        std::cout << "Raw output (hex): " << std::endl << "  ";
        for (size_t i = 0; i < RSA_OUTPUT_SIZE; i++) {
            std::cout << std::hex << std::setw(2) << std::setfill('0')
                      << (int)outputData[i] << " ";
            if ((i + 1) % 16 == 0) std::cout << std::endl << "  ";
        }
        std::cout << std::dec << std::endl;

        bool all_zeros = true;
        for (size_t i = 0; i < RSA_OUTPUT_SIZE; i++) {
            if (outputData[i] != 0) {
                all_zeros = false;
                break;
            }
        }

        if (all_zeros) {
            std::cout << "\033[31mWARNING: Output is all zeros! Check RSA accumulation.\033[0m" << std::endl;
        }

        PR_HEADER("DEBUG");
        cthread->printDebug();

        cthread->freeMem(inputData);
        cthread->freeMem(outputData);

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
