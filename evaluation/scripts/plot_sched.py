import pandas
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import seaborn as sns

# ===== FONT AND STYLE SETTINGS =====
FONT_SIZE = 13
LABEL_SIZE = 11
TICK_SIZE = 12
LEGEND_SIZE = 10
VALUE_SIZE = 11

plt.rcParams['mathtext.fontset'] = 'cm'
plt.rcParams['font.size'] = FONT_SIZE
plt.rcParams['axes.labelsize'] = LABEL_SIZE
plt.rcParams['xtick.labelsize'] = TICK_SIZE
plt.rcParams['ytick.labelsize'] = TICK_SIZE
plt.rcParams['legend.fontsize'] = LEGEND_SIZE

# ===== COLOR SETUP =====
palette = sns.color_palette("pastel")
color1 = palette[0]  # Blue for Coyote
color2 = palette[1]  # Orange for uShell

# ===== HATCH PATTERNS =====
hatch1 = "//"   # Coyote
hatch2 = "\\\\"  # uShell

# ===== DATA LOADING =====
data1 = pandas.read_csv("../data/sched_latency.csv")
data2 = pandas.read_csv("../data/sched_reconfig.csv")
data3 = pandas.read_csv("../data/sched_resp_avg.csv")
data4 = pandas.read_csv("../data/sched_resp_95.csv")
data5 = pandas.read_csv("../data/sched_deadline.csv")


def latency_percentage(data1):
    # Calculate the latency percentages
    latency_array = [
        round(data1.loc[0, 'Latency[ms]'] / data1.loc[0, 'Latency[ms]'] * 100, 1),
        round(data1.loc[1, 'Latency[ms]'] / data1.loc[1, 'Latency[ms]'] * 100, 1),
        round(data1.loc[2, 'Latency[ms]'] / data1.loc[2, 'Latency[ms]'] * 100, 1),
        round(data1.loc[3, 'Latency[ms]'] / data1.loc[0, 'Latency[ms]'] * 100, 1),
        round(data1.loc[4, 'Latency[ms]'] / data1.loc[1, 'Latency[ms]'] * 100, 1),
        round(data1.loc[5, 'Latency[ms]'] / data1.loc[2, 'Latency[ms]'] * 100, 1)
    ]
    return latency_array

def config_percentage(data1):
    # Calculate the latency percentages
    latency_array = [
        round(data1.loc[0, 'Reconfig count'] / data1.loc[0, 'Reconfig count'] * 100, 1),
        round(data1.loc[1, 'Reconfig count'] / data1.loc[1, 'Reconfig count'] * 100, 1),
        round(data1.loc[2, 'Reconfig count'] / data1.loc[2, 'Reconfig count'] * 100, 1),
        round(data1.loc[3, 'Reconfig count'] / data1.loc[0, 'Reconfig count'] * 100, 1),
        round(data1.loc[4, 'Reconfig count'] / data1.loc[1, 'Reconfig count'] * 100, 1),
        round(data1.loc[5, 'Reconfig count'] / data1.loc[2, 'Reconfig count'] * 100, 1)
    ]
    return latency_array

def deadline_percentage(data1):
    # Calculate the latency percentages
    latency_array = [
        round(data1.loc[0, 'Deadline misses'] / data1.loc[0, 'Deadline misses'] * 100, 1),
        round(data1.loc[1, 'Deadline misses'] / data1.loc[1, 'Deadline misses'] * 100, 1),
        round(data1.loc[2, 'Deadline misses'] / data1.loc[2, 'Deadline misses'] * 100, 1),
        round(data1.loc[3, 'Deadline misses'] / data1.loc[0, 'Deadline misses'] * 100, 1),
        round(data1.loc[4, 'Deadline misses'] / data1.loc[1, 'Deadline misses'] * 100, 1),
        round(data1.loc[5, 'Deadline misses'] / data1.loc[2, 'Deadline misses'] * 100, 1)
    ]
    return latency_array

data_frame = [
    latency_percentage(data1),
    config_percentage(data2),
    latency_percentage(data3),
    latency_percentage(data4),
    deadline_percentage(data5)
]


palette = sns.color_palette("pastel")
color1 = palette[0]
color2 = palette[1]
color3 = palette[2]

