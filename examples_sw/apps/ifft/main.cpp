#include <iostream>
#include <string>
#include <malloc.h>
#include <signal.h>
#include <boost/program_options.hpp>
#include <any>
#include <cmath>
#include <vector>
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
constexpr auto const defSize = 16384;
constexpr auto const defDW = 4;


void generateFrequencyData(float* buffer, int size) {
    memset(buffer, 0, 2 * size * sizeof(float));
    
    // Lower frequency component
    int freq_idx = size/16;  // Using lower frequency 
    buffer[2*freq_idx] = 500.0f;     // Real part
    buffer[2*freq_idx+1] = 0.0f;     // Imaginary part
    
    // Add second harmonic
    buffer[2*(freq_idx*2)] = 250.0f;
    buffer[2*(freq_idx*2)+1] = 0.0f;
}

int main(int argc, char *argv[]) {
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    boost::program_options::options_description programDescription("Options:");
    programDescription.add_options()
        ("reps,r", boost::program_options::value<uint32_t>(), "Number of reps");
    
    boost::program_options::variables_map commandLineArgs;
    boost::program_options::store(boost::program_options::parse_command_line(argc, argv, programDescription), commandLineArgs);
    boost::program_options::notify(commandLineArgs);

    uint32_t size = defSize;
    uint32_t n_reps = defReps;
    
    if(commandLineArgs.count("reps") > 0) n_reps = commandLineArgs["reps"].as<uint32_t>();

    uint32_t buffer_size = 2 * size * sizeof(float);  // Complex data (real + imaginary)
    uint32_t n_pages = (buffer_size + hugePageSize - 1) / hugePageSize;

    PR_HEADER("PARAMS");
    std::cout << "vFPGA ID: " << targetVfid << std::endl;
    std::cout << "Number of allocated pages per run: " << n_pages << std::endl;
    std::cout << "IFFT size: " << size << std::endl;
    std::cout << "Number of reps: " << n_reps << std::endl;

    try {
        std::unique_ptr<cThread<std::any>> cthread(new cThread<std::any>(targetVfid, getpid(), defDevice));
        cthread->start();
        
        std::vector<float*> input_buffers(n_reps, nullptr);
        std::vector<float*> output_buffers(n_reps, nullptr);

        // Allocate and initialize memory
	for(int i = 0; i < n_reps; i++) {
	    input_buffers[i] = (float*) cthread->getMem({CoyoteAlloc::HPF, n_pages});
	    output_buffers[i] = (float*) cthread->getMem({CoyoteAlloc::HPF, n_pages});
	    
	    if (!input_buffers[i] || !output_buffers[i]) {
		throw std::runtime_error("Memory allocation failed");
	    }

	    // Initialize with frequency domain test data
	    generateFrequencyData(input_buffers[i], size);
	    memset(output_buffers[i], 0, buffer_size);
	}

        sgEntry sg;
        sgFlags sg_flags = { true, true, false };

        cBench bench(n_reps);
        PR_HEADER("IFFT PROCESSING");

        cthread->clearCompleted();

        auto benchmark_thr = [&]() {
            for(int i = 0; i < n_reps; i++) {
                memset(&sg, 0, sizeof(localSg));
                
                sg.local.src_addr = input_buffers[i];
                sg.local.src_len = buffer_size;
                sg.local.src_stream = strmHost;
                sg.local.src_dest = targetVfid;

                sg.local.dst_addr = output_buffers[i];
                sg.local.dst_len = buffer_size;
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

        std::cout << std::fixed << std::setprecision(2);
        std::cout << "Size: " << std::setw(8) << size << ", throughput: " 
                  << std::setw(8) << (1000 * buffer_size) / (bench.getAvg() / n_reps) 
                  << " MB/s" << std::endl;

        // Print sample output
        for(int i = 0; i < n_reps; i++) {
            float* output_ptr = output_buffers[i];
            std::cout << "\nFirst 32 output values:\n";
            for(int j = 0; j < 32; j++) {
                std::cout << std::fixed << std::setprecision(6) << output_ptr[j] << " ";
                if((j + 1) % 8 == 0) std::cout << "\n";
            }
        }

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
