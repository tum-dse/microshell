import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

# ===== FONT AND STYLE SETTINGS =====
FONT_SIZE = 10
LABEL_SIZE = 12
TICK_SIZE = 12
LEGEND_SIZE = 12
ANNOTATION_SIZE = 12
SPEEDUP_SIZE = 10

plt.rcParams['mathtext.fontset'] = 'cm'
plt.rcParams['font.size'] = FONT_SIZE
plt.rcParams['axes.labelsize'] = LABEL_SIZE
plt.rcParams['xtick.labelsize'] = TICK_SIZE
plt.rcParams['ytick.labelsize'] = TICK_SIZE
plt.rcParams['legend.fontsize'] = LEGEND_SIZE

# ===== COLOR SETUP =====
palette = sns.color_palette("pastel")
color1 = palette[0]  # Blue
color2 = palette[1]  # Orange
color3 = palette[2]  # Green
size_colors = [color1, color2, color3]  # Order: 8KB=Orange, 256KB=Blue, 1MB=Green

# ===== DATA =====
applications = ["Audio Processing", "Digital Signature", "Secure Storage", "Signed Compression", "Speech Recognition"]
display_names = ["Audio Processing", "Digital Signature", "Secure Storage", "Signed Compression", "Speech Recognition"]
data_sizes = ["8KB", "256KB", "1MB"]

# Format: [baseline, µShell_mono, µShell] for each data size
data = {
    "Audio Processing": [97.9, 98.5, 95.0, 224.9, 226.0, 219.0, 225.8, 224.8, 218.8],
    "Digital Signature": [88.4, 87.3, 84.8, 233.1, 233.9, 229.4, 239.5, 238.3, 232.3],
    "Secure Storage": [147.3, 146.8, 141.0, 159.6, 158.5, 150.5, 159.8, 160.7, 155.7],
    "Signed Compression": [73.5, 74.5, 72.3, 150.1, 149.2, 143.7, 154.4, 153.6, 150.6],
    "Speech Recognition": [82.0, 81.2, 77.4, 69.9, 70.6, 67.8, 69.6, 70.2, 67.4]
}

