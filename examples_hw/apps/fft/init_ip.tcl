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

# Create FFT IP
create_ip -name xfft -vendor xilinx.com -library ip -version 9.1 -module_name xfft_0
set_property -dict [list \
    CONFIG.transform_length {16384} \
    CONFIG.data_format {floating_point} \
    CONFIG.implementation_options {automatically_select} \
    CONFIG.input_width {32} \
    CONFIG.output_ordering {natural_order} \
    CONFIG.aresetn {true} \
] [get_ips xfft_0]

# Create Constant blocks for FFT configuration
create_ip -name xlconstant -vendor xilinx.com -library ip -version 1.1 -module_name xlconstant_0
set_property -dict [list \
    CONFIG.CONST_WIDTH {16} \
    CONFIG.CONST_VAL {1} \
] [get_ips xlconstant_0]

create_ip -name xlconstant -vendor xilinx.com -library ip -version 1.1 -module_name xlconstant_1
set_property -dict [list \
    CONFIG.CONST_WIDTH {1} \
    CONFIG.CONST_VAL {1} \
] [get_ips xlconstant_1]

# Generate all IP targets
generate_target all [get_ips]
