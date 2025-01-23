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

/* Signal handler */
std::atomic<bool> stalled(false); 
void gotInt(int) {
    stalled.store(true);
}

/* Def params */
constexpr auto const defDevice = 0;
constexpr auto const targetVfid = 0;  
constexpr auto const defReps = 1;
constexpr auto const INPUT_WIDTH = 32;
constexpr auto const INPUT_HEIGHT = 32;
constexpr auto const OUTPUT_WIDTH = 32;
constexpr auto const OUTPUT_HEIGHT = 32;

struct RGBPixel {
    unsigned char r;
    unsigned char g;
    unsigned char b;
    unsigned char reserved;
} __attribute__((aligned(8)));

int main(int argc, char *argv[]) {
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    uint32_t n_reps = defReps;
    uint32_t input_buffer_size = INPUT_WIDTH * INPUT_HEIGHT * sizeof(RGBPixel);
    uint32_t output_buffer_size = OUTPUT_WIDTH * OUTPUT_HEIGHT * sizeof(RGBPixel);
    uint32_t input_pages = (input_buffer_size + hugePageSize - 1) / hugePageSize;
    uint32_t output_pages = (output_buffer_size + hugePageSize - 1) / hugePageSize;

    PR_HEADER("PARAMS");
    std::cout << "vFPGA ID: " << targetVfid << std::endl;
    std::cout << "Input dimensions: " << INPUT_WIDTH << "x" << INPUT_HEIGHT << std::endl;
    std::cout << "Output dimensions: " << OUTPUT_WIDTH << "x" << OUTPUT_HEIGHT << std::endl;
    std::cout << "Number of reps: " << n_reps << std::endl;

    try {
        std::cout << "Initializing Coyote thread..." << std::endl;
        std::unique_ptr<cThread<std::any>> cthread(new cThread<std::any>(targetVfid, getpid(), defDevice));
        
        std::cout << "Starting Coyote thread..." << std::endl;
        cthread->start();

        std::cout << "Allocating memory..." << std::endl;
        std::vector<RGBPixel*> input_data(n_reps, nullptr);
        std::vector<RGBPixel*> output_data(n_reps, nullptr);

        for(int i = 0; i < n_reps; i++) {
            input_data[i] = (RGBPixel*) cthread->getMem({CoyoteAlloc::HPF, input_pages});
            output_data[i] = (RGBPixel*) cthread->getMem({CoyoteAlloc::HPF, output_pages});
            
            if (!input_data[i] || !output_data[i]) {
                throw std::runtime_error("Memory allocation failed");
            }

            for(int j = 0; j < INPUT_WIDTH * INPUT_HEIGHT; j++) {
                input_data[i][j].r = (unsigned char)(j % 255);
                input_data[i][j].g = (unsigned char)(j % 255);
                input_data[i][j].b = 128;
                input_data[i][j].reserved = 0;
            }
            memset(output_data[i], 0, output_buffer_size);
        }

        sgEntry sg;
        sgFlags sg_flags = { true, true, false };
        cBench bench(n_reps);
        PR_HEADER("LETTERBOX PROCESSING");

        std::cout << "Clearing completion flags..." << std::endl;
        cthread->clearCompleted();
        
        std::cout << "Starting data transfer..." << std::endl;
        bench.runtime([&]() {
            for(int i = 0; i < n_reps; i++) {
                memset(&sg, 0, sizeof(localSg));
                sg.local.src_addr = input_data[i];
                sg.local.src_len = input_buffer_size;
                sg.local.src_stream = strmHost;
                sg.local.src_dest = targetVfid;

                sg.local.dst_addr = output_data[i];
                sg.local.dst_len = output_buffer_size;
                sg.local.dst_stream = strmHost;
                sg.local.dst_dest = targetVfid;
                
                sg_flags.last = (i == n_reps-1);

                std::cout << "Invoking transfer " << i + 1 << "/" << n_reps << std::endl;
                cthread->invoke(CoyoteOper::LOCAL_TRANSFER, &sg, sg_flags);
            }

            std::cout << "Waiting for completion..." << std::endl;
            unsigned int timeout_counter = 0;
            while(cthread->checkCompleted(CoyoteOper::LOCAL_WRITE) != 1) {
                if(stalled.load()) throw std::runtime_error("Operation stalled");
                if(++timeout_counter > 1000000) {
                    throw std::runtime_error("Operation timeout");
                }
                usleep(1000);  // Sleep 1ms between checks
            }
        });

        std::cout << "Processing completed" << std::endl;
        cthread->printDebug();

        for(int i = 0; i < n_reps; i++) {
            if(input_data[i]) cthread->freeMem(input_data[i]);
            if(output_data[i]) cthread->freeMem(output_data[i]);
        }

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }
    
    return EXIT_SUCCESS;
}
