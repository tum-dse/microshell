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

/* Default parameters */
constexpr auto const defDevice = 0;
constexpr auto const targetVfid = 0;  
constexpr auto const defReps = 1;
constexpr auto const defSize = 64 * 1024;  // 64KB default
constexpr auto const maxSize = 1024 * 1024;  // Max: 1MB

// AES-compatible test pattern (same as RLE test for consistency)
constexpr uint8_t test_plaintext[16] = {
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h',
    'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p'
};

// Generate AES-compatible pattern for secure pipeline
void generateSecurePipelinePattern(uint8_t* buffer, size_t size) {
    memset(buffer, 0, size);
    
    for (size_t chunk = 0; chunk < size / 64; chunk++) {
        size_t chunk_offset = chunk * 64;
        
        // Fill each 64-byte chunk with pattern that compresses to 'abcdefghijklmnop'
        for (int i = 0; i < 16; i++) {
            char target_char = test_plaintext[i];  // 'a' through 'p'
            
            // Repeat each character 4 times within the chunk
            for (int repeat = 0; repeat < 4; repeat++) {
                buffer[chunk_offset + i * 4 + repeat] = target_char;
            }
        }
    }
}

// Analyze secure pipeline output
void analyzeSecurePipelineOutput(uint8_t* buffer, size_t buffer_size, uint32_t input_chunks) {
    std::cout << "Secure Pipeline Output Analysis:" << std::endl;
    
    // Show raw hex output
    size_t hex_display_size = std::min(buffer_size, size_t(128));
    std::cout << "  Raw output (hex): ";
    for (size_t i = 0; i < hex_display_size; i++) {
        std::cout << std::hex << std::setw(2) << std::setfill('0') 
                  << static_cast<int>(buffer[i]) << " ";
        if ((i + 1) % 16 == 0) std::cout << std::endl << "                    ";
    }
    std::cout << std::dec << std::endl;
    
    // Check for encrypted data
    bool has_encrypted_data = false;
    size_t non_zero_bytes = 0;
    
    for (size_t i = 0; i < buffer_size; i++) {
        if (buffer[i] != 0) {
            has_encrypted_data = true;
            non_zero_bytes++;
        }
    }
    
    if (has_encrypted_data) {
        std::cout << " Encrypted data detected (" << non_zero_bytes << " non-zero bytes)" << std::endl;
    } else {
        std::cout << " No encrypted data - pipeline failed" << std::endl;
        return;
    }
    
    // Count valid encrypted blocks
    size_t valid_blocks = 0;
    for (size_t block_offset = 0; block_offset < buffer_size; block_offset += 64) {
        if (block_offset + 64 > buffer_size) break;
        
        bool block_has_data = false;
        for (int i = 0; i < 64; i++) {
            if (buffer[block_offset + i] != 0) {
                block_has_data = true;
                break;
            }
        }
        if (block_has_data) valid_blocks++;
    }
    
    std::cout << "  Encrypted blocks: " << valid_blocks << std::endl;

    // Pipeline analysis
    size_t expected_rle_compressed = input_chunks * 16;  // 16 bytes per input chunk after RLE
    size_t expected_aes_blocks = input_chunks;           // Should match RLE compression ratio
    
    std::cout << "  Pipeline stages:" << std::endl;
    std::cout << "    Input: " << input_chunks << " × 64 bytes = " << (input_chunks * 64) << " bytes" << std::endl;
    std::cout << "    After RLE: " << expected_rle_compressed << " bytes (4:1 compression)" << std::endl;
    std::cout << "    After AES: " << valid_blocks << " blocks (expected ~" << expected_aes_blocks << ")" << std::endl;
    
    // Validate pipeline efficiency
    double overall_efficiency = static_cast<double>(input_chunks * 64) / (valid_blocks * 64);
    std::cout << "  Overall efficiency: " << std::fixed << std::setprecision(1) << overall_efficiency << ":1" << std::endl;
    
    if (valid_blocks == expected_aes_blocks) {
        std::cout << " Pipeline working correctly!" << std::endl;
    } else {
        std::cout << " Pipeline efficiency issue (expected " << expected_aes_blocks 
                  << " blocks, got " << valid_blocks << ")" << std::endl;
    }
}

