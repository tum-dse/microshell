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
constexpr auto const defSThread = 0;
constexpr auto const defNThreads = 1;
constexpr auto const defHuge = true;
constexpr auto const defMapped = true;
constexpr auto const nRepsThr = 128;
constexpr auto const defSize = 16384 * sizeof(float); // FFT size
constexpr auto const nBenchRuns = 1;

/* Thread context structure */
struct ThreadContext {
    void* fft_input;          // FFT input buffer
    void* result_buffer;      // Classification result
    sgEntry sg;               // Scatter-gather entry
    sgFlags flags;            // Transfer flags
    uint32_t n_runs;          // Number of completed runs
    std::chrono::high_resolution_clock::time_point start_time;
    std::chrono::high_resolution_clock::time_point end_time;
    
    ThreadContext() : fft_input(nullptr), result_buffer(nullptr), n_runs(0) {}
};

/* Audio data preparation function */
void prepareFftInput(float* input, size_t size) {
    const float sample_rate = 44100.0f;  // Standard audio sample rate
    const float fundamental_freq = 440.0f;  // A4 note
    
    for(size_t i = 0; i < size/sizeof(float); i++) {
        float t = static_cast<float>(i) / sample_rate;
        // Create a mix of frequencies
        input[i] = 0.5f * sin(2.0f * M_PI * fundamental_freq * t) +         // Main tone
                  0.3f * sin(2.0f * M_PI * (2 * fundamental_freq) * t) +    // First harmonic
                  0.2f * sin(2.0f * M_PI * (3 * fundamental_freq) * t);     // Second harmonic
    }
}

/* Result validation function */
void validateResult(float result) {
    if (result < 1.0f || result > 5.0f) {
        std::cout << "Warning: Unexpected classification result: " << result 
                  << " (expected range: 1-5)" << std::endl;
    }
}

