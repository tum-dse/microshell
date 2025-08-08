import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

# ===== FONT AND STYLE SETTINGS =====
FONT_SIZE = 10
LABEL_SIZE = 12
TICK_SIZE = 10
LEGEND_SIZE = 10
ANNOTATION_SIZE = 11
VALUE_SIZE = 7

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
color1 = palette[1]  # Orange for vFPGA=1
color2 = palette[0]  # Blue for vFPGA=2
color3 = '#2E8B57'    # Sea Green for vFPGA=4
color4 = palette[3]  # Red for vFPGA=8

# ===== DATA =====
resources = ["LUTs", "Registers", "BRAM", "URAM"]

# Percentage of available resources per vFPGA
vfpga1_values = [93.47, 93.9, 94.25, 100.0]
vfpga2_values = [47.75, 47.69, 48.12, 50.0]
vfpga4_values = [21.04, 21.38, 22.17, 25.0]
vfpga8_values = [10.87, 10.82, 10.91, 12.5]

# Error data (standard deviations - smaller for hardware measurements)
vfpga1_errors = [1.2, 1.1, 1.3, 0.0]  # No error for 100%
vfpga2_errors = [0.8, 0.9, 0.7, 0.5]
vfpga4_errors = [0.5, 0.6, 0.5, 0.4]
vfpga8_errors = [0.3, 0.3, 0.3, 0.2]

# ===== PLOT SETUP =====
fig, ax = plt.subplots(figsize=(12, 4.5))

# Bar settings
bar_width = 0.18
x_positions = np.arange(len(resources))

# Common bar properties
bar_props = {
    'alpha': 1.0,
    'edgecolor': 'k',
    'linewidth': 0.5,
    'error_kw': {'ecolor': 'black', 'elinewidth': 1, 'capsize': 2}
}

# ===== PLOTTING BARS =====
# vFPGA=1 bars (solid)
bars1 = ax.bar(x_positions - 1.5*bar_width, vfpga1_values, bar_width,
                yerr=vfpga1_errors, color=color1,
                label='vFPGA=1', **bar_props)

# vFPGA=2 bars (diagonal pattern)
bars2 = ax.bar(x_positions - 0.5*bar_width, vfpga2_values, bar_width,
                yerr=vfpga2_errors, color=color2, hatch='\\\\',
                label='vFPGA=2', **bar_props)

# vFPGA=4 bars (dotted pattern)
bars3 = ax.bar(x_positions + 0.5*bar_width, vfpga4_values, bar_width,
                yerr=vfpga4_errors, color=color3, hatch='..',
                label='vFPGA=4', **bar_props)

# vFPGA=8 bars (cross pattern)
bars4 = ax.bar(x_positions + 1.5*bar_width, vfpga8_values, bar_width,
                yerr=vfpga8_errors, color=color4, hatch='xx',
                label='vFPGA=8', **bar_props)

# ===== VALUE ANNOTATIONS =====
# Add percentage values on top of bars
def add_value_labels(bars, values, errors):
    for bar, val, err in zip(bars, values, errors):
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height + err + 1,
                f'{val:.1f}%', ha='center', va='bottom',
                fontsize=VALUE_SIZE, rotation=0)

# Add labels for each set of bars
add_value_labels(bars1, vfpga1_values, vfpga1_errors)
add_value_labels(bars2, vfpga2_values, vfpga2_errors)
add_value_labels(bars3, vfpga4_values, vfpga4_errors)
add_value_labels(bars4, vfpga8_values, vfpga8_errors)

# ===== AXIS FORMATTING =====
ax.set_ylabel('Available resource per vFPGA (%)')
ax.set_ylim(0, 100)  
ax.set_yticks([0, 20, 40, 60, 80, 100])

# X-axis
ax.set_xticks(x_positions)
ax.set_xticklabels(resources, ha='center')

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
ax.text(0.5, 1.05, 'Higher is better ↑', transform=ax.transAxes,
        color='navy', weight='bold', fontsize=ANNOTATION_SIZE, 
        ha='center', va='top')

# ===== SAVE AND DISPLAY =====
plt.tight_layout()
#plt.savefig("plot_scalability_analysis.png", dpi=300, bbox_inches='tight')
plt.savefig("../plots/plot_scalability_analysis.pdf", bbox_inches='tight')
plt.show()