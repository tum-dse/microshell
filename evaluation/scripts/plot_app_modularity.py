import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

# ===== FONT AND STYLE SETTINGS =====
FONT_SIZE = 14
LABEL_SIZE = 14
TICK_SIZE = 10
LEGEND_SIZE = 14
TITLE_SIZE = 16

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
# Using our established color palette
palette = sns.color_palette("pastel")
color_memory = palette[1]    # Orange for memory I/O
color_compute = '#2E8B57'   # Sea Green for Compute task
color_filtering = palette[3] # Red/Pink for Filtering
color_formatting = palette[0] # Blue for Formatting
color_etc = 'white'         # White for Etc.

# ===== DATA =====
applications = ['BigQuery[1]', 'BigTable[2]', 'Firewall\n(NF) [3]', 'IDS\n(NF) [3]', 
                'Image\nFilter [4]', 'Graph\nprocessing [5]', 'Genomics [6]']

# Data for stacked bars (number of modules of each type)
memory_io = [2, 1, 0, 0, 1, 2, 1]
compute_task = [3, 2, 1, 1, 1, 2, 1]
filtering = [1, 1, 1, 1, 2, 0, 0]
formatting = [1, 1, 1, 1, 1, 0, 0]
etc = [0, 1, 0, 1, 0, 1, 1]

# ===== PLOT SETUP =====
fig, ax = plt.subplots(figsize=(12, 7))

# Calculate bar width
bar_width = 0.6
x_positions = np.arange(len(applications))

# ===== PLOTTING INDIVIDUAL MODULES =====
# For each application, plot individual modules with lines between them
for i, app in enumerate(applications):
    current_height = 0
    
    # Memory I/O modules
    for j in range(memory_io[i]):
        ax.bar(x_positions[i], 1, bar_width, 
               bottom=current_height, color=color_memory, 
               edgecolor='black', linewidth=0.5)
        current_height += 1
    
    # Compute task modules
    for j in range(compute_task[i]):
        ax.bar(x_positions[i], 1, bar_width, 
               bottom=current_height, color=color_compute, 
               edgecolor='black', linewidth=0.5)
        current_height += 1
    
    # Filtering modules
    for j in range(filtering[i]):
        ax.bar(x_positions[i], 1, bar_width, 
               bottom=current_height, color=color_filtering, 
               edgecolor='black', linewidth=0.5)
        current_height += 1
    
    # Formatting modules
    for j in range(formatting[i]):
        ax.bar(x_positions[i], 1, bar_width, 
               bottom=current_height, color=color_formatting, 
               edgecolor='black', linewidth=0.5)
        current_height += 1
    
    # Etc. modules
    for j in range(etc[i]):
        ax.bar(x_positions[i], 1, bar_width, 
               bottom=current_height, color=color_etc, 
               edgecolor='black', linewidth=0.5)
        current_height += 1

# ===== AXIS FORMATTING =====
# Remove the standard ylabel
ax.set_ylabel('')

# Set y-axis limits and ticks to match the desired output
ax.set_ylim(0, 8)
ax.set_yticks([0, 2, 4, 6])

# X-axis
ax.set_xticks(x_positions)
ax.set_xticklabels(applications, ha='center')

# Add custom y-axis label on the left (rotated)
ax.text(-0.04, 0.5, 'Number of modules', transform=ax.transAxes,
        rotation=90, ha='center', va='center', fontsize=LABEL_SIZE)

# Grid - only horizontal lines
ax.grid(True, alpha=0.3, axis='y', color='gray', linestyle='-')
ax.set_axisbelow(True)

# Remove top and right spines
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

# ===== TITLE =====
ax.set_title('Empirical study 1: Application Modularity Analysis', 
             fontsize=TITLE_SIZE, pad=15, weight='bold')

# ===== LEGEND =====
# Create custom legend handles for better control
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor=color_memory, edgecolor='black', label='Memory I/O', linewidth=0.5),
    Patch(facecolor=color_compute, edgecolor='black', label='Compute Task', linewidth=0.5),
    Patch(facecolor=color_filtering, edgecolor='black', label='Filtering', linewidth=0.5),
    Patch(facecolor=color_formatting, edgecolor='black', label='Formatting', linewidth=0.5),
    Patch(facecolor=color_etc, edgecolor='black', label='Etc.', linewidth=0.5)
]

# Position legend above the plot
ax.legend(handles=legend_elements, loc='upper center', bbox_to_anchor=(0.5, 1.0),
          ncol=5, frameon=False, columnspacing=1.5)

# ===== SAVE AND DISPLAY =====
plt.tight_layout()
plt.savefig("application_modularity_analysis.png", dpi=300, bbox_inches='tight')
plt.savefig("application_modularity_analysis.pdf", bbox_inches='tight')
plt.show()