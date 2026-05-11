# Evaluation Scripts

Automation for the µShell vs. baseline experiments. Each script wraps the
manual `cmake -DEXAMPLE=… && make` flow that the top-level README documents.

## Paper section ↔ subdir

Each subdir produces exactly one figure or table in the paper. `evaluation/data/`
and `evaluation/plots/` mirror the same layout — each script reads from
`data/<same-subdir>/` and writes plots to `plots/<same-subdir>/`.

| Subdir              | Paper output                              | Section |
|---------------------|-------------------------------------------|---------|
| `modularity_2/`       | Figure 1 — Modularity of real-world apps   | §2      |
| `composability_2/`    | Figure 2 — Composability of Vitis Vision   | §2      |
| `effectiveness_2/`    | Figure 3 — Direct communication effectiveness | §2   |
| `scalability_2/`      | Figure 4 — Available FPGA resources per vFPGA | §2   |
| `resource_usage_2/`   | Figure 5 — Resource usage analysis (Vitis modules) | §2 |
| `reconfig_2/`         | Figure 6 — Reconfiguration overhead (motivation) | §2 |
| `e2e_6.1/`              | Figure 11 — End-to-end performance        | §6.1    |
| `scheduling_6.2/`       | Figure 12 — Component-aware scheduling     | §6.2    |
| `deployment_6.3/`       | Figure 13 — Application deployment overheads | §6.3 |
| `complexity_6.4/`       | Table 5 — Programmability (SLoC + CC)     | §6.4    |
| `efficiency_6.5/`       | Table 6 — µShell resource usage on U280   | §6.5    |
| `extract_util.tcl`  | Vivado helper (shared by `scalability_2/` + `efficiency_6.5/`) | — |

All commands below assume cwd `evaluation/scripts/`.

## Server split

Bitstream generation runs on **Amy** (compile-only). Hardware tests run on
**Clara** (Vivado-programmed FPGA + driver). Bitstreams are produced on Amy
and copied to Clara before running any SW-side script.

## Application names

The composed pipelines and their single-binary "monolithic" counterparts:

| Composed (DFG)          | Monolithic                       | Modules used         |
|-------------------------|----------------------------------|----------------------|
| `audio_processing`      | `audio_processing_monolithic`    | fft + quantize + rle |
| `digital_signature`     | `digital_signature_monolithic`   | sha256 + rsa         |
| `secure_storage`        | `secure_storage_monolithic`      | rle + aes_ctr        |
| `signed_compression`    | `signed_compression_monolithic`  | rle + rsa            |
| `speech_recognition`    | `speech_recognition_monolithic`  | fft + svm            |

Single-module bring-ups: `aes_ctr`, `fft`, `quantize`, `rle`, `rsa`, `sha256`, `svm`.

The baseline repo only ships the composed apps (no `_monolithic`).

---

## §2 Motivation figures

### Figure 1 — Modularity of real-world apps (`modularity_2/`)

Hardcoded literature-survey breakdown of accelerator module categories across
big-data, networking, XR, autonomous vehicles, wearables, etc. Reproduces
the bars in Figure 1 (and Table 1) directly from paper-supplied counts.

```bash
python3 modularity_2/plot_app_modularity.py
# → plots/modularity_2/application_modularity_analysis.{pdf,png}
```

### Figure 2 — Composability of Vitis Vision (`composability_2/`)

Function-call overlap analysis on Vitis Vision Library applications.

```bash
python3 composability_2/process_cv_files.py vision/L3/examples/   # → file_functions.txt
python3 composability_2/analyze_functions.py                       # → similarity_matrix.csv, overlap_matrix.csv
python3 composability_2/visualize_correlation.py similarity_matrix.csv overlap_matrix.csv -o visualization.pdf
# → plots/composability_2/correlation_heatmap.pdf
```

### Figure 3 — Direct communication effectiveness (`effectiveness_2/`)

