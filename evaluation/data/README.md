# Evaluation data

CSVs consumed by the plot scripts under `evaluation/scripts/`. One subdir
per paper figure / table — see `evaluation/scripts/README.md` for which
script produces and consumes each file.

| Dir                | Paper output | Contents                                           |
|--------------------|--------------|----------------------------------------------------|
| `composability_2/`   | Figure 2     | `similarity_matrix.csv`, `overlap_matrix.csv` (in scripts dir) |
| `effectiveness_2/`   | Figure 3     | `effectiveness.csv` (paper rows + measured rows)   |
| `scalability_2/`     | Figure 4     | `scalability.csv` (merged from per-build raws)     |
| `resource_usage_2/`  | Figure 5     | `module_resource_usage.csv` (Vivado dump from the 7-vFPGA build) |
| `reconfig_2/`        | Figure 6     | `sched_motive.csv` (reconfig-motivation source)    |
| `e2e_6.1/`             | Figure 11    | `e2e.csv` (paper rows + measured rows)             |
| `scheduling_6.2/`      | Figure 12    | `sched_{latency,reconfig,resp_avg,resp_95,deadline}.csv` |
| `deployment_6.3/`      | Figure 13    | `reconfig_{cap,pr}.log` + `reconfig_times.csv`     |
| `complexity_6.4/`      | Table 5      | `complexity_{baseline,ushell}_results.csv`         |
| `efficiency_6.5/`      | Table 6      | `util_{coyote,ushell,inter_4,inter_6,inter_8}.csv` |
