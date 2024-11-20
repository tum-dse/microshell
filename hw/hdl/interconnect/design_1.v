//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
//Date        : Wed Nov 20 13:17:45 2024
//Host        : anubhav-ROG running 64-bit Ubuntu 22.04.5 LTS
//Command     : generate_target design_1.bd
//Design      : design_1
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,da_board_cnt=1,da_clkrst_cnt=1,synth_mode=Hierarchical}" *) (* HW_HANDOFF = "design_1.hwdef" *) 
module design_1
   (M00_AXIS_0_tdata,
    M00_AXIS_0_tdest,
    M00_AXIS_0_tready,
    M00_AXIS_0_tvalid,
    M01_AXIS_0_tdata,
    M01_AXIS_0_tdest,
    M01_AXIS_0_tready,
    M01_AXIS_0_tvalid,
    M02_AXIS_0_tdata,
    M02_AXIS_0_tdest,
    M02_AXIS_0_tready,
    M02_AXIS_0_tvalid,
    M03_AXIS_0_tdata,
    M03_AXIS_0_tdest,
    M03_AXIS_0_tready,
    M03_AXIS_0_tvalid,
    S00_AXIS_0_tdata,
    S00_AXIS_0_tdest,
    S00_AXIS_0_tready,
    S00_AXIS_0_tvalid,
    S01_AXIS_0_tdata,
    S01_AXIS_0_tdest,
    S01_AXIS_0_tready,
    S01_AXIS_0_tvalid,
    S02_AXIS_0_tdata,
    S02_AXIS_0_tdest,
    S02_AXIS_0_tready,
    S02_AXIS_0_tvalid,
    S03_AXIS_0_tdata,
    S03_AXIS_0_tdest,
    S03_AXIS_0_tready,
    S03_AXIS_0_tvalid,
    aclk_0,
    aresetn_0,
    s_decode_err_0);
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS_0 TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M00_AXIS_0, CLK_DOMAIN design_1_aclk_0, FREQ_HZ 10000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 1, TDEST_WIDTH 2, TID_WIDTH 0, TUSER_WIDTH 0" *) output [7:0]M00_AXIS_0_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS_0 TDEST" *) output [1:0]M00_AXIS_0_tdest;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS_0 TREADY" *) input [0:0]M00_AXIS_0_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS_0 TVALID" *) output [0:0]M00_AXIS_0_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M01_AXIS_0 TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M01_AXIS_0, CLK_DOMAIN design_1_aclk_0, FREQ_HZ 10000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 1, TDEST_WIDTH 2, TID_WIDTH 0, TUSER_WIDTH 0" *) output [7:0]M01_AXIS_0_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M01_AXIS_0 TDEST" *) output [1:0]M01_AXIS_0_tdest;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M01_AXIS_0 TREADY" *) input [0:0]M01_AXIS_0_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M01_AXIS_0 TVALID" *) output [0:0]M01_AXIS_0_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M02_AXIS_0 TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M02_AXIS_0, CLK_DOMAIN design_1_aclk_0, FREQ_HZ 10000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 1, TDEST_WIDTH 2, TID_WIDTH 0, TUSER_WIDTH 0" *) output [7:0]M02_AXIS_0_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M02_AXIS_0 TDEST" *) output [1:0]M02_AXIS_0_tdest;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M02_AXIS_0 TREADY" *) input [0:0]M02_AXIS_0_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M02_AXIS_0 TVALID" *) output [0:0]M02_AXIS_0_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M03_AXIS_0 TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M03_AXIS_0, CLK_DOMAIN design_1_aclk_0, FREQ_HZ 10000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 1, TDEST_WIDTH 2, TID_WIDTH 0, TUSER_WIDTH 0" *) output [7:0]M03_AXIS_0_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M03_AXIS_0 TDEST" *) output [1:0]M03_AXIS_0_tdest;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M03_AXIS_0 TREADY" *) input [0:0]M03_AXIS_0_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M03_AXIS_0 TVALID" *) output [0:0]M03_AXIS_0_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S00_AXIS_0 TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S00_AXIS_0, CLK_DOMAIN design_1_aclk_0, FREQ_HZ 10000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) input [7:0]S00_AXIS_0_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S00_AXIS_0 TDEST" *) input [1:0]S00_AXIS_0_tdest;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S00_AXIS_0 TREADY" *) output [0:0]S00_AXIS_0_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S00_AXIS_0 TVALID" *) input [0:0]S00_AXIS_0_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S01_AXIS_0 TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S01_AXIS_0, CLK_DOMAIN design_1_aclk_0, FREQ_HZ 10000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) input [7:0]S01_AXIS_0_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S01_AXIS_0 TDEST" *) input [1:0]S01_AXIS_0_tdest;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S01_AXIS_0 TREADY" *) output [0:0]S01_AXIS_0_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S01_AXIS_0 TVALID" *) input [0:0]S01_AXIS_0_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S02_AXIS_0 TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S02_AXIS_0, CLK_DOMAIN design_1_aclk_0, FREQ_HZ 10000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 1, TDEST_WIDTH 2, TID_WIDTH 0, TUSER_WIDTH 0" *) input [7:0]S02_AXIS_0_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S02_AXIS_0 TDEST" *) input [1:0]S02_AXIS_0_tdest;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S02_AXIS_0 TREADY" *) output [0:0]S02_AXIS_0_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S02_AXIS_0 TVALID" *) input [0:0]S02_AXIS_0_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S03_AXIS_0 TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S03_AXIS_0, CLK_DOMAIN design_1_aclk_0, FREQ_HZ 10000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 1, TDEST_WIDTH 2, TID_WIDTH 0, TUSER_WIDTH 0" *) input [7:0]S03_AXIS_0_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S03_AXIS_0 TDEST" *) input [1:0]S03_AXIS_0_tdest;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S03_AXIS_0 TREADY" *) output [0:0]S03_AXIS_0_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S03_AXIS_0 TVALID" *) input [0:0]S03_AXIS_0_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.ACLK_0 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.ACLK_0, ASSOCIATED_BUSIF M00_AXIS_0:S00_AXIS_0:S01_AXIS_0:M01_AXIS_0:M02_AXIS_0:M03_AXIS_0:S02_AXIS_0:S03_AXIS_0, ASSOCIATED_RESET aresetn_0, CLK_DOMAIN design_1_aclk_0, FREQ_HZ 10000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input aclk_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.ARESETN_0 RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.ARESETN_0, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input aresetn_0;
  output [3:0]s_decode_err_0;

  wire [7:0]S00_AXIS_0_1_TDATA;
  wire [1:0]S00_AXIS_0_1_TDEST;
  wire [0:0]S00_AXIS_0_1_TREADY;
  wire [0:0]S00_AXIS_0_1_TVALID;
  wire [7:0]S01_AXIS_0_1_TDATA;
  wire [1:0]S01_AXIS_0_1_TDEST;
  wire [1:1]S01_AXIS_0_1_TREADY;
  wire [0:0]S01_AXIS_0_1_TVALID;
  wire [7:0]S02_AXIS_0_1_TDATA;
  wire [1:0]S02_AXIS_0_1_TDEST;
  wire [2:2]S02_AXIS_0_1_TREADY;
  wire [0:0]S02_AXIS_0_1_TVALID;
  wire [7:0]S03_AXIS_0_1_TDATA;
  wire [1:0]S03_AXIS_0_1_TDEST;
  wire [3:3]S03_AXIS_0_1_TREADY;
  wire [0:0]S03_AXIS_0_1_TVALID;
  wire aclk_0_1;
  wire aresetn_0_1;
  wire [7:0]axis_switch_0_M00_AXIS_TDATA;
  wire [1:0]axis_switch_0_M00_AXIS_TDEST;
  wire [0:0]axis_switch_0_M00_AXIS_TREADY;
  wire [0:0]axis_switch_0_M00_AXIS_TVALID;
  wire [15:8]axis_switch_0_M01_AXIS_TDATA;
  wire [3:2]axis_switch_0_M01_AXIS_TDEST;
  wire [0:0]axis_switch_0_M01_AXIS_TREADY;
  wire [1:1]axis_switch_0_M01_AXIS_TVALID;
  wire [23:16]axis_switch_0_M02_AXIS_TDATA;
  wire [5:4]axis_switch_0_M02_AXIS_TDEST;
  wire [0:0]axis_switch_0_M02_AXIS_TREADY;
  wire [2:2]axis_switch_0_M02_AXIS_TVALID;
  wire [31:24]axis_switch_0_M03_AXIS_TDATA;
  wire [7:6]axis_switch_0_M03_AXIS_TDEST;
  wire [0:0]axis_switch_0_M03_AXIS_TREADY;
  wire [3:3]axis_switch_0_M03_AXIS_TVALID;
  wire [3:0]axis_switch_0_s_decode_err;

  assign M00_AXIS_0_tdata[7:0] = axis_switch_0_M00_AXIS_TDATA;
  assign M00_AXIS_0_tdest[1:0] = axis_switch_0_M00_AXIS_TDEST;
  assign M00_AXIS_0_tvalid[0] = axis_switch_0_M00_AXIS_TVALID;
  assign M01_AXIS_0_tdata[7:0] = axis_switch_0_M01_AXIS_TDATA;
  assign M01_AXIS_0_tdest[1:0] = axis_switch_0_M01_AXIS_TDEST;
  assign M01_AXIS_0_tvalid[0] = axis_switch_0_M01_AXIS_TVALID;
  assign M02_AXIS_0_tdata[7:0] = axis_switch_0_M02_AXIS_TDATA;
  assign M02_AXIS_0_tdest[1:0] = axis_switch_0_M02_AXIS_TDEST;
  assign M02_AXIS_0_tvalid[0] = axis_switch_0_M02_AXIS_TVALID;
  assign M03_AXIS_0_tdata[7:0] = axis_switch_0_M03_AXIS_TDATA;
  assign M03_AXIS_0_tdest[1:0] = axis_switch_0_M03_AXIS_TDEST;
  assign M03_AXIS_0_tvalid[0] = axis_switch_0_M03_AXIS_TVALID;
  assign S00_AXIS_0_1_TDATA = S00_AXIS_0_tdata[7:0];
  assign S00_AXIS_0_1_TDEST = S00_AXIS_0_tdest[1:0];
  assign S00_AXIS_0_1_TVALID = S00_AXIS_0_tvalid[0];
  assign S00_AXIS_0_tready[0] = S00_AXIS_0_1_TREADY;
  assign S01_AXIS_0_1_TDATA = S01_AXIS_0_tdata[7:0];
  assign S01_AXIS_0_1_TDEST = S01_AXIS_0_tdest[1:0];
  assign S01_AXIS_0_1_TVALID = S01_AXIS_0_tvalid[0];
  assign S01_AXIS_0_tready[0] = S01_AXIS_0_1_TREADY;
  assign S02_AXIS_0_1_TDATA = S02_AXIS_0_tdata[7:0];
  assign S02_AXIS_0_1_TDEST = S02_AXIS_0_tdest[1:0];
  assign S02_AXIS_0_1_TVALID = S02_AXIS_0_tvalid[0];
  assign S02_AXIS_0_tready[0] = S02_AXIS_0_1_TREADY;
  assign S03_AXIS_0_1_TDATA = S03_AXIS_0_tdata[7:0];
  assign S03_AXIS_0_1_TDEST = S03_AXIS_0_tdest[1:0];
  assign S03_AXIS_0_1_TVALID = S03_AXIS_0_tvalid[0];
  assign S03_AXIS_0_tready[0] = S03_AXIS_0_1_TREADY;
  assign aclk_0_1 = aclk_0;
  assign aresetn_0_1 = aresetn_0;
  assign axis_switch_0_M00_AXIS_TREADY = M00_AXIS_0_tready[0];
  assign axis_switch_0_M01_AXIS_TREADY = M01_AXIS_0_tready[0];
  assign axis_switch_0_M02_AXIS_TREADY = M02_AXIS_0_tready[0];
  assign axis_switch_0_M03_AXIS_TREADY = M03_AXIS_0_tready[0];
  assign s_decode_err_0[3:0] = axis_switch_0_s_decode_err;
  design_1_axis_switch_0_0 axis_switch_0
       (.aclk(aclk_0_1),
        .aresetn(aresetn_0_1),
        .m_axis_tdata({axis_switch_0_M03_AXIS_TDATA,axis_switch_0_M02_AXIS_TDATA,axis_switch_0_M01_AXIS_TDATA,axis_switch_0_M00_AXIS_TDATA}),
        .m_axis_tdest({axis_switch_0_M03_AXIS_TDEST,axis_switch_0_M02_AXIS_TDEST,axis_switch_0_M01_AXIS_TDEST,axis_switch_0_M00_AXIS_TDEST}),
        .m_axis_tready({axis_switch_0_M03_AXIS_TREADY,axis_switch_0_M02_AXIS_TREADY,axis_switch_0_M01_AXIS_TREADY,axis_switch_0_M00_AXIS_TREADY}),
        .m_axis_tvalid({axis_switch_0_M03_AXIS_TVALID,axis_switch_0_M02_AXIS_TVALID,axis_switch_0_M01_AXIS_TVALID,axis_switch_0_M00_AXIS_TVALID}),
        .s_axis_tdata({S03_AXIS_0_1_TDATA,S02_AXIS_0_1_TDATA,S01_AXIS_0_1_TDATA,S00_AXIS_0_1_TDATA}),
        .s_axis_tdest({S03_AXIS_0_1_TDEST,S02_AXIS_0_1_TDEST,S01_AXIS_0_1_TDEST,S00_AXIS_0_1_TDEST}),
        .s_axis_tready({S03_AXIS_0_1_TREADY,S02_AXIS_0_1_TREADY,S01_AXIS_0_1_TREADY,S00_AXIS_0_1_TREADY}),
        .s_axis_tvalid({S03_AXIS_0_1_TVALID,S02_AXIS_0_1_TVALID,S01_AXIS_0_1_TVALID,S00_AXIS_0_1_TVALID}),
        .s_decode_err(axis_switch_0_s_decode_err));
endmodule
