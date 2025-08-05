#!/bin/bash
# Hardware loading and testing script with performance metrics extraction
# This script loads a built bitstream and runs tests on it
set -e # Exit on any error

# Configuration
DEFAULT_TEST_SIZE="1048576"  # Default 1MB
CSV_FILENAME="e2e_ushell_results.csv"

# Check for bc
if ! command -v bc &> /dev/null; then
    echo "Error: 'bc' not found. Install with: sudo apt-get install bc"
    exit 1
fi

# Function to display usage
usage() {
    echo "Usage: $0 <example_name> <bitstream_path> <ushell_base_dir> [test_size]"
    echo ""
    echo "Arguments:"
    echo "  example_name      - Name of the example (e.g., digi_sign, audio, secure, etc.)"
    echo "  bitstream_path    - Path to the bitstream file (.bit)"
    echo "  ushell_base_dir   - Path to ushell base directory"
    echo "  test_size         - Optional: Test size parameter (default: $DEFAULT_TEST_SIZE)"
    echo ""
    echo "Examples:"
    echo "  # From ushell base directory:"
    echo "  $0 audio examples_hw/audio/bitstreams/cyt_top.bit /path/to/ushell 65536"
    echo ""
    echo "  # From another directory:"
    echo "  $0 digi_sign /home/user/my_bitstream.bit /path/to/ushell"
    echo ""
    echo "  # With absolute path:"
    echo "  $0 secure /scratch/user/bitstreams/secure.bit /scratch/user/ushell 1048576"
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
        value=$(echo "$line" | sed -E 's/.*Throughput:[[:space:]]+([0-9]+\.?[0-9]*)[[:space:]]+MB\/s.*/\1/')
        
        # Try without slash if failed
        if [ -z "$value" ] || [ "$value" = "$line" ]; then
            value=$(echo "$line" | sed -E 's/.*Throughput:[[:space:]]+([0-9]+\.?[0-9]*)[[:space:]]+MB[[:space:]]*s.*/\1/')
        fi
        
        # Try more flexible pattern
        if [ -z "$value" ] || [ "$value" = "$line" ]; then
            value=$(echo "$line" | sed -E 's/.*Throughput:[[:space:]]+([0-9]+\.?[0-9]*).*/\1/')
        fi
    fi
    
    echo "$value"
}

# Function to extract latency value from output
extract_latency() {
    local output="$1"
    local value=""
    
    # Look for "Total latency: X ns" pattern
    local line=$(echo "$output" | grep -E "^[[:space:]]*Total[[:space:]]+latency:" | head -1)
    
    if [ -n "$line" ]; then
        value=$(echo "$line" | sed -E 's/.*Total[[:space:]]+latency:[[:space:]]+([0-9]+\.?[0-9]*)[[:space:]]+ns.*/\1/')
        
        # Try alternative pattern
        if [ -z "$value" ] || [ "$value" = "$line" ]; then
            value=$(echo "$line" | sed -E 's/.*Total[[:space:]]+latency:[[:space:]]+([0-9]+\.?[0-9]*).*/\1/')
        fi
        
        # Convert to integer if decimal
        if [[ "$value" =~ \. ]]; then
            value=$(echo "scale=0; $value / 1" | bc 2>/dev/null || echo "$value")
        fi
    fi
    
    # Try "Average latency" as fallback
    if [ -z "$value" ]; then
        line=$(echo "$output" | grep -Ei "^[[:space:]]*Average[[:space:]]+latency:" | head -1)
        if [ -n "$line" ]; then
            value=$(echo "$line" | sed -E 's/.*Average[[:space:]]+latency:[[:space:]]+([0-9]+\.?[0-9]*)[[:space:]]*[μµum]?s?.*/\1/')
            
            # Convert μs to ns
            if echo "$line" | grep -E "[μµu]s" > /dev/null; then
                value=$(echo "scale=0; $value * 1000 / 1" | bc 2>/dev/null || echo "$value")
            elif echo "$line" | grep -q "ms"; then
                value=$(echo "scale=0; $value * 1000000 / 1" | bc 2>/dev/null || echo "$value")
            fi
        fi
    fi
    
    echo "$value"
}

