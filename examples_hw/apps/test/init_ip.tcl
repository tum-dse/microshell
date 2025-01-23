file mkdir $build_dir/iprepo
set cmd "exec unzip $hw_dir/ip/xilinx_com_hls_letterbox_c0_0_accel_1_0.zip -d $build_dir/iprepo/letterbox_accel"
eval $cmd
update_ip_catalog -rebuild

set letterbox_accel [create_ip -name letterbox_c0_0_accel -vendor xilinx.com -library hls -version 1.0 -module_name letterbox_accel]

set_property -dict {
    GENERATE_SYNTH_CHECKPOINT {1}
} $letterbox_accel

generate_target all [get_ips]