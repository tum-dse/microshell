# ILA cores for perf_local_2:
#   ila_perf_host   — 6 probes for the host-stream loop.
#   ila_perf_host_2 — 12 probes for combined host + card streams.
# vfpga_top.svh only instantiates ila_perf_host today; ila_perf_host_2 is
# kept for symmetry with perf_local's IP set.

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_perf_host

set_property -dict {
    CONFIG.C_NUM_OF_PROBES {6}
    CONFIG.C_EN_STRG_QUAL {1}
    CONFIG.ALL_PROBE_SAME_MU_CNT {2}
} [get_ips ila_perf_host]

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_perf_host_2

set_property -dict {
    CONFIG.C_NUM_OF_PROBES {12}
    CONFIG.C_EN_STRG_QUAL {1}
    CONFIG.ALL_PROBE_SAME_MU_CNT {2}
} [get_ips ila_perf_host_2]