int main(int argc, char *argv[]) {
    // Signal handler setup
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    // Parse command line arguments
    boost::program_options::options_description programDescription("Options:");
    programDescription.add_options()
        ("bitstream,b", boost::program_options::value<string>(), "Shell bitstream")
        ("device,d", boost::program_options::value<uint32_t>(), "Target device")
        ("sthread,t", boost::program_options::value<uint32_t>(), "Starting thread number")
        ("nthreads,n", boost::program_options::value<uint32_t>(), "Number of threads")
        ("hugepages,h", boost::program_options::value<bool>(), "Use hugepages")
        ("mapped,m", boost::program_options::value<bool>(), "Use mapped memory")
        ("reps,r", boost::program_options::value<uint32_t>(), "Number of repetitions")
        ("size,s", boost::program_options::value<uint32_t>(), "Transfer size");
    
    boost::program_options::variables_map commandLineArgs;
    boost::program_options::store(boost::program_options::parse_command_line(argc, argv, programDescription), commandLineArgs);
    boost::program_options::notify(commandLineArgs);

    // Process command line arguments
    string bstream_path = "";
    uint32_t cs_dev = defDevice;
    uint32_t s_thread = defSThread;
    uint32_t n_threads = defNThreads;
    bool huge = defHuge;
    bool mapped = defMapped;
    uint32_t n_reps = nRepsThr;
    uint32_t size = defSize;

    if(commandLineArgs.count("bitstream")) {
        bstream_path = commandLineArgs["bitstream"].as<string>();
        std::cout << std::endl << "Loading shell bitstream from: " << bstream_path << std::endl;
        cRnfg crnfg(cs_dev);
        crnfg.shellReconfigure(bstream_path);
    }
    if(commandLineArgs.count("device")) cs_dev = commandLineArgs["device"].as<uint32_t>();
    if(commandLineArgs.count("sthread")) s_thread = commandLineArgs["sthread"].as<uint32_t>();
    if(commandLineArgs.count("nthreads")) n_threads = commandLineArgs["nthreads"].as<uint32_t>();
    if(commandLineArgs.count("hugepages")) huge = commandLineArgs["hugepages"].as<bool>();
    if(commandLineArgs.count("mapped")) mapped = commandLineArgs["mapped"].as<bool>();
    if(commandLineArgs.count("reps")) n_reps = commandLineArgs["reps"].as<uint32_t>();
    if(commandLineArgs.count("size")) size = commandLineArgs["size"].as<uint32_t>();

    PR_HEADER("SPEECH RECOGNITION PIPELINE PARAMETERS");
    std::cout << "FFT Size: " << size/sizeof(float) << " samples" << std::endl;
    std::cout << "Number of threads: " << n_threads << std::endl;
    std::cout << "Using hugepages: " << huge << std::endl;
    std::cout << "Using mapped memory: " << mapped << std::endl;
    std::cout << "Number of repetitions: " << n_reps << std::endl;

    try {
        // Initialize resources
        std::vector<std::unique_ptr<cThread<std::any>>> cthread;
        std::vector<ThreadContext> contexts(n_threads);

        // Allocate resources for each thread
        for(int i = 0; i < n_threads; i++) {
            cthread.emplace_back(new cThread<std::any>(targetVfid, getpid(), cs_dev));
            cthread[i]->start();  // Start the thread

            // Allocate memory
            contexts[i].fft_input = cthread[i]->getMem({huge ? CoyoteAlloc::HPF : CoyoteAlloc::REG, size});
            contexts[i].result_buffer = cthread[i]->getMem({huge ? CoyoteAlloc::HPF : CoyoteAlloc::REG, sizeof(float)});

            if(!contexts[i].fft_input || !contexts[i].result_buffer) {
                throw std::runtime_error("Memory allocation failed for thread " + std::to_string(i));
            }

            // Setup scatter-gather entries
            memset(&contexts[i].sg, 0, sizeof(localSg));
            contexts[i].sg.local.src_addr = contexts[i].fft_input;
            contexts[i].sg.local.src_len = size;
            contexts[i].sg.local.src_stream = strmHost;
            contexts[i].sg.local.src_dest = i + s_thread;

            contexts[i].sg.local.dst_addr = contexts[i].result_buffer;
            contexts[i].sg.local.dst_len = sizeof(float);
            contexts[i].sg.local.dst_stream = strmHost;
            contexts[i].sg.local.dst_dest = i + s_thread;
        }

        // Benchmark setup
        cBench bench(nBenchRuns);
        PR_HEADER("SPEECH RECOGNITION PIPELINE BENCHMARK");

        auto benchmark_thr = [&]() {
            // Clear completion status for all threads
            for(int i = 0; i < n_threads; i++) {
                contexts[i].n_runs = 0;
                cthread[i]->clearCompleted();
            }

            // Process each repetition
            for(uint32_t rep = 0; rep < n_reps; rep++) {
                std::cout << "\nProcessing Repetition " << rep + 1 << "/" << n_reps << std::endl;
                
                for(int i = 0; i < n_threads; i++) {
                    // Prepare input data
                    prepareFftInput((float*)contexts[i].fft_input, size);
                    
                    // Setup transfer flags
                    contexts[i].flags = {false, false, false};
                    if(rep == n_reps-1) contexts[i].flags.last = true;
                    
                    // Start timing
                    contexts[i].start_time = std::chrono::high_resolution_clock::now();
                    
                    // Launch transfer
                    cthread[i]->invoke(CoyoteOper::LOCAL_TRANSFER, &contexts[i].sg, contexts[i].flags);
                    contexts[i].n_runs++;
                }

                // Wait for completion
                for(int i = 0; i < n_threads; i++) {
                    while(cthread[i]->checkCompleted(CoyoteOper::LOCAL_TRANSFER) != contexts[i].n_runs) {
                        if(stalled.load()) {
                            throw std::runtime_error("Stalled, SIGINT caught");
                        }
                        std::this_thread::sleep_for(std::chrono::milliseconds(10));
                    }
                    
                    // End timing
                    contexts[i].end_time = std::chrono::high_resolution_clock::now();
                    
                    // Get and validate results
                    float result = *((float*)contexts[i].result_buffer);
                    auto duration = std::chrono::duration_cast<std::chrono::microseconds>(
                        contexts[i].end_time - contexts[i].start_time).count();
                    
                    std::cout << "Thread " << i << ":" << std::endl;
                    std::cout << "  Processing time: " << duration << " us" << std::endl;
                    std::cout << "  Classification result: " << result << std::endl;
                    validateResult(result);
                }
            }
        };

        // Run benchmark
        bench.runtime(benchmark_thr);
        
        // Print overall performance metrics
        std::cout << std::fixed << std::setprecision(2);
        double avg_throughput = (1000.0 * (double)n_threads * (double)n_reps * (double)size) / bench.getAvg();
        std::cout << "\nOverall Pipeline Performance:" << std::endl;
        std::cout << "Average throughput: " << avg_throughput << " MB/s" << std::endl;
        std::cout << "Average latency: " << bench.getAvg()/(n_threads * n_reps) << " us per sample" << std::endl;

        // Print debug info
        PR_HEADER("DEBUG INFORMATION");
        cthread[0]->printDebug();

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
