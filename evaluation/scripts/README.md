# Evaluation

This document provides instructions for running various evaluation tests including performance overhead analysis, scalability analysis, and programmability measurements.

## End-to-End Performance Overhead

### Step 1: Generate Bitstreams for Baseline

Run the following commands to compile and generate bitstreams:

```bash
bash ./compile_hw.sh
```
### Step 3: Run Tests to get Evaluation Data

Run the following commands to run software tests (at 1MB) on generated bitstreams:

```bash
bash ./compile_sw.sh -p {$PROJ_NAME}
```

You can also run tests at different sizes and number of repetitions by controlling the -s (size in bytes) and -r (repetitions) parameters

#### Example

```bash
./test -s 65536 -r 10
```

## Programmability

To measure code complexity and programmability metrics:

```bash
cd evaluation/scripts
bash ./measure_complexity.sh
```

## Scalability Analysis

### Step 1: Generate Bitstreams

Run the following commands to compile and generate bitstreams:

```bash
cd evaluation/scripts
bash ./compile_scalability.sh
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

## FPGA Acceleration Effectiveness Analysis

### Step 1: Generate Bitstreams for Individual Components

Run the following commands to compile and generate bitstreams:

```bash
cd evaluation/scripts
bash ./compile_effectiveness_hw.sh
```

### Step 2: Generate Bitstreams for Baseline

Run the following commands to compile and generate bitstreams:

```bash
bash ./compile_hw.sh
```

If already generated, skip this step

### Step 3: Run Tests to get Evaluation Data

Run the following commands to run software tests (at 1MB) on generated bitstreams:

```bash
bash ./compile_effectiveness_sw.sh -p {$PROJ_NAME}
```

You can also run tests at different sizes and number of repetitions by controlling the -s (size in bytes) and -r (repetitions) parameters

#### Example

```bash
./test -s 65536 -r 10
```
