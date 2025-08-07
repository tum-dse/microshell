import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

# ===== FONT AND STYLE SETTINGS =====
FONT_SIZE = 12
LABEL_SIZE = 11
TICK_SIZE = 11
LEGEND_SIZE = 11
# TITLE_SIZE = 16

# Set font to match ASPLOS paper style
# plt.rcParams['font.family'] = 'serif'
# plt.rcParams['font.serif'] = ['Times New Roman', 'DejaVu Serif', 'Computer Modern Roman']
plt.rcParams['mathtext.fontset'] = 'cm'
plt.rcParams['font.size'] = FONT_SIZE
plt.rcParams['axes.labelsize'] = LABEL_SIZE
plt.rcParams['xtick.labelsize'] = TICK_SIZE
plt.rcParams['ytick.labelsize'] = TICK_SIZE
plt.rcParams['legend.fontsize'] = LEGEND_SIZE

# ===== COLOR SETUP =====
# Using our established color palette
palette = sns.color_palette("pastel")
color_compute = palette[1]      # Orange for Computation
color_data = palette[0]       # Blue for data management 
color_encoding = palette[2]   # Sea green for data encoding/encryption
# color_encoding = '#2E8B57'   # Sea green for data encoding/encryption
color_networking = palette[3]    # Red/Pink for Networking
color_ml_matching = palette[4]    # Purple for ML/AI
color_misc = 'white'             # White for Etc.

# ===== DATA =====
applications = ['Google\nBigQuery\n[38,39]',         # big data analytics 
                'Google\nBigTable\n[38,40]',
                'Stateful\nFirewall\n[65]',       # network functions
                'Intrusion\nDetection\n[65]',   
                'Audio\nDecoder\n[46,93]', 
                'Swarm\nPerception\n[47,93]', 
                'Speaker\nAuth.\n[18]',
                'Kalman\nFilter\n[18]',
                'Brain\nStimulat.\n[58]',
                'Video\nSync.\n[58]',
                'Context\nDetection\n[87,95]',
                'Audio\nProcessing\n[115]',
                'Digital\nSignature\n[90]',
                'Secure\nStorage\n[85]',
                'Signed\nCompress.\n[50]',
                'Speech\nRecogn.\n[89]'
                ]

