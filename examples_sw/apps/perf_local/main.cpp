/**
 * Copyright (c) 2021, Systems Group, ETH Zurich
 * All rights reserved.
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

#define EN_THR_TESTS
#define EN_LAT_TESTS

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
constexpr auto const nRegions = 1;
constexpr auto const defHuge = true;
constexpr auto const defMappped = true;
constexpr auto const defStream = 1;
constexpr auto const nRepsThr = 1;
constexpr auto const nRepsLat = 1;
constexpr auto const defMinSize = 64;
constexpr auto const defMaxSize = 1 * 1024 * 1024;
constexpr auto const nBenchRuns = 1;
constexpr auto const SINGLE_TEST_SIZE = 64;

// Simple helper function - just check completion with timeout
bool wait_for_completion(cThread<std::any>* cthread, CoyoteOper operation, int timeout_ms = 2000) {
    int attempts = timeout_ms / 100;
    for(int i = 0; i < attempts; i++) {
        uint32_t completions = 0;
        switch(operation) {
            case CoyoteOper::LOCAL_READ:
                completions = cthread->checkCompleted(CoyoteOper::LOCAL_READ);
                break;
            case CoyoteOper::LOCAL_WRITE:
            case CoyoteOper::LOCAL_TRANSFER:
                completions = cthread->checkCompleted(CoyoteOper::LOCAL_WRITE);
                break;
            default:
                completions = cthread->checkCompleted(operation);
                break;
        }
        if(completions > 0) return true;
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }
    return false;
}

/**
 * @brief Validation tests with Memory Gateway
 */
