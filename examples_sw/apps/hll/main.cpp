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
constexpr auto const defSize = 128 * 1024;
constexpr auto const defDW = 4;
constexpr auto const nBenchRuns = 1;

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
    uint32_t n_pages_rslt = (n_reps * 4 + pageSize - 1) / pageSize;

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
        uint32_t* hMem = (uint32_t*) cthread->getMem({CoyoteAlloc::HPF, n_pages_host});
        float* rMem = (float*) cthread->getMem({CoyoteAlloc::REG, n_pages_rslt});

        if (!hMem || !rMem) {
            throw std::runtime_error("Memory allocation failed");
        }

        // Setup scatter-gather entries for transfer
        sgEntry sg;
        sgFlags sg_flags = { false, false, false };

        // Benchmark setup
        cBench bench(nBenchRuns);
        PR_HEADER("CARDINALITY ESTIMATION");

        auto benchmark_thr = [&]() {
            for(int i = 0; i < n_reps; i++) {
                // Clear previous completion status
                cthread->clearCompleted();

                // Fill with random data
                for(int j = 0; j < size/defDW; j++) {
                    hMem[j] = rand();
                }

                // Setup transfer
                memset(&sg, 0, sizeof(localSg));
                sg.local.src_addr = hMem;
                sg.local.src_len = size;
                sg.local.src_stream = strmHost;
                sg.local.src_dest = targetVfid;

                sg.local.dst_addr = &rMem[i];
                sg.local.dst_len = 4;  // Size of float
                sg.local.dst_stream = strmHost;
                sg.local.dst_dest = targetVfid;

                sg_flags.last = true;  // Mark as last for this transfer
                
                // Execute transfer
                cthread->invoke(CoyoteOper::LOCAL_TRANSFER, &sg, sg_flags);

                // Wait for completion with timeout
                auto start_time = std::chrono::high_resolution_clock::now();
                bool completed = false;
                
                while (!completed) {
                    if (stalled.load()) {
                        throw std::runtime_error("Stalled, SIGINT caught");
                    }

                    completed = (cthread->checkCompleted(CoyoteOper::LOCAL_TRANSFER) == 1);
                    
                    auto current_time = std::chrono::high_resolution_clock::now();
                    auto elapsed = std::chrono::duration_cast<std::chrono::seconds>
                                 (current_time - start_time).count();
                    
                    if (elapsed > 5) { // 5 second timeout
                        throw std::runtime_error("Transfer timeout in repetition " + std::to_string(i));
                    }

                    if (!completed) {
                        std::this_thread::sleep_for(std::chrono::milliseconds(10));
                    }
                }
            }
        };

        bench.runtime(benchmark_thr);

        // Print results
        std::cout << std::fixed << std::setprecision(2);
        std::cout << "Size: " << std::setw(8) << size << ", thr: " 
                  << std::setw(8) << (1000 * size) / (bench.getAvg() / n_reps) 
                  << " MB/s" << std::endl << std::endl;

        for(int i = 0; i < n_reps; i++)
            std::cout << "Repetition: " << std::setw(8) << i 
                     << ", cardinality: " << rMem[i] << std::endl;
        std::cout << std::endl;
        
        // Print debug info
        cthread->printDebug();

        // Cleanup
        if(hMem) cthread->freeMem(hMem);
        if(rMem) cthread->freeMem(rMem);

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }
    
    return EXIT_SUCCESS;
}
