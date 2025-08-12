import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

# ===== FONT AND STYLE SETTINGS =====
FONT_SIZE = 10
LABEL_SIZE = 10
TICK_SIZE = 10
LEGEND_SIZE = 9
ANNOTATION_SIZE = 9
VALUE_SIZE = 7


plt.rcParams['mathtext.fontset'] = 'cm'
plt.rcParams['font.size'] = FONT_SIZE
plt.rcParams['axes.labelsize'] = LABEL_SIZE
plt.rcParams['xtick.labelsize'] = TICK_SIZE
plt.rcParams['ytick.labelsize'] = TICK_SIZE
plt.rcParams['legend.fontsize'] = LEGEND_SIZE

# ===== COLOR SETUP =====
palette = sns.color_palette("pastel")
color1 = palette[0]  # Blue for vFPGA=1
color2 = palette[1]  # Orange for vFPGA=2
color3 = palette[2]  # Green for vFPGA=4
color4 = palette[3]  # Red for vFPGA=8

# ===== DATA =====
resources = ["LUTs", "Registers", "BRAM", "URAM"]

# Percentage of available resources per vFPGA
vfpga1_values = [96.93, 96.83, 97.72, 100.0]
vfpga2_values = [47.75, 47.69, 48.12, 50.0]
vfpga4_values = [21.04, 21.38, 22.17, 25.0]
vfpga8_values = [10.87, 10.82, 10.91, 12.5]

# ===== PLOT SETUP =====
width = 4.0
height = 2.8
fig, ax = plt.subplots(figsize=(width, height))

# Bar settings
bar_width = 0.18
x_positions = np.arange(len(resources))

# Common bar properties
bar_props = {
    'alpha': 1.0,
    'edgecolor': 'k',
    'linewidth': 1.0
}

# ===== PLOTTING BARS =====
# vFPGA=1 bars (solid)
bars1 = ax.bar(x_positions - 1.5*bar_width, vfpga1_values, bar_width,
                color=color1, hatch='//',
                label='vFPGA=1', **bar_props)

# vFPGA=2 bars (diagonal pattern)
bars2 = ax.bar(x_positions - 0.5*bar_width, vfpga2_values, bar_width,
                color=color2, hatch='\\\\',
                label='vFPGA=2', **bar_props)

# vFPGA=4 bars (dotted pattern)
bars3 = ax.bar(x_positions + 0.5*bar_width, vfpga4_values, bar_width,
                color=color3, hatch='..',
                label='vFPGA=4', **bar_props)

# vFPGA=8 bars (cross pattern)
bars4 = ax.bar(x_positions + 1.5*bar_width, vfpga8_values, bar_width,
                color=color4, hatch='xx',
                label='vFPGA=8', **bar_props)

# ===== VALUE ANNOTATIONS =====
# Add percentage values on top of bars
def add_value_labels(bars, values):
    for bar, val in zip(bars, values):
        height = bar.get_height()
        # Format 100.0 as "100%" and others with one decimal
        if val == 100.0:
            label = '100%'
        else:
            label = f'{val:.1f}%'
        ax.text(bar.get_x() + bar.get_width()/2. + 0.03, height + 1.1,
                label, ha='center', va='bottom',
                fontsize=VALUE_SIZE, rotation=90, weight='bold')

# Add labels for each set of bars
add_value_labels(bars1, vfpga1_values)
add_value_labels(bars2, vfpga2_values)
add_value_labels(bars3, vfpga4_values)
add_value_labels(bars4, vfpga8_values)

# ===== AXIS FORMATTING =====
ax.set_ylabel('Available resource per vFPGA (%)')
ax.set_ylim(0, 135)
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
ax.legend(loc='upper right', frameon=True, ncol=2,
          handlelength=2.0, handletextpad=0.5, columnspacing=1.0,
          bbox_to_anchor=(1, 1.14))

# ===== ANNOTATIONS =====
ax.text(0.1, 1.08, 'Higher is better ↑', transform=ax.transAxes,
        color='navy', weight='bold', fontsize=ANNOTATION_SIZE,
        ha='center', va='top')

# ===== SAVE AND DISPLAY =====
plt.tight_layout()
#plt.savefig("scalability_analysis.png", dpi=300, bbox_inches='tight')
plt.savefig("../plots/scalability_analysis.pdf", bbox_inches='tight')
plt.show()