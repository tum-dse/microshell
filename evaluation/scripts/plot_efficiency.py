import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
from matplotlib.ticker import FuncFormatter

# ===== FONT AND STYLE SETTINGS =====
FONT_SIZE = 10
LABEL_SIZE = 10
TICK_SIZE = 10
LEGEND_SIZE = 9
VALUE_SIZE = 7
#SEGMENT_LABEL_SIZE = 5

# Set font to match style
plt.rcParams['mathtext.fontset'] = 'cm'
plt.rcParams['font.size'] = FONT_SIZE
plt.rcParams['axes.labelsize'] = LABEL_SIZE
plt.rcParams['xtick.labelsize'] = TICK_SIZE
plt.rcParams['ytick.labelsize'] = TICK_SIZE
plt.rcParams['legend.fontsize'] = LEGEND_SIZE

# ===== COLOR SETUP (NOW FOR SHARING LEVELS) =====
palette = sns.color_palette("pastel")
color_noshare = palette[0]    # Blue for no-share
color_share2 = palette[1]     # Green for shared by 2
color_share3 = palette[3]     # Orange for shared by 3
color_share4 = palette[2]     # Red for shared by 4

# ===== DATA =====
applications = ["ISPPIPELINE", "ISP_24BIT_DECOMPAND", "GAUSSIANDIFFERENCE", "DEFECT_DETECTION"]
resources = ["LUTs", "Registers", "BRAM", "URAM"]

# Total percentage of resources used by each app on U280
app_totals = {
    "ISPPIPELINE": [1.45, 0.82, 2.38, 0.63],
    "ISP_24BIT_DECOMPAND": [4.83, 2.77, 43.97, 0.21],
    "GAUSSIANDIFFERENCE": [0.87, 0.50, 0.74, 0],
    "DEFECT_DETECTION": [1.98, 1.08, 0.92, 0]
}

# Breakdown of each app's total into sharing components
app_breakdowns = {
    "ISPPIPELINE": [
        [10.48, 79.87, 0, 9.65],     # LUTs
        [11.41, 77.54, 0, 11.05],     # Registers
        [0, 100, 0, 0],               # BRAM
        [100, 0, 0, 0],               # URAM
    ],
    "ISP_24BIT_DECOMPAND": [
        [83.03, 12.61, 0.16, 4.20],  # LUTs
        [83.84, 11.74, 0.08, 4.34],  # Registers
        [98.65, 1.35, 0, 0],          # BRAM
        [100, 0, 0, 0],               # URAM
    ],
    "GAUSSIANDIFFERENCE": [
        [25.86, 64.34, 0.49, 9.31],  # LUTs
        [24.02, 65.71, 0.52, 9.75],  # Registers
        [33.33, 66.67, 0, 0],         # BRAM
        [0, 0, 0, 0],                 # URAM (no usage)
    ],
    "DEFECT_DETECTION": [
        [71.55, 12.29, 0.42, 15.74], # LUTs
        [70.31, 10.88, 0.49, 18.32], # Registers
        [91.89, 8.11, 0, 0],          # BRAM
        [0, 0, 0, 0],                 # URAM (no usage)
    ]
}

# ===== PLOT SETUP =====
fig, ax = plt.subplots(figsize=(4.0, 2.8))  # Wider for 4 application groups with spacing

# Bar settings
bar_width = 0.20  # Width for each bar
x_positions = np.arange(len(applications)) * 1.2  # Extra spacing between app groups

# Patterns for different resources (instead of sharing levels)
resource_patterns = ['', '//', '..', 'xx']  # LUTs, Registers, BRAM, URAM

