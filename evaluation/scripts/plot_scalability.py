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

# Use color setup
palette = sns.color_palette("pastel")
color1 = palette[0]  # Blue for vFPGA=1
color2 = palette[1]   # Orange for vFPGA=2
color3 = '#2E8B57'  # Green for vFPGA=4
color4 = palette[3]  # Red for vFPGA=8

# Data
resources = ["LUTs", "Registers", "BRAM", "URAM"]

# Percentage of available resources
vfpga1_values = [93.47, 93.9, 94.25, 100]
vfpga2_values = [47.75, 47.69, 48.12, 50]
vfpga4_values = [21.04, 21.38, 22.17, 25]
vfpga8_values = [10.87, 10.82, 10.91, 12.5]

# Create plot
fig, ax = plt.subplots(figsize=(14, 6.5))

# Bar settings
bar_width = 0.18
x_positions = np.arange(len(resources))

# Plot bars with hatching patterns
bars1 = ax.bar(x_positions - 1.5*bar_width, vfpga1_values, bar_width,
                color=color1, alpha=1.0, edgecolor='black', linewidth=0.5,
                label='vFPGA=1')  # Solid color, no hatch

bars2 = ax.bar(x_positions - 0.5*bar_width, vfpga2_values, bar_width,
                color=color2, alpha=1.0, edgecolor='black', linewidth=0.5,
                hatch='\\\\', label='vFPGA=2')

bars3 = ax.bar(x_positions + 0.5*bar_width, vfpga4_values, bar_width,
                color=color3, alpha=1.0, edgecolor='black', linewidth=0.5,
                hatch='..', label='vFPGA=4')

bars4 = ax.bar(x_positions + 1.5*bar_width, vfpga8_values, bar_width,
                color=color4, alpha=1.0, edgecolor='black', linewidth=0.5,
                hatch='xx', label='vFPGA=8')

# Styling
ax.set_ylabel('Available resource per vFPGA (%)')
ax.set_ylim(0, 100)
ax.set_yticks([0, 20, 40, 60, 80, 100])

# X-axis
ax.set_xticks(x_positions)
ax.set_xticklabels(resources)

# Grid
ax.grid(True, alpha=0.3, axis='y', color='gray')
ax.set_axisbelow(True)

# Remove top and right spines
sns.despine(ax=ax)

# Legend
ax.legend(loc='upper right', frameon=True, ncol=1, fontsize=14,
          handlelength=2.0, handletextpad=0.5, columnspacing=1.0)

# Clean annotation
ax.text(0.5, 1.05, 'Higher is better ↑', transform=ax.transAxes,
        color='navy', weight='bold', fontsize=16, ha='center', va='top')

plt.tight_layout()
plt.savefig("plot_scalability_analysis.png", dpi=300, bbox_inches='tight')
plt.savefig("plot_scalability_analysis.pdf", bbox_inches='tight')
plt.show()