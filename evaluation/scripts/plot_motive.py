import seaborn as sns
import pandas
import matplotlib  # type: ignore
import matplotlib.pyplot as plt
from typing import Any, Dict, List, Union

matplotlib.rcParams["pdf.fonttype"] = 42
matplotlib.rcParams["ps.fonttype"] = 42
FORMATTER: Dict[str, matplotlib.ticker.Formatter] = {}
COLUMN_ALIASES: Dict[str, str] = {}

FONTSIZE = 14

sns.set(font_scale=1.6)
sns.set_style("ticks")

data1 = pandas.read_csv("../data/sched_motive.csv")

print(data1.head())
# print(data["app"][0])
palette = sns.color_palette("pastel")
# sns.set_style("whitegrid")

color1 = palette[0]
color2 = palette[1]
color3 = palette[2]

hatch1 = ""
hatch2 = "."
# hatch3 = "*"

hatch_list = [hatch1, hatch2]

palette_console = [color1, color3]


width = 7  # \textwidth is 7 inch
height = 5

# fig, axs = plt.subplots(nrows=2, ncols=3, sharex=True)
fig, axs = plt.subplots(nrows=1, ncols=1)
fig.set_size_inches(width, height)
fig.suptitle(
    "Lower is better ↓", fontsize=18, color="navy", weight="bold", x=0.55, y=0.95
)
# plt.yscale('log')


g1 = sns.barplot(
    ax=axs,
    data=data1,
    x="Shared sched logics",
    y="Reconfig overhead (ms)",
    hue="Policy",
    # x=column_alias("system"),
    # y=column_alias("nginx-requests"),
    # ci="sd",
    errorbar=None,
    palette=palette_console,
    edgecolor="k",  # Edge color set to black
    errcolor="black",  # Error bar color set to black
    errwidth=1,  # Error bar width set to 1
    capsize=0.2,  # Error bar cap size set to 0.2
    linewidth=2,
    # errcolor="black",
    # errwidth=1,
    width=0.8,
    # capsize=0.2,
    alpha=0.6,
    # height=height,
    # aspect=nginx_width/height,
)

# apply hatch
for idx, bar in enumerate(axs.containers[1]):
    bar.set_hatch(hatch_list[1])

# # apply bar value
# for c in axs[0, 0].containers:
#     labels = [f'{(v.get_height()/1000):.1f}k' for v in c]
#     axs[0, 0].bar_label(c, labels=labels, label_type='edge',
#                     padding=3,
#                     # fontsize=fontsize, rotation=rotation
#                     )


# ff = FORMATTER["krps"]
# axs[0, 0].yaxis.set_major_formatter(ff)
# axs[0, 0].set_yscale("log")
# g1.set(xticks=[], xticklabels=[], xlabel="(a) Throughput of the storage applications")
# g1.set_title("Lower is better ↓", fontsize=15, color="navy", weight="bold",
#                     x = 0.50, y=1, pad=10)
axs.set_title("Coyote's reconfig overhead", weight="bold")
axs.legend(loc="upper left")
axs.set_ylim([0, 150])
# plt.legend(loc="upper left")

fig.tight_layout()
fig.savefig("motive.png", bbox_inches="tight")
fig.savefig("motive.pdf", bbox_inches="tight")

print("Output: motive.png, motive.pdf")
