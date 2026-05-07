import csv
import os
import statistics
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

# ===== FONT AND STYLE SETTINGS =====
FONT_SIZE = 10
LABEL_SIZE = 10
TICK_SIZE = 10
LEGEND_SIZE = 10
ANNOTATION_SIZE = 10
SPEEDUP_SIZE = 8

# Set font to match ASPLOS paper style
# plt.rcParams['font.family'] = 'serif'
# plt.rcParams['font.serif'] = ['Times New Roman', 'DejaVu Serif', 'Computer Modern Roman']
plt.rcParams['mathtext.fontset'] = 'cm'
plt.rcParams['font.size'] = FONT_SIZE
plt.rcParams['axes.labelsize'] = LABEL_SIZE
plt.rcParams['xtick.labelsize'] = TICK_SIZE
plt.rcParams['ytick.labelsize'] = TICK_SIZE
plt.rcParams['legend.fontsize'] = LEGEND_SIZE

# ===== COLOR SETUP =====
palette = sns.color_palette("pastel")
color1 = palette[0]  # Blue for CPU-sync
color2 = palette[1]  # Orange for direct communication (IPC)

# ===== DATA =====
applications = ["Audio\nProcessing", "Digital\nSignature", "Secure\nStorage", "Signed\nCompression", "Speech\nRecognition"]

# Internal app keys (CSV uses these); display labels above are what the
# x-axis renders.
app_keys = ["audio_processing", "digital_signature", "secure_storage",
            "signed_compression", "speech_recognition"]

# Paper values — used as a fallback if no measurement CSV is present, so the
# plot still renders against the original numbers.
PAPER_CPU_SYNC = [61.2, 215.1, 153.9, 149.3, 26.0]
PAPER_IPC      = [225.8, 239.5, 159.8, 154.4, 69.7]
PAPER_CPU_ERR  = [0.1, 1.4, 0.4, 0.2, 0.0]
PAPER_IPC_ERR  = [0.5, 1.2, 0.1, 0.0, 0.0]

CSV_PATH = os.path.join(os.path.dirname(__file__), "..", "..", "data", "effectiveness", "effectiveness.csv")

def load_measurements():
    """Aggregate (app, mode) -> (mean throughput, stddev). Multiple CSV rows
    for the same (app, mode) are averaged; the std-dev across rows becomes
    the error bar. Missing entries fall back to the paper numbers above so
    partial measurements still produce a sensible plot."""
    if not os.path.exists(CSV_PATH):
        print(f"[plot_effectiveness] {CSV_PATH} not found — using paper numbers.")
        return PAPER_CPU_SYNC[:], PAPER_IPC[:], PAPER_CPU_ERR[:], PAPER_IPC_ERR[:]

    samples = {}  # (app, mode) -> [throughputs]
    with open(CSV_PATH) as f:
        for row in csv.DictReader(f):
            try:
                thr = float(row["throughput_MBps"])
            except (KeyError, ValueError):
                continue
            samples.setdefault((row["app"], row["mode"]), []).append(thr)

    cpu, ipc, cpu_err, ipc_err = [], [], [], []
    for i, app in enumerate(app_keys):
        cs = samples.get((app, "cpu_sync"))
        if cs:
            cpu.append(sum(cs) / len(cs))
            cpu_err.append(statistics.stdev(cs) if len(cs) > 1 else 0.0)
        else:
            cpu.append(PAPER_CPU_SYNC[i]); cpu_err.append(PAPER_CPU_ERR[i])
        ds = samples.get((app, "direct"))
        if ds:
            ipc.append(sum(ds) / len(ds))
            ipc_err.append(statistics.stdev(ds) if len(ds) > 1 else 0.0)
        else:
            ipc.append(PAPER_IPC[i]); ipc_err.append(PAPER_IPC_ERR[i])
    return cpu, ipc, cpu_err, ipc_err

cpu_sync_values, ipc_values, cpu_sync_errors, ipc_errors = load_measurements()

# ===== PLOT SETUP =====
width = 5.8
height = 2.4
fig, ax = plt.subplots(figsize=(width, height))

# Bar settings
bar_width = 0.24
x_positions = np.arange(len(applications))

# Common bar properties
bar_props = {
    'alpha': 1.0,
    'edgecolor': 'k',
    'linewidth': 1.0,
    'error_kw': {'ecolor': 'black', 'elinewidth': 1, 'capsize': 2}
}

# ===== PLOTTING BARS =====
# CPU-sync bars (solid)
bars1 = ax.bar(x_positions - bar_width/2, cpu_sync_values, bar_width,
                yerr=cpu_sync_errors, color=color1, hatch='//',
                label='CPU-sync', **bar_props)

# IPC bars (with pattern)
bars2 = ax.bar(x_positions + bar_width/2, ipc_values, bar_width,
                yerr=ipc_errors, color=color2, hatch='\\\\',
                label='Direct comm.', **bar_props)

# ===== SPEEDUP ANNOTATIONS =====
for i, (cpu_val, ipc_val, cpu_err, ipc_err) in enumerate(zip(cpu_sync_values, ipc_values, cpu_sync_errors, ipc_errors)):
    # Speedup of IPC over CPU-sync
    speedup = ipc_val / cpu_val
    x_pos = x_positions[i] + bar_width/2
    y_pos = ipc_val + ipc_err + 3

    ax.text(x_pos + 0.01, y_pos + 1, f'{speedup:.1f}x', ha='center', va='bottom',
            fontsize=SPEEDUP_SIZE, rotation=90, weight='bold')

# ===== AXIS FORMATTING =====
ax.set_ylabel('Throughput (MB/s)')
ax.set_ylim(0, 280)
ax.set_yticks([0, 50, 100, 150, 200, 250])

# X-axis
ax.set_xticks(x_positions)
ax.set_xticklabels(applications, ha='center')

# Grid
ax.grid(True, alpha=0.3, axis='y', color='gray')
ax.set_axisbelow(True)

# Remove top and right spines
sns.despine(ax=ax)

# ===== LEGEND =====
ax.legend(loc='upper right', frameon=True, ncol=1,
          handlelength=2.0, handletextpad=0.5,
          bbox_to_anchor=(1.0, 1.15))

# ===== ANNOTATIONS =====
ax.text(0.50, 1.1, 'Higher is better ↑', transform=ax.transAxes,
        color='navy', weight='bold', fontsize=ANNOTATION_SIZE,
        ha='center', va='top')

# ===== SAVE AND DISPLAY =====
plt.tight_layout()
#plt.savefig("direct_comm_effectiveness.png", dpi=300, bbox_inches='tight')
plt.savefig("../../plots/effectiveness/direct_comm_effectiveness.pdf", bbox_inches='tight')
plt.show()