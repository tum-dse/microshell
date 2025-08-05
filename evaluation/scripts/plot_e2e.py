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
color1 = palette[0]  # Blue
color2 = palette[1]  # Orange
color3 = '#2E8B57'    # Sea Green
size_colors = [color2, color1, color3]  # Order: 8KB=Orange, 256KB=Blue, 1MB=Green

# ===== DATA =====
applications = ["Audio Processing", "Digital Signature", "Secure Storage", "Signed Compression", "Speech Recognition"]
display_names = ["Audio Processing", "Digital Signature", "Secure Storage", "Signed Compression", "Speech Recognition"]
data_sizes = ["8KB", "256KB", "1MB"]

# Format: [baseline, µShell_mono, µShell] for each data size
data = {
    "Audio Processing": [108.1, 104.5, 105.6, 227.9, 226.4, 219.7, 225.6, 226.3, 221.4],
    "Digital Signature": [89.1, 89.0, 87.7, 232.4, 233.4, 228.2, 239.2, 239.1, 233.5],
    "Secure Storage": [148.3, 147.4, 144.1, 160.5, 159.6, 155.3, 159.3, 158.8, 154.1],
    "Signed Compression": [72.2, 73.8, 69.4, 149.8, 150.4, 144.1, 154.1, 154.3, 150.8],
    "Speech Recognition": [75.4, 80.3, 73.1, 69.7, 69.9, 68.2, 69.6, 69.6, 68.3]
}

# Error data (standard deviations)
error_data = {
    "Audio Processing": [2.5, 2.1, 2.3, 4.5, 4.2, 3.8, 3.9, 4.1, 3.7],
    "Digital Signature": [1.8, 1.9, 1.7, 3.2, 3.5, 2.9, 3.8, 3.7, 3.4],
    "Secure Storage": [2.9, 2.8, 2.5, 2.7, 2.6, 2.4, 2.8, 2.7, 2.5],
    "Signed Compression": [1.5, 1.6, 1.4, 2.4, 2.5, 2.2, 2.6, 2.6, 2.4],
    "Speech Recognition": [1.3, 1.5, 1.2, 1.1, 1.1, 1.0, 1.2, 1.2, 1.1]
}

# ===== PLOT SETUP =====
fig, ax = plt.subplots(figsize=(12, 3.5))

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
        'linewidth': 0.5,
        'error_kw': {'ecolor': 'black', 'elinewidth': 1, 'capsize': 2}
    }

    # Plot bars with their respective patterns
    if baseline_values:
        ax.bar(x_baseline, baseline_values, bar_width,
               yerr=baseline_errors, color=size_colors[size_idx], **bar_props)

    if ushell_mono_values:
        ax.bar(x_ushell_mono, ushell_mono_values, bar_width,
               yerr=ushell_mono_errors, color=size_colors[size_idx],
               hatch='//', **bar_props)

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
            y_pos = ushell_mono_val + ushell_mono_err + 3

            ax.text(x_pos, y_pos, f'{speedup:.2f}x', ha='center', va='bottom',
                   fontsize=SPEEDUP_SIZE, rotation=90, weight='bold')

        # Speedup for µShell
        if baseline_val is not None and ushell_val is not None:
            speedup = ushell_val / baseline_val
            x_pos = x_positions[app_idx] + size_idx * (bar_width * 3) + bar_width * 2
            y_pos = ushell_val + ushell_err + 3

            ax.text(x_pos, y_pos, f'{speedup:.2f}x', ha='center', va='bottom',
                   fontsize=SPEEDUP_SIZE, rotation=90, weight='bold')

# ===== AXIS FORMATTING =====
ax.set_ylabel('Throughput [MiB/s]')  # Uses LABEL_SIZE from rcParams
ax.set_ylim(0, 275)
ax.set_yticks([0, 100, 200])

# X-axis
group_centers = x_positions + (len(data_sizes) * bar_width * 3 - bar_width) / 2
ax.set_xticks(group_centers)
ax.set_xticklabels(display_names, ha='center')  # Uses TICK_SIZE from rcParams

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
    legend_elements.append(Patch(facecolor=color, alpha=1.0, label=size))

# Platform patterns
legend_elements.append(Patch(facecolor='gray', alpha=1.0, label='Coyote'))
legend_elements.append(Patch(facecolor='gray', alpha=1.0, hatch='//', label='µShell_mono'))
legend_elements.append(Patch(facecolor='gray', alpha=1.0, hatch='..', label='µShell'))

ax.legend(handles=legend_elements, loc='upper right', frameon=True, 
          ncol=2, bbox_to_anchor=(0.98, 1))  # Uses LEGEND_SIZE from rcParams

# ===== ANNOTATION =====
ax.text(0.5, 0.98, 'Higher is better ↑', transform=ax.transAxes,
        color='navy', weight='bold', fontsize=ANNOTATION_SIZE, ha='center', va='top')

# ===== SAVE AND DISPLAY =====
plt.tight_layout()
plt.subplots_adjust(top=0.98)
plt.savefig("plot_e2e.png", dpi=300, bbox_inches='tight')
plt.savefig("plot_e2e.pdf", bbox_inches='tight')
plt.show()