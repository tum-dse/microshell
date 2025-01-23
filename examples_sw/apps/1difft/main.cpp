#include <iostream>
#include <string>
#include <malloc.h>
#include <signal.h>
#include <boost/program_options.hpp>
#include <any>
#include <cmath>
#include <iomanip>
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
constexpr auto const accumulateSize = 512;
constexpr auto const outputSize = defSize / accumulateSize;
//constexpr float const sampleRate = 44100.0f;

void generateFrequencyData(float* buffer, int size) {
    for(int i = 0; i < size; i++) {
        float magnitude = (i < size/2) ? 100.0f : 50.0f;
        float phase = 2.0f * M_PI * i / size;
        buffer[2*i] = magnitude * cos(phase);
        buffer[2*i+1] = magnitude * sin(phase);
    }
}

void processAndPrintResults(float* input_ptr, float* output_ptr, int size) {
    std::cout << "\nRaw frequency components around peak region (indices 15-25):\n";
    for(int j = 15; j < 25; j++) {
        std::cout << "Bin " << std::setw(2) << j << ": (" 
                 << std::setw(10) << std::fixed << std::setprecision(6) << input_ptr[2*j]
                 << ", " << std::setw(10) << input_ptr[2*j+1] << "i) "
                 << "mag: " << std::sqrt(input_ptr[2*j]*input_ptr[2*j] + 
                                       input_ptr[2*j+1]*input_ptr[2*j+1]) << "\n";
    }
    
    std::cout << "\nNormalized time-domain values (first 10):\n";
    float scale = 1.0f / size;
    for(int i = 0; i < 10; i++) {
        float real = output_ptr[2*i] * scale;
        float imag = output_ptr[2*i+1] * scale;
        std::cout << "(" << std::setw(10) << std::fixed << std::setprecision(6) 
                 << real << ", " << std::setw(10) << imag << "i) "
                 << "mag: " << std::sqrt(real*real + imag*imag) << "\n";
    }
}

int main(int argc, char *argv[]) {
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    uint32_t size = defSize;
    uint32_t n_reps = defReps;
    uint32_t buffer_size = 2 * size * sizeof(float);
    uint32_t n_pages = (buffer_size + hugePageSize - 1) / hugePageSize;

    PR_HEADER("PARAMS");
    std::cout << "vFPGA ID: " << targetVfid << std::endl;
    std::cout << "Number of allocated pages per run: " << n_pages << std::endl;
    std::cout << "IFFT size: " << size << std::endl;
    //std::cout << "Sample rate: " << sampleRate << " Hz" << std::endl;

    try {
        std::unique_ptr<cThread<std::any>> cthread(new cThread<std::any>(targetVfid, getpid(), defDevice));
        cthread->start();
        
        float* input_buffer = (float*) cthread->getMem({CoyoteAlloc::HPF, n_pages});
        float* output_buffer = (float*) cthread->getMem({CoyoteAlloc::HPF, n_pages});
        
        if (!input_buffer || !output_buffer) {
            throw std::runtime_error("Memory allocation failed");
        }

        generateFrequencyData(input_buffer, size);
        memset(output_buffer, 0, buffer_size);

        sgEntry sg;
        sgFlags sg_flags = { true, true, false };
        memset(&sg, 0, sizeof(localSg));
        
        sg.local.src_addr = input_buffer;
        sg.local.src_len = buffer_size;
        sg.local.src_stream = strmHost;
        sg.local.src_dest = targetVfid;
        sg.local.dst_addr = output_buffer;
        sg.local.dst_len = buffer_size;
        sg.local.dst_stream = strmHost;
        sg.local.dst_dest = targetVfid;

        PR_HEADER("IFFT PROCESSING");
        
        cthread->invoke(CoyoteOper::LOCAL_TRANSFER, &sg, sg_flags);

        while(cthread->checkCompleted(CoyoteOper::LOCAL_WRITE) != 1) {
            if(stalled.load()) throw std::runtime_error("Stalled");
        }

        processAndPrintResults(input_buffer, output_buffer, size);

        cthread->printDebug();
        
        cthread->freeMem(input_buffer);
        cthread->freeMem(output_buffer);

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }
    
    return EXIT_SUCCESS;
}