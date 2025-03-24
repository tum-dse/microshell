create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_ctrl_fpga
set_property -dict [list \
    CONFIG.C_NUM_OF_PROBES {7} \
    CONFIG.C_PROBE0_WIDTH {2} \
    CONFIG.C_PROBE1_WIDTH {32} \
    CONFIG.C_PROBE2_WIDTH {64} \
    CONFIG.C_PROBE5_WIDTH {32} \
    CONFIG.C_EN_STRG_QUAL {1} \
    CONFIG.ALL_PROBE_SAME_MU_CNT {2} \
] [get_ips ila_ctrl_fpga]

# Generate all IP targets
generate_target all [get_ips]