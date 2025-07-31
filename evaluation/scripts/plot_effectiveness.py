import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

# Set seaborn style like the reference
sns.set(font_scale=1.4)
sns.set_style("ticks")

# Set font to match ASPLOS paper style
plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.serif'] = ['Times New Roman', 'DejaVu Serif', 'Computer Modern Roman']
plt.rcParams['mathtext.fontset'] = 'cm'
plt.rcParams['font.size'] = 16
plt.rcParams['axes.labelsize'] = 16
plt.rcParams['xtick.labelsize'] = 16
plt.rcParams['ytick.labelsize'] = 16
plt.rcParams['legend.fontsize'] = 14

# Use color setup similar to reference
palette = sns.color_palette("pastel")
color1 = palette[0]  # Blue for CPU-sync
color2 = palette[1]   # Orange for direct communication (IPC)

# Data
applications = ["Audio Processing", "Digital Signature", "Secure Storage", "Signed Compression", "Speech Recognition"]

# Sample data (replace with your actual values)
cpu_sync_values = [85.9, 208.0, 139.9, 146.0, 29.2]  # CPU-sync throughput
ipc_values = [225.6, 239.2, 159.3, 154.1, 69.6]  # IPC throughput

# Create plot
fig, ax = plt.subplots(figsize=(16, 5.5))

# Bar settings
bar_width = 0.35
x_positions = np.arange(len(applications))

# Plot bars
bars1 = ax.bar(x_positions - bar_width/2, cpu_sync_values, bar_width,
                color=color1, alpha=1.0, edgecolor='black', linewidth=0.5,
                label='CPU-sync')  # Solid color, no hatch

bars2 = ax.bar(x_positions + bar_width/2, ipc_values, bar_width,
                color=color2, alpha=1.0, edgecolor='black', linewidth=0.5,
                hatch='\\\\', label='direct communication (IPC)')  # With pattern

# Styling
ax.set_ylabel('Throughput (MB/s)')
ax.set_ylim(0, 300)
ax.set_yticks([0, 50, 100, 150, 200, 250, 300])

# X-axis
ax.set_xticks(x_positions)
ax.set_xticklabels(applications)

# Grid
ax.grid(True, alpha=0.3, axis='y', color='gray')
ax.set_axisbelow(True)

# Remove top and right spines
sns.despine(ax=ax)

# Legend
ax.legend(bbox_to_anchor=(1, 1.01), loc='upper right', frameon=True, ncol=1, fontsize=14,
          handlelength=2.0, handletextpad=0.5)

# Clean annotation
ax.text(0.5, 0.98, 'Higher is better ↑', transform=ax.transAxes,
        color='navy', weight='bold', fontsize=16, ha='center', va='top')

plt.tight_layout()
plt.savefig("plot_fpga_acceleration_effectiveness.png", dpi=300, bbox_inches='tight')
plt.savefig("plot_fpga_acceleration_effectiveness.pdf", bbox_inches='tight')
plt.show()