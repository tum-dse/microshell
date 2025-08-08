import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

# ===== FONT AND STYLE SETTINGS =====
FONT_SIZE = 10
LABEL_SIZE = 11
TICK_SIZE = 10
LEGEND_SIZE = 9
ANNOTATION_SIZE = 10
SPEEDUP_SIZE = 7

# Set font to match ASPLOS paper style
plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.serif'] = ['Times New Roman', 'DejaVu Serif', 'Computer Modern Roman']
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

# Throughput values (MB/s)
cpu_sync_values = [85.9, 208.0, 139.9, 146.0, 29.2]
ipc_values = [225.6, 239.2, 159.3, 154.1, 69.6]

# Error data (standard deviations)
cpu_sync_errors = [3.2, 5.1, 4.2, 3.8, 1.2]
ipc_errors = [4.5, 5.8, 3.9, 4.1, 2.1]

# ===== PLOT SETUP =====
fig, ax = plt.subplots(figsize=(10, 4))

# Bar settings
bar_width = 0.35
x_positions = np.arange(len(applications))

# Common bar properties
bar_props = {
    'alpha': 1.0,
    'edgecolor': 'k',
    'linewidth': 0.5,
    'error_kw': {'ecolor': 'black', 'elinewidth': 1, 'capsize': 2}
}

# ===== PLOTTING BARS =====
# CPU-sync bars (solid)
bars1 = ax.bar(x_positions - bar_width/2, cpu_sync_values, bar_width,
                yerr=cpu_sync_errors, color=color1, 
                label='CPU-sync', **bar_props)

# IPC bars (with pattern)
bars2 = ax.bar(x_positions + bar_width/2, ipc_values, bar_width,
                yerr=ipc_errors, color=color2, hatch='\\\\',
                label='direct communication (IPC)', **bar_props)

# ===== SPEEDUP ANNOTATIONS =====
for i, (cpu_val, ipc_val, cpu_err, ipc_err) in enumerate(zip(cpu_sync_values, ipc_values, cpu_sync_errors, ipc_errors)):
    # Speedup of IPC over CPU-sync
    speedup = ipc_val / cpu_val
    x_pos = x_positions[i] + bar_width/2
    y_pos = ipc_val + ipc_err + 3
    
    ax.text(x_pos, y_pos, f'{speedup:.2f}x', ha='center', va='bottom',
            fontsize=SPEEDUP_SIZE, weight='normal')

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
          bbox_to_anchor=(1, 1))

# ===== ANNOTATIONS =====
ax.text(0.5, 0.98, 'Higher is better ↑', transform=ax.transAxes,
        color='navy', weight='bold', fontsize=ANNOTATION_SIZE, 
        ha='center', va='top')

# ===== SAVE AND DISPLAY =====
plt.tight_layout()
#plt.savefig("plot_fpga_acceleration_effectiveness.png", dpi=300, bbox_inches='tight')
plt.savefig("../plots/plot_fpga_acceleration_effectiveness.pdf", bbox_inches='tight')
plt.show()