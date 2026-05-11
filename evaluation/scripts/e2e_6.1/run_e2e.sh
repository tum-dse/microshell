#!/bin/bash
# Driver for the e2e end-to-end-throughput experiment (Figure 11).
#
# Runs each of the 5 paper apps in 3 systems × 3 sizes = 9 cells per app:
#   - "coyote"      : composed pipeline on baseline Coyote v2 shell
#                      (same HDL as Fig 3 "direct").
#   - "ushell_mono" : monolithic single-vFPGA on µShell (microshell repo).
#   - "ushell"      : composed pipeline on µShell, routed through the
#                      µShell switch (microshell repo).
# Default sizes: 8 KB / 256 KB / 1 MB.
#
# Bitstream lookup priority per (app, system):
#   1. Fresh bitgen output in the build dir → auto-stage to the labeled
#      bitstream and use it.
#   2. Pre-staged <base>/bitstreams/<label>_top.bit (from
#      stage_bitstreams_e2e.sh, or manually placed).
#   3. Skip with a SKIP marker.
#
# Programming uses sudo bash ./program_fpga.sh <label>. Each ./test
# invocation is gated by a 120s timeout; on hang we kill, persist the
# captured output as a log, unload the driver, and continue to the next
# size.
#
# CSV schema (rows tagged source=measured):
#   app,system,size_bytes,throughput_MBps,latency_ns,n_reps,stddev_MBps,
#   source,timestamp
# Paper baseline rows (source=paper) are pre-populated in e2e.csv so
# plot_e2e.py has a per-cell fallback. Run this orchestrator multiple
# times for averaged numbers — plot_e2e.py averages across measured rows
# and uses std-dev as the error bar.

set -e

usage() {
    echo "Usage: $0 <baseline_base_dir> <microshell_base_dir> [--reps N] [--sizes A,B,C]"
    echo ""
    echo "  baseline_base_dir   Path to baseline (Coyote v2) repo — supplies"
    echo "                      coyote bitstreams + SW."
    echo "  microshell_base_dir Path to µShell repo — supplies ushell and"
    echo "                      ushell_mono bitstreams + SW."
    echo "  --sizes A,B,C       Comma-separated transfer sizes in bytes."
    echo "                      Default: 8192,262144,1048576 (= 8 KB, 256 KB, 1 MB)."
    echo ""
    echo "Auto-enters nix-shell at the baseline root if not already inside one."
    echo "Each ./test runs with the SW default of 1 rep (matches Fig 3 convention —"
    echo "reps>1 risks hangs in some SW paths). Run multiple times for averaged"
    echo "Fig 11 numbers; plot_e2e.py averages measured rows."
    exit 1
}

if [ $# -lt 2 ]; then usage; fi
BASELINE_BASE=$(realpath "$1"); shift
MSHELL_BASE=$(realpath "$1"); shift
SIZES_CSV="8192,262144,1048576"
while [ $# -gt 0 ]; do
    case "$1" in
        --sizes) SIZES_CSV="$2"; shift 2 ;;
        *) echo "Unknown arg: $1"; usage ;;
    esac
done
IFS=',' read -ra SIZES <<< "$SIZES_CSV"

for base in "$BASELINE_BASE" "$MSHELL_BASE"; do
    if [ ! -d "$base/examples_sw" ] || [ ! -f "$base/program_fpga.sh" ]; then
        echo "Error: $base doesn't look like a valid repo (missing examples_sw/ or program_fpga.sh)"
        exit 1
    fi
done

# Auto-wrap in nix-shell if we aren't already inside one. Re-execs the script
# from inside `nix-shell shell.nix` at the baseline root.
if [ -z "$IN_NIX_SHELL" ]; then
    if [ ! -f "$BASELINE_BASE/shell.nix" ]; then
        echo "Error: $BASELINE_BASE/shell.nix not found"
        echo "  Cannot enter nix-shell. Either install shell.nix in baseline or"
        echo "  run inside an existing nix-shell session."
        exit 1
    fi
    SCRIPT=$(realpath "$0")
    echo "[run_e2e] entering nix-shell at $BASELINE_BASE..."
    cd "$BASELINE_BASE"
    exec nix-shell shell.nix --run "bash '$SCRIPT' '$BASELINE_BASE' '$MSHELL_BASE' --sizes $SIZES_CSV"
fi

