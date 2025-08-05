# Evaluation

This document provides instructions for running various evaluation tests including performance overhead analysis, scalability analysis, and programmability measurements. Both automated scripts and manual procedures are documented.

## Important Note on Server Usage

Due to potential server crashes during hardware testing on Clara, the workflow is split:
- **Amy Server**: Used for hardware compilation (bitstream generation)
- **Clara Server**: Used for hardware testing and software execution

## End-to-End Performance Overhead

This analysis compares the performance overhead between baseline and µShell implementations.

### µShell and µShell_mono

#### Step 1: Generate Bitstreams for µShell and µShell_mono

##### Automated Method
```bash
cd evaluation/scripts
bash ./compile_hw_ushell.sh /path/to/ushell
```

This creates parallel tmux sessions for all examples including mono versions. Monitor progress with:
```bash
tmux list-sessions
tmux attach -t build_audio_hw        # Regular version
tmux attach -t build_audio_mono_hw   # Mono version
```

##### Manual Method (Run on Amy Server)
For individual compilation or debugging:

```bash
# Navigate to µShell hardware directory
cd /path/to/ushell/examples_hw/

# For regular version
mkdir digi_sign_ushell && cd digi_sign_ushell
xilinx-shell
cmake ../ -DEXAMPLE=digi_sign_ushell -DFDEV_NAME=u280
make project
make bitgen

# For mono version
mkdir digi_sign_mono && cd digi_sign_mono
xilinx-shell
cmake ../ -DEXAMPLE=digi_sign_mono -DFDEV_NAME=u280
make project
make bitgen

# Note the bitstream location for later use:
# Regular: /path/to/ushell/examples_hw/digi_sign_ushell/bitstreams/cyt_top.bit
# Mono: /path/to/ushell/examples_hw/digi_sign_mono/bitstreams/cyt_top.bit
```

Transfer bitstream files to Clara server after generation (applicable to both generation methods).

#### Step 2: Run Tests to get Evaluation Data

##### Automated Method
From the evaluation/scripts directory, the scripts now require the bitstream path:

```bash
# Test regular µShell examples with bitstream path (default 1MB)
./compile_sw_ushell.sh audio /path/to/ushell/examples_hw/audio/bitstreams/cyt_top.bit /path/to/ushell
./compile_sw_ushell.sh digi_sign /path/to/ushell/examples_hw/digi_sign/bitstreams/cyt_top.bit /path/to/ushell
./compile_sw_ushell.sh secure /path/to/ushell/examples_hw/secure/bitstreams/cyt_top.bit /path/to/ushell

# Test mono versions with their bitstream paths
./compile_sw_ushell.sh audio_mono /path/to/ushell/examples_hw/audio_mono/bitstreams/cyt_top.bit /path/to/ushell
./compile_sw_ushell.sh digi_sign_mono /path/to/ushell/examples_hw/digi_sign_mono/bitstreams/cyt_top.bit /path/to/ushell

# Test with custom size
./compile_sw_ushell.sh audio /path/to/ushell/examples_hw/audio/bitstreams/cyt_top.bit /path/to/ushell 65536

# Test with custom bitstream from different location
./compile_sw_ushell.sh audio /home/user/custom_bitstreams/audio_v2.bit /path/to/ushell 1048576
```

Results are saved to: `evaluation/data/e2e_ushell_results.csv`

##### Manual Method (Run on Clara Server)

1. **Setup Environment**:
```bash
cd /scratch/anubhav/vFPIO/
nix-shell vfpio.nix
sudo sysctl -w vm.nr_hugepages=1024

# Load driver
cd /path/to/ushell/driver/
sudo rmmod coyote_drv 2>/dev/null || true
sudo insmod coyote_drv.ko

# Copy bitstream to standard location (if not already there)
mkdir -p /path/to/ushell/bitstreams
cp /path/to/your/bitstream.bit /path/to/ushell/bitstreams/cyt_top.bit
cp /path/to/your/bitstream.ltx /path/to/ushell/bitstreams/cyt_top.ltx  # if available

# Program FPGA
cd /path/to/ushell
bash ./program_fpga.sh cyt_top
```

