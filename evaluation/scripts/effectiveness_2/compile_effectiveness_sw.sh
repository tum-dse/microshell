#!/bin/bash
# Hardware loading and testing script with effectiveness metrics extraction
# This script loads a bitstream, runs tests, and captures effectiveness data
#
# Supported output patterns from C++ test programs:
#   Primary patterns (from printLatencyStats):
#     Total latency: X ns (Y us)
#     Throughput:    X MB/s
#   
#   Fallback patterns:
#     Average latency: X μs/ms/ns
#     Average throughput: X MB/s
#
# Effectiveness data is saved to CSV format for analysis
#
set -e # Exit on any error

# Configuration
DEFAULT_TEST_SIZE="1048576"
DEFAULT_CSV_FILENAME="effectiveness_results.csv"

# Check for required tools
if ! command -v bc &> /dev/null; then
    echo "Error: 'bc' calculator not found. Please install it:"
    echo "  Ubuntu/Debian: sudo apt-get install bc"
    echo "  RHEL/CentOS: sudo yum install bc"
    exit 1
fi

# Function to display usage
usage() {
    echo "Usage: $0 <example_name> <bitstream_path> <baseline_base_dir> [test_size] [options]"
    echo ""
    echo "Arguments:"
    echo "  example_name      - Module name (fft, aes_ctr, rsa, sha256, quantize, rle, svm)"
    echo "  bitstream_path    - Path to the bitstream file (.bit)"
    echo "  baseline_base_dir - Path to baseline base directory"
    echo "  test_size         - Optional: Test size parameter (default: $DEFAULT_TEST_SIZE)"
    echo "                      Can be comma-separated for multiple tests"
    echo ""
    echo "Options:"
    echo "  --csv <filename>       - Specify CSV filename (default: $DEFAULT_CSV_FILENAME)"
    echo "  --verbose, -v          - Show detailed debug output"
    echo "  --skip-fpga-prog       - Skip FPGA programming (if already programmed)"
    echo ""
    echo "Examples:"
    echo "  # From baseline base directory:"
    echo "  $0 fft examples_hw/fft/bitstreams/cyt_top.bit /path/to/baseline"
    echo "  $0 aes_ctr examples_hw/aes_ctr/bitstreams/cyt_top.bit /path/to/baseline 65536"
    echo ""
    echo "  # From another directory:"
    echo "  $0 rsa /path/to/bitstream.bit /path/to/baseline"
    echo "  $0 fft /home/user/fft.bit /path/to/baseline 1048576"
    echo ""
    echo "  # With multiple test sizes and options:"
    echo "  $0 sha256 ./sha256.bit /path/to/baseline 32768,65536,131072 --csv sha256_sweep.csv --verbose"
    echo ""
    exit 1
}

# Function to extract throughput value from output
extract_throughput() {
    local output="$1"
    local value=""
    
    # Look for "Throughput:" followed by value and "MB/s"
    local line=$(echo "$output" | grep -E "^[[:space:]]*Throughput:" | head -1)
    
    if [ -n "$line" ]; then
        # Extract the numeric value before MB/s (including decimals and scientific notation)
        value=$(echo "$line" | sed -E 's/.*Throughput:[[:space:]]+([0-9]+\.?[0-9]*[eE]?[+-]?[0-9]*)[[:space:]]+MB\/s.*/\1/')
        
        # If MB/s pattern failed, try without the slash
        if [ -z "$value" ] || [ "$value" = "$line" ]; then
            value=$(echo "$line" | sed -E 's/.*Throughput:[[:space:]]+([0-9]+\.?[0-9]*[eE]?[+-]?[0-9]*)[[:space:]]+MB[[:space:]]*s.*/\1/')
        fi
        
        # If still no match, try more flexible pattern
        if [ -z "$value" ] || [ "$value" = "$line" ]; then
            value=$(echo "$line" | sed -E 's/.*Throughput:[[:space:]]+([0-9]+\.?[0-9]*[eE]?[+-]?[0-9]*).*/\1/')
        fi
    fi
    
    # If "Throughput" not found, try "Average throughput" as fallback
    if [ -z "$value" ]; then
        line=$(echo "$output" | grep -Ei "^[[:space:]]*Average[[:space:]]+throughput:" | head -1)
        if [ -n "$line" ]; then
            value=$(echo "$line" | sed -E 's/.*Average[[:space:]]+throughput:[[:space:]]+([0-9]+\.?[0-9]*[eE]?[+-]?[0-9]*)[[:space:]]+MB.*/\1/i')
        fi
    fi
    
    # Convert scientific notation if present
    if [ -n "$value" ] && [[ "$value" =~ [eE] ]]; then
        value=$(echo "$value" | bc -l 2>/dev/null || echo "$value")
    fi
    
    echo "$value"
}