Compares two execution modes for each of the 5 paper apps:
- **direct**: composed pipeline on a single vFPGA.
- **cpu_sync**: each module on its own vFPGA, host CPU shuttling between stages.

Bitstreams (Amy):
```bash
bash effectiveness_2/compile_bitgen_effectiveness.sh /path/to/baseline
# 10 tmux sessions: 5 direct + 5 cpu_sync. Review timing then:
bash effectiveness_2/stage_bitstreams_effectiveness.sh /path/to/baseline
```

Measure (Clara):
```bash
bash effectiveness_2/run_effectiveness.sh /path/to/baseline
# Auto-enters nix-shell. Appends rows to data/effectiveness_2/effectiveness.csv.
# Run multiple times for averaged numbers (single rep per ./test — see comment in run script).
```

Plot:
```bash
python3 effectiveness_2/plot_effectiveness.py
# → plots/effectiveness_2/direct_comm_effectiveness.pdf
```

CSV is the only source of truth — paper-baseline rows (`source=paper`) act as
fallback when no measurements exist for a cell.

### Figure 4 — Available FPGA resources per vFPGA (`scalability_2/`)

Bitstreams for vFPGA-count sweeps (`1vfpga`, `2vfpga`, `4vfpga`, `8vfpga`) on
the baseline shell:

```bash
bash scalability_2/compile_scalability.sh /path/to/baseline
```

Open each implementation checkpoint in Vivado and extract utilization:

```bash
xilinx-shell; vivado -mode tcl
> open_checkpoint /path/to/baseline/examples_hw/<n>vfpga/checkpoints/shell_routed.dcp
> source extract_util.tcl
```

Plot:
```bash
python3 scalability_2/plot_scalability.py
# → plots/scalability_2/scalability_analysis.{pdf,png}
```

Per-vFPGA resource formula:
```
per_vfpga = (U280_total - (inst_shell - inst_user_wrapper)) / num_vFPGAs
```

U280 reference: 1,303,680 LUTs · 2,607,360 FFs · 2,016 BRAM (36Kb) · 960 URAM · 9,024 DSP.

### Figure 5 — Resource usage analysis (`resource_usage_2/`)

Vitis Vision module-sharing breakdown — how much of each app's resource
footprint is shared with N other apps. Plot uses hardcoded paper values;
`extract_modules.py` is the helper that produced `module_resource_usage.csv`
from a 7-vFPGA "all modules in parallel" baseline build.

```bash
python3 resource_usage_2/plot_resource_usage.py
# → plots/resource_usage_2/resource_usage.{pdf,png}
```

### Figure 6 — Reconfiguration overhead (`reconfig_2/`)

Partial-reconfiguration overhead as a function of accelerator reuse fraction
(0% / 25% / 50% / 75% / 100%). Compares Coyote (no reuse) vs. PR-with-reuse.

```bash
python3 reconfig_2/plot_reconf_analysis.py
# → plots/reconfig_2/reconf_analysis.pdf
```

The values are derived from `data/reconfig_2/sched_motive.csv` (currently
hardcoded in the script for paper reproducibility).

---

## §6 Evaluation

### §6.1 End-to-end performance — Figure 11 (`e2e_6.1/`)

Bitstreams (Amy):
```bash
bash e2e_6.1/compile_hw_baseline.sh /path/to/baseline       # coyote composed
bash e2e_6.1/compile_hw_ushell.sh   /path/to/microShell     # ushell composed + monolithic
bash e2e_6.1/stage_bitstreams_e2e.sh /path/to/baseline /path/to/microShell
```

Measure (Clara):
```bash
bash e2e_6.1/run_e2e.sh /path/to/baseline /path/to/microShell
# Auto-enters nix-shell. 5 apps × 3 systems × 3 sizes = 45 cells per pass.
# Run multiple times for averaged numbers.
```

Plot:
```bash
python3 e2e_6.1/plot_e2e.py
# → plots/e2e_6.1/e2e.{pdf,png}
```

