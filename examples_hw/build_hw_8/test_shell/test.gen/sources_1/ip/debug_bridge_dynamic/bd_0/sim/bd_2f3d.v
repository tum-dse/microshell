//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Command: generate_target bd_2f3d.bd
//Design : bd_2f3d
//Purpose: IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "bd_2f3d,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=bd_2f3d,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=3,numReposBlks=3,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=SBD,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "debug_bridge_dynamic.hwdef" *) 
module bd_2f3d
   (S_BSCAN_bscanid_en,
    S_BSCAN_capture,
    S_BSCAN_drck,
    S_BSCAN_reset,
    S_BSCAN_runtest,
    S_BSCAN_sel,
    S_BSCAN_shift,
    S_BSCAN_tck,
    S_BSCAN_tdi,
    S_BSCAN_tdo,
    S_BSCAN_tms,
    S_BSCAN_update,
    clk,
    m0_bscan_bscanid_en,
    m0_bscan_capture,
    m0_bscan_drck,
    m0_bscan_reset,
    m0_bscan_runtest,
    m0_bscan_sel,
    m0_bscan_shift,
    m0_bscan_tck,
    m0_bscan_tdi,
    m0_bscan_tdo,
    m0_bscan_tms,
    m0_bscan_update);
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 S_BSCAN BSCANID_EN" *) input S_BSCAN_bscanid_en;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 S_BSCAN CAPTURE" *) input S_BSCAN_capture;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 S_BSCAN DRCK" *) input S_BSCAN_drck;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 S_BSCAN RESET" *) input S_BSCAN_reset;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 S_BSCAN RUNTEST" *) input S_BSCAN_runtest;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 S_BSCAN SEL" *) input S_BSCAN_sel;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 S_BSCAN SHIFT" *) input S_BSCAN_shift;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 S_BSCAN TCK" *) input S_BSCAN_tck;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 S_BSCAN TDI" *) input S_BSCAN_tdi;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 S_BSCAN TDO" *) output S_BSCAN_tdo;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 S_BSCAN TMS" *) input S_BSCAN_tms;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 S_BSCAN UPDATE" *) input S_BSCAN_update;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK, CLK_DOMAIN bd_2f3d_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input clk;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 m0_bscan BSCANID_en" *) output m0_bscan_bscanid_en;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 m0_bscan CAPTURE" *) output m0_bscan_capture;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 m0_bscan DRCK" *) output m0_bscan_drck;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 m0_bscan RESET" *) output m0_bscan_reset;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 m0_bscan RUNTEST" *) output m0_bscan_runtest;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 m0_bscan SEL" *) output m0_bscan_sel;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 m0_bscan SHIFT" *) output m0_bscan_shift;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 m0_bscan TCK" *) output m0_bscan_tck;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 m0_bscan TDI" *) output m0_bscan_tdi;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 m0_bscan TDO" *) input m0_bscan_tdo;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 m0_bscan TMS" *) output m0_bscan_tms;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 m0_bscan UPDATE" *) output m0_bscan_update;

  wire S_BSCAN_1_BSCANID_EN;
  wire S_BSCAN_1_CAPTURE;
  wire S_BSCAN_1_DRCK;
  wire S_BSCAN_1_RESET;
  wire S_BSCAN_1_RUNTEST;
  wire S_BSCAN_1_SEL;
  wire S_BSCAN_1_SHIFT;
  wire S_BSCAN_1_TCK;
  wire S_BSCAN_1_TDI;
  wire S_BSCAN_1_TDO;
  wire S_BSCAN_1_TMS;
  wire S_BSCAN_1_UPDATE;
  wire bs_switch_m0_bscan_BSCANID_en;
  wire bs_switch_m0_bscan_CAPTURE;
  wire bs_switch_m0_bscan_DRCK;
  wire bs_switch_m0_bscan_RESET;
  wire bs_switch_m0_bscan_RUNTEST;
  wire bs_switch_m0_bscan_SEL;
  wire bs_switch_m0_bscan_SHIFT;
  wire bs_switch_m0_bscan_TCK;
  wire bs_switch_m0_bscan_TDI;
  wire bs_switch_m0_bscan_TDO;
  wire bs_switch_m0_bscan_TMS;
  wire bs_switch_m0_bscan_UPDATE;
  wire bs_switch_m1_bscan_BSCANID_en;
  wire bs_switch_m1_bscan_CAPTURE;
  wire bs_switch_m1_bscan_DRCK;
  wire bs_switch_m1_bscan_RESET;
  wire bs_switch_m1_bscan_RUNTEST;
  wire bs_switch_m1_bscan_SEL;
  wire bs_switch_m1_bscan_SHIFT;
  wire bs_switch_m1_bscan_TCK;
  wire bs_switch_m1_bscan_TDI;
  wire bs_switch_m1_bscan_TDO;
  wire bs_switch_m1_bscan_TMS;
  wire bs_switch_m1_bscan_UPDATE;
  wire clk_1;
  wire lut_buffer_m_bscan_BSCANID_EN;
  wire lut_buffer_m_bscan_CAPTURE;
  wire lut_buffer_m_bscan_DRCK;
  wire lut_buffer_m_bscan_RESET;
  wire lut_buffer_m_bscan_RUNTEST;
  wire lut_buffer_m_bscan_SEL;
  wire lut_buffer_m_bscan_SHIFT;
  wire lut_buffer_m_bscan_TCK;
  wire lut_buffer_m_bscan_TDI;
  wire lut_buffer_m_bscan_TDO;
  wire lut_buffer_m_bscan_TMS;
  wire lut_buffer_m_bscan_UPDATE;

  assign S_BSCAN_1_BSCANID_EN = S_BSCAN_bscanid_en;
  assign S_BSCAN_1_CAPTURE = S_BSCAN_capture;
  assign S_BSCAN_1_DRCK = S_BSCAN_drck;
  assign S_BSCAN_1_RESET = S_BSCAN_reset;
  assign S_BSCAN_1_RUNTEST = S_BSCAN_runtest;
  assign S_BSCAN_1_SEL = S_BSCAN_sel;
  assign S_BSCAN_1_SHIFT = S_BSCAN_shift;
  assign S_BSCAN_1_TCK = S_BSCAN_tck;
  assign S_BSCAN_1_TDI = S_BSCAN_tdi;
  assign S_BSCAN_1_TMS = S_BSCAN_tms;
  assign S_BSCAN_1_UPDATE = S_BSCAN_update;
  assign S_BSCAN_tdo = S_BSCAN_1_TDO;
  assign bs_switch_m1_bscan_TDO = m0_bscan_tdo;
  assign clk_1 = clk;
  assign m0_bscan_bscanid_en = bs_switch_m1_bscan_BSCANID_en;
  assign m0_bscan_capture = bs_switch_m1_bscan_CAPTURE;
  assign m0_bscan_drck = bs_switch_m1_bscan_DRCK;
  assign m0_bscan_reset = bs_switch_m1_bscan_RESET;
  assign m0_bscan_runtest = bs_switch_m1_bscan_RUNTEST;
  assign m0_bscan_sel = bs_switch_m1_bscan_SEL;
  assign m0_bscan_shift = bs_switch_m1_bscan_SHIFT;
  assign m0_bscan_tck = bs_switch_m1_bscan_TCK;
  assign m0_bscan_tdi = bs_switch_m1_bscan_TDI;
  assign m0_bscan_tms = bs_switch_m1_bscan_TMS;
  assign m0_bscan_update = bs_switch_m1_bscan_UPDATE;
  bd_2f3d_bs_switch_0 bs_switch
       (.bscanid_en_0(bs_switch_m0_bscan_BSCANID_en),
        .bscanid_en_1(bs_switch_m1_bscan_BSCANID_en),
        .capture_0(bs_switch_m0_bscan_CAPTURE),
        .capture_1(bs_switch_m1_bscan_CAPTURE),
        .drck_0(bs_switch_m0_bscan_DRCK),
        .drck_1(bs_switch_m1_bscan_DRCK),
        .reset_0(bs_switch_m0_bscan_RESET),
        .reset_1(bs_switch_m1_bscan_RESET),
        .runtest_0(bs_switch_m0_bscan_RUNTEST),
        .runtest_1(bs_switch_m1_bscan_RUNTEST),
        .s_bscan_capture(lut_buffer_m_bscan_CAPTURE),
        .s_bscan_drck(lut_buffer_m_bscan_DRCK),
        .s_bscan_reset(lut_buffer_m_bscan_RESET),
        .s_bscan_runtest(lut_buffer_m_bscan_RUNTEST),
        .s_bscan_sel(lut_buffer_m_bscan_SEL),
        .s_bscan_shift(lut_buffer_m_bscan_SHIFT),
        .s_bscan_tck(lut_buffer_m_bscan_TCK),
        .s_bscan_tdi(lut_buffer_m_bscan_TDI),
        .s_bscan_tdo(lut_buffer_m_bscan_TDO),
        .s_bscan_tms(lut_buffer_m_bscan_TMS),
        .s_bscan_update(lut_buffer_m_bscan_UPDATE),
        .s_bscanid_en(lut_buffer_m_bscan_BSCANID_EN),
        .sel_0(bs_switch_m0_bscan_SEL),
        .sel_1(bs_switch_m1_bscan_SEL),
        .shift_0(bs_switch_m0_bscan_SHIFT),
        .shift_1(bs_switch_m1_bscan_SHIFT),
        .tck_0(bs_switch_m0_bscan_TCK),
        .tck_1(bs_switch_m1_bscan_TCK),
        .tdi_0(bs_switch_m0_bscan_TDI),
        .tdi_1(bs_switch_m1_bscan_TDI),
        .tdo_0(bs_switch_m0_bscan_TDO),
        .tdo_1(bs_switch_m1_bscan_TDO),
        .tms_0(bs_switch_m0_bscan_TMS),
        .tms_1(bs_switch_m1_bscan_TMS),
        .update_0(bs_switch_m0_bscan_UPDATE),
        .update_1(bs_switch_m1_bscan_UPDATE));
  bd_2f3d_lut_buffer_0 lut_buffer
       (.bscanid_en_i(S_BSCAN_1_BSCANID_EN),
        .bscanid_en_o(lut_buffer_m_bscan_BSCANID_EN),
        .capture_i(S_BSCAN_1_CAPTURE),
        .capture_o(lut_buffer_m_bscan_CAPTURE),
        .drck_i(S_BSCAN_1_DRCK),
        .drck_o(lut_buffer_m_bscan_DRCK),
        .reset_i(S_BSCAN_1_RESET),
        .reset_o(lut_buffer_m_bscan_RESET),
        .runtest_i(S_BSCAN_1_RUNTEST),
        .runtest_o(lut_buffer_m_bscan_RUNTEST),
        .sel_i(S_BSCAN_1_SEL),
        .sel_o(lut_buffer_m_bscan_SEL),
        .shift_i(S_BSCAN_1_SHIFT),
        .shift_o(lut_buffer_m_bscan_SHIFT),
        .tck_i(S_BSCAN_1_TCK),
        .tck_o(lut_buffer_m_bscan_TCK),
        .tdi_i(S_BSCAN_1_TDI),
        .tdi_o(lut_buffer_m_bscan_TDI),
        .tdo_i(lut_buffer_m_bscan_TDO),
        .tdo_o(S_BSCAN_1_TDO),
        .tms_i(S_BSCAN_1_TMS),
        .tms_o(lut_buffer_m_bscan_TMS),
        .update_i(S_BSCAN_1_UPDATE),
        .update_o(lut_buffer_m_bscan_UPDATE));
  bd_2f3d_xsdbm_0 xsdbm
       (.bscanid_en(bs_switch_m0_bscan_BSCANID_en),
        .capture(bs_switch_m0_bscan_CAPTURE),
        .clk(clk_1),
        .drck(bs_switch_m0_bscan_DRCK),
        .reset(bs_switch_m0_bscan_RESET),
        .runtest(bs_switch_m0_bscan_RUNTEST),
        .sel(bs_switch_m0_bscan_SEL),
        .shift(bs_switch_m0_bscan_SHIFT),
        .tck(bs_switch_m0_bscan_TCK),
        .tdi(bs_switch_m0_bscan_TDI),
        .tdo(bs_switch_m0_bscan_TDO),
        .tms(bs_switch_m0_bscan_TMS),
        .update(bs_switch_m0_bscan_UPDATE));
endmodule