# Check arguments - now requires at least 3
if [ $# -lt 3 ]; then
    usage
fi

# Required arguments
EXAMPLE_NAME="$1"
BITSTREAM_PATH="$2"
USHELL_BASE="$3"
TEST_SIZE="${4:-$DEFAULT_TEST_SIZE}"

# Convert paths to absolute
USHELL_BASE=$(realpath "$USHELL_BASE")
BITSTREAM_PATH=$(realpath "$BITSTREAM_PATH")

# Validate ushell base directory exists
if [ ! -d "$USHELL_BASE" ]; then
    echo "Error: ushell base directory $USHELL_BASE does not exist"
    exit 1
fi

# Validate bitstream file exists
if [ ! -f "$BITSTREAM_PATH" ]; then
    echo "Error: Bitstream file not found: $BITSTREAM_PATH"
    exit 1
fi

# Validate ushell base directory structure
if [ ! -d "$USHELL_BASE/examples_sw" ] || [ ! -d "$USHELL_BASE/driver" ] || [ ! -f "$USHELL_BASE/program_fpga.sh" ]; then
    echo "Error: Invalid ushell base directory structure: $USHELL_BASE"
    echo ""
    echo "Expected structure:"
    echo "  $USHELL_BASE/examples_sw/     - Software examples directory"
    echo "  $USHELL_BASE/driver/          - Driver directory with coyote_drv.ko"
    echo "  $USHELL_BASE/program_fpga.sh  - FPGA programming script"
    echo ""
    exit 1
fi

echo "=================================================="
echo "Hardware Test Configuration"
echo "=================================================="
echo "Example name: $EXAMPLE_NAME"
echo "Bitstream: $BITSTREAM_PATH"
echo "ushell base: $USHELL_BASE"
echo "Test size: $TEST_SIZE bytes"
echo "=================================================="

# Create evaluation data directory
EVAL_DIR="$USHELL_BASE/evaluation/data"
mkdir -p "$EVAL_DIR"
CSV_FILE="$EVAL_DIR/$CSV_FILENAME"

# Create CSV header if file doesn't exist
if [ ! -f "$CSV_FILE" ]; then
    echo "Creating new CSV file: $CSV_FILE"
    echo "example_name,data_size_bytes,throughput_MBps,latency_ns,timestamp" > "$CSV_FILE"
fi

# Step 1: Copy bitstream to standard location
echo ""
echo "Step 1: Setting up bitstream..."
mkdir -p "$USHELL_BASE/bitstreams"
cp "$BITSTREAM_PATH" "$USHELL_BASE/bitstreams/cyt_top.bit"

# Copy debug file if it exists in the same directory
LTX_FILE="${BITSTREAM_PATH%.bit}.ltx"
if [ -f "$LTX_FILE" ]; then
    cp "$LTX_FILE" "$USHELL_BASE/bitstreams/cyt_top.ltx"
    echo "Bitstream and debug files copied successfully"
else
    echo "Bitstream copied successfully (no .ltx file found)"
fi

# Step 2: Setup vFPIO environment
echo ""
echo "Step 2: Setting up vFPIO environment..."
if [ -f "$USHELL_BASE/vfpio.nix" ]; then
    cd "$USHELL_BASE"
    nix-shell vfpio.nix --run "echo 'vFPIO environment ready'"
else
    echo "No vfpio.nix found, skipping environment setup"
fi

# Step 3: Configure hugepages
echo ""
echo "Step 3: Configuring hugepages..."
sudo sysctl -w vm.nr_hugepages=1024
echo "Hugepages configured"

# Step 4: Load driver
echo ""
echo "Step 4: Loading ushell driver..."
cd "$USHELL_BASE/driver/"

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
echo ""
echo "Step 5: Programming FPGA..."
cd "$USHELL_BASE"

if [ ! -f "program_fpga.sh" ]; then
    echo "Error: program_fpga.sh script not found"
    exit 1
fi

bash ./program_fpga.sh cyt_top
if [ $? -ne 0 ]; then
    echo "Error: FPGA programming failed"
    exit 1
fi
echo "FPGA programmed successfully"

# Step 6: Build and run software test
echo ""
echo "Step 6: Building and running software test..."
cd "$USHELL_BASE/examples_sw/"

# Clean up any existing build directory
rm -rf "${EXAMPLE_NAME}_test"
mkdir "${EXAMPLE_NAME}_test"
cd "${EXAMPLE_NAME}_test"

# Build the software example
echo "Building software for $EXAMPLE_NAME..."
cmake ../ -DEXAMPLE="$EXAMPLE_NAME"
make

# Navigate to bin directory and run tests
cd bin

if [ ! -f "./test" ]; then
    echo "Error: Test executable not found"
    exit 1
fi

echo ""
echo "Running test with size: $TEST_SIZE bytes..."
echo "=================================================="

# Run test and capture output
TEST_OUTPUT=$(./test -s "$TEST_SIZE" 2>&1 | tee /dev/tty)

# Extract throughput and latency
echo ""
echo "Parsing test results..."

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
    fi
fi

if [ -n "$LATENCY" ]; then
    if ! [[ "$LATENCY" =~ ^[0-9]+\.?[0-9]*$ ]]; then
        echo "Warning: Invalid latency value: $LATENCY"
        LATENCY=""
    fi
fi

# Get timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Append to CSV
if [ -n "$THROUGHPUT" ] && [ -n "$LATENCY" ]; then
    echo "$EXAMPLE_NAME,$TEST_SIZE,$THROUGHPUT,$LATENCY,$TIMESTAMP" >> "$CSV_FILE"
    echo "Results saved to: $CSV_FILE"
else
    echo "Warning: Could not extract performance metrics"
    # Save with N/A values
    THROUGHPUT=${THROUGHPUT:-"N/A"}
    LATENCY=${LATENCY:-"N/A"}
    echo "$EXAMPLE_NAME,$TEST_SIZE,$THROUGHPUT,$LATENCY,$TIMESTAMP" >> "$CSV_FILE"
fi

# Save full log
LOG_FILE="$EVAL_DIR/${EXAMPLE_NAME}_${TEST_SIZE}_$(date '+%Y%m%d_%H%M%S').log"
echo "$TEST_OUTPUT" > "$LOG_FILE"
echo "Full log saved to: $LOG_FILE"

echo ""
echo "=================================================="
echo "Hardware loading and testing completed successfully!"
echo "Example: $EXAMPLE_NAME"
echo "Test size: $TEST_SIZE bytes"
echo "Throughput: ${THROUGHPUT:-N/A} MB/s"
echo "Latency: ${LATENCY:-N/A} ns"
echo "Results saved to: $CSV_FILE"
echo "=================================================="

# Usage examples:
# From ushell base directory:
# ./hw_test.sh audio examples_hw/audio/bitstreams/cyt_top.bit . 65536
# ./hw_test.sh digi_sign ./my_bitstream.bit . 1048576
#
# From another directory:
# ./hw_test.sh secure /path/to/bitstream.bit /path/to/ushell
# ./hw_test.sh signcomp /home/user/bitstreams/signcomp.bit /scratch/user/ushell 32768