# Function to extract latency value from output
extract_latency() {
    local output="$1"
    local value=""
    
    # Look for "Total latency: X ns" pattern from the C++ code
    local line=$(echo "$output" | grep -E "^[[:space:]]*Total[[:space:]]+latency:" | head -1)
    
    if [ -n "$line" ]; then
        # Extract the numeric value followed by ns (including decimals and scientific notation)
        value=$(echo "$line" | sed -E 's/.*Total[[:space:]]+latency:[[:space:]]+([0-9]+\.?[0-9]*[eE]?[+-]?[0-9]*)[[:space:]]+ns.*/\1/')
        
        # The value is already in nanoseconds, no conversion needed
        if [ -z "$value" ] || [ "$value" = "$line" ]; then
            # Try alternative pattern
            value=$(echo "$line" | sed -E 's/.*Total[[:space:]]+latency:[[:space:]]+([0-9]+\.?[0-9]*[eE]?[+-]?[0-9]*).*/\1/')
        fi
        
        # Convert scientific notation if present
        if [[ "$value" =~ [eE] ]]; then
            value=$(echo "$value" | bc -l 2>/dev/null || echo "$value")
        fi
        
        # Convert to integer nanoseconds if it has decimal places
        if [[ "$value" =~ \. ]]; then
            value=$(echo "scale=0; $value / 1" | bc 2>/dev/null || echo "$value")
        fi
    fi
    
    # If "Total latency" not found, try "Average latency" as fallback
    if [ -z "$value" ]; then
        line=$(echo "$output" | grep -Ei "^[[:space:]]*Average[[:space:]]+latency:" | head -1)
        if [ -n "$line" ]; then
            value=$(echo "$line" | sed -E 's/.*Average[[:space:]]+latency:[[:space:]]+([0-9]+\.?[0-9]*[eE]?[+-]?[0-9]*)[[:space:]]*[μµum]?s?.*/\1/')
            
            # Check for unit conversions
            if echo "$line" | grep -E "[μµu]s" > /dev/null; then
                value=$(echo "scale=0; $value * 1000 / 1" | bc 2>/dev/null || echo "$value")
            elif echo "$line" | grep -q "ms"; then
                value=$(echo "scale=0; $value * 1000000 / 1" | bc 2>/dev/null || echo "$value")
            fi
            
            # Convert scientific notation if present
            if [[ "$value" =~ [eE] ]]; then
                value=$(echo "$value" | bc -l 2>/dev/null || echo "$value")
            fi
        fi
    fi
    
    echo "$value"
}

