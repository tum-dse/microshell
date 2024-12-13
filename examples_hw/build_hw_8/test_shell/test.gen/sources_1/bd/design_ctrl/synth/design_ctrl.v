//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.1 (lin64) Build 3526262 Mon Apr 18 15:47:01 MDT 2022
//Date        : Wed Nov 27 16:16:59 2024
//Host        : amy running 64-bit NixOS 24.05 (Uakari)
//Command     : generate_target design_ctrl.bd
//Design      : design_ctrl
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "design_ctrl,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_ctrl,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=25,numReposBlks=20,numNonXlnxBlks=0,numHierBlks=5,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "design_ctrl.hwdef" *) 
module design_ctrl
   (aclk,
    aresetn,
    axi_cnfg_araddr,
    axi_cnfg_arprot,
    axi_cnfg_arready,
    axi_cnfg_arvalid,
    axi_cnfg_awaddr,
    axi_cnfg_awprot,
    axi_cnfg_awready,
    axi_cnfg_awvalid,
    axi_cnfg_bready,
    axi_cnfg_bresp,
    axi_cnfg_bvalid,
    axi_cnfg_rdata,
    axi_cnfg_rready,
    axi_cnfg_rresp,
    axi_cnfg_rvalid,
    axi_cnfg_wdata,
    axi_cnfg_wready,
    axi_cnfg_wstrb,
    axi_cnfg_wvalid,
    axi_ctrl_0_araddr,
    axi_ctrl_0_arprot,
    axi_ctrl_0_arready,
    axi_ctrl_0_arvalid,
    axi_ctrl_0_awaddr,
    axi_ctrl_0_awprot,
    axi_ctrl_0_awready,
    axi_ctrl_0_awvalid,
    axi_ctrl_0_bready,
    axi_ctrl_0_bresp,
    axi_ctrl_0_bvalid,
    axi_ctrl_0_rdata,
    axi_ctrl_0_rready,
    axi_ctrl_0_rresp,
    axi_ctrl_0_rvalid,
    axi_ctrl_0_wdata,
    axi_ctrl_0_wready,
    axi_ctrl_0_wstrb,
    axi_ctrl_0_wvalid,
    axi_main_araddr,
    axi_main_arburst,
    axi_main_arcache,
    axi_main_arid,
    axi_main_arlen,
    axi_main_arlock,
    axi_main_arprot,
    axi_main_arqos,
    axi_main_arready,
    axi_main_arregion,
    axi_main_arsize,
    axi_main_arvalid,
    axi_main_awaddr,
    axi_main_awburst,
    axi_main_awcache,
    axi_main_awid,
    axi_main_awlen,
    axi_main_awlock,
    axi_main_awprot,
    axi_main_awqos,
    axi_main_awready,
    axi_main_awregion,
    axi_main_awsize,
    axi_main_awvalid,
    axi_main_bid,
    axi_main_bready,
    axi_main_bresp,
    axi_main_bvalid,
    axi_main_rdata,
    axi_main_rid,
    axi_main_rlast,
    axi_main_rready,
    axi_main_rresp,
    axi_main_rvalid,
    axi_main_wdata,
    axi_main_wlast,
    axi_main_wready,
    axi_main_wstrb,
    axi_main_wvalid,
    axim_ctrl_0_araddr,
    axim_ctrl_0_arburst,
    axim_ctrl_0_arcache,
    axim_ctrl_0_arlen,
    axim_ctrl_0_arlock,
    axim_ctrl_0_arprot,
    axim_ctrl_0_arqos,
    axim_ctrl_0_arready,
    axim_ctrl_0_arregion,
    axim_ctrl_0_arsize,
    axim_ctrl_0_arvalid,
    axim_ctrl_0_awaddr,
    axim_ctrl_0_awburst,
    axim_ctrl_0_awcache,
    axim_ctrl_0_awlen,
    axim_ctrl_0_awlock,
    axim_ctrl_0_awprot,
    axim_ctrl_0_awqos,
    axim_ctrl_0_awready,
    axim_ctrl_0_awregion,
    axim_ctrl_0_awsize,
    axim_ctrl_0_awvalid,
    axim_ctrl_0_bready,
    axim_ctrl_0_bresp,
    axim_ctrl_0_bvalid,
    axim_ctrl_0_rdata,
    axim_ctrl_0_rlast,
    axim_ctrl_0_rready,
    axim_ctrl_0_rresp,
    axim_ctrl_0_rvalid,
    axim_ctrl_0_wdata,
    axim_ctrl_0_wlast,
    axim_ctrl_0_wready,
    axim_ctrl_0_wstrb,
    axim_ctrl_0_wvalid,
    lckresetn,
    nclk,
    nresetn,
    sys_reset,
    uclk,
    uresetn,
    xclk,
    xresetn);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.ACLK, ASSOCIATED_BUSIF axi_cnfg:axi_ctrl_0:axim_ctrl_0, ASSOCIATED_RESET aresetn, CLK_DOMAIN /clk_wiz_0_clk_out1, FREQ_HZ 250000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) output aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.ARESETN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.ARESETN, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) output [0:0]aresetn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_cnfg ARADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME axi_cnfg, ADDR_WIDTH 64, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN /clk_wiz_0_clk_out1, DATA_WIDTH 64, FREQ_HZ 250000000, HAS_BRESP 1, HAS_BURST 1, HAS_CACHE 1, HAS_LOCK 1, HAS_PROT 1, HAS_QOS 1, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 0, INSERT_VIP 0, MAX_BURST_LENGTH 1, NUM_READ_OUTSTANDING 2, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 2, NUM_WRITE_THREADS 1, PHASE 0.0, PROTOCOL AXI4LITE, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 0, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) output [63:0]axi_cnfg_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_cnfg ARPROT" *) output [2:0]axi_cnfg_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_cnfg ARREADY" *) input axi_cnfg_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_cnfg ARVALID" *) output axi_cnfg_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_cnfg AWADDR" *) output [63:0]axi_cnfg_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_cnfg AWPROT" *) output [2:0]axi_cnfg_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_cnfg AWREADY" *) input axi_cnfg_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_cnfg AWVALID" *) output axi_cnfg_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_cnfg BREADY" *) output axi_cnfg_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_cnfg BRESP" *) input [1:0]axi_cnfg_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_cnfg BVALID" *) input axi_cnfg_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_cnfg RDATA" *) input [63:0]axi_cnfg_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_cnfg RREADY" *) output axi_cnfg_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_cnfg RRESP" *) input [1:0]axi_cnfg_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_cnfg RVALID" *) input axi_cnfg_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_cnfg WDATA" *) output [63:0]axi_cnfg_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_cnfg WREADY" *) input axi_cnfg_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_cnfg WSTRB" *) output [7:0]axi_cnfg_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_cnfg WVALID" *) output axi_cnfg_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ctrl_0 ARADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME axi_ctrl_0, ADDR_WIDTH 64, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN /clk_wiz_0_clk_out1, DATA_WIDTH 64, FREQ_HZ 250000000, HAS_BRESP 1, HAS_BURST 1, HAS_CACHE 1, HAS_LOCK 1, HAS_PROT 1, HAS_QOS 1, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 0, INSERT_VIP 0, MAX_BURST_LENGTH 1, NUM_READ_OUTSTANDING 2, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 2, NUM_WRITE_THREADS 1, PHASE 0.0, PROTOCOL AXI4LITE, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 0, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) output [63:0]axi_ctrl_0_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ctrl_0 ARPROT" *) output [2:0]axi_ctrl_0_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ctrl_0 ARREADY" *) input axi_ctrl_0_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ctrl_0 ARVALID" *) output axi_ctrl_0_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ctrl_0 AWADDR" *) output [63:0]axi_ctrl_0_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ctrl_0 AWPROT" *) output [2:0]axi_ctrl_0_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ctrl_0 AWREADY" *) input axi_ctrl_0_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ctrl_0 AWVALID" *) output axi_ctrl_0_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ctrl_0 BREADY" *) output axi_ctrl_0_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ctrl_0 BRESP" *) input [1:0]axi_ctrl_0_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ctrl_0 BVALID" *) input axi_ctrl_0_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ctrl_0 RDATA" *) input [63:0]axi_ctrl_0_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ctrl_0 RREADY" *) output axi_ctrl_0_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ctrl_0 RRESP" *) input [1:0]axi_ctrl_0_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ctrl_0 RVALID" *) input axi_ctrl_0_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ctrl_0 WDATA" *) output [63:0]axi_ctrl_0_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ctrl_0 WREADY" *) input axi_ctrl_0_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ctrl_0 WSTRB" *) output [7:0]axi_ctrl_0_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_ctrl_0 WVALID" *) output axi_ctrl_0_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main ARADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME axi_main, ADDR_WIDTH 64, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN design_ctrl_xclk, DATA_WIDTH 512, FREQ_HZ 250000000, HAS_BRESP 1, HAS_BURST 1, HAS_CACHE 1, HAS_LOCK 1, HAS_PROT 1, HAS_QOS 1, HAS_REGION 1, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 6, INSERT_VIP 0, MAX_BURST_LENGTH 16, NUM_READ_OUTSTANDING 8, NUM_READ_THREADS 2, NUM_WRITE_OUTSTANDING 8, NUM_WRITE_THREADS 2, PHASE 0.0, PROTOCOL AXI4, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 0, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) input [63:0]axi_main_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main ARBURST" *) input [1:0]axi_main_arburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main ARCACHE" *) input [3:0]axi_main_arcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main ARID" *) input [5:0]axi_main_arid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main ARLEN" *) input [7:0]axi_main_arlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main ARLOCK" *) input [0:0]axi_main_arlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main ARPROT" *) input [2:0]axi_main_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main ARQOS" *) input [3:0]axi_main_arqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main ARREADY" *) output axi_main_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main ARREGION" *) input [3:0]axi_main_arregion;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main ARSIZE" *) input [2:0]axi_main_arsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main ARVALID" *) input axi_main_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main AWADDR" *) input [63:0]axi_main_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main AWBURST" *) input [1:0]axi_main_awburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main AWCACHE" *) input [3:0]axi_main_awcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main AWID" *) input [5:0]axi_main_awid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main AWLEN" *) input [7:0]axi_main_awlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main AWLOCK" *) input [0:0]axi_main_awlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main AWPROT" *) input [2:0]axi_main_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main AWQOS" *) input [3:0]axi_main_awqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main AWREADY" *) output axi_main_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main AWREGION" *) input [3:0]axi_main_awregion;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main AWSIZE" *) input [2:0]axi_main_awsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main AWVALID" *) input axi_main_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main BID" *) output [5:0]axi_main_bid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main BREADY" *) input axi_main_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main BRESP" *) output [1:0]axi_main_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main BVALID" *) output axi_main_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main RDATA" *) output [511:0]axi_main_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main RID" *) output [5:0]axi_main_rid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main RLAST" *) output axi_main_rlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main RREADY" *) input axi_main_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main RRESP" *) output [1:0]axi_main_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main RVALID" *) output axi_main_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main WDATA" *) input [511:0]axi_main_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main WLAST" *) input axi_main_wlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main WREADY" *) output axi_main_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main WSTRB" *) input [63:0]axi_main_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_main WVALID" *) input axi_main_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 ARADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME axim_ctrl_0, ADDR_WIDTH 64, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN /clk_wiz_0_clk_out1, DATA_WIDTH 256, FREQ_HZ 250000000, HAS_BRESP 1, HAS_BURST 1, HAS_CACHE 1, HAS_LOCK 1, HAS_PROT 1, HAS_QOS 0, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 0, INSERT_VIP 0, MAX_BURST_LENGTH 32, NUM_READ_OUTSTANDING 8, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 8, NUM_WRITE_THREADS 1, PHASE 0.0, PROTOCOL AXI4, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 0, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) output [63:0]axim_ctrl_0_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 ARBURST" *) output [1:0]axim_ctrl_0_arburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 ARCACHE" *) output [3:0]axim_ctrl_0_arcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 ARLEN" *) output [7:0]axim_ctrl_0_arlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 ARLOCK" *) output [0:0]axim_ctrl_0_arlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 ARPROT" *) output [2:0]axim_ctrl_0_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 ARQOS" *) output [3:0]axim_ctrl_0_arqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 ARREADY" *) input axim_ctrl_0_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 ARREGION" *) output [3:0]axim_ctrl_0_arregion;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 ARSIZE" *) output [2:0]axim_ctrl_0_arsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 ARVALID" *) output axim_ctrl_0_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 AWADDR" *) output [63:0]axim_ctrl_0_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 AWBURST" *) output [1:0]axim_ctrl_0_awburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 AWCACHE" *) output [3:0]axim_ctrl_0_awcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 AWLEN" *) output [7:0]axim_ctrl_0_awlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 AWLOCK" *) output [0:0]axim_ctrl_0_awlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 AWPROT" *) output [2:0]axim_ctrl_0_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 AWQOS" *) output [3:0]axim_ctrl_0_awqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 AWREADY" *) input axim_ctrl_0_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 AWREGION" *) output [3:0]axim_ctrl_0_awregion;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 AWSIZE" *) output [2:0]axim_ctrl_0_awsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 AWVALID" *) output axim_ctrl_0_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 BREADY" *) output axim_ctrl_0_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 BRESP" *) input [1:0]axim_ctrl_0_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 BVALID" *) input axim_ctrl_0_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 RDATA" *) input [255:0]axim_ctrl_0_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 RLAST" *) input axim_ctrl_0_rlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 RREADY" *) output axim_ctrl_0_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 RRESP" *) input [1:0]axim_ctrl_0_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 RVALID" *) input axim_ctrl_0_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 WDATA" *) output [255:0]axim_ctrl_0_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 WLAST" *) output axim_ctrl_0_wlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 WREADY" *) input axim_ctrl_0_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 WSTRB" *) output [31:0]axim_ctrl_0_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axim_ctrl_0 WVALID" *) output axim_ctrl_0_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.LCKRESETN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.LCKRESETN, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) output lckresetn;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.NCLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.NCLK, ASSOCIATED_RESET nresetn, CLK_DOMAIN /clk_wiz_0_clk_out1, FREQ_HZ 250000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) output nclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.NRESETN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.NRESETN, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) output [0:0]nresetn;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.SYS_RESET RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.SYS_RESET, INSERT_VIP 0, POLARITY ACTIVE_HIGH" *) input sys_reset;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.UCLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.UCLK, ASSOCIATED_RESET uresetn, CLK_DOMAIN /clk_wiz_0_clk_out1, FREQ_HZ 250000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) output uclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.URESETN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.URESETN, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) output [0:0]uresetn;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.XCLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.XCLK, ASSOCIATED_BUSIF axi_main, ASSOCIATED_RESET xresetn, CLK_DOMAIN design_ctrl_xclk, FREQ_HZ 250000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input xclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.XRESETN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.XRESETN, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input xresetn;

  wire [63:0]axi_interconnect_0_M00_AXI_ARADDR;
  wire [2:0]axi_interconnect_0_M00_AXI_ARPROT;
  wire axi_interconnect_0_M00_AXI_ARREADY;
  wire axi_interconnect_0_M00_AXI_ARVALID;
  wire [63:0]axi_interconnect_0_M00_AXI_AWADDR;
  wire [2:0]axi_interconnect_0_M00_AXI_AWPROT;
  wire axi_interconnect_0_M00_AXI_AWREADY;
  wire axi_interconnect_0_M00_AXI_AWVALID;
  wire axi_interconnect_0_M00_AXI_BREADY;
  wire [1:0]axi_interconnect_0_M00_AXI_BRESP;
  wire axi_interconnect_0_M00_AXI_BVALID;
  wire [63:0]axi_interconnect_0_M00_AXI_RDATA;
  wire axi_interconnect_0_M00_AXI_RREADY;
  wire [1:0]axi_interconnect_0_M00_AXI_RRESP;
  wire axi_interconnect_0_M00_AXI_RVALID;
  wire [63:0]axi_interconnect_0_M00_AXI_WDATA;
  wire axi_interconnect_0_M00_AXI_WREADY;
  wire [7:0]axi_interconnect_0_M00_AXI_WSTRB;
  wire axi_interconnect_0_M00_AXI_WVALID;
  wire [63:0]axi_interconnect_0_M01_AXI_ARADDR;
  wire [2:0]axi_interconnect_0_M01_AXI_ARPROT;
  wire axi_interconnect_0_M01_AXI_ARREADY;
  wire axi_interconnect_0_M01_AXI_ARVALID;
  wire [63:0]axi_interconnect_0_M01_AXI_AWADDR;
  wire [2:0]axi_interconnect_0_M01_AXI_AWPROT;
  wire axi_interconnect_0_M01_AXI_AWREADY;
  wire axi_interconnect_0_M01_AXI_AWVALID;
  wire axi_interconnect_0_M01_AXI_BREADY;
  wire [1:0]axi_interconnect_0_M01_AXI_BRESP;
  wire axi_interconnect_0_M01_AXI_BVALID;
  wire [63:0]axi_interconnect_0_M01_AXI_RDATA;
  wire axi_interconnect_0_M01_AXI_RREADY;
  wire [1:0]axi_interconnect_0_M01_AXI_RRESP;
  wire axi_interconnect_0_M01_AXI_RVALID;
  wire [63:0]axi_interconnect_0_M01_AXI_WDATA;
  wire axi_interconnect_0_M01_AXI_WREADY;
  wire [7:0]axi_interconnect_0_M01_AXI_WSTRB;
  wire axi_interconnect_0_M01_AXI_WVALID;
  wire [63:0]axi_interconnect_0_M02_AXI_ARADDR;
  wire [1:0]axi_interconnect_0_M02_AXI_ARBURST;
  wire [3:0]axi_interconnect_0_M02_AXI_ARCACHE;
  wire [7:0]axi_interconnect_0_M02_AXI_ARLEN;
  wire [0:0]axi_interconnect_0_M02_AXI_ARLOCK;
  wire [2:0]axi_interconnect_0_M02_AXI_ARPROT;
  wire [3:0]axi_interconnect_0_M02_AXI_ARQOS;
  wire axi_interconnect_0_M02_AXI_ARREADY;
  wire [3:0]axi_interconnect_0_M02_AXI_ARREGION;
  wire [2:0]axi_interconnect_0_M02_AXI_ARSIZE;
  wire axi_interconnect_0_M02_AXI_ARVALID;
  wire [63:0]axi_interconnect_0_M02_AXI_AWADDR;
  wire [1:0]axi_interconnect_0_M02_AXI_AWBURST;
  wire [3:0]axi_interconnect_0_M02_AXI_AWCACHE;
  wire [7:0]axi_interconnect_0_M02_AXI_AWLEN;
  wire [0:0]axi_interconnect_0_M02_AXI_AWLOCK;
  wire [2:0]axi_interconnect_0_M02_AXI_AWPROT;
  wire [3:0]axi_interconnect_0_M02_AXI_AWQOS;
  wire axi_interconnect_0_M02_AXI_AWREADY;
  wire [3:0]axi_interconnect_0_M02_AXI_AWREGION;
  wire [2:0]axi_interconnect_0_M02_AXI_AWSIZE;
  wire axi_interconnect_0_M02_AXI_AWVALID;
  wire axi_interconnect_0_M02_AXI_BREADY;
  wire [1:0]axi_interconnect_0_M02_AXI_BRESP;
  wire axi_interconnect_0_M02_AXI_BVALID;
  wire [255:0]axi_interconnect_0_M02_AXI_RDATA;
  wire axi_interconnect_0_M02_AXI_RLAST;
  wire axi_interconnect_0_M02_AXI_RREADY;
  wire [1:0]axi_interconnect_0_M02_AXI_RRESP;
  wire axi_interconnect_0_M02_AXI_RVALID;
  wire [255:0]axi_interconnect_0_M02_AXI_WDATA;
  wire axi_interconnect_0_M02_AXI_WLAST;
  wire axi_interconnect_0_M02_AXI_WREADY;
  wire [31:0]axi_interconnect_0_M02_AXI_WSTRB;
  wire axi_interconnect_0_M02_AXI_WVALID;
  wire [63:0]axi_interconnect_0_S00_AXI_ARADDR;
  wire [1:0]axi_interconnect_0_S00_AXI_ARBURST;
  wire [3:0]axi_interconnect_0_S00_AXI_ARCACHE;
  wire [5:0]axi_interconnect_0_S00_AXI_ARID;
  wire [7:0]axi_interconnect_0_S00_AXI_ARLEN;
  wire [0:0]axi_interconnect_0_S00_AXI_ARLOCK;
  wire [2:0]axi_interconnect_0_S00_AXI_ARPROT;
  wire [3:0]axi_interconnect_0_S00_AXI_ARQOS;
  wire axi_interconnect_0_S00_AXI_ARREADY;
  wire [3:0]axi_interconnect_0_S00_AXI_ARREGION;
  wire [2:0]axi_interconnect_0_S00_AXI_ARSIZE;
  wire axi_interconnect_0_S00_AXI_ARVALID;
  wire [63:0]axi_interconnect_0_S00_AXI_AWADDR;
  wire [1:0]axi_interconnect_0_S00_AXI_AWBURST;
  wire [3:0]axi_interconnect_0_S00_AXI_AWCACHE;
  wire [5:0]axi_interconnect_0_S00_AXI_AWID;
  wire [7:0]axi_interconnect_0_S00_AXI_AWLEN;
  wire [0:0]axi_interconnect_0_S00_AXI_AWLOCK;
  wire [2:0]axi_interconnect_0_S00_AXI_AWPROT;
  wire [3:0]axi_interconnect_0_S00_AXI_AWQOS;
  wire axi_interconnect_0_S00_AXI_AWREADY;
  wire [3:0]axi_interconnect_0_S00_AXI_AWREGION;
  wire [2:0]axi_interconnect_0_S00_AXI_AWSIZE;
  wire axi_interconnect_0_S00_AXI_AWVALID;
  wire [5:0]axi_interconnect_0_S00_AXI_BID;
  wire axi_interconnect_0_S00_AXI_BREADY;
  wire [1:0]axi_interconnect_0_S00_AXI_BRESP;
  wire axi_interconnect_0_S00_AXI_BVALID;
  wire [511:0]axi_interconnect_0_S00_AXI_RDATA;
  wire [5:0]axi_interconnect_0_S00_AXI_RID;
  wire axi_interconnect_0_S00_AXI_RLAST;
  wire axi_interconnect_0_S00_AXI_RREADY;
  wire [1:0]axi_interconnect_0_S00_AXI_RRESP;
  wire axi_interconnect_0_S00_AXI_RVALID;
  wire [511:0]axi_interconnect_0_S00_AXI_WDATA;
  wire axi_interconnect_0_S00_AXI_WLAST;
  wire axi_interconnect_0_S00_AXI_WREADY;
  wire [63:0]axi_interconnect_0_S00_AXI_WSTRB;
  wire axi_interconnect_0_S00_AXI_WVALID;
  wire clk_wiz_0_clk_out1;
  wire clk_wiz_0_clk_out2;
  wire clk_wiz_0_clk_out3;
  wire clk_wiz_0_locked;
  wire [0:0]proc_sys_reset_a_interconnect_aresetn;
  wire [0:0]proc_sys_reset_a_peripheral_aresetn;
  wire [0:0]proc_sys_reset_n_peripheral_aresetn;
  wire [0:0]proc_sys_reset_u_peripheral_aresetn;
  wire sys_reset_1;
  wire xclk_1;
  wire xresetn_1;

  assign aclk = clk_wiz_0_clk_out1;
  assign aresetn[0] = proc_sys_reset_a_peripheral_aresetn;
  assign axi_cnfg_araddr[63:0] = axi_interconnect_0_M00_AXI_ARADDR;
  assign axi_cnfg_arprot[2:0] = axi_interconnect_0_M00_AXI_ARPROT;
  assign axi_cnfg_arvalid = axi_interconnect_0_M00_AXI_ARVALID;
  assign axi_cnfg_awaddr[63:0] = axi_interconnect_0_M00_AXI_AWADDR;
  assign axi_cnfg_awprot[2:0] = axi_interconnect_0_M00_AXI_AWPROT;
  assign axi_cnfg_awvalid = axi_interconnect_0_M00_AXI_AWVALID;
  assign axi_cnfg_bready = axi_interconnect_0_M00_AXI_BREADY;
  assign axi_cnfg_rready = axi_interconnect_0_M00_AXI_RREADY;
  assign axi_cnfg_wdata[63:0] = axi_interconnect_0_M00_AXI_WDATA;
  assign axi_cnfg_wstrb[7:0] = axi_interconnect_0_M00_AXI_WSTRB;
  assign axi_cnfg_wvalid = axi_interconnect_0_M00_AXI_WVALID;
  assign axi_ctrl_0_araddr[63:0] = axi_interconnect_0_M01_AXI_ARADDR;
  assign axi_ctrl_0_arprot[2:0] = axi_interconnect_0_M01_AXI_ARPROT;
  assign axi_ctrl_0_arvalid = axi_interconnect_0_M01_AXI_ARVALID;
  assign axi_ctrl_0_awaddr[63:0] = axi_interconnect_0_M01_AXI_AWADDR;
  assign axi_ctrl_0_awprot[2:0] = axi_interconnect_0_M01_AXI_AWPROT;
  assign axi_ctrl_0_awvalid = axi_interconnect_0_M01_AXI_AWVALID;
  assign axi_ctrl_0_bready = axi_interconnect_0_M01_AXI_BREADY;
  assign axi_ctrl_0_rready = axi_interconnect_0_M01_AXI_RREADY;
  assign axi_ctrl_0_wdata[63:0] = axi_interconnect_0_M01_AXI_WDATA;
  assign axi_ctrl_0_wstrb[7:0] = axi_interconnect_0_M01_AXI_WSTRB;
  assign axi_ctrl_0_wvalid = axi_interconnect_0_M01_AXI_WVALID;
  assign axi_interconnect_0_M00_AXI_ARREADY = axi_cnfg_arready;
  assign axi_interconnect_0_M00_AXI_AWREADY = axi_cnfg_awready;
  assign axi_interconnect_0_M00_AXI_BRESP = axi_cnfg_bresp[1:0];
  assign axi_interconnect_0_M00_AXI_BVALID = axi_cnfg_bvalid;
  assign axi_interconnect_0_M00_AXI_RDATA = axi_cnfg_rdata[63:0];
  assign axi_interconnect_0_M00_AXI_RRESP = axi_cnfg_rresp[1:0];
  assign axi_interconnect_0_M00_AXI_RVALID = axi_cnfg_rvalid;
  assign axi_interconnect_0_M00_AXI_WREADY = axi_cnfg_wready;
  assign axi_interconnect_0_M01_AXI_ARREADY = axi_ctrl_0_arready;
  assign axi_interconnect_0_M01_AXI_AWREADY = axi_ctrl_0_awready;
  assign axi_interconnect_0_M01_AXI_BRESP = axi_ctrl_0_bresp[1:0];
  assign axi_interconnect_0_M01_AXI_BVALID = axi_ctrl_0_bvalid;
  assign axi_interconnect_0_M01_AXI_RDATA = axi_ctrl_0_rdata[63:0];
  assign axi_interconnect_0_M01_AXI_RRESP = axi_ctrl_0_rresp[1:0];
  assign axi_interconnect_0_M01_AXI_RVALID = axi_ctrl_0_rvalid;
  assign axi_interconnect_0_M01_AXI_WREADY = axi_ctrl_0_wready;
  assign axi_interconnect_0_M02_AXI_ARREADY = axim_ctrl_0_arready;
  assign axi_interconnect_0_M02_AXI_AWREADY = axim_ctrl_0_awready;
  assign axi_interconnect_0_M02_AXI_BRESP = axim_ctrl_0_bresp[1:0];
  assign axi_interconnect_0_M02_AXI_BVALID = axim_ctrl_0_bvalid;
  assign axi_interconnect_0_M02_AXI_RDATA = axim_ctrl_0_rdata[255:0];
  assign axi_interconnect_0_M02_AXI_RLAST = axim_ctrl_0_rlast;
  assign axi_interconnect_0_M02_AXI_RRESP = axim_ctrl_0_rresp[1:0];
  assign axi_interconnect_0_M02_AXI_RVALID = axim_ctrl_0_rvalid;
  assign axi_interconnect_0_M02_AXI_WREADY = axim_ctrl_0_wready;
  assign axi_interconnect_0_S00_AXI_ARADDR = axi_main_araddr[63:0];
  assign axi_interconnect_0_S00_AXI_ARBURST = axi_main_arburst[1:0];
  assign axi_interconnect_0_S00_AXI_ARCACHE = axi_main_arcache[3:0];
  assign axi_interconnect_0_S00_AXI_ARID = axi_main_arid[5:0];
  assign axi_interconnect_0_S00_AXI_ARLEN = axi_main_arlen[7:0];
  assign axi_interconnect_0_S00_AXI_ARLOCK = axi_main_arlock[0];
  assign axi_interconnect_0_S00_AXI_ARPROT = axi_main_arprot[2:0];
  assign axi_interconnect_0_S00_AXI_ARQOS = axi_main_arqos[3:0];
  assign axi_interconnect_0_S00_AXI_ARREGION = axi_main_arregion[3:0];
  assign axi_interconnect_0_S00_AXI_ARSIZE = axi_main_arsize[2:0];
  assign axi_interconnect_0_S00_AXI_ARVALID = axi_main_arvalid;
  assign axi_interconnect_0_S00_AXI_AWADDR = axi_main_awaddr[63:0];
  assign axi_interconnect_0_S00_AXI_AWBURST = axi_main_awburst[1:0];
  assign axi_interconnect_0_S00_AXI_AWCACHE = axi_main_awcache[3:0];
  assign axi_interconnect_0_S00_AXI_AWID = axi_main_awid[5:0];
  assign axi_interconnect_0_S00_AXI_AWLEN = axi_main_awlen[7:0];
  assign axi_interconnect_0_S00_AXI_AWLOCK = axi_main_awlock[0];
  assign axi_interconnect_0_S00_AXI_AWPROT = axi_main_awprot[2:0];
  assign axi_interconnect_0_S00_AXI_AWQOS = axi_main_awqos[3:0];
  assign axi_interconnect_0_S00_AXI_AWREGION = axi_main_awregion[3:0];
  assign axi_interconnect_0_S00_AXI_AWSIZE = axi_main_awsize[2:0];
  assign axi_interconnect_0_S00_AXI_AWVALID = axi_main_awvalid;
  assign axi_interconnect_0_S00_AXI_BREADY = axi_main_bready;
  assign axi_interconnect_0_S00_AXI_RREADY = axi_main_rready;
  assign axi_interconnect_0_S00_AXI_WDATA = axi_main_wdata[511:0];
  assign axi_interconnect_0_S00_AXI_WLAST = axi_main_wlast;
  assign axi_interconnect_0_S00_AXI_WSTRB = axi_main_wstrb[63:0];
  assign axi_interconnect_0_S00_AXI_WVALID = axi_main_wvalid;
  assign axi_main_arready = axi_interconnect_0_S00_AXI_ARREADY;
  assign axi_main_awready = axi_interconnect_0_S00_AXI_AWREADY;
  assign axi_main_bid[5:0] = axi_interconnect_0_S00_AXI_BID;
  assign axi_main_bresp[1:0] = axi_interconnect_0_S00_AXI_BRESP;
  assign axi_main_bvalid = axi_interconnect_0_S00_AXI_BVALID;
  assign axi_main_rdata[511:0] = axi_interconnect_0_S00_AXI_RDATA;
  assign axi_main_rid[5:0] = axi_interconnect_0_S00_AXI_RID;
  assign axi_main_rlast = axi_interconnect_0_S00_AXI_RLAST;
  assign axi_main_rresp[1:0] = axi_interconnect_0_S00_AXI_RRESP;
  assign axi_main_rvalid = axi_interconnect_0_S00_AXI_RVALID;
  assign axi_main_wready = axi_interconnect_0_S00_AXI_WREADY;
  assign axim_ctrl_0_araddr[63:0] = axi_interconnect_0_M02_AXI_ARADDR;
  assign axim_ctrl_0_arburst[1:0] = axi_interconnect_0_M02_AXI_ARBURST;
  assign axim_ctrl_0_arcache[3:0] = axi_interconnect_0_M02_AXI_ARCACHE;
  assign axim_ctrl_0_arlen[7:0] = axi_interconnect_0_M02_AXI_ARLEN;
  assign axim_ctrl_0_arlock[0] = axi_interconnect_0_M02_AXI_ARLOCK;
  assign axim_ctrl_0_arprot[2:0] = axi_interconnect_0_M02_AXI_ARPROT;
  assign axim_ctrl_0_arqos[3:0] = axi_interconnect_0_M02_AXI_ARQOS;
  assign axim_ctrl_0_arregion[3:0] = axi_interconnect_0_M02_AXI_ARREGION;
  assign axim_ctrl_0_arsize[2:0] = axi_interconnect_0_M02_AXI_ARSIZE;
  assign axim_ctrl_0_arvalid = axi_interconnect_0_M02_AXI_ARVALID;
  assign axim_ctrl_0_awaddr[63:0] = axi_interconnect_0_M02_AXI_AWADDR;
  assign axim_ctrl_0_awburst[1:0] = axi_interconnect_0_M02_AXI_AWBURST;
  assign axim_ctrl_0_awcache[3:0] = axi_interconnect_0_M02_AXI_AWCACHE;
  assign axim_ctrl_0_awlen[7:0] = axi_interconnect_0_M02_AXI_AWLEN;
  assign axim_ctrl_0_awlock[0] = axi_interconnect_0_M02_AXI_AWLOCK;
  assign axim_ctrl_0_awprot[2:0] = axi_interconnect_0_M02_AXI_AWPROT;
  assign axim_ctrl_0_awqos[3:0] = axi_interconnect_0_M02_AXI_AWQOS;
  assign axim_ctrl_0_awregion[3:0] = axi_interconnect_0_M02_AXI_AWREGION;
  assign axim_ctrl_0_awsize[2:0] = axi_interconnect_0_M02_AXI_AWSIZE;
  assign axim_ctrl_0_awvalid = axi_interconnect_0_M02_AXI_AWVALID;
  assign axim_ctrl_0_bready = axi_interconnect_0_M02_AXI_BREADY;
  assign axim_ctrl_0_rready = axi_interconnect_0_M02_AXI_RREADY;
  assign axim_ctrl_0_wdata[255:0] = axi_interconnect_0_M02_AXI_WDATA;
  assign axim_ctrl_0_wlast = axi_interconnect_0_M02_AXI_WLAST;
  assign axim_ctrl_0_wstrb[31:0] = axi_interconnect_0_M02_AXI_WSTRB;
  assign axim_ctrl_0_wvalid = axi_interconnect_0_M02_AXI_WVALID;
  assign lckresetn = clk_wiz_0_locked;
  assign nclk = clk_wiz_0_clk_out2;
  assign nresetn[0] = proc_sys_reset_n_peripheral_aresetn;
  assign sys_reset_1 = sys_reset;
  assign uclk = clk_wiz_0_clk_out3;
  assign uresetn[0] = proc_sys_reset_u_peripheral_aresetn;
  assign xclk_1 = xclk;
  assign xresetn_1 = xresetn;
  design_ctrl_axi_interconnect_0_0 axi_interconnect_0
       (.ACLK(xclk_1),
        .ARESETN(xresetn_1),
        .M00_ACLK(clk_wiz_0_clk_out1),
        .M00_ARESETN(proc_sys_reset_a_interconnect_aresetn),
        .M00_AXI_araddr(axi_interconnect_0_M00_AXI_ARADDR),
        .M00_AXI_arprot(axi_interconnect_0_M00_AXI_ARPROT),
        .M00_AXI_arready(axi_interconnect_0_M00_AXI_ARREADY),
        .M00_AXI_arvalid(axi_interconnect_0_M00_AXI_ARVALID),
        .M00_AXI_awaddr(axi_interconnect_0_M00_AXI_AWADDR),
        .M00_AXI_awprot(axi_interconnect_0_M00_AXI_AWPROT),
        .M00_AXI_awready(axi_interconnect_0_M00_AXI_AWREADY),
        .M00_AXI_awvalid(axi_interconnect_0_M00_AXI_AWVALID),
        .M00_AXI_bready(axi_interconnect_0_M00_AXI_BREADY),
        .M00_AXI_bresp(axi_interconnect_0_M00_AXI_BRESP),
        .M00_AXI_bvalid(axi_interconnect_0_M00_AXI_BVALID),
        .M00_AXI_rdata(axi_interconnect_0_M00_AXI_RDATA),
        .M00_AXI_rready(axi_interconnect_0_M00_AXI_RREADY),
        .M00_AXI_rresp(axi_interconnect_0_M00_AXI_RRESP),
        .M00_AXI_rvalid(axi_interconnect_0_M00_AXI_RVALID),
        .M00_AXI_wdata(axi_interconnect_0_M00_AXI_WDATA),
        .M00_AXI_wready(axi_interconnect_0_M00_AXI_WREADY),
        .M00_AXI_wstrb(axi_interconnect_0_M00_AXI_WSTRB),
        .M00_AXI_wvalid(axi_interconnect_0_M00_AXI_WVALID),
        .M01_ACLK(clk_wiz_0_clk_out1),
        .M01_ARESETN(proc_sys_reset_a_interconnect_aresetn),
        .M01_AXI_araddr(axi_interconnect_0_M01_AXI_ARADDR),
        .M01_AXI_arprot(axi_interconnect_0_M01_AXI_ARPROT),
        .M01_AXI_arready(axi_interconnect_0_M01_AXI_ARREADY),
        .M01_AXI_arvalid(axi_interconnect_0_M01_AXI_ARVALID),
        .M01_AXI_awaddr(axi_interconnect_0_M01_AXI_AWADDR),
        .M01_AXI_awprot(axi_interconnect_0_M01_AXI_AWPROT),
        .M01_AXI_awready(axi_interconnect_0_M01_AXI_AWREADY),
        .M01_AXI_awvalid(axi_interconnect_0_M01_AXI_AWVALID),
        .M01_AXI_bready(axi_interconnect_0_M01_AXI_BREADY),
        .M01_AXI_bresp(axi_interconnect_0_M01_AXI_BRESP),
        .M01_AXI_bvalid(axi_interconnect_0_M01_AXI_BVALID),
        .M01_AXI_rdata(axi_interconnect_0_M01_AXI_RDATA),
        .M01_AXI_rready(axi_interconnect_0_M01_AXI_RREADY),
        .M01_AXI_rresp(axi_interconnect_0_M01_AXI_RRESP),
        .M01_AXI_rvalid(axi_interconnect_0_M01_AXI_RVALID),
        .M01_AXI_wdata(axi_interconnect_0_M01_AXI_WDATA),
        .M01_AXI_wready(axi_interconnect_0_M01_AXI_WREADY),
        .M01_AXI_wstrb(axi_interconnect_0_M01_AXI_WSTRB),
        .M01_AXI_wvalid(axi_interconnect_0_M01_AXI_WVALID),
        .M02_ACLK(clk_wiz_0_clk_out1),
        .M02_ARESETN(proc_sys_reset_a_interconnect_aresetn),
        .M02_AXI_araddr(axi_interconnect_0_M02_AXI_ARADDR),
        .M02_AXI_arburst(axi_interconnect_0_M02_AXI_ARBURST),
        .M02_AXI_arcache(axi_interconnect_0_M02_AXI_ARCACHE),
        .M02_AXI_arlen(axi_interconnect_0_M02_AXI_ARLEN),
        .M02_AXI_arlock(axi_interconnect_0_M02_AXI_ARLOCK),
        .M02_AXI_arprot(axi_interconnect_0_M02_AXI_ARPROT),
        .M02_AXI_arqos(axi_interconnect_0_M02_AXI_ARQOS),
        .M02_AXI_arready(axi_interconnect_0_M02_AXI_ARREADY),
        .M02_AXI_arregion(axi_interconnect_0_M02_AXI_ARREGION),
        .M02_AXI_arsize(axi_interconnect_0_M02_AXI_ARSIZE),
        .M02_AXI_arvalid(axi_interconnect_0_M02_AXI_ARVALID),
        .M02_AXI_awaddr(axi_interconnect_0_M02_AXI_AWADDR),
        .M02_AXI_awburst(axi_interconnect_0_M02_AXI_AWBURST),
        .M02_AXI_awcache(axi_interconnect_0_M02_AXI_AWCACHE),
        .M02_AXI_awlen(axi_interconnect_0_M02_AXI_AWLEN),
        .M02_AXI_awlock(axi_interconnect_0_M02_AXI_AWLOCK),
        .M02_AXI_awprot(axi_interconnect_0_M02_AXI_AWPROT),
        .M02_AXI_awqos(axi_interconnect_0_M02_AXI_AWQOS),
        .M02_AXI_awready(axi_interconnect_0_M02_AXI_AWREADY),
        .M02_AXI_awregion(axi_interconnect_0_M02_AXI_AWREGION),
        .M02_AXI_awsize(axi_interconnect_0_M02_AXI_AWSIZE),
        .M02_AXI_awvalid(axi_interconnect_0_M02_AXI_AWVALID),
        .M02_AXI_bready(axi_interconnect_0_M02_AXI_BREADY),
        .M02_AXI_bresp(axi_interconnect_0_M02_AXI_BRESP),
        .M02_AXI_bvalid(axi_interconnect_0_M02_AXI_BVALID),
        .M02_AXI_rdata(axi_interconnect_0_M02_AXI_RDATA),
        .M02_AXI_rlast(axi_interconnect_0_M02_AXI_RLAST),
        .M02_AXI_rready(axi_interconnect_0_M02_AXI_RREADY),
        .M02_AXI_rresp(axi_interconnect_0_M02_AXI_RRESP),
        .M02_AXI_rvalid(axi_interconnect_0_M02_AXI_RVALID),
        .M02_AXI_wdata(axi_interconnect_0_M02_AXI_WDATA),
        .M02_AXI_wlast(axi_interconnect_0_M02_AXI_WLAST),
        .M02_AXI_wready(axi_interconnect_0_M02_AXI_WREADY),
        .M02_AXI_wstrb(axi_interconnect_0_M02_AXI_WSTRB),
        .M02_AXI_wvalid(axi_interconnect_0_M02_AXI_WVALID),
        .S00_ACLK(xclk_1),
        .S00_ARESETN(xresetn_1),
        .S00_AXI_araddr(axi_interconnect_0_S00_AXI_ARADDR),
        .S00_AXI_arburst(axi_interconnect_0_S00_AXI_ARBURST),
        .S00_AXI_arcache(axi_interconnect_0_S00_AXI_ARCACHE),
        .S00_AXI_arid(axi_interconnect_0_S00_AXI_ARID),
        .S00_AXI_arlen(axi_interconnect_0_S00_AXI_ARLEN),
        .S00_AXI_arlock(axi_interconnect_0_S00_AXI_ARLOCK),
        .S00_AXI_arprot(axi_interconnect_0_S00_AXI_ARPROT),
        .S00_AXI_arqos(axi_interconnect_0_S00_AXI_ARQOS),
        .S00_AXI_arready(axi_interconnect_0_S00_AXI_ARREADY),
        .S00_AXI_arregion(axi_interconnect_0_S00_AXI_ARREGION),
        .S00_AXI_arsize(axi_interconnect_0_S00_AXI_ARSIZE),
        .S00_AXI_arvalid(axi_interconnect_0_S00_AXI_ARVALID),
        .S00_AXI_awaddr(axi_interconnect_0_S00_AXI_AWADDR),
        .S00_AXI_awburst(axi_interconnect_0_S00_AXI_AWBURST),
        .S00_AXI_awcache(axi_interconnect_0_S00_AXI_AWCACHE),
        .S00_AXI_awid(axi_interconnect_0_S00_AXI_AWID),
        .S00_AXI_awlen(axi_interconnect_0_S00_AXI_AWLEN),
        .S00_AXI_awlock(axi_interconnect_0_S00_AXI_AWLOCK),
        .S00_AXI_awprot(axi_interconnect_0_S00_AXI_AWPROT),
        .S00_AXI_awqos(axi_interconnect_0_S00_AXI_AWQOS),
        .S00_AXI_awready(axi_interconnect_0_S00_AXI_AWREADY),
        .S00_AXI_awregion(axi_interconnect_0_S00_AXI_AWREGION),
        .S00_AXI_awsize(axi_interconnect_0_S00_AXI_AWSIZE),
        .S00_AXI_awvalid(axi_interconnect_0_S00_AXI_AWVALID),
        .S00_AXI_bid(axi_interconnect_0_S00_AXI_BID),
        .S00_AXI_bready(axi_interconnect_0_S00_AXI_BREADY),
        .S00_AXI_bresp(axi_interconnect_0_S00_AXI_BRESP),
        .S00_AXI_bvalid(axi_interconnect_0_S00_AXI_BVALID),
        .S00_AXI_rdata(axi_interconnect_0_S00_AXI_RDATA),
        .S00_AXI_rid(axi_interconnect_0_S00_AXI_RID),
        .S00_AXI_rlast(axi_interconnect_0_S00_AXI_RLAST),
        .S00_AXI_rready(axi_interconnect_0_S00_AXI_RREADY),
        .S00_AXI_rresp(axi_interconnect_0_S00_AXI_RRESP),
        .S00_AXI_rvalid(axi_interconnect_0_S00_AXI_RVALID),
        .S00_AXI_wdata(axi_interconnect_0_S00_AXI_WDATA),
        .S00_AXI_wlast(axi_interconnect_0_S00_AXI_WLAST),
        .S00_AXI_wready(axi_interconnect_0_S00_AXI_WREADY),
        .S00_AXI_wstrb(axi_interconnect_0_S00_AXI_WSTRB),
        .S00_AXI_wvalid(axi_interconnect_0_S00_AXI_WVALID));
  design_ctrl_clk_wiz_0_0 clk_wiz_0
       (.clk_in1(xclk_1),
        .clk_out1(clk_wiz_0_clk_out1),
        .clk_out2(clk_wiz_0_clk_out2),
        .clk_out3(clk_wiz_0_clk_out3),
        .locked(clk_wiz_0_locked),
        .reset(sys_reset_1));
  design_ctrl_proc_sys_reset_a_0 proc_sys_reset_a
       (.aux_reset_in(1'b1),
        .dcm_locked(1'b1),
        .ext_reset_in(xresetn_1),
        .interconnect_aresetn(proc_sys_reset_a_interconnect_aresetn),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(proc_sys_reset_a_peripheral_aresetn),
        .slowest_sync_clk(clk_wiz_0_clk_out1));
  design_ctrl_proc_sys_reset_n_0 proc_sys_reset_n
       (.aux_reset_in(1'b1),
        .dcm_locked(1'b1),
        .ext_reset_in(xresetn_1),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(proc_sys_reset_n_peripheral_aresetn),
        .slowest_sync_clk(clk_wiz_0_clk_out2));
  design_ctrl_proc_sys_reset_u_0 proc_sys_reset_u
       (.aux_reset_in(1'b1),
        .dcm_locked(1'b1),
        .ext_reset_in(xresetn_1),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(proc_sys_reset_u_peripheral_aresetn),
        .slowest_sync_clk(clk_wiz_0_clk_out3));
endmodule

module design_ctrl_axi_interconnect_0_0
   (ACLK,
    ARESETN,
    M00_ACLK,
    M00_ARESETN,
    M00_AXI_araddr,
    M00_AXI_arprot,
    M00_AXI_arready,
    M00_AXI_arvalid,
    M00_AXI_awaddr,
    M00_AXI_awprot,
    M00_AXI_awready,
    M00_AXI_awvalid,
    M00_AXI_bready,
    M00_AXI_bresp,
    M00_AXI_bvalid,
    M00_AXI_rdata,
    M00_AXI_rready,
    M00_AXI_rresp,
    M00_AXI_rvalid,
    M00_AXI_wdata,
    M00_AXI_wready,
    M00_AXI_wstrb,
    M00_AXI_wvalid,
    M01_ACLK,
    M01_ARESETN,
    M01_AXI_araddr,
    M01_AXI_arprot,
    M01_AXI_arready,
    M01_AXI_arvalid,
    M01_AXI_awaddr,
    M01_AXI_awprot,
    M01_AXI_awready,
    M01_AXI_awvalid,
    M01_AXI_bready,
    M01_AXI_bresp,
    M01_AXI_bvalid,
    M01_AXI_rdata,
    M01_AXI_rready,
    M01_AXI_rresp,
    M01_AXI_rvalid,
    M01_AXI_wdata,
    M01_AXI_wready,
    M01_AXI_wstrb,
    M01_AXI_wvalid,
    M02_ACLK,
    M02_ARESETN,
    M02_AXI_araddr,
    M02_AXI_arburst,
    M02_AXI_arcache,
    M02_AXI_arlen,
    M02_AXI_arlock,
    M02_AXI_arprot,
    M02_AXI_arqos,
    M02_AXI_arready,
    M02_AXI_arregion,
    M02_AXI_arsize,
    M02_AXI_arvalid,
    M02_AXI_awaddr,
    M02_AXI_awburst,
    M02_AXI_awcache,
    M02_AXI_awlen,
    M02_AXI_awlock,
    M02_AXI_awprot,
    M02_AXI_awqos,
    M02_AXI_awready,
    M02_AXI_awregion,
    M02_AXI_awsize,
    M02_AXI_awvalid,
    M02_AXI_bready,
    M02_AXI_bresp,
    M02_AXI_bvalid,
    M02_AXI_rdata,
    M02_AXI_rlast,
    M02_AXI_rready,
    M02_AXI_rresp,
    M02_AXI_rvalid,
    M02_AXI_wdata,
    M02_AXI_wlast,
    M02_AXI_wready,
    M02_AXI_wstrb,
    M02_AXI_wvalid,
    S00_ACLK,
    S00_ARESETN,
    S00_AXI_araddr,
    S00_AXI_arburst,
    S00_AXI_arcache,
    S00_AXI_arid,
    S00_AXI_arlen,
    S00_AXI_arlock,
    S00_AXI_arprot,
    S00_AXI_arqos,
    S00_AXI_arready,
    S00_AXI_arregion,
    S00_AXI_arsize,
    S00_AXI_arvalid,
    S00_AXI_awaddr,
    S00_AXI_awburst,
    S00_AXI_awcache,
    S00_AXI_awid,
    S00_AXI_awlen,
    S00_AXI_awlock,
    S00_AXI_awprot,
    S00_AXI_awqos,
    S00_AXI_awready,
    S00_AXI_awregion,
    S00_AXI_awsize,
    S00_AXI_awvalid,
    S00_AXI_bid,
    S00_AXI_bready,
    S00_AXI_bresp,
    S00_AXI_bvalid,
    S00_AXI_rdata,
    S00_AXI_rid,
    S00_AXI_rlast,
    S00_AXI_rready,
    S00_AXI_rresp,
    S00_AXI_rvalid,
    S00_AXI_wdata,
    S00_AXI_wlast,
    S00_AXI_wready,
    S00_AXI_wstrb,
    S00_AXI_wvalid);
  input ACLK;
  input ARESETN;
  input M00_ACLK;
  input M00_ARESETN;
  output [63:0]M00_AXI_araddr;
  output [2:0]M00_AXI_arprot;
  input M00_AXI_arready;
  output M00_AXI_arvalid;
  output [63:0]M00_AXI_awaddr;
  output [2:0]M00_AXI_awprot;
  input M00_AXI_awready;
  output M00_AXI_awvalid;
  output M00_AXI_bready;
  input [1:0]M00_AXI_bresp;
  input M00_AXI_bvalid;
  input [63:0]M00_AXI_rdata;
  output M00_AXI_rready;
  input [1:0]M00_AXI_rresp;
  input M00_AXI_rvalid;
  output [63:0]M00_AXI_wdata;
  input M00_AXI_wready;
  output [7:0]M00_AXI_wstrb;
  output M00_AXI_wvalid;
  input M01_ACLK;
  input M01_ARESETN;
  output [63:0]M01_AXI_araddr;
  output [2:0]M01_AXI_arprot;
  input M01_AXI_arready;
  output M01_AXI_arvalid;
  output [63:0]M01_AXI_awaddr;
  output [2:0]M01_AXI_awprot;
  input M01_AXI_awready;
  output M01_AXI_awvalid;
  output M01_AXI_bready;
  input [1:0]M01_AXI_bresp;
  input M01_AXI_bvalid;
  input [63:0]M01_AXI_rdata;
  output M01_AXI_rready;
  input [1:0]M01_AXI_rresp;
  input M01_AXI_rvalid;
  output [63:0]M01_AXI_wdata;
  input M01_AXI_wready;
  output [7:0]M01_AXI_wstrb;
  output M01_AXI_wvalid;
  input M02_ACLK;
  input M02_ARESETN;
  output [63:0]M02_AXI_araddr;
  output [1:0]M02_AXI_arburst;
  output [3:0]M02_AXI_arcache;
  output [7:0]M02_AXI_arlen;
  output [0:0]M02_AXI_arlock;
  output [2:0]M02_AXI_arprot;
  output [3:0]M02_AXI_arqos;
  input M02_AXI_arready;
  output [3:0]M02_AXI_arregion;
  output [2:0]M02_AXI_arsize;
  output M02_AXI_arvalid;
  output [63:0]M02_AXI_awaddr;
  output [1:0]M02_AXI_awburst;
  output [3:0]M02_AXI_awcache;
  output [7:0]M02_AXI_awlen;
  output [0:0]M02_AXI_awlock;
  output [2:0]M02_AXI_awprot;
  output [3:0]M02_AXI_awqos;
  input M02_AXI_awready;
  output [3:0]M02_AXI_awregion;
  output [2:0]M02_AXI_awsize;
  output M02_AXI_awvalid;
  output M02_AXI_bready;
  input [1:0]M02_AXI_bresp;
  input M02_AXI_bvalid;
  input [255:0]M02_AXI_rdata;
  input M02_AXI_rlast;
  output M02_AXI_rready;
  input [1:0]M02_AXI_rresp;
  input M02_AXI_rvalid;
  output [255:0]M02_AXI_wdata;
  output M02_AXI_wlast;
  input M02_AXI_wready;
  output [31:0]M02_AXI_wstrb;
  output M02_AXI_wvalid;
  input S00_ACLK;
  input S00_ARESETN;
  input [63:0]S00_AXI_araddr;
  input [1:0]S00_AXI_arburst;
  input [3:0]S00_AXI_arcache;
  input [5:0]S00_AXI_arid;
  input [7:0]S00_AXI_arlen;
  input [0:0]S00_AXI_arlock;
  input [2:0]S00_AXI_arprot;
  input [3:0]S00_AXI_arqos;
  output S00_AXI_arready;
  input [3:0]S00_AXI_arregion;
  input [2:0]S00_AXI_arsize;
  input S00_AXI_arvalid;
  input [63:0]S00_AXI_awaddr;
  input [1:0]S00_AXI_awburst;
  input [3:0]S00_AXI_awcache;
  input [5:0]S00_AXI_awid;
  input [7:0]S00_AXI_awlen;
  input [0:0]S00_AXI_awlock;
  input [2:0]S00_AXI_awprot;
  input [3:0]S00_AXI_awqos;
  output S00_AXI_awready;
  input [3:0]S00_AXI_awregion;
  input [2:0]S00_AXI_awsize;
  input S00_AXI_awvalid;
  output [5:0]S00_AXI_bid;
  input S00_AXI_bready;
  output [1:0]S00_AXI_bresp;
  output S00_AXI_bvalid;
  output [511:0]S00_AXI_rdata;
  output [5:0]S00_AXI_rid;
  output S00_AXI_rlast;
  input S00_AXI_rready;
  output [1:0]S00_AXI_rresp;
  output S00_AXI_rvalid;
  input [511:0]S00_AXI_wdata;
  input S00_AXI_wlast;
  output S00_AXI_wready;
  input [63:0]S00_AXI_wstrb;
  input S00_AXI_wvalid;

  wire M00_ACLK_1;
  wire M00_ARESETN_1;
  wire M01_ACLK_1;
  wire M01_ARESETN_1;
  wire M02_ACLK_1;
  wire M02_ARESETN_1;
  wire S00_ACLK_1;
  wire S00_ARESETN_1;
  wire axi_interconnect_0_ACLK_net;
  wire axi_interconnect_0_ARESETN_net;
  wire [63:0]axi_interconnect_0_to_s00_couplers_ARADDR;
  wire [1:0]axi_interconnect_0_to_s00_couplers_ARBURST;
  wire [3:0]axi_interconnect_0_to_s00_couplers_ARCACHE;
  wire [5:0]axi_interconnect_0_to_s00_couplers_ARID;
  wire [7:0]axi_interconnect_0_to_s00_couplers_ARLEN;
  wire [0:0]axi_interconnect_0_to_s00_couplers_ARLOCK;
  wire [2:0]axi_interconnect_0_to_s00_couplers_ARPROT;
  wire [3:0]axi_interconnect_0_to_s00_couplers_ARQOS;
  wire axi_interconnect_0_to_s00_couplers_ARREADY;
  wire [3:0]axi_interconnect_0_to_s00_couplers_ARREGION;
  wire [2:0]axi_interconnect_0_to_s00_couplers_ARSIZE;
  wire axi_interconnect_0_to_s00_couplers_ARVALID;
  wire [63:0]axi_interconnect_0_to_s00_couplers_AWADDR;
  wire [1:0]axi_interconnect_0_to_s00_couplers_AWBURST;
  wire [3:0]axi_interconnect_0_to_s00_couplers_AWCACHE;
  wire [5:0]axi_interconnect_0_to_s00_couplers_AWID;
  wire [7:0]axi_interconnect_0_to_s00_couplers_AWLEN;
  wire [0:0]axi_interconnect_0_to_s00_couplers_AWLOCK;
  wire [2:0]axi_interconnect_0_to_s00_couplers_AWPROT;
  wire [3:0]axi_interconnect_0_to_s00_couplers_AWQOS;
  wire axi_interconnect_0_to_s00_couplers_AWREADY;
  wire [3:0]axi_interconnect_0_to_s00_couplers_AWREGION;
  wire [2:0]axi_interconnect_0_to_s00_couplers_AWSIZE;
  wire axi_interconnect_0_to_s00_couplers_AWVALID;
  wire [5:0]axi_interconnect_0_to_s00_couplers_BID;
  wire axi_interconnect_0_to_s00_couplers_BREADY;
  wire [1:0]axi_interconnect_0_to_s00_couplers_BRESP;
  wire axi_interconnect_0_to_s00_couplers_BVALID;
  wire [511:0]axi_interconnect_0_to_s00_couplers_RDATA;
  wire [5:0]axi_interconnect_0_to_s00_couplers_RID;
  wire axi_interconnect_0_to_s00_couplers_RLAST;
  wire axi_interconnect_0_to_s00_couplers_RREADY;
  wire [1:0]axi_interconnect_0_to_s00_couplers_RRESP;
  wire axi_interconnect_0_to_s00_couplers_RVALID;
  wire [511:0]axi_interconnect_0_to_s00_couplers_WDATA;
  wire axi_interconnect_0_to_s00_couplers_WLAST;
  wire axi_interconnect_0_to_s00_couplers_WREADY;
  wire [63:0]axi_interconnect_0_to_s00_couplers_WSTRB;
  wire axi_interconnect_0_to_s00_couplers_WVALID;
  wire [63:0]m00_couplers_to_axi_interconnect_0_ARADDR;
  wire [2:0]m00_couplers_to_axi_interconnect_0_ARPROT;
  wire m00_couplers_to_axi_interconnect_0_ARREADY;
  wire m00_couplers_to_axi_interconnect_0_ARVALID;
  wire [63:0]m00_couplers_to_axi_interconnect_0_AWADDR;
  wire [2:0]m00_couplers_to_axi_interconnect_0_AWPROT;
  wire m00_couplers_to_axi_interconnect_0_AWREADY;
  wire m00_couplers_to_axi_interconnect_0_AWVALID;
  wire m00_couplers_to_axi_interconnect_0_BREADY;
  wire [1:0]m00_couplers_to_axi_interconnect_0_BRESP;
  wire m00_couplers_to_axi_interconnect_0_BVALID;
  wire [63:0]m00_couplers_to_axi_interconnect_0_RDATA;
  wire m00_couplers_to_axi_interconnect_0_RREADY;
  wire [1:0]m00_couplers_to_axi_interconnect_0_RRESP;
  wire m00_couplers_to_axi_interconnect_0_RVALID;
  wire [63:0]m00_couplers_to_axi_interconnect_0_WDATA;
  wire m00_couplers_to_axi_interconnect_0_WREADY;
  wire [7:0]m00_couplers_to_axi_interconnect_0_WSTRB;
  wire m00_couplers_to_axi_interconnect_0_WVALID;
  wire [63:0]m01_couplers_to_axi_interconnect_0_ARADDR;
  wire [2:0]m01_couplers_to_axi_interconnect_0_ARPROT;
  wire m01_couplers_to_axi_interconnect_0_ARREADY;
  wire m01_couplers_to_axi_interconnect_0_ARVALID;
  wire [63:0]m01_couplers_to_axi_interconnect_0_AWADDR;
  wire [2:0]m01_couplers_to_axi_interconnect_0_AWPROT;
  wire m01_couplers_to_axi_interconnect_0_AWREADY;
  wire m01_couplers_to_axi_interconnect_0_AWVALID;
  wire m01_couplers_to_axi_interconnect_0_BREADY;
  wire [1:0]m01_couplers_to_axi_interconnect_0_BRESP;
  wire m01_couplers_to_axi_interconnect_0_BVALID;
  wire [63:0]m01_couplers_to_axi_interconnect_0_RDATA;
  wire m01_couplers_to_axi_interconnect_0_RREADY;
  wire [1:0]m01_couplers_to_axi_interconnect_0_RRESP;
  wire m01_couplers_to_axi_interconnect_0_RVALID;
  wire [63:0]m01_couplers_to_axi_interconnect_0_WDATA;
  wire m01_couplers_to_axi_interconnect_0_WREADY;
  wire [7:0]m01_couplers_to_axi_interconnect_0_WSTRB;
  wire m01_couplers_to_axi_interconnect_0_WVALID;
  wire [63:0]m02_couplers_to_axi_interconnect_0_ARADDR;
  wire [1:0]m02_couplers_to_axi_interconnect_0_ARBURST;
  wire [3:0]m02_couplers_to_axi_interconnect_0_ARCACHE;
  wire [7:0]m02_couplers_to_axi_interconnect_0_ARLEN;
  wire [0:0]m02_couplers_to_axi_interconnect_0_ARLOCK;
  wire [2:0]m02_couplers_to_axi_interconnect_0_ARPROT;
  wire [3:0]m02_couplers_to_axi_interconnect_0_ARQOS;
  wire m02_couplers_to_axi_interconnect_0_ARREADY;
  wire [3:0]m02_couplers_to_axi_interconnect_0_ARREGION;
  wire [2:0]m02_couplers_to_axi_interconnect_0_ARSIZE;
  wire m02_couplers_to_axi_interconnect_0_ARVALID;
  wire [63:0]m02_couplers_to_axi_interconnect_0_AWADDR;
  wire [1:0]m02_couplers_to_axi_interconnect_0_AWBURST;
  wire [3:0]m02_couplers_to_axi_interconnect_0_AWCACHE;
  wire [7:0]m02_couplers_to_axi_interconnect_0_AWLEN;
  wire [0:0]m02_couplers_to_axi_interconnect_0_AWLOCK;
  wire [2:0]m02_couplers_to_axi_interconnect_0_AWPROT;
  wire [3:0]m02_couplers_to_axi_interconnect_0_AWQOS;
  wire m02_couplers_to_axi_interconnect_0_AWREADY;
  wire [3:0]m02_couplers_to_axi_interconnect_0_AWREGION;
  wire [2:0]m02_couplers_to_axi_interconnect_0_AWSIZE;
  wire m02_couplers_to_axi_interconnect_0_AWVALID;
  wire m02_couplers_to_axi_interconnect_0_BREADY;
  wire [1:0]m02_couplers_to_axi_interconnect_0_BRESP;
  wire m02_couplers_to_axi_interconnect_0_BVALID;
  wire [255:0]m02_couplers_to_axi_interconnect_0_RDATA;
  wire m02_couplers_to_axi_interconnect_0_RLAST;
  wire m02_couplers_to_axi_interconnect_0_RREADY;
  wire [1:0]m02_couplers_to_axi_interconnect_0_RRESP;
  wire m02_couplers_to_axi_interconnect_0_RVALID;
  wire [255:0]m02_couplers_to_axi_interconnect_0_WDATA;
  wire m02_couplers_to_axi_interconnect_0_WLAST;
  wire m02_couplers_to_axi_interconnect_0_WREADY;
  wire [31:0]m02_couplers_to_axi_interconnect_0_WSTRB;
  wire m02_couplers_to_axi_interconnect_0_WVALID;
  wire [63:0]s00_couplers_to_xbar_ARADDR;
  wire [1:0]s00_couplers_to_xbar_ARBURST;
  wire [3:0]s00_couplers_to_xbar_ARCACHE;
  wire [5:0]s00_couplers_to_xbar_ARID;
  wire [7:0]s00_couplers_to_xbar_ARLEN;
  wire [0:0]s00_couplers_to_xbar_ARLOCK;
  wire [2:0]s00_couplers_to_xbar_ARPROT;
  wire [3:0]s00_couplers_to_xbar_ARQOS;
  wire [0:0]s00_couplers_to_xbar_ARREADY;
  wire [2:0]s00_couplers_to_xbar_ARSIZE;
  wire s00_couplers_to_xbar_ARVALID;
  wire [63:0]s00_couplers_to_xbar_AWADDR;
  wire [1:0]s00_couplers_to_xbar_AWBURST;
  wire [3:0]s00_couplers_to_xbar_AWCACHE;
  wire [5:0]s00_couplers_to_xbar_AWID;
  wire [7:0]s00_couplers_to_xbar_AWLEN;
  wire [0:0]s00_couplers_to_xbar_AWLOCK;
  wire [2:0]s00_couplers_to_xbar_AWPROT;
  wire [3:0]s00_couplers_to_xbar_AWQOS;
  wire [0:0]s00_couplers_to_xbar_AWREADY;
  wire [2:0]s00_couplers_to_xbar_AWSIZE;
  wire s00_couplers_to_xbar_AWVALID;
  wire [5:0]s00_couplers_to_xbar_BID;
  wire s00_couplers_to_xbar_BREADY;
  wire [1:0]s00_couplers_to_xbar_BRESP;
  wire [0:0]s00_couplers_to_xbar_BVALID;
  wire [511:0]s00_couplers_to_xbar_RDATA;
  wire [5:0]s00_couplers_to_xbar_RID;
  wire [0:0]s00_couplers_to_xbar_RLAST;
  wire s00_couplers_to_xbar_RREADY;
  wire [1:0]s00_couplers_to_xbar_RRESP;
  wire [0:0]s00_couplers_to_xbar_RVALID;
  wire [511:0]s00_couplers_to_xbar_WDATA;
  wire s00_couplers_to_xbar_WLAST;
  wire [0:0]s00_couplers_to_xbar_WREADY;
  wire [63:0]s00_couplers_to_xbar_WSTRB;
  wire s00_couplers_to_xbar_WVALID;
  wire [63:0]xbar_to_m00_couplers_ARADDR;
  wire [1:0]xbar_to_m00_couplers_ARBURST;
  wire [3:0]xbar_to_m00_couplers_ARCACHE;
  wire [5:0]xbar_to_m00_couplers_ARID;
  wire [7:0]xbar_to_m00_couplers_ARLEN;
  wire [0:0]xbar_to_m00_couplers_ARLOCK;
  wire [2:0]xbar_to_m00_couplers_ARPROT;
  wire [3:0]xbar_to_m00_couplers_ARQOS;
  wire xbar_to_m00_couplers_ARREADY;
  wire [3:0]xbar_to_m00_couplers_ARREGION;
  wire [2:0]xbar_to_m00_couplers_ARSIZE;
  wire [0:0]xbar_to_m00_couplers_ARVALID;
  wire [63:0]xbar_to_m00_couplers_AWADDR;
  wire [1:0]xbar_to_m00_couplers_AWBURST;
  wire [3:0]xbar_to_m00_couplers_AWCACHE;
  wire [5:0]xbar_to_m00_couplers_AWID;
  wire [7:0]xbar_to_m00_couplers_AWLEN;
  wire [0:0]xbar_to_m00_couplers_AWLOCK;
  wire [2:0]xbar_to_m00_couplers_AWPROT;
  wire [3:0]xbar_to_m00_couplers_AWQOS;
  wire xbar_to_m00_couplers_AWREADY;
  wire [3:0]xbar_to_m00_couplers_AWREGION;
  wire [2:0]xbar_to_m00_couplers_AWSIZE;
  wire [0:0]xbar_to_m00_couplers_AWVALID;
  wire [5:0]xbar_to_m00_couplers_BID;
  wire [0:0]xbar_to_m00_couplers_BREADY;
  wire [1:0]xbar_to_m00_couplers_BRESP;
  wire xbar_to_m00_couplers_BVALID;
  wire [511:0]xbar_to_m00_couplers_RDATA;
  wire [5:0]xbar_to_m00_couplers_RID;
  wire xbar_to_m00_couplers_RLAST;
  wire [0:0]xbar_to_m00_couplers_RREADY;
  wire [1:0]xbar_to_m00_couplers_RRESP;
  wire xbar_to_m00_couplers_RVALID;
  wire [511:0]xbar_to_m00_couplers_WDATA;
  wire [0:0]xbar_to_m00_couplers_WLAST;
  wire xbar_to_m00_couplers_WREADY;
  wire [63:0]xbar_to_m00_couplers_WSTRB;
  wire [0:0]xbar_to_m00_couplers_WVALID;
  wire [127:64]xbar_to_m01_couplers_ARADDR;
  wire [3:2]xbar_to_m01_couplers_ARBURST;
  wire [7:4]xbar_to_m01_couplers_ARCACHE;
  wire [11:6]xbar_to_m01_couplers_ARID;
  wire [15:8]xbar_to_m01_couplers_ARLEN;
  wire [1:1]xbar_to_m01_couplers_ARLOCK;
  wire [5:3]xbar_to_m01_couplers_ARPROT;
  wire [7:4]xbar_to_m01_couplers_ARQOS;
  wire xbar_to_m01_couplers_ARREADY;
  wire [7:4]xbar_to_m01_couplers_ARREGION;
  wire [5:3]xbar_to_m01_couplers_ARSIZE;
  wire [1:1]xbar_to_m01_couplers_ARVALID;
  wire [127:64]xbar_to_m01_couplers_AWADDR;
  wire [3:2]xbar_to_m01_couplers_AWBURST;
  wire [7:4]xbar_to_m01_couplers_AWCACHE;
  wire [11:6]xbar_to_m01_couplers_AWID;
  wire [15:8]xbar_to_m01_couplers_AWLEN;
  wire [1:1]xbar_to_m01_couplers_AWLOCK;
  wire [5:3]xbar_to_m01_couplers_AWPROT;
  wire [7:4]xbar_to_m01_couplers_AWQOS;
  wire xbar_to_m01_couplers_AWREADY;
  wire [7:4]xbar_to_m01_couplers_AWREGION;
  wire [5:3]xbar_to_m01_couplers_AWSIZE;
  wire [1:1]xbar_to_m01_couplers_AWVALID;
  wire [5:0]xbar_to_m01_couplers_BID;
  wire [1:1]xbar_to_m01_couplers_BREADY;
  wire [1:0]xbar_to_m01_couplers_BRESP;
  wire xbar_to_m01_couplers_BVALID;
  wire [511:0]xbar_to_m01_couplers_RDATA;
  wire [5:0]xbar_to_m01_couplers_RID;
  wire xbar_to_m01_couplers_RLAST;
  wire [1:1]xbar_to_m01_couplers_RREADY;
  wire [1:0]xbar_to_m01_couplers_RRESP;
  wire xbar_to_m01_couplers_RVALID;
  wire [1023:512]xbar_to_m01_couplers_WDATA;
  wire [1:1]xbar_to_m01_couplers_WLAST;
  wire xbar_to_m01_couplers_WREADY;
  wire [127:64]xbar_to_m01_couplers_WSTRB;
  wire [1:1]xbar_to_m01_couplers_WVALID;
  wire [191:128]xbar_to_m02_couplers_ARADDR;
  wire [5:4]xbar_to_m02_couplers_ARBURST;
  wire [11:8]xbar_to_m02_couplers_ARCACHE;
  wire [17:12]xbar_to_m02_couplers_ARID;
  wire [23:16]xbar_to_m02_couplers_ARLEN;
  wire [2:2]xbar_to_m02_couplers_ARLOCK;
  wire [8:6]xbar_to_m02_couplers_ARPROT;
  wire [11:8]xbar_to_m02_couplers_ARQOS;
  wire xbar_to_m02_couplers_ARREADY;
  wire [11:8]xbar_to_m02_couplers_ARREGION;
  wire [8:6]xbar_to_m02_couplers_ARSIZE;
  wire [2:2]xbar_to_m02_couplers_ARVALID;
  wire [191:128]xbar_to_m02_couplers_AWADDR;
  wire [5:4]xbar_to_m02_couplers_AWBURST;
  wire [11:8]xbar_to_m02_couplers_AWCACHE;
  wire [17:12]xbar_to_m02_couplers_AWID;
  wire [23:16]xbar_to_m02_couplers_AWLEN;
  wire [2:2]xbar_to_m02_couplers_AWLOCK;
  wire [8:6]xbar_to_m02_couplers_AWPROT;
  wire [11:8]xbar_to_m02_couplers_AWQOS;
  wire xbar_to_m02_couplers_AWREADY;
  wire [11:8]xbar_to_m02_couplers_AWREGION;
  wire [8:6]xbar_to_m02_couplers_AWSIZE;
  wire [2:2]xbar_to_m02_couplers_AWVALID;
  wire [5:0]xbar_to_m02_couplers_BID;
  wire [2:2]xbar_to_m02_couplers_BREADY;
  wire [1:0]xbar_to_m02_couplers_BRESP;
  wire xbar_to_m02_couplers_BVALID;
  wire [511:0]xbar_to_m02_couplers_RDATA;
  wire [5:0]xbar_to_m02_couplers_RID;
  wire xbar_to_m02_couplers_RLAST;
  wire [2:2]xbar_to_m02_couplers_RREADY;
  wire [1:0]xbar_to_m02_couplers_RRESP;
  wire xbar_to_m02_couplers_RVALID;
  wire [1535:1024]xbar_to_m02_couplers_WDATA;
  wire [2:2]xbar_to_m02_couplers_WLAST;
  wire xbar_to_m02_couplers_WREADY;
  wire [191:128]xbar_to_m02_couplers_WSTRB;
  wire [2:2]xbar_to_m02_couplers_WVALID;

  assign M00_ACLK_1 = M00_ACLK;
  assign M00_ARESETN_1 = M00_ARESETN;
  assign M00_AXI_araddr[63:0] = m00_couplers_to_axi_interconnect_0_ARADDR;
  assign M00_AXI_arprot[2:0] = m00_couplers_to_axi_interconnect_0_ARPROT;
  assign M00_AXI_arvalid = m00_couplers_to_axi_interconnect_0_ARVALID;
  assign M00_AXI_awaddr[63:0] = m00_couplers_to_axi_interconnect_0_AWADDR;
  assign M00_AXI_awprot[2:0] = m00_couplers_to_axi_interconnect_0_AWPROT;
  assign M00_AXI_awvalid = m00_couplers_to_axi_interconnect_0_AWVALID;
  assign M00_AXI_bready = m00_couplers_to_axi_interconnect_0_BREADY;
  assign M00_AXI_rready = m00_couplers_to_axi_interconnect_0_RREADY;
  assign M00_AXI_wdata[63:0] = m00_couplers_to_axi_interconnect_0_WDATA;
  assign M00_AXI_wstrb[7:0] = m00_couplers_to_axi_interconnect_0_WSTRB;
  assign M00_AXI_wvalid = m00_couplers_to_axi_interconnect_0_WVALID;
  assign M01_ACLK_1 = M01_ACLK;
  assign M01_ARESETN_1 = M01_ARESETN;
  assign M01_AXI_araddr[63:0] = m01_couplers_to_axi_interconnect_0_ARADDR;
  assign M01_AXI_arprot[2:0] = m01_couplers_to_axi_interconnect_0_ARPROT;
  assign M01_AXI_arvalid = m01_couplers_to_axi_interconnect_0_ARVALID;
  assign M01_AXI_awaddr[63:0] = m01_couplers_to_axi_interconnect_0_AWADDR;
  assign M01_AXI_awprot[2:0] = m01_couplers_to_axi_interconnect_0_AWPROT;
  assign M01_AXI_awvalid = m01_couplers_to_axi_interconnect_0_AWVALID;
  assign M01_AXI_bready = m01_couplers_to_axi_interconnect_0_BREADY;
  assign M01_AXI_rready = m01_couplers_to_axi_interconnect_0_RREADY;
  assign M01_AXI_wdata[63:0] = m01_couplers_to_axi_interconnect_0_WDATA;
  assign M01_AXI_wstrb[7:0] = m01_couplers_to_axi_interconnect_0_WSTRB;
  assign M01_AXI_wvalid = m01_couplers_to_axi_interconnect_0_WVALID;
  assign M02_ACLK_1 = M02_ACLK;
  assign M02_ARESETN_1 = M02_ARESETN;
  assign M02_AXI_araddr[63:0] = m02_couplers_to_axi_interconnect_0_ARADDR;
  assign M02_AXI_arburst[1:0] = m02_couplers_to_axi_interconnect_0_ARBURST;
  assign M02_AXI_arcache[3:0] = m02_couplers_to_axi_interconnect_0_ARCACHE;
  assign M02_AXI_arlen[7:0] = m02_couplers_to_axi_interconnect_0_ARLEN;
  assign M02_AXI_arlock[0] = m02_couplers_to_axi_interconnect_0_ARLOCK;
  assign M02_AXI_arprot[2:0] = m02_couplers_to_axi_interconnect_0_ARPROT;
  assign M02_AXI_arqos[3:0] = m02_couplers_to_axi_interconnect_0_ARQOS;
  assign M02_AXI_arregion[3:0] = m02_couplers_to_axi_interconnect_0_ARREGION;
  assign M02_AXI_arsize[2:0] = m02_couplers_to_axi_interconnect_0_ARSIZE;
  assign M02_AXI_arvalid = m02_couplers_to_axi_interconnect_0_ARVALID;
  assign M02_AXI_awaddr[63:0] = m02_couplers_to_axi_interconnect_0_AWADDR;
  assign M02_AXI_awburst[1:0] = m02_couplers_to_axi_interconnect_0_AWBURST;
  assign M02_AXI_awcache[3:0] = m02_couplers_to_axi_interconnect_0_AWCACHE;
  assign M02_AXI_awlen[7:0] = m02_couplers_to_axi_interconnect_0_AWLEN;
  assign M02_AXI_awlock[0] = m02_couplers_to_axi_interconnect_0_AWLOCK;
  assign M02_AXI_awprot[2:0] = m02_couplers_to_axi_interconnect_0_AWPROT;
  assign M02_AXI_awqos[3:0] = m02_couplers_to_axi_interconnect_0_AWQOS;
  assign M02_AXI_awregion[3:0] = m02_couplers_to_axi_interconnect_0_AWREGION;
  assign M02_AXI_awsize[2:0] = m02_couplers_to_axi_interconnect_0_AWSIZE;
  assign M02_AXI_awvalid = m02_couplers_to_axi_interconnect_0_AWVALID;
  assign M02_AXI_bready = m02_couplers_to_axi_interconnect_0_BREADY;
  assign M02_AXI_rready = m02_couplers_to_axi_interconnect_0_RREADY;
  assign M02_AXI_wdata[255:0] = m02_couplers_to_axi_interconnect_0_WDATA;
  assign M02_AXI_wlast = m02_couplers_to_axi_interconnect_0_WLAST;
  assign M02_AXI_wstrb[31:0] = m02_couplers_to_axi_interconnect_0_WSTRB;
  assign M02_AXI_wvalid = m02_couplers_to_axi_interconnect_0_WVALID;
  assign S00_ACLK_1 = S00_ACLK;
  assign S00_ARESETN_1 = S00_ARESETN;
  assign S00_AXI_arready = axi_interconnect_0_to_s00_couplers_ARREADY;
  assign S00_AXI_awready = axi_interconnect_0_to_s00_couplers_AWREADY;
  assign S00_AXI_bid[5:0] = axi_interconnect_0_to_s00_couplers_BID;
  assign S00_AXI_bresp[1:0] = axi_interconnect_0_to_s00_couplers_BRESP;
  assign S00_AXI_bvalid = axi_interconnect_0_to_s00_couplers_BVALID;
  assign S00_AXI_rdata[511:0] = axi_interconnect_0_to_s00_couplers_RDATA;
  assign S00_AXI_rid[5:0] = axi_interconnect_0_to_s00_couplers_RID;
  assign S00_AXI_rlast = axi_interconnect_0_to_s00_couplers_RLAST;
  assign S00_AXI_rresp[1:0] = axi_interconnect_0_to_s00_couplers_RRESP;
  assign S00_AXI_rvalid = axi_interconnect_0_to_s00_couplers_RVALID;
  assign S00_AXI_wready = axi_interconnect_0_to_s00_couplers_WREADY;
  assign axi_interconnect_0_ACLK_net = ACLK;
  assign axi_interconnect_0_ARESETN_net = ARESETN;
  assign axi_interconnect_0_to_s00_couplers_ARADDR = S00_AXI_araddr[63:0];
  assign axi_interconnect_0_to_s00_couplers_ARBURST = S00_AXI_arburst[1:0];
  assign axi_interconnect_0_to_s00_couplers_ARCACHE = S00_AXI_arcache[3:0];
  assign axi_interconnect_0_to_s00_couplers_ARID = S00_AXI_arid[5:0];
  assign axi_interconnect_0_to_s00_couplers_ARLEN = S00_AXI_arlen[7:0];
  assign axi_interconnect_0_to_s00_couplers_ARLOCK = S00_AXI_arlock[0];
  assign axi_interconnect_0_to_s00_couplers_ARPROT = S00_AXI_arprot[2:0];
  assign axi_interconnect_0_to_s00_couplers_ARQOS = S00_AXI_arqos[3:0];
  assign axi_interconnect_0_to_s00_couplers_ARREGION = S00_AXI_arregion[3:0];
  assign axi_interconnect_0_to_s00_couplers_ARSIZE = S00_AXI_arsize[2:0];
  assign axi_interconnect_0_to_s00_couplers_ARVALID = S00_AXI_arvalid;
  assign axi_interconnect_0_to_s00_couplers_AWADDR = S00_AXI_awaddr[63:0];
  assign axi_interconnect_0_to_s00_couplers_AWBURST = S00_AXI_awburst[1:0];
  assign axi_interconnect_0_to_s00_couplers_AWCACHE = S00_AXI_awcache[3:0];
  assign axi_interconnect_0_to_s00_couplers_AWID = S00_AXI_awid[5:0];
  assign axi_interconnect_0_to_s00_couplers_AWLEN = S00_AXI_awlen[7:0];
  assign axi_interconnect_0_to_s00_couplers_AWLOCK = S00_AXI_awlock[0];
  assign axi_interconnect_0_to_s00_couplers_AWPROT = S00_AXI_awprot[2:0];
  assign axi_interconnect_0_to_s00_couplers_AWQOS = S00_AXI_awqos[3:0];
  assign axi_interconnect_0_to_s00_couplers_AWREGION = S00_AXI_awregion[3:0];
  assign axi_interconnect_0_to_s00_couplers_AWSIZE = S00_AXI_awsize[2:0];
  assign axi_interconnect_0_to_s00_couplers_AWVALID = S00_AXI_awvalid;
  assign axi_interconnect_0_to_s00_couplers_BREADY = S00_AXI_bready;
  assign axi_interconnect_0_to_s00_couplers_RREADY = S00_AXI_rready;
  assign axi_interconnect_0_to_s00_couplers_WDATA = S00_AXI_wdata[511:0];
  assign axi_interconnect_0_to_s00_couplers_WLAST = S00_AXI_wlast;
  assign axi_interconnect_0_to_s00_couplers_WSTRB = S00_AXI_wstrb[63:0];
  assign axi_interconnect_0_to_s00_couplers_WVALID = S00_AXI_wvalid;
  assign m00_couplers_to_axi_interconnect_0_ARREADY = M00_AXI_arready;
  assign m00_couplers_to_axi_interconnect_0_AWREADY = M00_AXI_awready;
  assign m00_couplers_to_axi_interconnect_0_BRESP = M00_AXI_bresp[1:0];
  assign m00_couplers_to_axi_interconnect_0_BVALID = M00_AXI_bvalid;
  assign m00_couplers_to_axi_interconnect_0_RDATA = M00_AXI_rdata[63:0];
  assign m00_couplers_to_axi_interconnect_0_RRESP = M00_AXI_rresp[1:0];
  assign m00_couplers_to_axi_interconnect_0_RVALID = M00_AXI_rvalid;
  assign m00_couplers_to_axi_interconnect_0_WREADY = M00_AXI_wready;
  assign m01_couplers_to_axi_interconnect_0_ARREADY = M01_AXI_arready;
  assign m01_couplers_to_axi_interconnect_0_AWREADY = M01_AXI_awready;
  assign m01_couplers_to_axi_interconnect_0_BRESP = M01_AXI_bresp[1:0];
  assign m01_couplers_to_axi_interconnect_0_BVALID = M01_AXI_bvalid;
  assign m01_couplers_to_axi_interconnect_0_RDATA = M01_AXI_rdata[63:0];
  assign m01_couplers_to_axi_interconnect_0_RRESP = M01_AXI_rresp[1:0];
  assign m01_couplers_to_axi_interconnect_0_RVALID = M01_AXI_rvalid;
  assign m01_couplers_to_axi_interconnect_0_WREADY = M01_AXI_wready;
  assign m02_couplers_to_axi_interconnect_0_ARREADY = M02_AXI_arready;
  assign m02_couplers_to_axi_interconnect_0_AWREADY = M02_AXI_awready;
  assign m02_couplers_to_axi_interconnect_0_BRESP = M02_AXI_bresp[1:0];
  assign m02_couplers_to_axi_interconnect_0_BVALID = M02_AXI_bvalid;
  assign m02_couplers_to_axi_interconnect_0_RDATA = M02_AXI_rdata[255:0];
  assign m02_couplers_to_axi_interconnect_0_RLAST = M02_AXI_rlast;
  assign m02_couplers_to_axi_interconnect_0_RRESP = M02_AXI_rresp[1:0];
  assign m02_couplers_to_axi_interconnect_0_RVALID = M02_AXI_rvalid;
  assign m02_couplers_to_axi_interconnect_0_WREADY = M02_AXI_wready;
  m00_couplers_imp_ZKQPZL m00_couplers
       (.M_ACLK(M00_ACLK_1),
        .M_ARESETN(M00_ARESETN_1),
        .M_AXI_araddr(m00_couplers_to_axi_interconnect_0_ARADDR),
        .M_AXI_arprot(m00_couplers_to_axi_interconnect_0_ARPROT),
        .M_AXI_arready(m00_couplers_to_axi_interconnect_0_ARREADY),
        .M_AXI_arvalid(m00_couplers_to_axi_interconnect_0_ARVALID),
        .M_AXI_awaddr(m00_couplers_to_axi_interconnect_0_AWADDR),
        .M_AXI_awprot(m00_couplers_to_axi_interconnect_0_AWPROT),
        .M_AXI_awready(m00_couplers_to_axi_interconnect_0_AWREADY),
        .M_AXI_awvalid(m00_couplers_to_axi_interconnect_0_AWVALID),
        .M_AXI_bready(m00_couplers_to_axi_interconnect_0_BREADY),
        .M_AXI_bresp(m00_couplers_to_axi_interconnect_0_BRESP),
        .M_AXI_bvalid(m00_couplers_to_axi_interconnect_0_BVALID),
        .M_AXI_rdata(m00_couplers_to_axi_interconnect_0_RDATA),
        .M_AXI_rready(m00_couplers_to_axi_interconnect_0_RREADY),
        .M_AXI_rresp(m00_couplers_to_axi_interconnect_0_RRESP),
        .M_AXI_rvalid(m00_couplers_to_axi_interconnect_0_RVALID),
        .M_AXI_wdata(m00_couplers_to_axi_interconnect_0_WDATA),
        .M_AXI_wready(m00_couplers_to_axi_interconnect_0_WREADY),
        .M_AXI_wstrb(m00_couplers_to_axi_interconnect_0_WSTRB),
        .M_AXI_wvalid(m00_couplers_to_axi_interconnect_0_WVALID),
        .S_ACLK(axi_interconnect_0_ACLK_net),
        .S_ARESETN(axi_interconnect_0_ARESETN_net),
        .S_AXI_araddr(xbar_to_m00_couplers_ARADDR),
        .S_AXI_arburst(xbar_to_m00_couplers_ARBURST),
        .S_AXI_arcache(xbar_to_m00_couplers_ARCACHE),
        .S_AXI_arid(xbar_to_m00_couplers_ARID),
        .S_AXI_arlen(xbar_to_m00_couplers_ARLEN),
        .S_AXI_arlock(xbar_to_m00_couplers_ARLOCK),
        .S_AXI_arprot(xbar_to_m00_couplers_ARPROT),
        .S_AXI_arqos(xbar_to_m00_couplers_ARQOS),
        .S_AXI_arready(xbar_to_m00_couplers_ARREADY),
        .S_AXI_arregion(xbar_to_m00_couplers_ARREGION),
        .S_AXI_arsize(xbar_to_m00_couplers_ARSIZE),
        .S_AXI_arvalid(xbar_to_m00_couplers_ARVALID),
        .S_AXI_awaddr(xbar_to_m00_couplers_AWADDR),
        .S_AXI_awburst(xbar_to_m00_couplers_AWBURST),
        .S_AXI_awcache(xbar_to_m00_couplers_AWCACHE),
        .S_AXI_awid(xbar_to_m00_couplers_AWID),
        .S_AXI_awlen(xbar_to_m00_couplers_AWLEN),
        .S_AXI_awlock(xbar_to_m00_couplers_AWLOCK),
        .S_AXI_awprot(xbar_to_m00_couplers_AWPROT),
        .S_AXI_awqos(xbar_to_m00_couplers_AWQOS),
        .S_AXI_awready(xbar_to_m00_couplers_AWREADY),
        .S_AXI_awregion(xbar_to_m00_couplers_AWREGION),
        .S_AXI_awsize(xbar_to_m00_couplers_AWSIZE),
        .S_AXI_awvalid(xbar_to_m00_couplers_AWVALID),
        .S_AXI_bid(xbar_to_m00_couplers_BID),
        .S_AXI_bready(xbar_to_m00_couplers_BREADY),
        .S_AXI_bresp(xbar_to_m00_couplers_BRESP),
        .S_AXI_bvalid(xbar_to_m00_couplers_BVALID),
        .S_AXI_rdata(xbar_to_m00_couplers_RDATA),
        .S_AXI_rid(xbar_to_m00_couplers_RID),
        .S_AXI_rlast(xbar_to_m00_couplers_RLAST),
        .S_AXI_rready(xbar_to_m00_couplers_RREADY),
        .S_AXI_rresp(xbar_to_m00_couplers_RRESP),
        .S_AXI_rvalid(xbar_to_m00_couplers_RVALID),
        .S_AXI_wdata(xbar_to_m00_couplers_WDATA),
        .S_AXI_wlast(xbar_to_m00_couplers_WLAST),
        .S_AXI_wready(xbar_to_m00_couplers_WREADY),
        .S_AXI_wstrb(xbar_to_m00_couplers_WSTRB),
        .S_AXI_wvalid(xbar_to_m00_couplers_WVALID));
  m01_couplers_imp_8UHLLB m01_couplers
       (.M_ACLK(M01_ACLK_1),
        .M_ARESETN(M01_ARESETN_1),
        .M_AXI_araddr(m01_couplers_to_axi_interconnect_0_ARADDR),
        .M_AXI_arprot(m01_couplers_to_axi_interconnect_0_ARPROT),
        .M_AXI_arready(m01_couplers_to_axi_interconnect_0_ARREADY),
        .M_AXI_arvalid(m01_couplers_to_axi_interconnect_0_ARVALID),
        .M_AXI_awaddr(m01_couplers_to_axi_interconnect_0_AWADDR),
        .M_AXI_awprot(m01_couplers_to_axi_interconnect_0_AWPROT),
        .M_AXI_awready(m01_couplers_to_axi_interconnect_0_AWREADY),
        .M_AXI_awvalid(m01_couplers_to_axi_interconnect_0_AWVALID),
        .M_AXI_bready(m01_couplers_to_axi_interconnect_0_BREADY),
        .M_AXI_bresp(m01_couplers_to_axi_interconnect_0_BRESP),
        .M_AXI_bvalid(m01_couplers_to_axi_interconnect_0_BVALID),
        .M_AXI_rdata(m01_couplers_to_axi_interconnect_0_RDATA),
        .M_AXI_rready(m01_couplers_to_axi_interconnect_0_RREADY),
        .M_AXI_rresp(m01_couplers_to_axi_interconnect_0_RRESP),
        .M_AXI_rvalid(m01_couplers_to_axi_interconnect_0_RVALID),
        .M_AXI_wdata(m01_couplers_to_axi_interconnect_0_WDATA),
        .M_AXI_wready(m01_couplers_to_axi_interconnect_0_WREADY),
        .M_AXI_wstrb(m01_couplers_to_axi_interconnect_0_WSTRB),
        .M_AXI_wvalid(m01_couplers_to_axi_interconnect_0_WVALID),
        .S_ACLK(axi_interconnect_0_ACLK_net),
        .S_ARESETN(axi_interconnect_0_ARESETN_net),
        .S_AXI_araddr(xbar_to_m01_couplers_ARADDR),
        .S_AXI_arburst(xbar_to_m01_couplers_ARBURST),
        .S_AXI_arcache(xbar_to_m01_couplers_ARCACHE),
        .S_AXI_arid(xbar_to_m01_couplers_ARID),
        .S_AXI_arlen(xbar_to_m01_couplers_ARLEN),
        .S_AXI_arlock(xbar_to_m01_couplers_ARLOCK),
        .S_AXI_arprot(xbar_to_m01_couplers_ARPROT),
        .S_AXI_arqos(xbar_to_m01_couplers_ARQOS),
        .S_AXI_arready(xbar_to_m01_couplers_ARREADY),
        .S_AXI_arregion(xbar_to_m01_couplers_ARREGION),
        .S_AXI_arsize(xbar_to_m01_couplers_ARSIZE),
        .S_AXI_arvalid(xbar_to_m01_couplers_ARVALID),
        .S_AXI_awaddr(xbar_to_m01_couplers_AWADDR),
        .S_AXI_awburst(xbar_to_m01_couplers_AWBURST),
        .S_AXI_awcache(xbar_to_m01_couplers_AWCACHE),
        .S_AXI_awid(xbar_to_m01_couplers_AWID),
        .S_AXI_awlen(xbar_to_m01_couplers_AWLEN),
        .S_AXI_awlock(xbar_to_m01_couplers_AWLOCK),
        .S_AXI_awprot(xbar_to_m01_couplers_AWPROT),
        .S_AXI_awqos(xbar_to_m01_couplers_AWQOS),
        .S_AXI_awready(xbar_to_m01_couplers_AWREADY),
        .S_AXI_awregion(xbar_to_m01_couplers_AWREGION),
        .S_AXI_awsize(xbar_to_m01_couplers_AWSIZE),
        .S_AXI_awvalid(xbar_to_m01_couplers_AWVALID),
        .S_AXI_bid(xbar_to_m01_couplers_BID),
        .S_AXI_bready(xbar_to_m01_couplers_BREADY),
        .S_AXI_bresp(xbar_to_m01_couplers_BRESP),
        .S_AXI_bvalid(xbar_to_m01_couplers_BVALID),
        .S_AXI_rdata(xbar_to_m01_couplers_RDATA),
        .S_AXI_rid(xbar_to_m01_couplers_RID),
        .S_AXI_rlast(xbar_to_m01_couplers_RLAST),
        .S_AXI_rready(xbar_to_m01_couplers_RREADY),
        .S_AXI_rresp(xbar_to_m01_couplers_RRESP),
        .S_AXI_rvalid(xbar_to_m01_couplers_RVALID),
        .S_AXI_wdata(xbar_to_m01_couplers_WDATA),
        .S_AXI_wlast(xbar_to_m01_couplers_WLAST),
        .S_AXI_wready(xbar_to_m01_couplers_WREADY),
        .S_AXI_wstrb(xbar_to_m01_couplers_WSTRB),
        .S_AXI_wvalid(xbar_to_m01_couplers_WVALID));
  m02_couplers_imp_S0PEUK m02_couplers
       (.M_ACLK(M02_ACLK_1),
        .M_ARESETN(M02_ARESETN_1),
        .M_AXI_araddr(m02_couplers_to_axi_interconnect_0_ARADDR),
        .M_AXI_arburst(m02_couplers_to_axi_interconnect_0_ARBURST),
        .M_AXI_arcache(m02_couplers_to_axi_interconnect_0_ARCACHE),
        .M_AXI_arlen(m02_couplers_to_axi_interconnect_0_ARLEN),
        .M_AXI_arlock(m02_couplers_to_axi_interconnect_0_ARLOCK),
        .M_AXI_arprot(m02_couplers_to_axi_interconnect_0_ARPROT),
        .M_AXI_arqos(m02_couplers_to_axi_interconnect_0_ARQOS),
        .M_AXI_arready(m02_couplers_to_axi_interconnect_0_ARREADY),
        .M_AXI_arregion(m02_couplers_to_axi_interconnect_0_ARREGION),
        .M_AXI_arsize(m02_couplers_to_axi_interconnect_0_ARSIZE),
        .M_AXI_arvalid(m02_couplers_to_axi_interconnect_0_ARVALID),
        .M_AXI_awaddr(m02_couplers_to_axi_interconnect_0_AWADDR),
        .M_AXI_awburst(m02_couplers_to_axi_interconnect_0_AWBURST),
        .M_AXI_awcache(m02_couplers_to_axi_interconnect_0_AWCACHE),
        .M_AXI_awlen(m02_couplers_to_axi_interconnect_0_AWLEN),
        .M_AXI_awlock(m02_couplers_to_axi_interconnect_0_AWLOCK),
        .M_AXI_awprot(m02_couplers_to_axi_interconnect_0_AWPROT),
        .M_AXI_awqos(m02_couplers_to_axi_interconnect_0_AWQOS),
        .M_AXI_awready(m02_couplers_to_axi_interconnect_0_AWREADY),
        .M_AXI_awregion(m02_couplers_to_axi_interconnect_0_AWREGION),
        .M_AXI_awsize(m02_couplers_to_axi_interconnect_0_AWSIZE),
        .M_AXI_awvalid(m02_couplers_to_axi_interconnect_0_AWVALID),
        .M_AXI_bready(m02_couplers_to_axi_interconnect_0_BREADY),
        .M_AXI_bresp(m02_couplers_to_axi_interconnect_0_BRESP),
        .M_AXI_bvalid(m02_couplers_to_axi_interconnect_0_BVALID),
        .M_AXI_rdata(m02_couplers_to_axi_interconnect_0_RDATA),
        .M_AXI_rlast(m02_couplers_to_axi_interconnect_0_RLAST),
        .M_AXI_rready(m02_couplers_to_axi_interconnect_0_RREADY),
        .M_AXI_rresp(m02_couplers_to_axi_interconnect_0_RRESP),
        .M_AXI_rvalid(m02_couplers_to_axi_interconnect_0_RVALID),
        .M_AXI_wdata(m02_couplers_to_axi_interconnect_0_WDATA),
        .M_AXI_wlast(m02_couplers_to_axi_interconnect_0_WLAST),
        .M_AXI_wready(m02_couplers_to_axi_interconnect_0_WREADY),
        .M_AXI_wstrb(m02_couplers_to_axi_interconnect_0_WSTRB),
        .M_AXI_wvalid(m02_couplers_to_axi_interconnect_0_WVALID),
        .S_ACLK(axi_interconnect_0_ACLK_net),
        .S_ARESETN(axi_interconnect_0_ARESETN_net),
        .S_AXI_araddr(xbar_to_m02_couplers_ARADDR),
        .S_AXI_arburst(xbar_to_m02_couplers_ARBURST),
        .S_AXI_arcache(xbar_to_m02_couplers_ARCACHE),
        .S_AXI_arid(xbar_to_m02_couplers_ARID),
        .S_AXI_arlen(xbar_to_m02_couplers_ARLEN),
        .S_AXI_arlock(xbar_to_m02_couplers_ARLOCK),
        .S_AXI_arprot(xbar_to_m02_couplers_ARPROT),
        .S_AXI_arqos(xbar_to_m02_couplers_ARQOS),
        .S_AXI_arready(xbar_to_m02_couplers_ARREADY),
        .S_AXI_arregion(xbar_to_m02_couplers_ARREGION),
        .S_AXI_arsize(xbar_to_m02_couplers_ARSIZE),
        .S_AXI_arvalid(xbar_to_m02_couplers_ARVALID),
        .S_AXI_awaddr(xbar_to_m02_couplers_AWADDR),
        .S_AXI_awburst(xbar_to_m02_couplers_AWBURST),
        .S_AXI_awcache(xbar_to_m02_couplers_AWCACHE),
        .S_AXI_awid(xbar_to_m02_couplers_AWID),
        .S_AXI_awlen(xbar_to_m02_couplers_AWLEN),
        .S_AXI_awlock(xbar_to_m02_couplers_AWLOCK),
        .S_AXI_awprot(xbar_to_m02_couplers_AWPROT),
        .S_AXI_awqos(xbar_to_m02_couplers_AWQOS),
        .S_AXI_awready(xbar_to_m02_couplers_AWREADY),
        .S_AXI_awregion(xbar_to_m02_couplers_AWREGION),
        .S_AXI_awsize(xbar_to_m02_couplers_AWSIZE),
        .S_AXI_awvalid(xbar_to_m02_couplers_AWVALID),
        .S_AXI_bid(xbar_to_m02_couplers_BID),
        .S_AXI_bready(xbar_to_m02_couplers_BREADY),
        .S_AXI_bresp(xbar_to_m02_couplers_BRESP),
        .S_AXI_bvalid(xbar_to_m02_couplers_BVALID),
        .S_AXI_rdata(xbar_to_m02_couplers_RDATA),
        .S_AXI_rid(xbar_to_m02_couplers_RID),
        .S_AXI_rlast(xbar_to_m02_couplers_RLAST),
        .S_AXI_rready(xbar_to_m02_couplers_RREADY),
        .S_AXI_rresp(xbar_to_m02_couplers_RRESP),
        .S_AXI_rvalid(xbar_to_m02_couplers_RVALID),
        .S_AXI_wdata(xbar_to_m02_couplers_WDATA),
        .S_AXI_wlast(xbar_to_m02_couplers_WLAST),
        .S_AXI_wready(xbar_to_m02_couplers_WREADY),
        .S_AXI_wstrb(xbar_to_m02_couplers_WSTRB),
        .S_AXI_wvalid(xbar_to_m02_couplers_WVALID));
  s00_couplers_imp_U116O1 s00_couplers
       (.M_ACLK(axi_interconnect_0_ACLK_net),
        .M_ARESETN(axi_interconnect_0_ARESETN_net),
        .M_AXI_araddr(s00_couplers_to_xbar_ARADDR),
        .M_AXI_arburst(s00_couplers_to_xbar_ARBURST),
        .M_AXI_arcache(s00_couplers_to_xbar_ARCACHE),
        .M_AXI_arid(s00_couplers_to_xbar_ARID),
        .M_AXI_arlen(s00_couplers_to_xbar_ARLEN),
        .M_AXI_arlock(s00_couplers_to_xbar_ARLOCK),
        .M_AXI_arprot(s00_couplers_to_xbar_ARPROT),
        .M_AXI_arqos(s00_couplers_to_xbar_ARQOS),
        .M_AXI_arready(s00_couplers_to_xbar_ARREADY),
        .M_AXI_arsize(s00_couplers_to_xbar_ARSIZE),
        .M_AXI_arvalid(s00_couplers_to_xbar_ARVALID),
        .M_AXI_awaddr(s00_couplers_to_xbar_AWADDR),
        .M_AXI_awburst(s00_couplers_to_xbar_AWBURST),
        .M_AXI_awcache(s00_couplers_to_xbar_AWCACHE),
        .M_AXI_awid(s00_couplers_to_xbar_AWID),
        .M_AXI_awlen(s00_couplers_to_xbar_AWLEN),
        .M_AXI_awlock(s00_couplers_to_xbar_AWLOCK),
        .M_AXI_awprot(s00_couplers_to_xbar_AWPROT),
        .M_AXI_awqos(s00_couplers_to_xbar_AWQOS),
        .M_AXI_awready(s00_couplers_to_xbar_AWREADY),
        .M_AXI_awsize(s00_couplers_to_xbar_AWSIZE),
        .M_AXI_awvalid(s00_couplers_to_xbar_AWVALID),
        .M_AXI_bid(s00_couplers_to_xbar_BID),
        .M_AXI_bready(s00_couplers_to_xbar_BREADY),
        .M_AXI_bresp(s00_couplers_to_xbar_BRESP),
        .M_AXI_bvalid(s00_couplers_to_xbar_BVALID),
        .M_AXI_rdata(s00_couplers_to_xbar_RDATA),
        .M_AXI_rid(s00_couplers_to_xbar_RID),
        .M_AXI_rlast(s00_couplers_to_xbar_RLAST),
        .M_AXI_rready(s00_couplers_to_xbar_RREADY),
        .M_AXI_rresp(s00_couplers_to_xbar_RRESP),
        .M_AXI_rvalid(s00_couplers_to_xbar_RVALID),
        .M_AXI_wdata(s00_couplers_to_xbar_WDATA),
        .M_AXI_wlast(s00_couplers_to_xbar_WLAST),
        .M_AXI_wready(s00_couplers_to_xbar_WREADY),
        .M_AXI_wstrb(s00_couplers_to_xbar_WSTRB),
        .M_AXI_wvalid(s00_couplers_to_xbar_WVALID),
        .S_ACLK(S00_ACLK_1),
        .S_ARESETN(S00_ARESETN_1),
        .S_AXI_araddr(axi_interconnect_0_to_s00_couplers_ARADDR),
        .S_AXI_arburst(axi_interconnect_0_to_s00_couplers_ARBURST),
        .S_AXI_arcache(axi_interconnect_0_to_s00_couplers_ARCACHE),
        .S_AXI_arid(axi_interconnect_0_to_s00_couplers_ARID),
        .S_AXI_arlen(axi_interconnect_0_to_s00_couplers_ARLEN),
        .S_AXI_arlock(axi_interconnect_0_to_s00_couplers_ARLOCK),
        .S_AXI_arprot(axi_interconnect_0_to_s00_couplers_ARPROT),
        .S_AXI_arqos(axi_interconnect_0_to_s00_couplers_ARQOS),
        .S_AXI_arready(axi_interconnect_0_to_s00_couplers_ARREADY),
        .S_AXI_arregion(axi_interconnect_0_to_s00_couplers_ARREGION),
        .S_AXI_arsize(axi_interconnect_0_to_s00_couplers_ARSIZE),
        .S_AXI_arvalid(axi_interconnect_0_to_s00_couplers_ARVALID),
        .S_AXI_awaddr(axi_interconnect_0_to_s00_couplers_AWADDR),
        .S_AXI_awburst(axi_interconnect_0_to_s00_couplers_AWBURST),
        .S_AXI_awcache(axi_interconnect_0_to_s00_couplers_AWCACHE),
        .S_AXI_awid(axi_interconnect_0_to_s00_couplers_AWID),
        .S_AXI_awlen(axi_interconnect_0_to_s00_couplers_AWLEN),
        .S_AXI_awlock(axi_interconnect_0_to_s00_couplers_AWLOCK),
        .S_AXI_awprot(axi_interconnect_0_to_s00_couplers_AWPROT),
        .S_AXI_awqos(axi_interconnect_0_to_s00_couplers_AWQOS),
        .S_AXI_awready(axi_interconnect_0_to_s00_couplers_AWREADY),
        .S_AXI_awregion(axi_interconnect_0_to_s00_couplers_AWREGION),
        .S_AXI_awsize(axi_interconnect_0_to_s00_couplers_AWSIZE),
        .S_AXI_awvalid(axi_interconnect_0_to_s00_couplers_AWVALID),
        .S_AXI_bid(axi_interconnect_0_to_s00_couplers_BID),
        .S_AXI_bready(axi_interconnect_0_to_s00_couplers_BREADY),
        .S_AXI_bresp(axi_interconnect_0_to_s00_couplers_BRESP),
        .S_AXI_bvalid(axi_interconnect_0_to_s00_couplers_BVALID),
        .S_AXI_rdata(axi_interconnect_0_to_s00_couplers_RDATA),
        .S_AXI_rid(axi_interconnect_0_to_s00_couplers_RID),
        .S_AXI_rlast(axi_interconnect_0_to_s00_couplers_RLAST),
        .S_AXI_rready(axi_interconnect_0_to_s00_couplers_RREADY),
        .S_AXI_rresp(axi_interconnect_0_to_s00_couplers_RRESP),
        .S_AXI_rvalid(axi_interconnect_0_to_s00_couplers_RVALID),
        .S_AXI_wdata(axi_interconnect_0_to_s00_couplers_WDATA),
        .S_AXI_wlast(axi_interconnect_0_to_s00_couplers_WLAST),
        .S_AXI_wready(axi_interconnect_0_to_s00_couplers_WREADY),
        .S_AXI_wstrb(axi_interconnect_0_to_s00_couplers_WSTRB),
        .S_AXI_wvalid(axi_interconnect_0_to_s00_couplers_WVALID));
  design_ctrl_xbar_0 xbar
       (.aclk(axi_interconnect_0_ACLK_net),
        .aresetn(axi_interconnect_0_ARESETN_net),
        .m_axi_araddr({xbar_to_m02_couplers_ARADDR,xbar_to_m01_couplers_ARADDR,xbar_to_m00_couplers_ARADDR}),
        .m_axi_arburst({xbar_to_m02_couplers_ARBURST,xbar_to_m01_couplers_ARBURST,xbar_to_m00_couplers_ARBURST}),
        .m_axi_arcache({xbar_to_m02_couplers_ARCACHE,xbar_to_m01_couplers_ARCACHE,xbar_to_m00_couplers_ARCACHE}),
        .m_axi_arid({xbar_to_m02_couplers_ARID,xbar_to_m01_couplers_ARID,xbar_to_m00_couplers_ARID}),
        .m_axi_arlen({xbar_to_m02_couplers_ARLEN,xbar_to_m01_couplers_ARLEN,xbar_to_m00_couplers_ARLEN}),
        .m_axi_arlock({xbar_to_m02_couplers_ARLOCK,xbar_to_m01_couplers_ARLOCK,xbar_to_m00_couplers_ARLOCK}),
        .m_axi_arprot({xbar_to_m02_couplers_ARPROT,xbar_to_m01_couplers_ARPROT,xbar_to_m00_couplers_ARPROT}),
        .m_axi_arqos({xbar_to_m02_couplers_ARQOS,xbar_to_m01_couplers_ARQOS,xbar_to_m00_couplers_ARQOS}),
        .m_axi_arready({xbar_to_m02_couplers_ARREADY,xbar_to_m01_couplers_ARREADY,xbar_to_m00_couplers_ARREADY}),
        .m_axi_arregion({xbar_to_m02_couplers_ARREGION,xbar_to_m01_couplers_ARREGION,xbar_to_m00_couplers_ARREGION}),
        .m_axi_arsize({xbar_to_m02_couplers_ARSIZE,xbar_to_m01_couplers_ARSIZE,xbar_to_m00_couplers_ARSIZE}),
        .m_axi_arvalid({xbar_to_m02_couplers_ARVALID,xbar_to_m01_couplers_ARVALID,xbar_to_m00_couplers_ARVALID}),
        .m_axi_awaddr({xbar_to_m02_couplers_AWADDR,xbar_to_m01_couplers_AWADDR,xbar_to_m00_couplers_AWADDR}),
        .m_axi_awburst({xbar_to_m02_couplers_AWBURST,xbar_to_m01_couplers_AWBURST,xbar_to_m00_couplers_AWBURST}),
        .m_axi_awcache({xbar_to_m02_couplers_AWCACHE,xbar_to_m01_couplers_AWCACHE,xbar_to_m00_couplers_AWCACHE}),
        .m_axi_awid({xbar_to_m02_couplers_AWID,xbar_to_m01_couplers_AWID,xbar_to_m00_couplers_AWID}),
        .m_axi_awlen({xbar_to_m02_couplers_AWLEN,xbar_to_m01_couplers_AWLEN,xbar_to_m00_couplers_AWLEN}),
        .m_axi_awlock({xbar_to_m02_couplers_AWLOCK,xbar_to_m01_couplers_AWLOCK,xbar_to_m00_couplers_AWLOCK}),
        .m_axi_awprot({xbar_to_m02_couplers_AWPROT,xbar_to_m01_couplers_AWPROT,xbar_to_m00_couplers_AWPROT}),
        .m_axi_awqos({xbar_to_m02_couplers_AWQOS,xbar_to_m01_couplers_AWQOS,xbar_to_m00_couplers_AWQOS}),
        .m_axi_awready({xbar_to_m02_couplers_AWREADY,xbar_to_m01_couplers_AWREADY,xbar_to_m00_couplers_AWREADY}),
        .m_axi_awregion({xbar_to_m02_couplers_AWREGION,xbar_to_m01_couplers_AWREGION,xbar_to_m00_couplers_AWREGION}),
        .m_axi_awsize({xbar_to_m02_couplers_AWSIZE,xbar_to_m01_couplers_AWSIZE,xbar_to_m00_couplers_AWSIZE}),
        .m_axi_awvalid({xbar_to_m02_couplers_AWVALID,xbar_to_m01_couplers_AWVALID,xbar_to_m00_couplers_AWVALID}),
        .m_axi_bid({xbar_to_m02_couplers_BID,xbar_to_m01_couplers_BID,xbar_to_m00_couplers_BID}),
        .m_axi_bready({xbar_to_m02_couplers_BREADY,xbar_to_m01_couplers_BREADY,xbar_to_m00_couplers_BREADY}),
        .m_axi_bresp({xbar_to_m02_couplers_BRESP,xbar_to_m01_couplers_BRESP,xbar_to_m00_couplers_BRESP}),
        .m_axi_bvalid({xbar_to_m02_couplers_BVALID,xbar_to_m01_couplers_BVALID,xbar_to_m00_couplers_BVALID}),
        .m_axi_rdata({xbar_to_m02_couplers_RDATA,xbar_to_m01_couplers_RDATA,xbar_to_m00_couplers_RDATA}),
        .m_axi_rid({xbar_to_m02_couplers_RID,xbar_to_m01_couplers_RID,xbar_to_m00_couplers_RID}),
        .m_axi_rlast({xbar_to_m02_couplers_RLAST,xbar_to_m01_couplers_RLAST,xbar_to_m00_couplers_RLAST}),
        .m_axi_rready({xbar_to_m02_couplers_RREADY,xbar_to_m01_couplers_RREADY,xbar_to_m00_couplers_RREADY}),
        .m_axi_rresp({xbar_to_m02_couplers_RRESP,xbar_to_m01_couplers_RRESP,xbar_to_m00_couplers_RRESP}),
        .m_axi_rvalid({xbar_to_m02_couplers_RVALID,xbar_to_m01_couplers_RVALID,xbar_to_m00_couplers_RVALID}),
        .m_axi_wdata({xbar_to_m02_couplers_WDATA,xbar_to_m01_couplers_WDATA,xbar_to_m00_couplers_WDATA}),
        .m_axi_wlast({xbar_to_m02_couplers_WLAST,xbar_to_m01_couplers_WLAST,xbar_to_m00_couplers_WLAST}),
        .m_axi_wready({xbar_to_m02_couplers_WREADY,xbar_to_m01_couplers_WREADY,xbar_to_m00_couplers_WREADY}),
        .m_axi_wstrb({xbar_to_m02_couplers_WSTRB,xbar_to_m01_couplers_WSTRB,xbar_to_m00_couplers_WSTRB}),
        .m_axi_wvalid({xbar_to_m02_couplers_WVALID,xbar_to_m01_couplers_WVALID,xbar_to_m00_couplers_WVALID}),
        .s_axi_araddr(s00_couplers_to_xbar_ARADDR),
        .s_axi_arburst(s00_couplers_to_xbar_ARBURST),
        .s_axi_arcache(s00_couplers_to_xbar_ARCACHE),
        .s_axi_arid(s00_couplers_to_xbar_ARID),
        .s_axi_arlen(s00_couplers_to_xbar_ARLEN),
        .s_axi_arlock(s00_couplers_to_xbar_ARLOCK),
        .s_axi_arprot(s00_couplers_to_xbar_ARPROT),
        .s_axi_arqos(s00_couplers_to_xbar_ARQOS),
        .s_axi_arready(s00_couplers_to_xbar_ARREADY),
        .s_axi_arsize(s00_couplers_to_xbar_ARSIZE),
        .s_axi_arvalid(s00_couplers_to_xbar_ARVALID),
        .s_axi_awaddr(s00_couplers_to_xbar_AWADDR),
        .s_axi_awburst(s00_couplers_to_xbar_AWBURST),
        .s_axi_awcache(s00_couplers_to_xbar_AWCACHE),
        .s_axi_awid(s00_couplers_to_xbar_AWID),
        .s_axi_awlen(s00_couplers_to_xbar_AWLEN),
        .s_axi_awlock(s00_couplers_to_xbar_AWLOCK),
        .s_axi_awprot(s00_couplers_to_xbar_AWPROT),
        .s_axi_awqos(s00_couplers_to_xbar_AWQOS),
        .s_axi_awready(s00_couplers_to_xbar_AWREADY),
        .s_axi_awsize(s00_couplers_to_xbar_AWSIZE),
        .s_axi_awvalid(s00_couplers_to_xbar_AWVALID),
        .s_axi_bid(s00_couplers_to_xbar_BID),
        .s_axi_bready(s00_couplers_to_xbar_BREADY),
        .s_axi_bresp(s00_couplers_to_xbar_BRESP),
        .s_axi_bvalid(s00_couplers_to_xbar_BVALID),
        .s_axi_rdata(s00_couplers_to_xbar_RDATA),
        .s_axi_rid(s00_couplers_to_xbar_RID),
        .s_axi_rlast(s00_couplers_to_xbar_RLAST),
        .s_axi_rready(s00_couplers_to_xbar_RREADY),
        .s_axi_rresp(s00_couplers_to_xbar_RRESP),
        .s_axi_rvalid(s00_couplers_to_xbar_RVALID),
        .s_axi_wdata(s00_couplers_to_xbar_WDATA),
        .s_axi_wlast(s00_couplers_to_xbar_WLAST),
        .s_axi_wready(s00_couplers_to_xbar_WREADY),
        .s_axi_wstrb(s00_couplers_to_xbar_WSTRB),
        .s_axi_wvalid(s00_couplers_to_xbar_WVALID));
endmodule

module m00_couplers_imp_ZKQPZL
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arprot,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awprot,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arburst,
    S_AXI_arcache,
    S_AXI_arid,
    S_AXI_arlen,
    S_AXI_arlock,
    S_AXI_arprot,
    S_AXI_arqos,
    S_AXI_arready,
    S_AXI_arregion,
    S_AXI_arsize,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awburst,
    S_AXI_awcache,
    S_AXI_awid,
    S_AXI_awlen,
    S_AXI_awlock,
    S_AXI_awprot,
    S_AXI_awqos,
    S_AXI_awready,
    S_AXI_awregion,
    S_AXI_awsize,
    S_AXI_awvalid,
    S_AXI_bid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rid,
    S_AXI_rlast,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wlast,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [63:0]M_AXI_araddr;
  output [2:0]M_AXI_arprot;
  input M_AXI_arready;
  output M_AXI_arvalid;
  output [63:0]M_AXI_awaddr;
  output [2:0]M_AXI_awprot;
  input M_AXI_awready;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [63:0]M_AXI_rdata;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [63:0]M_AXI_wdata;
  input M_AXI_wready;
  output [7:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [63:0]S_AXI_araddr;
  input [1:0]S_AXI_arburst;
  input [3:0]S_AXI_arcache;
  input [5:0]S_AXI_arid;
  input [7:0]S_AXI_arlen;
  input [0:0]S_AXI_arlock;
  input [2:0]S_AXI_arprot;
  input [3:0]S_AXI_arqos;
  output S_AXI_arready;
  input [3:0]S_AXI_arregion;
  input [2:0]S_AXI_arsize;
  input S_AXI_arvalid;
  input [63:0]S_AXI_awaddr;
  input [1:0]S_AXI_awburst;
  input [3:0]S_AXI_awcache;
  input [5:0]S_AXI_awid;
  input [7:0]S_AXI_awlen;
  input [0:0]S_AXI_awlock;
  input [2:0]S_AXI_awprot;
  input [3:0]S_AXI_awqos;
  output S_AXI_awready;
  input [3:0]S_AXI_awregion;
  input [2:0]S_AXI_awsize;
  input S_AXI_awvalid;
  output [5:0]S_AXI_bid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [511:0]S_AXI_rdata;
  output [5:0]S_AXI_rid;
  output S_AXI_rlast;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [511:0]S_AXI_wdata;
  input S_AXI_wlast;
  output S_AXI_wready;
  input [63:0]S_AXI_wstrb;
  input S_AXI_wvalid;

  wire M_ACLK_1;
  wire M_ARESETN_1;
  wire S_ACLK_1;
  wire S_ARESETN_1;
  wire [63:0]auto_cc_to_auto_ds_ARADDR;
  wire [1:0]auto_cc_to_auto_ds_ARBURST;
  wire [3:0]auto_cc_to_auto_ds_ARCACHE;
  wire [5:0]auto_cc_to_auto_ds_ARID;
  wire [7:0]auto_cc_to_auto_ds_ARLEN;
  wire [0:0]auto_cc_to_auto_ds_ARLOCK;
  wire [2:0]auto_cc_to_auto_ds_ARPROT;
  wire [3:0]auto_cc_to_auto_ds_ARQOS;
  wire auto_cc_to_auto_ds_ARREADY;
  wire [3:0]auto_cc_to_auto_ds_ARREGION;
  wire [2:0]auto_cc_to_auto_ds_ARSIZE;
  wire auto_cc_to_auto_ds_ARVALID;
  wire [63:0]auto_cc_to_auto_ds_AWADDR;
  wire [1:0]auto_cc_to_auto_ds_AWBURST;
  wire [3:0]auto_cc_to_auto_ds_AWCACHE;
  wire [5:0]auto_cc_to_auto_ds_AWID;
  wire [7:0]auto_cc_to_auto_ds_AWLEN;
  wire [0:0]auto_cc_to_auto_ds_AWLOCK;
  wire [2:0]auto_cc_to_auto_ds_AWPROT;
  wire [3:0]auto_cc_to_auto_ds_AWQOS;
  wire auto_cc_to_auto_ds_AWREADY;
  wire [3:0]auto_cc_to_auto_ds_AWREGION;
  wire [2:0]auto_cc_to_auto_ds_AWSIZE;
  wire auto_cc_to_auto_ds_AWVALID;
  wire [5:0]auto_cc_to_auto_ds_BID;
  wire auto_cc_to_auto_ds_BREADY;
  wire [1:0]auto_cc_to_auto_ds_BRESP;
  wire auto_cc_to_auto_ds_BVALID;
  wire [511:0]auto_cc_to_auto_ds_RDATA;
  wire [5:0]auto_cc_to_auto_ds_RID;
  wire auto_cc_to_auto_ds_RLAST;
  wire auto_cc_to_auto_ds_RREADY;
  wire [1:0]auto_cc_to_auto_ds_RRESP;
  wire auto_cc_to_auto_ds_RVALID;
  wire [511:0]auto_cc_to_auto_ds_WDATA;
  wire auto_cc_to_auto_ds_WLAST;
  wire auto_cc_to_auto_ds_WREADY;
  wire [63:0]auto_cc_to_auto_ds_WSTRB;
  wire auto_cc_to_auto_ds_WVALID;
  wire [63:0]auto_ds_to_auto_rs_ARADDR;
  wire [1:0]auto_ds_to_auto_rs_ARBURST;
  wire [3:0]auto_ds_to_auto_rs_ARCACHE;
  wire [7:0]auto_ds_to_auto_rs_ARLEN;
  wire [0:0]auto_ds_to_auto_rs_ARLOCK;
  wire [2:0]auto_ds_to_auto_rs_ARPROT;
  wire [3:0]auto_ds_to_auto_rs_ARQOS;
  wire auto_ds_to_auto_rs_ARREADY;
  wire [3:0]auto_ds_to_auto_rs_ARREGION;
  wire [2:0]auto_ds_to_auto_rs_ARSIZE;
  wire auto_ds_to_auto_rs_ARVALID;
  wire [63:0]auto_ds_to_auto_rs_AWADDR;
  wire [1:0]auto_ds_to_auto_rs_AWBURST;
  wire [3:0]auto_ds_to_auto_rs_AWCACHE;
  wire [7:0]auto_ds_to_auto_rs_AWLEN;
  wire [0:0]auto_ds_to_auto_rs_AWLOCK;
  wire [2:0]auto_ds_to_auto_rs_AWPROT;
  wire [3:0]auto_ds_to_auto_rs_AWQOS;
  wire auto_ds_to_auto_rs_AWREADY;
  wire [3:0]auto_ds_to_auto_rs_AWREGION;
  wire [2:0]auto_ds_to_auto_rs_AWSIZE;
  wire auto_ds_to_auto_rs_AWVALID;
  wire auto_ds_to_auto_rs_BREADY;
  wire [1:0]auto_ds_to_auto_rs_BRESP;
  wire auto_ds_to_auto_rs_BVALID;
  wire [63:0]auto_ds_to_auto_rs_RDATA;
  wire auto_ds_to_auto_rs_RLAST;
  wire auto_ds_to_auto_rs_RREADY;
  wire [1:0]auto_ds_to_auto_rs_RRESP;
  wire auto_ds_to_auto_rs_RVALID;
  wire [63:0]auto_ds_to_auto_rs_WDATA;
  wire auto_ds_to_auto_rs_WLAST;
  wire auto_ds_to_auto_rs_WREADY;
  wire [7:0]auto_ds_to_auto_rs_WSTRB;
  wire auto_ds_to_auto_rs_WVALID;
  wire [63:0]auto_pc_to_m00_regslice_ARADDR;
  wire [2:0]auto_pc_to_m00_regslice_ARPROT;
  wire auto_pc_to_m00_regslice_ARREADY;
  wire auto_pc_to_m00_regslice_ARVALID;
  wire [63:0]auto_pc_to_m00_regslice_AWADDR;
  wire [2:0]auto_pc_to_m00_regslice_AWPROT;
  wire auto_pc_to_m00_regslice_AWREADY;
  wire auto_pc_to_m00_regslice_AWVALID;
  wire auto_pc_to_m00_regslice_BREADY;
  wire [1:0]auto_pc_to_m00_regslice_BRESP;
  wire auto_pc_to_m00_regslice_BVALID;
  wire [63:0]auto_pc_to_m00_regslice_RDATA;
  wire auto_pc_to_m00_regslice_RREADY;
  wire [1:0]auto_pc_to_m00_regslice_RRESP;
  wire auto_pc_to_m00_regslice_RVALID;
  wire [63:0]auto_pc_to_m00_regslice_WDATA;
  wire auto_pc_to_m00_regslice_WREADY;
  wire [7:0]auto_pc_to_m00_regslice_WSTRB;
  wire auto_pc_to_m00_regslice_WVALID;
  wire [63:0]auto_rs_to_auto_pc_ARADDR;
  wire [1:0]auto_rs_to_auto_pc_ARBURST;
  wire [3:0]auto_rs_to_auto_pc_ARCACHE;
  wire [7:0]auto_rs_to_auto_pc_ARLEN;
  wire [0:0]auto_rs_to_auto_pc_ARLOCK;
  wire [2:0]auto_rs_to_auto_pc_ARPROT;
  wire [3:0]auto_rs_to_auto_pc_ARQOS;
  wire auto_rs_to_auto_pc_ARREADY;
  wire [3:0]auto_rs_to_auto_pc_ARREGION;
  wire [2:0]auto_rs_to_auto_pc_ARSIZE;
  wire auto_rs_to_auto_pc_ARVALID;
  wire [63:0]auto_rs_to_auto_pc_AWADDR;
  wire [1:0]auto_rs_to_auto_pc_AWBURST;
  wire [3:0]auto_rs_to_auto_pc_AWCACHE;
  wire [7:0]auto_rs_to_auto_pc_AWLEN;
  wire [0:0]auto_rs_to_auto_pc_AWLOCK;
  wire [2:0]auto_rs_to_auto_pc_AWPROT;
  wire [3:0]auto_rs_to_auto_pc_AWQOS;
  wire auto_rs_to_auto_pc_AWREADY;
  wire [3:0]auto_rs_to_auto_pc_AWREGION;
  wire [2:0]auto_rs_to_auto_pc_AWSIZE;
  wire auto_rs_to_auto_pc_AWVALID;
  wire auto_rs_to_auto_pc_BREADY;
  wire [1:0]auto_rs_to_auto_pc_BRESP;
  wire auto_rs_to_auto_pc_BVALID;
  wire [63:0]auto_rs_to_auto_pc_RDATA;
  wire auto_rs_to_auto_pc_RLAST;
  wire auto_rs_to_auto_pc_RREADY;
  wire [1:0]auto_rs_to_auto_pc_RRESP;
  wire auto_rs_to_auto_pc_RVALID;
  wire [63:0]auto_rs_to_auto_pc_WDATA;
  wire auto_rs_to_auto_pc_WLAST;
  wire auto_rs_to_auto_pc_WREADY;
  wire [7:0]auto_rs_to_auto_pc_WSTRB;
  wire auto_rs_to_auto_pc_WVALID;
  wire [63:0]m00_couplers_to_auto_cc_ARADDR;
  wire [1:0]m00_couplers_to_auto_cc_ARBURST;
  wire [3:0]m00_couplers_to_auto_cc_ARCACHE;
  wire [5:0]m00_couplers_to_auto_cc_ARID;
  wire [7:0]m00_couplers_to_auto_cc_ARLEN;
  wire [0:0]m00_couplers_to_auto_cc_ARLOCK;
  wire [2:0]m00_couplers_to_auto_cc_ARPROT;
  wire [3:0]m00_couplers_to_auto_cc_ARQOS;
  wire m00_couplers_to_auto_cc_ARREADY;
  wire [3:0]m00_couplers_to_auto_cc_ARREGION;
  wire [2:0]m00_couplers_to_auto_cc_ARSIZE;
  wire m00_couplers_to_auto_cc_ARVALID;
  wire [63:0]m00_couplers_to_auto_cc_AWADDR;
  wire [1:0]m00_couplers_to_auto_cc_AWBURST;
  wire [3:0]m00_couplers_to_auto_cc_AWCACHE;
  wire [5:0]m00_couplers_to_auto_cc_AWID;
  wire [7:0]m00_couplers_to_auto_cc_AWLEN;
  wire [0:0]m00_couplers_to_auto_cc_AWLOCK;
  wire [2:0]m00_couplers_to_auto_cc_AWPROT;
  wire [3:0]m00_couplers_to_auto_cc_AWQOS;
  wire m00_couplers_to_auto_cc_AWREADY;
  wire [3:0]m00_couplers_to_auto_cc_AWREGION;
  wire [2:0]m00_couplers_to_auto_cc_AWSIZE;
  wire m00_couplers_to_auto_cc_AWVALID;
  wire [5:0]m00_couplers_to_auto_cc_BID;
  wire m00_couplers_to_auto_cc_BREADY;
  wire [1:0]m00_couplers_to_auto_cc_BRESP;
  wire m00_couplers_to_auto_cc_BVALID;
  wire [511:0]m00_couplers_to_auto_cc_RDATA;
  wire [5:0]m00_couplers_to_auto_cc_RID;
  wire m00_couplers_to_auto_cc_RLAST;
  wire m00_couplers_to_auto_cc_RREADY;
  wire [1:0]m00_couplers_to_auto_cc_RRESP;
  wire m00_couplers_to_auto_cc_RVALID;
  wire [511:0]m00_couplers_to_auto_cc_WDATA;
  wire m00_couplers_to_auto_cc_WLAST;
  wire m00_couplers_to_auto_cc_WREADY;
  wire [63:0]m00_couplers_to_auto_cc_WSTRB;
  wire m00_couplers_to_auto_cc_WVALID;
  wire [63:0]m00_regslice_to_m00_couplers_ARADDR;
  wire [2:0]m00_regslice_to_m00_couplers_ARPROT;
  wire m00_regslice_to_m00_couplers_ARREADY;
  wire m00_regslice_to_m00_couplers_ARVALID;
  wire [63:0]m00_regslice_to_m00_couplers_AWADDR;
  wire [2:0]m00_regslice_to_m00_couplers_AWPROT;
  wire m00_regslice_to_m00_couplers_AWREADY;
  wire m00_regslice_to_m00_couplers_AWVALID;
  wire m00_regslice_to_m00_couplers_BREADY;
  wire [1:0]m00_regslice_to_m00_couplers_BRESP;
  wire m00_regslice_to_m00_couplers_BVALID;
  wire [63:0]m00_regslice_to_m00_couplers_RDATA;
  wire m00_regslice_to_m00_couplers_RREADY;
  wire [1:0]m00_regslice_to_m00_couplers_RRESP;
  wire m00_regslice_to_m00_couplers_RVALID;
  wire [63:0]m00_regslice_to_m00_couplers_WDATA;
  wire m00_regslice_to_m00_couplers_WREADY;
  wire [7:0]m00_regslice_to_m00_couplers_WSTRB;
  wire m00_regslice_to_m00_couplers_WVALID;

  assign M_ACLK_1 = M_ACLK;
  assign M_ARESETN_1 = M_ARESETN;
  assign M_AXI_araddr[63:0] = m00_regslice_to_m00_couplers_ARADDR;
  assign M_AXI_arprot[2:0] = m00_regslice_to_m00_couplers_ARPROT;
  assign M_AXI_arvalid = m00_regslice_to_m00_couplers_ARVALID;
  assign M_AXI_awaddr[63:0] = m00_regslice_to_m00_couplers_AWADDR;
  assign M_AXI_awprot[2:0] = m00_regslice_to_m00_couplers_AWPROT;
  assign M_AXI_awvalid = m00_regslice_to_m00_couplers_AWVALID;
  assign M_AXI_bready = m00_regslice_to_m00_couplers_BREADY;
  assign M_AXI_rready = m00_regslice_to_m00_couplers_RREADY;
  assign M_AXI_wdata[63:0] = m00_regslice_to_m00_couplers_WDATA;
  assign M_AXI_wstrb[7:0] = m00_regslice_to_m00_couplers_WSTRB;
  assign M_AXI_wvalid = m00_regslice_to_m00_couplers_WVALID;
  assign S_ACLK_1 = S_ACLK;
  assign S_ARESETN_1 = S_ARESETN;
  assign S_AXI_arready = m00_couplers_to_auto_cc_ARREADY;
  assign S_AXI_awready = m00_couplers_to_auto_cc_AWREADY;
  assign S_AXI_bid[5:0] = m00_couplers_to_auto_cc_BID;
  assign S_AXI_bresp[1:0] = m00_couplers_to_auto_cc_BRESP;
  assign S_AXI_bvalid = m00_couplers_to_auto_cc_BVALID;
  assign S_AXI_rdata[511:0] = m00_couplers_to_auto_cc_RDATA;
  assign S_AXI_rid[5:0] = m00_couplers_to_auto_cc_RID;
  assign S_AXI_rlast = m00_couplers_to_auto_cc_RLAST;
  assign S_AXI_rresp[1:0] = m00_couplers_to_auto_cc_RRESP;
  assign S_AXI_rvalid = m00_couplers_to_auto_cc_RVALID;
  assign S_AXI_wready = m00_couplers_to_auto_cc_WREADY;
  assign m00_couplers_to_auto_cc_ARADDR = S_AXI_araddr[63:0];
  assign m00_couplers_to_auto_cc_ARBURST = S_AXI_arburst[1:0];
  assign m00_couplers_to_auto_cc_ARCACHE = S_AXI_arcache[3:0];
  assign m00_couplers_to_auto_cc_ARID = S_AXI_arid[5:0];
  assign m00_couplers_to_auto_cc_ARLEN = S_AXI_arlen[7:0];
  assign m00_couplers_to_auto_cc_ARLOCK = S_AXI_arlock[0];
  assign m00_couplers_to_auto_cc_ARPROT = S_AXI_arprot[2:0];
  assign m00_couplers_to_auto_cc_ARQOS = S_AXI_arqos[3:0];
  assign m00_couplers_to_auto_cc_ARREGION = S_AXI_arregion[3:0];
  assign m00_couplers_to_auto_cc_ARSIZE = S_AXI_arsize[2:0];
  assign m00_couplers_to_auto_cc_ARVALID = S_AXI_arvalid;
  assign m00_couplers_to_auto_cc_AWADDR = S_AXI_awaddr[63:0];
  assign m00_couplers_to_auto_cc_AWBURST = S_AXI_awburst[1:0];
  assign m00_couplers_to_auto_cc_AWCACHE = S_AXI_awcache[3:0];
  assign m00_couplers_to_auto_cc_AWID = S_AXI_awid[5:0];
  assign m00_couplers_to_auto_cc_AWLEN = S_AXI_awlen[7:0];
  assign m00_couplers_to_auto_cc_AWLOCK = S_AXI_awlock[0];
  assign m00_couplers_to_auto_cc_AWPROT = S_AXI_awprot[2:0];
  assign m00_couplers_to_auto_cc_AWQOS = S_AXI_awqos[3:0];
  assign m00_couplers_to_auto_cc_AWREGION = S_AXI_awregion[3:0];
  assign m00_couplers_to_auto_cc_AWSIZE = S_AXI_awsize[2:0];
  assign m00_couplers_to_auto_cc_AWVALID = S_AXI_awvalid;
  assign m00_couplers_to_auto_cc_BREADY = S_AXI_bready;
  assign m00_couplers_to_auto_cc_RREADY = S_AXI_rready;
  assign m00_couplers_to_auto_cc_WDATA = S_AXI_wdata[511:0];
  assign m00_couplers_to_auto_cc_WLAST = S_AXI_wlast;
  assign m00_couplers_to_auto_cc_WSTRB = S_AXI_wstrb[63:0];
  assign m00_couplers_to_auto_cc_WVALID = S_AXI_wvalid;
  assign m00_regslice_to_m00_couplers_ARREADY = M_AXI_arready;
  assign m00_regslice_to_m00_couplers_AWREADY = M_AXI_awready;
  assign m00_regslice_to_m00_couplers_BRESP = M_AXI_bresp[1:0];
  assign m00_regslice_to_m00_couplers_BVALID = M_AXI_bvalid;
  assign m00_regslice_to_m00_couplers_RDATA = M_AXI_rdata[63:0];
  assign m00_regslice_to_m00_couplers_RRESP = M_AXI_rresp[1:0];
  assign m00_regslice_to_m00_couplers_RVALID = M_AXI_rvalid;
  assign m00_regslice_to_m00_couplers_WREADY = M_AXI_wready;
  design_ctrl_auto_cc_0 auto_cc
       (.m_axi_aclk(M_ACLK_1),
        .m_axi_araddr(auto_cc_to_auto_ds_ARADDR),
        .m_axi_arburst(auto_cc_to_auto_ds_ARBURST),
        .m_axi_arcache(auto_cc_to_auto_ds_ARCACHE),
        .m_axi_aresetn(M_ARESETN_1),
        .m_axi_arid(auto_cc_to_auto_ds_ARID),
        .m_axi_arlen(auto_cc_to_auto_ds_ARLEN),
        .m_axi_arlock(auto_cc_to_auto_ds_ARLOCK),
        .m_axi_arprot(auto_cc_to_auto_ds_ARPROT),
        .m_axi_arqos(auto_cc_to_auto_ds_ARQOS),
        .m_axi_arready(auto_cc_to_auto_ds_ARREADY),
        .m_axi_arregion(auto_cc_to_auto_ds_ARREGION),
        .m_axi_arsize(auto_cc_to_auto_ds_ARSIZE),
        .m_axi_arvalid(auto_cc_to_auto_ds_ARVALID),
        .m_axi_awaddr(auto_cc_to_auto_ds_AWADDR),
        .m_axi_awburst(auto_cc_to_auto_ds_AWBURST),
        .m_axi_awcache(auto_cc_to_auto_ds_AWCACHE),
        .m_axi_awid(auto_cc_to_auto_ds_AWID),
        .m_axi_awlen(auto_cc_to_auto_ds_AWLEN),
        .m_axi_awlock(auto_cc_to_auto_ds_AWLOCK),
        .m_axi_awprot(auto_cc_to_auto_ds_AWPROT),
        .m_axi_awqos(auto_cc_to_auto_ds_AWQOS),
        .m_axi_awready(auto_cc_to_auto_ds_AWREADY),
        .m_axi_awregion(auto_cc_to_auto_ds_AWREGION),
        .m_axi_awsize(auto_cc_to_auto_ds_AWSIZE),
        .m_axi_awvalid(auto_cc_to_auto_ds_AWVALID),
        .m_axi_bid(auto_cc_to_auto_ds_BID),
        .m_axi_bready(auto_cc_to_auto_ds_BREADY),
        .m_axi_bresp(auto_cc_to_auto_ds_BRESP),
        .m_axi_bvalid(auto_cc_to_auto_ds_BVALID),
        .m_axi_rdata(auto_cc_to_auto_ds_RDATA),
        .m_axi_rid(auto_cc_to_auto_ds_RID),
        .m_axi_rlast(auto_cc_to_auto_ds_RLAST),
        .m_axi_rready(auto_cc_to_auto_ds_RREADY),
        .m_axi_rresp(auto_cc_to_auto_ds_RRESP),
        .m_axi_rvalid(auto_cc_to_auto_ds_RVALID),
        .m_axi_wdata(auto_cc_to_auto_ds_WDATA),
        .m_axi_wlast(auto_cc_to_auto_ds_WLAST),
        .m_axi_wready(auto_cc_to_auto_ds_WREADY),
        .m_axi_wstrb(auto_cc_to_auto_ds_WSTRB),
        .m_axi_wvalid(auto_cc_to_auto_ds_WVALID),
        .s_axi_aclk(S_ACLK_1),
        .s_axi_araddr(m00_couplers_to_auto_cc_ARADDR),
        .s_axi_arburst(m00_couplers_to_auto_cc_ARBURST),
        .s_axi_arcache(m00_couplers_to_auto_cc_ARCACHE),
        .s_axi_aresetn(S_ARESETN_1),
        .s_axi_arid(m00_couplers_to_auto_cc_ARID),
        .s_axi_arlen(m00_couplers_to_auto_cc_ARLEN),
        .s_axi_arlock(m00_couplers_to_auto_cc_ARLOCK),
        .s_axi_arprot(m00_couplers_to_auto_cc_ARPROT),
        .s_axi_arqos(m00_couplers_to_auto_cc_ARQOS),
        .s_axi_arready(m00_couplers_to_auto_cc_ARREADY),
        .s_axi_arregion(m00_couplers_to_auto_cc_ARREGION),
        .s_axi_arsize(m00_couplers_to_auto_cc_ARSIZE),
        .s_axi_arvalid(m00_couplers_to_auto_cc_ARVALID),
        .s_axi_awaddr(m00_couplers_to_auto_cc_AWADDR),
        .s_axi_awburst(m00_couplers_to_auto_cc_AWBURST),
        .s_axi_awcache(m00_couplers_to_auto_cc_AWCACHE),
        .s_axi_awid(m00_couplers_to_auto_cc_AWID),
        .s_axi_awlen(m00_couplers_to_auto_cc_AWLEN),
        .s_axi_awlock(m00_couplers_to_auto_cc_AWLOCK),
        .s_axi_awprot(m00_couplers_to_auto_cc_AWPROT),
        .s_axi_awqos(m00_couplers_to_auto_cc_AWQOS),
        .s_axi_awready(m00_couplers_to_auto_cc_AWREADY),
        .s_axi_awregion(m00_couplers_to_auto_cc_AWREGION),
        .s_axi_awsize(m00_couplers_to_auto_cc_AWSIZE),
        .s_axi_awvalid(m00_couplers_to_auto_cc_AWVALID),
        .s_axi_bid(m00_couplers_to_auto_cc_BID),
        .s_axi_bready(m00_couplers_to_auto_cc_BREADY),
        .s_axi_bresp(m00_couplers_to_auto_cc_BRESP),
        .s_axi_bvalid(m00_couplers_to_auto_cc_BVALID),
        .s_axi_rdata(m00_couplers_to_auto_cc_RDATA),
        .s_axi_rid(m00_couplers_to_auto_cc_RID),
        .s_axi_rlast(m00_couplers_to_auto_cc_RLAST),
        .s_axi_rready(m00_couplers_to_auto_cc_RREADY),
        .s_axi_rresp(m00_couplers_to_auto_cc_RRESP),
        .s_axi_rvalid(m00_couplers_to_auto_cc_RVALID),
        .s_axi_wdata(m00_couplers_to_auto_cc_WDATA),
        .s_axi_wlast(m00_couplers_to_auto_cc_WLAST),
        .s_axi_wready(m00_couplers_to_auto_cc_WREADY),
        .s_axi_wstrb(m00_couplers_to_auto_cc_WSTRB),
        .s_axi_wvalid(m00_couplers_to_auto_cc_WVALID));
  design_ctrl_auto_ds_0 auto_ds
       (.m_axi_araddr(auto_ds_to_auto_rs_ARADDR),
        .m_axi_arburst(auto_ds_to_auto_rs_ARBURST),
        .m_axi_arcache(auto_ds_to_auto_rs_ARCACHE),
        .m_axi_arlen(auto_ds_to_auto_rs_ARLEN),
        .m_axi_arlock(auto_ds_to_auto_rs_ARLOCK),
        .m_axi_arprot(auto_ds_to_auto_rs_ARPROT),
        .m_axi_arqos(auto_ds_to_auto_rs_ARQOS),
        .m_axi_arready(auto_ds_to_auto_rs_ARREADY),
        .m_axi_arregion(auto_ds_to_auto_rs_ARREGION),
        .m_axi_arsize(auto_ds_to_auto_rs_ARSIZE),
        .m_axi_arvalid(auto_ds_to_auto_rs_ARVALID),
        .m_axi_awaddr(auto_ds_to_auto_rs_AWADDR),
        .m_axi_awburst(auto_ds_to_auto_rs_AWBURST),
        .m_axi_awcache(auto_ds_to_auto_rs_AWCACHE),
        .m_axi_awlen(auto_ds_to_auto_rs_AWLEN),
        .m_axi_awlock(auto_ds_to_auto_rs_AWLOCK),
        .m_axi_awprot(auto_ds_to_auto_rs_AWPROT),
        .m_axi_awqos(auto_ds_to_auto_rs_AWQOS),
        .m_axi_awready(auto_ds_to_auto_rs_AWREADY),
        .m_axi_awregion(auto_ds_to_auto_rs_AWREGION),
        .m_axi_awsize(auto_ds_to_auto_rs_AWSIZE),
        .m_axi_awvalid(auto_ds_to_auto_rs_AWVALID),
        .m_axi_bready(auto_ds_to_auto_rs_BREADY),
        .m_axi_bresp(auto_ds_to_auto_rs_BRESP),
        .m_axi_bvalid(auto_ds_to_auto_rs_BVALID),
        .m_axi_rdata(auto_ds_to_auto_rs_RDATA),
        .m_axi_rlast(auto_ds_to_auto_rs_RLAST),
        .m_axi_rready(auto_ds_to_auto_rs_RREADY),
        .m_axi_rresp(auto_ds_to_auto_rs_RRESP),
        .m_axi_rvalid(auto_ds_to_auto_rs_RVALID),
        .m_axi_wdata(auto_ds_to_auto_rs_WDATA),
        .m_axi_wlast(auto_ds_to_auto_rs_WLAST),
        .m_axi_wready(auto_ds_to_auto_rs_WREADY),
        .m_axi_wstrb(auto_ds_to_auto_rs_WSTRB),
        .m_axi_wvalid(auto_ds_to_auto_rs_WVALID),
        .s_axi_aclk(M_ACLK_1),
        .s_axi_araddr(auto_cc_to_auto_ds_ARADDR),
        .s_axi_arburst(auto_cc_to_auto_ds_ARBURST),
        .s_axi_arcache(auto_cc_to_auto_ds_ARCACHE),
        .s_axi_aresetn(M_ARESETN_1),
        .s_axi_arid(auto_cc_to_auto_ds_ARID),
        .s_axi_arlen(auto_cc_to_auto_ds_ARLEN),
        .s_axi_arlock(auto_cc_to_auto_ds_ARLOCK),
        .s_axi_arprot(auto_cc_to_auto_ds_ARPROT),
        .s_axi_arqos(auto_cc_to_auto_ds_ARQOS),
        .s_axi_arready(auto_cc_to_auto_ds_ARREADY),
        .s_axi_arregion(auto_cc_to_auto_ds_ARREGION),
        .s_axi_arsize(auto_cc_to_auto_ds_ARSIZE),
        .s_axi_arvalid(auto_cc_to_auto_ds_ARVALID),
        .s_axi_awaddr(auto_cc_to_auto_ds_AWADDR),
        .s_axi_awburst(auto_cc_to_auto_ds_AWBURST),
        .s_axi_awcache(auto_cc_to_auto_ds_AWCACHE),
        .s_axi_awid(auto_cc_to_auto_ds_AWID),
        .s_axi_awlen(auto_cc_to_auto_ds_AWLEN),
        .s_axi_awlock(auto_cc_to_auto_ds_AWLOCK),
        .s_axi_awprot(auto_cc_to_auto_ds_AWPROT),
        .s_axi_awqos(auto_cc_to_auto_ds_AWQOS),
        .s_axi_awready(auto_cc_to_auto_ds_AWREADY),
        .s_axi_awregion(auto_cc_to_auto_ds_AWREGION),
        .s_axi_awsize(auto_cc_to_auto_ds_AWSIZE),
        .s_axi_awvalid(auto_cc_to_auto_ds_AWVALID),
        .s_axi_bid(auto_cc_to_auto_ds_BID),
        .s_axi_bready(auto_cc_to_auto_ds_BREADY),
        .s_axi_bresp(auto_cc_to_auto_ds_BRESP),
        .s_axi_bvalid(auto_cc_to_auto_ds_BVALID),
        .s_axi_rdata(auto_cc_to_auto_ds_RDATA),
        .s_axi_rid(auto_cc_to_auto_ds_RID),
        .s_axi_rlast(auto_cc_to_auto_ds_RLAST),
        .s_axi_rready(auto_cc_to_auto_ds_RREADY),
        .s_axi_rresp(auto_cc_to_auto_ds_RRESP),
        .s_axi_rvalid(auto_cc_to_auto_ds_RVALID),
        .s_axi_wdata(auto_cc_to_auto_ds_WDATA),
        .s_axi_wlast(auto_cc_to_auto_ds_WLAST),
        .s_axi_wready(auto_cc_to_auto_ds_WREADY),
        .s_axi_wstrb(auto_cc_to_auto_ds_WSTRB),
        .s_axi_wvalid(auto_cc_to_auto_ds_WVALID));
  design_ctrl_auto_pc_0 auto_pc
       (.aclk(M_ACLK_1),
        .aresetn(M_ARESETN_1),
        .m_axi_araddr(auto_pc_to_m00_regslice_ARADDR),
        .m_axi_arprot(auto_pc_to_m00_regslice_ARPROT),
        .m_axi_arready(auto_pc_to_m00_regslice_ARREADY),
        .m_axi_arvalid(auto_pc_to_m00_regslice_ARVALID),
        .m_axi_awaddr(auto_pc_to_m00_regslice_AWADDR),
        .m_axi_awprot(auto_pc_to_m00_regslice_AWPROT),
        .m_axi_awready(auto_pc_to_m00_regslice_AWREADY),
        .m_axi_awvalid(auto_pc_to_m00_regslice_AWVALID),
        .m_axi_bready(auto_pc_to_m00_regslice_BREADY),
        .m_axi_bresp(auto_pc_to_m00_regslice_BRESP),
        .m_axi_bvalid(auto_pc_to_m00_regslice_BVALID),
        .m_axi_rdata(auto_pc_to_m00_regslice_RDATA),
        .m_axi_rready(auto_pc_to_m00_regslice_RREADY),
        .m_axi_rresp(auto_pc_to_m00_regslice_RRESP),
        .m_axi_rvalid(auto_pc_to_m00_regslice_RVALID),
        .m_axi_wdata(auto_pc_to_m00_regslice_WDATA),
        .m_axi_wready(auto_pc_to_m00_regslice_WREADY),
        .m_axi_wstrb(auto_pc_to_m00_regslice_WSTRB),
        .m_axi_wvalid(auto_pc_to_m00_regslice_WVALID),
        .s_axi_araddr(auto_rs_to_auto_pc_ARADDR),
        .s_axi_arburst(auto_rs_to_auto_pc_ARBURST),
        .s_axi_arcache(auto_rs_to_auto_pc_ARCACHE),
        .s_axi_arlen(auto_rs_to_auto_pc_ARLEN),
        .s_axi_arlock(auto_rs_to_auto_pc_ARLOCK),
        .s_axi_arprot(auto_rs_to_auto_pc_ARPROT),
        .s_axi_arqos(auto_rs_to_auto_pc_ARQOS),
        .s_axi_arready(auto_rs_to_auto_pc_ARREADY),
        .s_axi_arregion(auto_rs_to_auto_pc_ARREGION),
        .s_axi_arsize(auto_rs_to_auto_pc_ARSIZE),
        .s_axi_arvalid(auto_rs_to_auto_pc_ARVALID),
        .s_axi_awaddr(auto_rs_to_auto_pc_AWADDR),
        .s_axi_awburst(auto_rs_to_auto_pc_AWBURST),
        .s_axi_awcache(auto_rs_to_auto_pc_AWCACHE),
        .s_axi_awlen(auto_rs_to_auto_pc_AWLEN),
        .s_axi_awlock(auto_rs_to_auto_pc_AWLOCK),
        .s_axi_awprot(auto_rs_to_auto_pc_AWPROT),
        .s_axi_awqos(auto_rs_to_auto_pc_AWQOS),
        .s_axi_awready(auto_rs_to_auto_pc_AWREADY),
        .s_axi_awregion(auto_rs_to_auto_pc_AWREGION),
        .s_axi_awsize(auto_rs_to_auto_pc_AWSIZE),
        .s_axi_awvalid(auto_rs_to_auto_pc_AWVALID),
        .s_axi_bready(auto_rs_to_auto_pc_BREADY),
        .s_axi_bresp(auto_rs_to_auto_pc_BRESP),
        .s_axi_bvalid(auto_rs_to_auto_pc_BVALID),
        .s_axi_rdata(auto_rs_to_auto_pc_RDATA),
        .s_axi_rlast(auto_rs_to_auto_pc_RLAST),
        .s_axi_rready(auto_rs_to_auto_pc_RREADY),
        .s_axi_rresp(auto_rs_to_auto_pc_RRESP),
        .s_axi_rvalid(auto_rs_to_auto_pc_RVALID),
        .s_axi_wdata(auto_rs_to_auto_pc_WDATA),
        .s_axi_wlast(auto_rs_to_auto_pc_WLAST),
        .s_axi_wready(auto_rs_to_auto_pc_WREADY),
        .s_axi_wstrb(auto_rs_to_auto_pc_WSTRB),
        .s_axi_wvalid(auto_rs_to_auto_pc_WVALID));
  design_ctrl_auto_rs_0 auto_rs
       (.aclk(M_ACLK_1),
        .aresetn(M_ARESETN_1),
        .m_axi_araddr(auto_rs_to_auto_pc_ARADDR),
        .m_axi_arburst(auto_rs_to_auto_pc_ARBURST),
        .m_axi_arcache(auto_rs_to_auto_pc_ARCACHE),
        .m_axi_arlen(auto_rs_to_auto_pc_ARLEN),
        .m_axi_arlock(auto_rs_to_auto_pc_ARLOCK),
        .m_axi_arprot(auto_rs_to_auto_pc_ARPROT),
        .m_axi_arqos(auto_rs_to_auto_pc_ARQOS),
        .m_axi_arready(auto_rs_to_auto_pc_ARREADY),
        .m_axi_arregion(auto_rs_to_auto_pc_ARREGION),
        .m_axi_arsize(auto_rs_to_auto_pc_ARSIZE),
        .m_axi_arvalid(auto_rs_to_auto_pc_ARVALID),
        .m_axi_awaddr(auto_rs_to_auto_pc_AWADDR),
        .m_axi_awburst(auto_rs_to_auto_pc_AWBURST),
        .m_axi_awcache(auto_rs_to_auto_pc_AWCACHE),
        .m_axi_awlen(auto_rs_to_auto_pc_AWLEN),
        .m_axi_awlock(auto_rs_to_auto_pc_AWLOCK),
        .m_axi_awprot(auto_rs_to_auto_pc_AWPROT),
        .m_axi_awqos(auto_rs_to_auto_pc_AWQOS),
        .m_axi_awready(auto_rs_to_auto_pc_AWREADY),
        .m_axi_awregion(auto_rs_to_auto_pc_AWREGION),
        .m_axi_awsize(auto_rs_to_auto_pc_AWSIZE),
        .m_axi_awvalid(auto_rs_to_auto_pc_AWVALID),
        .m_axi_bready(auto_rs_to_auto_pc_BREADY),
        .m_axi_bresp(auto_rs_to_auto_pc_BRESP),
        .m_axi_bvalid(auto_rs_to_auto_pc_BVALID),
        .m_axi_rdata(auto_rs_to_auto_pc_RDATA),
        .m_axi_rlast(auto_rs_to_auto_pc_RLAST),
        .m_axi_rready(auto_rs_to_auto_pc_RREADY),
        .m_axi_rresp(auto_rs_to_auto_pc_RRESP),
        .m_axi_rvalid(auto_rs_to_auto_pc_RVALID),
        .m_axi_wdata(auto_rs_to_auto_pc_WDATA),
        .m_axi_wlast(auto_rs_to_auto_pc_WLAST),
        .m_axi_wready(auto_rs_to_auto_pc_WREADY),
        .m_axi_wstrb(auto_rs_to_auto_pc_WSTRB),
        .m_axi_wvalid(auto_rs_to_auto_pc_WVALID),
        .s_axi_araddr(auto_ds_to_auto_rs_ARADDR),
        .s_axi_arburst(auto_ds_to_auto_rs_ARBURST),
        .s_axi_arcache(auto_ds_to_auto_rs_ARCACHE),
        .s_axi_arlen(auto_ds_to_auto_rs_ARLEN),
        .s_axi_arlock(auto_ds_to_auto_rs_ARLOCK),
        .s_axi_arprot(auto_ds_to_auto_rs_ARPROT),
        .s_axi_arqos(auto_ds_to_auto_rs_ARQOS),
        .s_axi_arready(auto_ds_to_auto_rs_ARREADY),
        .s_axi_arregion(auto_ds_to_auto_rs_ARREGION),
        .s_axi_arsize(auto_ds_to_auto_rs_ARSIZE),
        .s_axi_arvalid(auto_ds_to_auto_rs_ARVALID),
        .s_axi_awaddr(auto_ds_to_auto_rs_AWADDR),
        .s_axi_awburst(auto_ds_to_auto_rs_AWBURST),
        .s_axi_awcache(auto_ds_to_auto_rs_AWCACHE),
        .s_axi_awlen(auto_ds_to_auto_rs_AWLEN),
        .s_axi_awlock(auto_ds_to_auto_rs_AWLOCK),
        .s_axi_awprot(auto_ds_to_auto_rs_AWPROT),
        .s_axi_awqos(auto_ds_to_auto_rs_AWQOS),
        .s_axi_awready(auto_ds_to_auto_rs_AWREADY),
        .s_axi_awregion(auto_ds_to_auto_rs_AWREGION),
        .s_axi_awsize(auto_ds_to_auto_rs_AWSIZE),
        .s_axi_awvalid(auto_ds_to_auto_rs_AWVALID),
        .s_axi_bready(auto_ds_to_auto_rs_BREADY),
        .s_axi_bresp(auto_ds_to_auto_rs_BRESP),
        .s_axi_bvalid(auto_ds_to_auto_rs_BVALID),
        .s_axi_rdata(auto_ds_to_auto_rs_RDATA),
        .s_axi_rlast(auto_ds_to_auto_rs_RLAST),
        .s_axi_rready(auto_ds_to_auto_rs_RREADY),
        .s_axi_rresp(auto_ds_to_auto_rs_RRESP),
        .s_axi_rvalid(auto_ds_to_auto_rs_RVALID),
        .s_axi_wdata(auto_ds_to_auto_rs_WDATA),
        .s_axi_wlast(auto_ds_to_auto_rs_WLAST),
        .s_axi_wready(auto_ds_to_auto_rs_WREADY),
        .s_axi_wstrb(auto_ds_to_auto_rs_WSTRB),
        .s_axi_wvalid(auto_ds_to_auto_rs_WVALID));
  design_ctrl_m00_regslice_0 m00_regslice
       (.aclk(M_ACLK_1),
        .aresetn(M_ARESETN_1),
        .m_axi_araddr(m00_regslice_to_m00_couplers_ARADDR),
        .m_axi_arprot(m00_regslice_to_m00_couplers_ARPROT),
        .m_axi_arready(m00_regslice_to_m00_couplers_ARREADY),
        .m_axi_arvalid(m00_regslice_to_m00_couplers_ARVALID),
        .m_axi_awaddr(m00_regslice_to_m00_couplers_AWADDR),
        .m_axi_awprot(m00_regslice_to_m00_couplers_AWPROT),
        .m_axi_awready(m00_regslice_to_m00_couplers_AWREADY),
        .m_axi_awvalid(m00_regslice_to_m00_couplers_AWVALID),
        .m_axi_bready(m00_regslice_to_m00_couplers_BREADY),
        .m_axi_bresp(m00_regslice_to_m00_couplers_BRESP),
        .m_axi_bvalid(m00_regslice_to_m00_couplers_BVALID),
        .m_axi_rdata(m00_regslice_to_m00_couplers_RDATA),
        .m_axi_rready(m00_regslice_to_m00_couplers_RREADY),
        .m_axi_rresp(m00_regslice_to_m00_couplers_RRESP),
        .m_axi_rvalid(m00_regslice_to_m00_couplers_RVALID),
        .m_axi_wdata(m00_regslice_to_m00_couplers_WDATA),
        .m_axi_wready(m00_regslice_to_m00_couplers_WREADY),
        .m_axi_wstrb(m00_regslice_to_m00_couplers_WSTRB),
        .m_axi_wvalid(m00_regslice_to_m00_couplers_WVALID),
        .s_axi_araddr(auto_pc_to_m00_regslice_ARADDR),
        .s_axi_arprot(auto_pc_to_m00_regslice_ARPROT),
        .s_axi_arready(auto_pc_to_m00_regslice_ARREADY),
        .s_axi_arvalid(auto_pc_to_m00_regslice_ARVALID),
        .s_axi_awaddr(auto_pc_to_m00_regslice_AWADDR),
        .s_axi_awprot(auto_pc_to_m00_regslice_AWPROT),
        .s_axi_awready(auto_pc_to_m00_regslice_AWREADY),
        .s_axi_awvalid(auto_pc_to_m00_regslice_AWVALID),
        .s_axi_bready(auto_pc_to_m00_regslice_BREADY),
        .s_axi_bresp(auto_pc_to_m00_regslice_BRESP),
        .s_axi_bvalid(auto_pc_to_m00_regslice_BVALID),
        .s_axi_rdata(auto_pc_to_m00_regslice_RDATA),
        .s_axi_rready(auto_pc_to_m00_regslice_RREADY),
        .s_axi_rresp(auto_pc_to_m00_regslice_RRESP),
        .s_axi_rvalid(auto_pc_to_m00_regslice_RVALID),
        .s_axi_wdata(auto_pc_to_m00_regslice_WDATA),
        .s_axi_wready(auto_pc_to_m00_regslice_WREADY),
        .s_axi_wstrb(auto_pc_to_m00_regslice_WSTRB),
        .s_axi_wvalid(auto_pc_to_m00_regslice_WVALID));
endmodule

module m01_couplers_imp_8UHLLB
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arprot,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awprot,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arburst,
    S_AXI_arcache,
    S_AXI_arid,
    S_AXI_arlen,
    S_AXI_arlock,
    S_AXI_arprot,
    S_AXI_arqos,
    S_AXI_arready,
    S_AXI_arregion,
    S_AXI_arsize,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awburst,
    S_AXI_awcache,
    S_AXI_awid,
    S_AXI_awlen,
    S_AXI_awlock,
    S_AXI_awprot,
    S_AXI_awqos,
    S_AXI_awready,
    S_AXI_awregion,
    S_AXI_awsize,
    S_AXI_awvalid,
    S_AXI_bid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rid,
    S_AXI_rlast,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wlast,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [63:0]M_AXI_araddr;
  output [2:0]M_AXI_arprot;
  input M_AXI_arready;
  output M_AXI_arvalid;
  output [63:0]M_AXI_awaddr;
  output [2:0]M_AXI_awprot;
  input M_AXI_awready;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [63:0]M_AXI_rdata;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [63:0]M_AXI_wdata;
  input M_AXI_wready;
  output [7:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [63:0]S_AXI_araddr;
  input [1:0]S_AXI_arburst;
  input [3:0]S_AXI_arcache;
  input [5:0]S_AXI_arid;
  input [7:0]S_AXI_arlen;
  input [0:0]S_AXI_arlock;
  input [2:0]S_AXI_arprot;
  input [3:0]S_AXI_arqos;
  output S_AXI_arready;
  input [3:0]S_AXI_arregion;
  input [2:0]S_AXI_arsize;
  input S_AXI_arvalid;
  input [63:0]S_AXI_awaddr;
  input [1:0]S_AXI_awburst;
  input [3:0]S_AXI_awcache;
  input [5:0]S_AXI_awid;
  input [7:0]S_AXI_awlen;
  input [0:0]S_AXI_awlock;
  input [2:0]S_AXI_awprot;
  input [3:0]S_AXI_awqos;
  output S_AXI_awready;
  input [3:0]S_AXI_awregion;
  input [2:0]S_AXI_awsize;
  input S_AXI_awvalid;
  output [5:0]S_AXI_bid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [511:0]S_AXI_rdata;
  output [5:0]S_AXI_rid;
  output S_AXI_rlast;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [511:0]S_AXI_wdata;
  input S_AXI_wlast;
  output S_AXI_wready;
  input [63:0]S_AXI_wstrb;
  input S_AXI_wvalid;

  wire M_ACLK_1;
  wire M_ARESETN_1;
  wire S_ACLK_1;
  wire S_ARESETN_1;
  wire [63:0]auto_cc_to_auto_ds_ARADDR;
  wire [1:0]auto_cc_to_auto_ds_ARBURST;
  wire [3:0]auto_cc_to_auto_ds_ARCACHE;
  wire [5:0]auto_cc_to_auto_ds_ARID;
  wire [7:0]auto_cc_to_auto_ds_ARLEN;
  wire [0:0]auto_cc_to_auto_ds_ARLOCK;
  wire [2:0]auto_cc_to_auto_ds_ARPROT;
  wire [3:0]auto_cc_to_auto_ds_ARQOS;
  wire auto_cc_to_auto_ds_ARREADY;
  wire [3:0]auto_cc_to_auto_ds_ARREGION;
  wire [2:0]auto_cc_to_auto_ds_ARSIZE;
  wire auto_cc_to_auto_ds_ARVALID;
  wire [63:0]auto_cc_to_auto_ds_AWADDR;
  wire [1:0]auto_cc_to_auto_ds_AWBURST;
  wire [3:0]auto_cc_to_auto_ds_AWCACHE;
  wire [5:0]auto_cc_to_auto_ds_AWID;
  wire [7:0]auto_cc_to_auto_ds_AWLEN;
  wire [0:0]auto_cc_to_auto_ds_AWLOCK;
  wire [2:0]auto_cc_to_auto_ds_AWPROT;
  wire [3:0]auto_cc_to_auto_ds_AWQOS;
  wire auto_cc_to_auto_ds_AWREADY;
  wire [3:0]auto_cc_to_auto_ds_AWREGION;
  wire [2:0]auto_cc_to_auto_ds_AWSIZE;
  wire auto_cc_to_auto_ds_AWVALID;
  wire [5:0]auto_cc_to_auto_ds_BID;
  wire auto_cc_to_auto_ds_BREADY;
  wire [1:0]auto_cc_to_auto_ds_BRESP;
  wire auto_cc_to_auto_ds_BVALID;
  wire [511:0]auto_cc_to_auto_ds_RDATA;
  wire [5:0]auto_cc_to_auto_ds_RID;
  wire auto_cc_to_auto_ds_RLAST;
  wire auto_cc_to_auto_ds_RREADY;
  wire [1:0]auto_cc_to_auto_ds_RRESP;
  wire auto_cc_to_auto_ds_RVALID;
  wire [511:0]auto_cc_to_auto_ds_WDATA;
  wire auto_cc_to_auto_ds_WLAST;
  wire auto_cc_to_auto_ds_WREADY;
  wire [63:0]auto_cc_to_auto_ds_WSTRB;
  wire auto_cc_to_auto_ds_WVALID;
  wire [63:0]auto_ds_to_auto_rs_ARADDR;
  wire [1:0]auto_ds_to_auto_rs_ARBURST;
  wire [3:0]auto_ds_to_auto_rs_ARCACHE;
  wire [7:0]auto_ds_to_auto_rs_ARLEN;
  wire [0:0]auto_ds_to_auto_rs_ARLOCK;
  wire [2:0]auto_ds_to_auto_rs_ARPROT;
  wire [3:0]auto_ds_to_auto_rs_ARQOS;
  wire auto_ds_to_auto_rs_ARREADY;
  wire [3:0]auto_ds_to_auto_rs_ARREGION;
  wire [2:0]auto_ds_to_auto_rs_ARSIZE;
  wire auto_ds_to_auto_rs_ARVALID;
  wire [63:0]auto_ds_to_auto_rs_AWADDR;
  wire [1:0]auto_ds_to_auto_rs_AWBURST;
  wire [3:0]auto_ds_to_auto_rs_AWCACHE;
  wire [7:0]auto_ds_to_auto_rs_AWLEN;
  wire [0:0]auto_ds_to_auto_rs_AWLOCK;
  wire [2:0]auto_ds_to_auto_rs_AWPROT;
  wire [3:0]auto_ds_to_auto_rs_AWQOS;
  wire auto_ds_to_auto_rs_AWREADY;
  wire [3:0]auto_ds_to_auto_rs_AWREGION;
  wire [2:0]auto_ds_to_auto_rs_AWSIZE;
  wire auto_ds_to_auto_rs_AWVALID;
  wire auto_ds_to_auto_rs_BREADY;
  wire [1:0]auto_ds_to_auto_rs_BRESP;
  wire auto_ds_to_auto_rs_BVALID;
  wire [63:0]auto_ds_to_auto_rs_RDATA;
  wire auto_ds_to_auto_rs_RLAST;
  wire auto_ds_to_auto_rs_RREADY;
  wire [1:0]auto_ds_to_auto_rs_RRESP;
  wire auto_ds_to_auto_rs_RVALID;
  wire [63:0]auto_ds_to_auto_rs_WDATA;
  wire auto_ds_to_auto_rs_WLAST;
  wire auto_ds_to_auto_rs_WREADY;
  wire [7:0]auto_ds_to_auto_rs_WSTRB;
  wire auto_ds_to_auto_rs_WVALID;
  wire [63:0]auto_pc_to_m01_regslice_ARADDR;
  wire [2:0]auto_pc_to_m01_regslice_ARPROT;
  wire auto_pc_to_m01_regslice_ARREADY;
  wire auto_pc_to_m01_regslice_ARVALID;
  wire [63:0]auto_pc_to_m01_regslice_AWADDR;
  wire [2:0]auto_pc_to_m01_regslice_AWPROT;
  wire auto_pc_to_m01_regslice_AWREADY;
  wire auto_pc_to_m01_regslice_AWVALID;
  wire auto_pc_to_m01_regslice_BREADY;
  wire [1:0]auto_pc_to_m01_regslice_BRESP;
  wire auto_pc_to_m01_regslice_BVALID;
  wire [63:0]auto_pc_to_m01_regslice_RDATA;
  wire auto_pc_to_m01_regslice_RREADY;
  wire [1:0]auto_pc_to_m01_regslice_RRESP;
  wire auto_pc_to_m01_regslice_RVALID;
  wire [63:0]auto_pc_to_m01_regslice_WDATA;
  wire auto_pc_to_m01_regslice_WREADY;
  wire [7:0]auto_pc_to_m01_regslice_WSTRB;
  wire auto_pc_to_m01_regslice_WVALID;
  wire [63:0]auto_rs_to_auto_pc_ARADDR;
  wire [1:0]auto_rs_to_auto_pc_ARBURST;
  wire [3:0]auto_rs_to_auto_pc_ARCACHE;
  wire [7:0]auto_rs_to_auto_pc_ARLEN;
  wire [0:0]auto_rs_to_auto_pc_ARLOCK;
  wire [2:0]auto_rs_to_auto_pc_ARPROT;
  wire [3:0]auto_rs_to_auto_pc_ARQOS;
  wire auto_rs_to_auto_pc_ARREADY;
  wire [3:0]auto_rs_to_auto_pc_ARREGION;
  wire [2:0]auto_rs_to_auto_pc_ARSIZE;
  wire auto_rs_to_auto_pc_ARVALID;
  wire [63:0]auto_rs_to_auto_pc_AWADDR;
  wire [1:0]auto_rs_to_auto_pc_AWBURST;
  wire [3:0]auto_rs_to_auto_pc_AWCACHE;
  wire [7:0]auto_rs_to_auto_pc_AWLEN;
  wire [0:0]auto_rs_to_auto_pc_AWLOCK;
  wire [2:0]auto_rs_to_auto_pc_AWPROT;
  wire [3:0]auto_rs_to_auto_pc_AWQOS;
  wire auto_rs_to_auto_pc_AWREADY;
  wire [3:0]auto_rs_to_auto_pc_AWREGION;
  wire [2:0]auto_rs_to_auto_pc_AWSIZE;
  wire auto_rs_to_auto_pc_AWVALID;
  wire auto_rs_to_auto_pc_BREADY;
  wire [1:0]auto_rs_to_auto_pc_BRESP;
  wire auto_rs_to_auto_pc_BVALID;
  wire [63:0]auto_rs_to_auto_pc_RDATA;
  wire auto_rs_to_auto_pc_RLAST;
  wire auto_rs_to_auto_pc_RREADY;
  wire [1:0]auto_rs_to_auto_pc_RRESP;
  wire auto_rs_to_auto_pc_RVALID;
  wire [63:0]auto_rs_to_auto_pc_WDATA;
  wire auto_rs_to_auto_pc_WLAST;
  wire auto_rs_to_auto_pc_WREADY;
  wire [7:0]auto_rs_to_auto_pc_WSTRB;
  wire auto_rs_to_auto_pc_WVALID;
  wire [63:0]m01_couplers_to_auto_cc_ARADDR;
  wire [1:0]m01_couplers_to_auto_cc_ARBURST;
  wire [3:0]m01_couplers_to_auto_cc_ARCACHE;
  wire [5:0]m01_couplers_to_auto_cc_ARID;
  wire [7:0]m01_couplers_to_auto_cc_ARLEN;
  wire [0:0]m01_couplers_to_auto_cc_ARLOCK;
  wire [2:0]m01_couplers_to_auto_cc_ARPROT;
  wire [3:0]m01_couplers_to_auto_cc_ARQOS;
  wire m01_couplers_to_auto_cc_ARREADY;
  wire [3:0]m01_couplers_to_auto_cc_ARREGION;
  wire [2:0]m01_couplers_to_auto_cc_ARSIZE;
  wire m01_couplers_to_auto_cc_ARVALID;
  wire [63:0]m01_couplers_to_auto_cc_AWADDR;
  wire [1:0]m01_couplers_to_auto_cc_AWBURST;
  wire [3:0]m01_couplers_to_auto_cc_AWCACHE;
  wire [5:0]m01_couplers_to_auto_cc_AWID;
  wire [7:0]m01_couplers_to_auto_cc_AWLEN;
  wire [0:0]m01_couplers_to_auto_cc_AWLOCK;
  wire [2:0]m01_couplers_to_auto_cc_AWPROT;
  wire [3:0]m01_couplers_to_auto_cc_AWQOS;
  wire m01_couplers_to_auto_cc_AWREADY;
  wire [3:0]m01_couplers_to_auto_cc_AWREGION;
  wire [2:0]m01_couplers_to_auto_cc_AWSIZE;
  wire m01_couplers_to_auto_cc_AWVALID;
  wire [5:0]m01_couplers_to_auto_cc_BID;
  wire m01_couplers_to_auto_cc_BREADY;
  wire [1:0]m01_couplers_to_auto_cc_BRESP;
  wire m01_couplers_to_auto_cc_BVALID;
  wire [511:0]m01_couplers_to_auto_cc_RDATA;
  wire [5:0]m01_couplers_to_auto_cc_RID;
  wire m01_couplers_to_auto_cc_RLAST;
  wire m01_couplers_to_auto_cc_RREADY;
  wire [1:0]m01_couplers_to_auto_cc_RRESP;
  wire m01_couplers_to_auto_cc_RVALID;
  wire [511:0]m01_couplers_to_auto_cc_WDATA;
  wire m01_couplers_to_auto_cc_WLAST;
  wire m01_couplers_to_auto_cc_WREADY;
  wire [63:0]m01_couplers_to_auto_cc_WSTRB;
  wire m01_couplers_to_auto_cc_WVALID;
  wire [63:0]m01_regslice_to_m01_couplers_ARADDR;
  wire [2:0]m01_regslice_to_m01_couplers_ARPROT;
  wire m01_regslice_to_m01_couplers_ARREADY;
  wire m01_regslice_to_m01_couplers_ARVALID;
  wire [63:0]m01_regslice_to_m01_couplers_AWADDR;
  wire [2:0]m01_regslice_to_m01_couplers_AWPROT;
  wire m01_regslice_to_m01_couplers_AWREADY;
  wire m01_regslice_to_m01_couplers_AWVALID;
  wire m01_regslice_to_m01_couplers_BREADY;
  wire [1:0]m01_regslice_to_m01_couplers_BRESP;
  wire m01_regslice_to_m01_couplers_BVALID;
  wire [63:0]m01_regslice_to_m01_couplers_RDATA;
  wire m01_regslice_to_m01_couplers_RREADY;
  wire [1:0]m01_regslice_to_m01_couplers_RRESP;
  wire m01_regslice_to_m01_couplers_RVALID;
  wire [63:0]m01_regslice_to_m01_couplers_WDATA;
  wire m01_regslice_to_m01_couplers_WREADY;
  wire [7:0]m01_regslice_to_m01_couplers_WSTRB;
  wire m01_regslice_to_m01_couplers_WVALID;

  assign M_ACLK_1 = M_ACLK;
  assign M_ARESETN_1 = M_ARESETN;
  assign M_AXI_araddr[63:0] = m01_regslice_to_m01_couplers_ARADDR;
  assign M_AXI_arprot[2:0] = m01_regslice_to_m01_couplers_ARPROT;
  assign M_AXI_arvalid = m01_regslice_to_m01_couplers_ARVALID;
  assign M_AXI_awaddr[63:0] = m01_regslice_to_m01_couplers_AWADDR;
  assign M_AXI_awprot[2:0] = m01_regslice_to_m01_couplers_AWPROT;
  assign M_AXI_awvalid = m01_regslice_to_m01_couplers_AWVALID;
  assign M_AXI_bready = m01_regslice_to_m01_couplers_BREADY;
  assign M_AXI_rready = m01_regslice_to_m01_couplers_RREADY;
  assign M_AXI_wdata[63:0] = m01_regslice_to_m01_couplers_WDATA;
  assign M_AXI_wstrb[7:0] = m01_regslice_to_m01_couplers_WSTRB;
  assign M_AXI_wvalid = m01_regslice_to_m01_couplers_WVALID;
  assign S_ACLK_1 = S_ACLK;
  assign S_ARESETN_1 = S_ARESETN;
  assign S_AXI_arready = m01_couplers_to_auto_cc_ARREADY;
  assign S_AXI_awready = m01_couplers_to_auto_cc_AWREADY;
  assign S_AXI_bid[5:0] = m01_couplers_to_auto_cc_BID;
  assign S_AXI_bresp[1:0] = m01_couplers_to_auto_cc_BRESP;
  assign S_AXI_bvalid = m01_couplers_to_auto_cc_BVALID;
  assign S_AXI_rdata[511:0] = m01_couplers_to_auto_cc_RDATA;
  assign S_AXI_rid[5:0] = m01_couplers_to_auto_cc_RID;
  assign S_AXI_rlast = m01_couplers_to_auto_cc_RLAST;
  assign S_AXI_rresp[1:0] = m01_couplers_to_auto_cc_RRESP;
  assign S_AXI_rvalid = m01_couplers_to_auto_cc_RVALID;
  assign S_AXI_wready = m01_couplers_to_auto_cc_WREADY;
  assign m01_couplers_to_auto_cc_ARADDR = S_AXI_araddr[63:0];
  assign m01_couplers_to_auto_cc_ARBURST = S_AXI_arburst[1:0];
  assign m01_couplers_to_auto_cc_ARCACHE = S_AXI_arcache[3:0];
  assign m01_couplers_to_auto_cc_ARID = S_AXI_arid[5:0];
  assign m01_couplers_to_auto_cc_ARLEN = S_AXI_arlen[7:0];
  assign m01_couplers_to_auto_cc_ARLOCK = S_AXI_arlock[0];
  assign m01_couplers_to_auto_cc_ARPROT = S_AXI_arprot[2:0];
  assign m01_couplers_to_auto_cc_ARQOS = S_AXI_arqos[3:0];
  assign m01_couplers_to_auto_cc_ARREGION = S_AXI_arregion[3:0];
  assign m01_couplers_to_auto_cc_ARSIZE = S_AXI_arsize[2:0];
  assign m01_couplers_to_auto_cc_ARVALID = S_AXI_arvalid;
  assign m01_couplers_to_auto_cc_AWADDR = S_AXI_awaddr[63:0];
  assign m01_couplers_to_auto_cc_AWBURST = S_AXI_awburst[1:0];
  assign m01_couplers_to_auto_cc_AWCACHE = S_AXI_awcache[3:0];
  assign m01_couplers_to_auto_cc_AWID = S_AXI_awid[5:0];
  assign m01_couplers_to_auto_cc_AWLEN = S_AXI_awlen[7:0];
  assign m01_couplers_to_auto_cc_AWLOCK = S_AXI_awlock[0];
  assign m01_couplers_to_auto_cc_AWPROT = S_AXI_awprot[2:0];
  assign m01_couplers_to_auto_cc_AWQOS = S_AXI_awqos[3:0];
  assign m01_couplers_to_auto_cc_AWREGION = S_AXI_awregion[3:0];
  assign m01_couplers_to_auto_cc_AWSIZE = S_AXI_awsize[2:0];
  assign m01_couplers_to_auto_cc_AWVALID = S_AXI_awvalid;
  assign m01_couplers_to_auto_cc_BREADY = S_AXI_bready;
  assign m01_couplers_to_auto_cc_RREADY = S_AXI_rready;
  assign m01_couplers_to_auto_cc_WDATA = S_AXI_wdata[511:0];
  assign m01_couplers_to_auto_cc_WLAST = S_AXI_wlast;
  assign m01_couplers_to_auto_cc_WSTRB = S_AXI_wstrb[63:0];
  assign m01_couplers_to_auto_cc_WVALID = S_AXI_wvalid;
  assign m01_regslice_to_m01_couplers_ARREADY = M_AXI_arready;
  assign m01_regslice_to_m01_couplers_AWREADY = M_AXI_awready;
  assign m01_regslice_to_m01_couplers_BRESP = M_AXI_bresp[1:0];
  assign m01_regslice_to_m01_couplers_BVALID = M_AXI_bvalid;
  assign m01_regslice_to_m01_couplers_RDATA = M_AXI_rdata[63:0];
  assign m01_regslice_to_m01_couplers_RRESP = M_AXI_rresp[1:0];
  assign m01_regslice_to_m01_couplers_RVALID = M_AXI_rvalid;
  assign m01_regslice_to_m01_couplers_WREADY = M_AXI_wready;
  design_ctrl_auto_cc_1 auto_cc
       (.m_axi_aclk(M_ACLK_1),
        .m_axi_araddr(auto_cc_to_auto_ds_ARADDR),
        .m_axi_arburst(auto_cc_to_auto_ds_ARBURST),
        .m_axi_arcache(auto_cc_to_auto_ds_ARCACHE),
        .m_axi_aresetn(M_ARESETN_1),
        .m_axi_arid(auto_cc_to_auto_ds_ARID),
        .m_axi_arlen(auto_cc_to_auto_ds_ARLEN),
        .m_axi_arlock(auto_cc_to_auto_ds_ARLOCK),
        .m_axi_arprot(auto_cc_to_auto_ds_ARPROT),
        .m_axi_arqos(auto_cc_to_auto_ds_ARQOS),
        .m_axi_arready(auto_cc_to_auto_ds_ARREADY),
        .m_axi_arregion(auto_cc_to_auto_ds_ARREGION),
        .m_axi_arsize(auto_cc_to_auto_ds_ARSIZE),
        .m_axi_arvalid(auto_cc_to_auto_ds_ARVALID),
        .m_axi_awaddr(auto_cc_to_auto_ds_AWADDR),
        .m_axi_awburst(auto_cc_to_auto_ds_AWBURST),
        .m_axi_awcache(auto_cc_to_auto_ds_AWCACHE),
        .m_axi_awid(auto_cc_to_auto_ds_AWID),
        .m_axi_awlen(auto_cc_to_auto_ds_AWLEN),
        .m_axi_awlock(auto_cc_to_auto_ds_AWLOCK),
        .m_axi_awprot(auto_cc_to_auto_ds_AWPROT),
        .m_axi_awqos(auto_cc_to_auto_ds_AWQOS),
        .m_axi_awready(auto_cc_to_auto_ds_AWREADY),
        .m_axi_awregion(auto_cc_to_auto_ds_AWREGION),
        .m_axi_awsize(auto_cc_to_auto_ds_AWSIZE),
        .m_axi_awvalid(auto_cc_to_auto_ds_AWVALID),
        .m_axi_bid(auto_cc_to_auto_ds_BID),
        .m_axi_bready(auto_cc_to_auto_ds_BREADY),
        .m_axi_bresp(auto_cc_to_auto_ds_BRESP),
        .m_axi_bvalid(auto_cc_to_auto_ds_BVALID),
        .m_axi_rdata(auto_cc_to_auto_ds_RDATA),
        .m_axi_rid(auto_cc_to_auto_ds_RID),
        .m_axi_rlast(auto_cc_to_auto_ds_RLAST),
        .m_axi_rready(auto_cc_to_auto_ds_RREADY),
        .m_axi_rresp(auto_cc_to_auto_ds_RRESP),
        .m_axi_rvalid(auto_cc_to_auto_ds_RVALID),
        .m_axi_wdata(auto_cc_to_auto_ds_WDATA),
        .m_axi_wlast(auto_cc_to_auto_ds_WLAST),
        .m_axi_wready(auto_cc_to_auto_ds_WREADY),
        .m_axi_wstrb(auto_cc_to_auto_ds_WSTRB),
        .m_axi_wvalid(auto_cc_to_auto_ds_WVALID),
        .s_axi_aclk(S_ACLK_1),
        .s_axi_araddr(m01_couplers_to_auto_cc_ARADDR),
        .s_axi_arburst(m01_couplers_to_auto_cc_ARBURST),
        .s_axi_arcache(m01_couplers_to_auto_cc_ARCACHE),
        .s_axi_aresetn(S_ARESETN_1),
        .s_axi_arid(m01_couplers_to_auto_cc_ARID),
        .s_axi_arlen(m01_couplers_to_auto_cc_ARLEN),
        .s_axi_arlock(m01_couplers_to_auto_cc_ARLOCK),
        .s_axi_arprot(m01_couplers_to_auto_cc_ARPROT),
        .s_axi_arqos(m01_couplers_to_auto_cc_ARQOS),
        .s_axi_arready(m01_couplers_to_auto_cc_ARREADY),
        .s_axi_arregion(m01_couplers_to_auto_cc_ARREGION),
        .s_axi_arsize(m01_couplers_to_auto_cc_ARSIZE),
        .s_axi_arvalid(m01_couplers_to_auto_cc_ARVALID),
        .s_axi_awaddr(m01_couplers_to_auto_cc_AWADDR),
        .s_axi_awburst(m01_couplers_to_auto_cc_AWBURST),
        .s_axi_awcache(m01_couplers_to_auto_cc_AWCACHE),
        .s_axi_awid(m01_couplers_to_auto_cc_AWID),
        .s_axi_awlen(m01_couplers_to_auto_cc_AWLEN),
        .s_axi_awlock(m01_couplers_to_auto_cc_AWLOCK),
        .s_axi_awprot(m01_couplers_to_auto_cc_AWPROT),
        .s_axi_awqos(m01_couplers_to_auto_cc_AWQOS),
        .s_axi_awready(m01_couplers_to_auto_cc_AWREADY),
        .s_axi_awregion(m01_couplers_to_auto_cc_AWREGION),
        .s_axi_awsize(m01_couplers_to_auto_cc_AWSIZE),
        .s_axi_awvalid(m01_couplers_to_auto_cc_AWVALID),
        .s_axi_bid(m01_couplers_to_auto_cc_BID),
        .s_axi_bready(m01_couplers_to_auto_cc_BREADY),
        .s_axi_bresp(m01_couplers_to_auto_cc_BRESP),
        .s_axi_bvalid(m01_couplers_to_auto_cc_BVALID),
        .s_axi_rdata(m01_couplers_to_auto_cc_RDATA),
        .s_axi_rid(m01_couplers_to_auto_cc_RID),
        .s_axi_rlast(m01_couplers_to_auto_cc_RLAST),
        .s_axi_rready(m01_couplers_to_auto_cc_RREADY),
        .s_axi_rresp(m01_couplers_to_auto_cc_RRESP),
        .s_axi_rvalid(m01_couplers_to_auto_cc_RVALID),
        .s_axi_wdata(m01_couplers_to_auto_cc_WDATA),
        .s_axi_wlast(m01_couplers_to_auto_cc_WLAST),
        .s_axi_wready(m01_couplers_to_auto_cc_WREADY),
        .s_axi_wstrb(m01_couplers_to_auto_cc_WSTRB),
        .s_axi_wvalid(m01_couplers_to_auto_cc_WVALID));
  design_ctrl_auto_ds_1 auto_ds
       (.m_axi_araddr(auto_ds_to_auto_rs_ARADDR),
        .m_axi_arburst(auto_ds_to_auto_rs_ARBURST),
        .m_axi_arcache(auto_ds_to_auto_rs_ARCACHE),
        .m_axi_arlen(auto_ds_to_auto_rs_ARLEN),
        .m_axi_arlock(auto_ds_to_auto_rs_ARLOCK),
        .m_axi_arprot(auto_ds_to_auto_rs_ARPROT),
        .m_axi_arqos(auto_ds_to_auto_rs_ARQOS),
        .m_axi_arready(auto_ds_to_auto_rs_ARREADY),
        .m_axi_arregion(auto_ds_to_auto_rs_ARREGION),
        .m_axi_arsize(auto_ds_to_auto_rs_ARSIZE),
        .m_axi_arvalid(auto_ds_to_auto_rs_ARVALID),
        .m_axi_awaddr(auto_ds_to_auto_rs_AWADDR),
        .m_axi_awburst(auto_ds_to_auto_rs_AWBURST),
        .m_axi_awcache(auto_ds_to_auto_rs_AWCACHE),
        .m_axi_awlen(auto_ds_to_auto_rs_AWLEN),
        .m_axi_awlock(auto_ds_to_auto_rs_AWLOCK),
        .m_axi_awprot(auto_ds_to_auto_rs_AWPROT),
        .m_axi_awqos(auto_ds_to_auto_rs_AWQOS),
        .m_axi_awready(auto_ds_to_auto_rs_AWREADY),
        .m_axi_awregion(auto_ds_to_auto_rs_AWREGION),
        .m_axi_awsize(auto_ds_to_auto_rs_AWSIZE),
        .m_axi_awvalid(auto_ds_to_auto_rs_AWVALID),
        .m_axi_bready(auto_ds_to_auto_rs_BREADY),
        .m_axi_bresp(auto_ds_to_auto_rs_BRESP),
        .m_axi_bvalid(auto_ds_to_auto_rs_BVALID),
        .m_axi_rdata(auto_ds_to_auto_rs_RDATA),
        .m_axi_rlast(auto_ds_to_auto_rs_RLAST),
        .m_axi_rready(auto_ds_to_auto_rs_RREADY),
        .m_axi_rresp(auto_ds_to_auto_rs_RRESP),
        .m_axi_rvalid(auto_ds_to_auto_rs_RVALID),
        .m_axi_wdata(auto_ds_to_auto_rs_WDATA),
        .m_axi_wlast(auto_ds_to_auto_rs_WLAST),
        .m_axi_wready(auto_ds_to_auto_rs_WREADY),
        .m_axi_wstrb(auto_ds_to_auto_rs_WSTRB),
        .m_axi_wvalid(auto_ds_to_auto_rs_WVALID),
        .s_axi_aclk(M_ACLK_1),
        .s_axi_araddr(auto_cc_to_auto_ds_ARADDR),
        .s_axi_arburst(auto_cc_to_auto_ds_ARBURST),
        .s_axi_arcache(auto_cc_to_auto_ds_ARCACHE),
        .s_axi_aresetn(M_ARESETN_1),
        .s_axi_arid(auto_cc_to_auto_ds_ARID),
        .s_axi_arlen(auto_cc_to_auto_ds_ARLEN),
        .s_axi_arlock(auto_cc_to_auto_ds_ARLOCK),
        .s_axi_arprot(auto_cc_to_auto_ds_ARPROT),
        .s_axi_arqos(auto_cc_to_auto_ds_ARQOS),
        .s_axi_arready(auto_cc_to_auto_ds_ARREADY),
        .s_axi_arregion(auto_cc_to_auto_ds_ARREGION),
        .s_axi_arsize(auto_cc_to_auto_ds_ARSIZE),
        .s_axi_arvalid(auto_cc_to_auto_ds_ARVALID),
        .s_axi_awaddr(auto_cc_to_auto_ds_AWADDR),
        .s_axi_awburst(auto_cc_to_auto_ds_AWBURST),
        .s_axi_awcache(auto_cc_to_auto_ds_AWCACHE),
        .s_axi_awid(auto_cc_to_auto_ds_AWID),
        .s_axi_awlen(auto_cc_to_auto_ds_AWLEN),
        .s_axi_awlock(auto_cc_to_auto_ds_AWLOCK),
        .s_axi_awprot(auto_cc_to_auto_ds_AWPROT),
        .s_axi_awqos(auto_cc_to_auto_ds_AWQOS),
        .s_axi_awready(auto_cc_to_auto_ds_AWREADY),
        .s_axi_awregion(auto_cc_to_auto_ds_AWREGION),
        .s_axi_awsize(auto_cc_to_auto_ds_AWSIZE),
        .s_axi_awvalid(auto_cc_to_auto_ds_AWVALID),
        .s_axi_bid(auto_cc_to_auto_ds_BID),
        .s_axi_bready(auto_cc_to_auto_ds_BREADY),
        .s_axi_bresp(auto_cc_to_auto_ds_BRESP),
        .s_axi_bvalid(auto_cc_to_auto_ds_BVALID),
        .s_axi_rdata(auto_cc_to_auto_ds_RDATA),
        .s_axi_rid(auto_cc_to_auto_ds_RID),
        .s_axi_rlast(auto_cc_to_auto_ds_RLAST),
        .s_axi_rready(auto_cc_to_auto_ds_RREADY),
        .s_axi_rresp(auto_cc_to_auto_ds_RRESP),
        .s_axi_rvalid(auto_cc_to_auto_ds_RVALID),
        .s_axi_wdata(auto_cc_to_auto_ds_WDATA),
        .s_axi_wlast(auto_cc_to_auto_ds_WLAST),
        .s_axi_wready(auto_cc_to_auto_ds_WREADY),
        .s_axi_wstrb(auto_cc_to_auto_ds_WSTRB),
        .s_axi_wvalid(auto_cc_to_auto_ds_WVALID));
  design_ctrl_auto_pc_1 auto_pc
       (.aclk(M_ACLK_1),
        .aresetn(M_ARESETN_1),
        .m_axi_araddr(auto_pc_to_m01_regslice_ARADDR),
        .m_axi_arprot(auto_pc_to_m01_regslice_ARPROT),
        .m_axi_arready(auto_pc_to_m01_regslice_ARREADY),
        .m_axi_arvalid(auto_pc_to_m01_regslice_ARVALID),
        .m_axi_awaddr(auto_pc_to_m01_regslice_AWADDR),
        .m_axi_awprot(auto_pc_to_m01_regslice_AWPROT),
        .m_axi_awready(auto_pc_to_m01_regslice_AWREADY),
        .m_axi_awvalid(auto_pc_to_m01_regslice_AWVALID),
        .m_axi_bready(auto_pc_to_m01_regslice_BREADY),
        .m_axi_bresp(auto_pc_to_m01_regslice_BRESP),
        .m_axi_bvalid(auto_pc_to_m01_regslice_BVALID),
        .m_axi_rdata(auto_pc_to_m01_regslice_RDATA),
        .m_axi_rready(auto_pc_to_m01_regslice_RREADY),
        .m_axi_rresp(auto_pc_to_m01_regslice_RRESP),
        .m_axi_rvalid(auto_pc_to_m01_regslice_RVALID),
        .m_axi_wdata(auto_pc_to_m01_regslice_WDATA),
        .m_axi_wready(auto_pc_to_m01_regslice_WREADY),
        .m_axi_wstrb(auto_pc_to_m01_regslice_WSTRB),
        .m_axi_wvalid(auto_pc_to_m01_regslice_WVALID),
        .s_axi_araddr(auto_rs_to_auto_pc_ARADDR),
        .s_axi_arburst(auto_rs_to_auto_pc_ARBURST),
        .s_axi_arcache(auto_rs_to_auto_pc_ARCACHE),
        .s_axi_arlen(auto_rs_to_auto_pc_ARLEN),
        .s_axi_arlock(auto_rs_to_auto_pc_ARLOCK),
        .s_axi_arprot(auto_rs_to_auto_pc_ARPROT),
        .s_axi_arqos(auto_rs_to_auto_pc_ARQOS),
        .s_axi_arready(auto_rs_to_auto_pc_ARREADY),
        .s_axi_arregion(auto_rs_to_auto_pc_ARREGION),
        .s_axi_arsize(auto_rs_to_auto_pc_ARSIZE),
        .s_axi_arvalid(auto_rs_to_auto_pc_ARVALID),
        .s_axi_awaddr(auto_rs_to_auto_pc_AWADDR),
        .s_axi_awburst(auto_rs_to_auto_pc_AWBURST),
        .s_axi_awcache(auto_rs_to_auto_pc_AWCACHE),
        .s_axi_awlen(auto_rs_to_auto_pc_AWLEN),
        .s_axi_awlock(auto_rs_to_auto_pc_AWLOCK),
        .s_axi_awprot(auto_rs_to_auto_pc_AWPROT),
        .s_axi_awqos(auto_rs_to_auto_pc_AWQOS),
        .s_axi_awready(auto_rs_to_auto_pc_AWREADY),
        .s_axi_awregion(auto_rs_to_auto_pc_AWREGION),
        .s_axi_awsize(auto_rs_to_auto_pc_AWSIZE),
        .s_axi_awvalid(auto_rs_to_auto_pc_AWVALID),
        .s_axi_bready(auto_rs_to_auto_pc_BREADY),
        .s_axi_bresp(auto_rs_to_auto_pc_BRESP),
        .s_axi_bvalid(auto_rs_to_auto_pc_BVALID),
        .s_axi_rdata(auto_rs_to_auto_pc_RDATA),
        .s_axi_rlast(auto_rs_to_auto_pc_RLAST),
        .s_axi_rready(auto_rs_to_auto_pc_RREADY),
        .s_axi_rresp(auto_rs_to_auto_pc_RRESP),
        .s_axi_rvalid(auto_rs_to_auto_pc_RVALID),
        .s_axi_wdata(auto_rs_to_auto_pc_WDATA),
        .s_axi_wlast(auto_rs_to_auto_pc_WLAST),
        .s_axi_wready(auto_rs_to_auto_pc_WREADY),
        .s_axi_wstrb(auto_rs_to_auto_pc_WSTRB),
        .s_axi_wvalid(auto_rs_to_auto_pc_WVALID));
  design_ctrl_auto_rs_1 auto_rs
       (.aclk(M_ACLK_1),
        .aresetn(M_ARESETN_1),
        .m_axi_araddr(auto_rs_to_auto_pc_ARADDR),
        .m_axi_arburst(auto_rs_to_auto_pc_ARBURST),
        .m_axi_arcache(auto_rs_to_auto_pc_ARCACHE),
        .m_axi_arlen(auto_rs_to_auto_pc_ARLEN),
        .m_axi_arlock(auto_rs_to_auto_pc_ARLOCK),
        .m_axi_arprot(auto_rs_to_auto_pc_ARPROT),
        .m_axi_arqos(auto_rs_to_auto_pc_ARQOS),
        .m_axi_arready(auto_rs_to_auto_pc_ARREADY),
        .m_axi_arregion(auto_rs_to_auto_pc_ARREGION),
        .m_axi_arsize(auto_rs_to_auto_pc_ARSIZE),
        .m_axi_arvalid(auto_rs_to_auto_pc_ARVALID),
        .m_axi_awaddr(auto_rs_to_auto_pc_AWADDR),
        .m_axi_awburst(auto_rs_to_auto_pc_AWBURST),
        .m_axi_awcache(auto_rs_to_auto_pc_AWCACHE),
        .m_axi_awlen(auto_rs_to_auto_pc_AWLEN),
        .m_axi_awlock(auto_rs_to_auto_pc_AWLOCK),
        .m_axi_awprot(auto_rs_to_auto_pc_AWPROT),
        .m_axi_awqos(auto_rs_to_auto_pc_AWQOS),
        .m_axi_awready(auto_rs_to_auto_pc_AWREADY),
        .m_axi_awregion(auto_rs_to_auto_pc_AWREGION),
        .m_axi_awsize(auto_rs_to_auto_pc_AWSIZE),
        .m_axi_awvalid(auto_rs_to_auto_pc_AWVALID),
        .m_axi_bready(auto_rs_to_auto_pc_BREADY),
        .m_axi_bresp(auto_rs_to_auto_pc_BRESP),
        .m_axi_bvalid(auto_rs_to_auto_pc_BVALID),
        .m_axi_rdata(auto_rs_to_auto_pc_RDATA),
        .m_axi_rlast(auto_rs_to_auto_pc_RLAST),
        .m_axi_rready(auto_rs_to_auto_pc_RREADY),
        .m_axi_rresp(auto_rs_to_auto_pc_RRESP),
        .m_axi_rvalid(auto_rs_to_auto_pc_RVALID),
        .m_axi_wdata(auto_rs_to_auto_pc_WDATA),
        .m_axi_wlast(auto_rs_to_auto_pc_WLAST),
        .m_axi_wready(auto_rs_to_auto_pc_WREADY),
        .m_axi_wstrb(auto_rs_to_auto_pc_WSTRB),
        .m_axi_wvalid(auto_rs_to_auto_pc_WVALID),
        .s_axi_araddr(auto_ds_to_auto_rs_ARADDR),
        .s_axi_arburst(auto_ds_to_auto_rs_ARBURST),
        .s_axi_arcache(auto_ds_to_auto_rs_ARCACHE),
        .s_axi_arlen(auto_ds_to_auto_rs_ARLEN),
        .s_axi_arlock(auto_ds_to_auto_rs_ARLOCK),
        .s_axi_arprot(auto_ds_to_auto_rs_ARPROT),
        .s_axi_arqos(auto_ds_to_auto_rs_ARQOS),
        .s_axi_arready(auto_ds_to_auto_rs_ARREADY),
        .s_axi_arregion(auto_ds_to_auto_rs_ARREGION),
        .s_axi_arsize(auto_ds_to_auto_rs_ARSIZE),
        .s_axi_arvalid(auto_ds_to_auto_rs_ARVALID),
        .s_axi_awaddr(auto_ds_to_auto_rs_AWADDR),
        .s_axi_awburst(auto_ds_to_auto_rs_AWBURST),
        .s_axi_awcache(auto_ds_to_auto_rs_AWCACHE),
        .s_axi_awlen(auto_ds_to_auto_rs_AWLEN),
        .s_axi_awlock(auto_ds_to_auto_rs_AWLOCK),
        .s_axi_awprot(auto_ds_to_auto_rs_AWPROT),
        .s_axi_awqos(auto_ds_to_auto_rs_AWQOS),
        .s_axi_awready(auto_ds_to_auto_rs_AWREADY),
        .s_axi_awregion(auto_ds_to_auto_rs_AWREGION),
        .s_axi_awsize(auto_ds_to_auto_rs_AWSIZE),
        .s_axi_awvalid(auto_ds_to_auto_rs_AWVALID),
        .s_axi_bready(auto_ds_to_auto_rs_BREADY),
        .s_axi_bresp(auto_ds_to_auto_rs_BRESP),
        .s_axi_bvalid(auto_ds_to_auto_rs_BVALID),
        .s_axi_rdata(auto_ds_to_auto_rs_RDATA),
        .s_axi_rlast(auto_ds_to_auto_rs_RLAST),
        .s_axi_rready(auto_ds_to_auto_rs_RREADY),
        .s_axi_rresp(auto_ds_to_auto_rs_RRESP),
        .s_axi_rvalid(auto_ds_to_auto_rs_RVALID),
        .s_axi_wdata(auto_ds_to_auto_rs_WDATA),
        .s_axi_wlast(auto_ds_to_auto_rs_WLAST),
        .s_axi_wready(auto_ds_to_auto_rs_WREADY),
        .s_axi_wstrb(auto_ds_to_auto_rs_WSTRB),
        .s_axi_wvalid(auto_ds_to_auto_rs_WVALID));
  design_ctrl_m01_regslice_0 m01_regslice
       (.aclk(M_ACLK_1),
        .aresetn(M_ARESETN_1),
        .m_axi_araddr(m01_regslice_to_m01_couplers_ARADDR),
        .m_axi_arprot(m01_regslice_to_m01_couplers_ARPROT),
        .m_axi_arready(m01_regslice_to_m01_couplers_ARREADY),
        .m_axi_arvalid(m01_regslice_to_m01_couplers_ARVALID),
        .m_axi_awaddr(m01_regslice_to_m01_couplers_AWADDR),
        .m_axi_awprot(m01_regslice_to_m01_couplers_AWPROT),
        .m_axi_awready(m01_regslice_to_m01_couplers_AWREADY),
        .m_axi_awvalid(m01_regslice_to_m01_couplers_AWVALID),
        .m_axi_bready(m01_regslice_to_m01_couplers_BREADY),
        .m_axi_bresp(m01_regslice_to_m01_couplers_BRESP),
        .m_axi_bvalid(m01_regslice_to_m01_couplers_BVALID),
        .m_axi_rdata(m01_regslice_to_m01_couplers_RDATA),
        .m_axi_rready(m01_regslice_to_m01_couplers_RREADY),
        .m_axi_rresp(m01_regslice_to_m01_couplers_RRESP),
        .m_axi_rvalid(m01_regslice_to_m01_couplers_RVALID),
        .m_axi_wdata(m01_regslice_to_m01_couplers_WDATA),
        .m_axi_wready(m01_regslice_to_m01_couplers_WREADY),
        .m_axi_wstrb(m01_regslice_to_m01_couplers_WSTRB),
        .m_axi_wvalid(m01_regslice_to_m01_couplers_WVALID),
        .s_axi_araddr(auto_pc_to_m01_regslice_ARADDR),
        .s_axi_arprot(auto_pc_to_m01_regslice_ARPROT),
        .s_axi_arready(auto_pc_to_m01_regslice_ARREADY),
        .s_axi_arvalid(auto_pc_to_m01_regslice_ARVALID),
        .s_axi_awaddr(auto_pc_to_m01_regslice_AWADDR),
        .s_axi_awprot(auto_pc_to_m01_regslice_AWPROT),
        .s_axi_awready(auto_pc_to_m01_regslice_AWREADY),
        .s_axi_awvalid(auto_pc_to_m01_regslice_AWVALID),
        .s_axi_bready(auto_pc_to_m01_regslice_BREADY),
        .s_axi_bresp(auto_pc_to_m01_regslice_BRESP),
        .s_axi_bvalid(auto_pc_to_m01_regslice_BVALID),
        .s_axi_rdata(auto_pc_to_m01_regslice_RDATA),
        .s_axi_rready(auto_pc_to_m01_regslice_RREADY),
        .s_axi_rresp(auto_pc_to_m01_regslice_RRESP),
        .s_axi_rvalid(auto_pc_to_m01_regslice_RVALID),
        .s_axi_wdata(auto_pc_to_m01_regslice_WDATA),
        .s_axi_wready(auto_pc_to_m01_regslice_WREADY),
        .s_axi_wstrb(auto_pc_to_m01_regslice_WSTRB),
        .s_axi_wvalid(auto_pc_to_m01_regslice_WVALID));
endmodule

module m02_couplers_imp_S0PEUK
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arburst,
    M_AXI_arcache,
    M_AXI_arlen,
    M_AXI_arlock,
    M_AXI_arprot,
    M_AXI_arqos,
    M_AXI_arready,
    M_AXI_arregion,
    M_AXI_arsize,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awburst,
    M_AXI_awcache,
    M_AXI_awlen,
    M_AXI_awlock,
    M_AXI_awprot,
    M_AXI_awqos,
    M_AXI_awready,
    M_AXI_awregion,
    M_AXI_awsize,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rlast,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wlast,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arburst,
    S_AXI_arcache,
    S_AXI_arid,
    S_AXI_arlen,
    S_AXI_arlock,
    S_AXI_arprot,
    S_AXI_arqos,
    S_AXI_arready,
    S_AXI_arregion,
    S_AXI_arsize,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awburst,
    S_AXI_awcache,
    S_AXI_awid,
    S_AXI_awlen,
    S_AXI_awlock,
    S_AXI_awprot,
    S_AXI_awqos,
    S_AXI_awready,
    S_AXI_awregion,
    S_AXI_awsize,
    S_AXI_awvalid,
    S_AXI_bid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rid,
    S_AXI_rlast,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wlast,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [63:0]M_AXI_araddr;
  output [1:0]M_AXI_arburst;
  output [3:0]M_AXI_arcache;
  output [7:0]M_AXI_arlen;
  output [0:0]M_AXI_arlock;
  output [2:0]M_AXI_arprot;
  output [3:0]M_AXI_arqos;
  input M_AXI_arready;
  output [3:0]M_AXI_arregion;
  output [2:0]M_AXI_arsize;
  output M_AXI_arvalid;
  output [63:0]M_AXI_awaddr;
  output [1:0]M_AXI_awburst;
  output [3:0]M_AXI_awcache;
  output [7:0]M_AXI_awlen;
  output [0:0]M_AXI_awlock;
  output [2:0]M_AXI_awprot;
  output [3:0]M_AXI_awqos;
  input M_AXI_awready;
  output [3:0]M_AXI_awregion;
  output [2:0]M_AXI_awsize;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [255:0]M_AXI_rdata;
  input M_AXI_rlast;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [255:0]M_AXI_wdata;
  output M_AXI_wlast;
  input M_AXI_wready;
  output [31:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [63:0]S_AXI_araddr;
  input [1:0]S_AXI_arburst;
  input [3:0]S_AXI_arcache;
  input [5:0]S_AXI_arid;
  input [7:0]S_AXI_arlen;
  input [0:0]S_AXI_arlock;
  input [2:0]S_AXI_arprot;
  input [3:0]S_AXI_arqos;
  output S_AXI_arready;
  input [3:0]S_AXI_arregion;
  input [2:0]S_AXI_arsize;
  input S_AXI_arvalid;
  input [63:0]S_AXI_awaddr;
  input [1:0]S_AXI_awburst;
  input [3:0]S_AXI_awcache;
  input [5:0]S_AXI_awid;
  input [7:0]S_AXI_awlen;
  input [0:0]S_AXI_awlock;
  input [2:0]S_AXI_awprot;
  input [3:0]S_AXI_awqos;
  output S_AXI_awready;
  input [3:0]S_AXI_awregion;
  input [2:0]S_AXI_awsize;
  input S_AXI_awvalid;
  output [5:0]S_AXI_bid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [511:0]S_AXI_rdata;
  output [5:0]S_AXI_rid;
  output S_AXI_rlast;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [511:0]S_AXI_wdata;
  input S_AXI_wlast;
  output S_AXI_wready;
  input [63:0]S_AXI_wstrb;
  input S_AXI_wvalid;

  wire M_ACLK_1;
  wire M_ARESETN_1;
  wire S_ACLK_1;
  wire S_ARESETN_1;
  wire [63:0]auto_cc_to_auto_ds_ARADDR;
  wire [1:0]auto_cc_to_auto_ds_ARBURST;
  wire [3:0]auto_cc_to_auto_ds_ARCACHE;
  wire [5:0]auto_cc_to_auto_ds_ARID;
  wire [7:0]auto_cc_to_auto_ds_ARLEN;
  wire [0:0]auto_cc_to_auto_ds_ARLOCK;
  wire [2:0]auto_cc_to_auto_ds_ARPROT;
  wire [3:0]auto_cc_to_auto_ds_ARQOS;
  wire auto_cc_to_auto_ds_ARREADY;
  wire [3:0]auto_cc_to_auto_ds_ARREGION;
  wire [2:0]auto_cc_to_auto_ds_ARSIZE;
  wire auto_cc_to_auto_ds_ARVALID;
  wire [63:0]auto_cc_to_auto_ds_AWADDR;
  wire [1:0]auto_cc_to_auto_ds_AWBURST;
  wire [3:0]auto_cc_to_auto_ds_AWCACHE;
  wire [5:0]auto_cc_to_auto_ds_AWID;
  wire [7:0]auto_cc_to_auto_ds_AWLEN;
  wire [0:0]auto_cc_to_auto_ds_AWLOCK;
  wire [2:0]auto_cc_to_auto_ds_AWPROT;
  wire [3:0]auto_cc_to_auto_ds_AWQOS;
  wire auto_cc_to_auto_ds_AWREADY;
  wire [3:0]auto_cc_to_auto_ds_AWREGION;
  wire [2:0]auto_cc_to_auto_ds_AWSIZE;
  wire auto_cc_to_auto_ds_AWVALID;
  wire [5:0]auto_cc_to_auto_ds_BID;
  wire auto_cc_to_auto_ds_BREADY;
  wire [1:0]auto_cc_to_auto_ds_BRESP;
  wire auto_cc_to_auto_ds_BVALID;
  wire [511:0]auto_cc_to_auto_ds_RDATA;
  wire [5:0]auto_cc_to_auto_ds_RID;
  wire auto_cc_to_auto_ds_RLAST;
  wire auto_cc_to_auto_ds_RREADY;
  wire [1:0]auto_cc_to_auto_ds_RRESP;
  wire auto_cc_to_auto_ds_RVALID;
  wire [511:0]auto_cc_to_auto_ds_WDATA;
  wire auto_cc_to_auto_ds_WLAST;
  wire auto_cc_to_auto_ds_WREADY;
  wire [63:0]auto_cc_to_auto_ds_WSTRB;
  wire auto_cc_to_auto_ds_WVALID;
  wire [63:0]auto_ds_to_m02_regslice_ARADDR;
  wire [1:0]auto_ds_to_m02_regslice_ARBURST;
  wire [3:0]auto_ds_to_m02_regslice_ARCACHE;
  wire [7:0]auto_ds_to_m02_regslice_ARLEN;
  wire [0:0]auto_ds_to_m02_regslice_ARLOCK;
  wire [2:0]auto_ds_to_m02_regslice_ARPROT;
  wire [3:0]auto_ds_to_m02_regslice_ARQOS;
  wire auto_ds_to_m02_regslice_ARREADY;
  wire [3:0]auto_ds_to_m02_regslice_ARREGION;
  wire [2:0]auto_ds_to_m02_regslice_ARSIZE;
  wire auto_ds_to_m02_regslice_ARVALID;
  wire [63:0]auto_ds_to_m02_regslice_AWADDR;
  wire [1:0]auto_ds_to_m02_regslice_AWBURST;
  wire [3:0]auto_ds_to_m02_regslice_AWCACHE;
  wire [7:0]auto_ds_to_m02_regslice_AWLEN;
  wire [0:0]auto_ds_to_m02_regslice_AWLOCK;
  wire [2:0]auto_ds_to_m02_regslice_AWPROT;
  wire [3:0]auto_ds_to_m02_regslice_AWQOS;
  wire auto_ds_to_m02_regslice_AWREADY;
  wire [3:0]auto_ds_to_m02_regslice_AWREGION;
  wire [2:0]auto_ds_to_m02_regslice_AWSIZE;
  wire auto_ds_to_m02_regslice_AWVALID;
  wire auto_ds_to_m02_regslice_BREADY;
  wire [1:0]auto_ds_to_m02_regslice_BRESP;
  wire auto_ds_to_m02_regslice_BVALID;
  wire [255:0]auto_ds_to_m02_regslice_RDATA;
  wire auto_ds_to_m02_regslice_RLAST;
  wire auto_ds_to_m02_regslice_RREADY;
  wire [1:0]auto_ds_to_m02_regslice_RRESP;
  wire auto_ds_to_m02_regslice_RVALID;
  wire [255:0]auto_ds_to_m02_regslice_WDATA;
  wire auto_ds_to_m02_regslice_WLAST;
  wire auto_ds_to_m02_regslice_WREADY;
  wire [31:0]auto_ds_to_m02_regslice_WSTRB;
  wire auto_ds_to_m02_regslice_WVALID;
  wire [63:0]m02_couplers_to_auto_cc_ARADDR;
  wire [1:0]m02_couplers_to_auto_cc_ARBURST;
  wire [3:0]m02_couplers_to_auto_cc_ARCACHE;
  wire [5:0]m02_couplers_to_auto_cc_ARID;
  wire [7:0]m02_couplers_to_auto_cc_ARLEN;
  wire [0:0]m02_couplers_to_auto_cc_ARLOCK;
  wire [2:0]m02_couplers_to_auto_cc_ARPROT;
  wire [3:0]m02_couplers_to_auto_cc_ARQOS;
  wire m02_couplers_to_auto_cc_ARREADY;
  wire [3:0]m02_couplers_to_auto_cc_ARREGION;
  wire [2:0]m02_couplers_to_auto_cc_ARSIZE;
  wire m02_couplers_to_auto_cc_ARVALID;
  wire [63:0]m02_couplers_to_auto_cc_AWADDR;
  wire [1:0]m02_couplers_to_auto_cc_AWBURST;
  wire [3:0]m02_couplers_to_auto_cc_AWCACHE;
  wire [5:0]m02_couplers_to_auto_cc_AWID;
  wire [7:0]m02_couplers_to_auto_cc_AWLEN;
  wire [0:0]m02_couplers_to_auto_cc_AWLOCK;
  wire [2:0]m02_couplers_to_auto_cc_AWPROT;
  wire [3:0]m02_couplers_to_auto_cc_AWQOS;
  wire m02_couplers_to_auto_cc_AWREADY;
  wire [3:0]m02_couplers_to_auto_cc_AWREGION;
  wire [2:0]m02_couplers_to_auto_cc_AWSIZE;
  wire m02_couplers_to_auto_cc_AWVALID;
  wire [5:0]m02_couplers_to_auto_cc_BID;
  wire m02_couplers_to_auto_cc_BREADY;
  wire [1:0]m02_couplers_to_auto_cc_BRESP;
  wire m02_couplers_to_auto_cc_BVALID;
  wire [511:0]m02_couplers_to_auto_cc_RDATA;
  wire [5:0]m02_couplers_to_auto_cc_RID;
  wire m02_couplers_to_auto_cc_RLAST;
  wire m02_couplers_to_auto_cc_RREADY;
  wire [1:0]m02_couplers_to_auto_cc_RRESP;
  wire m02_couplers_to_auto_cc_RVALID;
  wire [511:0]m02_couplers_to_auto_cc_WDATA;
  wire m02_couplers_to_auto_cc_WLAST;
  wire m02_couplers_to_auto_cc_WREADY;
  wire [63:0]m02_couplers_to_auto_cc_WSTRB;
  wire m02_couplers_to_auto_cc_WVALID;
  wire [63:0]m02_regslice_to_m02_couplers_ARADDR;
  wire [1:0]m02_regslice_to_m02_couplers_ARBURST;
  wire [3:0]m02_regslice_to_m02_couplers_ARCACHE;
  wire [7:0]m02_regslice_to_m02_couplers_ARLEN;
  wire [0:0]m02_regslice_to_m02_couplers_ARLOCK;
  wire [2:0]m02_regslice_to_m02_couplers_ARPROT;
  wire [3:0]m02_regslice_to_m02_couplers_ARQOS;
  wire m02_regslice_to_m02_couplers_ARREADY;
  wire [3:0]m02_regslice_to_m02_couplers_ARREGION;
  wire [2:0]m02_regslice_to_m02_couplers_ARSIZE;
  wire m02_regslice_to_m02_couplers_ARVALID;
  wire [63:0]m02_regslice_to_m02_couplers_AWADDR;
  wire [1:0]m02_regslice_to_m02_couplers_AWBURST;
  wire [3:0]m02_regslice_to_m02_couplers_AWCACHE;
  wire [7:0]m02_regslice_to_m02_couplers_AWLEN;
  wire [0:0]m02_regslice_to_m02_couplers_AWLOCK;
  wire [2:0]m02_regslice_to_m02_couplers_AWPROT;
  wire [3:0]m02_regslice_to_m02_couplers_AWQOS;
  wire m02_regslice_to_m02_couplers_AWREADY;
  wire [3:0]m02_regslice_to_m02_couplers_AWREGION;
  wire [2:0]m02_regslice_to_m02_couplers_AWSIZE;
  wire m02_regslice_to_m02_couplers_AWVALID;
  wire m02_regslice_to_m02_couplers_BREADY;
  wire [1:0]m02_regslice_to_m02_couplers_BRESP;
  wire m02_regslice_to_m02_couplers_BVALID;
  wire [255:0]m02_regslice_to_m02_couplers_RDATA;
  wire m02_regslice_to_m02_couplers_RLAST;
  wire m02_regslice_to_m02_couplers_RREADY;
  wire [1:0]m02_regslice_to_m02_couplers_RRESP;
  wire m02_regslice_to_m02_couplers_RVALID;
  wire [255:0]m02_regslice_to_m02_couplers_WDATA;
  wire m02_regslice_to_m02_couplers_WLAST;
  wire m02_regslice_to_m02_couplers_WREADY;
  wire [31:0]m02_regslice_to_m02_couplers_WSTRB;
  wire m02_regslice_to_m02_couplers_WVALID;

  assign M_ACLK_1 = M_ACLK;
  assign M_ARESETN_1 = M_ARESETN;
  assign M_AXI_araddr[63:0] = m02_regslice_to_m02_couplers_ARADDR;
  assign M_AXI_arburst[1:0] = m02_regslice_to_m02_couplers_ARBURST;
  assign M_AXI_arcache[3:0] = m02_regslice_to_m02_couplers_ARCACHE;
  assign M_AXI_arlen[7:0] = m02_regslice_to_m02_couplers_ARLEN;
  assign M_AXI_arlock[0] = m02_regslice_to_m02_couplers_ARLOCK;
  assign M_AXI_arprot[2:0] = m02_regslice_to_m02_couplers_ARPROT;
  assign M_AXI_arqos[3:0] = m02_regslice_to_m02_couplers_ARQOS;
  assign M_AXI_arregion[3:0] = m02_regslice_to_m02_couplers_ARREGION;
  assign M_AXI_arsize[2:0] = m02_regslice_to_m02_couplers_ARSIZE;
  assign M_AXI_arvalid = m02_regslice_to_m02_couplers_ARVALID;
  assign M_AXI_awaddr[63:0] = m02_regslice_to_m02_couplers_AWADDR;
  assign M_AXI_awburst[1:0] = m02_regslice_to_m02_couplers_AWBURST;
  assign M_AXI_awcache[3:0] = m02_regslice_to_m02_couplers_AWCACHE;
  assign M_AXI_awlen[7:0] = m02_regslice_to_m02_couplers_AWLEN;
  assign M_AXI_awlock[0] = m02_regslice_to_m02_couplers_AWLOCK;
  assign M_AXI_awprot[2:0] = m02_regslice_to_m02_couplers_AWPROT;
  assign M_AXI_awqos[3:0] = m02_regslice_to_m02_couplers_AWQOS;
  assign M_AXI_awregion[3:0] = m02_regslice_to_m02_couplers_AWREGION;
  assign M_AXI_awsize[2:0] = m02_regslice_to_m02_couplers_AWSIZE;
  assign M_AXI_awvalid = m02_regslice_to_m02_couplers_AWVALID;
  assign M_AXI_bready = m02_regslice_to_m02_couplers_BREADY;
  assign M_AXI_rready = m02_regslice_to_m02_couplers_RREADY;
  assign M_AXI_wdata[255:0] = m02_regslice_to_m02_couplers_WDATA;
  assign M_AXI_wlast = m02_regslice_to_m02_couplers_WLAST;
  assign M_AXI_wstrb[31:0] = m02_regslice_to_m02_couplers_WSTRB;
  assign M_AXI_wvalid = m02_regslice_to_m02_couplers_WVALID;
  assign S_ACLK_1 = S_ACLK;
  assign S_ARESETN_1 = S_ARESETN;
  assign S_AXI_arready = m02_couplers_to_auto_cc_ARREADY;
  assign S_AXI_awready = m02_couplers_to_auto_cc_AWREADY;
  assign S_AXI_bid[5:0] = m02_couplers_to_auto_cc_BID;
  assign S_AXI_bresp[1:0] = m02_couplers_to_auto_cc_BRESP;
  assign S_AXI_bvalid = m02_couplers_to_auto_cc_BVALID;
  assign S_AXI_rdata[511:0] = m02_couplers_to_auto_cc_RDATA;
  assign S_AXI_rid[5:0] = m02_couplers_to_auto_cc_RID;
  assign S_AXI_rlast = m02_couplers_to_auto_cc_RLAST;
  assign S_AXI_rresp[1:0] = m02_couplers_to_auto_cc_RRESP;
  assign S_AXI_rvalid = m02_couplers_to_auto_cc_RVALID;
  assign S_AXI_wready = m02_couplers_to_auto_cc_WREADY;
  assign m02_couplers_to_auto_cc_ARADDR = S_AXI_araddr[63:0];
  assign m02_couplers_to_auto_cc_ARBURST = S_AXI_arburst[1:0];
  assign m02_couplers_to_auto_cc_ARCACHE = S_AXI_arcache[3:0];
  assign m02_couplers_to_auto_cc_ARID = S_AXI_arid[5:0];
  assign m02_couplers_to_auto_cc_ARLEN = S_AXI_arlen[7:0];
  assign m02_couplers_to_auto_cc_ARLOCK = S_AXI_arlock[0];
  assign m02_couplers_to_auto_cc_ARPROT = S_AXI_arprot[2:0];
  assign m02_couplers_to_auto_cc_ARQOS = S_AXI_arqos[3:0];
  assign m02_couplers_to_auto_cc_ARREGION = S_AXI_arregion[3:0];
  assign m02_couplers_to_auto_cc_ARSIZE = S_AXI_arsize[2:0];
  assign m02_couplers_to_auto_cc_ARVALID = S_AXI_arvalid;
  assign m02_couplers_to_auto_cc_AWADDR = S_AXI_awaddr[63:0];
  assign m02_couplers_to_auto_cc_AWBURST = S_AXI_awburst[1:0];
  assign m02_couplers_to_auto_cc_AWCACHE = S_AXI_awcache[3:0];
  assign m02_couplers_to_auto_cc_AWID = S_AXI_awid[5:0];
  assign m02_couplers_to_auto_cc_AWLEN = S_AXI_awlen[7:0];
  assign m02_couplers_to_auto_cc_AWLOCK = S_AXI_awlock[0];
  assign m02_couplers_to_auto_cc_AWPROT = S_AXI_awprot[2:0];
  assign m02_couplers_to_auto_cc_AWQOS = S_AXI_awqos[3:0];
  assign m02_couplers_to_auto_cc_AWREGION = S_AXI_awregion[3:0];
  assign m02_couplers_to_auto_cc_AWSIZE = S_AXI_awsize[2:0];
  assign m02_couplers_to_auto_cc_AWVALID = S_AXI_awvalid;
  assign m02_couplers_to_auto_cc_BREADY = S_AXI_bready;
  assign m02_couplers_to_auto_cc_RREADY = S_AXI_rready;
  assign m02_couplers_to_auto_cc_WDATA = S_AXI_wdata[511:0];
  assign m02_couplers_to_auto_cc_WLAST = S_AXI_wlast;
  assign m02_couplers_to_auto_cc_WSTRB = S_AXI_wstrb[63:0];
  assign m02_couplers_to_auto_cc_WVALID = S_AXI_wvalid;
  assign m02_regslice_to_m02_couplers_ARREADY = M_AXI_arready;
  assign m02_regslice_to_m02_couplers_AWREADY = M_AXI_awready;
  assign m02_regslice_to_m02_couplers_BRESP = M_AXI_bresp[1:0];
  assign m02_regslice_to_m02_couplers_BVALID = M_AXI_bvalid;
  assign m02_regslice_to_m02_couplers_RDATA = M_AXI_rdata[255:0];
  assign m02_regslice_to_m02_couplers_RLAST = M_AXI_rlast;
  assign m02_regslice_to_m02_couplers_RRESP = M_AXI_rresp[1:0];
  assign m02_regslice_to_m02_couplers_RVALID = M_AXI_rvalid;
  assign m02_regslice_to_m02_couplers_WREADY = M_AXI_wready;
  design_ctrl_auto_cc_2 auto_cc
       (.m_axi_aclk(M_ACLK_1),
        .m_axi_araddr(auto_cc_to_auto_ds_ARADDR),
        .m_axi_arburst(auto_cc_to_auto_ds_ARBURST),
        .m_axi_arcache(auto_cc_to_auto_ds_ARCACHE),
        .m_axi_aresetn(M_ARESETN_1),
        .m_axi_arid(auto_cc_to_auto_ds_ARID),
        .m_axi_arlen(auto_cc_to_auto_ds_ARLEN),
        .m_axi_arlock(auto_cc_to_auto_ds_ARLOCK),
        .m_axi_arprot(auto_cc_to_auto_ds_ARPROT),
        .m_axi_arqos(auto_cc_to_auto_ds_ARQOS),
        .m_axi_arready(auto_cc_to_auto_ds_ARREADY),
        .m_axi_arregion(auto_cc_to_auto_ds_ARREGION),
        .m_axi_arsize(auto_cc_to_auto_ds_ARSIZE),
        .m_axi_arvalid(auto_cc_to_auto_ds_ARVALID),
        .m_axi_awaddr(auto_cc_to_auto_ds_AWADDR),
        .m_axi_awburst(auto_cc_to_auto_ds_AWBURST),
        .m_axi_awcache(auto_cc_to_auto_ds_AWCACHE),
        .m_axi_awid(auto_cc_to_auto_ds_AWID),
        .m_axi_awlen(auto_cc_to_auto_ds_AWLEN),
        .m_axi_awlock(auto_cc_to_auto_ds_AWLOCK),
        .m_axi_awprot(auto_cc_to_auto_ds_AWPROT),
        .m_axi_awqos(auto_cc_to_auto_ds_AWQOS),
        .m_axi_awready(auto_cc_to_auto_ds_AWREADY),
        .m_axi_awregion(auto_cc_to_auto_ds_AWREGION),
        .m_axi_awsize(auto_cc_to_auto_ds_AWSIZE),
        .m_axi_awvalid(auto_cc_to_auto_ds_AWVALID),
        .m_axi_bid(auto_cc_to_auto_ds_BID),
        .m_axi_bready(auto_cc_to_auto_ds_BREADY),
        .m_axi_bresp(auto_cc_to_auto_ds_BRESP),
        .m_axi_bvalid(auto_cc_to_auto_ds_BVALID),
        .m_axi_rdata(auto_cc_to_auto_ds_RDATA),
        .m_axi_rid(auto_cc_to_auto_ds_RID),
        .m_axi_rlast(auto_cc_to_auto_ds_RLAST),
        .m_axi_rready(auto_cc_to_auto_ds_RREADY),
        .m_axi_rresp(auto_cc_to_auto_ds_RRESP),
        .m_axi_rvalid(auto_cc_to_auto_ds_RVALID),
        .m_axi_wdata(auto_cc_to_auto_ds_WDATA),
        .m_axi_wlast(auto_cc_to_auto_ds_WLAST),
        .m_axi_wready(auto_cc_to_auto_ds_WREADY),
        .m_axi_wstrb(auto_cc_to_auto_ds_WSTRB),
        .m_axi_wvalid(auto_cc_to_auto_ds_WVALID),
        .s_axi_aclk(S_ACLK_1),
        .s_axi_araddr(m02_couplers_to_auto_cc_ARADDR),
        .s_axi_arburst(m02_couplers_to_auto_cc_ARBURST),
        .s_axi_arcache(m02_couplers_to_auto_cc_ARCACHE),
        .s_axi_aresetn(S_ARESETN_1),
        .s_axi_arid(m02_couplers_to_auto_cc_ARID),
        .s_axi_arlen(m02_couplers_to_auto_cc_ARLEN),
        .s_axi_arlock(m02_couplers_to_auto_cc_ARLOCK),
        .s_axi_arprot(m02_couplers_to_auto_cc_ARPROT),
        .s_axi_arqos(m02_couplers_to_auto_cc_ARQOS),
        .s_axi_arready(m02_couplers_to_auto_cc_ARREADY),
        .s_axi_arregion(m02_couplers_to_auto_cc_ARREGION),
        .s_axi_arsize(m02_couplers_to_auto_cc_ARSIZE),
        .s_axi_arvalid(m02_couplers_to_auto_cc_ARVALID),
        .s_axi_awaddr(m02_couplers_to_auto_cc_AWADDR),
        .s_axi_awburst(m02_couplers_to_auto_cc_AWBURST),
        .s_axi_awcache(m02_couplers_to_auto_cc_AWCACHE),
        .s_axi_awid(m02_couplers_to_auto_cc_AWID),
        .s_axi_awlen(m02_couplers_to_auto_cc_AWLEN),
        .s_axi_awlock(m02_couplers_to_auto_cc_AWLOCK),
        .s_axi_awprot(m02_couplers_to_auto_cc_AWPROT),
        .s_axi_awqos(m02_couplers_to_auto_cc_AWQOS),
        .s_axi_awready(m02_couplers_to_auto_cc_AWREADY),
        .s_axi_awregion(m02_couplers_to_auto_cc_AWREGION),
        .s_axi_awsize(m02_couplers_to_auto_cc_AWSIZE),
        .s_axi_awvalid(m02_couplers_to_auto_cc_AWVALID),
        .s_axi_bid(m02_couplers_to_auto_cc_BID),
        .s_axi_bready(m02_couplers_to_auto_cc_BREADY),
        .s_axi_bresp(m02_couplers_to_auto_cc_BRESP),
        .s_axi_bvalid(m02_couplers_to_auto_cc_BVALID),
        .s_axi_rdata(m02_couplers_to_auto_cc_RDATA),
        .s_axi_rid(m02_couplers_to_auto_cc_RID),
        .s_axi_rlast(m02_couplers_to_auto_cc_RLAST),
        .s_axi_rready(m02_couplers_to_auto_cc_RREADY),
        .s_axi_rresp(m02_couplers_to_auto_cc_RRESP),
        .s_axi_rvalid(m02_couplers_to_auto_cc_RVALID),
        .s_axi_wdata(m02_couplers_to_auto_cc_WDATA),
        .s_axi_wlast(m02_couplers_to_auto_cc_WLAST),
        .s_axi_wready(m02_couplers_to_auto_cc_WREADY),
        .s_axi_wstrb(m02_couplers_to_auto_cc_WSTRB),
        .s_axi_wvalid(m02_couplers_to_auto_cc_WVALID));
  design_ctrl_auto_ds_2 auto_ds
       (.m_axi_araddr(auto_ds_to_m02_regslice_ARADDR),
        .m_axi_arburst(auto_ds_to_m02_regslice_ARBURST),
        .m_axi_arcache(auto_ds_to_m02_regslice_ARCACHE),
        .m_axi_arlen(auto_ds_to_m02_regslice_ARLEN),
        .m_axi_arlock(auto_ds_to_m02_regslice_ARLOCK),
        .m_axi_arprot(auto_ds_to_m02_regslice_ARPROT),
        .m_axi_arqos(auto_ds_to_m02_regslice_ARQOS),
        .m_axi_arready(auto_ds_to_m02_regslice_ARREADY),
        .m_axi_arregion(auto_ds_to_m02_regslice_ARREGION),
        .m_axi_arsize(auto_ds_to_m02_regslice_ARSIZE),
        .m_axi_arvalid(auto_ds_to_m02_regslice_ARVALID),
        .m_axi_awaddr(auto_ds_to_m02_regslice_AWADDR),
        .m_axi_awburst(auto_ds_to_m02_regslice_AWBURST),
        .m_axi_awcache(auto_ds_to_m02_regslice_AWCACHE),
        .m_axi_awlen(auto_ds_to_m02_regslice_AWLEN),
        .m_axi_awlock(auto_ds_to_m02_regslice_AWLOCK),
        .m_axi_awprot(auto_ds_to_m02_regslice_AWPROT),
        .m_axi_awqos(auto_ds_to_m02_regslice_AWQOS),
        .m_axi_awready(auto_ds_to_m02_regslice_AWREADY),
        .m_axi_awregion(auto_ds_to_m02_regslice_AWREGION),
        .m_axi_awsize(auto_ds_to_m02_regslice_AWSIZE),
        .m_axi_awvalid(auto_ds_to_m02_regslice_AWVALID),
        .m_axi_bready(auto_ds_to_m02_regslice_BREADY),
        .m_axi_bresp(auto_ds_to_m02_regslice_BRESP),
        .m_axi_bvalid(auto_ds_to_m02_regslice_BVALID),
        .m_axi_rdata(auto_ds_to_m02_regslice_RDATA),
        .m_axi_rlast(auto_ds_to_m02_regslice_RLAST),
        .m_axi_rready(auto_ds_to_m02_regslice_RREADY),
        .m_axi_rresp(auto_ds_to_m02_regslice_RRESP),
        .m_axi_rvalid(auto_ds_to_m02_regslice_RVALID),
        .m_axi_wdata(auto_ds_to_m02_regslice_WDATA),
        .m_axi_wlast(auto_ds_to_m02_regslice_WLAST),
        .m_axi_wready(auto_ds_to_m02_regslice_WREADY),
        .m_axi_wstrb(auto_ds_to_m02_regslice_WSTRB),
        .m_axi_wvalid(auto_ds_to_m02_regslice_WVALID),
        .s_axi_aclk(M_ACLK_1),
        .s_axi_araddr(auto_cc_to_auto_ds_ARADDR),
        .s_axi_arburst(auto_cc_to_auto_ds_ARBURST),
        .s_axi_arcache(auto_cc_to_auto_ds_ARCACHE),
        .s_axi_aresetn(M_ARESETN_1),
        .s_axi_arid(auto_cc_to_auto_ds_ARID),
        .s_axi_arlen(auto_cc_to_auto_ds_ARLEN),
        .s_axi_arlock(auto_cc_to_auto_ds_ARLOCK),
        .s_axi_arprot(auto_cc_to_auto_ds_ARPROT),
        .s_axi_arqos(auto_cc_to_auto_ds_ARQOS),
        .s_axi_arready(auto_cc_to_auto_ds_ARREADY),
        .s_axi_arregion(auto_cc_to_auto_ds_ARREGION),
        .s_axi_arsize(auto_cc_to_auto_ds_ARSIZE),
        .s_axi_arvalid(auto_cc_to_auto_ds_ARVALID),
        .s_axi_awaddr(auto_cc_to_auto_ds_AWADDR),
        .s_axi_awburst(auto_cc_to_auto_ds_AWBURST),
        .s_axi_awcache(auto_cc_to_auto_ds_AWCACHE),
        .s_axi_awid(auto_cc_to_auto_ds_AWID),
        .s_axi_awlen(auto_cc_to_auto_ds_AWLEN),
        .s_axi_awlock(auto_cc_to_auto_ds_AWLOCK),
        .s_axi_awprot(auto_cc_to_auto_ds_AWPROT),
        .s_axi_awqos(auto_cc_to_auto_ds_AWQOS),
        .s_axi_awready(auto_cc_to_auto_ds_AWREADY),
        .s_axi_awregion(auto_cc_to_auto_ds_AWREGION),
        .s_axi_awsize(auto_cc_to_auto_ds_AWSIZE),
        .s_axi_awvalid(auto_cc_to_auto_ds_AWVALID),
        .s_axi_bid(auto_cc_to_auto_ds_BID),
        .s_axi_bready(auto_cc_to_auto_ds_BREADY),
        .s_axi_bresp(auto_cc_to_auto_ds_BRESP),
        .s_axi_bvalid(auto_cc_to_auto_ds_BVALID),
        .s_axi_rdata(auto_cc_to_auto_ds_RDATA),
        .s_axi_rid(auto_cc_to_auto_ds_RID),
        .s_axi_rlast(auto_cc_to_auto_ds_RLAST),
        .s_axi_rready(auto_cc_to_auto_ds_RREADY),
        .s_axi_rresp(auto_cc_to_auto_ds_RRESP),
        .s_axi_rvalid(auto_cc_to_auto_ds_RVALID),
        .s_axi_wdata(auto_cc_to_auto_ds_WDATA),
        .s_axi_wlast(auto_cc_to_auto_ds_WLAST),
        .s_axi_wready(auto_cc_to_auto_ds_WREADY),
        .s_axi_wstrb(auto_cc_to_auto_ds_WSTRB),
        .s_axi_wvalid(auto_cc_to_auto_ds_WVALID));
  design_ctrl_m02_regslice_0 m02_regslice
       (.aclk(M_ACLK_1),
        .aresetn(M_ARESETN_1),
        .m_axi_araddr(m02_regslice_to_m02_couplers_ARADDR),
        .m_axi_arburst(m02_regslice_to_m02_couplers_ARBURST),
        .m_axi_arcache(m02_regslice_to_m02_couplers_ARCACHE),
        .m_axi_arlen(m02_regslice_to_m02_couplers_ARLEN),
        .m_axi_arlock(m02_regslice_to_m02_couplers_ARLOCK),
        .m_axi_arprot(m02_regslice_to_m02_couplers_ARPROT),
        .m_axi_arqos(m02_regslice_to_m02_couplers_ARQOS),
        .m_axi_arready(m02_regslice_to_m02_couplers_ARREADY),
        .m_axi_arregion(m02_regslice_to_m02_couplers_ARREGION),
        .m_axi_arsize(m02_regslice_to_m02_couplers_ARSIZE),
        .m_axi_arvalid(m02_regslice_to_m02_couplers_ARVALID),
        .m_axi_awaddr(m02_regslice_to_m02_couplers_AWADDR),
        .m_axi_awburst(m02_regslice_to_m02_couplers_AWBURST),
        .m_axi_awcache(m02_regslice_to_m02_couplers_AWCACHE),
        .m_axi_awlen(m02_regslice_to_m02_couplers_AWLEN),
        .m_axi_awlock(m02_regslice_to_m02_couplers_AWLOCK),
        .m_axi_awprot(m02_regslice_to_m02_couplers_AWPROT),
        .m_axi_awqos(m02_regslice_to_m02_couplers_AWQOS),
        .m_axi_awready(m02_regslice_to_m02_couplers_AWREADY),
        .m_axi_awregion(m02_regslice_to_m02_couplers_AWREGION),
        .m_axi_awsize(m02_regslice_to_m02_couplers_AWSIZE),
        .m_axi_awvalid(m02_regslice_to_m02_couplers_AWVALID),
        .m_axi_bready(m02_regslice_to_m02_couplers_BREADY),
        .m_axi_bresp(m02_regslice_to_m02_couplers_BRESP),
        .m_axi_bvalid(m02_regslice_to_m02_couplers_BVALID),
        .m_axi_rdata(m02_regslice_to_m02_couplers_RDATA),
        .m_axi_rlast(m02_regslice_to_m02_couplers_RLAST),
        .m_axi_rready(m02_regslice_to_m02_couplers_RREADY),
        .m_axi_rresp(m02_regslice_to_m02_couplers_RRESP),
        .m_axi_rvalid(m02_regslice_to_m02_couplers_RVALID),
        .m_axi_wdata(m02_regslice_to_m02_couplers_WDATA),
        .m_axi_wlast(m02_regslice_to_m02_couplers_WLAST),
        .m_axi_wready(m02_regslice_to_m02_couplers_WREADY),
        .m_axi_wstrb(m02_regslice_to_m02_couplers_WSTRB),
        .m_axi_wvalid(m02_regslice_to_m02_couplers_WVALID),
        .s_axi_araddr(auto_ds_to_m02_regslice_ARADDR),
        .s_axi_arburst(auto_ds_to_m02_regslice_ARBURST),
        .s_axi_arcache(auto_ds_to_m02_regslice_ARCACHE),
        .s_axi_arlen(auto_ds_to_m02_regslice_ARLEN),
        .s_axi_arlock(auto_ds_to_m02_regslice_ARLOCK),
        .s_axi_arprot(auto_ds_to_m02_regslice_ARPROT),
        .s_axi_arqos(auto_ds_to_m02_regslice_ARQOS),
        .s_axi_arready(auto_ds_to_m02_regslice_ARREADY),
        .s_axi_arregion(auto_ds_to_m02_regslice_ARREGION),
        .s_axi_arsize(auto_ds_to_m02_regslice_ARSIZE),
        .s_axi_arvalid(auto_ds_to_m02_regslice_ARVALID),
        .s_axi_awaddr(auto_ds_to_m02_regslice_AWADDR),
        .s_axi_awburst(auto_ds_to_m02_regslice_AWBURST),
        .s_axi_awcache(auto_ds_to_m02_regslice_AWCACHE),
        .s_axi_awlen(auto_ds_to_m02_regslice_AWLEN),
        .s_axi_awlock(auto_ds_to_m02_regslice_AWLOCK),
        .s_axi_awprot(auto_ds_to_m02_regslice_AWPROT),
        .s_axi_awqos(auto_ds_to_m02_regslice_AWQOS),
        .s_axi_awready(auto_ds_to_m02_regslice_AWREADY),
        .s_axi_awregion(auto_ds_to_m02_regslice_AWREGION),
        .s_axi_awsize(auto_ds_to_m02_regslice_AWSIZE),
        .s_axi_awvalid(auto_ds_to_m02_regslice_AWVALID),
        .s_axi_bready(auto_ds_to_m02_regslice_BREADY),
        .s_axi_bresp(auto_ds_to_m02_regslice_BRESP),
        .s_axi_bvalid(auto_ds_to_m02_regslice_BVALID),
        .s_axi_rdata(auto_ds_to_m02_regslice_RDATA),
        .s_axi_rlast(auto_ds_to_m02_regslice_RLAST),
        .s_axi_rready(auto_ds_to_m02_regslice_RREADY),
        .s_axi_rresp(auto_ds_to_m02_regslice_RRESP),
        .s_axi_rvalid(auto_ds_to_m02_regslice_RVALID),
        .s_axi_wdata(auto_ds_to_m02_regslice_WDATA),
        .s_axi_wlast(auto_ds_to_m02_regslice_WLAST),
        .s_axi_wready(auto_ds_to_m02_regslice_WREADY),
        .s_axi_wstrb(auto_ds_to_m02_regslice_WSTRB),
        .s_axi_wvalid(auto_ds_to_m02_regslice_WVALID));
endmodule

module s00_couplers_imp_U116O1
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arburst,
    M_AXI_arcache,
    M_AXI_arid,
    M_AXI_arlen,
    M_AXI_arlock,
    M_AXI_arprot,
    M_AXI_arqos,
    M_AXI_arready,
    M_AXI_arsize,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awburst,
    M_AXI_awcache,
    M_AXI_awid,
    M_AXI_awlen,
    M_AXI_awlock,
    M_AXI_awprot,
    M_AXI_awqos,
    M_AXI_awready,
    M_AXI_awsize,
    M_AXI_awvalid,
    M_AXI_bid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rid,
    M_AXI_rlast,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wlast,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arburst,
    S_AXI_arcache,
    S_AXI_arid,
    S_AXI_arlen,
    S_AXI_arlock,
    S_AXI_arprot,
    S_AXI_arqos,
    S_AXI_arready,
    S_AXI_arregion,
    S_AXI_arsize,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awburst,
    S_AXI_awcache,
    S_AXI_awid,
    S_AXI_awlen,
    S_AXI_awlock,
    S_AXI_awprot,
    S_AXI_awqos,
    S_AXI_awready,
    S_AXI_awregion,
    S_AXI_awsize,
    S_AXI_awvalid,
    S_AXI_bid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rid,
    S_AXI_rlast,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wlast,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input M_ARESETN;
  output [63:0]M_AXI_araddr;
  output [1:0]M_AXI_arburst;
  output [3:0]M_AXI_arcache;
  output [5:0]M_AXI_arid;
  output [7:0]M_AXI_arlen;
  output [0:0]M_AXI_arlock;
  output [2:0]M_AXI_arprot;
  output [3:0]M_AXI_arqos;
  input M_AXI_arready;
  output [2:0]M_AXI_arsize;
  output M_AXI_arvalid;
  output [63:0]M_AXI_awaddr;
  output [1:0]M_AXI_awburst;
  output [3:0]M_AXI_awcache;
  output [5:0]M_AXI_awid;
  output [7:0]M_AXI_awlen;
  output [0:0]M_AXI_awlock;
  output [2:0]M_AXI_awprot;
  output [3:0]M_AXI_awqos;
  input M_AXI_awready;
  output [2:0]M_AXI_awsize;
  output M_AXI_awvalid;
  input [5:0]M_AXI_bid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [511:0]M_AXI_rdata;
  input [5:0]M_AXI_rid;
  input M_AXI_rlast;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [511:0]M_AXI_wdata;
  output M_AXI_wlast;
  input M_AXI_wready;
  output [63:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input S_ACLK;
  input S_ARESETN;
  input [63:0]S_AXI_araddr;
  input [1:0]S_AXI_arburst;
  input [3:0]S_AXI_arcache;
  input [5:0]S_AXI_arid;
  input [7:0]S_AXI_arlen;
  input [0:0]S_AXI_arlock;
  input [2:0]S_AXI_arprot;
  input [3:0]S_AXI_arqos;
  output S_AXI_arready;
  input [3:0]S_AXI_arregion;
  input [2:0]S_AXI_arsize;
  input S_AXI_arvalid;
  input [63:0]S_AXI_awaddr;
  input [1:0]S_AXI_awburst;
  input [3:0]S_AXI_awcache;
  input [5:0]S_AXI_awid;
  input [7:0]S_AXI_awlen;
  input [0:0]S_AXI_awlock;
  input [2:0]S_AXI_awprot;
  input [3:0]S_AXI_awqos;
  output S_AXI_awready;
  input [3:0]S_AXI_awregion;
  input [2:0]S_AXI_awsize;
  input S_AXI_awvalid;
  output [5:0]S_AXI_bid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [511:0]S_AXI_rdata;
  output [5:0]S_AXI_rid;
  output S_AXI_rlast;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [511:0]S_AXI_wdata;
  input S_AXI_wlast;
  output S_AXI_wready;
  input [63:0]S_AXI_wstrb;
  input S_AXI_wvalid;

  wire M_ACLK_1;
  wire M_ARESETN_1;
  wire S_ACLK_1;
  wire S_ARESETN_1;
  wire [63:0]s00_couplers_to_s00_regslice_ARADDR;
  wire [1:0]s00_couplers_to_s00_regslice_ARBURST;
  wire [3:0]s00_couplers_to_s00_regslice_ARCACHE;
  wire [5:0]s00_couplers_to_s00_regslice_ARID;
  wire [7:0]s00_couplers_to_s00_regslice_ARLEN;
  wire [0:0]s00_couplers_to_s00_regslice_ARLOCK;
  wire [2:0]s00_couplers_to_s00_regslice_ARPROT;
  wire [3:0]s00_couplers_to_s00_regslice_ARQOS;
  wire s00_couplers_to_s00_regslice_ARREADY;
  wire [3:0]s00_couplers_to_s00_regslice_ARREGION;
  wire [2:0]s00_couplers_to_s00_regslice_ARSIZE;
  wire s00_couplers_to_s00_regslice_ARVALID;
  wire [63:0]s00_couplers_to_s00_regslice_AWADDR;
  wire [1:0]s00_couplers_to_s00_regslice_AWBURST;
  wire [3:0]s00_couplers_to_s00_regslice_AWCACHE;
  wire [5:0]s00_couplers_to_s00_regslice_AWID;
  wire [7:0]s00_couplers_to_s00_regslice_AWLEN;
  wire [0:0]s00_couplers_to_s00_regslice_AWLOCK;
  wire [2:0]s00_couplers_to_s00_regslice_AWPROT;
  wire [3:0]s00_couplers_to_s00_regslice_AWQOS;
  wire s00_couplers_to_s00_regslice_AWREADY;
  wire [3:0]s00_couplers_to_s00_regslice_AWREGION;
  wire [2:0]s00_couplers_to_s00_regslice_AWSIZE;
  wire s00_couplers_to_s00_regslice_AWVALID;
  wire [5:0]s00_couplers_to_s00_regslice_BID;
  wire s00_couplers_to_s00_regslice_BREADY;
  wire [1:0]s00_couplers_to_s00_regslice_BRESP;
  wire s00_couplers_to_s00_regslice_BVALID;
  wire [511:0]s00_couplers_to_s00_regslice_RDATA;
  wire [5:0]s00_couplers_to_s00_regslice_RID;
  wire s00_couplers_to_s00_regslice_RLAST;
  wire s00_couplers_to_s00_regslice_RREADY;
  wire [1:0]s00_couplers_to_s00_regslice_RRESP;
  wire s00_couplers_to_s00_regslice_RVALID;
  wire [511:0]s00_couplers_to_s00_regslice_WDATA;
  wire s00_couplers_to_s00_regslice_WLAST;
  wire s00_couplers_to_s00_regslice_WREADY;
  wire [63:0]s00_couplers_to_s00_regslice_WSTRB;
  wire s00_couplers_to_s00_regslice_WVALID;
  wire [63:0]s00_data_fifo_to_s00_couplers_ARADDR;
  wire [1:0]s00_data_fifo_to_s00_couplers_ARBURST;
  wire [3:0]s00_data_fifo_to_s00_couplers_ARCACHE;
  wire [5:0]s00_data_fifo_to_s00_couplers_ARID;
  wire [7:0]s00_data_fifo_to_s00_couplers_ARLEN;
  wire [0:0]s00_data_fifo_to_s00_couplers_ARLOCK;
  wire [2:0]s00_data_fifo_to_s00_couplers_ARPROT;
  wire [3:0]s00_data_fifo_to_s00_couplers_ARQOS;
  wire s00_data_fifo_to_s00_couplers_ARREADY;
  wire [2:0]s00_data_fifo_to_s00_couplers_ARSIZE;
  wire s00_data_fifo_to_s00_couplers_ARVALID;
  wire [63:0]s00_data_fifo_to_s00_couplers_AWADDR;
  wire [1:0]s00_data_fifo_to_s00_couplers_AWBURST;
  wire [3:0]s00_data_fifo_to_s00_couplers_AWCACHE;
  wire [5:0]s00_data_fifo_to_s00_couplers_AWID;
  wire [7:0]s00_data_fifo_to_s00_couplers_AWLEN;
  wire [0:0]s00_data_fifo_to_s00_couplers_AWLOCK;
  wire [2:0]s00_data_fifo_to_s00_couplers_AWPROT;
  wire [3:0]s00_data_fifo_to_s00_couplers_AWQOS;
  wire s00_data_fifo_to_s00_couplers_AWREADY;
  wire [2:0]s00_data_fifo_to_s00_couplers_AWSIZE;
  wire s00_data_fifo_to_s00_couplers_AWVALID;
  wire [5:0]s00_data_fifo_to_s00_couplers_BID;
  wire s00_data_fifo_to_s00_couplers_BREADY;
  wire [1:0]s00_data_fifo_to_s00_couplers_BRESP;
  wire s00_data_fifo_to_s00_couplers_BVALID;
  wire [511:0]s00_data_fifo_to_s00_couplers_RDATA;
  wire [5:0]s00_data_fifo_to_s00_couplers_RID;
  wire s00_data_fifo_to_s00_couplers_RLAST;
  wire s00_data_fifo_to_s00_couplers_RREADY;
  wire [1:0]s00_data_fifo_to_s00_couplers_RRESP;
  wire s00_data_fifo_to_s00_couplers_RVALID;
  wire [511:0]s00_data_fifo_to_s00_couplers_WDATA;
  wire s00_data_fifo_to_s00_couplers_WLAST;
  wire s00_data_fifo_to_s00_couplers_WREADY;
  wire [63:0]s00_data_fifo_to_s00_couplers_WSTRB;
  wire s00_data_fifo_to_s00_couplers_WVALID;
  wire [63:0]s00_regslice_to_s00_data_fifo_ARADDR;
  wire [1:0]s00_regslice_to_s00_data_fifo_ARBURST;
  wire [3:0]s00_regslice_to_s00_data_fifo_ARCACHE;
  wire [5:0]s00_regslice_to_s00_data_fifo_ARID;
  wire [7:0]s00_regslice_to_s00_data_fifo_ARLEN;
  wire [0:0]s00_regslice_to_s00_data_fifo_ARLOCK;
  wire [2:0]s00_regslice_to_s00_data_fifo_ARPROT;
  wire [3:0]s00_regslice_to_s00_data_fifo_ARQOS;
  wire s00_regslice_to_s00_data_fifo_ARREADY;
  wire [3:0]s00_regslice_to_s00_data_fifo_ARREGION;
  wire [2:0]s00_regslice_to_s00_data_fifo_ARSIZE;
  wire s00_regslice_to_s00_data_fifo_ARVALID;
  wire [63:0]s00_regslice_to_s00_data_fifo_AWADDR;
  wire [1:0]s00_regslice_to_s00_data_fifo_AWBURST;
  wire [3:0]s00_regslice_to_s00_data_fifo_AWCACHE;
  wire [5:0]s00_regslice_to_s00_data_fifo_AWID;
  wire [7:0]s00_regslice_to_s00_data_fifo_AWLEN;
  wire [0:0]s00_regslice_to_s00_data_fifo_AWLOCK;
  wire [2:0]s00_regslice_to_s00_data_fifo_AWPROT;
  wire [3:0]s00_regslice_to_s00_data_fifo_AWQOS;
  wire s00_regslice_to_s00_data_fifo_AWREADY;
  wire [3:0]s00_regslice_to_s00_data_fifo_AWREGION;
  wire [2:0]s00_regslice_to_s00_data_fifo_AWSIZE;
  wire s00_regslice_to_s00_data_fifo_AWVALID;
  wire [5:0]s00_regslice_to_s00_data_fifo_BID;
  wire s00_regslice_to_s00_data_fifo_BREADY;
  wire [1:0]s00_regslice_to_s00_data_fifo_BRESP;
  wire s00_regslice_to_s00_data_fifo_BVALID;
  wire [511:0]s00_regslice_to_s00_data_fifo_RDATA;
  wire [5:0]s00_regslice_to_s00_data_fifo_RID;
  wire s00_regslice_to_s00_data_fifo_RLAST;
  wire s00_regslice_to_s00_data_fifo_RREADY;
  wire [1:0]s00_regslice_to_s00_data_fifo_RRESP;
  wire s00_regslice_to_s00_data_fifo_RVALID;
  wire [511:0]s00_regslice_to_s00_data_fifo_WDATA;
  wire s00_regslice_to_s00_data_fifo_WLAST;
  wire s00_regslice_to_s00_data_fifo_WREADY;
  wire [63:0]s00_regslice_to_s00_data_fifo_WSTRB;
  wire s00_regslice_to_s00_data_fifo_WVALID;

  assign M_ACLK_1 = M_ACLK;
  assign M_ARESETN_1 = M_ARESETN;
  assign M_AXI_araddr[63:0] = s00_data_fifo_to_s00_couplers_ARADDR;
  assign M_AXI_arburst[1:0] = s00_data_fifo_to_s00_couplers_ARBURST;
  assign M_AXI_arcache[3:0] = s00_data_fifo_to_s00_couplers_ARCACHE;
  assign M_AXI_arid[5:0] = s00_data_fifo_to_s00_couplers_ARID;
  assign M_AXI_arlen[7:0] = s00_data_fifo_to_s00_couplers_ARLEN;
  assign M_AXI_arlock[0] = s00_data_fifo_to_s00_couplers_ARLOCK;
  assign M_AXI_arprot[2:0] = s00_data_fifo_to_s00_couplers_ARPROT;
  assign M_AXI_arqos[3:0] = s00_data_fifo_to_s00_couplers_ARQOS;
  assign M_AXI_arsize[2:0] = s00_data_fifo_to_s00_couplers_ARSIZE;
  assign M_AXI_arvalid = s00_data_fifo_to_s00_couplers_ARVALID;
  assign M_AXI_awaddr[63:0] = s00_data_fifo_to_s00_couplers_AWADDR;
  assign M_AXI_awburst[1:0] = s00_data_fifo_to_s00_couplers_AWBURST;
  assign M_AXI_awcache[3:0] = s00_data_fifo_to_s00_couplers_AWCACHE;
  assign M_AXI_awid[5:0] = s00_data_fifo_to_s00_couplers_AWID;
  assign M_AXI_awlen[7:0] = s00_data_fifo_to_s00_couplers_AWLEN;
  assign M_AXI_awlock[0] = s00_data_fifo_to_s00_couplers_AWLOCK;
  assign M_AXI_awprot[2:0] = s00_data_fifo_to_s00_couplers_AWPROT;
  assign M_AXI_awqos[3:0] = s00_data_fifo_to_s00_couplers_AWQOS;
  assign M_AXI_awsize[2:0] = s00_data_fifo_to_s00_couplers_AWSIZE;
  assign M_AXI_awvalid = s00_data_fifo_to_s00_couplers_AWVALID;
  assign M_AXI_bready = s00_data_fifo_to_s00_couplers_BREADY;
  assign M_AXI_rready = s00_data_fifo_to_s00_couplers_RREADY;
  assign M_AXI_wdata[511:0] = s00_data_fifo_to_s00_couplers_WDATA;
  assign M_AXI_wlast = s00_data_fifo_to_s00_couplers_WLAST;
  assign M_AXI_wstrb[63:0] = s00_data_fifo_to_s00_couplers_WSTRB;
  assign M_AXI_wvalid = s00_data_fifo_to_s00_couplers_WVALID;
  assign S_ACLK_1 = S_ACLK;
  assign S_ARESETN_1 = S_ARESETN;
  assign S_AXI_arready = s00_couplers_to_s00_regslice_ARREADY;
  assign S_AXI_awready = s00_couplers_to_s00_regslice_AWREADY;
  assign S_AXI_bid[5:0] = s00_couplers_to_s00_regslice_BID;
  assign S_AXI_bresp[1:0] = s00_couplers_to_s00_regslice_BRESP;
  assign S_AXI_bvalid = s00_couplers_to_s00_regslice_BVALID;
  assign S_AXI_rdata[511:0] = s00_couplers_to_s00_regslice_RDATA;
  assign S_AXI_rid[5:0] = s00_couplers_to_s00_regslice_RID;
  assign S_AXI_rlast = s00_couplers_to_s00_regslice_RLAST;
  assign S_AXI_rresp[1:0] = s00_couplers_to_s00_regslice_RRESP;
  assign S_AXI_rvalid = s00_couplers_to_s00_regslice_RVALID;
  assign S_AXI_wready = s00_couplers_to_s00_regslice_WREADY;
  assign s00_couplers_to_s00_regslice_ARADDR = S_AXI_araddr[63:0];
  assign s00_couplers_to_s00_regslice_ARBURST = S_AXI_arburst[1:0];
  assign s00_couplers_to_s00_regslice_ARCACHE = S_AXI_arcache[3:0];
  assign s00_couplers_to_s00_regslice_ARID = S_AXI_arid[5:0];
  assign s00_couplers_to_s00_regslice_ARLEN = S_AXI_arlen[7:0];
  assign s00_couplers_to_s00_regslice_ARLOCK = S_AXI_arlock[0];
  assign s00_couplers_to_s00_regslice_ARPROT = S_AXI_arprot[2:0];
  assign s00_couplers_to_s00_regslice_ARQOS = S_AXI_arqos[3:0];
  assign s00_couplers_to_s00_regslice_ARREGION = S_AXI_arregion[3:0];
  assign s00_couplers_to_s00_regslice_ARSIZE = S_AXI_arsize[2:0];
  assign s00_couplers_to_s00_regslice_ARVALID = S_AXI_arvalid;
  assign s00_couplers_to_s00_regslice_AWADDR = S_AXI_awaddr[63:0];
  assign s00_couplers_to_s00_regslice_AWBURST = S_AXI_awburst[1:0];
  assign s00_couplers_to_s00_regslice_AWCACHE = S_AXI_awcache[3:0];
  assign s00_couplers_to_s00_regslice_AWID = S_AXI_awid[5:0];
  assign s00_couplers_to_s00_regslice_AWLEN = S_AXI_awlen[7:0];
  assign s00_couplers_to_s00_regslice_AWLOCK = S_AXI_awlock[0];
  assign s00_couplers_to_s00_regslice_AWPROT = S_AXI_awprot[2:0];
  assign s00_couplers_to_s00_regslice_AWQOS = S_AXI_awqos[3:0];
  assign s00_couplers_to_s00_regslice_AWREGION = S_AXI_awregion[3:0];
  assign s00_couplers_to_s00_regslice_AWSIZE = S_AXI_awsize[2:0];
  assign s00_couplers_to_s00_regslice_AWVALID = S_AXI_awvalid;
  assign s00_couplers_to_s00_regslice_BREADY = S_AXI_bready;
  assign s00_couplers_to_s00_regslice_RREADY = S_AXI_rready;
  assign s00_couplers_to_s00_regslice_WDATA = S_AXI_wdata[511:0];
  assign s00_couplers_to_s00_regslice_WLAST = S_AXI_wlast;
  assign s00_couplers_to_s00_regslice_WSTRB = S_AXI_wstrb[63:0];
  assign s00_couplers_to_s00_regslice_WVALID = S_AXI_wvalid;
  assign s00_data_fifo_to_s00_couplers_ARREADY = M_AXI_arready;
  assign s00_data_fifo_to_s00_couplers_AWREADY = M_AXI_awready;
  assign s00_data_fifo_to_s00_couplers_BID = M_AXI_bid[5:0];
  assign s00_data_fifo_to_s00_couplers_BRESP = M_AXI_bresp[1:0];
  assign s00_data_fifo_to_s00_couplers_BVALID = M_AXI_bvalid;
  assign s00_data_fifo_to_s00_couplers_RDATA = M_AXI_rdata[511:0];
  assign s00_data_fifo_to_s00_couplers_RID = M_AXI_rid[5:0];
  assign s00_data_fifo_to_s00_couplers_RLAST = M_AXI_rlast;
  assign s00_data_fifo_to_s00_couplers_RRESP = M_AXI_rresp[1:0];
  assign s00_data_fifo_to_s00_couplers_RVALID = M_AXI_rvalid;
  assign s00_data_fifo_to_s00_couplers_WREADY = M_AXI_wready;
  design_ctrl_s00_data_fifo_0 s00_data_fifo
       (.aclk(M_ACLK_1),
        .aresetn(M_ARESETN_1),
        .m_axi_araddr(s00_data_fifo_to_s00_couplers_ARADDR),
        .m_axi_arburst(s00_data_fifo_to_s00_couplers_ARBURST),
        .m_axi_arcache(s00_data_fifo_to_s00_couplers_ARCACHE),
        .m_axi_arid(s00_data_fifo_to_s00_couplers_ARID),
        .m_axi_arlen(s00_data_fifo_to_s00_couplers_ARLEN),
        .m_axi_arlock(s00_data_fifo_to_s00_couplers_ARLOCK),
        .m_axi_arprot(s00_data_fifo_to_s00_couplers_ARPROT),
        .m_axi_arqos(s00_data_fifo_to_s00_couplers_ARQOS),
        .m_axi_arready(s00_data_fifo_to_s00_couplers_ARREADY),
        .m_axi_arsize(s00_data_fifo_to_s00_couplers_ARSIZE),
        .m_axi_arvalid(s00_data_fifo_to_s00_couplers_ARVALID),
        .m_axi_awaddr(s00_data_fifo_to_s00_couplers_AWADDR),
        .m_axi_awburst(s00_data_fifo_to_s00_couplers_AWBURST),
        .m_axi_awcache(s00_data_fifo_to_s00_couplers_AWCACHE),
        .m_axi_awid(s00_data_fifo_to_s00_couplers_AWID),
        .m_axi_awlen(s00_data_fifo_to_s00_couplers_AWLEN),
        .m_axi_awlock(s00_data_fifo_to_s00_couplers_AWLOCK),
        .m_axi_awprot(s00_data_fifo_to_s00_couplers_AWPROT),
        .m_axi_awqos(s00_data_fifo_to_s00_couplers_AWQOS),
        .m_axi_awready(s00_data_fifo_to_s00_couplers_AWREADY),
        .m_axi_awsize(s00_data_fifo_to_s00_couplers_AWSIZE),
        .m_axi_awvalid(s00_data_fifo_to_s00_couplers_AWVALID),
        .m_axi_bid(s00_data_fifo_to_s00_couplers_BID),
        .m_axi_bready(s00_data_fifo_to_s00_couplers_BREADY),
        .m_axi_bresp(s00_data_fifo_to_s00_couplers_BRESP),
        .m_axi_bvalid(s00_data_fifo_to_s00_couplers_BVALID),
        .m_axi_rdata(s00_data_fifo_to_s00_couplers_RDATA),
        .m_axi_rid(s00_data_fifo_to_s00_couplers_RID),
        .m_axi_rlast(s00_data_fifo_to_s00_couplers_RLAST),
        .m_axi_rready(s00_data_fifo_to_s00_couplers_RREADY),
        .m_axi_rresp(s00_data_fifo_to_s00_couplers_RRESP),
        .m_axi_rvalid(s00_data_fifo_to_s00_couplers_RVALID),
        .m_axi_wdata(s00_data_fifo_to_s00_couplers_WDATA),
        .m_axi_wlast(s00_data_fifo_to_s00_couplers_WLAST),
        .m_axi_wready(s00_data_fifo_to_s00_couplers_WREADY),
        .m_axi_wstrb(s00_data_fifo_to_s00_couplers_WSTRB),
        .m_axi_wvalid(s00_data_fifo_to_s00_couplers_WVALID),
        .s_axi_araddr(s00_regslice_to_s00_data_fifo_ARADDR),
        .s_axi_arburst(s00_regslice_to_s00_data_fifo_ARBURST),
        .s_axi_arcache(s00_regslice_to_s00_data_fifo_ARCACHE),
        .s_axi_arid(s00_regslice_to_s00_data_fifo_ARID),
        .s_axi_arlen(s00_regslice_to_s00_data_fifo_ARLEN),
        .s_axi_arlock(s00_regslice_to_s00_data_fifo_ARLOCK),
        .s_axi_arprot(s00_regslice_to_s00_data_fifo_ARPROT),
        .s_axi_arqos(s00_regslice_to_s00_data_fifo_ARQOS),
        .s_axi_arready(s00_regslice_to_s00_data_fifo_ARREADY),
        .s_axi_arregion(s00_regslice_to_s00_data_fifo_ARREGION),
        .s_axi_arsize(s00_regslice_to_s00_data_fifo_ARSIZE),
        .s_axi_arvalid(s00_regslice_to_s00_data_fifo_ARVALID),
        .s_axi_awaddr(s00_regslice_to_s00_data_fifo_AWADDR),
        .s_axi_awburst(s00_regslice_to_s00_data_fifo_AWBURST),
        .s_axi_awcache(s00_regslice_to_s00_data_fifo_AWCACHE),
        .s_axi_awid(s00_regslice_to_s00_data_fifo_AWID),
        .s_axi_awlen(s00_regslice_to_s00_data_fifo_AWLEN),
        .s_axi_awlock(s00_regslice_to_s00_data_fifo_AWLOCK),
        .s_axi_awprot(s00_regslice_to_s00_data_fifo_AWPROT),
        .s_axi_awqos(s00_regslice_to_s00_data_fifo_AWQOS),
        .s_axi_awready(s00_regslice_to_s00_data_fifo_AWREADY),
        .s_axi_awregion(s00_regslice_to_s00_data_fifo_AWREGION),
        .s_axi_awsize(s00_regslice_to_s00_data_fifo_AWSIZE),
        .s_axi_awvalid(s00_regslice_to_s00_data_fifo_AWVALID),
        .s_axi_bid(s00_regslice_to_s00_data_fifo_BID),
        .s_axi_bready(s00_regslice_to_s00_data_fifo_BREADY),
        .s_axi_bresp(s00_regslice_to_s00_data_fifo_BRESP),
        .s_axi_bvalid(s00_regslice_to_s00_data_fifo_BVALID),
        .s_axi_rdata(s00_regslice_to_s00_data_fifo_RDATA),
        .s_axi_rid(s00_regslice_to_s00_data_fifo_RID),
        .s_axi_rlast(s00_regslice_to_s00_data_fifo_RLAST),
        .s_axi_rready(s00_regslice_to_s00_data_fifo_RREADY),
        .s_axi_rresp(s00_regslice_to_s00_data_fifo_RRESP),
        .s_axi_rvalid(s00_regslice_to_s00_data_fifo_RVALID),
        .s_axi_wdata(s00_regslice_to_s00_data_fifo_WDATA),
        .s_axi_wlast(s00_regslice_to_s00_data_fifo_WLAST),
        .s_axi_wready(s00_regslice_to_s00_data_fifo_WREADY),
        .s_axi_wstrb(s00_regslice_to_s00_data_fifo_WSTRB),
        .s_axi_wvalid(s00_regslice_to_s00_data_fifo_WVALID));
  design_ctrl_s00_regslice_0 s00_regslice
       (.aclk(S_ACLK_1),
        .aresetn(S_ARESETN_1),
        .m_axi_araddr(s00_regslice_to_s00_data_fifo_ARADDR),
        .m_axi_arburst(s00_regslice_to_s00_data_fifo_ARBURST),
        .m_axi_arcache(s00_regslice_to_s00_data_fifo_ARCACHE),
        .m_axi_arid(s00_regslice_to_s00_data_fifo_ARID),
        .m_axi_arlen(s00_regslice_to_s00_data_fifo_ARLEN),
        .m_axi_arlock(s00_regslice_to_s00_data_fifo_ARLOCK),
        .m_axi_arprot(s00_regslice_to_s00_data_fifo_ARPROT),
        .m_axi_arqos(s00_regslice_to_s00_data_fifo_ARQOS),
        .m_axi_arready(s00_regslice_to_s00_data_fifo_ARREADY),
        .m_axi_arregion(s00_regslice_to_s00_data_fifo_ARREGION),
        .m_axi_arsize(s00_regslice_to_s00_data_fifo_ARSIZE),
        .m_axi_arvalid(s00_regslice_to_s00_data_fifo_ARVALID),
        .m_axi_awaddr(s00_regslice_to_s00_data_fifo_AWADDR),
        .m_axi_awburst(s00_regslice_to_s00_data_fifo_AWBURST),
        .m_axi_awcache(s00_regslice_to_s00_data_fifo_AWCACHE),
        .m_axi_awid(s00_regslice_to_s00_data_fifo_AWID),
        .m_axi_awlen(s00_regslice_to_s00_data_fifo_AWLEN),
        .m_axi_awlock(s00_regslice_to_s00_data_fifo_AWLOCK),
        .m_axi_awprot(s00_regslice_to_s00_data_fifo_AWPROT),
        .m_axi_awqos(s00_regslice_to_s00_data_fifo_AWQOS),
        .m_axi_awready(s00_regslice_to_s00_data_fifo_AWREADY),
        .m_axi_awregion(s00_regslice_to_s00_data_fifo_AWREGION),
        .m_axi_awsize(s00_regslice_to_s00_data_fifo_AWSIZE),
        .m_axi_awvalid(s00_regslice_to_s00_data_fifo_AWVALID),
        .m_axi_bid(s00_regslice_to_s00_data_fifo_BID),
        .m_axi_bready(s00_regslice_to_s00_data_fifo_BREADY),
        .m_axi_bresp(s00_regslice_to_s00_data_fifo_BRESP),
        .m_axi_bvalid(s00_regslice_to_s00_data_fifo_BVALID),
        .m_axi_rdata(s00_regslice_to_s00_data_fifo_RDATA),
        .m_axi_rid(s00_regslice_to_s00_data_fifo_RID),
        .m_axi_rlast(s00_regslice_to_s00_data_fifo_RLAST),
        .m_axi_rready(s00_regslice_to_s00_data_fifo_RREADY),
        .m_axi_rresp(s00_regslice_to_s00_data_fifo_RRESP),
        .m_axi_rvalid(s00_regslice_to_s00_data_fifo_RVALID),
        .m_axi_wdata(s00_regslice_to_s00_data_fifo_WDATA),
        .m_axi_wlast(s00_regslice_to_s00_data_fifo_WLAST),
        .m_axi_wready(s00_regslice_to_s00_data_fifo_WREADY),
        .m_axi_wstrb(s00_regslice_to_s00_data_fifo_WSTRB),
        .m_axi_wvalid(s00_regslice_to_s00_data_fifo_WVALID),
        .s_axi_araddr(s00_couplers_to_s00_regslice_ARADDR),
        .s_axi_arburst(s00_couplers_to_s00_regslice_ARBURST),
        .s_axi_arcache(s00_couplers_to_s00_regslice_ARCACHE),
        .s_axi_arid(s00_couplers_to_s00_regslice_ARID),
        .s_axi_arlen(s00_couplers_to_s00_regslice_ARLEN),
        .s_axi_arlock(s00_couplers_to_s00_regslice_ARLOCK),
        .s_axi_arprot(s00_couplers_to_s00_regslice_ARPROT),
        .s_axi_arqos(s00_couplers_to_s00_regslice_ARQOS),
        .s_axi_arready(s00_couplers_to_s00_regslice_ARREADY),
        .s_axi_arregion(s00_couplers_to_s00_regslice_ARREGION),
        .s_axi_arsize(s00_couplers_to_s00_regslice_ARSIZE),
        .s_axi_arvalid(s00_couplers_to_s00_regslice_ARVALID),
        .s_axi_awaddr(s00_couplers_to_s00_regslice_AWADDR),
        .s_axi_awburst(s00_couplers_to_s00_regslice_AWBURST),
        .s_axi_awcache(s00_couplers_to_s00_regslice_AWCACHE),
        .s_axi_awid(s00_couplers_to_s00_regslice_AWID),
        .s_axi_awlen(s00_couplers_to_s00_regslice_AWLEN),
        .s_axi_awlock(s00_couplers_to_s00_regslice_AWLOCK),
        .s_axi_awprot(s00_couplers_to_s00_regslice_AWPROT),
        .s_axi_awqos(s00_couplers_to_s00_regslice_AWQOS),
        .s_axi_awready(s00_couplers_to_s00_regslice_AWREADY),
        .s_axi_awregion(s00_couplers_to_s00_regslice_AWREGION),
        .s_axi_awsize(s00_couplers_to_s00_regslice_AWSIZE),
        .s_axi_awvalid(s00_couplers_to_s00_regslice_AWVALID),
        .s_axi_bid(s00_couplers_to_s00_regslice_BID),
        .s_axi_bready(s00_couplers_to_s00_regslice_BREADY),
        .s_axi_bresp(s00_couplers_to_s00_regslice_BRESP),
        .s_axi_bvalid(s00_couplers_to_s00_regslice_BVALID),
        .s_axi_rdata(s00_couplers_to_s00_regslice_RDATA),
        .s_axi_rid(s00_couplers_to_s00_regslice_RID),
        .s_axi_rlast(s00_couplers_to_s00_regslice_RLAST),
        .s_axi_rready(s00_couplers_to_s00_regslice_RREADY),
        .s_axi_rresp(s00_couplers_to_s00_regslice_RRESP),
        .s_axi_rvalid(s00_couplers_to_s00_regslice_RVALID),
        .s_axi_wdata(s00_couplers_to_s00_regslice_WDATA),
        .s_axi_wlast(s00_couplers_to_s00_regslice_WLAST),
        .s_axi_wready(s00_couplers_to_s00_regslice_WREADY),
        .s_axi_wstrb(s00_couplers_to_s00_regslice_WSTRB),
        .s_axi_wvalid(s00_couplers_to_s00_regslice_WVALID));
endmodule