# Error data (standard deviations)
error_data = {
    "Audio Processing": [10.2, 10.0, 10.0, 3.4, 2.0, 2.0, 0.5, 0.5, 0.5],
    "Digital Signature": [1.2, 1.2, 1.2, 0.2, 0.2, 0.2, 1.2, 0.2, 0.2],
    "Secure Storage": [0.5, 0.2, 0.2, 0.0, 0.6, 0.6, 0.1, 0.1, 0.1],
    "Signed Compression": [0.1, 0.1, 0.1, 0.5, 0.4, 0.4, 0.0, 0.0, 0.0],
    "Speech Recognition": [0.5, 0.5, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
}

# ===== PLOT SETUP =====
fig, ax = plt.subplots(figsize=(16, 4))

# Bar settings
bar_width = 0.1
group_spacing = 1.2
x_positions = np.arange(len(applications)) * group_spacing

# Hatch patterns: solid, diagonal, dotted
hatch_patterns = ["", "//", ".."]

# ===== PLOTTING BARS =====
for size_idx, size in enumerate(data_sizes):
    baseline_values = []
    ushell_mono_values = []
    ushell_values = []
    baseline_errors = []
    ushell_mono_errors = []
    ushell_errors = []
    x_baseline = []
    x_ushell_mono = []
    x_ushell = []

    # Collect data for current size
    for app_idx, app in enumerate(applications):
        baseline_val = data[app][size_idx * 3]
        ushell_mono_val = data[app][size_idx * 3 + 1]
        ushell_val = data[app][size_idx * 3 + 2]

        baseline_err = error_data[app][size_idx * 3]
        ushell_mono_err = error_data[app][size_idx * 3 + 1]
        ushell_err = error_data[app][size_idx * 3 + 2]

        if baseline_val is not None:
            baseline_values.append(baseline_val)
            baseline_errors.append(baseline_err)
            x_baseline.append(x_positions[app_idx] + size_idx * (bar_width * 3))

        if ushell_mono_val is not None:
            ushell_mono_values.append(ushell_mono_val)
            ushell_mono_errors.append(ushell_mono_err)
            x_ushell_mono.append(x_positions[app_idx] + size_idx * (bar_width * 3) + bar_width)

        if ushell_val is not None:
            ushell_values.append(ushell_val)
            ushell_errors.append(ushell_err)
            x_ushell.append(x_positions[app_idx] + size_idx * (bar_width * 3) + bar_width * 2)

    # Common bar properties
    bar_props = {
        'alpha': 1.0,
        'edgecolor': 'k',
        'linewidth': 1,
        'error_kw': {'ecolor': 'black', 'elinewidth': 1, 'capsize': 2}
    }

    # Plot bars with their respective patterns
    if baseline_values:
        ax.bar(x_baseline, baseline_values, bar_width,
               yerr=baseline_errors, color=size_colors[size_idx],
                hatch='//', **bar_props)

    if ushell_mono_values:
        ax.bar(x_ushell_mono, ushell_mono_values, bar_width,
               yerr=ushell_mono_errors, color=size_colors[size_idx],
               hatch='\\\\', **bar_props)

    if ushell_values:
        ax.bar(x_ushell, ushell_values, bar_width,
               yerr=ushell_errors, color=size_colors[size_idx],
               hatch='..', **bar_props)

# ===== SPEEDUP ANNOTATIONS =====
for size_idx, size in enumerate(data_sizes):
    for app_idx, app in enumerate(applications):
        baseline_val = data[app][size_idx * 3]
        ushell_mono_val = data[app][size_idx * 3 + 1]
        ushell_val = data[app][size_idx * 3 + 2]

        # Get error values for positioning
        ushell_mono_err = error_data[app][size_idx * 3 + 1]
        ushell_err = error_data[app][size_idx * 3 + 2]

        # Speedup for µShell_mono
        if baseline_val is not None and ushell_mono_val is not None:
            speedup = ushell_mono_val / baseline_val
            x_pos = x_positions[app_idx] + size_idx * (bar_width * 3) + bar_width
            y_pos = ushell_mono_val + ushell_mono_err + 4

            ax.text(x_pos + 0.01, y_pos, f'{speedup:.2f}x', ha='center', va='bottom',
                   fontsize=SPEEDUP_SIZE, rotation=90, weight='bold')

        # Speedup for µShell
        if baseline_val is not None and ushell_val is not None:
            speedup = ushell_val / baseline_val
            x_pos = x_positions[app_idx] + size_idx * (bar_width * 3) + bar_width * 2
            y_pos = ushell_val + ushell_err + 4

            ax.text(x_pos + 0.01, y_pos, f'{speedup:.2f}x', ha='center', va='bottom',
                   fontsize=SPEEDUP_SIZE, rotation=90, weight='bold')

# ===== AXIS FORMATTING =====
ax.set_ylabel('Throughput [MB/s]', fontsize=LABEL_SIZE)
ax.set_ylim(0, 275)
ax.set_yticks([0, 50, 100, 150, 200, 250])

# X-axis
group_centers = x_positions + (len(data_sizes) * bar_width * 3 - bar_width) / 2
ax.set_xticks(group_centers)
ax.set_xticklabels(display_names, ha='center', fontsize=LABEL_SIZE)

# Grid
ax.grid(True, alpha=0.3, axis='y', color='gray')
ax.set_axisbelow(True)

# Remove top and right spines
sns.despine(ax=ax)

# ===== LEGEND =====
from matplotlib.patches import Patch
legend_elements = []

# Data size colors
for size_idx, (size, color) in enumerate(zip(data_sizes, size_colors)):
    legend_elements.append(Patch(facecolor=color, edgecolor="k", alpha=1.0, label=size))  # Added edgecolor="k"

# Platform patterns
legend_elements.append(Patch(facecolor='white', edgecolor="k", alpha=1.0, hatch='//', label='Coyote'))  # Added edgecolor="k"
legend_elements.append(Patch(facecolor='white', edgecolor="k", alpha=1.0, hatch='\\\\', label='µShell_mono'))  # Added edgecolor="k"
legend_elements.append(Patch(facecolor='white', edgecolor="k", alpha=1.0, hatch='..', label='µShell'))  # Added edgecolor="k"

# Updated legend
ax.legend(handles=legend_elements, loc='upper right', frameon=True,
          ncol=2, bbox_to_anchor=(1, 1.08))

# ===== ANNOTATION =====
fig.suptitle('Higher is better ↑', fontsize=ANNOTATION_SIZE, color='navy',
             weight='bold', x=0.5, y=0.89)

# ===== SAVE AND DISPLAY =====
plt.tight_layout()
plt.subplots_adjust(bottom=0.1)
#plt.savefig("e2e.png", dpi=300, bbox_inches='tight')
plt.savefig("../plots/e2e.pdf", bbox_inches='tight')
plt.show()