CSV (`data/e2e_6.1/e2e.csv`) is pre-populated with `source=paper` rows so the plot
renders before any measurement. Measured rows take precedence per cell.

### §6.2 Scheduling improvements — Figure 12 (`scheduling_6.2/`)

Data lives in `data/scheduling_6.2/sched_*.csv` (collected via the scheduler app
under `examples_sw/apps/scheduler`).

```bash
python3 scheduling_6.2/plot_sched.py
# → plots/scheduling_6.2/sched.{pdf,png}
# Reads: sched_latency.csv, sched_reconfig.csv, sched_resp_avg.csv,
#        sched_resp_95.csv, sched_deadline.csv
```

### §6.3 Application deployment overheads — Figure 13 (`deployment_6.3/`)

Breakdown of µShell vs. Coyote deployment overhead across 1/2/3/4 ULs
(object cap update + memory cap + buffer alloc + partial reconfig).

Extract:
```bash
python3 deployment_6.3/extract_reconfig.py
# Parses data/deployment_6.3/reconfig_{cap,pr}.log → data/deployment_6.3/reconfig_times.csv
```

Plot:
```bash
python3 deployment_6.3/plot_reconfig_overhead.py
# → plots/deployment_6.3/reconfig_overhead.{pdf,png}
```

### §6.4 Programmability — Table 5 (`complexity_6.4/`)

SLoC and cyclomatic complexity using `scc` (LOC + CC) and `jq` (JSON parsing).
Install via `nix-shell -p scc jq` if missing.

```bash
bash complexity_6.4/measure_complexity_baseline.sh /path/to/baseline
bash complexity_6.4/measure_complexity_ushell.sh   /path/to/microShell

python3 complexity_6.4/plot_complexity.py \
    --baseline-csv /path/to/baseline/evaluation/data/complexity_6.4/complexity_baseline_results.csv \
    --ushell-csv   /path/to/microShell/evaluation/data/complexity_6.4/complexity_ushell_results.csv
# → plots/complexity_6.4/complexity.{pdf,png}
```

CSVs:
- `complexity_baseline_results.csv` — one row per composed app
- `complexity_ushell_results.csv` — two rows per app (`composed` + `monolithic`)
- columns: `app_name, variant, files, lines, blanks, comments, code, complexity, timestamp`

### §6.5 Resource overheads — Table 6 (`efficiency_6.5/`)

µShell vs. Coyote resource usage on U280, broken down by component (CEU, MMU,
Inter for 3/4/6/8 vFPGAs, PCIe DMA, etc.). Data comes from Vivado's
hierarchical utilization reports.

Capture (per vFPGA-count, in Vivado):
```bash
xilinx-shell; vivado -mode tcl
> open_checkpoint /path/to/<shell>/checkpoints/shell_routed.dcp
> source extract_util.tcl       # → util_<shell>.csv next to the checkpoint
```

Aggregate:
```bash
python3 efficiency_6.5/extract_util.py
# Reads data/efficiency_6.5/util_{coyote,ushell,inter_4,inter_6,inter_8}.csv
# Prints Table 6 rows to stdout
```

Table 6 has no plot — it's tabular output the paper consumes directly.

---

## Troubleshooting

```bash
sudo rmmod coyote_drv && sudo insmod /path/to/microShell/driver/coyote_drv.ko
cat /proc/sys/vm/nr_hugepages           # should be ≥ 1024
ls /path/to/microShell/bitstreams/      # cyt_top.bit must exist before program_fpga.sh
sudo dmesg | tail -50                   # driver / FPGA programming errors
```

## File reference

- HW CMake entry points: `examples_hw/CMakeLists.txt` (both repos).
- SW CMake entry points: `examples_sw/CMakeLists.txt` (both repos).
- App sources: `examples_{hw,sw}/apps/`.
- DFG runtime (µShell only): `microShell/sw/{include,src}/`.
- Baseline runtime: `baseline/microShell/sw/{include,src}/`.
