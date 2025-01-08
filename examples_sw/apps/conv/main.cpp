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
#ifdef EN_AVX
#include <x86intrin.h>
#endif
#include <boost/program_options.hpp>
#include <any>
#include <cmath>
#include <random>
#include <vector>
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

/* Default parameters */
constexpr auto const defDevice = 0;
constexpr auto const targetVfid = 0;  
constexpr auto const defReps = 1;
constexpr auto const defSize = 32;  // 32x32 image default

int main(int argc, char *argv[])  
{
    // Signal handler
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    // Program options
    boost::program_options::options_description programDescription("Options:");
    programDescription.add_options()
        ("size,s", boost::program_options::value<uint32_t>(), "Image size (width=height)")
        ("reps,r", boost::program_options::value<uint32_t>(), "Number of repetitions");
    
    boost::program_options::variables_map commandLineArgs;
    boost::program_options::store(boost::program_options::parse_command_line(argc, argv, programDescription), commandLineArgs);
    boost::program_options::notify(commandLineArgs);

    uint32_t size = defSize;
    uint32_t n_reps = defReps;

    if(commandLineArgs.count("size") > 0) size = commandLineArgs["size"].as<uint32_t>();
    if(commandLineArgs.count("reps") > 0) n_reps = commandLineArgs["reps"].as<uint32_t>();

    // Calculate memory requirements
    uint32_t bytes_per_pixel = 1;  // 8-bit pixels
    uint32_t buffer_size = size * size * bytes_per_pixel;
    uint32_t aligned_size = ((buffer_size + 511) / 512) * 512; // Align to 512 bytes
    uint32_t n_pages = (aligned_size + hugePageSize - 1) / hugePageSize;


    PR_HEADER("CONVOLUTION TEST");
    std::cout << "Image size: " << size << "x" << size << " pixels" << std::endl;
    std::cout << "Buffer size: " << buffer_size << " bytes" << std::endl;
    std::cout << "Aligned size: " << aligned_size << " bytes" << std::endl;
    std::cout << "Pages required: " << n_pages << std::endl;
    std::cout << "Repetitions: " << n_reps << std::endl;

    try {
        // Initialize FPGA thread
        std::unique_ptr<cThread<std::any>> cthread(new cThread<std::any>(targetVfid, getpid(), defDevice));
        cthread->start();

        std::vector<uint64_t*> input_buffers(n_reps, nullptr);
        std::vector<uint64_t*> output_buffers(n_reps, nullptr);
        
        // Allocate and initialize memory
        for(int i = 0; i < n_reps; i++) {
            input_buffers[i] = (uint64_t*) cthread->getMem({CoyoteAlloc::HPF, n_pages});
            output_buffers[i] = (uint64_t*) cthread->getMem({CoyoteAlloc::HPF, n_pages});
            
            if (!input_buffers[i] || !output_buffers[i]) {
                throw std::runtime_error("Memory allocation failed");
            }

            // Fill input with test pattern
            for(uint32_t j = 0; j < aligned_size; j++) {
                ((uint64_t*)input_buffers[i])[j] = j & 0xFF;
            }

            // Clear output buffer
            memset(output_buffers[i], 0, aligned_size);
        }

        // Setup transfer
        sgEntry sg;
        sgFlags sg_flags = {true, true, false};
        
        cBench bench(n_reps);
        PR_HEADER("CONV");

        cthread->clearCompleted();

        auto benchmark_thr = [&]() {
            for(int i = 0; i < n_reps; i++) {
                memset(&sg, 0, sizeof(sgEntry));
                
                sg.local.src_addr = input_buffers[i];
                sg.local.src_len = aligned_size;
                sg.local.src_stream = strmHost;
                sg.local.src_dest = targetVfid;

                sg.local.dst_addr = output_buffers[i];
                sg.local.dst_len = aligned_size;
                sg.local.dst_stream = strmHost;
                sg.local.dst_dest = targetVfid;

                sg_flags.last = (i == n_reps-1);
                
                cthread->invoke(CoyoteOper::LOCAL_TRANSFER, &sg, sg_flags);
            }

            // Wait for completion with status updates
            auto start = std::chrono::high_resolution_clock::now();
            while(cthread->checkCompleted(CoyoteOper::LOCAL_WRITE) != 1) {
                if(stalled.load()) throw std::runtime_error("Stalled");
                
                auto now = std::chrono::high_resolution_clock::now();
                auto elapsed = std::chrono::duration_cast<std::chrono::seconds>(now - start).count();
                
                if(elapsed > 5) {
                    throw std::runtime_error("Transfer timeout");
                }
            }
        };

        bench.runtime(benchmark_thr);

        // Print results
        std::cout << std::fixed << std::setprecision(2);
        std::cout << "Size: " << std::setw(8) << size << ", throughput: " 
                  << std::setw(8) << (1000 * aligned_size) / (bench.getAvg() / n_reps) 
                  << " MB/s" << std::endl;

        // Print sample values from first buffer
        std::cout << "\nFirst few input pixels: ";
        for(int i = 0; i < 4; i++) {
            std::cout << std::hex << (int)((uint64_t*)input_buffers[0])[i] << " ";
        }
        
        std::cout << "\nFirst few output pixels: ";
        for(int i = 0; i < 4; i++) {
            std::cout << std::hex << (int)((uint64_t*)output_buffers[0])[i] << " ";
        }
        std::cout << std::dec << std::endl;

        cthread->printDebug();

        // Cleanup
        for(int i = 0; i < n_reps; i++) {
            if(input_buffers[i]) cthread->freeMem(input_buffers[i]);
            if(output_buffers[i]) cthread->freeMem(output_buffers[i]);
        }

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }
    
    return EXIT_SUCCESS;
}