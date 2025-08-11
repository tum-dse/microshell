import seaborn as sns
import pandas
import matplotlib  # type: ignore
import matplotlib.pyplot as plt
import numpy as np

# ===== FONT AND STYLE SETTINGS =====
FONT_SIZE = 10
LABEL_SIZE = 10
TICK_SIZE = 10
LEGEND_SIZE = 9
ANNOTATION_SIZE = 9

plt.rcParams['mathtext.fontset'] = 'cm'
plt.rcParams['font.size'] = FONT_SIZE
plt.rcParams['axes.labelsize'] = LABEL_SIZE
plt.rcParams['xtick.labelsize'] = TICK_SIZE
plt.rcParams['ytick.labelsize'] = TICK_SIZE
plt.rcParams['legend.fontsize'] = LEGEND_SIZE

# ===== DATA =====
resources = ["0%", "25%", "50%", "75%", "100%"]
reconf_raw = [58080, 58091, 58091, 58069, 58054] # us order
reconf_avg = (sum(reconf_raw) / len(reconf_raw)) / 1000 # ms order
pr_values = [reconf_avg, reconf_avg*(0.75), reconf_avg*(0.50), reconf_avg*(0.25), 0]
coyote_values = [reconf_avg, reconf_avg, reconf_avg, reconf_avg, 0]

# df = pandas.read_csv("../data/sched_motive.csv")
# print(df)
# 
# df_coyote = df[df['Policy'] == 'Coyote']
# df_pr = df[df['Policy'] == 'Partially reconfig']
# coyote_values = df_coyote['Reconfig overhead (ms)'].tolist()
# pr_values = df_pr['Reconfig overhead (ms)'].tolist()

# ===== COLOR SETUP =====
palette = sns.color_palette("pastel")
color1 = palette[0]
color2 = palette[1]
color3 = palette[2]
# palette_console = [color1, color2]

hatch1 = ""
hatch2 = "."
# hatch3 = "*"
hatch_list = [hatch1, hatch2]

# ===== PLOT SETUP =====
# width = 7  # \textwidth is 7 inch
width = 4.0
height = 2.8
fig, ax = plt.subplots(figsize=(width, height))

# Bar settings
bar_width = 0.24
x_positions = np.arange(len(resources))


# Common bar properties
bar_props = {
    'alpha': 1.0,
    'edgecolor': 'k',
    'linewidth': 1.0,
    'error_kw': {'ecolor': 'black', 'elinewidth': 1, 'capsize': 2}
}

# ===== PLOTTING BARS =====
# Coyote bars (solid)
bars1 = ax.bar(x_positions - 0.5*bar_width, coyote_values, bar_width,
               # yerr=vfpga1_errors, 
               color=color1, hatch='//',
                label='Full Reconf. (Coyote)', **bar_props)

# PR bars (diagonal pattern)
bars2 = ax.bar(x_positions + 0.5*bar_width, pr_values, bar_width,
               # yerr=vfpga2_errors, 
               color=color2, hatch='\\\\',
                label='Partial Reconf. (PR)', **bar_props)

# ===== AXIS FORMATTING =====
ax.set_xlabel('Shared logic ratio')
ax.set_ylabel('Reconfiguration overhead (ms)')
# ax.set_ylim(0, 130)  
ax.set_ylim(0, 75)  
# ax.set_yticks([0, 20, 40, 60, 80, 100])
ax.set_yticks([0, 10, 20, 30, 40, 50, 60])

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
          bbox_to_anchor=(1, 1.05))

# ===== ANNOTATIONS =====
ax.text(0.22, 0.98, 'Lower is better ↓', transform=ax.transAxes,
        color='navy', weight='bold', fontsize=ANNOTATION_SIZE, 
        ha='center', va='top')

plt.tight_layout()
# fig.savefig("motive.png", bbox_inches="tight")
plt.savefig("../plots/reconf_analysis.pdf", bbox_inches="tight")
plt.show()
