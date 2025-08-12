#!/usr/bin/env python3

import pandas as pd
import numpy as np
import matplotlib  # type: ignore
import matplotlib.pyplot as plt
import common
import seaborn as sns
import matplotlib.ticker as ticker

# ===== FONT AND STYLE SETTINGS =====
FONT_SIZE = 10
LABEL_SIZE = 10
TICK_SIZE = 10
LEGEND_SIZE = 9
ANNOTATION_SIZE = 9
VALUE_SIZE = 7

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
palette = sns.color_palette("pastel")
color1 = palette[0]  # Blue for vFPGA=1
color2 = palette[1]  # Orange for vFPGA=2
color3 = palette[2]  # Green for vFPGA=4
# color3 = '#2E8B57'    # Sea Green for vFPGA=4
color4 = palette[3]  # Red for vFPGA=8

# ===== DATA =====
vFPGA_count = ["1 vFPGA", "2 vFPGA", "3 vFPGA", "4 vFPGA"]

# Percentage of available resources per vFPGA
pr_time = [58000, 58000, 58000, 58000]
object_alloc = [3.6, 3.6*2, 3.6*3, 3.6*4]
mem_values = [2, 2*2, 2*3, 2*4]
buffer_alloc = [253.1, 253.1, 253.1, 253.1]


plt.rcParams.update({'font.size': 9.2})
width = 4.0
height = 2.8
# width = 7.0
# aspect = 2.0
# height = width / aspect
fig, (ax1, ax2, ax3) = plt.subplots(3, 1, sharex=True, figsize=(width, height))

# Set the formatter for the y-axis to use scientific notation for values over 1000
# ax1.yaxis.set_major_formatter(ticker.ScalarFormatter())
# ax1.ticklabel_format(style='sci', axis='y', scilimits=(3, 4))

ax1.set_ylim(55000, 60000)
ax2.set_ylim(200, 350)
ax3.set_ylim(0, 25)

# Hide the spines between plots
ax1.spines.bottom.set_visible(False)
ax2.spines.top.set_visible(False)
ax2.spines.bottom.set_visible(False)
ax3.spines.top.set_visible(False)

# Hide top spine
ax1.spines.top.set_visible(False)

# Hide the x axis from the upper plots
ax1.get_xaxis().set_visible(False)
ax2.get_xaxis().set_visible(False)

d = .5  # Proportion of vertical to horizontal extent of the slanted line
kwargs = dict(marker=[(-1, -d), (1, d)], markersize=10,
              linestyle="none", color='k', mec='k', mew=2, clip_on=False)
ax1.plot([0, 1], [0, 0], transform=ax1.transAxes, **kwargs)
ax2.plot([0, 1], [1, 1], transform=ax2.transAxes, **kwargs)
ax2.plot([0, 1], [0, 0], transform=ax2.transAxes, **kwargs)
ax3.plot([0, 1], [1, 1], transform=ax3.transAxes, **kwargs)

# x_labels = ["Boot unikernel", "Init platform",
#             "Create buffers", "Create kernel", "Exec kernel", "Sync"]
# [x_labels = ["Boot\nOS", "Init\nplatform",
# [            "Create\nbuffers", "Create\nkernel", "Execute", "Sync"]


bar_width = 0.18
x_positions = np.arange(len(vFPGA_count))

bar_props = {
    'alpha': 1.0,
    'edgecolor': 'k',
    'linewidth': 1.0,
    'error_kw': {'ecolor': 'black', 'elinewidth': 1, 'capsize': 2}
}


axs = [ax1, ax2, ax3]

for ax in axs:


    ax.bar(x_positions - 0.5*bar_width, buffer_alloc, bar_width,
                    color=color3, hatch='//',
                    label='buffer alloc', **bar_props)

    # vFPGA=2 bars (diagonal pattern)
    ax.bar(x_positions - 0.5*bar_width, pr_time, bar_width,
                    bottom=np.array(buffer_alloc),
                    color=color4, hatch='//',
                    label='partial reconfig', **bar_props)

    

    ax.bar(x_positions + 0.5*bar_width, object_alloc, bar_width,
                    color=color1, hatch='\\\\',
                    label='object cap', **bar_props)

    # vFPGA=2 bars (diagonal pattern)
    ax.bar(x_positions + 0.5*bar_width, mem_values, bar_width,
                    bottom=np.array(object_alloc),
                    color=color2, hatch='\\\\',
                    label='mem cap', **bar_props)

    # vFPGA=4 bars (dotted pattern)
    ax.bar(x_positions + 0.5*bar_width, buffer_alloc, bar_width,
                    bottom=np.array(object_alloc) + np.array(mem_values),
                    color=color3, hatch='\\\\',
                    **bar_props)
    



# plt.xticks(x, x_labels)
ax.set_xticks(x_positions, vFPGA_count)
ax.set_xticklabels(vFPGA_count, fontsize=9)
ax2.set_ylabel("Time (us)")
# ax2.yaxis.set_label_coords(-0.07, 0.7)
ax2.yaxis.set_label_coords(-0.18, 0.7)


p1 = matplotlib.patches.Patch(facecolor='white', hatch='//', edgecolor="k",
                        label='Coyote')
p2 = matplotlib.patches.Patch(facecolor='white', hatch='\\\\', edgecolor="k",
                        label='uShell')

handles, labels = ax1.get_legend_handles_labels()
handles += [p1, p2]
labels += ['Coyote', 'uShell']

ax1.legend(handles=handles, labels=labels, loc='upper right', frameon=True,
           ncol=3, prop={'size': 8.0}, bbox_to_anchor=(1, 1.9))

ax1.text(0.5, 3.28, 'Lower is better ↓', transform=ax.transAxes,
        color='navy', weight='bold', fontsize=ANNOTATION_SIZE, 
        ha='center', va='top', zorder=10)
plt.tight_layout()
# FIXME: plt.margiins() doesn't change margins for some reason...
plt.margins(x=0.0, tight=True) 
plt.subplots_adjust(wspace=0, hspace=0.05)

for ax in axs:
    ax.set_axisbelow(True)
    ax.yaxis.grid()

# ax.spines['top'].set_visible(False)
# ax.spines['right'].set_visible(False)
# ax.spines['bottom'].set_visible(False)
# ax.spines['left'].set_visible(False)
# ax.set_axisbelow(True)
# ax.grid(axis='y')

print("Saving figure to reconfig_overhead.png")
print("Saving figure to reconfig_overhead.pdf")
plt.savefig("reconfig_overhead.png", dpi=300, bbox_inches='tight')
plt.savefig("reconfig_overhead.pdf", dpi=300, bbox_inches='tight')