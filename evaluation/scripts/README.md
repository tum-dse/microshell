# Evaluation Scripts

Automation for the µShell vs. baseline experiments. Each script wraps the
manual `cmake -DEXAMPLE=… && make` flow that the top-level README documents.

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
bash ./compile_hw_ushell.sh   /path/to/microShell   # composed + monolithic
bash ./compile_hw_baseline.sh /path/to/baseline     # composed only
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
./compile_sw_ushell.sh   audio_processing /path/to/audio_processing/cyt_top.bit /path/to/microShell
./compile_sw_baseline.sh audio_processing /path/to/audio_processing/cyt_top.bit /path/to/baseline

# Optional 4th arg = transfer size in bytes (default 1048576)
./compile_sw_ushell.sh   audio_processing <bit> /path/to/microShell 65536
```

CSV outputs:
- `evaluation/data/e2e_ushell_results.csv`
- `evaluation/data/e2e_baseline_results.csv`

Columns: `example_name, data_size_bytes, throughput_MBps, latency_ns, timestamp`.

### Plot

```bash
cd evaluation/scripts && python3 plot_e2e.py
# → evaluation/plots/e2e.{png,pdf}
```

> Note: `plot_e2e.py` currently uses hardcoded numbers from the paper run.
> Wiring it to consume the CSVs above is a known TODO.

## Programmability

```bash
bash ./measure_complexity_baseline.sh /path/to/baseline
bash ./measure_complexity_ushell.sh   /path/to/microShell
python3 plot_app_modularity.py
# → evaluation/plots/application_modularity_analysis.{pdf,png}
```

The scripts use `scc` (auto-installs if missing) to count LOC across each app.
The ushell script reports both the composed and `_monolithic` variants.

## Scalability

Bitstreams for vFPGA-count sweeps (`1vfpga`, `2vfpga`, `4vfpga`, `8vfpga`)
live in the **baseline** repo (the µShell shell side):

```bash
bash ./compile_scalability.sh /path/to/baseline
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
python3 plot_scalability.py
# → evaluation/plots/plot_scalability_analysis.{pdf,png}
```

## FPGA Acceleration Effectiveness

Compares CPU-orchestrated component chaining (sum of single-module latencies)
against direct on-FPGA chaining (composed apps from §End-to-End).

### Step 1 — module bitstreams (baseline)

```bash
bash ./compile_effectiveness_hw.sh /path/to/baseline
# Builds: aes_ctr, rsa, fft, svm, sha256, quantize, rle
```

### Step 2 — measure each module on Clara

```bash
./compile_effectiveness_sw.sh fft     /path/to/baseline/examples_hw/fft/bitstreams/cyt_top.bit     /path/to/baseline
./compile_effectiveness_sw.sh quantize /path/to/baseline/examples_hw/quantize/bitstreams/cyt_top.bit /path/to/baseline
./compile_effectiveness_sw.sh rle     /path/to/baseline/examples_hw/rle/bitstreams/cyt_top.bit     /path/to/baseline
./compile_effectiveness_sw.sh aes_ctr /path/to/baseline/examples_hw/aes_ctr/bitstreams/cyt_top.bit /path/to/baseline
./compile_effectiveness_sw.sh rsa     /path/to/baseline/examples_hw/rsa/bitstreams/cyt_top.bit     /path/to/baseline
./compile_effectiveness_sw.sh sha256  /path/to/baseline/examples_hw/sha256/bitstreams/cyt_top.bit  /path/to/baseline
./compile_effectiveness_sw.sh svm     /path/to/baseline/examples_hw/svm/bitstreams/cyt_top.bit     /path/to/baseline
```

CSV: `evaluation/data/effectiveness_results.csv` (override with `--csv`).

CPU-sync latency = sum of component latencies; IPC latency comes from the
composed `e2e_baseline_results.csv` row for the same app. Mapping:

| App                  | Components              |
|----------------------|-------------------------|
| Audio Processing     | fft + quantize + rle    |
| Digital Signature    | sha256 + rsa            |
| Secure Storage       | rle + aes_ctr           |
| Signed Compression   | rle + rsa               |
| Speech Recognition   | fft + svm               |

```bash
python3 plot_effectiveness.py
# → evaluation/plots/direct_comm_effectiveness.pdf
```

## Scheduling Improvements

Data lives in `evaluation/data/sched_*.csv` (collected via the scheduler app
under `examples_sw/apps/scheduler`).

```bash
python3 plot_sched.py
# → evaluation/plots/sched.{png,pdf}
# Reads: sched_latency.csv, sched_reconfig.csv, sched_resp_avg.csv,
#        sched_resp_95.csv, sched_deadline.csv
```

`plot_reconf_analysis.py` and `plot_reconfig_overhead.py` produce supporting
figures (sched motivation, reconfiguration cost breakdown).

## Vitis Vision component analysis (supplementary)

```bash
python3 process_cv_files.py vision/L3/examples/      # → file_functions.txt
python3 analyze_functions.py                          # → similarity_matrix.csv, overlap_matrix.csv
python3 visualize_correlation.py similarity_matrix.csv overlap_matrix.csv -o visualization.pdf
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