2. **Build and Run Software**:
```bash
cd /path/to/ushell/examples_sw/
mkdir digi_sign_ushell && cd digi_sign_ushell
cmake ../ -DEXAMPLE=digi_sign_ushell
make
cd bin

# Run tests with different sizes
./test              # Default parameters
./test -s 65536     # 64KB
./test -s 1048576   # 1MB
./test -s 4194304   # 4MB
```

3. **Reuse Existing Builds** (for quick testing):
```bash
# Navigate directly to existing build
cd /path/to/ushell/examples_sw/digi_sign_ushell/bin

# Run multiple tests without rebuilding
./test -s 1024      # 1KB
./test -s 16384     # 16KB
./test -s 65536     # 64KB
./test -s 1048576   # 1MB
```

### Baseline

#### Step 1: Generate Bitstreams for Baseline

##### Automated Method
```bash
cd evaluation/scripts
bash ./compile_hw_baseline.sh /path/to/baseline
```

##### Manual Method (Run on Amy Server)
```bash
cd /path/to/baseline/examples_hw/
mkdir digi_sign_base && cd digi_sign_base
xilinx-shell
cmake ../ -DEXAMPLE=digi_sign_base -DFDEV_NAME=u280
make project
make bitgen

# Note the bitstream location for later use:
# /path/to/baseline/examples_hw/digi_sign_base/bitstreams/cyt_top.bit
```

#### Step 2: Run Tests to get Evaluation Data

##### Automated Method
The scripts now require the bitstream path:

```bash
# Test baseline examples with bitstream path (default 1MB)
./compile_sw_baseline.sh audio /path/to/baseline/examples_hw/audio/bitstreams/cyt_top.bit /path/to/baseline
./compile_sw_baseline.sh digi_sign /path/to/baseline/examples_hw/digi_sign/bitstreams/cyt_top.bit /path/to/baseline

# Test with custom size
./compile_sw_baseline.sh audio /path/to/baseline/examples_hw/audio/bitstreams/cyt_top.bit /path/to/baseline 65536

# Test with custom bitstream location
./compile_sw_baseline.sh secure /scratch/builds/secure_optimized.bit /path/to/baseline 1048576
```

Results are saved to: `evaluation/data/e2e_baseline_results.csv`

##### Manual Method (Run on Clara Server)
Follow the same environment setup as µShell, then:

```bash
# Copy bitstream to standard location
mkdir -p /path/to/baseline/bitstreams
cp /path/to/your/bitstream.bit /path/to/baseline/bitstreams/cyt_top.bit
cp /path/to/your/bitstream.ltx /path/to/baseline/bitstreams/cyt_top.ltx  # if available

# Program FPGA and run tests
cd /path/to/baseline
bash ./program_fpga.sh cyt_top

cd /path/to/baseline/examples_sw/
mkdir digi_sign_base && cd digi_sign_base
cmake ../ -DEXAMPLE=digi_sign_base
make
cd bin

# Run tests
./test -s 65536     # 64KB test
./test -s 1048576   # 1MB test
```

### Analysis

The CSV files contain:
- `example_name`: Application name
- `data_size_bytes`: Test data size
- `throughput_MBps`: Throughput in MB/s
- `latency_ns`: Latency in nanoseconds
- `timestamp`: Test execution time

Compare the results between baseline and µShell to calculate the performance overhead.

### Manual Testing Best Practices

1. **Performance Sweep**: Test multiple data sizes for comprehensive analysis:
```bash
for size in 1024 4096 16384 65536 262144 1048576 4194304; do
    echo "Testing size: $size bytes"
    ./test -s $size
    sleep 2  # Brief pause between tests
done
```

2. **Multiple Runs**: For statistical significance:
```bash
# Run same test multiple times
for i in {1..5}; do
    echo "Run $i"
    ./test -s 1048576
done
```

3. **Quick Verification**: After FPGA programming:
```bash
# Small test to verify functionality
./test -s 1024
```

### Script Usage Examples

With the updated scripts, you can now test bitstreams from any location:

```bash
# Standard bitstream location
./compile_sw_ushell.sh audio examples_hw/audio/bitstreams/cyt_top.bit /path/to/ushell

# Custom bitstream location
./compile_sw_baseline.sh digi_sign /home/user/my_bitstreams/digi_sign_v2.bit /path/to/baseline

# Absolute paths
./compile_sw_ushell.sh secure /scratch/builds/secure_2024.bit /scratch/user/ushell 65536

# Testing different versions
./compile_sw_baseline.sh audio /tmp/audio_debug.bit /path/to/baseline 1048576
./compile_sw_baseline.sh audio /tmp/audio_optimized.bit /path/to/baseline 1048576
```

