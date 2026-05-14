# Reproducing the µShell paper

Detailed instructions to rebuild the artifacts behind every figure and table
in §6 (Evaluation) of the paper. Cross-link from the top-level
[README.md](README.md).

The µShell repository (this branch) holds the modular shell, runtime, and
example apps; locally at `/scratch/anubhav/microShell`. The Coyote
baseline lives on the
[`baseline` branch](https://github.com/TUM-DSE/microShell/tree/baseline)
and is checked out locally at `/scratch/anubhav/baseline/microShell`.
Commands below assume these two paths.

## Contents

- [Build environment](#build-environment)
- [Building from source](#building-from-source)
  - [Hardware bitstreams](#hardware-bitstreams)
  - [Host software](#host-software)
  - [Application names](#application-names)
- [Pre-built bitstreams](#pre-built-bitstreams)
- §2 [Motivation figures — Figures 1, 2, 3, 6](#2-motivation-figures--figures-1-2-3-6)
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

### Application names

µShell uses short, unrefactored names in both repos. The eval scripts
translate the paper's canonical long names (kept in CSVs and plot labels)
to whatever's in each repo's `examples_{hw,sw}/CMakeLists.txt`.

| Paper name (canonical)  | Master HW       | Master SW       | Baseline HW   | Baseline SW       |
|-------------------------|-----------------|-----------------|---------------|-------------------|
| Audio Processing        | `audio`         | `audio`         | `audio`       | `audio`           |
| Digital Signature       | `digi_sign`     | `digi_sign`     | **`digi`**    | `digi_sign`       |
| Secure Storage          | `secure`        | `secure`        | `secure`      | `secure`          |
| Signed Compression      | `signcomp`      | `signcomp`      | `signcomp`    | `signcomp`        |
| Speech Recognition      | `speech`        | `speech`        | `speech`      | `speech`          |

µShell-monolithic SW (master): `audio_mono`, `digi_sign_mono`, `secure_mono`,
`signcomp_mono`, `speech_mono`.

Fig 3 cpu_sync SW (baseline): `audio_cpu`, `digi_sign_cpu`, `secure_cpu`,
`signcomp_cpu`, `speech_cpu`. Matching HW EXAMPLE entries on baseline
(`audio_cpu`, `digi_cpu`, `secure_cpu`, `signcomp_cpu`, `speech_cpu`) bitgen
a multi-vFPGA bitstream with one module per region.

Single-module bring-ups (both repos): `aes_ctr`, `fft`, `quant`, `rle`,
`rsa`, `sha2`, `svm`.

## Pre-built bitstreams

If a Vivado run fails or you want to skip the 3–4 h bitgen step,
[`bitstreams/`](bitstreams/) ships known-good bitstreams from the paper
run as flat labelled files (one `.bit` + matching `.ltx` per label):

```
/scratch/anubhav/microShell/bitstreams/
├── audio_ushell_top.{bit,ltx}      audio_mono_top.{bit,ltx}
├── digital_ushell_top.{bit,ltx}    digital_mono_top.{bit,ltx}
├── secure_ushell_top.{bit,ltx}     secure_mono_top.{bit,ltx}
├── signed_ushell_top.{bit,ltx}     signed_mono_top.{bit,ltx}
└── speech_ushell_top.{bit,ltx}     speech_mono_top.{bit,ltx}

/scratch/anubhav/baseline/microShell/bitstreams/
├── audio_coyote_top.{bit,ltx}      audio_direct_top.{bit,ltx}    audio_cpu_top.{bit,ltx}
├── digital_coyote_top.{bit,ltx}    digital_direct_top.{bit,ltx}  digital_cpu_top.{bit,ltx}
├── secure_coyote_top.{bit,ltx}     secure_direct_top.{bit,ltx}   secure_cpu_top.{bit,ltx}
├── signed_coyote_top.{bit,ltx}     signed_direct_top.{bit,ltx}   signed_cpu_top.{bit,ltx}
└── speech_coyote_top.{bit,ltx}     speech_direct_top.{bit,ltx}   speech_cpu_top.{bit,ltx}
```

To program a labelled bitstream (the eval scripts do this automatically;
shown here for manual use):

```bash
cd /scratch/anubhav/microShell   # or /scratch/anubhav/baseline/microShell
sudo bash ./program_fpga.sh <label>      # e.g. audio_ushell_top
sudo sysctl -w vm.nr_hugepages=1024
```

`program_fpga.sh` resolves `<label>` → `bitstreams/<label>.bit` at the
repo root.

---

## §2 Motivation figures — Figures 1, 2, 3, 6

Background figures used in §2. Most are paper-driven (literature survey or
hardcoded counts); Figure 3 requires fresh bitstreams + measurements.
Figure 4 and Figure 5 share data with §6.5 and are covered there.

All commands assume cwd = `/scratch/anubhav/microShell/evaluation/scripts/`.

### Figure 1 — Modularity of real-world apps

Literature-survey breakdown of accelerator module categories.

```bash
python3 modularity_2/plot_app_modularity.py
# → evaluation/plots/modularity_2/application_modularity_analysis.{pdf,png}
```

### Figure 2 — Composability of Vitis Vision

Function-call overlap analysis on Vitis Vision Library applications.

```bash
python3 composability_2/process_cv_files.py vision/L3/examples/   # → file_functions.txt
python3 composability_2/analyze_functions.py                       # → similarity_matrix.csv, overlap_matrix.csv
python3 composability_2/visualize_correlation.py similarity_matrix.csv overlap_matrix.csv -o visualization.pdf
# → evaluation/plots/composability_2/correlation_heatmap.pdf
```

### Figure 3 — Direct communication effectiveness

Compares two execution modes per app: **direct** (composed on one vFPGA)
vs. **cpu_sync** (one module per vFPGA, host CPU shuttling between stages).

Bitstreams (build host):
```bash
bash effectiveness_2/compile_bitgen_effectiveness.sh /scratch/anubhav/baseline/microShell
# 10 tmux sessions: 5 direct + 5 cpu_sync. Review timing, then:
bash effectiveness_2/stage_bitstreams_effectiveness.sh /scratch/anubhav/baseline/microShell
```

Measure (FPGA host):
```bash
bash effectiveness_2/run_effectiveness.sh /scratch/anubhav/baseline/microShell
# Auto-enters nix-shell. Appends rows to data/effectiveness_2/effectiveness.csv.
```

Plot:
```bash
python3 effectiveness_2/plot_effectiveness.py
# → evaluation/plots/effectiveness_2/direct_comm_effectiveness.pdf
```

CSV is the only source of truth — paper rows (`source=paper`) act as the
fallback when no measurements exist for a cell.

### Figure 6 — Reconfiguration overhead (motivation)

Partial-reconfiguration overhead as a function of accelerator reuse
fraction (0% / 25% / 50% / 75% / 100%). Hardcoded paper values.

```bash
python3 reconfig_2/plot_reconf_analysis.py
# → evaluation/plots/reconfig_2/reconf_analysis.pdf
```

---

## §6.1 End-to-end performance — Figure 11

Compares throughput and latency of the five composed applications across
three systems: Coyote baseline (`coyote`), µShell composed (`ushell`),
and a single-vFPGA monolithic variant on µShell (`ushell_mono`). Three
transfer sizes per cell: 8 KB / 256 KB / 1 MB.

All commands assume cwd = `/scratch/anubhav/microShell/evaluation/scripts/`.

### Step 1 — bitstreams (build host)

```bash
bash e2e_6.1/compile_hw_baseline.sh /scratch/anubhav/baseline/microShell   # coyote (composed)
bash e2e_6.1/compile_hw_ushell.sh   /scratch/anubhav/microShell            # ushell + monolithic
```

15 tmux sessions in total (5 baseline + 10 µShell). Each runs
`xilinx-shell -c 'cmake ... && make project && make bitgen'` and tees to
`<build_dir>/bitgen.log`. Attach with `tmux attach -t bitgen_<short>_<system>`.
Bitgen takes ~3–4 h per session.

After reviewing timing reports, promote to labelled locations:

```bash
bash e2e_6.1/stage_bitstreams_e2e.sh \
    /scratch/anubhav/baseline/microShell \
    /scratch/anubhav/microShell
```

Pre-built bitstreams ship in [`bitstreams/`](bitstreams/) and at
`/scratch/anubhav/baseline/microShell/bitstreams/`, so this step can be
skipped if you trust the shipped artefacts.

### Step 2 — measure on the FPGA host

```bash
bash e2e_6.1/run_e2e.sh /scratch/anubhav/baseline/microShell /scratch/anubhav/microShell
```

Auto-enters `nix-shell` at the baseline root. For each (app, system, size)
cell — 45 cells per pass — programs the FPGA, builds the SW (incremental),
runs `./test`, and appends one row to `evaluation/data/e2e_6.1/e2e.csv`
with `source=measured`.

Run multiple times (≥3) to get stddev error bars; `plot_e2e.py` averages
across the measured rows per cell.

CSV columns: `app, system, size_bytes, throughput_MBps, latency_ns, n_reps, stddev_MBps, source, timestamp`.

### Step 3 — plot

```bash
python3 e2e_6.1/plot_e2e.py
# → evaluation/plots/e2e_6.1/e2e.{pdf,png}
```

`e2e.csv` ships pre-populated with `source=paper` rows so the plot renders
before any measurement. Measured rows take precedence per cell; cells with
no measurement fall back to paper.

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
cd /scratch/anubhav/microShell/evaluation/scripts
python3 scheduling_6.2/plot_sched.py
# Reads: evaluation/data/scheduling_6.2/sched_{latency,reconfig,resp_avg,resp_95,deadline}.csv
# → evaluation/plots/scheduling_6.2/sched.{pdf,png}
```

---

## §6.3 Application-deployment overheads — Figure 13

Here we measure the cost of deploying multi-component accelerators: µShell's
capability/buffer updates vs. Coyote's partial-reconfiguration cost, for
configurations of 1–4 user-logic components.

### Step 1 — collect data for capability/buffer updates

We use one bitstream to collect data of capability/buffer updates and another bitstream for partial reconfiguration cost.

For capability/buffer updates, first programs the FPGA using the following command and then compile the [`software application`](examples_sw/apps/pipeline)

```bash
bash ./program_fpga.sh 6_3_cap
mkdir build_pipe_sw/ && cd build_pipe_sw/
cmake ../examples_sw/ -DEXAMPLE=pipeline -DCMAKE_POLICY_VERSION_MINIMUM=3.5
```

Then run the application and generate the log file.

```bash
sudo ./bin/test >> reconfig_cap.log
cp reconfig_cap.log /scratch/anubhav/microShell/evaluation/data/deployment_6.3/
```

### Step 2 — collect data for partial reconfiguration

Now we collect the data for partial reconfiguration. For the software, we need one ["server thread"](examples_sw/apps/perf_service/server/) and one ["client thread"](examples_sw/apps/perf_service/client/).

Open two terminals connected to our machine, in the one for server terminal

```bash
bash ./program_fpga.sh 6_3_pr
mkdir build_perf_server_sw/ && cd build_perf_server_sw/
cp ../bitstreams/cyt_top_pr_time_3_0807/* .
cmake ../examples_sw/ -DEXAMPLE=perf_server -DCMAKE_POLICY_VERSION_MINIMUM=3.5

sudo ./bin/test
```

```bash

bash ./program_fpga.sh 6_3_pr
mkdir build_perf_client_sw/ && cd build_perf_client_sw/
cmake ../examples_sw/ -DEXAMPLE=perf_client -DCMAKE_POLICY_VERSION_MINIMUM=3.5
sudo ./bin/test -1 true
```

The execution log were written into system journal. Save the log into a file and copy it into the data folder.

```bash

journalctl -n 100 > reconfig_pr.log
cp reconfig_pr.log /scratch/anubhav/microShell/evaluation/data/deployment_6.3/
```


### Step 3 — plot


Now combine the data from the two logs and make the plots. 

```bash
cd /scratch/anubhav/microShell/evaluation/scripts
# Parses data/deployment_6.3/reconfig_{cap,pr}.log → data/deployment_6.3/reconfig_times.csv
python3 deployment_6.3/extract_reconfig.py

python3 deployment_6.3/plot_reconfig_overhead.py
# → evaluation/plots/deployment_6.3/reconfig_overhead.{pdf,png}
```

---

## §6.4 Programmability — Table 5

Source lines of code (SLoC) and cyclomatic complexity (CC) of the host
applications, baseline vs. µShell composed vs. µShell monolithic. Table 5
in the paper; the repo also produces a grouped bar chart of the same data.

All commands assume cwd = `/scratch/anubhav/microShell/evaluation/scripts/`.

### Step 1 — install tools

```bash
nix-shell -p scc jq
```

`scc` computes LOC and cyclomatic complexity; `jq` parses its JSON output.

### Step 2 — measure

```bash
bash complexity_6.4/measure_complexity_baseline.sh /scratch/anubhav/baseline/microShell
bash complexity_6.4/measure_complexity_ushell.sh   /scratch/anubhav/microShell
```

CSVs land in each repo's `evaluation/data/complexity_6.4/`:

- `/scratch/anubhav/baseline/microShell/evaluation/data/complexity_6.4/complexity_baseline_results.csv` — one row per composed app
- `/scratch/anubhav/microShell/evaluation/data/complexity_6.4/complexity_ushell_results.csv` — two rows per app (`composed` + `monolithic`)

Columns: `app_name, variant, files, lines, blanks, comments, code, complexity, timestamp`.

### Step 3 — plot

```bash
python3 complexity_6.4/plot_complexity.py \
    --baseline-csv /scratch/anubhav/baseline/microShell/evaluation/data/complexity_6.4/complexity_baseline_results.csv \
    --ushell-csv   /scratch/anubhav/microShell/evaluation/data/complexity_6.4/complexity_ushell_results.csv
# → evaluation/plots/complexity_6.4/complexity.{pdf,png}
```

> `modularity_2/plot_app_modularity.py` is unrelated supplementary material
> (Figure 1) — it draws a literature-survey breakdown of accelerator module
> categories from hardcoded paper counts, not from these CSVs.

---

## §6.5 Resource overheads — Figures 4–5, Table 6

Resource utilization of µShell vs. Coyote on the U280, plus the per-module
breakdown that drives Figure 5. Numbers come from Vivado hierarchical
utilization reports of six bitstreams:

- **Coyote baseline**: built on the `baseline` branch with one of the
  per-vFPGA-count shells.
- **µShell with 3 / 4 / 6 / 8 vFPGAs**: scalability sweep, built on
  `master` HW CMakeLists as `ceu_3`, `ceu_4`, `ceu_6`, `ceu_8`.
- **All-modules bitstream** (Figure 5 data source): built on the `baseline`
  branch as the `resource_usage` target — 7 modules on 7 vFPGAs in one
  shell.

Bitgen all six is ~24 h. The flow below uses the smallest configuration
(`ceu_3` or `1vfpga`) as a representative example; the rest are identical
recipes with different `EXAMPLE` names.

### Step 1 — bitgen the µShell vFPGA-count sweep (master branch)

```bash
cd /scratch/anubhav/microShell/examples_hw
mkdir build_ushell_3 && cd build_ushell_3
xilinx-shell -c "cmake ../ -DEXAMPLE=ceu_3 -DFDEV_NAME=u280 && make project && make bitgen"
```

Repeat with `EXAMPLE=ceu_4`, `EXAMPLE=ceu_6`, `EXAMPLE=ceu_8` for the
other three µShell shells.

### Step 2 — bitgen the Coyote baseline shell (baseline branch)

```bash
cd /scratch/anubhav/baseline/microShell/examples_hw
mkdir build_3vfpga && cd build_3vfpga
xilinx-shell -c "cmake ../ -DEXAMPLE=3vfpga -DFDEV_NAME=u280 && make project && make bitgen"
```

`1vfpga`, `2vfpga`, `4vfpga`, `8vfpga` are also defined; use whichever
matches the µShell vFPGA count you want to compare against.

The four-config sweep can be kicked off in parallel via:
```bash
cd /scratch/anubhav/microShell/evaluation/scripts
bash scalability_2/compile_scalability.sh /scratch/anubhav/baseline/microShell
```

### Step 3 — bitgen the all-modules bitstream (baseline branch, Figure 5)

```bash
cd /scratch/anubhav/baseline/microShell/examples_hw
mkdir build_resource_usage && cd build_resource_usage
xilinx-shell -c "cmake ../ -DEXAMPLE=resource_usage -DFDEV_NAME=u280 && make project && make bitgen"
```

This is the 7-vFPGA build with one module per region (fft, quant, rle,
sha2, rsa, aes_ctr, svm).

### Step 4 — extract hierarchical utilization (in Vivado)

For each build, open the routed checkpoint and run the TCL helper:


```bash
xilinx-shell
vivado -mode tcl
> source /scratch/anubhav/microShell/evaluation/scripts/extract_util.tcl <build_dir_name>
```

`extract_util.tcl` opens `<build_dir_name>/checkpoints/shell_routed.dcp`
and writes `<build_dir_name>/util_<build_dir_name>.csv`.

Copy the CSVs into the µShell repo:

```bash
cp /scratch/anubhav/baseline/microShell/examples_hw/build_*vfpga/util_*.csv \
   /scratch/anubhav/microShell/evaluation/data/resource_usage_6.5/
cp /scratch/anubhav/baseline/microShell/examples_hw/build_resource_usage/util_resource_usage.csv \
   /scratch/anubhav/microShell/evaluation/data/resource_usage_6.5/module_resource_usage.csv
```

A pre-generated `module_resource_usage.csv` is already shipped at
`evaluation/data/resource_usage_6.5/module_resource_usage.csv` so you can
skip Step 3 + the second copy above if you only want Table 6 numbers.

### Step 5 — aggregate

Per-shell summary (Table 6):
```bash
cd /scratch/anubhav/microShell/evaluation/scripts
python3 resource_usage_6.5/extract_util.py
# Prints the Table 6 rows (Coyote, µShell, Inter 3/4/6/8, PCIe DMA, MMU, CEU)
```

Per-module summary (Figure 5 — Vitis Vision sharing analysis is hardcoded
in `resource_usage_6.5/plot_resource_usage.py`; `extract_modules.py`
generates the per-module footprint table from the all-modules bitstream):
```bash
python3 resource_usage_6.5/extract_modules.py
# Prints per-module utilization (FFT / Quantize / RLE / SHA-256 / RSA / AES-CTR / SVM)

python3 resource_usage_6.5/plot_resource_usage.py
# → evaluation/plots/resource_usage_6.5/resource_usage.{pdf,png}  (Figure 5)
```

Per-vFPGA budget (Figure 4):
```bash
python3 scalability_2/plot_scalability.py --baseline /scratch/anubhav/baseline/microShell
# → evaluation/plots/scalability_2/scalability_analysis.{pdf,png}  (Figure 4)
```





<!-- ## Artifact claims

All figures and tables in §6 of the paper are reproducible with the commands
above. Numbers may differ from the paper run depending on system state
(driver version, FPGA temperature, hugepage availability, transient queueing
under Vivado-PR). Pre-built bitstreams under [`bitstreams/`](bitstreams/) let
you reproduce the host-side measurements without re-running Vivado.

Several plotting scripts (`plot_e2e.py`, `plot_effectiveness.py`,
`plot_efficiency.py`, `plot_scalability.py`) currently embed paper-run
numbers; rewiring them to consume the CSVs they're paired with is a known
TODO. `plot_complexity.py` (§6.4) and `plot_sched.py` (§6.2) read CSVs
directly today. -->