int main(int argc, char *argv[])
{
    // ---------------------------------------------------------------
    // Args
    // ---------------------------------------------------------------

    // Sig handler
    struct sigaction sa;
    memset( &sa, 0, sizeof(sa) );
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT,&sa,NULL);

    // Read arguments
    boost::program_options::options_description programDescription("Options:");
    programDescription.add_options()
        ("bitstream,b", boost::program_options::value<string>(), "Shell bitstream")
        ("device,d", boost::program_options::value<uint32_t>(), "Target device")
        ("regions,g", boost::program_options::value<uint32_t>(), "Number of vFPGAs")
        ("hugepages,h", boost::program_options::value<bool>(), "Hugepages")
        ("mapped,m", boost::program_options::value<bool>(), "Mapped / page fault")
        ("stream,t", boost::program_options::value<bool>(), "Streaming interface")
        ("repst,r", boost::program_options::value<uint32_t>(), "Number of repetitions (throughput)")
        ("repsl,l", boost::program_options::value<uint32_t>(), "Number of repetitions (latency)")
        ("test_size,s", boost::program_options::value<uint32_t>(), "Single test size (default: 64 bytes)");

    boost::program_options::variables_map commandLineArgs;
    boost::program_options::store(boost::program_options::parse_command_line(argc, argv, programDescription), commandLineArgs);
    boost::program_options::notify(commandLineArgs);

    string bstream_path = "";
    uint32_t cs_dev = defDevice;
    uint32_t n_regions = nRegions;
    bool huge = defHuge;
    bool mapped = defMappped;
    bool stream = defStream;
    uint32_t n_reps_thr = nRepsThr;
    uint32_t n_reps_lat = nRepsLat;
    uint32_t max_size = defMaxSize;
    uint32_t single_test_size = SINGLE_TEST_SIZE;

    if(commandLineArgs.count("bitstream") > 0) {
        bstream_path = commandLineArgs["bitstream"].as<string>();
        
        std::cout << std::endl << "Shell loading (path: " << bstream_path << ") ..." << std::endl;
        cRnfg crnfg(cs_dev);
        crnfg.shellReconfigure(bstream_path);
    }
    if(commandLineArgs.count("device") > 0) cs_dev = commandLineArgs["device"].as<uint32_t>();
    if(commandLineArgs.count("regions") > 0) n_regions = commandLineArgs["regions"].as<uint32_t>();
    if(commandLineArgs.count("hugepages") > 0) huge = commandLineArgs["hugepages"].as<bool>();
    if(commandLineArgs.count("mapped") > 0) mapped = commandLineArgs["mapped"].as<bool>();
    if(commandLineArgs.count("stream") > 0) stream = commandLineArgs["stream"].as<bool>();
    if(commandLineArgs.count("repst") > 0) n_reps_thr = commandLineArgs["repst"].as<uint32_t>();
    if(commandLineArgs.count("repsl") > 0) n_reps_lat = commandLineArgs["repsl"].as<uint32_t>();
    if(commandLineArgs.count("test_size") > 0) single_test_size = commandLineArgs["test_size"].as<uint32_t>();

    PR_HEADER("PARAMS");
    std::cout << "Number of regions: " << n_regions << std::endl;
    std::cout << "Hugepages: " << huge << std::endl;
    std::cout << "Mapped pages: " << mapped << std::endl;
    std::cout << "Streaming: " << (stream ? "HOST" : "CARD") << std::endl;
    std::cout << "Number of repetitions (thr): " << n_reps_thr << std::endl;
    std::cout << "Number of repetitions (lat): " << n_reps_lat << std::endl;
    std::cout << "Single test size: " << single_test_size << " bytes" << std::endl << std::endl;

    // ---------------------------------------------------------------
    // Init
    // ---------------------------------------------------------------

    // Handles
    std::vector<std::unique_ptr<cThread<std::any>>> cthread;
    void* hMem[n_regions];
    bool endpoints_configured = false;

    // Obtain resources
    for (int i = 0; i < n_regions; i++) {
        cthread.emplace_back(new cThread<std::any>(i, getpid(), cs_dev));
        hMem[i] = mapped ? (cthread[i]->getMem({huge ? CoyoteAlloc::HPF : CoyoteAlloc::REG, max_size}))
                         : (huge ? (mmap(NULL, max_size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0))
                                 : (malloc(max_size)));

        std::cout << "Region " << i << " memory allocated at: 0x" << std::hex << hMem[i] << std::dec << std::endl;
    }

    sgEntry sg[n_regions];

    for(int i = 0; i < n_regions; i++) {
        // SG entries - initialize with single test size
        memset(&sg[i], 0, sizeof(localSg));
        sg[i].local.src_addr = hMem[i];
        sg[i].local.src_len = single_test_size;
        sg[i].local.src_stream = stream;
        sg[i].local.dst_addr = hMem[i];
        sg[i].local.dst_len = single_test_size;
        sg[i].local.dst_stream = stream;
    }

    // ---------------------------------------------------------------
    // Configure Memory Endpoints
    // ---------------------------------------------------------------

    PR_HEADER("CONFIGURING MEMORY ENDPOINTS");
    std::cout << "Configuring endpoints for memory access control..." << std::endl;

    // Configure endpoints for each region
    for (int i = 0; i < n_regions; i++) {
        // Calculate virtual address range for this endpoint
        uint64_t vaddr_base = reinterpret_cast<uint64_t>(hMem[i]);
        uint64_t vaddr_bound = vaddr_base + max_size - 1;

        // Create endpoint configuration
        epConfig config(vaddr_base, vaddr_bound, EP_ACCESS_RW, true);

        std::cout << "Region " << i << " endpoint configuration:" << std::endl;
        std::cout << "  Base address:  0x" << std::hex << vaddr_base << std::dec << std::endl;
        std::cout << "  Bound address: 0x" << std::hex << vaddr_bound << std::dec << std::endl;
        std::cout << "  Access rights: " << (config.access_rights & EP_ACCESS_READ ? "R" : "-")
                  << (config.access_rights & EP_ACCESS_WRITE ? "W" : "-") << std::endl;

        try {
            // CORRECTED: Each region uses endpoint 0 for itself
            uint32_t ep_index = 0;  
            
            // Configure the endpoint
            cthread[i]->epConfigure(ep_index, config);

            // Add small delay to ensure hardware configuration is complete
            std::this_thread::sleep_for(std::chrono::milliseconds(10));

            // Verify endpoint configuration by reading back from hardware
            epConfig readback_config = cthread[i]->epGetConfig(ep_index);

            std::cout << "  Hardware readback values:" << std::endl;
            std::cout << "    Base:   0x" << std::hex << readback_config.base_addr << std::dec << std::endl;
            std::cout << "    Bound:  0x" << std::hex << readback_config.bound_addr << std::dec << std::endl;
            std::cout << "    Access: 0x" << std::hex << (uint32_t)readback_config.access_rights << std::dec << std::endl;
            std::cout << "    Valid:  " << readback_config.valid << std::endl;

            // Check if the configuration was successful
            bool config_ok = (readback_config.base_addr == vaddr_base) &&
                             (readback_config.bound_addr == vaddr_bound) &&
                             (readback_config.access_rights == EP_ACCESS_RW) &&
                             (readback_config.valid == true);

            if (config_ok) {
                std::cout << "  ✓ Configuration verified in hardware!" << std::endl;
                endpoints_configured = true;
            } else {
                std::cout << "  ✗ Hardware verification failed!" << std::endl;
                
                // Debug output for mismatch
                if (readback_config.base_addr != vaddr_base) {
                    std::cout << "    Base address mismatch: expected 0x" << std::hex << vaddr_base 
                              << ", got 0x" << readback_config.base_addr << std::dec << std::endl;
                }
                if (readback_config.bound_addr != vaddr_bound) {
                    std::cout << "    Bound address mismatch: expected 0x" << std::hex << vaddr_bound 
                              << ", got 0x" << readback_config.bound_addr << std::dec << std::endl;
                }
                if (readback_config.access_rights != EP_ACCESS_RW) {
                    std::cout << "    Access rights mismatch: expected " << EP_ACCESS_RW 
                              << ", got " << (uint32_t)readback_config.access_rights << std::endl;
                }
                if (!readback_config.valid) {
                    std::cout << "    Valid bit not set" << std::endl;
                }
            }
        } catch (const std::exception& e) {
            std::cout << "  ERROR: Failed to configure endpoint " << i << ": " << e.what() << std::endl;
        }
    }

    // ---------------------------------------------------------------
    // Memory Pattern Test with Completion Checking
    // ---------------------------------------------------------------

    PR_HEADER("MEMORY PATTERN TEST WITH COMPLETION");
    std::cout << "Writing and verifying test pattern with completion checking..." << std::endl;

    // Write test pattern
    for (int i = 0; i < n_regions; i++) {
        for (int j = 0; j < 16; j++) {
            ((uint32_t *)hMem[i])[j] = 0xA0000000 + (i << 16) + j;
        }
    }

    // Force memory sync with completion checking
    for (int i = 0; i < n_regions; i++) {
        cthread[i]->clearCompleted();
        cthread[i]->invoke(CoyoteOper::LOCAL_TRANSFER, &sg[i], {true, false, false});
        
        if (wait_for_completion(cthread[i].get(), CoyoteOper::LOCAL_TRANSFER)) {
            std::cout << "Region " << i << " memory sync completed successfully." << std::endl;
        } else {
            std::cout << "Region " << i << " memory sync TIMED OUT - may be blocked!" << std::endl;
        }
    }

    // Verify pattern
    std::cout << "\nVerifying memory test pattern..." << std::endl;
    for (int i = 0; i < n_regions; i++) {
        std::cout << "Region " << i << " memory verification:" << std::endl;
        bool pattern_ok = true;

        for (int j = 0; j < 16; j++) {
            uint32_t expected = 0xA0000000 + (i << 16) + j;
            uint32_t actual = ((uint32_t *)hMem[i])[j];

            if (actual == expected) {
                std::cout << "  [" << std::setw(2) << j << "]: 0x" << std::hex << actual << std::dec << " ✓" << std::endl;
            } else {
                std::cout << "  [" << std::setw(2) << j << "]: 0x" << std::hex << actual
                          << " ✗ (Expected: 0x" << expected << ")" << std::dec << std::endl;
                pattern_ok = false;
            }
        }

        if(pattern_ok) {
            std::cout << "  ✓ Region " << i << " pattern verification PASSED" << std::endl;
        } else {
            std::cout << "  ✗ Region " << i << " pattern verification FAILED" << std::endl;
        }
    }

    // ---------------------------------------------------------------
    // Endpoint Access Control Test with Completion Checking
    // ---------------------------------------------------------------

    PR_HEADER("ENDPOINT ACCESS CONTROL TEST WITH COMPLETION");
    std::cout << "Testing endpoint access control with proper completion checking..." << std::endl;

    int passed_tests = 0;
    int total_tests = 0;

    for (int i = 0; i < std::min(1, (int)n_regions); i++) {
        std::cout << "\nTesting endpoint access control for region " << i << ":" << std::endl;

        uint64_t base_addr = reinterpret_cast<uint64_t>(hMem[i]);
        uint64_t bound_addr = base_addr + max_size - 1;
        uint32_t ep_index = 0;  // Use endpoint 0 for each region

        // Test 1: Normal read-write access (should succeed)
        epConfig rw_config(base_addr, bound_addr, EP_ACCESS_RW, true);
        cthread[i]->epConfigure(ep_index, rw_config);
        std::this_thread::sleep_for(std::chrono::milliseconds(10)); // Allow config to propagate

        // Test read operation
        cthread[i]->clearCompleted();
        cthread[i]->invoke(CoyoteOper::LOCAL_READ, &sg[i], {true, false, false});
        total_tests++;
        if (wait_for_completion(cthread[i].get(), CoyoteOper::LOCAL_READ)) {
            std::cout << "  ✓ Read-write access (read operation) - PASSED" << std::endl;
            passed_tests++;
        } else {
            std::cout << "  ✗ Read-write access (read operation) - FAILED (timed out)" << std::endl;
        }

        // Test write operation
        cthread[i]->clearCompleted();
        cthread[i]->invoke(CoyoteOper::LOCAL_WRITE, &sg[i], {true, false, false});
        total_tests++;
        if (wait_for_completion(cthread[i].get(), CoyoteOper::LOCAL_WRITE)) {
            std::cout << "  ✓ Read-write access (write operation) - PASSED" << std::endl;
            passed_tests++;
        } else {
            std::cout << "  ✗ Read-write access (write operation) - FAILED (timed out)" << std::endl;
        }

        // Test 2: Configure as read-only
        epConfig ro_config(base_addr, bound_addr, EP_ACCESS_READ, true);
        cthread[i]->epConfigure(ep_index, ro_config);
        std::this_thread::sleep_for(std::chrono::milliseconds(10));
        std::cout << "  Configured endpoint as READ-ONLY" << std::endl;

        // Test read (should succeed)
        cthread[i]->clearCompleted();
        cthread[i]->invoke(CoyoteOper::LOCAL_READ, &sg[i], {true, false, false});
        total_tests++;
        if (wait_for_completion(cthread[i].get(), CoyoteOper::LOCAL_READ)) {
            std::cout << "  ✓ Read-only access (read operation) - PASSED" << std::endl;
            passed_tests++;
        } else {
            std::cout << "  ✗ Read-only access (read operation) - FAILED (incorrectly blocked)" << std::endl;
        }

        // Test write (should be blocked)
        cthread[i]->clearCompleted();
        cthread[i]->invoke(CoyoteOper::LOCAL_WRITE, &sg[i], {true, false, false});
        total_tests++;
        if (!wait_for_completion(cthread[i].get(), CoyoteOper::LOCAL_WRITE)) {
            std::cout << "  ✓ Read-only access (write operation) - PASSED (correctly blocked)" << std::endl;
            passed_tests++;
        } else {
            std::cout << "  ✗ Read-only access (write operation) - FAILED (should have been blocked)" << std::endl;
        }

        // Test 3: Configure as write-only
        epConfig wo_config(base_addr, bound_addr, EP_ACCESS_WRITE, true);
        cthread[i]->epConfigure(ep_index, wo_config);
        std::this_thread::sleep_for(std::chrono::milliseconds(10));
        std::cout << "  Configured endpoint as WRITE-ONLY" << std::endl;

        // Test read (should be blocked)
        cthread[i]->clearCompleted();
        cthread[i]->invoke(CoyoteOper::LOCAL_READ, &sg[i], {true, false, false});
        total_tests++;
        if (!wait_for_completion(cthread[i].get(), CoyoteOper::LOCAL_READ)) {
            std::cout << "  ✓ Write-only access (read operation) - PASSED (correctly blocked)" << std::endl;
            passed_tests++;
        } else {
            std::cout << "  ✗ Write-only access (read operation) - FAILED (should have been blocked)" << std::endl;
        }

        // Test write (should succeed)
        cthread[i]->clearCompleted();
        cthread[i]->invoke(CoyoteOper::LOCAL_WRITE, &sg[i], {true, false, false});
        total_tests++;
        if (wait_for_completion(cthread[i].get(), CoyoteOper::LOCAL_WRITE)) {
            std::cout << "  ✓ Write-only access (write operation) - PASSED" << std::endl;
            passed_tests++;
        } else {
            std::cout << "  ✗ Write-only access (write operation) - FAILED (incorrectly blocked)" << std::endl;
        }

        // Test 4: Disable endpoint
        cthread[i]->epSetValid(ep_index, false);
        std::this_thread::sleep_for(std::chrono::milliseconds(10));
        std::cout << "  Disabled endpoint" << std::endl;

        // Test read (should be blocked)
        cthread[i]->clearCompleted();
        cthread[i]->invoke(CoyoteOper::LOCAL_READ, &sg[i], {true, false, false});
        total_tests++;
        if (!wait_for_completion(cthread[i].get(), CoyoteOper::LOCAL_READ)) {
            std::cout << "  ✓ Disabled endpoint (read operation) - PASSED (correctly blocked)" << std::endl;
            passed_tests++;
        } else {
            std::cout << "  ✗ Disabled endpoint (read operation) - FAILED (should have been blocked)" << std::endl;
        }

        // Test write (should be blocked)
        cthread[i]->clearCompleted();
        cthread[i]->invoke(CoyoteOper::LOCAL_WRITE, &sg[i], {true, false, false});
        total_tests++;
        if (!wait_for_completion(cthread[i].get(), CoyoteOper::LOCAL_WRITE)) {
            std::cout << "  ✓ Disabled endpoint (write operation) - PASSED (correctly blocked)" << std::endl;
            passed_tests++;
        } else {
            std::cout << "  ✗ Disabled endpoint (write operation) - FAILED (should have been blocked)" << std::endl;
        }

        // Test 5: Out-of-bounds access
        // Re-enable endpoint with limited range
        epConfig limited_config(base_addr, base_addr + 1023, EP_ACCESS_RW, true); // Only first 1KB
        cthread[i]->epConfigure(ep_index, limited_config);
        std::this_thread::sleep_for(std::chrono::milliseconds(10));

        // Modify sg to access beyond the limited range
        sgEntry oob_sg = sg[i];
        oob_sg.local.src_addr = reinterpret_cast<void*>(base_addr + 2048); // Beyond 1KB limit
        oob_sg.local.dst_addr = reinterpret_cast<void*>(base_addr + 2048);

        cthread[i]->clearCompleted();
        cthread[i]->invoke(CoyoteOper::LOCAL_READ, &oob_sg, {true, false, false});
        total_tests++;
        if (!wait_for_completion(cthread[i].get(), CoyoteOper::LOCAL_READ)) {
            std::cout << "  ✓ Out-of-bounds access - PASSED (correctly blocked)" << std::endl;
            passed_tests++;
        } else {
            std::cout << "  ✗ Out-of-bounds access - FAILED (should have been blocked)" << std::endl;
        }

        // Restore full access for cleanup
        epConfig restore_config(base_addr, bound_addr, EP_ACCESS_RW, true);
        cthread[i]->epConfigure(ep_index, restore_config);
        std::this_thread::sleep_for(std::chrono::milliseconds(10));
    }

    std::cout << "\n========================================" << std::endl;
    std::cout << "ACCESS CONTROL TEST SUMMARY:" << std::endl;
    std::cout << "Passed: " << passed_tests << "/" << total_tests << " tests" << std::endl;
    if(passed_tests == total_tests) {
        std::cout << "✓ ALL TESTS PASSED - Memory Gateway working correctly!" << std::endl;
    } else {
        std::cout << "✗ " << (total_tests - passed_tests) << " TESTS FAILED - Memory Gateway issues detected!" << std::endl;
    }
    std::cout << "========================================" << std::endl;

    // ---------------------------------------------------------------
    // Performance Test
    // ---------------------------------------------------------------
    cBench bench(nBenchRuns);

    PR_HEADER("SIMPLIFIED PERF HOST TEST - SINGLE SIZE");

    // Test single transfer first
    std::cout << "Testing single " << single_test_size << "-byte transfer with endpoint validation..." << std::endl;

    // Validate memory addresses against configured endpoints
    for(int i = 0; i < n_regions; i++) {
        uint64_t test_addr = reinterpret_cast<uint64_t>(hMem[i]);
        uint64_t test_end = test_addr + single_test_size - 1;

        if (endpoints_configured) {
            try {
                uint32_t ep_index = 0;  // Use endpoint 0 for each region
                epConfig current_ep = cthread[i]->epGetConfig(ep_index);

                std::cout << "Region " << i << " address validation:" << std::endl;
                std::cout << "  Test range: 0x" << std::hex << test_addr << " - 0x" << test_end << std::dec << std::endl;
                std::cout << "  EP range:   0x" << std::hex << current_ep.base_addr << " - 0x" << current_ep.bound_addr << std::dec << std::endl;

                if (!current_ep.valid) {
                    std::cout << "  WARNING: Endpoint not valid!" << std::endl;
                } else if (test_addr < current_ep.base_addr || test_end > current_ep.bound_addr) {
                    std::cout << "  ERROR: Address range outside configured endpoint!" << std::endl;
                } else {
                    std::cout << "  ✓ Address range within configured endpoint" << std::endl;
                }
            } catch (const std::exception& e) {
                std::cout << "  ERROR reading endpoint config: " << e.what() << std::endl;
            }
        }
    }

    // Single transfer test with proper completion checking
    for(int i = 0; i < n_regions; i++) {
        std::cout << "Testing region " << i << " with " << single_test_size << " bytes..." << std::endl;
        
        cthread[i]->clearCompleted();
        cthread[i]->invoke(CoyoteOper::LOCAL_TRANSFER, &sg[i], {true, false, false});
        
        if (wait_for_completion(cthread[i].get(), CoyoteOper::LOCAL_TRANSFER)) {
            std::cout << "  ✓ Transfer completed successfully" << std::endl;
        } else {
            std::cout << "  ⚠ Transfer timed out - may indicate memory gateway blocking" << std::endl;
        }
    }

    // Single size performance benchmark
    std::cout << "\nRunning single-size performance benchmark..." << std::endl;
    std::cout << "Testing " << single_test_size << " bytes with " << n_reps_lat << " repetitions" << std::endl;
    std::cout << "----------------------------------------------------" << std::endl;

    // Prep for latency test
    for(int i = 0; i < n_regions; i++) {
        cthread[i]->clearCompleted();
        sg[i].local.src_len = single_test_size;
        sg[i].local.dst_len = single_test_size;
    }

    try {
        // Latency test with timeout
        auto benchmark_lat = [&]() {
            // Transfer the data
            for(int i = 0; i < n_reps_lat; i++) {
                for(int j = 0; j < n_regions; j++) {
                    cthread[j]->invoke(CoyoteOper::LOCAL_TRANSFER, &sg[j], {true, true, false});

                    // Add timeout to prevent hanging
                    int timeout_counter = 0;
                    while(cthread[j]->checkCompleted(CoyoteOper::LOCAL_WRITE) != 1) {
                        if(stalled.load()) throw std::runtime_error("Stalled, SIGINT caught");

                        timeout_counter++;
                        if(timeout_counter > 500) { // 5 second timeout
                            throw std::runtime_error("Transfer timeout for size " + std::to_string(single_test_size));
                        }
                        std::this_thread::sleep_for(std::chrono::milliseconds(10));
                    }
                }
            }
        };

        bench.runtime(benchmark_lat);
        std::cout << "SUCCESS: " << single_test_size << " bytes completed in "
                  << bench.getAvg() / n_reps_lat << " ns average latency" << std::endl;
    }
    catch (const std::exception& e) {
        std::cout << "FAILED: " << single_test_size << " bytes - " << e.what() << std::endl;
    }

    std::cout << std::endl;

    // Display final memory contents
    for (int j = 0; j < n_regions; j++) {
        std::cout << "Data for vFPGA " << j << std::endl;
        for (int i = 0; i < std::min(8, (int)(32 / sizeof(uint32_t))); i++) {
            std::cout << "Number " << i << ": " << ((uint32_t *)hMem[j])[i] << std::endl;
        }
    }

    // ---------------------------------------------------------------
    // Release
    // ---------------------------------------------------------------

    // Disable all endpoints before cleanup
    PR_HEADER("CLEANUP");
    if (endpoints_configured) {
        for (int i = 0; i < n_regions; i++) {
            try {
                uint32_t ep_index = 0;  // Use endpoint 0 for each region
                cthread[i]->epSetValid(ep_index, false);
                std::cout << "Disabled endpoint for region " << i << std::endl;
            } catch (const std::exception& e) {
                std::cout << "Warning: Failed to disable endpoint for region " << i << ": " << e.what() << std::endl;
            }
        }
    } else {
        std::cout << "No endpoints were configured, skipping endpoint cleanup." << std::endl;
    }

    // Print status
    for (int i = 0; i < n_regions; i++) {
        if(!mapped) {
            if(!huge) free(hMem[i]);
            else      munmap(hMem[i], max_size);
        }
        cthread[i]->printDebug();
    }

    return EXIT_SUCCESS;
}