# Check minimum arguments - now requires at least 3
if [ $# -lt 3 ]; then
    usage
fi

# Required arguments
EXAMPLE_NAME="$1"
BITSTREAM_PATH="$2"
BASELINE_BASE="$3"

# Check if 4th argument is test size or an option
if [ $# -ge 4 ] && [[ "$4" =~ ^[0-9,]+$ ]]; then
    TEST_SIZE="$4"
    shift 4  # Skip the first four arguments
else
    TEST_SIZE="$DEFAULT_TEST_SIZE"
    shift 3  # Skip the first three arguments
fi

# Default values for options
VERBOSE=false
CSV_FILENAME="$DEFAULT_CSV_FILENAME"
SKIP_FPGA_PROG=false

# Parse optional arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --csv)
            if [ $# -lt 2 ]; then
                echo "Error: --csv requires a filename"
                usage
            fi
            CSV_FILENAME="$2"
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            ;;
        --skip-fpga-prog)
            SKIP_FPGA_PROG=true
            ;;
        *)
            echo "Error: Unknown argument: $1"
            usage
            ;;
    esac
    shift
done

# Convert paths to absolute
BASELINE_BASE=$(realpath "$BASELINE_BASE")
BITSTREAM_PATH=$(realpath "$BITSTREAM_PATH")

# Validate baseline base directory exists
if [ ! -d "$BASELINE_BASE" ]; then
    echo "Error: baseline base directory $BASELINE_BASE does not exist"
    exit 1
fi

# Validate bitstream file exists
if [ ! -f "$BITSTREAM_PATH" ]; then
    echo "Error: Bitstream file not found: $BITSTREAM_PATH"
    exit 1
fi

# Validate baseline base directory structure
if [ ! -d "$BASELINE_BASE/examples_sw" ] || [ ! -d "$BASELINE_BASE/driver" ] || [ ! -f "$BASELINE_BASE/program_fpga.sh" ]; then
    echo "Error: Invalid baseline base directory structure: $BASELINE_BASE"
    echo ""
    echo "Expected structure:"
    echo "  $BASELINE_BASE/examples_sw/     - Software examples directory"
    echo "  $BASELINE_BASE/driver/          - Driver directory with coyote_drv.ko"
    echo "  $BASELINE_BASE/program_fpga.sh  - FPGA programming script"
    echo ""
    exit 1
fi

# Display configuration
echo "=================================================="
echo "Hardware Test Configuration"
echo "=================================================="
echo "Example name: $EXAMPLE_NAME"
echo "Bitstream: $BITSTREAM_PATH"
echo "baseline base: $BASELINE_BASE"
echo "Test size(s): $TEST_SIZE"
echo "CSV output: $CSV_FILENAME"
echo "Verbose mode: $VERBOSE"
echo "Skip FPGA programming: $SKIP_FPGA_PROG"
echo "=================================================="

# Create evaluation data directory
EVAL_DIR="$BASELINE_BASE/evaluation/data"
mkdir -p "$EVAL_DIR"

# Define CSV file path
CSV_FILE="$EVAL_DIR/$CSV_FILENAME"

# Create CSV header if file doesn't exist
if [ ! -f "$CSV_FILE" ]; then
    echo "Creating new CSV file: $CSV_FILE"
    echo "example_name,data_size_bytes,throughput_MBps,latency_ns,timestamp" > "$CSV_FILE"
else
    echo "Appending to existing CSV file: $CSV_FILE"
fi

# Convert comma-separated test sizes to array
IFS=',' read -ra TEST_SIZES <<< "$TEST_SIZE"

# Step 1: Copy bitstream to standard location
echo ""
echo "Step 1: Setting up bitstream..."
mkdir -p "$BASELINE_BASE/bitstreams"
cp "$BITSTREAM_PATH" "$BASELINE_BASE/bitstreams/cyt_top.bit"

# Copy debug file if it exists in the same directory
LTX_FILE="${BITSTREAM_PATH%.bit}.ltx"
if [ -f "$LTX_FILE" ]; then
    cp "$LTX_FILE" "$BASELINE_BASE/bitstreams/cyt_top.ltx"
    echo "Bitstream and debug files copied successfully"
else
    echo "Bitstream copied successfully (no .ltx file found)"
fi

# Step 2: Setup environment (if vfpio.nix exists)
echo ""
echo "Step 2: Setting up environment..."
if [ -f "$BASELINE_BASE/vfpio.nix" ]; then
    cd "$BASELINE_BASE"
    nix-shell vfpio.nix --run "echo 'vFPIO environment ready'"
else
    echo "No vfpio.nix found in $BASELINE_BASE, skipping environment setup"
fi

# Step 3: Configure hugepages
echo ""
echo "Step 3: Configuring hugepages..."
sudo sysctl -w vm.nr_hugepages=1024
echo "Hugepages configured"

# Step 4: Load driver
echo ""
echo "Step 4: Loading baseline driver..."
cd "$BASELINE_BASE/driver/"

if [ ! -f "coyote_drv.ko" ]; then
    echo "Error: Driver module coyote_drv.ko not found"
    echo "Please build the driver first"
    exit 1
fi

# Remove driver if already loaded
sudo rmmod coyote_drv 2>/dev/null || true
sudo insmod coyote_drv.ko
echo "Driver loaded successfully"

# Step 5: Program FPGA with bitstream
if [ "$SKIP_FPGA_PROG" = false ]; then
    echo ""
    echo "Step 5: Programming FPGA..."
    
    cd "$BASELINE_BASE"
    bash ./program_fpga.sh cyt_top
    if [ $? -ne 0 ]; then
        echo "Error: FPGA programming failed"
        exit 1
    fi
    echo "FPGA programmed successfully"
else
    echo ""
    echo "Step 5: Skipping FPGA programming (--skip-fpga-prog specified)"
fi

# Step 6: Build software once
echo ""
echo "Step 6: Building software..."
cd "$BASELINE_BASE/examples_sw/"

# Clean up any existing build directory
rm -rf "${EXAMPLE_NAME}_test"
mkdir "${EXAMPLE_NAME}_test"
cd "${EXAMPLE_NAME}_test"

# Build the software example
echo "Building software for $EXAMPLE_NAME..."
cmake ../ -DEXAMPLE="$EXAMPLE_NAME"
make

# Check if test executable exists
if [ ! -f "bin/test" ]; then
    echo "Error: Test executable not found after build"
    exit 1
fi

# Step 7: Run tests for each size
echo ""
echo "Step 7: Running effectiveness tests..."

# Navigate to bin directory for tests
cd bin

# Function to run test with optional timeout
run_test() {
    local test_size=$1
    local test_output=""
    
    # Run test with 5-minute timeout
    if command -v timeout &> /dev/null; then
        test_output=$(timeout 300 ./test -s "$test_size" 2>&1 | tee /dev/tty)
        if [ ${PIPESTATUS[0]} -eq 124 ]; then
            echo "Error: Test timed out after 5 minutes"
            return 1
        fi
    else
        test_output=$(./test -s "$test_size" 2>&1 | tee /dev/tty)
    fi
    
    echo "$test_output"
    return 0
}

# Loop through all test sizes
TEST_NUMBER=0
TOTAL_TESTS=${#TEST_SIZES[@]}
SUCCESSFUL_TESTS=0

for CURRENT_TEST_SIZE in "${TEST_SIZES[@]}"; do
    # Trim whitespace from test size
    CURRENT_TEST_SIZE=$(echo "$CURRENT_TEST_SIZE" | xargs)
    
    # Validate test size is a number
    if ! [[ "$CURRENT_TEST_SIZE" =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid test size: $CURRENT_TEST_SIZE (must be a positive integer)"
        continue
    fi
    
    TEST_NUMBER=$((TEST_NUMBER + 1))
    
    echo ""
    echo "=================================================="
    echo "Test $TEST_NUMBER of $TOTAL_TESTS: Data size = $CURRENT_TEST_SIZE bytes"
    echo "=================================================="

    # Run the test and capture output
    TEST_OUTPUT=$(run_test "$CURRENT_TEST_SIZE")
    if [ $? -ne 0 ]; then
        echo "Test failed, skipping to next size..."
        continue
    fi

    # Extract throughput and latency from output
    echo ""
    echo "Parsing test results..."

    # Debug: Show effectiveness section if verbose
    if [ "$VERBOSE" = true ]; then
        echo ""
        echo "=== DEBUG: effectiveness metrics search ==="
        echo "Total latency lines:"
        echo "$TEST_OUTPUT" | grep -i "total latency" || echo "  None found"
        echo ""
        echo "Throughput lines:"
        echo "$TEST_OUTPUT" | grep -i "throughput" || echo "  None found"
        echo "=== END DEBUG ==="
    fi

    THROUGHPUT=$(extract_throughput "$TEST_OUTPUT")
    LATENCY=$(extract_latency "$TEST_OUTPUT")

    # Display extracted values
    echo "Extracted values:"
    echo "  Throughput: ${THROUGHPUT:-N/A} MB/s"
    echo "  Latency: ${LATENCY:-N/A} ns"

    # Validate extracted values
    if [ -n "$THROUGHPUT" ]; then
        if ! [[ "$THROUGHPUT" =~ ^[0-9]+\.?[0-9]*$ ]]; then
            echo "Warning: Invalid throughput value: $THROUGHPUT"
            THROUGHPUT=""
        elif (( $(echo "$THROUGHPUT > 100000" | bc -l) )); then
            echo "Warning: Unusually high throughput: $THROUGHPUT MB/s"
        fi
    fi

    if [ -n "$LATENCY" ]; then
        if ! [[ "$LATENCY" =~ ^[0-9]+\.?[0-9]*$ ]]; then
            echo "Warning: Invalid latency value: $LATENCY"
            LATENCY=""
        elif (( $(echo "$LATENCY > 1000000000000" | bc -l) )); then
            echo "Warning: Unusually high latency: $LATENCY ns (> 1 second)"
        fi
    fi

    # Get current timestamp
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    # Append data to CSV
    if [ -n "$THROUGHPUT" ] && [ -n "$LATENCY" ]; then
        echo "$EXAMPLE_NAME,$CURRENT_TEST_SIZE,$THROUGHPUT,$LATENCY,$TIMESTAMP" >> "$CSV_FILE"
        echo "Results saved to CSV"
        SUCCESSFUL_TESTS=$((SUCCESSFUL_TESTS + 1))
    else
        echo "Warning: Could not extract effectiveness metrics"
        # Save with N/A values
        THROUGHPUT=${THROUGHPUT:-"N/A"}
        LATENCY=${LATENCY:-"N/A"}
        echo "$EXAMPLE_NAME,$CURRENT_TEST_SIZE,$THROUGHPUT,$LATENCY,$TIMESTAMP" >> "$CSV_FILE"
        
        # Create debug file
        if [ "$VERBOSE" = true ]; then
            DEBUG_FILE="$EVAL_DIR/${EXAMPLE_NAME}_${CURRENT_TEST_SIZE}_$(date '+%Y%m%d_%H%M%S').debug"
            echo "$TEST_OUTPUT" > "$DEBUG_FILE"
            echo "Debug output saved to: $DEBUG_FILE"
        fi
    fi

    # Save full log
    LOG_FILE="$EVAL_DIR/${EXAMPLE_NAME}_${CURRENT_TEST_SIZE}_$(date '+%Y%m%d_%H%M%S').log"
    echo "$TEST_OUTPUT" > "$LOG_FILE"
    echo "Full log saved to: $LOG_FILE"
done

# Final summary
echo ""
echo "=================================================="
echo "Testing Complete!"
echo "=================================================="
echo "Example: $EXAMPLE_NAME"
echo "Total tests run: $TEST_NUMBER"
echo "Successful extractions: $SUCCESSFUL_TESTS"
echo "Results saved to: $CSV_FILE"
echo "=================================================="

# Display results summary if available
if [ -f "$CSV_FILE" ] && [ $SUCCESSFUL_TESTS -gt 0 ]; then
    echo ""
    echo "effectiveness Summary:"
    echo "-------------------"
    tail -n +2 "$CSV_FILE" | grep "^$EXAMPLE_NAME," | tail -n "$TEST_NUMBER" | \
    awk -F',' 'BEGIN {printf "%-12s %-15s %-15s\n", "Size (bytes)", "Throughput (MB/s)", "Latency (ns)"} 
                     {printf "%-12s %-15s %-15s\n", $2, $3, $4}'
    echo "=================================================="
fi

# Usage examples:
# From baseline base directory:
# ./compile_effectiveness_sw.sh fft examples_hw/fft/bitstreams/cyt_top.bit . 65536
# ./compile_effectiveness_sw.sh aes_ctr ./my_bitstream.bit . 1048576
#
# From another directory:
# ./compile_effectiveness_sw.sh rsa /path/to/bitstream.bit /path/to/baseline
# ./compile_effectiveness_sw.sh sha256 /home/user/bitstreams/sha256.bit /scratch/user/baseline 32768
#
# With options:
# ./compile_effectiveness_sw.sh fft ./fft.bit /path/to/baseline 32768,65536 --csv fft_sweep.csv --verbose