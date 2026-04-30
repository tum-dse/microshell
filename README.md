# µShell: a microkernel-based FPGA shell architecture

µShell is a hardware/OS co-design for modular accelerator deployment. Inspired
by the microkernel principle, individual hardware modules (FFT, RSA, AES, …)
are deployed into separate vFPGAs and dynamically chained together by a
host-side dataflow graph (DFG) API to compose end-to-end accelerators.

This repo contains the µShell shell, runtime, driver, example modules, and the
end-to-end applications used in the paper. The accompanying baseline (the same
applications written against an unmodified Coyote shell) lives at
[TUM-DSE/microShell, branch `baseline`](https://github.com/TUM-DSE/microShell/tree/baseline).

## Main results

<div align="center">
  <img src="evaluation/plots/e2e.png" width="95%"/>
  <br/>
  <em>Figure 11 — End-to-end performance: µShell vs. Coyote v2 baseline and a monolithic single-binary variant, across the five composed applications.</em>
</div>

<br/>

<div align="center">
  <img src="evaluation/plots/sched.png" width="95%"/>
  <br/>
  <em>Figure 12 — Component-aware scheduling vs. Coyote's FIFO scheduler, across five metrics: (a) end-to-end latency, (b) reconfiguration count, (c) average response time, (d) tail (95%) response time, (e) deadline misses.</em>
</div>

<br/>

<div align="center">
  <img src="evaluation/plots/reconfig_overhead.png" width="50%"/>
  <br/>
  <em>Figure 13 — Application-deployment overhead: µShell capability/buffer updates vs. Coyote partial-reconfiguration cost, for accelerators of 1–4 user-logic components.</em>
</div>

## Prerequisites

### Hardware

- AMD EPYC 7413 CPU × 2
- Xilinx Alveo U280 FPGA × 2
- 100 GbE FPGA-attached NIC
- Bitstream generation (Vivado) and FPGA tests can run on the same host or be
  split across a build host and an FPGA host to keep Vivado off the test path.

### Software

- Linux 6.9.0-rc7 / NixOS 23.11
- [Nix](https://nixos.org/download.html) — all build dependencies are pinned
  via `shell.nix` (host build/run) and `xilinx-shell` (Vivado toolchain)
- Vivado 2022.x (loaded by `xilinx-shell`)
- Python ≥ 3.11 for the plotting scripts under `evaluation/scripts/`

## Getting started

A "hello world"-equivalent run using `perf_local` — the smallest end-to-end
test, a host loop across two vFPGAs.

### 1. Clone the repository

```bash
git clone git@github.com:TUM-DSE/microShell.git microShell
cd microShell
```

### 2. Build the FPGA driver

```bash
nix-shell -p gcc14 gnumake
cd driver
make KERNELDIR=$(nix-build -E '(import <nixpkgs> {}).linuxPackages_6_8.kernel.dev' --no-out-link)/lib/modules/*/build M=$(pwd)
```

A pre-compiled driver is also shipped with this repo if you want to skip the
build.

### 3. Compile perf_local

```bash
nix-shell shell.nix
cd examples_sw && mkdir build_perf_local && cd build_perf_local
cmake ../ -DEXAMPLE=perf_local
make
```

### 4. Program the FPGA and run the test

`perf_local` is shipped as a pre-built bitstream under
[`bitstreams/perf_local/`](bitstreams/perf_local/). Stage it and program:

```bash
cp bitstreams/perf_local/cyt_top.bit bitstreams/cyt_top.bit
sudo bash ./program_fpga.sh cyt_top
sudo sysctl -w vm.nr_hugepages=1024

cd examples_sw/build_perf_local/bin
./test
```

Reports average throughput across two vFPGAs.

## Reproducing the paper

The detailed step-by-step flow — bitstream generation, host-side measurements,
CSV outputs, plot generation — lives in [REPRODUCE.md](REPRODUCE.md). The
mapping from paper artifacts to repo scripts:

| Paper section | Artifact         | Repo plot                                    | Driver scripts                                                    |
|---------------|------------------|----------------------------------------------|-------------------------------------------------------------------|
| §6.1          | Figure 11        | `evaluation/plots/e2e.{png,pdf}`             | `compile_hw_*.sh`, `compile_sw_*.sh` → `plot_e2e.py`              |
| §6.2          | Figure 12 (a–e)  | `evaluation/plots/sched.{png,pdf}`           | `examples_sw/apps/scheduler` → `plot_sched.py`                    |
| §6.3          | Figure 13        | `evaluation/plots/reconfig_overhead.{png,pdf}` | `examples_sw/apps/reconfigure_shell` → `plot_reconfig_overhead.py` |
| §6.4          | Table 5          | `evaluation/plots/complexity.{png,pdf}`      | `measure_complexity_*.sh` → `plot_complexity.py`                  |
| §6.5          | Figures 4–5, Table 6 | `evaluation/plots/{plot_scalability_analysis,resource_efficiency,direct_comm_effectiveness}.pdf` | `compile_scalability.sh`, `compile_effectiveness_*.sh` → `plot_scalability.py`, `plot_efficiency.py`, `plot_effectiveness.py` |

Pre-built bitstreams under [`bitstreams/`](bitstreams/) (one folder per
`EXAMPLE` target) let you skip the 3–4 h Vivado runs and go straight to the
measurement and plotting steps.

## Repository layout

```
microShell/
├── examples_hw/apps/         # HW pipelines (audio_processing, digital_signature, ...)
│   └── modules/              #   single-module bring-ups (fft, rsa, sha256, ...)
├── examples_sw/apps/         # Host programs, mirrors examples_hw
│   ├── *_monolithic/         #   single-binary versions used in §6.1
│   └── modules/              #   per-module test programs
├── sw/{include,src}/         # µShell runtime: DFG API, capabilities, dataflow
├── driver/                   # Linux kernel driver (Coyote-derived)
├── bitstreams/               # Pre-built .bit / .ltx, one folder per EXAMPLE target
├── evaluation/{scripts,data,plots}
├── program_fpga.sh           # Load bitstream + driver + hugepages
├── shell.nix                 # Reproducible build environment
└── REPRODUCE.md              # Full reproduction instructions
```

## Troubleshooting

- **Driver won't load** — `sudo rmmod coyote_drv && sudo insmod driver/coyote_drv.ko`. If that fails, reboot and retry; stuck driver state usually clears.
- **FPGA programming fails** — verify `bitstreams/cyt_top.bit` exists before running `program_fpga.sh`. Check `sudo dmesg | tail -50` for PCIe / programming errors.
- **Hugepage shortage** — `cat /proc/sys/vm/nr_hugepages` should be ≥ 1024. Re-run the `sysctl` command if the number resets after reboot.
- **Test process hangs** — `sudo pkill -9 test`, then re-program the FPGA before retrying.

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
