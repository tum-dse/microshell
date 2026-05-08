#!/bin/bash
# Spawn 10 parallel tmux sessions to bitgen Figure 11's two µShell systems:
#   5 ushell      (composed pipeline routed through µShell's switch)
#   5 ushell_mono (monolithic single-vFPGA, µShell variant of Fig 3 direct)
#
# Each session enters its build dir and runs:
#   xilinx-shell -c "cmake ../ -DEXAMPLE=<target> -DFDEV_NAME=u280 \
#                    && make project && make bitgen"
#
# Build dirs use the existing long-form example names (matches µShell's CMake
# example layout); staged labels use short forms (see stage_bitstreams_e2e.sh).
#
# Bitgen takes 3-4h per session. Sessions stay alive after bitgen so you can
# review the build via `tmux attach -t bitgen_<short>_<mode>`. Staging the
# resulting cyt_top.bit/ltx into <microshell>/bitstreams/<label>_top.{bit,ltx}
# is a SEPARATE step — see stage_bitstreams_e2e.sh.

set -e

usage() {
    echo "Usage: $0 <microshell_base_dir>"
    echo ""
    echo "  microshell_base_dir  Path to µShell repo (must have examples_hw/)."
    echo ""
    echo "Spawns 10 tmux sessions named:"
    echo "  bitgen_audio_ushell, bitgen_digital_ushell, bitgen_secure_ushell,"
    echo "  bitgen_signed_ushell, bitgen_speech_ushell,"
    echo "  bitgen_audio_mono, bitgen_digital_mono, bitgen_secure_mono,"
    echo "  bitgen_signed_mono, bitgen_speech_mono"
    echo ""
    echo "Monitor:    tmux ls"
    echo "Attach:     tmux attach -t bitgen_audio_ushell"
    echo "Detach:     Ctrl-b d"
    echo "After all sessions complete, run stage_bitstreams_e2e.sh"
    exit 1
}

if [ $# -lt 1 ]; then usage; fi
MSHELL_BASE=$(realpath "$1")

if [ ! -d "$MSHELL_BASE/examples_hw" ]; then
    echo "Error: $MSHELL_BASE/examples_hw not found"
    exit 1
fi

if ! command -v tmux &>/dev/null; then
    echo "Error: tmux is required"
    exit 1
fi

if ! command -v xilinx-shell &>/dev/null; then
    echo "Error: xilinx-shell is required (Vivado env wrapper)"
    exit 1
fi

declare -A app_short=(
    [audio_processing]=audio
    [digital_signature]=digital
    [secure_storage]=secure
    [signed_compression]=signed
    [speech_recognition]=speech
)
apps=(audio_processing digital_signature secure_storage signed_compression speech_recognition)
modes=(ushell mono)

# Make sure all 10 build dirs exist.
for app in "${apps[@]}"; do
    mkdir -p "$MSHELL_BASE/examples_hw/$app"
    mkdir -p "$MSHELL_BASE/examples_hw/${app}_monolithic"
done

echo "Spawning 10 bitgen tmux sessions in $MSHELL_BASE"
echo "================================================"

for app in "${apps[@]}"; do
    short="${app_short[$app]}"
    for mode in "${modes[@]}"; do
        cmake_target="$app"
        [ "$mode" = "mono" ] && cmake_target="${app}_monolithic"
        session="bitgen_${short}_${mode}"
        build_dir="$MSHELL_BASE/examples_hw/$cmake_target"

        # Kill any prior session with the same name.
        tmux kill-session -t "$session" 2>/dev/null || true

        tmux new-session -d -s "$session" -c "$build_dir" bash -c "
            export PATH=\$HOME/.local/cmake/bin:\$PATH
            LOG='$build_dir/bitgen.log'
            {
                echo '=== bitgen for ${short}_${mode} started '\$(date)' ==='
                xilinx-shell -c 'cmake ../ -DEXAMPLE=$cmake_target -DFDEV_NAME=u280 && make project && make bitgen'
                rc=\$?
                echo '=== bitgen for ${short}_${mode} ended '\$(date)' (exit '\$rc') ==='
            } 2>&1 | tee -a \"\$LOG\"
            exec bash
        "
        echo "  launched: $session  (build dir: $build_dir, target: $cmake_target)"
    done
done

echo ""
echo "All 10 sessions running. Useful commands:"
echo "  tmux ls                                    # list sessions"
echo "  tmux attach -t bitgen_audio_ushell         # review one"
echo "  tmux kill-session -t bitgen_audio_ushell   # cancel one"
echo ""
echo "Logs are also tee'd to <build_dir>/bitgen.log per session."
echo ""
echo "After all sessions report 'bitgen ... ended (exit 0)' and you've"
echo "reviewed the timing reports, run:"
echo "  bash stage_bitstreams_e2e.sh <baseline_base_dir> $MSHELL_BASE"
