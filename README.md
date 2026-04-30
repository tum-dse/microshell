# µShell — Baseline (stock Coyote shell)

## Overview

This is the **baseline** branch of the µShell artifact: the same five
end-to-end applications (audio processing, digital signature, secure storage,
signed compression, speech recognition) ported to run on an unmodified
[Coyote](https://github.com/fpgasystems/Coyote) FPGA shell. It is the
comparison point used in the µShell paper.

The µShell side of the comparison — the microkernel-style shell with the DFG
runtime, the modular vFPGA composition, and the evaluation pipeline — lives at
[TUM-DSE/microShell, branch `master`](https://github.com/TUM-DSE/microShell).

This repo is intentionally minimal: it ships only what's needed to build and
run the baseline applications. Evaluation scripts, plots, and aggregated data
live in the µShell repo.

# Reproduce baseline numbers

```bash
git clone -b baseline git@github.com:TUM-DSE/microShell.git microShell-baseline
cd microShell-baseline
```

## Specs

### Software

- Operating system: Linux 6.9.0-rc7 / NixOS 23.11
- [Nix](https://nixos.org/download.html): all build dependencies are pinned via
  `shell.nix` (host-side build/run) and `xilinx-shell` (Vivado toolchain)
- Vivado 2022.x for bitstream generation

### Hardware

- AMD EPYC 7413 CPU × 2
- Xilinx Alveo U280 FPGA × 2
- 100 GbE FPGA-attached NIC
- Bitstream generation (Vivado) and FPGA tests can run on the same host or be
  split across a build host and an FPGA host to keep Vivado off the test path.

## Getting Started Instructions

A "Hello World"-equivalent run using `perf_local`.

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

Available `EXAMPLE` targets — see [examples_hw/CMakeLists.txt](examples_hw/CMakeLists.txt):

- Composed apps: `audio_processing`, `digital_signature`, `secure_storage`, `signed_compression`, `speech_recognition`
- Single modules: `aes_ctr`, `fft`, `quantize`, `rle`, `rsa`, `sha256`, `svm`
- Scalability: `1vfpga`, `2vfpga`, `4vfpga`, `8vfpga`
- Other: `perf_local`, `perf_fpga`, `static`

The baseline does **not** include the `_monolithic` variants; those only exist
on the µShell side as the single-binary point of comparison.

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
├── digital_signature/...
├── secure_storage/...
├── signed_compression/...
├── speech_recognition/...
├── aes_ctr/  fft/  quantize/  rle/  rsa/  sha256/  svm/
├── 1vfpga/  2vfpga/  4vfpga/  8vfpga/
├── perf_local/  perf_fpga/
└── static/
```

Copy the matching pair into the load path that `program_fpga.sh` expects, then
program the FPGA:

```bash
cp bitstreams/<example>/cyt_top.bit bitstreams/cyt_top.bit
cp bitstreams/<example>/cyt_top.ltx bitstreams/cyt_top.ltx   # if present
sudo bash ./program_fpga.sh cyt_top
```

## Running experiments

The evaluation pipeline (compile scripts, CSV aggregation, plot generation)
lives in the µShell repo under
[`evaluation/scripts/`](https://github.com/TUM-DSE/microShell/tree/master/evaluation/scripts).
Those scripts take the path to **this** repo as an argument when measuring the
baseline (e.g. `bash compile_hw_baseline.sh /path/to/microShell-baseline`).
Refer to `evaluation/scripts/README.md` on the µShell side for the full flow.

## Potential Issues

- **Driver won't load** — `sudo rmmod coyote_drv && sudo insmod driver/coyote_drv.ko`. If that fails, reboot and retry.
- **FPGA programming fails** — verify `bitstreams/cyt_top.bit` exists before running `program_fpga.sh`. Check `sudo dmesg | tail -50` for PCIe / programming errors.
- **Hugepage shortage** — `cat /proc/sys/vm/nr_hugepages` should be ≥ 1024.
- **Test process hangs** — `sudo pkill -9 test`, then re-program the FPGA before retrying.

## Repository layout

```
microShell (baseline)/
├── examples_hw/apps/         # HW pipelines (audio_processing, digital_signature, ...)
│   └── modules/              #   single-module bring-ups (fft, rsa, sha256, ...)
├── examples_sw/apps/         # Host programs, mirrors examples_hw
│   └── modules/              #   per-module test programs
├── sw/{include,src}/         # Coyote runtime (cThread, sgEntry, CoyoteOper, ...)
├── driver/                   # Linux kernel driver
├── hw/                       # Coyote shell HDL
├── bitstreams/               # Pre-built .bit / .ltx, one folder per EXAMPLE target
├── evaluation/               # Synced from the µShell repo by an external bot — do not edit by hand
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
