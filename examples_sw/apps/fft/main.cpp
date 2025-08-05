/**
 * FFT
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
#include <cmath>
#include <random>
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
constexpr auto const defSize = 256;      // Default: 256 bytes (32 complex samples)
constexpr auto const defDW = 4;
constexpr float const sampleRate = 44100.0f;
constexpr auto const maxBinsToShow = 8;  // Limit FFT output display

// Generate sine wave value
float generateSineValue(int index) {
    const float amplitude = 1000.0f;
    const float frequency = 1378.125f;
    const float phase = 0.0f;
    
    float t = (float)index / sampleRate;
    return amplitude * sin(2.0f * M_PI * frequency * t + phase);
}

// Function to print summary FFT results
void printFFTSummary(float* output_ptr, int fft_index) {
    float freqResolution = sampleRate / 32;  // 32-point FFT: 1378.125 Hz/bin
    
    // Find peak magnitude bin
    float maxMagnitude = 0.0f;
    int peakBin = 0;
    
    for(int i = 0; i < 16; i++) {  // Check first 16 bins (Nyquist)
        float real = output_ptr[2*i];
        float imag = output_ptr[2*i+1];
        float magnitude = std::sqrt(real*real + imag*imag);
        
        if(magnitude > maxMagnitude) {
            maxMagnitude = magnitude;
            peakBin = i;
        }
    }
    
    float peakFreq = peakBin * freqResolution;
    
    std::cout << "FFT #" << (fft_index + 1) << " Summary: ";
    std::cout << "Peak at bin " << peakBin << " (" 
              << std::fixed << std::setprecision(1) << peakFreq << " Hz) "
              << "with magnitude " << std::setprecision(0) << maxMagnitude << std::endl;
}

// Print detailed FFT for first result only
void printDetailedFFT(float* output_ptr) {
    const float freqResolution = sampleRate / 32;  // 1378.125 Hz/bin
    
    std::cout << "\nDetailed FFT Output (first " << maxBinsToShow << " bins):\n";
    std::cout << "Bin\tFreq(Hz)\tMagnitude\n";
    std::cout << "--------------------------------\n";
    
    for(int i = 0; i < maxBinsToShow; i++) {
        float real = output_ptr[2*i];
        float imag = output_ptr[2*i+1];
        float magnitude = std::sqrt(real*real + imag*imag);
        
        std::cout << i << "\t" 
                  << std::fixed << std::setprecision(1) << (i * freqResolution) << "\t\t"
                  << std::setprecision(0) << magnitude << "\n";
    }
    std::cout << "... (" << (16 - maxBinsToShow) << " more bins omitted)\n";
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

int main(int argc, char *argv[]) {
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    boost::program_options::options_description programDescription("Options:");
    programDescription.add_options()
        ("size,s", boost::program_options::value<uint32_t>(), "Buffer size in bytes (must be multiple of 256)")
        ("reps,r", boost::program_options::value<uint32_t>(), "Number of reps")
        ("verbose,v", "Enable verbose output");
    
    boost::program_options::variables_map commandLineArgs;
    boost::program_options::store(boost::program_options::parse_command_line(argc, argv, programDescription), commandLineArgs);
    boost::program_options::notify(commandLineArgs);

    uint32_t n_reps = defReps;
    uint32_t size_bytes = defSize;
    bool verbose = commandLineArgs.count("verbose") > 0;
    
    if(commandLineArgs.count("size") > 0) size_bytes = commandLineArgs["size"].as<uint32_t>();
    if(commandLineArgs.count("reps") > 0) n_reps = commandLineArgs["reps"].as<uint32_t>();

    // Ensure size is multiple of 256 bytes (32 complex samples * 8 bytes/complex)
    constexpr uint32_t min_chunk_bytes = 32 * sizeof(std::complex<float>);  // 256 bytes
    if(size_bytes % min_chunk_bytes != 0) {
        uint32_t adjusted_size = ((size_bytes + min_chunk_bytes - 1) / min_chunk_bytes) * min_chunk_bytes;
        std::cout << "Warning: Size must be multiple of " << min_chunk_bytes 
                  << " bytes (32 complex samples). Adjusting " << size_bytes 
                  << " to " << adjusted_size << " bytes" << std::endl;
        size_bytes = adjusted_size;
    }

    // Calculate derived values
    uint32_t buffer_size = size_bytes;
    uint32_t complex_size = buffer_size / sizeof(float);     // Total floats
    uint32_t input_size = complex_size / 2;                  // Complex samples
    uint32_t num_ffts = input_size / 32;                     // Number of 32-point FFTs
    uint32_t n_pages = (buffer_size + hugePageSize - 1) / hugePageSize;

    PR_HEADER("PARAMS");
    std::cout << "vFPGA ID: " << targetVfid << std::endl;
    std::cout << "Number of allocated pages per run: " << n_pages << std::endl;
    std::cout << "Buffer size: " << size_bytes << " bytes" << std::endl;
    std::cout << "Complex samples: " << input_size << " (" << num_ffts << " x 32-point FFTs)" << std::endl;
    std::cout << "Number of reps: " << n_reps << std::endl;
    std::cout << "Sample rate: " << sampleRate << " Hz" << std::endl;
    std::cout << "Frequency resolution: " << (sampleRate/32) << " Hz/bin (per FFT)" << std::endl;
    if (!verbose) {
        std::cout << "Verbose mode: OFF (use -v for detailed output)" << std::endl;
    }

    try {
        std::unique_ptr<cThread<std::any>> cthread(new cThread<std::any>(targetVfid, getpid(), defDevice));
        cthread->start();
        
        std::vector<float*> input_buffers(n_reps, nullptr);
        std::vector<float*> output_buffers(n_reps, nullptr);

        std::vector<float> test_data(complex_size, 0.0f);

        // Show limited input samples
        if (verbose) {
            std::cout << "\nFirst 8 input complex samples:\n";
            for (uint32_t i = 0; i < min(8U, input_size); ++i) {
                test_data[2*i] = generateSineValue(i);      // Real part
                test_data[2*i + 1] = 0.0f;                  // Imaginary part                 
                std::cout << "  [" << i << "]: " << std::fixed << std::setprecision(2) 
                         << test_data[2*i] << " + " << test_data[2*i + 1] << "i\n";
            }
            std::cout << "\n";
        }
        
        // Generate all data
        for (uint32_t i = 0; i < input_size; ++i) {
            test_data[2*i] = generateSineValue(i);      // Real part
            test_data[2*i + 1] = 0.0f;                  // Imaginary part
        }

        // Allocate and initialize memory
        for(int i = 0; i < n_reps; i++) {
            input_buffers[i] = (float*) cthread->getMem({CoyoteAlloc::HPF, n_pages});
            output_buffers[i] = (float*) cthread->getMem({CoyoteAlloc::HPF, n_pages});
            
            if (!input_buffers[i] || !output_buffers[i]) {
                throw std::runtime_error("Memory allocation failed");
            }

            memcpy(input_buffers[i], test_data.data(), buffer_size);
            memset(output_buffers[i], 0, buffer_size);
        }

        sgEntry sg;
        sgFlags sg_flags = { true, true, false };

        cBench bench(n_reps);
        PR_HEADER("FFT PROCESSING");

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

            while(cthread->checkCompleted(CoyoteOper::LOCAL_TRANSFER) != n_reps) {
                if(stalled.load()) throw std::runtime_error("Stalled");
            }
        };

        bench.runtime(benchmark_thr);

        // Print performance metrics using printLatencyStats
        PR_HEADER("LATENCY MEASUREMENTS");
        printLatencyStats(bench.getAvg() / n_reps, buffer_size, n_reps);

        // Print FFT results
        PR_HEADER("RESULTS SUMMARY");
        
        // For first rep, show detailed output of first FFT
        if(n_reps > 0 && num_ffts > 0) {
            printDetailedFFT(output_buffers[0]);
            std::cout << std::endl;
        }
        
        // Show summary for all FFTs (limited output)
        int max_ffts_to_show = verbose ? min(10, (int)num_ffts) : min(5, (int)num_ffts);
        
        for(int i = 0; i < min(n_reps, verbose ? n_reps : 1); i++) {
            if(n_reps > 1) std::cout << "\nRep " << i << ":\n";
            
            for(int fft_idx = 0; fft_idx < max_ffts_to_show; fft_idx++) {
                printFFTSummary(output_buffers[i] + (fft_idx * 64), fft_idx);
            }
            
            if(num_ffts > max_ffts_to_show) {
                std::cout << "... (" << (num_ffts - max_ffts_to_show) 
                         << " more FFT outputs omitted)\n";
            }
        }

        if (verbose) {
            cthread->printDebug();
        }

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