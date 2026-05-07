#!/bin/bash
# Driver for the direct_comm_effectiveness experiment.
#
# Runs each of the 5 paper apps in two modes — "direct" (composed pipeline
# on a single vFPGA) and "cpu_sync" (one module per vFPGA, host shuttling
# between stages) — and writes per-mode throughput/latency rows to
# evaluation/data/effectiveness.csv.
#
# Programs the FPGA with the matching bitstream, builds the SW once per
# (app, mode), runs ./test, parses the "Throughput: X MB/s" /
# "Total latency: Y ns" lines that the cpusync mains and the composed
# baseline mains both already print.

set -e

usage() {
    echo "Usage: $0 <baseline_base_dir> [--reps N]"
    echo ""
    echo "  baseline_base_dir  Path to baseline (the repo with the cpusync"
    echo "                     bitstreams + SW)."
    echo "  --reps N           Number of measurement repetitions per (app,mode)"
    echo "                     averaged into the CSV row (default: 5)."
    echo ""
    echo "Expects bitstreams at:"
    echo "  <baseline>/examples_hw/<app>/bitstreams/cyt_top.bit         (direct)"
    echo "  <baseline>/examples_hw/<app>_cpusync/bitstreams/cyt_top.bit (cpu_sync)"
    exit 1
}

if [ $# -lt 1 ]; then usage; fi
BASELINE_BASE=$(realpath "$1"); shift
N_REPS=5
while [ $# -gt 0 ]; do
    case "$1" in
        --reps) N_REPS="$2"; shift 2 ;;
        *) echo "Unknown arg: $1"; usage ;;
    esac
done

if [ ! -d "$BASELINE_BASE/examples_sw" ] || [ ! -f "$BASELINE_BASE/program_fpga.sh" ]; then
    echo "Error: $BASELINE_BASE doesn't look like a baseline repo"
    exit 1
fi

EVAL_DIR="$(dirname "$(realpath "$0")")/../../data/effectiveness"
mkdir -p "$EVAL_DIR"
CSV_FILE="$EVAL_DIR/effectiveness.csv"
LOG_DIR="$EVAL_DIR/effectiveness_logs"
mkdir -p "$LOG_DIR"

if [ ! -f "$CSV_FILE" ]; then
    echo "app,mode,throughput_MBps,latency_ns,n_reps,timestamp" > "$CSV_FILE"
fi

apps=("audio_processing" "digital_signature" "secure_storage" "signed_compression" "speech_recognition")
modes=("direct" "cpu_sync")

# extract_metric <output> <pattern> -> numeric value or empty
extract_throughput() {
    echo "$1" | grep -E "^[[:space:]]*Throughput:" | head -1 \
        | sed -E 's/.*Throughput:[[:space:]]+([0-9]+\.?[0-9]*).*MB\/s.*/\1/'
}
extract_latency() {
    echo "$1" | grep -E "^[[:space:]]*Total[[:space:]]+latency:" | head -1 \
        | sed -E 's/.*Total[[:space:]]+latency:[[:space:]]+([0-9]+\.?[0-9]*)[[:space:]]+ns.*/\1/'
}

run_one() {
    local app="$1"
    local mode="$2"
    local example_name
    local bitstream

    if [ "$mode" = "direct" ]; then
        example_name="$app"
    else
        example_name="${app}_cpusync"
    fi
    bitstream="$BASELINE_BASE/examples_hw/$example_name/bitstreams/cyt_top.bit"

    echo ""
    echo "============================================================"
    echo "  $app / $mode"
    echo "============================================================"
    if [ ! -f "$bitstream" ]; then
        echo "  Skipping — bitstream not found: $bitstream"
        return
    fi

    # Program FPGA.
    cp "$bitstream" "$BASELINE_BASE/bitstreams/cyt_top.bit"
    cd "$BASELINE_BASE"
    bash ./program_fpga.sh cyt_top

    # (Re)load driver.
    sudo rmmod coyote_drv 2>/dev/null || true
    sudo insmod "$BASELINE_BASE/driver/coyote_drv.ko"

    # Build SW for this example.
    local build_dir="$BASELINE_BASE/examples_sw/${example_name}_test"
    rm -rf "$build_dir"; mkdir "$build_dir"; cd "$build_dir"
    cmake ../ -DEXAMPLE="$example_name" >/dev/null
    make -j >/dev/null

    if [ ! -f bin/test ]; then
        echo "  Build failed for $example_name"
        return
    fi

    # Measurement loop: run ./test --reps N once, parse throughput/latency.
    cd bin
    local out
    out=$(./test -r "$N_REPS" 2>&1)
    local log_file="$LOG_DIR/${example_name}_$(date +%Y%m%d_%H%M%S).log"
    echo "$out" > "$log_file"

    local thr lat
    thr=$(extract_throughput "$out")
    lat=$(extract_latency "$out")
    echo "  Throughput: ${thr:-N/A} MB/s   Latency: ${lat:-N/A} ns   (log: $log_file)"

    if [ -n "$thr" ] && [ -n "$lat" ]; then
        local ts; ts=$(date '+%Y-%m-%d %H:%M:%S')
        echo "$app,$mode,$thr,$lat,$N_REPS,$ts" >> "$CSV_FILE"
    else
        echo "  WARN: failed to parse metrics — see log."
    fi
}

for app in "${apps[@]}"; do
    for mode in "${modes[@]}"; do
        run_one "$app" "$mode"
    done
done

echo ""
echo "Done. Rows appended to $CSV_FILE"
echo "Logs:        $LOG_DIR"
