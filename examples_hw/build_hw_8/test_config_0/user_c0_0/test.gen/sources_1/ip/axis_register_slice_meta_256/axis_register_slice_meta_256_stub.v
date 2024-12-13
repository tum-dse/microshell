// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (lin64) Build 3526262 Mon Apr 18 15:47:01 MDT 2022
// Date        : Wed Nov 27 16:33:23 2024
// Host        : amy running 64-bit NixOS 24.05 (Uakari)
// Command     : write_verilog -force -mode synth_stub
//               /scratch/anubhav/Coyote/examples_hw/build_hw_8/test_config_0/user_c0_0/test.gen/sources_1/ip/axis_register_slice_meta_256/axis_register_slice_meta_256_stub.v
// Design      : axis_register_slice_meta_256
// Purpose     : Stub declaration of top-level module interface
// Device      : xcu280-fsvh2892-2L-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "axis_register_slice_v1_1_26_axis_register_slice,Vivado 2022.1" *)
module axis_register_slice_meta_256(aclk, aresetn, s_axis_tvalid, s_axis_tready, 
  s_axis_tdata, m_axis_tvalid, m_axis_tready, m_axis_tdata)
/* synthesis syn_black_box black_box_pad_pin="aclk,aresetn,s_axis_tvalid,s_axis_tready,s_axis_tdata[255:0],m_axis_tvalid,m_axis_tready,m_axis_tdata[255:0]" */;
  input aclk;
  input aresetn;
  input s_axis_tvalid;
  output s_axis_tready;
  input [255:0]s_axis_tdata;
  output m_axis_tvalid;
  input m_axis_tready;
  output [255:0]m_axis_tdata;
endmodule
