/**
 * SHA-256 module bring-up: feeds a fixed input pattern into the
 * standalone SHA-256 vFPGA and prints the 256-bit digests.
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
#ifdef EN_AVX
#include <x86intrin.h>
#endif
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
constexpr auto const defSize = 64 * 1024;
constexpr auto const defDW = 4;
constexpr auto const SHA256_DIGEST_LENGTH = 32;

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

int main(int argc, char *argv[])
{
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    boost::program_options::options_description programDescription("Options:");
    programDescription.add_options()
        ("size,s", boost::program_options::value<uint32_t>(), "Data size")
        ("reps,r", boost::program_options::value<uint32_t>(), "Number of reps");

    boost::program_options::variables_map commandLineArgs;
    boost::program_options::store(boost::program_options::parse_command_line(argc, argv, programDescription), commandLineArgs);
    boost::program_options::notify(commandLineArgs);

    uint32_t size = defSize;
    uint32_t n_reps = defReps;

    if(commandLineArgs.count("size") > 0) size = commandLineArgs["size"].as<uint32_t>();
    if(commandLineArgs.count("reps") > 0) n_reps = commandLineArgs["reps"].as<uint32_t>();

    uint32_t n_pages_host = (size + hugePageSize - 1) / hugePageSize;
    uint32_t n_pages_rslt = (n_reps * SHA256_DIGEST_LENGTH + pageSize - 1) / pageSize;

    PR_HEADER("PARAMS");
    std::cout << "vFPGA ID: " << targetVfid << std::endl;
    std::cout << "Number of allocated pages per run: " << n_pages_host << std::endl;
    std::cout << "Data size: " << size << std::endl;
    std::cout << "Number of reps: " << n_reps << std::endl;

    try {
        std::unique_ptr<cThread<std::any>> cthread(new cThread<std::any>(targetVfid, getpid(), defDevice));
        cthread->start();

        std::vector<uint32_t*> inputData(n_reps, nullptr);
        unsigned char* hashResults = nullptr;

        // Fill with the testbench reference chunk: FEDCBA9876543210 repeated 8x.
        for(int i = 0; i < n_reps; i++) {
            inputData[i] = (uint32_t*) cthread->getMem({CoyoteAlloc::HPF, n_pages_host});
            if (!inputData[i]) {
                throw std::runtime_error("Input memory allocation failed");
            }

            for (int j = 0; j < size/4; j += 2) {
                inputData[i][j] = 0x76543210;
                if (j+1 < size/4) {
                    inputData[i][j+1] = 0xFEDCBA98;
                }
            }
        }

        hashResults = (unsigned char*) cthread->getMem({CoyoteAlloc::HPF, n_pages_rslt});
        if (!hashResults) {
            throw std::runtime_error("Result memory allocation failed");
        }

        sgEntry sg;
        sgFlags sg_flags = { true, true, false };

        cBench bench(1);
        PR_HEADER("SHA256 HASHING");

        cthread->clearCompleted();

        auto benchmark_thr = [&]() {
            for(int i = 0; i < n_reps; i++) {
                memset(&sg, 0, sizeof(localSg));
                sg.local.src_addr = inputData[i];
                sg.local.src_len = size;
                sg.local.src_stream = strmHost;
                sg.local.src_dest = targetVfid;

                sg.local.dst_addr = &hashResults[i * SHA256_DIGEST_LENGTH];
                sg.local.dst_len = SHA256_DIGEST_LENGTH;
                sg.local.dst_stream = strmHost;
                sg.local.dst_dest = targetVfid;

                if(i == n_reps-1) sg_flags.last = true;

                cthread->invoke(CoyoteOper::LOCAL_TRANSFER, &sg, sg_flags);
            }

            // 30s wall-clock guard in case the FPGA hangs without raising SIGINT.
            auto start_time = std::chrono::high_resolution_clock::now();
            while(cthread->checkCompleted(CoyoteOper::LOCAL_TRANSFER) != n_reps) {
                if(stalled.load()) throw std::runtime_error("Stalled, SIGINT caught");

                auto current_time = std::chrono::high_resolution_clock::now();
                auto elapsed = std::chrono::duration_cast<std::chrono::seconds>
                             (current_time - start_time).count();

                if (elapsed > 30) {
                    throw std::runtime_error("Transfers timeout");
                }
            }
        };

        bench.runtime(benchmark_thr);

        PR_HEADER("LATENCY MEASUREMENTS");
        printLatencyStats(bench.getAvg() / n_reps, size, n_reps);

        std::cout << std::endl;
        for(int i = 0; i < n_reps; i++) {
            std::cout << "Hash " << i << ": ";
            for(int j = 0; j < SHA256_DIGEST_LENGTH; j++) {
                std::cout << std::hex << std::setw(2) << std::setfill('0')
                         << static_cast<int>(hashResults[i * SHA256_DIGEST_LENGTH + j]);
            }
            std::cout << std::dec << std::endl;
        }

        cthread->printDebug();

        for(int i = 0; i < n_reps; i++) {
            if(inputData[i]) {
                cthread->freeMem(inputData[i]);
                inputData[i] = nullptr;
            }
        }
        if(hashResults) {
            cthread->freeMem(hashResults);
            hashResults = nullptr;
        }

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
