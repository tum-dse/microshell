/**
 * SVM Classification 
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
#include <signal.h>
#ifdef EN_AVX
#include <x86intrin.h>
#endif
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
constexpr auto const defSize = 128;  // Default: 128 bytes (32 floats)
constexpr auto const maxPrintPackets = 3;  // Maximum packets to show in detail
constexpr auto const maxPrintOutputs = 5;  // Maximum output values to show in debug

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
        ("size,s", boost::program_options::value<uint32_t>(), "Total size in bytes (must be multiple of 128 bytes for 32 floats)")
        ("reps,r", boost::program_options::value<uint32_t>(), "Number of reps")
        ("verbose,v", "Enable verbose output");
    
    boost::program_options::variables_map commandLineArgs;
    boost::program_options::store(boost::program_options::parse_command_line(argc, argv, programDescription), 
                                commandLineArgs);
    boost::program_options::notify(commandLineArgs);

    uint32_t size_bytes = defSize;
    uint32_t n_reps = defReps;
    bool verbose = commandLineArgs.count("verbose") > 0;

    if(commandLineArgs.count("size") > 0) size_bytes = commandLineArgs["size"].as<uint32_t>();
    if(commandLineArgs.count("reps") > 0) n_reps = commandLineArgs["reps"].as<uint32_t>();

    // Ensure size is multiple of 128 bytes (32 floats * 4 bytes) for SVM requirement
    constexpr uint32_t min_chunk_bytes = 32 * sizeof(float);  // 128 bytes
    if(size_bytes % min_chunk_bytes != 0) {
        uint32_t adjusted_size = ((size_bytes + min_chunk_bytes - 1) / min_chunk_bytes) * min_chunk_bytes;
        std::cout << "Warning: Size must be multiple of " << min_chunk_bytes 
                  << " bytes (32 floats). Adjusting " << size_bytes 
                  << " to " << adjusted_size << " bytes" << std::endl;
        size_bytes = adjusted_size;
    }

    // Calculate derived values
    uint32_t num_floats = size_bytes / sizeof(float);
    uint32_t num_classifications = num_floats / 32;  // Number of expected classification results
    uint32_t buffer_size = size_bytes;  // Input buffer size in bytes
    uint32_t output_buffer_size = num_classifications * sizeof(float);  // One float per classification
    uint32_t n_pages_input = (buffer_size + hugePageSize - 1) / hugePageSize;
    uint32_t n_pages_output = (output_buffer_size + hugePageSize - 1) / hugePageSize;

    // Test data - known good SVM input that should produce a classification
    float test_data[32] = {
        36257662.0f, 70308074.0f, 162763557.0f, 109956489.0f, 86125933.0f,
        35535698.0f, 5473712.0f, 2191429.0f, 1655529.0f, 1427210.0f,
        1819290.0f, 2594503.0f, 2649694.0f, 849597.0f, 765175.0f,
        890647.0f, 1405332.0f, 1132804.0f, 5776375.0f, 18372118.0f,
        6724989.0f, 7313762.0f, 1469345.0f, 1744257.0f, 1631652.0f,
        823229.0f, 1018674.0f, 639273.0f, 601445.0f, 630083.0f,
        678854.0f, 636897.0f
    };

    PR_HEADER("PARAMS");
    std::cout << "vFPGA ID: " << targetVfid << std::endl;
    std::cout << "Input pages per run: " << n_pages_input << std::endl;
    std::cout << "Output pages per run: " << n_pages_output << std::endl;
    std::cout << "Total input size: " << size_bytes << " bytes (" << num_floats << " floats)" << std::endl;
    std::cout << "Number of 32-float sets: " << num_classifications << std::endl;
    std::cout << "Expected classifications: " << num_classifications << std::endl;
    std::cout << "Output buffer size: " << output_buffer_size << " bytes" << std::endl;
    std::cout << "Number of reps: " << n_reps << std::endl;
    if (!verbose) {
        std::cout << "Verbose mode: OFF (use -v for detailed output)" << std::endl;
    }

    try {
        // Initialize thread
        std::unique_ptr<cThread<std::any>> cthread(new cThread<std::any>(targetVfid, getpid(), defDevice));
        cthread->start();

        // Memory allocation
        std::vector<float*> input_data(n_reps, nullptr);
        std::vector<float*> output_data(n_reps, nullptr);

        // Allocate and fill memory
        for(int i = 0; i < n_reps; i++) {
            input_data[i] = (float*) cthread->getMem({CoyoteAlloc::HPF, n_pages_input});
            output_data[i] = (float*) cthread->getMem({CoyoteAlloc::HPF, n_pages_output});
            
            if (!input_data[i] || !output_data[i]) {
                throw std::runtime_error("Memory allocation failed");
            }

            // Fill input buffer with DIFFERENT test data for each packet
            for(int set = 0; set < num_classifications; set++) {
                for(int j = 0; j < 32; j++) {
                    // Send different data per packet by adding offset
                    input_data[i][set * 32 + j] = test_data[j] + (set * 1000.0f);
                }
            }

            // Clear output buffer
            memset(output_data[i], 0, output_buffer_size);
        }

        // Show limited input data samples
        if (num_classifications > 0) {
            std::cout << "\nInput data samples:\n";
            int packets_to_show = std::min((uint32_t)maxPrintPackets, num_classifications);
            
            for(int set = 0; set < packets_to_show; set++) {
                std::cout << "Packet " << (set + 1) << " (first 4 values): ";
                for(int j = 0; j < 4; j++) {
                    std::cout << std::fixed << std::setprecision(1) << (test_data[j] + (set * 1000.0f));
                    if(j < 3) std::cout << " ";
                }
                std::cout << " ... (+" << (set * 1000.0f) << " offset)\n";
            }
            
            if (num_classifications > maxPrintPackets) {
                std::cout << "... (" << (num_classifications - maxPrintPackets) 
                          << " more packets not shown)\n";
            }
            std::cout << "\n";
        }

        // Setup scatter-gather entries for transfer
        sgEntry sg;
        sgFlags sg_flags = { true, true, false };

        // Benchmark setup
        cBench bench(n_reps);
        PR_HEADER("SVM CLASSIFICATION");

        // Clear any previous completions
        cthread->clearCompleted();
        
        auto benchmark_thr = [&]() {
            // Queue all transfers
            for(int i = 0; i < n_reps; i++) {
                memset(&sg, 0, sizeof(localSg));
                sg.local.src_addr = input_data[i];
                sg.local.src_len = buffer_size; 
                sg.local.src_stream = strmHost;
                sg.local.src_dest = targetVfid;

                sg.local.dst_addr = output_data[i];
                sg.local.dst_len = output_buffer_size;  
                sg.local.dst_stream = strmHost;
                sg.local.dst_dest = targetVfid;
                
                sg_flags.last = (i == n_reps-1);

                cthread->invoke(CoyoteOper::LOCAL_TRANSFER, &sg, sg_flags);
            }

            // Wait for completion
            while(cthread->checkCompleted(CoyoteOper::LOCAL_TRANSFER) != n_reps) {
                if(stalled.load()) throw std::runtime_error("Stalled");
            }
        };

        bench.runtime(benchmark_thr);

        // Print performance metrics using printLatencyStats
        PR_HEADER("LATENCY MEASUREMENTS");
        printLatencyStats(bench.getAvg() / n_reps, buffer_size, n_reps);

        // Only show raw output buffer in verbose mode
        if (verbose) {
            PR_HEADER("RAW OUTPUT BUFFER DEBUG (First Rep)");
            if (n_reps > 0) {
                std::cout << "Buffer size: " << output_buffer_size << " bytes (" << (output_buffer_size/4) << " floats)\n";
                
                int outputs_to_show = std::min((uint32_t)maxPrintOutputs, (uint32_t)(output_buffer_size/4));
                for(int j = 0; j < outputs_to_show; j++) {
                    uint32_t bits = *(uint32_t*)&output_data[0][j];
                    std::cout << "  output[" << j << "] = " << output_data[0][j] 
                              << " (hex: 0x" << std::hex << bits << std::dec << ")\n";
                }
                
                if ((output_buffer_size/4) > maxPrintOutputs) {
                    std::cout << "  ... (" << ((output_buffer_size/4) - maxPrintOutputs) 
                              << " more values not shown)\n";
                }
                std::cout << std::endl;
            }
        }
        
        PR_HEADER("RESULTS SUMMARY");
        
        // Count classification results
        std::map<uint32_t, int> class_counts;
        std::map<uint32_t, std::string> class_names = {
            {0x3F800000, "Class 1"},
            {0x40000000, "Class 2"},
            {0x40400000, "Class 3"},
            {0x40800000, "Class 4"},
            {0x40A00000, "Class 5"}
        };
        
        for(int i = 0; i < n_reps; i++) {
            for(int j = 0; j < num_classifications; j++) {
                uint32_t result_bits = *(uint32_t*)&output_data[i][j];
                class_counts[result_bits]++;
            }
        }
        
        // Print summary
        std::cout << "Total classifications: " << (n_reps * num_classifications) << std::endl;
        std::cout << "\nClassification distribution:\n";
        for(const auto& [bits, count] : class_counts) {
            std::cout << "  ";
            if(class_names.find(bits) != class_names.end()) {
                std::cout << class_names[bits];
            } else {
                std::cout << "Unknown (0x" << std::hex << bits << std::dec << ")";
            }
            std::cout << ": " << count << " occurrences" << std::endl;
        }
        
        // Show first few detailed results only in verbose mode or if small dataset
        if (verbose || (n_reps * num_classifications <= 10)) {
            std::cout << "\nDetailed results (first few):\n";
            int max_detail = verbose ? n_reps : 1;
            
            for(int i = 0; i < std::min((uint32_t)max_detail, n_reps); i++) {
                std::cout << "Rep " << i << ":\n";
                int max_class = verbose ? num_classifications : std::min((uint32_t)3, num_classifications);
                
                for(int j = 0; j < max_class; j++) {
                    std::cout << "  Classification " << (j+1) << ": " << output_data[i][j];
                    
                    uint32_t result_bits = *(uint32_t*)&output_data[i][j];
                    if(class_names.find(result_bits) != class_names.end()) {
                        std::cout << " (" << class_names[result_bits] << ")";
                    } else {
                        std::cout << " (Unknown)";
                    }
                    std::cout << std::endl;
                }
                
                if (num_classifications > max_class) {
                    std::cout << "  ... (" << (num_classifications - max_class) 
                              << " more classifications not shown)\n";
                }
            }
        }
        
        // Print debug info
        if (verbose) {
            std::cout << std::endl;
            cthread->printDebug();
        }

        // Cleanup
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