int main(int argc, char *argv[])  
{
    // Signal handler
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    // Parse arguments
    boost::program_options::options_description programDescription("Secure Pipeline Test:");
    programDescription.add_options()
        ("size,s", boost::program_options::value<uint32_t>(), "Data size in bytes (default: 64KB)")
        ("reps,r", boost::program_options::value<uint32_t>(), "Number of repetitions (default: 1)")
        ("help,h", "Show help message");
    
    boost::program_options::variables_map commandLineArgs;
    boost::program_options::store(boost::program_options::parse_command_line(argc, argv, programDescription), commandLineArgs);
    boost::program_options::notify(commandLineArgs);

    if(commandLineArgs.count("help")) {
        std::cout << programDescription << std::endl;
        return EXIT_SUCCESS;
    }

    uint32_t size = defSize;
    uint32_t n_reps = defReps;

    if(commandLineArgs.count("size") > 0) {
        size = commandLineArgs["size"].as<uint32_t>();
        if (size == 0 || size > maxSize) {
            std::cerr << "Error: Invalid size (max: " << maxSize << " bytes)" << std::endl;
            return EXIT_FAILURE;
        }
    }
    if(commandLineArgs.count("reps") > 0) n_reps = commandLineArgs["reps"].as<uint32_t>();

    // Ensure size is multiple of 64 bytes
    size = ((size + 63) / 64) * 64;
    uint32_t input_chunks = size / 64;
    uint32_t output_size = input_chunks * 16;  // 4:1 compression: 64 bytes → 16 bytes per chunk
    uint32_t n_pages_host = (size + hugePageSize - 1) / hugePageSize;

    PR_HEADER("RLE + AES SECURE PIPELINE TEST");
    std::cout << "Input size: " << size << " bytes (" << input_chunks << " chunks)" << std::endl;
    std::cout << "Expected output size: " << output_size << " bytes (4:1 compression)" << std::endl;
    std::cout << "Repetitions: " << n_reps << std::endl;
    std::cout << "Expected: RLE compression (4:1) + AES encryption" << std::endl;
    
    try {
        // Initialize FPGA
        std::unique_ptr<cThread<std::any>> cthread(new cThread<std::any>(targetVfid, getpid(), defDevice));

        // Allocate memory
        std::vector<uint8_t*> plaintext(n_reps, nullptr);
        std::vector<uint8_t*> ciphertext(n_reps, nullptr);

        for(int i = 0; i < n_reps; i++) {
            plaintext[i] = (uint8_t*) cthread->getMem({CoyoteAlloc::HPF, n_pages_host});
            ciphertext[i] = (uint8_t*) cthread->getMem({CoyoteAlloc::HPF, n_pages_host});
            
            if (!plaintext[i] || !ciphertext[i]) {
                throw std::runtime_error("Memory allocation failed");
            }

            // Clear output and generate input pattern
            memset(ciphertext[i], 0, size);
            generateSecurePipelinePattern(plaintext[i], size);
        }

        // Show input sample
        std::cout << "Input pattern: ";
        for(int i = 0; i < 64; i++) {
            std::cout << static_cast<char>(plaintext[0][i]);
        }
        std::cout << " (AES-compatible RLE pattern)" << std::endl;

        // Execute transfers
        cBench bench(n_reps);
        cthread->clearCompleted();

        auto benchmark_thr = [&]() {
            // Queue all transfers
            for(int i = 0; i < n_reps; i++) {
                sgEntry sg;
                memset(&sg, 0, sizeof(localSg));
                
                sg.local.src_addr = plaintext[i];
                sg.local.src_len = size;
                sg.local.src_stream = strmHost;
                sg.local.src_dest = targetVfid;

                sg.local.dst_addr = ciphertext[i];
                sg.local.dst_len = output_size;  // Use compressed size (1/4 of input)
                sg.local.dst_stream = strmHost;
                sg.local.dst_dest = targetVfid;

                sgFlags sg_flags = { true, true, (i == n_reps-1) };
                cthread->invoke(CoyoteOper::LOCAL_TRANSFER, &sg, sg_flags);
            }

            // Wait for completion
            while(cthread->checkCompleted(CoyoteOper::LOCAL_TRANSFER) != n_reps) {
                if(stalled.load()) throw std::runtime_error("Stalled, SIGINT caught");
                std::this_thread::sleep_for(std::chrono::milliseconds(10));
            }
        };

        bench.runtime(benchmark_thr);

        // Analyze results
        PR_HEADER("RESULTS");
        
        bool overall_success = true;
        for(int i = 0; i < n_reps; i++) {
            if (n_reps > 1) std::cout << "--- Repetition " << (i+1) << " ---" << std::endl;
            
            analyzeSecurePipelineOutput(ciphertext[i], output_size, input_chunks);
            
            // Basic validation
            bool has_output = false;
            for(int j = 0; j < output_size; j++) {  // Check compressed output size
                if(ciphertext[i][j] != 0) {
                    has_output = true;
                    break;
                }
            }
            
            if(!has_output) {
                std::cout << " No output for repetition " << (i+1) << std::endl;
                overall_success = false;
            }
        }
        
        // Summary
        std::cout << "\nPipeline Status: " << (overall_success ? "Working" : "Failed") << std::endl;
        
        // Performance
        double total_throughput = (1000.0 * size * n_reps) / bench.getAvg();
        std::cout << "Performance: " << bench.getAvg() << " us, " 
                  << std::fixed << std::setprecision(2) << total_throughput << " MB/s" << std::endl;

        // Cleanup
        for(int i = 0; i < n_reps; i++) {
            if(plaintext[i]) cthread->freeMem(plaintext[i]);
            if(ciphertext[i]) cthread->freeMem(ciphertext[i]);
        }

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }
    
    return EXIT_SUCCESS;
}