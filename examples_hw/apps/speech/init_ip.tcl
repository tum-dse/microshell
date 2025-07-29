# Create Data Width Converter IPs
create_ip -name axis_dwidth_converter -vendor xilinx.com -library ip -version 1.1 -module_name dwidth_converter_512_64
set_property -dict [list \
    CONFIG.S_TDATA_NUM_BYTES {64} \
    CONFIG.M_TDATA_NUM_BYTES {8} \
    CONFIG.TID_WIDTH {4} \
    CONFIG.HAS_TLAST {1} \
] [get_ips dwidth_converter_512_64]

create_ip -name axis_dwidth_converter -vendor xilinx.com -library ip -version 1.1 -module_name dwidth_converter_64_512
set_property -dict [list \
    CONFIG.S_TDATA_NUM_BYTES {8} \
    CONFIG.M_TDATA_NUM_BYTES {64} \
    CONFIG.TID_WIDTH {4} \
    CONFIG.HAS_TLAST {1} \
] [get_ips dwidth_converter_64_512]

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

# Create FFT IP
create_ip -name xfft -vendor xilinx.com -library ip -version 9.1 -module_name xfft_0
set_property -dict [list \
    CONFIG.transform_length {32} \
    CONFIG.data_format {floating_point} \
    CONFIG.implementation_options {automatically_select} \
    CONFIG.input_width {32} \
    CONFIG.output_ordering {natural_order} \
    CONFIG.aresetn {true} \
] [get_ips xfft_0]

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_0
set_property -dict [list \
CONFIG.C_NUM_OF_PROBES {20} \
CONFIG.C_PROBE0_WIDTH {32} \
CONFIG.C_PROBE1_WIDTH {1} \
CONFIG.C_PROBE2_WIDTH {1} \
CONFIG.C_PROBE3_WIDTH {1} \
CONFIG.C_PROBE4_WIDTH {8} \
CONFIG.C_PROBE5_WIDTH {1} \
CONFIG.C_PROBE6_WIDTH {1} \
CONFIG.C_PROBE7_WIDTH {8} \
CONFIG.C_PROBE8_WIDTH {8} \
CONFIG.C_PROBE9_WIDTH {1} \
CONFIG.C_PROBE10_WIDTH {1} \
CONFIG.C_PROBE11_WIDTH {1} \
CONFIG.C_PROBE12_WIDTH {32} \
CONFIG.C_PROBE13_WIDTH {1} \
CONFIG.C_PROBE14_WIDTH {1} \
CONFIG.C_PROBE15_WIDTH {1} \
CONFIG.C_PROBE16_WIDTH {32} \
CONFIG.C_PROBE17_WIDTH {1} \
CONFIG.C_PROBE18_WIDTH {1} \
CONFIG.C_PROBE19_WIDTH {1} \
CONFIG.C_DATA_DEPTH {4096} \
] [get_ips ila_0]

# Generate all IP targets
generate_target all [get_ips]
