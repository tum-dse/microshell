/**
 * SVM module bring-up (DFG version): drives the standalone SVM vFPGA
 * with 32-float windows and reports the predicted class label.
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

#include "dfg.hpp"
#include "ushell.hpp"

using namespace std;
using namespace std::chrono;
using namespace fpga;
using namespace ushell;

std::atomic<bool> stalled(false);
void gotInt(int) {
    stalled.store(true);
}

constexpr auto const defDevice = 0;
constexpr auto const defReps = 1;
constexpr auto const defSize = 32;

// Coloured red bold section banner.
void print_header(const std::string& header) {
    std::cout << "\n-- \033[31m\e[1m" << header << "\033[0m\e[0m" << std::endl;
    std::cout << "-----------------------------------------------" << std::endl;
}

// Helper function to print latency statistics.
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

// Decode IEEE-754 bit pattern of canonical class outputs (1.0/2.0/3.0/4.0/5.0)
// into a human-readable label.
std::string getClassLabel(float result) {
    uint32_t result_bits = *(uint32_t*)&result;
    switch(result_bits) {
        case 0x40800000: return "Class 4";
        case 0x3F800000: return "Class 1";
        case 0x40000000: return "Class 2";
        case 0x40400000: return "Class 3";
        case 0x40A00000: return "Class 5";
        default: return "Unknown";
    }
}

int main(int argc, char *argv[])
{
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = gotInt;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    boost::program_options::options_description programDescription("SVM Classification Options:");
    programDescription.add_options()
        ("bitstream,b", boost::program_options::value<string>(), "Shell bitstream")
        ("device,d", boost::program_options::value<uint32_t>(), "Target device")
        ("size,s", boost::program_options::value<uint32_t>(), "Total number of floats (must be multiple of 32)")
        ("reps,r", boost::program_options::value<uint32_t>(), "Number of reps")
        ("help", "Show help");

    boost::program_options::variables_map commandLineArgs;
    boost::program_options::store(boost::program_options::parse_command_line(argc, argv, programDescription),
                                commandLineArgs);
    boost::program_options::notify(commandLineArgs);

    if(commandLineArgs.count("help")) {
        std::cout << programDescription << std::endl;
        return EXIT_SUCCESS;
    }

    string bstream_path = "";
    uint32_t cs_dev = defDevice;
    uint32_t size = defSize;
    uint32_t n_reps = defReps;

    if(commandLineArgs.count("bitstream") > 0) {
        bstream_path = commandLineArgs["bitstream"].as<string>();

        std::cout << std::endl << "Shell loading (path: " << bstream_path << ") ..." << std::endl;
        cRnfg crnfg(cs_dev);
        crnfg.shellReconfigure(bstream_path);
    }
    if(commandLineArgs.count("device") > 0) cs_dev = commandLineArgs["device"].as<uint32_t>();
    if(commandLineArgs.count("size") > 0) size = commandLineArgs["size"].as<uint32_t>();
    if(commandLineArgs.count("reps") > 0) n_reps = commandLineArgs["reps"].as<uint32_t>();

    // SVM consumes one classification per 32 floats.
    if(size % 32 != 0) {
        std::cout << "Warning: Size must be multiple of 32. Adjusting " << size
                  << " to " << ((size + 31) / 32) * 32 << std::endl;
        size = ((size + 31) / 32) * 32;
    }

    uint32_t num_classifications = size / 32;
    uint32_t buffer_size = size * sizeof(float);
    uint32_t output_buffer_size = num_classifications * sizeof(float);

    // Reference 32-sample input that produces a known SVM classification.
    float test_data[32] = {
        36257662.0f, 70308074.0f, 162763557.0f, 109956489.0f, 86125933.0f,
        35535698.0f, 5473712.0f, 2191429.0f, 1655529.0f, 1427210.0f,
        1819290.0f, 2594503.0f, 2649694.0f, 849597.0f, 765175.0f,
        890647.0f, 1405332.0f, 1132804.0f, 5776375.0f, 18372118.0f,
        6724989.0f, 7313762.0f, 1469345.0f, 1744257.0f, 1631652.0f,
        823229.0f, 1018674.0f, 639273.0f, 601445.0f, 630083.0f,
        678854.0f, 636897.0f
    };

    print_header("PARAMS");
    std::cout << "Pipeline: SVM Classification" << std::endl;
    std::cout << "Total input size: " << size << " floats (" << num_classifications << " sets of 32)" << std::endl;
    std::cout << "Expected classifications: " << num_classifications << std::endl;
    std::cout << "Output size: " << output_buffer_size << " bytes (" << num_classifications << " floats)" << std::endl;
    std::cout << "Number of reps: " << n_reps << std::endl;

    try {
        print_header("DATAFLOW SETUP");

        Dataflow svm_dataflow("svm_classification_pipeline");

        Task& svm_classifier = svm_dataflow.add_task("svm_classifier", "classification");

        Buffer& input_buffer = svm_dataflow.add_buffer(buffer_size, "input_buffer");
        Buffer& output_buffer = svm_dataflow.add_buffer(output_buffer_size, "output_buffer");

        svm_dataflow.to(input_buffer, svm_classifier.in)
                    .to(svm_classifier.out, output_buffer);

        std::cout << "Creating SVM dataflow:" << std::endl;
        std::cout << "  input_buffer → svm_classifier → output_buffer" << std::endl;

        if (!svm_dataflow.check()) {
            throw std::runtime_error("Failed to validate dataflow");
        }

        print_header("DATA GENERATION");

        // Per-packet offset prevents reps from collapsing into identical inputs.
        std::vector<std::vector<float>> test_inputs(n_reps);
        for(int i = 0; i < n_reps; i++) {
            test_inputs[i].resize(size);

            for(int set = 0; set < num_classifications; set++) {
                for(int j = 0; j < 32; j++) {
                    test_inputs[i][set * 32 + j] = test_data[j] + (set * 1000.0f);
                }
            }
        }

        std::cout << "\nInput data for each packet:\n";
        for(int set = 0; set < num_classifications; set++) {
            std::cout << "Packet " << (set + 1) << " (first 8 values): ";
            for(int j = 0; j < 8; j++) {
                std::cout << std::fixed << std::setprecision(1) << (test_data[j] + (set * 1000.0f));
                if(j < 7) std::cout << " ";
            }
            std::cout << " ... (+" << (set * 1000.0f) << " offset)\n";
        }
        std::cout << "\n";

        print_header("SVM CLASSIFICATION");

        cBench bench(n_reps);

        std::vector<std::vector<float>> output_data(n_reps);
        for(int i = 0; i < n_reps; i++) {
            output_data[i].resize(num_classifications);
        }

        auto benchmark_thr = [&]() {
            for(int i = 0; i < n_reps; i++) {
                write_dataflow_buffer(input_buffer, test_inputs[i].data(), buffer_size);
                svm_dataflow.clear_completed();
                svm_dataflow.execute(buffer_size);
                read_dataflow_buffer(output_buffer, output_data[i].data(), output_buffer_size);

                if(stalled.load()) throw std::runtime_error("Stalled, SIGINT caught");
            }
        };

        bench.runtime(benchmark_thr);

        print_header("LATENCY MEASUREMENTS");
        printLatencyStats(bench.getAvg() / n_reps, buffer_size, n_reps);

        print_header("RAW OUTPUT BUFFER DEBUG");
        for(int i = 0; i < n_reps; i++) {
            std::cout << "Rep " << i << " output buffer contents:\n";
            std::cout << "Buffer size: " << output_buffer_size << " bytes ("
                      << num_classifications << " floats)\n";

            for(int j = 0; j < num_classifications; j++) {
                uint32_t bits = *(uint32_t*)&output_data[i][j];
                std::cout << "  output[" << j << "] = " << output_data[i][j]
                          << " (hex: 0x" << std::hex << bits << std::dec << ")\n";
            }
            std::cout << std::endl;
        }

        print_header("RESULTS");
        for(int i = 0; i < n_reps; i++) {
            std::cout << "Rep " << i << " results:\n";
            for(int j = 0; j < num_classifications; j++) {
                std::cout << "  Classification " << (j+1) << "/" << num_classifications
                         << ": " << output_data[i][j]
                         << " (" << getClassLabel(output_data[i][j]) << ")"
                         << std::endl;
            }
            std::cout << std::endl;
        }

        if(n_reps > 1) {
            print_header("CONSISTENCY CHECK");
            bool consistent = true;
            for(int j = 0; j < num_classifications; j++) {
                bool packet_consistent = true;
                for(int i = 1; i < n_reps; i++) {
                    if(output_data[i][j] != output_data[0][j]) {
                        packet_consistent = false;
                        consistent = false;
                        break;
                    }
                }
                std::cout << "Packet " << (j+1) << ": "
                         << (packet_consistent ? "CONSISTENT" : "INCONSISTENT") << std::endl;
            }
            std::cout << "\nOverall consistency: " << (consistent ? "PASSED" : "FAILED") << std::endl;
        }

        if (svm_dataflow.get_debug_level() > 1) {
            print_header("DEBUG INFO");
            svm_dataflow.print_graph();
            svm_dataflow.print_connections();
            svm_dataflow.print_capability_tree();
        }

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }

    print_header("SVM CLASSIFICATION COMPLETE");
    std::cout << "SVM classification pipeline executed successfully!" << std::endl;

    return EXIT_SUCCESS;
}
