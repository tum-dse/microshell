# Reproducing the µShell paper

Detailed instructions to rebuild the artifacts behind every figure and table
in §6 (Evaluation) of the paper. Cross-link from the top-level
[README.md](README.md).

The µShell repository (this branch) holds the modular shell, runtime, and
example apps. The Coyote v2 baseline lives on the
[`baseline` branch](https://github.com/TUM-DSE/microShell/tree/baseline) and is
referenced below as `/path/to/baseline`.

## Contents

- [Build environment](#build-environment)
- [Building from source](#building-from-source)
  - [Hardware bitstreams](#hardware-bitstreams)
  - [Host software](#host-software)
- [Pre-built bitstreams](#pre-built-bitstreams)
- §6.1 [End-to-end performance — Figure 11](#61-end-to-end-performance--figure-11)
- §6.2 [Scheduling improvements — Figure 12](#62-scheduling-improvements--figure-12)
- §6.3 [Application-deployment overheads — Figure 13](#63-application-deployment-overheads--figure-13)
- §6.4 [Programmability — Table 5](#64-programmability--table-5)
- §6.5 [Resource overheads — Figures 4–5, Table 6](#65-resource-overheads--figures-45-table-6)
- [Artifact claims](#artifact-claims)

## Build environment

All host-side commands run inside `nix-shell shell.nix`. Vivado bitstream
generation runs inside `xilinx-shell`. Bitstream generation and FPGA tests
can run on the same host or be split across a build host and an FPGA host;
the per-section steps below assume the latter, with bitstream files copied
between hosts as needed.

## Building from source

### Hardware bitstreams

```bash
xilinx-shell
cd examples_hw && mkdir build_<example> && cd build_<example>
cmake ../ -DEXAMPLE=<name> -DFDEV_NAME=u280
make project
make bitgen     # 3–4 h on U280
```

`EXAMPLE` targets — see [examples_hw/CMakeLists.txt](examples_hw/CMakeLists.txt):

- Composed apps: `audio_processing`, `digital_signature`, `secure_storage`, `signed_compression`, `speech_recognition` (each with a `_monolithic` variant)
- Single modules: `aes_ctr`, `fft`, `quantize`, `rle`, `rsa`, `sha256`, `svm`
- Scalability sweep (baseline only): `1vfpga`, `2vfpga`, `4vfpga`, `8vfpga`
- Bring-ups: `perf_local`, `perf_local_2`, `perf_fpga`, `perf_counter`, `static`

The bitstream lands at `examples_hw/build_<example>/bitstreams/cyt_top.bit`.

### Host software

```bash
nix-shell shell.nix
cd examples_sw && mkdir build_<example> && cd build_<example>
cmake ../ -DEXAMPLE=<name>
make
./bin/test                    # default size
./bin/test -s 1048576         # 1 MB transfer
```

Available SW `EXAMPLE` targets: see [examples_sw/CMakeLists.txt](examples_sw/CMakeLists.txt).

## Pre-built bitstreams

If a Vivado run fails or you want to skip the 3–4 h bitgen step, the
[`bitstreams/`](bitstreams/) directory ships known-good bitstreams from the
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

To program a pre-built bitstream:

```bash
cp bitstreams/<example>/cyt_top.bit bitstreams/cyt_top.bit
cp bitstreams/<example>/cyt_top.ltx bitstreams/cyt_top.ltx   # if present
sudo bash ./program_fpga.sh cyt_top
sudo sysctl -w vm.nr_hugepages=1024
```

The `compile_sw_*.sh` scripts under [`evaluation/scripts/`](evaluation/scripts/)
already accept a bitstream path as their second argument, so you can point
them straight at `bitstreams/<example>/cyt_top.bit` without copying.

---

## §6.1 End-to-end performance — Figure 11

Compares throughput and latency of the five composed applications across
three configurations: Coyote v2 baseline, µShell, and a single-binary
monolithic variant on µShell.

### Step 1 — bitstreams (build host)

```bash
cd evaluation/scripts
bash ./compile_hw_ushell.sh   /path/to/microShell   # composed + monolithic
bash ./compile_hw_baseline.sh /path/to/baseline     # composed only
```

Builds run in parallel tmux sessions; attach with `tmux attach -t build_<example>_hw`.

### Step 2 — measure on the FPGA host

```bash
./compile_sw_ushell.sh   audio_processing /path/to/audio_processing/cyt_top.bit /path/to/microShell
./compile_sw_baseline.sh audio_processing /path/to/audio_processing/cyt_top.bit /path/to/baseline
# repeat for: digital_signature, secure_storage, signed_compression, speech_recognition
# add the µShell *_monolithic variants for the third bar in Figure 11
```

CSVs:
- `evaluation/data/e2e_ushell_results.csv`
- `evaluation/data/e2e_baseline_results.csv`

Columns: `example_name, data_size_bytes, throughput_MBps, latency_ns, timestamp`.

### Step 3 — plot

```bash
python3 plot_e2e.py
# → evaluation/plots/e2e.{png,pdf}
```

> Note: `plot_e2e.py` currently uses hardcoded paper-run numbers. Wiring it to
> consume the CSVs above is a known TODO.

---

## §6.2 Scheduling improvements — Figure 12

Compares µShell's component-aware scheduler against Coyote's FIFO scheduler
on three component-shared applications (digital signature, signed compression,
audio processing). Five sub-plots: end-to-end latency, reconfiguration count,
average response time, 95% tail response time, deadline misses.

### Step 1 — collect data

The scheduler experiment lives in
[`examples_sw/apps/scheduler/`](examples_sw/apps/scheduler/). Build it like
any other example:

```bash
cd examples_sw && mkdir build_scheduler && cd build_scheduler
cmake ../ -DEXAMPLE=scheduler
make
cd bin && ./test    # writes the sched_*.csv files into evaluation/data/
```

The runs deploy 8, 12, and 16 application instances every 20 ms.

### Step 2 — plot

```bash
cd evaluation/scripts
python3 plot_sched.py
# Reads: evaluation/data/sched_{latency,reconfig,resp_avg,resp_95,deadline}.csv
# → evaluation/plots/sched.{png,pdf}
```

---

## §6.3 Application-deployment overheads — Figure 13

Measures the cost of deploying multi-component accelerators: µShell's
capability/buffer updates vs. Coyote's partial-reconfiguration cost, for
configurations of 1–4 user-logic components. Two separate bitstreams feed
the figure — one for the capability/buffer path, one for partial
reconfiguration.

### Step 1 — collect capability/buffer-update timings

Program the `ceu_3` bitstream and run the
[`pipeline`](examples_sw/apps/pipeline) host app, which exercises capability
and buffer updates:

```bash
bash ./program_fpga.sh cyt_top_ceu_3
mkdir build_pipe_sw && cd build_pipe_sw
cmake ../examples_sw/ -DEXAMPLE=pipeline -DCMAKE_POLICY_VERSION_MINIMUM=3.5
make

sudo ./bin/test >> reconfig_cap.log
cp reconfig_cap.log ../evaluation/data/reconfig/
```

### Step 2 — collect partial-reconfiguration timings

Program a second bitstream and drive it with the
[`perf_service`](examples_sw/apps/perf_service) server + client. The server
publishes a perf_local accelerator; the client sequentially reconfigures
1–4 components and triggers each with `-1 true`. Open two terminals on the
FPGA host:

```bash
# Terminal 1 — server
bash ./program_fpga.sh cyt_top_pr_time_3
mkdir build_perf_server_sw && cd build_perf_server_sw
cmake ../examples_sw/ -DEXAMPLE=perf_server -DCMAKE_POLICY_VERSION_MINIMUM=3.5
make
sudo ./bin/test
```

```bash
# Terminal 2 — client
mkdir build_perf_client_sw && cd build_perf_client_sw
cmake ../examples_sw/ -DEXAMPLE=perf_client -DCMAKE_POLICY_VERSION_MINIMUM=3.5
make
sudo ./bin/test -1 true
```

The PR timings land in the system journal. Capture them:

```bash
journalctl -n 100 > reconfig_pr.log
cp reconfig_pr.log ../evaluation/data/reconfig/
```

### Step 3 — extract and plot

`extract_reconfig.py` parses both logs and writes a merged
`reconfig_times.csv`; `plot_reconfig_overhead.py` consumes that CSV.

```bash
python3 evaluation/scripts/reconfig/extract_reconfig.py
python3 evaluation/scripts/reconfig/plot_reconfig_overhead.py
# → evaluation/plots/reconfig/reconfig_overhead.{png,pdf}

python3 evaluation/scripts/reconfig/plot_reconf_analysis.py    # supplementary breakdown
# → evaluation/plots/reconfig/reconf_analysis.pdf
```

---

## §6.4 Programmability — Table 5

Source lines of code (SLoC) and cyclomatic complexity (CC) of the host
applications, baseline vs. µShell. Table 5 in the paper; this repo also
produces a grouped bar chart of the same data.

### Step 1 — measure

Requires `scc` and `jq`. Both are available via Nix:
`nix-shell -p scc jq`.

```bash
cd evaluation/scripts
bash ./measure_complexity_baseline.sh /path/to/baseline
bash ./measure_complexity_ushell.sh   /path/to/microShell
```

CSVs:
- `/path/to/baseline/evaluation/data/complexity_baseline_results.csv`
- `/path/to/microShell/evaluation/data/complexity_ushell_results.csv`

Columns: `app_name, variant, files, lines, blanks, comments, code, complexity, timestamp`.
The µShell CSV has two rows per app (`composed` and `monolithic`).

### Step 2 — plot

```bash
python3 plot_complexity.py \
    --baseline-csv /path/to/baseline/evaluation/data/complexity_baseline_results.csv \
    --ushell-csv   /path/to/microShell/evaluation/data/complexity_ushell_results.csv
# → evaluation/plots/complexity.{png,pdf}
```

> `plot_app_modularity.py` is unrelated supplementary material — it draws a
> literature-survey breakdown of accelerator module categories with hardcoded
> counts from the paper, not from these CSVs.

---

## §6.5 Resource overheads — Figures 4–5, Table 6

Three sub-experiments: the per-vFPGA resource budget under different
scalability targets (Figure 4), resource-usage breakdown across components
(Figure 5, Table 6), and the FPGA-acceleration-effectiveness comparison
(direct on-FPGA chaining vs. CPU-orchestrated chaining).

### Scalability — Figure 4

```bash
cd evaluation/scripts
bash ./compile_scalability.sh /path/to/baseline
# Builds 1vfpga, 2vfpga, 4vfpga, 8vfpga bitstreams.

# On the build host, open each implementation checkpoint in Vivado and dump
# the per-hierarchy utilization:
xilinx-shell
vivado -mode tcl
> open_checkpoint /path/to/baseline/examples_hw/<n>vfpga/checkpoints/shell_routed.dcp
> source extract_util.tcl       # writes per-hierarchy CSV

python3 plot_scalability.py
# → evaluation/plots/plot_scalability_analysis.{pdf,png}
```

Resource per vFPGA:

```
per_vfpga = (U280_total - (inst_shell - inst_user_wrapper)) / num_vFPGAs
```

U280 reference: 1,303,680 LUTs · 2,607,360 FFs · 2,016 BRAM (36Kb) · 960 URAM · 9,024 DSP.

### Resource efficiency — Figure 5, Table 6

```bash
python3 plot_efficiency.py
# → evaluation/plots/resource_efficiency.pdf
```

The numbers behind Table 6 come from the same Vivado utilization reports
collected for the scalability experiment.

### FPGA acceleration effectiveness

Compares CPU-orchestrated chaining (sum of single-module latencies) against
direct on-FPGA chaining (composed apps).

```bash
cd evaluation/scripts
bash ./compile_effectiveness_hw.sh /path/to/baseline
# Builds: aes_ctr, rsa, fft, svm, sha256, quantize, rle

./compile_effectiveness_sw.sh fft      <bit> /path/to/baseline
./compile_effectiveness_sw.sh quantize <bit> /path/to/baseline
./compile_effectiveness_sw.sh rle      <bit> /path/to/baseline
./compile_effectiveness_sw.sh aes_ctr  <bit> /path/to/baseline
./compile_effectiveness_sw.sh rsa      <bit> /path/to/baseline
./compile_effectiveness_sw.sh sha256   <bit> /path/to/baseline
./compile_effectiveness_sw.sh svm      <bit> /path/to/baseline

python3 plot_effectiveness.py
# → evaluation/plots/direct_comm_effectiveness.pdf
```

CPU-sync latency = sum of component latencies; the direct-IPC values come
from the composed `e2e_baseline_results.csv` row for the same app. Mapping:

| App                  | Components              |
|----------------------|-------------------------|
| Audio Processing     | fft + quantize + rle    |
| Digital Signature    | sha256 + rsa            |
| Secure Storage       | rle + aes_ctr           |
| Signed Compression   | rle + rsa               |
| Speech Recognition   | fft + svm               |

---

## Artifact claims

All figures and tables in §6 of the paper are reproducible with the commands
above. Numbers may differ from the paper run depending on system state
(driver version, FPGA temperature, hugepage availability, transient queueing
under Vivado-PR). Pre-built bitstreams under [`bitstreams/`](bitstreams/) let
you reproduce the host-side measurements without re-running Vivado.

Several plotting scripts (`plot_e2e.py`, `plot_effectiveness.py`,
`plot_efficiency.py`, `plot_scalability.py`) currently embed paper-run
numbers; rewiring them to consume the CSVs they're paired with is a known
TODO. `plot_complexity.py` (§6.4) and `plot_sched.py` (§6.2) read CSVs
directly today.