## Programmability

To measure code complexity and programmability metrics:

### Baseline Complexity Measurement

```bash
cd evaluation/scripts
bash ./measure_complexity_baseline.sh /path/to/baseline
```

# For analyzing Vitis Vision Library components

This evaluation consists of three steps. The `process_cv_files.py` goes through all the files and generate component reuse raw statics, `file_functions.txt`.
The `analyze_functions.py` process the `file_functions.txt` and generate data for plotting `top_10_functions` and `correlation_matrix.csv`. 
The `visualize_correlation.py` generates the correlation matrix.

```
python3 process_cv_files.py vision/L3/examples/ 
python3 analyze_functions.py 
python3 visualize_correlation.py correlation_matrix.csv -o visualization.png
```
### µShell Complexity Measurement

```bash
cd evaluation/scripts
bash ./measure_complexity_ushell.sh /path/to/ushell
```

### Manual Analysis

To manually examine code differences:
```bash
# Compare API usage
diff -r /path/to/baseline/sw/include /path/to/ushell/sw/include

# Count lines of code manually
find /path/to/baseline/examples_sw/apps -name "*.cpp" -o -name "*.h" | xargs wc -l
find /path/to/ushell/examples_sw/apps -name "*.cpp" -o -name "*.h" | xargs wc -l
```

## Scalability Analysis

### Step 1: Generate Bitstreams

```bash
cd evaluation/scripts
bash ./compile_scalability.sh /path/to/baseline
```

### Step 2: Access Vivado via RDP

After all bitstreams have been generated:

1. Access the server via RDP (Remote Desktop Protocol)
2. Open a terminal
3. Run the following commands:

```bash
xilinx-shell
vivado open_checkpoint ${proj_name}/checkpoints/shell_routed.dcp
```

#### Example

```bash
vivado open_checkpoint examples_hw/1vfpga/checkpoints/shell_routed.dcp
```

### Step 3: Generate Utilization Reports

After opening the checkpoint in Vivado:

1. Navigate to the **Reports** tab in the Vivado GUI
2. Generate the utilization report by:
   - Go to **Reports → Report Utilization**
   - Or use the Tcl command: `report_utilization -file utilization_report.txt`

### Step 4: Calculate Resource Usage per vFPGA

The utilization report will show resource usage for different hierarchical modules. Look for:
- `inst_shell` - The shell infrastructure resource usage
- `inst_user_wrapper` - The user logic wrapper resource usage
- Total available resources for the U280 FPGA

#### Resource Calculation Formulas

To calculate the theoretical resource allocation per vFPGA:

```
Theoretical per-vFPGA resource = (U280_available - (inst_shell - inst_user_wrapper)) / num_vFPGAs
```

Where:
- `U280_available` = Total available resources on the Xilinx Alveo U280 (e.g., LUTs, FFs, BRAM, DSP)
- `inst_shell` = Resources used by the shell infrastructure
- `inst_user_wrapper` = Resources used by the user logic wrapper
- `num_vFPGAs` = Number of virtual FPGAs in the design

#### U280 Resource Specifications

For reference, the Xilinx Alveo U280 contains:
- LUTs: 1,303,680
- Flip-Flops: 2,607,360
- Block RAM: 2,016 (36Kb blocks)
- Ultra RAM: 960
- DSP Slices: 9,024

## FPGA Acceleration Effectiveness Analysis

This analysis compares the performance of CPU-synchronized execution (individual components) versus direct FPGA communication (baseline).

### Step 1: Generate Bitstreams for Individual Components

##### Automated Method
```bash
cd evaluation/scripts
bash ./compile_effectiveness_hw.sh /path/to/baseline
```

##### Manual Method (Run on Amy Server)
Build individual components:
```bash
cd /path/to/baseline/examples_hw/

# Example for FFT component
mkdir fft && cd fft
xilinx-shell
cmake ../ -DEXAMPLE=fft -DFDEV_NAME=u280
make project
make bitgen

# Repeat for: aes_ctr, rsa, quant, rle, sha, svm
```