# Data for stacked bars (number of modules of each type)
# [Query, Table, FW, IDS, Audio, Vehicular, SpeakAuth, Kalman, Brain, VideoSync, TransDetect, Audio, Digital, Storage, Message, Speech]
compute_linear  = [0, 0, 0, 0, 0, 0, 2, 3, 0, 0, 0, 0, 0, 0, 0, 0]
compute_dsp     = [0, 0, 0, 0, 4, 1, 1, 0, 1, 1, 0, 2, 0, 0, 0, 1]
compute_basic   = [0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
data_database   = [2, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
data_transform  = [1, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
data_io_sensing = [2, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
encode_compress = [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0]
encode_crypto   = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 1, 1, 0]
network_infra   = [0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
network_sec     = [0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0]
ml_ai           = [0, 0, 0, 0, 0, 2, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1]
misc            = [1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0]
# io_ops       = [2, 1, 0, 0, 1, 2, 1]
# compute_task    = [3, 2, 1, 1, 1, 2, 1]
# filtering       = [1, 1, 1, 1, 2, 0, 0]
# formatting      = [1, 1, 1, 1, 1, 0, 0]
# etc             = [0, 1, 0, 1, 0, 1, 1]

# ===== PLOT SETUP =====
width = 14.0
height = 3.0
fig, ax = plt.subplots(figsize=(width, height))

# Calculate bar width
bar_width = 0.34
x_positions = np.arange(len(applications))

# ===== PLOTTING INDIVIDUAL MODULES =====
# For each application, plot individual modules with lines between them
for i, app in enumerate(applications):
    current_height = 0
    
    # compute_linear modules
    for j in range(compute_linear[i]):
        ax.bar(x_positions[i], 1, bar_width, 
               bottom=current_height, color=color_compute, 
               edgecolor='black', linewidth=1)
        current_height += 1

    # compute_dsp modules
    for j in range(compute_dsp[i]):
        ax.bar(x_positions[i], 1, bar_width, 
               bottom=current_height, color=color_compute, 
               edgecolor='black', linewidth=1, hatch='//')
        current_height += 1

    # compute_basic modules
    for j in range(compute_basic[i]):
        ax.bar(x_positions[i], 1, bar_width, 
               bottom=current_height, color=color_compute, 
               edgecolor='black', linewidth=1, hatch='..')
        current_height += 1

    # data_database modules
    for j in range(data_database[i]):
        ax.bar(x_positions[i], 1, bar_width, 
               bottom=current_height, color=color_data, 
               edgecolor='black', linewidth=1)
        current_height += 1

    # data_transform modules
    for j in range(data_transform[i]):
        ax.bar(x_positions[i], 1, bar_width, 
               bottom=current_height, color=color_data, 
               edgecolor='black', linewidth=1, hatch='//')
        current_height += 1

    # data_io_sensing modules
    for j in range(data_io_sensing[i]):
        ax.bar(x_positions[i], 1, bar_width, 
               bottom=current_height, color=color_data, 
               edgecolor='black', linewidth=1, hatch='..')
        current_height += 1
    
    # encode_compress modules
    for j in range(encode_compress[i]):
        ax.bar(x_positions[i], 1, bar_width, 
               bottom=current_height, color=color_encoding, 
               edgecolor='black', linewidth=1)
        current_height += 1

    # encode_crypto modules
    for j in range(encode_crypto[i]):
        ax.bar(x_positions[i], 1, bar_width, 
               bottom=current_height, color=color_encoding, 
               edgecolor='black', linewidth=1, hatch='//')
        current_height += 1
    
    # network_infra modules
    for j in range(network_infra[i]):
        ax.bar(x_positions[i], 1, bar_width, 
               bottom=current_height, color=color_networking, 
               edgecolor='black', linewidth=1)
        current_height += 1

    # network_sec modules
    for j in range(network_sec[i]):
        ax.bar(x_positions[i], 1, bar_width, 
               bottom=current_height, color=color_networking, 
               edgecolor='black', linewidth=1, hatch='//')
        current_height += 1

    # ml_ai modules
    for j in range(ml_ai[i]):
        ax.bar(x_positions[i], 1, bar_width, 
               bottom=current_height, color=color_ml_matching, 
               edgecolor='black', linewidth=1)
        current_height += 1
    
    # misc modules
    for j in range(misc[i]):
        ax.bar(x_positions[i], 1, bar_width, 
               bottom=current_height, color=color_misc, 
               edgecolor='black', linewidth=1)
        current_height += 1

# ===== AXIS FORMATTING =====
# Remove the standard ylabel
ax.set_ylabel('')

# Set y-axis limits and ticks to match the desired output
ax.set_ylim(0, 8)
ax.set_yticks([0, 2, 4, 6, 8])

# X-axis
ax.set_xticks(x_positions)
ax.set_xticklabels(applications, ha='center')

# Add custom y-axis label on the left (rotated)
ax.text(-0.02, 0.5, 'The number of tasks', transform=ax.transAxes,
        rotation=90, ha='center', va='center', fontsize=LABEL_SIZE)

# Grid - only horizontal lines
ax.grid(True, alpha=0.3, axis='y', color='gray', linestyle='-')
ax.set_axisbelow(True)

# Remove top and right spines
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

# ===== TITLE =====
# ax.set_title('Empirical study 1: Application Modularity Analysis', 
#              fontsize=TITLE_SIZE, pad=15, weight='bold')

# ===== LEGEND =====
# Create custom legend handles for better control
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor=color_compute,      edgecolor='black', hatch='',    label='Compute (LA)',    linewidth=1.0),
    Patch(facecolor=color_compute,      edgecolor='black', hatch='//',  label='Compute (DSP)',   linewidth=1.0),
    Patch(facecolor=color_compute,      edgecolor='black', hatch='..',  label='Compute (Basic)', linewidth=1.0),
    Patch(facecolor=color_data,         edgecolor='black', hatch='',    label='Data (DB)',       linewidth=1.0),
    Patch(facecolor=color_data,         edgecolor='black', hatch='//',  label='Data (Transform)',linewidth=1.0),
    Patch(facecolor=color_data,         edgecolor='black', hatch='..',  label='Data (I/O)',      linewidth=1.0),
    Patch(facecolor=color_encoding,     edgecolor='black', hatch='',    label='Compression', linewidth=1.0),
    Patch(facecolor=color_encoding,     edgecolor='black', hatch='//',  label='Cryptography',    linewidth=1.0),
    Patch(facecolor=color_networking,   edgecolor='black', hatch='',    label='Network (Com.)',linewidth=1.0),
    Patch(facecolor=color_networking,   edgecolor='black', hatch='//',  label='Network (Sec.)',  linewidth=1.0),
    Patch(facecolor=color_ml_matching,  edgecolor='black', hatch='',    label='ML/AI',           linewidth=1.0),
    Patch(facecolor=color_misc,         edgecolor='black', hatch='',    label='Misc.',           linewidth=1.0)
]

# Position legend above the plot
ax.legend(handles=legend_elements, loc='upper right', bbox_to_anchor=(0.94, 1.02),
          ncol=6, frameon=False, columnspacing=1.5)

# ===== SAVE AND DISPLAY =====
plt.tight_layout()
plt.margins(x=0.015, tight=True)
# plt.savefig("application_modularity_analysis.png", dpi=300, bbox_inches='tight')
plt.savefig("../plots/application_modularity_analysis.pdf", bbox_inches='tight')
plt.show()
