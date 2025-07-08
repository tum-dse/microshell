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
constexpr auto const defSize = 32;  // Default: single 32-point FFT

// Helper function to print latency statistics
void printLatencyStats(double latency_ns) {
    std::cout << std::fixed << std::setprecision(2);
    std::cout << "Processing started at: 0 ns" << std::endl;
    std::cout << "Processing completed at: " << latency_ns << " ns" << std::endl;
    std::cout << "Total latency: " << latency_ns << " ns (" << (latency_ns / 1000) << " us)" << std::endl;
}

int main(int argc, char *argv[]) {
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    boost::program_options::options_description programDescription("Options:");
    programDescription.add_options()
        ("size,s", boost::program_options::value<uint32_t>(), "Total samples (must be multiple of 32)")
        ("reps,r", boost::program_options::value<uint32_t>(), "Number of repetitions");
    
    boost::program_options::variables_map commandLineArgs;
    boost::program_options::store(boost::program_options::parse_command_line(argc, argv, programDescription), commandLineArgs);
    boost::program_options::notify(commandLineArgs);

    uint32_t size = defSize;
    uint32_t n_reps = defReps;
    
    if(commandLineArgs.count("size") > 0) size = commandLineArgs["size"].as<uint32_t>();
    if(commandLineArgs.count("reps") > 0) n_reps = commandLineArgs["reps"].as<uint32_t>();

    // Ensure size is a multiple of 32 (FFT requirement)
    if (size % 32 != 0) {
        std::cout << "Warning: Size must be multiple of 32. Adjusting " << size 
                  << " to " << ((size + 31) / 32) * 32 << std::endl;
        size = ((size + 31) / 32) * 32;
    }

    // FIXED: Calculate buffer requirements correctly
    uint32_t num_ffts = size / 32;  // Number of 32-point FFTs
    
    // CRITICAL FIX: Input should be complex (interleaved real/imaginary) for FFT
    uint32_t complex_samples = 2 * size;  // Each sample becomes [real, imag]
    uint32_t input_buffer_size = complex_samples * sizeof(float);
    
    // Output: one classification per 32-point FFT
    uint32_t output_buffer_size = num_ffts * sizeof(float);
    
    uint32_t n_pages_input = (input_buffer_size + hugePageSize - 1) / hugePageSize;
    uint32_t n_pages_output = (output_buffer_size + hugePageSize - 1) / hugePageSize;

    PR_HEADER("PARAMS");
    std::cout << "vFPGA ID: " << targetVfid << std::endl;
    std::cout << "Input pages per run: " << n_pages_input << std::endl;
    std::cout << "Output pages per run: " << n_pages_output << std::endl;
    std::cout << "Total samples: " << size << " (" << num_ffts << " x 32-point FFTs)" << std::endl;
    std::cout << "Expected classifications: " << num_ffts << std::endl;
    std::cout << "Number of reps: " << n_reps << std::endl;

    try {
        std::unique_ptr<cThread<std::any>> cthread(new cThread<std::any>(targetVfid, getpid(), defDevice));
        cthread->start();
        
        std::vector<float*> input_buffers(n_reps, nullptr);
        std::vector<float*> output_buffers(n_reps, nullptr);

        // FIXED: Generate test data that will produce known SVM results after FFT
        // Use the same base pattern that works in your SVM-only test, but apply it per FFT
        float base_pattern[32] = {
            36257662.0f, 70308074.0f, 162763557.0f, 109956489.0f, 86125933.0f,
            35535698.0f, 5473712.0f, 2191429.0f, 1655529.0f, 1427210.0f,
            1819290.0f, 2594503.0f, 2649694.0f, 849597.0f, 765175.0f,
            890647.0f, 1405332.0f, 1132804.0f, 5776375.0f, 18372118.0f,
            6724989.0f, 7313762.0f, 1469345.0f, 1744257.0f, 1631652.0f,
            823229.0f, 1018674.0f, 639273.0f, 601445.0f, 630083.0f,
            678854.0f, 636897.0f
        };

        // Show first FFT input data
        std::cout << "\nFirst 32-point FFT input (complex format):\n";
        for (int i = 0; i < 16; ++i) {  // Show first 16 complex pairs
            std::cout << std::fixed << std::setprecision(1) 
                      << base_pattern[i] << "+0.0i ";
            if ((i + 1) % 4 == 0) std::cout << "\n";
        }
        std::cout << "... (remaining 16 samples omitted)\n\n";

        // Allocate and initialize memory
        for(int i = 0; i < n_reps; i++) {
            input_buffers[i] = (float*) cthread->getMem({CoyoteAlloc::HPF, n_pages_input});
            output_buffers[i] = (float*) cthread->getMem({CoyoteAlloc::HPF, n_pages_output});
            
            if (!input_buffers[i] || !output_buffers[i]) {
                throw std::runtime_error("Memory allocation failed");
            }

            // FIXED: Fill complex data for FFT input
            // Each FFT gets a different variant of the base pattern
            for(int fft_idx = 0; fft_idx < num_ffts; fft_idx++) {
                for(int sample = 0; sample < 32; sample++) {
                    int complex_base = (fft_idx * 32 + sample) * 2;
                    
                    // Real part: base pattern + offset per FFT
                    input_buffers[i][complex_base] = base_pattern[sample] + (fft_idx * 1000.0f);
                    
                    // Imaginary part: zero (pure real signal)
                    input_buffers[i][complex_base + 1] = 0.0f;
                }
            }

            // Clear output buffer
            memset(output_buffers[i], 0, output_buffer_size);
        }
        
        sgEntry sg;
        sgFlags sg_flags = { true, true, false };

        cBench bench(n_reps);
        PR_HEADER("FFT + SVM PROCESSING");

        cthread->clearCompleted();

        auto benchmark_thr = [&]() {
            for(int i = 0; i < n_reps; i++) {
                memset(&sg, 0, sizeof(localSg));
                
                sg.local.src_addr = input_buffers[i];
                sg.local.src_len = input_buffer_size;
                sg.local.src_stream = strmHost;
                sg.local.src_dest = targetVfid;

                sg.local.dst_addr = output_buffers[i];
                sg.local.dst_len = output_buffer_size;
                sg.local.dst_stream = strmHost;
                sg.local.dst_dest = targetVfid;

                sg_flags.last = (i == n_reps-1);
                
                cthread->invoke(CoyoteOper::LOCAL_TRANSFER, &sg, sg_flags);
            }

            while(cthread->checkCompleted(CoyoteOper::LOCAL_WRITE) != 1) {
                if(stalled.load()) throw std::runtime_error("Stalled");
            }
        };

        bench.runtime(benchmark_thr);

        // Print basic results
        std::cout << std::fixed << std::setprecision(2);
        std::cout << "Size: " << std::setw(8) << size << ", thr: " 
                  << std::setw(8) << (1000 * input_buffer_size) / (bench.getAvg() / n_reps) 
                  << " MB/s" << std::endl << std::endl;

        // Print latency statistics
        PR_HEADER("LATENCY MEASUREMENTS");
        printLatencyStats(bench.getAvg() / n_reps);

        PR_HEADER("RESULTS");
        // Print all classification results
        for(int i = 0; i < n_reps; i++) {
            std::cout << "Rep " << i << " classification results:\n";
            for (uint32_t fft_idx = 0; fft_idx < num_ffts; fft_idx++) {
                float result = output_buffers[i][fft_idx];
                std::cout << "  FFT " << (fft_idx + 1) << "/" << num_ffts << ": " << result;
                
                // Map result to class label if it matches known values
                uint32_t result_bits = *(uint32_t*)&result;
                switch(result_bits) {
                    case 0x40800000: std::cout << " (Class 4)"; break;
                    case 0x3F800000: std::cout << " (Class 1)"; break;
                    case 0x40000000: std::cout << " (Class 2)"; break;
                    case 0x40400000: std::cout << " (Class 3)"; break;
                    case 0x40A00000: std::cout << " (Class 5)"; break;
                    default: 
                        if (result == 0.0f) std::cout << " (No result - check pipeline)";
                        else std::cout << " (Unknown class)";
                        break;
                }
                std::cout << std::endl;
            }
            std::cout << std::endl;
        }
        
        // Print debug info
        cthread->printDebug();

        // Cleanup
        for(int i = 0; i < n_reps; i++) {
            if(input_buffers[i]) {
                cthread->freeMem(input_buffers[i]);
                input_buffers[i] = nullptr;
            }
            if(output_buffers[i]) {
                cthread->freeMem(output_buffers[i]);
                output_buffers[i] = nullptr;
            }
        }

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }
    
    return EXIT_SUCCESS;
}