EVAL_DIR="$(dirname "$(realpath "$0")")/../../data/e2e_6.1"
mkdir -p "$EVAL_DIR"
CSV_FILE="$EVAL_DIR/e2e.csv"
LOG_DIR="$EVAL_DIR/e2e_logs"
mkdir -p "$LOG_DIR"

if [ ! -f "$CSV_FILE" ]; then
    echo "app,system,size_bytes,throughput_MBps,latency_ns,n_reps,stddev_MBps,source,timestamp" > "$CSV_FILE"
fi

apps=(audio_processing digital_signature secure_storage signed_compression speech_recognition)
systems=(coyote ushell_mono ushell)

declare -A app_short=(
    [audio_processing]=audio
    [digital_signature]=digital
    [secure_storage]=secure
    [signed_compression]=signed
    [speech_recognition]=speech
)

# Per-test timeout (seconds). Largest cell (1 MB × 5 reps) completes well
# under 1 s on a working build; this is a safety guard for HW-level hangs.
TEST_TIMEOUT=120

extract_throughput() {
    echo "$1" | grep -E "^[[:space:]]*Throughput:" | head -1 \
        | sed -E 's/.*Throughput:[[:space:]]+([0-9]+\.?[0-9]*).*MB\/s.*/\1/'
}
extract_latency() {
    echo "$1" | grep -E "^[[:space:]]*Total[[:space:]]+latency:" | head -1 \
        | sed -E 's/.*Total[[:space:]]+latency:[[:space:]]+([0-9]+\.?[0-9]*)[[:space:]]+ns.*/\1/'
}

# Run a step silently. On failure, persist combined stdout+stderr to a log
# under $LOG_DIR and echo a one-line failure marker. Returns the command's
# exit code so the caller can decide whether to skip the iteration.
# Usage: run_step <human-label> <log-basename> <cmd...>
run_step() {
    local label="$1" basename="$2"; shift 2
    local tmplog persist rc
    tmplog=$(mktemp)
    set +e
    "$@" >"$tmplog" 2>&1
    rc=$?
    set -e
    if [ "$rc" -eq 0 ]; then
        rm -f "$tmplog"
        return 0
    fi
    persist="$LOG_DIR/${basename}_$(date +%Y%m%d_%H%M%S).log"
    mv "$tmplog" "$persist"
    echo "  $label FAILED (rc=$rc) — log: $persist"
    return "$rc"
}

# Best-effort driver unload (rmmod, then rmmod -f if the module is wedged).
unload_driver() {
    sudo rmmod coyote_drv 2>/dev/null && return 0
    sudo rmmod -f coyote_drv 2>/dev/null || true
}

# Resolve per-system base / cmake-EXAMPLE / build dir / bitstream label /
# build-dir bitstream path. Echoes 5 fields separated by '|'.
resolve_target() {
    local app="$1" system="$2"
    local short="${app_short[$app]}"
    case "$system" in
        coyote)
            echo "$BASELINE_BASE|$app|build_${short}_coyote/bitstreams/cyt_top.bit|${short}_coyote|examples_sw/build_${short}_coyote"
            ;;
        ushell)
            echo "$MSHELL_BASE|$app|$app/bitstreams/cyt_top.bit|${short}_ushell|examples_sw/build_${short}_ushell"
            ;;
        ushell_mono)
            echo "$MSHELL_BASE|${app}_monolithic|${app}_monolithic/bitstreams/cyt_top.bit|${short}_mono|examples_sw/build_${short}_mono"
            ;;
        *) return 1 ;;
    esac
}

# Resolve and stage bitstream for (app, system). Echoes the label
# (e.g. "audio_coyote") on success, empty on failure. Auto-stages a fresh
# bitgen output to the labeled location if found.
resolve_bitstream() {
    local base="$1" build_subpath="$2" label="$3"
    local fresh="$base/examples_hw/$build_subpath"
    local fresh_ltx="${fresh%.bit}.ltx"
    local staged_bit="$base/bitstreams/${label}_top.bit"
    local staged_ltx="$base/bitstreams/${label}_top.ltx"

    if [ -f "$fresh" ]; then
        mkdir -p "$base/bitstreams"
        cp "$fresh" "$staged_bit"
        [ -f "$fresh_ltx" ] && cp "$fresh_ltx" "$staged_ltx" || rm -f "$staged_ltx"
        return 0
    elif [ -f "$staged_bit" ]; then
        return 0
    else
        return 1
    fi
}