### Step 2: Generate Bitstreams for Baseline

Build the application pipelines (skip if already done in previous sections):

```bash
bash ./compile_hw_baseline.sh /path/to/baseline
```

### Step 3: Run Performance Tests

#### 3.1 Test Individual Components (CPU-sync)

##### Automated Method
Now with consistent usage - all scripts require the bitstream path and base directory:

```bash
# Test individual components at 1MB (default)
./compile_effectiveness_sw.sh fft /path/to/baseline/examples_hw/fft/bitstreams/cyt_top.bit /path/to/baseline
./compile_effectiveness_sw.sh quant /path/to/baseline/examples_hw/quant/bitstreams/cyt_top.bit /path/to/baseline
./compile_effectiveness_sw.sh rle /path/to/baseline/examples_hw/rle/bitstreams/cyt_top.bit /path/to/baseline
./compile_effectiveness_sw.sh aes_ctr /path/to/baseline/examples_hw/aes_ctr/bitstreams/cyt_top.bit /path/to/baseline
./compile_effectiveness_sw.sh rsa /path/to/baseline/examples_hw/rsa/bitstreams/cyt_top.bit /path/to/baseline
./compile_effectiveness_sw.sh sha /path/to/baseline/examples_hw/sha/bitstreams/cyt_top.bit /path/to/baseline
./compile_effectiveness_sw.sh svm /path/to/baseline/examples_hw/svm/bitstreams/cyt_top.bit /path/to/baseline

# Test with specific sizes
./compile_effectiveness_sw.sh fft /path/to/baseline/examples_hw/fft/bitstreams/cyt_top.bit /path/to/baseline 1048576

# Test with multiple sizes and options
./compile_effectiveness_sw.sh fft /path/to/baseline/examples_hw/fft/bitstreams/cyt_top.bit /path/to/baseline 32768,65536,131072 --csv fft_sweep.csv --verbose
```

##### Manual Method (Run on Clara Server)
After environment setup:
```bash
cd /path/to/baseline/examples_sw/
mkdir fft && cd fft
cmake ../ -DEXAMPLE=fft
make
cd bin
./test -s 1048576  # Test at 1MB
```

#### 3.2 Test Baseline Applications (IPC/Direct Communication)

Test the integrated applications following the same procedures as in the End-to-End Performance section.

### Step 4: Compare Results

- **CPU-sync values**: Calculated from individual component latencies
- **IPC values**: Direct throughput measurements from integrated applications

### Step 5: Calculate CPU-sync Throughput

CPU-sync throughput is calculated by summing the latencies of individual components:

| Application | Components | Calculation |
|-------------|------------|-------------|
| Audio Processing   | FFT + Quant + RLE | Total_latency = latency_fft + latency_quant + latency_rle |
| Digital Signature  | SHA + RSA     | Total_latency = latency_sha + latency_rsa |
| Secure Storage     | RLE + AES-CTR | Total_latency = latency_rle + latency_aes |
| Signed Compression | RLE + RSA     | Total_latency = latency_rle + latency_rsa |
| Speech Recognition | FFT + SVM     | Total_latency = latency_fft + latency_svm |

## Troubleshooting

### Common Issues

1. **Driver conflicts**:
```bash
sudo rmmod coyote_drv
sudo insmod coyote_drv.ko
```

2. **FPGA programming verification**:
```bash
ls -la /path/to/bitstreams/cyt_top.*
```

3. **Hugepages check**:
```bash
cat /proc/sys/vm/nr_hugepages
```

4. **Test executable not found**:
```bash
# Verify build completed
ls -la bin/
# Rebuild if necessary
make clean && make
```

## File Locations Reference

- **Hardware compilation scripts**: `Coyote/examples_hw/CMakeLists.txt`
- **Hardware application code**: `Coyote/examples_hw/apps/`
- **Software compilation scripts**: `Coyote/examples_sw/CMakeLists.txt`
- **Host application code**: `Coyote/examples_sw/apps/`
- **Baseline APIs**: `Coyote/sw/include/` and `Coyote/sw/src/`
- **µShell APIs**: `microShell/sw/include/` and `microShell/sw/src/`
