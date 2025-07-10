#!/bin/bash

# Hardware loading and testing script
# This script loads a built bitstream and runs tests on it

set -e  # Exit on any error

# Function to display usage
usage() {
    echo "Usage: $0 <example_name> <coyote_base_dir> [test_size]"
    echo ""
    echo "Arguments:"
    echo "  example_name     - Name of the example (e.g., digi_sign, audio, secure, etc.)"
    echo "  coyote_base_dir  - Path to Coyote base directory"
    echo "  test_size        - Optional: Test size parameter (default: 65536)"
    echo ""
    exit 1
}

# Check arguments
if [ $# -lt 2 ]; then
    usage
fi

EXAMPLE_NAME="$1"
COYOTE_BASE="$2"
TEST_SIZE="${3:-65536}"  # Default to 65536 if not provided

# Validate directories exist
if [ ! -d "$COYOTE_BASE" ]; then
    echo "Error: Coyote base directory $COYOTE_BASE does not exist"
    exit 1
fi

if [ ! -d "$COYOTE_BASE/examples_hw/$EXAMPLE_NAME" ]; then
    echo "Error: Example directory $COYOTE_BASE/examples_hw/$EXAMPLE_NAME does not exist"
    echo "Make sure the hardware has been built first"
    exit 1
fi

echo "Loading and testing hardware example: $EXAMPLE_NAME"
echo "Coyote base directory: $COYOTE_BASE"
echo "Test size: $TEST_SIZE"
echo "=================================================="

# Step 1: Copy bitstream to bitstreams directory
echo "Step 1: Copying bitstream and debug files..."
cd "$COYOTE_BASE/examples_hw/$EXAMPLE_NAME/bitstreams"
if [ ! -f "cyt_top.bit" ]; then
    echo "Error: Bitstream file cyt_top.bit not found in $COYOTE_BASE/examples_hw/$EXAMPLE_NAME/bitstreams/"
    echo "Make sure the hardware build completed successfully"
    exit 1
fi

mkdir -p "$COYOTE_BASE/bitstreams"
cp cyt_top.bit "$COYOTE_BASE/bitstreams/"

# Copy the debug file if it exists
if [ -f "cyt_top.ltx" ]; then
    cp cyt_top.ltx "$COYOTE_BASE/bitstreams/"
    echo "Bitstream and debug files copied successfully"
else
    echo "Warning: cyt_top.ltx not found, copying bitstream only"
    echo "Bitstream copied successfully"
fi

# Step 2: Setup vFPIO environment
echo "Step 2: Setting up vFPIO environment..."
cd /scratch/anubhav/vFPIO/
nix-shell vfpio.nix --run "echo 'vFPIO environment ready'"

# Step 3: Configure hugepages
echo "Step 3: Configuring hugepages..."
sudo sysctl -w vm.nr_hugepages=1024
echo "Hugepages configured"

# Step 4: Load driver
echo "Step 4: Loading Coyote driver..."
cd "$COYOTE_BASE/driver/"
if [ ! -f "coyote_drv.ko" ]; then
    echo "Error: Driver module coyote_drv.ko not found"
    exit 1
fi

# Remove driver if already loaded
sudo rmmod coyote_drv 2>/dev/null || true
sudo insmod coyote_drv.ko
echo "Driver loaded successfully"

# Step 5: Program FPGA with bitstream
echo "Step 5: Programming FPGA..."
cd "$COYOTE_BASE"
if [ ! -f "program_fpga.sh" ]; then
    echo "Error: program_fpga.sh script not found"
    exit 1
fi

bash ./program_fpga.sh cyt_top
echo "FPGA programmed successfully"

# Step 6: Build and run software test
echo "Step 6: Building and running software test..."
cd "$COYOTE_BASE/examples_sw/"

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

echo "Running basic test..."
./test

echo "Running test with size parameter: $TEST_SIZE"
./test -s "$TEST_SIZE"

echo ""
echo "=================================================="
echo "Hardware loading and testing completed successfully!"
echo "Example: $EXAMPLE_NAME"
echo "Test size: $TEST_SIZE"
echo "=================================================="