//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.1 (lin64) Build 3526262 Mon Apr 18 15:47:01 MDT 2022
//Date        : Wed Nov 27 16:16:59 2024
//Host        : amy running 64-bit NixOS 24.05 (Uakari)
//Command     : generate_target design_ctrl_wrapper.bd
//Design      : design_ctrl_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_ctrl_wrapper
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
  output aclk;
  output [0:0]aresetn;
  output [63:0]axi_cnfg_araddr;
  output [2:0]axi_cnfg_arprot;
  input axi_cnfg_arready;
  output axi_cnfg_arvalid;
  output [63:0]axi_cnfg_awaddr;
  output [2:0]axi_cnfg_awprot;
  input axi_cnfg_awready;
  output axi_cnfg_awvalid;
  output axi_cnfg_bready;
  input [1:0]axi_cnfg_bresp;
  input axi_cnfg_bvalid;
  input [63:0]axi_cnfg_rdata;
  output axi_cnfg_rready;
  input [1:0]axi_cnfg_rresp;
  input axi_cnfg_rvalid;
  output [63:0]axi_cnfg_wdata;
  input axi_cnfg_wready;
  output [7:0]axi_cnfg_wstrb;
  output axi_cnfg_wvalid;
  output [63:0]axi_ctrl_0_araddr;
  output [2:0]axi_ctrl_0_arprot;
  input axi_ctrl_0_arready;
  output axi_ctrl_0_arvalid;
  output [63:0]axi_ctrl_0_awaddr;
  output [2:0]axi_ctrl_0_awprot;
  input axi_ctrl_0_awready;
  output axi_ctrl_0_awvalid;
  output axi_ctrl_0_bready;
  input [1:0]axi_ctrl_0_bresp;
  input axi_ctrl_0_bvalid;
  input [63:0]axi_ctrl_0_rdata;
  output axi_ctrl_0_rready;
  input [1:0]axi_ctrl_0_rresp;
  input axi_ctrl_0_rvalid;
  output [63:0]axi_ctrl_0_wdata;
  input axi_ctrl_0_wready;
  output [7:0]axi_ctrl_0_wstrb;
  output axi_ctrl_0_wvalid;
  input [63:0]axi_main_araddr;
  input [1:0]axi_main_arburst;
  input [3:0]axi_main_arcache;
  input [5:0]axi_main_arid;
  input [7:0]axi_main_arlen;
  input [0:0]axi_main_arlock;
  input [2:0]axi_main_arprot;
  input [3:0]axi_main_arqos;
  output axi_main_arready;
  input [3:0]axi_main_arregion;
  input [2:0]axi_main_arsize;
  input axi_main_arvalid;
  input [63:0]axi_main_awaddr;
  input [1:0]axi_main_awburst;
  input [3:0]axi_main_awcache;
  input [5:0]axi_main_awid;
  input [7:0]axi_main_awlen;
  input [0:0]axi_main_awlock;
  input [2:0]axi_main_awprot;
  input [3:0]axi_main_awqos;
  output axi_main_awready;
  input [3:0]axi_main_awregion;
  input [2:0]axi_main_awsize;
  input axi_main_awvalid;
  output [5:0]axi_main_bid;
  input axi_main_bready;
  output [1:0]axi_main_bresp;
  output axi_main_bvalid;
  output [511:0]axi_main_rdata;
  output [5:0]axi_main_rid;
  output axi_main_rlast;
  input axi_main_rready;
  output [1:0]axi_main_rresp;
  output axi_main_rvalid;
  input [511:0]axi_main_wdata;
  input axi_main_wlast;
  output axi_main_wready;
  input [63:0]axi_main_wstrb;
  input axi_main_wvalid;
  output [63:0]axim_ctrl_0_araddr;
  output [1:0]axim_ctrl_0_arburst;
  output [3:0]axim_ctrl_0_arcache;
  output [7:0]axim_ctrl_0_arlen;
  output [0:0]axim_ctrl_0_arlock;
  output [2:0]axim_ctrl_0_arprot;
  output [3:0]axim_ctrl_0_arqos;
  input axim_ctrl_0_arready;
  output [3:0]axim_ctrl_0_arregion;
  output [2:0]axim_ctrl_0_arsize;
  output axim_ctrl_0_arvalid;
  output [63:0]axim_ctrl_0_awaddr;
  output [1:0]axim_ctrl_0_awburst;
  output [3:0]axim_ctrl_0_awcache;
  output [7:0]axim_ctrl_0_awlen;
  output [0:0]axim_ctrl_0_awlock;
  output [2:0]axim_ctrl_0_awprot;
  output [3:0]axim_ctrl_0_awqos;
  input axim_ctrl_0_awready;
  output [3:0]axim_ctrl_0_awregion;
  output [2:0]axim_ctrl_0_awsize;
  output axim_ctrl_0_awvalid;
  output axim_ctrl_0_bready;
  input [1:0]axim_ctrl_0_bresp;
  input axim_ctrl_0_bvalid;
  input [255:0]axim_ctrl_0_rdata;
  input axim_ctrl_0_rlast;
  output axim_ctrl_0_rready;
  input [1:0]axim_ctrl_0_rresp;
  input axim_ctrl_0_rvalid;
  output [255:0]axim_ctrl_0_wdata;
  output axim_ctrl_0_wlast;
  input axim_ctrl_0_wready;
  output [31:0]axim_ctrl_0_wstrb;
  output axim_ctrl_0_wvalid;
  output lckresetn;
  output nclk;
  output [0:0]nresetn;
  input sys_reset;
  output uclk;
  output [0:0]uresetn;
  input xclk;
  input xresetn;

  wire aclk;
  wire [0:0]aresetn;
  wire [63:0]axi_cnfg_araddr;
  wire [2:0]axi_cnfg_arprot;
  wire axi_cnfg_arready;
  wire axi_cnfg_arvalid;
  wire [63:0]axi_cnfg_awaddr;
  wire [2:0]axi_cnfg_awprot;
  wire axi_cnfg_awready;
  wire axi_cnfg_awvalid;
  wire axi_cnfg_bready;
  wire [1:0]axi_cnfg_bresp;
  wire axi_cnfg_bvalid;
  wire [63:0]axi_cnfg_rdata;
  wire axi_cnfg_rready;
  wire [1:0]axi_cnfg_rresp;
  wire axi_cnfg_rvalid;
  wire [63:0]axi_cnfg_wdata;
  wire axi_cnfg_wready;
  wire [7:0]axi_cnfg_wstrb;
  wire axi_cnfg_wvalid;
  wire [63:0]axi_ctrl_0_araddr;
  wire [2:0]axi_ctrl_0_arprot;
  wire axi_ctrl_0_arready;
  wire axi_ctrl_0_arvalid;
  wire [63:0]axi_ctrl_0_awaddr;
  wire [2:0]axi_ctrl_0_awprot;
  wire axi_ctrl_0_awready;
  wire axi_ctrl_0_awvalid;
  wire axi_ctrl_0_bready;
  wire [1:0]axi_ctrl_0_bresp;
  wire axi_ctrl_0_bvalid;
  wire [63:0]axi_ctrl_0_rdata;
  wire axi_ctrl_0_rready;
  wire [1:0]axi_ctrl_0_rresp;
  wire axi_ctrl_0_rvalid;
  wire [63:0]axi_ctrl_0_wdata;
  wire axi_ctrl_0_wready;
  wire [7:0]axi_ctrl_0_wstrb;
  wire axi_ctrl_0_wvalid;
  wire [63:0]axi_main_araddr;
  wire [1:0]axi_main_arburst;
  wire [3:0]axi_main_arcache;
  wire [5:0]axi_main_arid;
  wire [7:0]axi_main_arlen;
  wire [0:0]axi_main_arlock;
  wire [2:0]axi_main_arprot;
  wire [3:0]axi_main_arqos;
  wire axi_main_arready;
  wire [3:0]axi_main_arregion;
  wire [2:0]axi_main_arsize;
  wire axi_main_arvalid;
  wire [63:0]axi_main_awaddr;
  wire [1:0]axi_main_awburst;
  wire [3:0]axi_main_awcache;
  wire [5:0]axi_main_awid;
  wire [7:0]axi_main_awlen;
  wire [0:0]axi_main_awlock;
  wire [2:0]axi_main_awprot;
  wire [3:0]axi_main_awqos;
  wire axi_main_awready;
  wire [3:0]axi_main_awregion;
  wire [2:0]axi_main_awsize;
  wire axi_main_awvalid;
  wire [5:0]axi_main_bid;
  wire axi_main_bready;
  wire [1:0]axi_main_bresp;
  wire axi_main_bvalid;
  wire [511:0]axi_main_rdata;
  wire [5:0]axi_main_rid;
  wire axi_main_rlast;
  wire axi_main_rready;
  wire [1:0]axi_main_rresp;
  wire axi_main_rvalid;
  wire [511:0]axi_main_wdata;
  wire axi_main_wlast;
  wire axi_main_wready;
  wire [63:0]axi_main_wstrb;
  wire axi_main_wvalid;
  wire [63:0]axim_ctrl_0_araddr;
  wire [1:0]axim_ctrl_0_arburst;
  wire [3:0]axim_ctrl_0_arcache;
  wire [7:0]axim_ctrl_0_arlen;
  wire [0:0]axim_ctrl_0_arlock;
  wire [2:0]axim_ctrl_0_arprot;
  wire [3:0]axim_ctrl_0_arqos;
  wire axim_ctrl_0_arready;
  wire [3:0]axim_ctrl_0_arregion;
  wire [2:0]axim_ctrl_0_arsize;
  wire axim_ctrl_0_arvalid;
  wire [63:0]axim_ctrl_0_awaddr;
  wire [1:0]axim_ctrl_0_awburst;
  wire [3:0]axim_ctrl_0_awcache;
  wire [7:0]axim_ctrl_0_awlen;
  wire [0:0]axim_ctrl_0_awlock;
  wire [2:0]axim_ctrl_0_awprot;
  wire [3:0]axim_ctrl_0_awqos;
  wire axim_ctrl_0_awready;
  wire [3:0]axim_ctrl_0_awregion;
  wire [2:0]axim_ctrl_0_awsize;
  wire axim_ctrl_0_awvalid;
  wire axim_ctrl_0_bready;
  wire [1:0]axim_ctrl_0_bresp;
  wire axim_ctrl_0_bvalid;
  wire [255:0]axim_ctrl_0_rdata;
  wire axim_ctrl_0_rlast;
  wire axim_ctrl_0_rready;
  wire [1:0]axim_ctrl_0_rresp;
  wire axim_ctrl_0_rvalid;
  wire [255:0]axim_ctrl_0_wdata;
  wire axim_ctrl_0_wlast;
  wire axim_ctrl_0_wready;
  wire [31:0]axim_ctrl_0_wstrb;
  wire axim_ctrl_0_wvalid;
  wire lckresetn;
  wire nclk;
  wire [0:0]nresetn;
  wire sys_reset;
  wire uclk;
  wire [0:0]uresetn;
  wire xclk;
  wire xresetn;

  design_ctrl design_ctrl_i
       (.aclk(aclk),
        .aresetn(aresetn),
        .axi_cnfg_araddr(axi_cnfg_araddr),
        .axi_cnfg_arprot(axi_cnfg_arprot),
        .axi_cnfg_arready(axi_cnfg_arready),
        .axi_cnfg_arvalid(axi_cnfg_arvalid),
        .axi_cnfg_awaddr(axi_cnfg_awaddr),
        .axi_cnfg_awprot(axi_cnfg_awprot),
        .axi_cnfg_awready(axi_cnfg_awready),
        .axi_cnfg_awvalid(axi_cnfg_awvalid),
        .axi_cnfg_bready(axi_cnfg_bready),
        .axi_cnfg_bresp(axi_cnfg_bresp),
        .axi_cnfg_bvalid(axi_cnfg_bvalid),
        .axi_cnfg_rdata(axi_cnfg_rdata),
        .axi_cnfg_rready(axi_cnfg_rready),
        .axi_cnfg_rresp(axi_cnfg_rresp),
        .axi_cnfg_rvalid(axi_cnfg_rvalid),
        .axi_cnfg_wdata(axi_cnfg_wdata),
        .axi_cnfg_wready(axi_cnfg_wready),
        .axi_cnfg_wstrb(axi_cnfg_wstrb),
        .axi_cnfg_wvalid(axi_cnfg_wvalid),
        .axi_ctrl_0_araddr(axi_ctrl_0_araddr),
        .axi_ctrl_0_arprot(axi_ctrl_0_arprot),
        .axi_ctrl_0_arready(axi_ctrl_0_arready),
        .axi_ctrl_0_arvalid(axi_ctrl_0_arvalid),
        .axi_ctrl_0_awaddr(axi_ctrl_0_awaddr),
        .axi_ctrl_0_awprot(axi_ctrl_0_awprot),
        .axi_ctrl_0_awready(axi_ctrl_0_awready),
        .axi_ctrl_0_awvalid(axi_ctrl_0_awvalid),
        .axi_ctrl_0_bready(axi_ctrl_0_bready),
        .axi_ctrl_0_bresp(axi_ctrl_0_bresp),
        .axi_ctrl_0_bvalid(axi_ctrl_0_bvalid),
        .axi_ctrl_0_rdata(axi_ctrl_0_rdata),
        .axi_ctrl_0_rready(axi_ctrl_0_rready),
        .axi_ctrl_0_rresp(axi_ctrl_0_rresp),
        .axi_ctrl_0_rvalid(axi_ctrl_0_rvalid),
        .axi_ctrl_0_wdata(axi_ctrl_0_wdata),
        .axi_ctrl_0_wready(axi_ctrl_0_wready),
        .axi_ctrl_0_wstrb(axi_ctrl_0_wstrb),
        .axi_ctrl_0_wvalid(axi_ctrl_0_wvalid),
        .axi_main_araddr(axi_main_araddr),
        .axi_main_arburst(axi_main_arburst),
        .axi_main_arcache(axi_main_arcache),
        .axi_main_arid(axi_main_arid),
        .axi_main_arlen(axi_main_arlen),
        .axi_main_arlock(axi_main_arlock),
        .axi_main_arprot(axi_main_arprot),
        .axi_main_arqos(axi_main_arqos),
        .axi_main_arready(axi_main_arready),
        .axi_main_arregion(axi_main_arregion),
        .axi_main_arsize(axi_main_arsize),
        .axi_main_arvalid(axi_main_arvalid),
        .axi_main_awaddr(axi_main_awaddr),
        .axi_main_awburst(axi_main_awburst),
        .axi_main_awcache(axi_main_awcache),
        .axi_main_awid(axi_main_awid),
        .axi_main_awlen(axi_main_awlen),
        .axi_main_awlock(axi_main_awlock),
        .axi_main_awprot(axi_main_awprot),
        .axi_main_awqos(axi_main_awqos),
        .axi_main_awready(axi_main_awready),
        .axi_main_awregion(axi_main_awregion),
        .axi_main_awsize(axi_main_awsize),
        .axi_main_awvalid(axi_main_awvalid),
        .axi_main_bid(axi_main_bid),
        .axi_main_bready(axi_main_bready),
        .axi_main_bresp(axi_main_bresp),
        .axi_main_bvalid(axi_main_bvalid),
        .axi_main_rdata(axi_main_rdata),
        .axi_main_rid(axi_main_rid),
        .axi_main_rlast(axi_main_rlast),
        .axi_main_rready(axi_main_rready),
        .axi_main_rresp(axi_main_rresp),
        .axi_main_rvalid(axi_main_rvalid),
        .axi_main_wdata(axi_main_wdata),
        .axi_main_wlast(axi_main_wlast),
        .axi_main_wready(axi_main_wready),
        .axi_main_wstrb(axi_main_wstrb),
        .axi_main_wvalid(axi_main_wvalid),
        .axim_ctrl_0_araddr(axim_ctrl_0_araddr),
        .axim_ctrl_0_arburst(axim_ctrl_0_arburst),
        .axim_ctrl_0_arcache(axim_ctrl_0_arcache),
        .axim_ctrl_0_arlen(axim_ctrl_0_arlen),
        .axim_ctrl_0_arlock(axim_ctrl_0_arlock),
        .axim_ctrl_0_arprot(axim_ctrl_0_arprot),
        .axim_ctrl_0_arqos(axim_ctrl_0_arqos),
        .axim_ctrl_0_arready(axim_ctrl_0_arready),
        .axim_ctrl_0_arregion(axim_ctrl_0_arregion),
        .axim_ctrl_0_arsize(axim_ctrl_0_arsize),
        .axim_ctrl_0_arvalid(axim_ctrl_0_arvalid),
        .axim_ctrl_0_awaddr(axim_ctrl_0_awaddr),
        .axim_ctrl_0_awburst(axim_ctrl_0_awburst),
        .axim_ctrl_0_awcache(axim_ctrl_0_awcache),
        .axim_ctrl_0_awlen(axim_ctrl_0_awlen),
        .axim_ctrl_0_awlock(axim_ctrl_0_awlock),
        .axim_ctrl_0_awprot(axim_ctrl_0_awprot),
        .axim_ctrl_0_awqos(axim_ctrl_0_awqos),
        .axim_ctrl_0_awready(axim_ctrl_0_awready),
        .axim_ctrl_0_awregion(axim_ctrl_0_awregion),
        .axim_ctrl_0_awsize(axim_ctrl_0_awsize),
        .axim_ctrl_0_awvalid(axim_ctrl_0_awvalid),
        .axim_ctrl_0_bready(axim_ctrl_0_bready),
        .axim_ctrl_0_bresp(axim_ctrl_0_bresp),
        .axim_ctrl_0_bvalid(axim_ctrl_0_bvalid),
        .axim_ctrl_0_rdata(axim_ctrl_0_rdata),
        .axim_ctrl_0_rlast(axim_ctrl_0_rlast),
        .axim_ctrl_0_rready(axim_ctrl_0_rready),
        .axim_ctrl_0_rresp(axim_ctrl_0_rresp),
        .axim_ctrl_0_rvalid(axim_ctrl_0_rvalid),
        .axim_ctrl_0_wdata(axim_ctrl_0_wdata),
        .axim_ctrl_0_wlast(axim_ctrl_0_wlast),
        .axim_ctrl_0_wready(axim_ctrl_0_wready),
        .axim_ctrl_0_wstrb(axim_ctrl_0_wstrb),
        .axim_ctrl_0_wvalid(axim_ctrl_0_wvalid),
        .lckresetn(lckresetn),
        .nclk(nclk),
        .nresetn(nresetn),
        .sys_reset(sys_reset),
        .uclk(uclk),
        .uresetn(uresetn),
        .xclk(xclk),
        .xresetn(xresetn));
endmodule