# Bar settings
bar_width = 0.35  # Width for each individual bar
x_values = [8, 12, 16]  # Number of tasks
x_positions = np.arange(len(x_values))  # Position indices

# Common bar properties for matplotlib bar()
bar_props = {
    'alpha': 1.0,
    'edgecolor': 'k',
    'linewidth': 1
}

# ===== SUBPLOT DATA AND CONFIGURATION =====
subplot_configs = [
    (axs[0], data1, "Latency[ms]", "(a) Latency"),
    (axs[1], data2, "Reconfig count", "(b) Reconfig. count"),
    (axs[2], data3, "Latency[ms]", "(c) Avg. response time"),
    (axs[3], data4, "Latency[ms]", "(d) Tail response time"),
    (axs[4], data5, "Deadline misses", "(e) Missed deadlines")
]

width = 14  # \textwidth is 7 inch
height = 3.5

bar_width = 0.18

# fig, axs = plt.subplots(nrows=2, ncols=3, sharex=True)
fig, axs = plt.subplots(nrows=1, ncols=5, sharex=True)
fig.set_size_inches(width, height)
fig.suptitle(
    "Lower is better ↓", fontsize=FONT_SIZE, color="navy", weight="bold", x=0.73, y=0.08
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
    linewidth=1.0,
    width=0.8,
    capsize=2,
    alpha=1.0,
    # 'error_kw': {'ecolor': 'black', 'elinewidth': 1, 'capsize': 2}
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

for ax in axs[:]: 
    ax.set_xlabel('')
    
# Set the x-axis label only for the bottom subplot (last one)
# axs[4].set_xlabel("Number of tasks", fontsize=FONTSIZE)

fig.supxlabel("Number of tasks")

# Function to calculate and display the percentage on each bar
def annotate_bars(ax, data_array):
    idx = 0  # Index to access latency_array
    for container in ax.containers:
        for bar in container:
            # Calculate the relative percentage here (you can replace it with your own calculation)
            value = data_array[idx]
            idx += 1
            if height > 0:  # Check if the bar has non-zero height
                ax.text(
                    bar.get_x() + bar.get_width() / 2 + 0.1,  # X position (middle of the bar)
                    bar.get_height(),  # Y position (top of the bar)
                    f'{value:.0f}%',  # Display the percentage with one decimal point
                    ha='center',  # Align horizontally in the center
                    va='bottom',  # Position the text above the bar
                    fontsize=VALUE_SIZE,
                    color='black'  # Text color
                )


# Remove legends from individual subplots and add it once globally
idx = 0
for ax in axs:
    ax.get_legend().set_visible(False)

    # Grid
    ax.grid(True, alpha=0.3, axis='y', color='gray')
    ax.set_axisbelow(True)
    
    # Remove top and right spines
    sns.despine(ax=ax)
    annotate_bars(ax, data_frame[idx])
    idx += 1


# ===== SHARED X-AXIS LABEL =====
fig.supxlabel("Number of tasks", fontsize=LABEL_SIZE, y=-0.065)

# ===== GLOBAL LEGEND =====
# Use actual policy names from data
actual_policies = []
for ax, data, y_label, title in subplot_configs:
    for policy in data['Policy'].unique():
        if policy not in actual_policies:
            actual_policies.append(policy)
    break  # Just check first dataset

# fig.legend(handles=[p1, p2, p3], loc="center left", bbox_to_anchor=(1.0, 0.5), frameon=False, ncol=1)
fig.legend(handles=[p1, p2], loc="lower right",  bbox_to_anchor=(1, 0), frameon=True, ncol=5, fontsize=FONT_SIZE)

fig.legend(handles=legend_elements, 
          loc="lower right", 
          bbox_to_anchor=(0.99, -0.1), 
          frameon=True, 
          ncol=2)     

# ===== GLOBAL ANNOTATION =====
# Position annotation in the bottom right area
fig.text(0.76,-0.065, "Lower is better ↓", 
         fontsize=ANNOTATION_SIZE, 
         color="navy", 
         weight="bold", 
         ha='center', va='bottom')

# ===== SAVE AND DISPLAY =====
#fig.savefig("sched.png", dpi=300, bbox_inches="tight")
fig.savefig("../plots/sched.pdf", bbox_inches="tight")
plt.show()