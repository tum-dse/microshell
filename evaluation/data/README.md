# Evaluation data

CSVs consumed by the plot scripts under `evaluation/scripts/`. One subdir
per paper figure / table — see `evaluation/scripts/README.md` for which
script produces and consumes each file.

| Dir              | Contents                                           |
|------------------|----------------------------------------------------|
| `complexity/`    | `complexity_{baseline,ushell}_results.csv` — Table 5 |
| `effectiveness/` | `effectiveness.csv` (written by `run_effectiveness.sh`) — Figure 3 |
| `scalability/`   | `scalability.csv` (merged from per-build raws by `plot_scalability.py`) — Figure 4 |
| `efficiency/`    | `module_resource_usage.csv` (raw Vivado hierarchical-util dump from the `resource_usage` build) |
| `scheduling/`    | `sched_*.csv` — Figure 12, plus `sched_motive.csv` for the reconfig motivation plot |
