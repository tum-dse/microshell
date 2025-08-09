import seaborn as sns
import pandas
import numpy as np
import matplotlib  # type: ignore
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from typing import Any, Dict, List, Union

# matplotlib.rcParams["pdf.fonttype"] = 42
# matplotlib.rcParams["ps.fonttype"] = 42
# FORMATTER: Dict[str, matplotlib.ticker.Formatter] = {}
COLUMN_ALIASES: Dict[str, str] = {}

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

# sns.set(font_scale=1.6)
sns.set_style("ticks")

data1 = pandas.read_csv("../data/sched_latency.csv")
data2 = pandas.read_csv("../data/sched_reconfig.csv")
data3 = pandas.read_csv("../data/sched_resp_avg.csv")
data4 = pandas.read_csv("../data/sched_resp_95.csv")
data5 = pandas.read_csv("../data/sched_deadline.csv")

palette = sns.color_palette("pastel")
color1 = palette[0]
color2 = palette[1]
color3 = palette[2]

x_positions = np.arange(len([8, 12,16]))

hatch1 = "//"
hatch2 = "\\\\"
hatch3 = ".."

hatch_list = [hatch1, hatch2]
palette_console = [color1, color2]

width = 14  # \textwidth is 7 inch
height = 5

bar_width = 0.18

# fig, axs = plt.subplots(nrows=2, ncols=3, sharex=True)
fig, axs = plt.subplots(nrows=1, ncols=5, sharex=True)
fig.set_size_inches(width, height)
fig.suptitle(
    "Lower is better ↓", fontsize=FONT_SIZE, color="navy", weight="bold", x=0.8, y=0.05
)

g1 = sns.barplot(
    ax=axs[0],
    data=data1,
    x="Number of tasks",
    y="Latency[ms]",
    hue="Policy",
    errorbar=None,
    palette=palette_console,
    edgecolor="k",
    linewidth=1,
    width=0.8,
    capsize=0.2,
    # alpha=0.6,
)

# apply hatch
for idx, bar in enumerate(axs[0].containers[0]):
    bar.set_hatch(hatch_list[0])
for idx, bar in enumerate(axs[0].containers[1]):
    bar.set_hatch(hatch_list[1])

axs[0].set_title("(a)", weight="bold")

g2 = sns.barplot(
    ax=axs[1],
    data=data2,
    x="Number of tasks",
    y="Reconfig count",
    hue="Policy",
    errorbar=None,
    palette=palette_console,
    edgecolor="k",
    linewidth=1,
    width=0.8,
    # alpha=0.6,
)
axs[1].set_title("(b)", weight="bold")
for idx, bar in enumerate(axs[1].containers[0]):
    bar.set_hatch(hatch_list[0])
for idx, bar in enumerate(axs[1].containers[1]):
    bar.set_hatch(hatch_list[1])
g3 = sns.barplot(
    ax=axs[2],
    data=data3,
    x="Number of tasks",
    y="Latency[ms]",
    hue="Policy",
    errorbar=None,
    palette=palette_console,
    edgecolor="k",
    linewidth=1,
    width=0.8,
    # alpha=0.6,
)

axs[2].set_title("(c)", weight="bold")
for idx, bar in enumerate(axs[2].containers[0]):
    bar.set_hatch(hatch_list[0])
for idx, bar in enumerate(axs[2].containers[1]):
    bar.set_hatch(hatch_list[1])

g4 = sns.barplot(
    ax=axs[3],
    data=data4,
    x="Number of tasks",
    y="Latency[ms]",
    hue="Policy",
    errorbar=None,
    palette=palette_console,
    edgecolor="k",
    linewidth=1,
    width=0.8,
    # alpha=0.6,
)

axs[3].set_title("(d)", weight="bold")
for idx, bar in enumerate(axs[3].containers[0]):
    bar.set_hatch(hatch_list[0])
for idx, bar in enumerate(axs[3].containers[1]):
    bar.set_hatch(hatch_list[1])

g5 = sns.barplot(
    ax=axs[4],
    data=data5,
    x="Number of tasks",
    y="Deadline misses",
    hue="Policy",
    errorbar=None,
    palette=palette_console,
    edgecolor="k",
    linewidth=1,
    width=0.8,
    # alpha=0.6,
)

axs[4].set_title("(e)", weight="bold")
for idx, bar in enumerate(axs[4].containers[0]):
    bar.set_hatch(hatch_list[0])
for idx, bar in enumerate(axs[4].containers[1]):
    bar.set_hatch(hatch_list[1])

for ax in axs[:]:  # Exclude the last subplot
    ax.set_xlabel('')
    
# Set the x-axis label only for the bottom subplot (last one)
# axs[4].set_xlabel("Number of tasks", fontsize=FONTSIZE)

fig.supxlabel("Number of tasks")

# Remove legends from individual subplots and add it once globally
for ax in axs:
    ax.get_legend().set_visible(False)

    # Grid
    ax.grid(True, alpha=0.3, axis='y', color='gray')
    ax.set_axisbelow(True)

    # Remove top and right spines
    sns.despine(ax=ax)

# handles, labels = axs[0].get_legend_handles_labels()
# fig.legend(handles, labels, loc="upper right", fontsize=FONTSIZE, bbox_to_anchor=(1, 0.96), ncol=5)

# legend
p1 = matplotlib.patches.Patch(facecolor=palette[0], hatch=hatch_list[0], edgecolor="k",
                        label='Coyote')
p2 = matplotlib.patches.Patch(facecolor=palette[1], hatch=hatch_list[1], edgecolor="k",
                        label='uShell')

# fig.legend(handles=[p1, p2, p3], loc="center left", bbox_to_anchor=(1.0, 0.5), frameon=False, ncol=1)
fig.legend(handles=[p1, p2], loc="lower right",  bbox_to_anchor=(1, 0), frameon=True, ncol=5)

# Add custom legend to the figure
# fig.legend(handles=handles, loc="upper left", fontsize=FONTSIZE, bbox_to_anchor=(0.5, 1.05), ncol=5)

fig.subplots_adjust(hspace=0.5, bottom=0)  # Adjust these values as needed

fig.tight_layout(pad=0.8)
fig.savefig("sched.png", bbox_inches="tight")
fig.savefig("sched.pdf", bbox_inches="tight")

print("Output: sched.png, sched.pdf")
