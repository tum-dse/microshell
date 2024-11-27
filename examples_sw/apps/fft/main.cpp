#include <iostream>
#include <string>
#include <malloc.h>
#include <chrono>
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
constexpr auto const defSize = 16384;
constexpr auto const defDW = 4;

int main(int argc, char *argv[]) {
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    boost::program_options::options_description programDescription("Options:");
    programDescription.add_options()
        ("size,s", boost::program_options::value<uint32_t>(), "FFT size")
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
    std::cout << "FFT size: " << size << std::endl;
    std::cout << "Number of reps: " << n_reps << std::endl;

    try {
        std::unique_ptr<cThread<std::any>> cthread(new cThread<std::any>(targetVfid, getpid(), defDevice));
        cthread->start();

        std::vector<float*> input_data(n_reps, nullptr);
        std::vector<float*> output_data(n_reps, nullptr);

        for(int i = 0; i < n_reps; i++) {
            input_data[i] = (float*) cthread->getMem({CoyoteAlloc::HPF, n_pages_host});
            output_data[i] = (float*) cthread->getMem({CoyoteAlloc::HPF, n_pages_host});
            
            if (!input_data[i] || !output_data[i]) {
                throw std::runtime_error("Memory allocation failed");
            }

            for(int j = 0; j < size; j++) {
                input_data[i][j] = sin(2.0 * M_PI * j / size);
            }
        }

        sgEntry sg;
        sgFlags sg_flags = { false, false, false };

        cBench bench(n_reps);
        PR_HEADER("FFT PROCESSING");

        auto benchmark_thr = [&]() {
            for(int i = 0; i < n_reps; i++) {
                memset(&sg, 0, sizeof(localSg));
                sg.local.src_addr = input_data[i];
                sg.local.src_len = n_pages_host * hugePageSize;
                sg.local.src_stream = strmHost;
                sg.local.src_dest = targetVfid;

                sg.local.dst_addr = output_data[i];
                sg.local.dst_len = n_pages_host * hugePageSize;
                sg.local.dst_stream = strmHost;
                sg.local.dst_dest = targetVfid;

                if(i == n_reps-1) sg_flags.last = true;
                
                cthread->invoke(CoyoteOper::LOCAL_TRANSFER, &sg, sg_flags);
            }

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

        std::cout << std::fixed << std::setprecision(2);
        std::cout << "Size: " << std::setw(8) << size << ", throughput: " 
                  << std::setw(8) << (1000 * size * sizeof(float)) / (bench.getAvg() / n_reps) 
                  << " MB/s" << std::endl;

        cthread->printDebug();

        for(int i = 0; i < n_reps; i++) {
            if(input_data[i]) {
                cthread->freeMem(input_data[i]);
                input_data[i] = nullptr;
            }
            if(output_data[i]) {
                cthread->freeMem(output_data[i]);
                output_data[i] = nullptr;
            }
        }

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }
    
    return EXIT_SUCCESS;
}
