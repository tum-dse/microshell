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

data1 = pandas.read_csv("sched_latency.csv")
data2 = pandas.read_csv("sched_reconfig.csv")
data3 = pandas.read_csv("sched_resp_avg.csv")
data4 = pandas.read_csv("sched_resp_95.csv")
data5 = pandas.read_csv("sched_deadline.csv")
data6 = pandas.read_csv("sched_motive.csv")

print(data1.head())
# print(data["app"][0])
palette = sns.color_palette("pastel")

color1 = palette[0]
color2 = palette[1]
color3 = palette[2]

hatch1 = ""
hatch2 = "."
# hatch3 = "*"

hatch_list = [hatch1, hatch2]

palette_console = [color1, color3]


width = 14  # \textwidth is 7 inch
height = 10

# fig, axs = plt.subplots(nrows=2, ncols=3, sharex=True)
fig, axs = plt.subplots(nrows=2, ncols=3)
fig.set_size_inches(width, height)
fig.suptitle(
    "Lower is better ↓", fontsize=18, color="navy", weight="bold", x=0.55, y=0.95
)
# plt.yscale('log')


g1 = sns.barplot(
    ax=axs[0, 0],
    data=data1,
    x="Number of tasks",
    y="Latency[ms]",
    hue="Policy",
    # x=column_alias("system"),
    # y=column_alias("nginx-requests"),
    # ci="sd",
    errorbar=None,
    palette=palette_console,
    edgecolor="k",
    linewidth=2,
    # errcolor="black",
    # errwidth=1,
    width=0.8,
    capsize=0.2,
    alpha=0.6,
    # height=height,
    # aspect=nginx_width/height,
)

# apply hatch
for idx, bar in enumerate(axs[0, 0].containers[1]):
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
axs[0, 0].set_title("(a) Latency", weight="bold")
axs[0, 0].legend(loc="upper left")

g2 = sns.barplot(
    ax=axs[0, 1],
    data=data2,
    x="Number of tasks",
    y="Reconfig count",
    hue="Policy",
    # ci="sd",
    errorbar=None,
    palette=palette_console,
    edgecolor="k",
    linewidth=2,
    # errcolor="black",
    # errwidth=1.5,
    # capsize=0.2,
    width=0.8,
    alpha=0.6,
    # height=height,
    # aspect=nginx_width/height,
)
# axs[0, 1].set_yscale("log")
axs[0, 1].set_title("(b) Reconfig count", weight="bold")
axs[0, 1].legend(loc="upper left")
for idx, bar in enumerate(axs[0, 1].containers[1]):
    bar.set_hatch(hatch_list[1])

# g2.set(xticks=[], xticklabels=["aaa"], xlabel="(b) Throughput of the network applications")
# g2.set_title("Higher is better ↑", fontsize=10, color="navy", weight="bold",
#                     x = 0.50, y=1, pad=10)

# sns.despine(ax=axs[0, 0])
# sns.despine(ax=axs[0, 1])


g3 = sns.barplot(
    ax=axs[0, 2],
    data=data3,
    x="Number of tasks",
    y="Latency[ms]",
    hue="Policy",
    # ci="sd",
    errorbar=None,
    palette=palette_console,
    edgecolor="k",
    linewidth=2,
    # errcolor="black",
    # errwidth=1.5,
    # capsize=0.2,
    width=0.8,
    alpha=0.6,
    # height=height,
    # aspect=nginx_width/height,
)
# axs[1, 0].set_yscale("log")
axs[0, 2].set_title("(c) Average repsonse time", weight="bold")
axs[0, 2].legend(loc="upper left")
for idx, bar in enumerate(axs[0, 2].containers[1]):
    bar.set_hatch(hatch_list[1])


g4 = sns.barplot(
    ax=axs[1, 0],
    data=data4,
    x="Number of tasks",
    y="Latency[ms]",
    hue="Policy",
    # ci="sd",
    errorbar=None,
    palette=palette_console,
    edgecolor="k",
    linewidth=2,
    # errcolor="black",
    # errwidth=1.5,
    # capsize=0.2,
    width=0.8,
    alpha=0.6,
    # height=height,
    # aspect=nginx_width/height,
)
# axs[1, 1].set_yscale("log")
axs[1, 0].set_title("(d) 95% response time", weight="bold")
axs[1, 0].legend(loc="upper left")
for idx, bar in enumerate(axs[1, 0].containers[1]):
    bar.set_hatch(hatch_list[1])


g5 = sns.barplot(
    ax=axs[1, 1],
    data=data5,
    x="Number of tasks",
    y="Deadline misses",
    hue="Policy",
    # ci="sd",
    errorbar=None,
    palette=palette_console,
    edgecolor="k",
    linewidth=2,
    # errcolor="black",
    # errwidth=1.5,
    # capsize=0.2,
    width=0.8,
    alpha=0.6,
    # height=height,
    # aspect=nginx_width/height,
)
# axs[1, 1].set_yscale("log")
axs[1, 1].set_title("(d) Deadline misses", weight="bold")
axs[1, 1].legend(loc="upper left")
for idx, bar in enumerate(axs[1, 1].containers[1]):
    bar.set_hatch(hatch_list[1])


# g6 = sns.barplot(
#     ax=axs[1, 2],
#     data=data6,
#     x="Shared sched logics",
#     y="Reconfig overhead (ms)",
#     hue="Policy",
#     # ci="sd",
#     errorbar=None,
#     palette=palette_console,
#     edgecolor="k",
#     # errcolor="black",
#     # errwidth=1.5,
#     # capsize=0.2,
#     width=0.8,
#     alpha=0.6,
#     # height=height,
#     # aspect=nginx_width/height,
# )
# # axs[1, 1].set_yscale("log")
# axs[1, 2].set_title("(e) Coyote's reconfig overhead", weight="bold")
# axs[1, 2].legend(loc="upper left")
# axs[1, 2].set_ylim([0, 150])
# for idx, bar in enumerate(axs[1, 2].containers[1]):
#     bar.set_hatch(hatch_list[1])

# Hide the empty subplot (axs[1, 2])
axs[1, 2].axis('off')

# plt.legend(loc="upper left")

fig.tight_layout()
fig.savefig("sched.png", bbox_inches="tight")
fig.savefig("sched.pdf", bbox_inches="tight")

print("Output: sched.png, sched.pdf")
