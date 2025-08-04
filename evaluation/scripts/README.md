# Evaluation

This document provides instructions for running various evaluation tests including performance overhead analysis, scalability analysis, and programmability measurements.

## End-to-End Performance Overhead

### Step 1: Generate Bitstreams for µShell and µShell_mono

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