run_one_app_system() {
    local app="$1" system="$2"
    local target; target=$(resolve_target "$app" "$system")
    local base example_name build_subpath label sw_subdir
    IFS='|' read -r base example_name build_subpath label sw_subdir <<< "$target"

    echo ""
    echo "============================================================"
    echo "  $app / $system  (label=$label, repo=$base)"
    echo "============================================================"

    if ! resolve_bitstream "$base" "$build_subpath" "$label"; then
        echo "  SKIP — no bitstream (build dir or staged) for $app/$system"
        return
    fi
    echo "  bitstream:   ${label}_top.bit"

    cd "$base"
    echo "  programming FPGA..."
    if ! run_step "program_fpga" "${app}_${system}_program" \
            sudo bash ./program_fpga.sh "$label"; then
        return
    fi

    unload_driver
    if ! run_step "insmod" "${app}_${system}_insmod" \
            sudo insmod "$base/driver/coyote_drv.ko"; then
        return
    fi

    # Build SW for this (app, system). Build dir is reused across runs;
    # cmake/make is incremental.
    local build_dir="$base/$sw_subdir"
    if [ ! -f "$build_dir/bin/test" ]; then
        echo "  building SW..."
        mkdir -p "$build_dir"
        if ! run_step "cmake" "${app}_${system}_cmake" \
                bash -c "cd '$build_dir' && cmake ../ -DEXAMPLE='$example_name'"; then
            return
        fi
        if ! run_step "make"  "${app}_${system}_make" \
                bash -c "cd '$build_dir' && make -j"; then
            return
        fi
    fi
    if [ ! -f "$build_dir/bin/test" ]; then
        echo "  SKIP — SW build did not produce $build_dir/bin/test"
        return
    fi

    for size in "${SIZES[@]}"; do
        local out rc persist
        # `sudo` precedes `timeout` so timeout runs as root and can SIGKILL
        # the test child directly after the grace period.
        set +e
        out=$(cd "$build_dir/bin" && sudo timeout --kill-after=5 "$TEST_TIMEOUT" \
                ./test -s "$size" 2>&1)
        rc=$?
        set -e

        if [ "$rc" -eq 124 ] || [ "$rc" -eq 137 ]; then
            persist="$LOG_DIR/${app}_${system}_${size}_timeout_$(date +%Y%m%d_%H%M%S).log"
            echo "$out" > "$persist"
            echo "  size=$size: TIMEOUT after ${TEST_TIMEOUT}s — log: $persist"
            unload_driver
            continue
        fi
        if [ "$rc" -ne 0 ]; then
            persist="$LOG_DIR/${app}_${system}_${size}_fail_$(date +%Y%m%d_%H%M%S).log"
            echo "$out" > "$persist"
            echo "  size=$size: test FAILED (rc=$rc) — log: $persist"
            continue
        fi

        local thr lat
        thr=$(extract_throughput "$out")
        lat=$(extract_latency "$out")

        if [ -n "$thr" ] && [ -n "$lat" ]; then
            printf "  size=%-7s thr=%s MB/s   lat=%s ns\n" "$size" "$thr" "$lat"
            local ts; ts=$(date '+%Y-%m-%d %H:%M:%S')
            # stddev_MBps=0 — single sample; aggregation across rows happens
            # in plot_e2e.py.
            # n_reps=1 (SW default), stddev_MBps=0 (single sample). Aggregation
            # across rows happens in plot_e2e.py — run the orchestrator
            # multiple times for averaged numbers.
            echo "$app,$system,$size,$thr,$lat,1,0,measured,$ts" >> "$CSV_FILE"
        else
            persist="$LOG_DIR/${app}_${system}_${size}_parse_$(date +%Y%m%d_%H%M%S).log"
            echo "$out" > "$persist"
            echo "  size=$size: WARN — could not parse metrics (log: $persist)"
        fi
    done
}

for app in "${apps[@]}"; do
    for system in "${systems[@]}"; do
        run_one_app_system "$app" "$system"
    done
done

echo ""
echo "Done. Rows appended to $CSV_FILE"
echo "Logs:        $LOG_DIR"
echo ""
echo "For averaged Figure 11 numbers, run this orchestrator 4 more times."
echo "Then: python3 plot_e2e.py"
