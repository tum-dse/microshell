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

/* Signal handler */
std::atomic<bool> stalled(false); 
void gotInt(int) {
    stalled.store(true);
}

/* Def params */
constexpr auto const defDevice = 0;
constexpr auto const targetVfid = 0;  
constexpr auto const defReps = 1;
constexpr auto const defSize = 64 * 1024;  // 64KB default
constexpr auto const defDW = 8;            // 64-bit for AES

// AES constants
constexpr auto const keyLow = 0xabf7158809cf4f3c;
constexpr auto const keyHigh = 0x2b7e151628aed2a6;
constexpr auto const plainLow = 0xe93d7e117393172a;
constexpr auto const plainHigh = 0x6bc1bee22e409f96;
constexpr auto const cipherLow = 0xa89ecaf32466ef97;
constexpr auto const cipherHigh = 0x3ad77bb40d7a3660;

int main(int argc, char *argv[])  
{
    // Signal handler setup
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    // Read arguments
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
    uint32_t n_pages_rslt = (n_reps * size + pageSize - 1) / pageSize;

    PR_HEADER("PARAMS");
    std::cout << "vFPGA ID: " << targetVfid << std::endl;
    std::cout << "Number of allocated pages per run: " << n_pages_host << std::endl;
    std::cout << "Data size: " << size << std::endl;
    std::cout << "Number of reps: " << n_reps << std::endl;

    try {
        // Initialize thread
        std::unique_ptr<cThread<std::any>> cthread(new cThread<std::any>(targetVfid, getpid(), defDevice));
        cthread->start();

        // Memory allocation
        std::vector<uint64_t*> plaintext(n_reps, nullptr);
        std::vector<uint64_t*> ciphertext(n_reps, nullptr);

        // Allocate and fill memory
        for(int i = 0; i < n_reps; i++) {
            plaintext[i] = (uint64_t*) cthread->getMem({CoyoteAlloc::HPF, n_pages_host});
            ciphertext[i] = (uint64_t*) cthread->getMem({CoyoteAlloc::HPF, n_pages_host});
            
            if (!plaintext[i] || !ciphertext[i]) {
                throw std::runtime_error("Memory allocation failed");
            }

            // Fill with test pattern
            for(int j = 0; j < size/defDW; j++) {
                plaintext[i][j] = (j % 2) ? plainHigh : plainLow;
            }
        }

        // Set AES key
        cthread->setCSR(keyLow, 0);
        cthread->setCSR(keyHigh, 1);

        // Setup scatter-gather entries for transfer
        sgEntry sg;
        sgFlags sg_flags = { false, false, false };

        // Benchmark setup
        cBench bench(1);
        PR_HEADER("AES ENCRYPTION");

        // Clear any previous completions
        cthread->clearCompleted();

        auto benchmark_thr = [&]() {
            // Queue all transfers
            for(int i = 0; i < n_reps; i++) {
                memset(&sg, 0, sizeof(localSg));
                sg.local.src_addr = plaintext[i];
                sg.local.src_len = size;
                sg.local.src_stream = strmHost;
                sg.local.src_dest = targetVfid;

                sg.local.dst_addr = ciphertext[i];
                sg.local.dst_len = size;
                sg.local.dst_stream = strmHost;
                sg.local.dst_dest = targetVfid;

                if(i == n_reps-1) sg_flags.last = true;
                
                cthread->invoke(CoyoteOper::LOCAL_TRANSFER, &sg, sg_flags);
            }

            // Wait for all transfers with timeout
            auto start_time = std::chrono::high_resolution_clock::now();
            while(cthread->checkCompleted(CoyoteOper::LOCAL_TRANSFER) != n_reps) {
                if(stalled.load()) throw std::runtime_error("Stalled, SIGINT caught");
                
                auto current_time = std::chrono::high_resolution_clock::now();
                auto elapsed = std::chrono::duration_cast<std::chrono::seconds>
                             (current_time - start_time).count();
                
                if (elapsed > 30) { // 30 second timeout for all transfers
                    throw std::runtime_error("Transfers timeout");
                }
            }
        };

        bench.runtime(benchmark_thr);

        // Print results
        std::cout << std::fixed << std::setprecision(2);
        std::cout << "Size: " << std::setw(8) << size << ", thr: " 
                  << std::setw(8) << (1000 * size) / (bench.getAvg() / n_reps) 
                  << " MB/s" << std::endl << std::endl;

        // Verify results
        bool success = true;
        for(int i = 0; i < n_reps && success; i++) {
            for(int j = 0; j < size/defDW && success; j++) {
                uint64_t expected = (j % 2) ? cipherHigh : cipherLow;
                if(ciphertext[i][j] != expected) {
                    std::cout << "Verification failed at rep " << i << ", offset " << j << std::endl;
                    std::cout << "Expected: 0x" << std::hex << expected 
                             << ", Got: 0x" << ciphertext[i][j] << std::dec << std::endl;
                    success = false;
                }
            }
        }
        
        std::cout << "Verification: " << (success ? "PASSED" : "FAILED") << std::endl;
        
        // Print debug info
        cthread->printDebug();

        // Cleanup
        for(int i = 0; i < n_reps; i++) {
            if(plaintext[i]) {
                cthread->freeMem(plaintext[i]);
                plaintext[i] = nullptr;
            }
            if(ciphertext[i]) {
                cthread->freeMem(ciphertext[i]);
                ciphertext[i] = nullptr;
            }
        }

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }
    
    return EXIT_SUCCESS;
}
