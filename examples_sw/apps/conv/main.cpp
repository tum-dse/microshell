#include <iostream>
#include <string>
#include <iomanip>
#include <signal.h>
#include <unistd.h>
#include <memory>
#include <any>
#include <chrono>
#include <boost/program_options.hpp>
#include "cBench.hpp"
#include "cThread.hpp"

using namespace std;
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
constexpr auto const defSize = 64 * 64;  // 64x64 image default

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
    uint32_t total_size = size * size * bytes_per_pixel;
    uint32_t n_pages = (total_size + hugePageSize - 1) / hugePageSize;

    PR_HEADER("CONVOLUTION TEST");
    std::cout << "Image size: " << size << "x" << size << " pixels" << std::endl;
    std::cout << "Total size: " << total_size << " bytes" << std::endl;
    std::cout << "Pages required: " << n_pages << std::endl;
    std::cout << "Repetitions: " << n_reps << std::endl;

    try {
        // Initialize FPGA thread
        std::unique_ptr<cThread<std::any>> cthread(new cThread<std::any>(targetVfid, getpid(), defDevice));
        cthread->start();

        // Allocate memory
        uint64_t* input_buffer = (uint64_t*)cthread->getMem({CoyoteAlloc::HPF, n_pages});
        uint64_t* output_buffer = (uint64_t*)cthread->getMem({CoyoteAlloc::HPF, n_pages});
        
        if (!input_buffer || !output_buffer) {
            throw std::runtime_error("Memory allocation failed");
        }

        // Fill input with test pattern
        std::cout << "Writing test pattern..." << std::endl;
        for(uint32_t i = 0; i < total_size; i++) {
            ((uint8_t*)input_buffer)[i] = i & 0xFF;
        }

        // Configure image size
        cthread->setCSR(size, 0);  // Set image width/height

        // Setup transfer
        sgEntry sg;
        sgFlags sg_flags = {false, false, false};
        
        memset(&sg, 0, sizeof(sgEntry));
        sg.local.src_addr = input_buffer;
        sg.local.src_len = total_size;
        sg.local.src_stream = strmHost;
        sg.local.src_dest = targetVfid;
        
        sg.local.dst_addr = output_buffer;
        sg.local.dst_len = total_size;
        sg.local.dst_stream = strmHost;
        sg.local.dst_dest = targetVfid;

        // Clear any previous completions
        cthread->clearCompleted();

        std::cout << "Starting convolution..." << std::endl;
        cthread->invoke(CoyoteOper::LOCAL_TRANSFER, &sg, sg_flags);

        // Wait for completion with timeout
        auto start = std::chrono::high_resolution_clock::now();
        while(cthread->checkCompleted(CoyoteOper::LOCAL_TRANSFER) != 1) {
            if(stalled.load()) {
                throw std::runtime_error("Operation interrupted");
            }
            
            auto now = std::chrono::high_resolution_clock::now();
            if(std::chrono::duration_cast<std::chrono::seconds>(now - start).count() > 10) {
                throw std::runtime_error("Operation timeout");
            }
            
            usleep(1000);  // 1ms sleep
        }

        // Basic verification - check if output is not all zeros
        std::cout << "Verifying output..." << std::endl;
        bool has_data = false;
        for(uint32_t i = 0; i < total_size && !has_data; i++) {
            if(((uint8_t*)output_buffer)[i] != 0) {
                has_data = true;
            }
        }
        
        if(!has_data) {
            std::cout << "WARNING: Output buffer contains all zeros!" << std::endl;
        }

        // Print some sample values
        std::cout << "\nFirst few input pixels: ";
        for(int i = 0; i < 4; i++) {
            std::cout << std::hex << (int)((uint8_t*)input_buffer)[i] << " ";
        }
        
        std::cout << "\nFirst few output pixels: ";
        for(int i = 0; i < 4; i++) {
            std::cout << std::hex << (int)((uint8_t*)output_buffer)[i] << " ";
        }
        std::cout << std::dec << std::endl;

        // Cleanup
        cthread->freeMem(input_buffer);
        cthread->freeMem(output_buffer);

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }
    
    return EXIT_SUCCESS;
}
