# Evaluation Scripts

Automation for the µShell vs. baseline experiments. Each script wraps the
manual `cmake -DEXAMPLE=… && make` flow that the top-level README documents.

## Layout

Scripts are grouped into one subdirectory per paper figure / table.
`evaluation/data/` and `evaluation/plots/` mirror the same layout —
each script reads from `data/<same-subdir>/` and writes plots to
`plots/<same-subdir>/`.

| Dir                      | What it produces |
|--------------------------|------------------|
| `complexity/`            | Table 5 (SLoC + CC) |
| `e2e/`                   | Figure 11 (end-to-end throughput) |
| `effectiveness/`         | Figure 3 (direct comm vs CPU-sync) |
| `scalability/`           | Figure 4 (per-vFPGA budget) |
| `efficiency/`            | resource-usage table (per-module footprints) |
| `modularity/`            | application-modularity / correlation figures |
| `reconfig/`              | Figure 13 (reconfiguration overhead) |
| `scheduling/`            | Figure 12 (component-aware scheduler) |
| `extract_util.tcl`       | Vivado helper, shared by `scalability/` and `efficiency/` |

All commands below assume cwd `evaluation/scripts/`.

## Server split

Bitstream generation runs on **Amy** (compile-only). Hardware tests run on
**Clara** (Vivado-programmed FPGA + driver). Bitstreams are produced on Amy
and copied to Clara before running any `compile_sw_*.sh` script.

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

## End-to-End Performance Overhead

### Step 1 — bitstreams (Amy)

```bash
cd evaluation/scripts
bash ./e2e/compile_hw_ushell.sh   /path/to/microShell   # composed + monolithic
bash ./e2e/compile_hw_baseline.sh /path/to/baseline     # composed only
```

Each example builds in its own tmux session: `tmux attach -t build_<example>_hw`.
Bitstream lands at `<base>/examples_hw/<example>/bitstreams/cyt_top.bit`.

Per-example manual build:

```bash
cd /path/to/microShell/examples_hw && mkdir audio_processing && cd audio_processing
xilinx-shell
cmake ../ -DEXAMPLE=audio_processing -DFDEV_NAME=u280
make project && make bitgen
```

### Step 2 — run on Clara

```bash
# Per-app: copies bitstream, programs FPGA, builds SW, runs ./test, parses metrics
./e2e/compile_sw_ushell.sh   audio_processing /path/to/audio_processing/cyt_top.bit /path/to/microShell
./e2e/compile_sw_baseline.sh audio_processing /path/to/audio_processing/cyt_top.bit /path/to/baseline

# Optional 4th arg = transfer size in bytes (default 1048576)
./e2e/compile_sw_ushell.sh   audio_processing <bit> /path/to/microShell 65536
```

CSV outputs:
- `evaluation/data/e2e_ushell_results.csv`
- `evaluation/data/e2e_baseline_results.csv`

Columns: `example_name, data_size_bytes, throughput_MBps, latency_ns, timestamp`.

### Plot

```bash
cd evaluation/scripts && python3 e2e/plot_e2e.py
# → evaluation/plots/e2e.{png,pdf}
```

> Note: `plot_e2e.py` currently uses hardcoded numbers from the paper run.
> Wiring it to consume the CSVs above is a known TODO.

## Programmability

```bash
bash ./complexity/measure_complexity_baseline.sh /path/to/baseline
bash ./complexity/measure_complexity_ushell.sh   /path/to/microShell

# Each script writes its CSV into <its repo>/evaluation/data/.
# Point the plotter at both:
python3 complexity/plot_complexity.py \
    --baseline-csv /path/to/baseline/evaluation/data/complexity_baseline_results.csv \
    --ushell-csv   /path/to/microShell/evaluation/data/complexity_ushell_results.csv
# → evaluation/plots/complexity.{pdf,png}
```

The shell scripts use `scc` (LOC + cyclomatic complexity) and `jq` (parse JSON).
Install via `nix-shell -p scc jq` if either is missing — the scripts no longer
attempt auto-installation.

CSVs:
- `complexity_baseline_results.csv` — one row per composed app
- `complexity_ushell_results.csv` — two rows per app (`composed` + `monolithic`)
- columns: `app_name, variant, files, lines, blanks, comments, code, complexity, timestamp`

