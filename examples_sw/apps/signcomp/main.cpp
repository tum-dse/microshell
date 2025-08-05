/**
 * Signed Compression Pipeline
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
constexpr auto const defSize = 64;     // Default: 64 bytes (RLE input)
constexpr auto const maxSize = 1024 * 1024;  // Max: 1MB
constexpr auto const RSA_OUTPUT_SIZE = 32;  // 256-bit RSA output (in bytes)
constexpr auto const defHuge = true;   
constexpr auto const defMapped = true; 
constexpr auto const defStream = 1;    

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

// Generate TRUE 4:1 compression pattern for RLE input
void generateStreamingRLEPattern(uint8_t* buffer, size_t size) {
    memset(buffer, 0, size);
    
    // Pattern: Each character repeated 4 times for true 4:1 compression
    // 64 bytes input: AAAABBBBCCCCDDDDEEEEFFFFGGGGHHHHIIIIJJJJKKKKLLLLMMMMNNNNOOOOPPPP
    // 16 bytes compressed: ABCDEFGHIJKLMNOP (true 4:1 compression!)
    
    for (size_t pos = 0; pos < size; pos++) {
        // Each character appears 4 times in sequence, cycling through A-P (16 chars)
        char base_char = 'A' + ((pos / 4) % 16);  // A-P, each repeated 4 times
        buffer[pos] = base_char;
    }
    
}

// Helper function to print buffer contents
void printBuffer(uint8_t* buffer, size_t size, const char* label) {
    std::cout << label << ": ";
    for(size_t i = 0; i < std::min(size, size_t(64)); i++) {
        std::cout << static_cast<char>(buffer[i]);
        if ((i + 1) % 16 == 0) std::cout << std::endl << "               ";
    }
    std::cout << std::endl;
}

// Helper function to print hex values for RSA output
void printHexBuffer(uint32_t* buffer, size_t words, const char* label) {
    std::cout << label << ": 0x";
    for(int i = words-1; i >= 0; i--) {
        std::cout << std::hex << std::setw(8) << std::setfill('0') << buffer[i];
    }
    std::cout << std::dec << std::endl;
}

// Analyze the pipeline output (RSA encrypted result)
void analyzePipelineOutput(uint8_t* buffer, size_t buffer_size, uint32_t input_chunks) {
    std::cout << "Secure Storage Output Analysis:" << std::endl;
    
    // Print raw hex data
    std::cout << "  Raw RSA output (hex, " << buffer_size << " bytes):" << std::endl << "  ";
    for (size_t i = 0; i < buffer_size; i++) {
        std::cout << std::hex << std::setw(2) << std::setfill('0') 
                  << static_cast<int>(buffer[i]) << " ";
        if ((i + 1) % 16 == 0) std::cout << std::endl << "  ";
    }
    std::cout << std::dec << std::endl;
    
    // Check for valid RSA output (non-zero data)
    bool has_valid_output = false;
    for (size_t i = 0; i < buffer_size; i++) {
        if (buffer[i] != 0) {
            has_valid_output = true;
            break;
        }
    }

}

int main(int argc, char *argv[]) {
    // Signal handler setup
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    // Read arguments
    boost::program_options::options_description programDescription("Options:");
    programDescription.add_options()
        ("size,s", boost::program_options::value<uint32_t>(), "RLE input size in bytes (default: 64, max: 1MB)")
        ("custom,c", "Use custom input pattern instead of default RLE pattern")
        ("hugepages,h", boost::program_options::value<bool>(), "Use hugepages (default: true)")
        ("mapped,m", boost::program_options::value<bool>(), "Use mapped memory (default: true)")
        ("stream,t", boost::program_options::value<bool>(), "Use streaming interface (default: true)")
        ("help", "Show help message");
    
    boost::program_options::variables_map commandLineArgs;
    boost::program_options::store(boost::program_options::parse_command_line(argc, argv, programDescription), 
                                commandLineArgs);
    boost::program_options::notify(commandLineArgs);

    if(commandLineArgs.count("help")) {
        std::cout << programDescription << std::endl;
        return EXIT_SUCCESS;
    }

    // Get parameters
    uint32_t input_size = defSize;
    bool huge = defHuge;
    bool mapped = defMapped;
    bool stream = defStream;
    
    if(commandLineArgs.count("size") > 0) {
        input_size = commandLineArgs["size"].as<uint32_t>();
        
        // Validate input size
        if (input_size == 0) {
            std::cerr << "Error: Size must be greater than 0" << std::endl;
            return EXIT_FAILURE;
        }
        if (input_size > maxSize) {
            std::cerr << "Error: Size too large (max: " << maxSize << " bytes)" << std::endl;
            return EXIT_FAILURE;
        }
    }
    
    if(commandLineArgs.count("hugepages") > 0) huge = commandLineArgs["hugepages"].as<bool>();
    if(commandLineArgs.count("mapped") > 0) mapped = commandLineArgs["mapped"].as<bool>();
    if(commandLineArgs.count("stream") > 0) stream = commandLineArgs["stream"].as<bool>();
    
    // Calculate sizes for pipeline
    uint32_t input_chunks = (input_size + 63) / 64;  // Number of 64-byte input chunks for RLE
    uint32_t expected_rle_compressed = input_chunks * 16;  // Expected RLE output (4:1 compression)
    uint32_t output_size = RSA_OUTPUT_SIZE;  // Final RSA output is always 32 bytes (256-bit)

    PR_HEADER("SECURE STORAGE (RLE + RSA)");
    std::cout << "Pipeline: RLE Compression → RSA Encryption" << std::endl;
    std::cout << "RLE input size: " << input_size << " bytes";
    if (input_size >= 1024) {
        std::cout << " (" << std::fixed << std::setprecision(1) << (input_size / 1024.0) << " KB)";
    }
    std::cout << std::endl;
    std::cout << "Input chunks: " << input_chunks << " (64-byte chunks)" << std::endl;
    std::cout << "Expected RLE compressed: " << expected_rle_compressed << " bytes (4:1 ratio)" << std::endl;
    std::cout << "Final RSA output: " << output_size << " bytes (256-bit encrypted)" << std::endl;
    std::cout << "Pattern: " << (commandLineArgs.count("custom") ? "Custom" : "True 4:1 RLE (AAAABBBB...PPPP)") << std::endl;
    std::cout << "Hugepages: " << huge << std::endl;
    std::cout << "Mapped: " << mapped << std::endl;
    std::cout << "Streaming: " << (stream ? "HOST" : "CARD") << std::endl;
    
    try {
        // Initialize FPGA
        std::unique_ptr<cThread<std::any>> cthread(new cThread<std::any>(targetVfid, getpid(), defDevice));

        // Memory allocation
        void* inputData;
        void* outputData;
        
        if (mapped) {
            // Use Coyote managed memory
            inputData = cthread->getMem({huge ? CoyoteAlloc::HPF : CoyoteAlloc::REG, 
                                        std::max(input_size, static_cast<uint32_t>(hugePageSize))});
            outputData = cthread->getMem({huge ? CoyoteAlloc::HPF : CoyoteAlloc::REG, 
                                         std::max(output_size, static_cast<uint32_t>(hugePageSize))});
        } else {
            // Use manual allocation
            if (huge) {
                inputData = mmap(NULL, std::max(input_size, static_cast<uint32_t>(hugePageSize)), 
                               PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);
                outputData = mmap(NULL, std::max(output_size, static_cast<uint32_t>(hugePageSize)), 
                                PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);
            } else {
                inputData = malloc(input_size);
                outputData = malloc(output_size);
            }
        }
            
        if (!inputData || !outputData) {
            throw std::runtime_error("Memory allocation failed");
        }

        // Clear output buffer
        memset(outputData, 0, output_size);
        
        // Generate RLE input pattern
        if (!commandLineArgs.count("custom")) {
            generateStreamingRLEPattern((uint8_t*)inputData, input_size);
        } else {
            // Fill with custom pattern
            std::cout << "Generating custom alternating pattern..." << std::endl;
            for (uint32_t i = 0; i < input_size; i++) {
                ((uint8_t*)inputData)[i] = 'A' + (i % 26);
            }
        }

        // Print the input pattern (show first and last parts for large inputs)
        if (input_size <= 256) {
            printBuffer((uint8_t*)inputData, input_size, "RLE Input");
        } else {
            std::cout << "RLE Input (first 64 bytes): ";
            for(size_t i = 0; i < 64; i++) {
                std::cout << static_cast<char>(((uint8_t*)inputData)[i]);
                if ((i + 1) % 16 == 0) std::cout << std::endl << "                            ";
            }
            std::cout << std::endl;
            
            std::cout << "RLE Input (last 64 bytes):  ";
            for(size_t i = input_size - 64; i < input_size; i++) {
                std::cout << static_cast<char>(((uint8_t*)inputData)[i]);
                if ((i - (input_size - 64) + 1) % 16 == 0) std::cout << std::endl << "                            ";
            }
            std::cout << std::endl;
        }

        // Configure single pipeline transfer
        sgEntry sg;
        memset(&sg, 0, sizeof(localSg));
        
        // Configure SG entry for pipeline (RLE → RSA)
        sg.local.src_addr = inputData;
        sg.local.src_len = input_size;
        sg.local.src_stream = stream;
        
        sg.local.dst_addr = outputData;
        sg.local.dst_len = output_size;
        sg.local.dst_stream = stream;
        
        cBench bench(1);
        cthread->clearCompleted();

        auto benchmark_thr = [&]() {
            // Single pipeline transfer (RLE + RSA)
            cthread->invoke(CoyoteOper::LOCAL_TRANSFER, &sg, {true, true, false});

            // Wait for pipeline completion
            auto start_time = std::chrono::high_resolution_clock::now();
            while(cthread->checkCompleted(CoyoteOper::LOCAL_TRANSFER) != 1) {
                if(stalled.load()) throw std::runtime_error("Stalled, SIGINT caught");
                
                auto current_time = std::chrono::high_resolution_clock::now();
                auto elapsed = std::chrono::duration_cast<std::chrono::seconds>(current_time - start_time).count();
                
                if (elapsed > 30) {
                    throw std::runtime_error("Pipeline timeout after 30 seconds");
                }
            }
        };

        bench.runtime(benchmark_thr);

        // Print results
        PR_HEADER("RESULTS");
        
        // Display the RSA encrypted output
        printHexBuffer((uint32_t*)outputData, output_size/4, "RSA Output");
        
        // Analyze the pipeline output
        analyzePipelineOutput((uint8_t*)outputData, output_size, input_chunks);
        
        // Print performance metrics using printLatencyStats
        PR_HEADER("LATENCY MEASUREMENTS");
        printLatencyStats(bench.getAvg(), input_size, 1);
        
        // Calculate overall compression + encryption metrics
        double space_efficiency = static_cast<double>(input_size) / output_size;
        std::cout << "\nSpace efficiency: " << std::fixed << std::setprecision(1) 
                  << space_efficiency << ":1 (input:output ratio)" << std::endl;

        
        // Debug print
        cthread->printDebug();
        
        // Cleanup
        if (mapped) {
            cthread->freeMem(inputData);
            cthread->freeMem(outputData);
        } else {
            if (huge) {
                munmap(inputData, std::max(input_size, static_cast<uint32_t>(hugePageSize)));
                munmap(outputData, std::max(output_size, static_cast<uint32_t>(hugePageSize)));
            } else {
                free(inputData);
                free(outputData);
            }
        }

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }
    
    return EXIT_SUCCESS;
}