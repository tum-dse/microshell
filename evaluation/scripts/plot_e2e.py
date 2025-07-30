import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

# Set seaborn style like the clean reference
sns.set(font_scale=1.4)
sns.set_style("ticks")

# Set font to match ASPLOS paper style
plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.serif'] = ['Times New Roman', 'DejaVu Serif', 'Computer Modern Roman']
plt.rcParams['mathtext.fontset'] = 'cm'  # Computer Modern for math
plt.rcParams['font.size'] = 16
plt.rcParams['axes.labelsize'] = 16
plt.rcParams['xtick.labelsize'] = 16
plt.rcParams['ytick.labelsize'] = 16
plt.rcParams['legend.fontsize'] = 14

# Use exact color setup from reference script
palette = sns.color_palette("pastel")
color1 = palette[0]  # Blue
color2 = palette[1]  # Orange
color3 = '#2E8B57'    # Sea Green (from the other plot)
palette_console = [color2, color1, color3]  # Only 3 colors needed now
size_colors = palette_console

# Data
applications = ["Audio Processing", "Digital Signature", "Secure Storage", "Signed Compression", "Speech Recognition"]
display_names = ["Audio Processing", "Digital Signature", "Secure Storage", "Signed Compression", "Speech Recognition"]
data_sizes = ["8KB", "256KB", "1MB"]

# Updated measurements from the table
# Format: [baseline, µShell, µShell_mono] for each data size
data = {
    "Audio Processing": [108.1, 105.6, 104.5, 227.9, 219.7, 226.4, 225.6, 221.4, 226.3],
    "Digital Signature": [89.1, 87.7, 89.0, 232.4, 228.2, 233.4, 239.2, 233.5, 239.1],
    "Secure Storage": [148.3, 144.1, 147.4, 160.5, 155.3, 159.6, 159.3, 154.1, 158.8],
    "Signed Compression": [72.2, 69.4, 73.8, 149.8, 144.1, 150.4, 154.1, 150.8, 154.3],
    "Speech Recognition": [75.4, 73.1, 80.3, 69.7, 70.2, 69.9, 69.6, 70.4, 69.6]
}

# Create plot with clean proportions
fig, ax = plt.subplots(figsize=(18, 5))  # Wider and shorter for double column

# Bar settings - joined bars like the reference
bar_width = 0.1  # Slightly wider bars
group_spacing = 1.3  # More spacing between groups
x_positions = np.arange(len(applications)) * group_spacing

# Plot each data size with different colors
for size_idx, size in enumerate(data_sizes):
    baseline_values = []
    ushell_values = []
    ushell_mono_values = []
    x_baseline = []
    x_ushell = []
    x_ushell_mono = []

    for app_idx, app in enumerate(applications):
        baseline_val = data[app][size_idx * 3]
        ushell_val = data[app][size_idx * 3 + 1]
        ushell_mono_val = data[app][size_idx * 3 + 2]

        if baseline_val is not None:
            baseline_values.append(baseline_val)
            x_baseline.append(x_positions[app_idx] + size_idx * (bar_width * 3))

        if ushell_val is not None:
            ushell_values.append(ushell_val)
            x_ushell.append(x_positions[app_idx] + size_idx * (bar_width * 3) + bar_width)

        if ushell_mono_val is not None:
            ushell_mono_values.append(ushell_mono_val)
            x_ushell_mono.append(x_positions[app_idx] + size_idx * (bar_width * 3) + bar_width * 2)

    # Plot baseline bars (solid) - with full saturation like reference
    if baseline_values:
        ax.bar(x_baseline, baseline_values, bar_width,
               color=size_colors[size_idx], alpha=1.0,  # Full alpha for saturation
               edgecolor='black', linewidth=0.5)

    # Plot µShell bars (dotted pattern like reference) - with full saturation
    if ushell_values:
        ax.bar(x_ushell, ushell_values, bar_width,
               color=size_colors[size_idx], alpha=1.0,  # Full alpha for saturation
               hatch='..', edgecolor='black', linewidth=0.5)

    # Plot µShell_mono bars (diagonal pattern) - with full saturation
    if ushell_mono_values:
        ax.bar(x_ushell_mono, ushell_mono_values, bar_width,
               color=size_colors[size_idx], alpha=1.0,  # Full alpha for saturation
               hatch='//', edgecolor='black', linewidth=0.5)

# Add speedup annotations for µShell
for size_idx, size in enumerate(data_sizes):
    for app_idx, app in enumerate(applications):
        baseline_val = data[app][size_idx * 3]
        ushell_val = data[app][size_idx * 3 + 1]
        ushell_mono_val = data[app][size_idx * 3 + 2]

        # Speedup for µShell
        if baseline_val is not None and ushell_val is not None:
            speedup = ushell_val / baseline_val
            x_pos = x_positions[app_idx] + size_idx * (bar_width * 3) + bar_width
            y_pos = ushell_val * 1.025

            ax.text(x_pos, y_pos, f'{speedup:.2f}x', ha='center', va='bottom',
                   fontsize=16, rotation=90, weight='bold')

        # Speedup for µShell_mono
        if baseline_val is not None and ushell_mono_val is not None:
            speedup = ushell_mono_val / baseline_val
            x_pos = x_positions[app_idx] + size_idx * (bar_width * 3) + bar_width * 2
            y_pos = ushell_mono_val * 1.025

            ax.text(x_pos, y_pos, f'{speedup:.2f}x', ha='center', va='bottom',
                   fontsize=16, rotation=90, weight='bold')

# Clean styling like reference
ax.set_ylabel('Throughput [MiB/s]')
#ax.set_yscale('log')
ax.set_ylim(0, 300)  # Adjusted based on new data range

# Set y-axis ticks at every 100
ax.set_yticks([0, 100, 200])

# Center x-ticks on application groups
group_centers = x_positions + (len(data_sizes) * bar_width * 3 - bar_width) / 2
ax.set_xticks(group_centers)
ax.set_xticklabels(display_names, ha='center')

# Grid lines only at major ticks (every 100)
ax.grid(True, alpha=0.5, axis='y', color='gray')
ax.set_axisbelow(True)

# Clean despine like reference
sns.despine(ax=ax)

# Clean legend
from matplotlib.patches import Patch
legend_elements = []

# Data size colors - full saturation like reference
for size_idx, (size, color) in enumerate(zip(data_sizes, size_colors)):
    legend_elements.append(Patch(facecolor=color, alpha=1.0, label=size))

# Platform patterns - full saturation (keeping original labels)
legend_elements.append(Patch(facecolor='gray', alpha=1.0, label='Coyote'))
legend_elements.append(Patch(facecolor='gray', alpha=1.0, hatch='..', label='µShell'))
legend_elements.append(Patch(facecolor='gray', alpha=1.0, hatch='//', label='µShell_mono'))

ax.legend(bbox_to_anchor=(1, 1.005), handles=legend_elements, loc='upper right', frameon=True, ncol=2, fontsize=16)

# Clean annotation
ax.text(0.5, 0.98, 'Higher is better ↑', transform=ax.transAxes,
        color='navy', weight='bold', fontsize=16, ha='center', va='top')

plt.tight_layout()
plt.savefig("pipeline_performance_updated.png", dpi=300, bbox_inches='tight')
plt.savefig("pipeline_performance_updated.pdf", bbox_inches='tight')
plt.show()