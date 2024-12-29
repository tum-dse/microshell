# Create Data Width Converter IPs
create_ip -name axis_dwidth_converter -vendor xilinx.com -library ip -version 1.1 -module_name dwidth_converter_512_32
set_property -dict [list \
    CONFIG.S_TDATA_NUM_BYTES {64} \
    CONFIG.M_TDATA_NUM_BYTES {4} \
    CONFIG.TID_WIDTH {4} \
    CONFIG.HAS_TLAST {1} \
] [get_ips dwidth_converter_512_32]

create_ip -name axis_dwidth_converter -vendor xilinx.com -library ip -version 1.1 -module_name dwidth_converter_32_512
set_property -dict [list \
    CONFIG.S_TDATA_NUM_BYTES {4} \
    CONFIG.M_TDATA_NUM_BYTES {64} \
    CONFIG.TID_WIDTH {4} \
    CONFIG.HAS_TLAST {1} \
] [get_ips dwidth_converter_32_512]

# Create Clock Wizard
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0
set_property -dict [list \
    CONFIG.PRIMITIVE {MMCM} \
    CONFIG.USE_LOCKED {true} \
    CONFIG.PRIM_SOURCE {Single_ended_clock_capable_pin} \
    CONFIG.PRIM_IN_FREQ {100.000} \
    CONFIG.CLKOUT1_USED {true} \
    CONFIG.NUM_OUT_CLKS {1} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {10.000} \
] [get_ips clk_wiz_0]

# For 10MHz clock domain
create_ip -name proc_sys_reset -vendor xilinx.com -library ip -version 5.0 -module_name proc_sys_reset_0
set_property -dict [list \
    CONFIG.USE_BOARD_FLOW {false} \
    CONFIG.RESET_BOARD_INTERFACE {Custom} \
    CONFIG.C_AUX_RESET_HIGH {0} \
    CONFIG.C_EXT_RESET_HIGH {1} \
] [get_ips proc_sys_reset_0]

# Generate all IP targets
generate_target all [get_ips]
