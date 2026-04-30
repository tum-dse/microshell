# µShell: A Microkernel-based FPGA Shell Architecture

## Overview

µShell is a hardware/OS co-design for modular accelerator deployment. Inspired
by the microkernel principle, individual hardware modules (FFT, RSA, AES, …)
are deployed into separate vFPGAs and dynamically chained together by a
host-side dataflow graph (DFG) API to compose end-to-end accelerators.

This repo contains the µShell shell, runtime, driver, example modules, and the
end-to-end applications used in the paper. The accompanying baseline (the same
applications written against an unmodified Coyote shell) lives at
[TUM-DSE/microShell, branch `baseline`](https://github.com/TUM-DSE/microShell/tree/baseline).

## Main Results

<div align="center">
  <img src="evaluation/plots/e2e.png" width="95%"/>
  <br/>
  <em>End-to-end throughput across the five composed applications, baseline vs. µShell.</em>
</div>

<br/>

<div align="center">
  <img src="evaluation/plots/sched.png" width="95%"/>
  <br/>
  <em>Scheduler comparison: latency, response time, deadline misses, reconfiguration cost across two policies.</em>
</div>

<br/>

<div align="center">
  <img src="evaluation/plots/reconfig_overhead.png" width="50%"/>
  <br/>
  <em>Partial reconfiguration latency breakdown for vFPGA module swaps.</em>
</div>

# Reproduce paper results

```bash
git clone git@github.com:TUM-DSE/microShell.git microShell
cd microShell
```

## Specs

### Software

- Operating system: Linux 6.9.0-rc7 / NixOS 23.11
- [Nix](https://nixos.org/download.html): all build dependencies are pinned via
  `shell.nix` (host-side build/run) and `xilinx-shell` (Vivado toolchain)
- Python ≥ 3.11 for the plot scripts under `evaluation/scripts/`

### Hardware

- AMD EPYC 7413 CPU × 2
- Xilinx Alveo U280 FPGA × 2
- 100 GbE FPGA-attached NIC
- Bitstream generation (Vivado) and FPGA tests can run on the same host or be
  split across a build host and an FPGA host to keep Vivado off the test path.

## Getting Started Instructions

A "Hello World"-equivalent run using `perf_local` — the smallest end-to-end
test, a host loop across two vFPGAs.

### Building the FPGA driver

```bash
nix-shell -p gcc14 gnumake
cd driver
make KERNELDIR=$(nix-build -E '(import <nixpkgs> {}).linuxPackages_6_8.kernel.dev' --no-out-link)/lib/modules/*/build M=$(pwd)
```

A pre-compiled driver is also shipped with this repo if you want to skip the
build.

### Obtaining an FPGA bitstream

Vivado bitstream generation takes 3–4 hours per design. Pre-built bitstreams
for every `EXAMPLE` target live under [`bitstreams/`](bitstreams/), one folder
per target — see [Pre-built bitstreams](#pre-built-bitstreams-fallback) below.

Do not change the path or filename of `bitstreams/cyt_top.bit`;
`program_fpga.sh` looks for it there.

### Compiling perf_local software

```bash
nix-shell shell.nix
cd examples_sw && mkdir build_perf_local && cd build_perf_local
cmake ../ -DEXAMPLE=perf_local
make
```

Set up hugepages for the host application:

```bash
sudo sysctl -w vm.nr_hugepages=1024
```

### Running the test

```bash
# from the repo root, with bitstreams/cyt_top.bit in place
sudo bash ./program_fpga.sh cyt_top
cd examples_sw/build_perf_local/bin
./test
```

This runs the perf_local host application and reports average throughput.

# Detailed Instructions

## Compilation

### Hardware

```bash
xilinx-shell
cd examples_hw && mkdir build_<example> && cd build_<example>
cmake ../ -DEXAMPLE=<name> -DFDEV_NAME=u280
make project
make bitgen     # 3-4 h on U280
```

Available `EXAMPLE` targets: see [examples_hw/CMakeLists.txt](examples_hw/CMakeLists.txt).
Composed apps: `audio_processing`, `digital_signature`, `secure_storage`,
`signed_compression`, `speech_recognition` (each with a `_monolithic` variant).
Single modules: `aes_ctr`, `fft`, `quantize`, `rle`, `rsa`, `sha256`, `svm`.

### Software

```bash
nix-shell shell.nix
cd examples_sw && mkdir build_<example> && cd build_<example>
cmake ../ -DEXAMPLE=<name>
make
./bin/test                    # default size
./bin/test -s 1048576         # 1 MB transfer
```

Available SW `EXAMPLE` targets: see [examples_sw/CMakeLists.txt](examples_sw/CMakeLists.txt).

## Pre-built bitstreams (fallback)

If a Vivado run fails or you want to skip the 3–4 h bitgen step, the
[`bitstreams/`](bitstreams/) directory holds known-good bitstreams from the
paper run, organised one folder per `EXAMPLE` target:

```
bitstreams/
├── audio_processing/{cyt_top.bit, cyt_top.ltx}
├── audio_processing_monolithic/...
├── digital_signature/...
├── ...
├── perf_local/...
├── aes_ctr/  fft/  quantize/  rle/  rsa/  sha256/  svm/
└── static/
```

Copy the matching pair into the load path that `program_fpga.sh` expects, then
program the FPGA:

```bash
cp bitstreams/<example>/cyt_top.bit bitstreams/cyt_top.bit
cp bitstreams/<example>/cyt_top.ltx bitstreams/cyt_top.ltx   # if present
sudo bash ./program_fpga.sh cyt_top
```

The `compile_sw_*.sh` scripts under [`evaluation/scripts/`](evaluation/scripts/)
already take an explicit bitstream path as their second argument, so you can
point them straight at `bitstreams/<example>/cyt_top.bit` without copying.

## Running experiments

Each evaluation section has a dedicated script (or pair of scripts) that
produces a plot under `evaluation/plots/`. The full step-by-step instructions
live in [`evaluation/scripts/README.md`](evaluation/scripts/README.md).

### End-to-End Performance Overhead

```bash
cd evaluation/scripts
bash ./compile_hw_ushell.sh   /path/to/microShell
bash ./compile_hw_baseline.sh /path/to/baseline
./compile_sw_ushell.sh   <app> <bitstream> /path/to/microShell
./compile_sw_baseline.sh <app> <bitstream> /path/to/baseline
python3 plot_e2e.py
```

Output: `evaluation/plots/e2e.{png,pdf}`.

### Programmability

```bash
bash ./measure_complexity_baseline.sh /path/to/baseline
bash ./measure_complexity_ushell.sh   /path/to/microShell
python3 plot_app_modularity.py
```

Output: `evaluation/plots/application_modularity_analysis.{pdf,png}`.

### Scalability

```bash
bash ./compile_scalability.sh /path/to/baseline
# Open <n>vfpga/checkpoints/shell_routed.dcp in Vivado, source extract_util.tcl
python3 plot_scalability.py
```

Output: `evaluation/plots/plot_scalability_analysis.{pdf,png}`.

### FPGA Acceleration Effectiveness

```bash
bash ./compile_effectiveness_hw.sh /path/to/baseline
./compile_effectiveness_sw.sh fft     <bitstream> /path/to/baseline
./compile_effectiveness_sw.sh quantize <bitstream> /path/to/baseline
# ...repeat for: rle, aes_ctr, rsa, sha256, svm
python3 plot_effectiveness.py
```

Output: `evaluation/plots/direct_comm_effectiveness.pdf`.

### Scheduling Improvements

```bash
# Data is collected by examples_sw/apps/scheduler; CSVs land in evaluation/data/
python3 plot_sched.py
python3 plot_reconfig_overhead.py
python3 plot_reconf_analysis.py
```

Output: `evaluation/plots/sched.{png,pdf}`, `reconfig_overhead.{png,pdf}`, `reconf_analysis.pdf`.

## Artifact Claims

All figures in the evaluation section are reproducible with the commands
above. Numbers may differ slightly from the paper run depending on system
state (driver version, FPGA temperature, hugepage availability).

## Potential Issues

- **Driver won't load** — `sudo rmmod coyote_drv && sudo insmod driver/coyote_drv.ko`. If that fails, reboot and retry; stuck driver state usually clears.
- **FPGA programming fails** — verify `bitstreams/cyt_top.bit` exists before running `program_fpga.sh`. Check `sudo dmesg | tail -50` for PCIe / programming errors.
- **Hugepage shortage** — `cat /proc/sys/vm/nr_hugepages` should be ≥ 1024. Re-run the `sysctl` command if the number resets after reboot.
- **Test process hangs** — `sudo pkill -9 test`, then re-program the FPGA before retrying.

## Repository layout

```
microShell/
├── examples_hw/apps/         # HW pipelines (audio_processing, digital_signature, ...)
│   └── modules/              #   single-module bring-ups (fft, rsa, sha256, ...)
├── examples_sw/apps/         # Host programs, mirrors examples_hw
│   ├── *_monolithic/         #   single-binary versions for the µShell baseline
│   └── modules/              #   per-module test programs
├── sw/{include,src}/         # µShell runtime: DFG, Pipeline, Buffer, ushell::*
├── driver/                   # Linux kernel driver (Coyote-derived)
├── bitstreams/               # Pre-built .bit / .ltx, one folder per EXAMPLE target
├── evaluation/{scripts,data,plots}
├── program_fpga.sh           # Load bitstream + driver + hugepages
└── shell.nix                 # Reproducible build environment
```

## License

MIT — see [LICENSE.md](LICENSE.md). Portions derived from
[Coyote](https://github.com/fpgasystems/Coyote) under BSD-3-Clause; original
copyright headers retained per file.

## Citation

```bibtex
@inproceedings{ushell,
  title  = {{µShell}: A Microkernel-based FPGA Shell Architecture},
  author = {TBD},
  year   = {TBD},
  note   = {Citation pending publication.}
}
```
