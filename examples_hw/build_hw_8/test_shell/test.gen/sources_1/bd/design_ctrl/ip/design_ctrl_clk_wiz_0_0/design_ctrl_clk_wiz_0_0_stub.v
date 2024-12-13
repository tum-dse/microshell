// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (lin64) Build 3526262 Mon Apr 18 15:47:01 MDT 2022
// Date        : Wed Nov 27 16:20:22 2024
// Host        : amy running 64-bit NixOS 24.05 (Uakari)
// Command     : write_verilog -force -mode synth_stub
//               /scratch/anubhav/Coyote/examples_hw/build_hw_8/test_shell/test.gen/sources_1/bd/design_ctrl/ip/design_ctrl_clk_wiz_0_0/design_ctrl_clk_wiz_0_0_stub.v
// Design      : design_ctrl_clk_wiz_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xcu280-fsvh2892-2L-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module design_ctrl_clk_wiz_0_0(clk_out1, clk_out2, clk_out3, reset, locked, 
  clk_in1)
/* synthesis syn_black_box black_box_pad_pin="clk_out1,clk_out2,clk_out3,reset,locked,clk_in1" */;
  output clk_out1;
  output clk_out2;
  output clk_out3;
  input reset;
  output locked;
  input clk_in1;
endmodule