`plot_app_modularity.py` is unrelated — it draws a literature-survey breakdown
of accelerator module categories and uses hardcoded counts from the paper.

## Scalability

Bitstreams for vFPGA-count sweeps (`1vfpga`, `2vfpga`, `4vfpga`, `8vfpga`)
live in the **baseline** repo (the µShell shell side):

```bash
bash ./scalability/compile_scalability.sh /path/to/baseline
```

Open each implementation checkpoint in Vivado on the build host and report
utilization:

```bash
xilinx-shell
vivado -mode tcl
> open_checkpoint /path/to/baseline/examples_hw/<n>vfpga/checkpoints/shell_routed.dcp
> source extract_util.tcl       # writes per-hierarchy CSV
```

Resource per vFPGA:

```
per_vfpga = (U280_total - (inst_shell - inst_user_wrapper)) / num_vFPGAs
```

U280 reference: 1,303,680 LUTs · 2,607,360 FFs · 2,016 BRAM (36Kb) · 960 URAM · 9,024 DSP.

```bash
python3 scalability/plot_scalability.py
# → evaluation/plots/plot_scalability_analysis.{pdf,png}
```

## FPGA Acceleration Effectiveness

Figure 3 (`direct_comm_effectiveness.pdf`) compares two execution modes for
each of the 5 paper apps:

- **direct**: composed pipeline on a single vFPGA (the Coyote baseline that
  also feeds the e2e plot — modules chained directly on-chip).
- **cpu_sync**: each module on its own vFPGA, with the host CPU sequentially
  invoking each stage and copying intermediate buffers between them.

| App                  | Modules in pipeline       |
|----------------------|---------------------------|
| Audio Processing     | FFT → Quantize → RLE      |
| Digital Signature    | SHA-256 → RSA             |
| Secure Storage       | RLE → AES-CTR             |
| Signed Compression   | RLE → RSA                 |
| Speech Recognition   | FFT → SVM                 |

### Step 1 — bitstreams

The composed (direct) bitstreams are produced by `compile_hw_baseline.sh`
(see §End-to-End). The cpusync bitstreams are produced by:

```bash
bash ./effectiveness/compile_effectiveness_hw.sh /path/to/baseline
# Builds: audio_processing_cpusync, digital_signature_cpusync,
#         secure_storage_cpusync, signed_compression_cpusync,
#         speech_recognition_cpusync
```

### Step 2 — measure on the FPGA

```bash
bash ./effectiveness/run_effectiveness.sh /path/to/baseline [--reps N]
```

For each (app, mode), the driver programs the matching bitstream, builds the
SW once, runs `./test -r N`, parses the `Throughput: X MB/s` /
`Total latency: Y ns` lines, and appends a row to
`evaluation/data/effectiveness.csv` with columns
`app,mode,throughput_MBps,latency_ns,n_reps,timestamp`.

### Step 3 — plot

```bash
python3 effectiveness/plot_effectiveness.py
# → evaluation/plots/direct_comm_effectiveness.pdf
```

The plot reads `data/effectiveness.csv` if present; multiple rows per
(app, mode) are averaged and the std-dev across rows becomes the error bar.
If the CSV is missing or doesn't cover an (app, mode), the script falls back
to the paper numbers so the figure still renders.

## Scheduling Improvements

Data lives in `evaluation/data/sched_*.csv` (collected via the scheduler app
under `examples_sw/apps/scheduler`).

```bash
python3 scheduling/plot_sched.py
# → evaluation/plots/sched.{png,pdf}
# Reads: sched_latency.csv, sched_reconfig.csv, sched_resp_avg.csv,
#        sched_resp_95.csv, sched_deadline.csv
```

`plot_reconf_analysis.py` and `plot_reconfig_overhead.py` produce supporting
figures (sched motivation, reconfiguration cost breakdown).

## Vitis Vision component analysis (supplementary)

```bash
python3 modularity/process_cv_files.py vision/L3/examples/      # → file_functions.txt
python3 modularity/analyze_functions.py                          # → similarity_matrix.csv, overlap_matrix.csv
python3 modularity/visualize_correlation.py similarity_matrix.csv overlap_matrix.csv -o visualization.pdf
```

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
