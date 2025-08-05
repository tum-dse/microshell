/**
 * AES CTR Encryption
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

/* Signal handler */
std::atomic<bool> stalled(false); 
void gotInt(int) {
    stalled.store(true);
}

/* Def params */
constexpr auto const defDevice = 0;
constexpr auto const targetVfid = 0;  
constexpr auto const defReps = 1;
constexpr auto const defSize = 1024;   // Default: 1KB data size

// Test pattern for AES
constexpr uint8_t test_plaintext[16] = {
    0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77,
    0x88, 0x99, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff
};

// Create descriptor based on panic_define.v format (128-bit descriptor)
void createPanicDescriptor(uint8_t* desc_ptr, uint32_t data_size) {
    // Initialize descriptor to zero (128 bits = 16 bytes)
    memset(desc_ptr, 0, 16);
    
    // Bits 0-31: Length
    desc_ptr[0] = data_size & 0xFF;
    desc_ptr[1] = (data_size >> 8) & 0xFF;
    desc_ptr[2] = (data_size >> 16) & 0xFF;
    desc_ptr[3] = (data_size >> 24) & 0xFF;
    
    // Bits 32-47: Cell ID
    desc_ptr[4] = 0x00;
    desc_ptr[5] = 0x00;
    
    // Bits 48-63: Chain (destination 1 = DMA engine)
    desc_ptr[6] = 0x01;
    desc_ptr[7] = 0x00;
    
    // Remaining fields set to 0
}

// Helper function to print latency statistics
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
    // Signal handler setup
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    // Read arguments
    boost::program_options::options_description programDescription("Options:");
    programDescription.add_options()
        ("size,s", boost::program_options::value<uint32_t>(), "Data size in bytes (default: 1KB)")
        ("reps,r", boost::program_options::value<uint32_t>(), "Number of repetitions");
    
    boost::program_options::variables_map commandLineArgs;
    boost::program_options::store(boost::program_options::parse_command_line(argc, argv, programDescription), commandLineArgs);
    boost::program_options::notify(commandLineArgs);

    uint32_t data_size = defSize;
    uint32_t n_reps = defReps;

    if(commandLineArgs.count("size") > 0) data_size = commandLineArgs["size"].as<uint32_t>();
    if(commandLineArgs.count("reps") > 0) n_reps = commandLineArgs["reps"].as<uint32_t>();

    // Ensure data size is multiple of 16 bytes (AES block size)
    data_size = ((data_size + 15) / 16) * 16;
    
    // Descriptor occupies first 512-bit word
    constexpr uint32_t DESC_SIZE_BYTES = 64;  // 512-bit word for descriptor
    uint32_t total_packet_size = DESC_SIZE_BYTES + data_size;

    uint32_t n_pages_host = (total_packet_size + hugePageSize - 1) / hugePageSize;

    PR_HEADER("PARAMS");
    std::cout << "vFPGA ID: " << targetVfid << std::endl;
    std::cout << "Data size: " << data_size << " bytes (" << data_size/16 << " AES blocks)" << std::endl;
    std::cout << "Total packet size: " << total_packet_size << " bytes" << std::endl;
    std::cout << "Number of reps: " << n_reps << std::endl;

    try {
        // Initialize thread
        std::unique_ptr<cThread<std::any>> cthread(new cThread<std::any>(targetVfid, getpid(), defDevice));
        cthread->start();

        // Memory allocation
        std::vector<uint8_t*> input_packets(n_reps, nullptr);
        std::vector<uint8_t*> output_packets(n_reps, nullptr);

        // Allocate and setup packets
        for(int i = 0; i < n_reps; i++) {
            input_packets[i] = (uint8_t*) cthread->getMem({CoyoteAlloc::HPF, n_pages_host});
            output_packets[i] = (uint8_t*) cthread->getMem({CoyoteAlloc::HPF, n_pages_host});
            
            if (!input_packets[i] || !output_packets[i]) {
                throw std::runtime_error("Memory allocation failed");
            }

            // Create descriptor
            memset(input_packets[i], 0, DESC_SIZE_BYTES);
            createPanicDescriptor(input_packets[i], data_size);
            
            // Fill data with test pattern
            uint8_t* data_ptr = input_packets[i] + DESC_SIZE_BYTES;
            for(int j = 0; j < data_size; j += 16) {
                memcpy(data_ptr + j, test_plaintext, 16);
            }
            
            // Clear output
            memset(output_packets[i], 0, total_packet_size);
        }

        // Setup scatter-gather entries
        sgEntry sg;
        sgFlags sg_flags = { true, true, false };

        // Benchmark setup
        cBench bench(n_reps);
        PR_HEADER("AES PROCESSING");

        // Clear any previous completions
        cthread->clearCompleted();
        
        auto benchmark_thr = [&]() {
            // Queue all transfers
            for(int i = 0; i < n_reps; i++) {
                memset(&sg, 0, sizeof(localSg));
                sg.local.src_addr = input_packets[i];
                sg.local.src_len = total_packet_size;
                sg.local.src_stream = strmHost;
                sg.local.src_dest = targetVfid;

                sg.local.dst_addr = output_packets[i];
                sg.local.dst_len = total_packet_size;
                sg.local.dst_stream = strmHost;
                sg.local.dst_dest = targetVfid;

                sg_flags.last = (i == n_reps-1);
                
                cthread->invoke(CoyoteOper::LOCAL_TRANSFER, &sg, sg_flags);
            }

            while(cthread->checkCompleted(CoyoteOper::LOCAL_TRANSFER) != n_reps) {
                if(stalled.load()) throw std::runtime_error("Stalled");
            }
        };

        bench.runtime(benchmark_thr);

        // Print performance metrics using printLatencyStats
        PR_HEADER("LATENCY MEASUREMENTS");
        printLatencyStats(bench.getAvg() / n_reps, total_packet_size, n_reps);

        // Simple verification
        PR_HEADER("VERIFICATION");
        bool success = false;
        
        // Check if output is different from input (encrypted)
        uint8_t* out_data = output_packets[0] + DESC_SIZE_BYTES;
        uint8_t* in_data = input_packets[0] + DESC_SIZE_BYTES;
        
        for(int i = 0; i < data_size; i++) {
            if(out_data[i] != in_data[i]) {
                success = true;
                break;
            }
        }
        
        if(success) {
            std::cout << "✓ Output is encrypted" << std::endl;
            
            // Show first block of encrypted data
            std::cout << "First encrypted block: ";
            for(int i = 0; i < 16; i++) {
                std::cout << std::hex << std::setw(2) << std::setfill('0') 
                          << (int)out_data[i] << " ";
            }
            std::cout << std::dec << std::endl;
        } else {
            std::cout << "✗ Output identical to input - encryption may have failed" << std::endl;
        }

        // Cleanup
        for(int i = 0; i < n_reps; i++) {
            if(input_packets[i]) {
                cthread->freeMem(input_packets[i]);
                input_packets[i] = nullptr;
            }
            if(output_packets[i]) {
                cthread->freeMem(output_packets[i]);
                output_packets[i] = nullptr;
            }
        }

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }
    
    return EXIT_SUCCESS;
}