# ===== PLOTTING FUNCTION =====
def plot_resource_bar(x_pos, resource_idx, app_name):
    """Plot a single resource bar for an application with sharing breakdown"""

    total_usage = app_totals[app_name][resource_idx]
    breakdown_percentages = app_breakdowns[app_name][resource_idx]
    pattern = resource_patterns[resource_idx]

    # Handle zero usage case
    if total_usage == 0:
        # Draw a very thin bar just to show it exists
        min_height = 2
        rect = ax.bar(x_pos, min_height, bar_width,
                      bottom=0, color='lightgray', edgecolor='black',
                      linewidth=1, alpha=0.3)

        # Add 0% label above
        ax.text(x_pos + 0.03, min_height + 2,
                '0%', ha='center', va='bottom',
                fontsize=VALUE_SIZE - 1, rotation=90, weight='bold')
        return

    # Colors for each sharing level
    colors = [color_noshare, color_share2, color_share3, color_share4]

    # Apply smart scaling for proportional segments
    scaled_values = []
    for pct in breakdown_percentages:
        if pct == 0:
            scaled_values.append(0)
        elif pct < 1:
            scaled_values.append(5)  # Minimum visibility
        else:
            scaled = np.power(pct, 0.6) * 8
            scaled = max(scaled, 5)
            scaled_values.append(scaled)

    # Normalize to sum to 100
    total_scaled = sum(scaled_values)
    if total_scaled > 0:
        segment_heights = [(v / total_scaled) * 100 for v in scaled_values]
    else:
        segment_heights = [25, 25, 25, 25]

    # Plot segments with different colors for sharing levels
    current_bottom = 0
    for i, (color, breakdown_pct, height) in enumerate(zip(colors, breakdown_percentages, segment_heights)):
        if height == 0:
            continue

        # Draw segment with color for sharing level and pattern for resource type
        rect = ax.bar(x_pos, height, bar_width,
                      bottom=current_bottom, color=color, edgecolor='black',
                      linewidth=1, hatch=pattern, alpha=1.0)

        # Add percentage label for significant segments
        #if breakdown_pct >= 2:
            #segment_center = current_bottom + height / 2
            #label_text = f'{breakdown_pct:.0f}%'

            #font_size = SEGMENT_LABEL_SIZE - 2 if height < 10 else SEGMENT_LABEL_SIZE - 1

            # Use black text on light colors, white on dark
            #text_color = 'black'

            #ax.text(x_pos, segment_center, label_text,
            #       ha='center', va='center', fontsize=font_size,
            #       color=text_color, weight='bold',
            #       bbox=dict(boxstyle='round,pad=0.03', facecolor='white',
            #       edgecolor='none', alpha=0.9))

        current_bottom += height

    # Add total value label on top
    ax.text(x_pos+0.03, 100 + 2,
            f'{total_usage:.1f}%', ha='center', va='bottom',
            fontsize=VALUE_SIZE, rotation=90, weight='bold')

# ===== PLOT ALL BARS =====
for i, app_name in enumerate(applications):
    # Plot 4 bars for each application (one for each resource)
    for j, resource in enumerate(resources):
        x_offset = (j - 1.5) * bar_width  # Center the 4 bars around the x position
        plot_resource_bar(x_positions[i] + x_offset, j, app_name)

# ===== AXIS FORMATTING =====
ax.set_ylabel('Breakdown percentage (%)', fontsize=LABEL_SIZE)
ax.yaxis.set_label_coords(-0.15, 0.425)
ax.set_ylim(0, 133)  # Extra space for top labels
ax.set_yticks([0, 20, 40, 60, 80, 100])
ax.set_yticklabels(['0', '20', '40', '60', '80', '100'])

# X-axis with application names (shortened for readability)
ax.set_xticks(x_positions)
app_labels = ["isp_pipe", "isp_decomp", "gaussidiff", "defct_detct"]
ax.set_xticklabels(app_labels, ha='center', fontsize=LABEL_SIZE, rotation=0)

# Grid
ax.grid(True, alpha=0.3, axis='y', color='gray', linestyle='-')
ax.set_axisbelow(True)

# Remove top and right spines
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

# ===== LEGEND =====
from matplotlib.patches import Patch

# Resource legend (with patterns)
resource_handles = [
    Patch(facecolor='white', edgecolor='black', label='LUTs', linewidth=1.0),
    Patch(facecolor='white', edgecolor='black', label='Regs', linewidth=1.0, hatch='////'),
    Patch(facecolor='white', edgecolor='black', label='BRAM', linewidth=1.0, hatch='....'),
    Patch(facecolor='white', edgecolor='black', label='URAM', linewidth=1.0, hatch='xxx')
]

# Sharing level legend (with colors)
sharing_handles = [
    Patch(facecolor=color_noshare, edgecolor='black', label='no-share', linewidth=1.0, alpha=0.9),
    Patch(facecolor=color_share2, edgecolor='black', label='share-2', linewidth=1.0, alpha=0.9),
    Patch(facecolor=color_share3, edgecolor='black', label='share-3', linewidth=1.0, alpha=0.9),
    Patch(facecolor=color_share4, edgecolor='black', label='share-4+', linewidth=1.0, alpha=0.9)
]

# Combine handles - resources first, then sharing levels
all_handles = resource_handles + sharing_handles

# Create a single legend with 2 columns
legend = ax.legend(handles=all_handles, loc='center',
                   bbox_to_anchor=(0.45, 1.05), ncol=4,
                   frameon=True, fancybox=False, shadow=False,
                   columnspacing=1.0, handletextpad=0.8, facecolor='white',
                   borderpad=0.5, fontsize=LEGEND_SIZE)

# ===== SAVE AND DISPLAY =====
plt.tight_layout()
plt.margins(x=0.02, tight=True)
plt.savefig("../plots/resource_efficiency.pdf", bbox_inches='tight')
plt.show()