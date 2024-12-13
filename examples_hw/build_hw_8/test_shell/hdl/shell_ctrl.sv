/**
  * Copyright (c) 2021, Systems Group, ETH Zurich
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without modification,
  * are permitted provided that the following conditions are met:
  *
  * 1. Redistributions of source code must retain the above copyright notice,
  * this list of conditions and the following disclaimer.
  * 2. Redistributions in binary form must reproduce the above copyright notice,
  * this list of conditions and the following disclaimer in the documentation
  * and/or other materials provided with the distribution.
  * 3. Neither the name of the copyright holder nor the names of its contributors
  * may be used to endorse or promote products derived from this software
  * without specific prior written permission.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
  * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
  * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
  * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
  * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */

`timescale 1ns / 1ps

import lynxTypes::*;

module shell_ctrl_cc (
    AXI4.s              axi_main,

    AXI4L.m             axi_cnfg,
    AXI4L.m             axi_ctrl [N_REGIONS],
    AXI4.m              axim_ctrl [N_REGIONS],

    input  logic        xclk,
    input  logic        xresetn,
    output logic        aclk,
    output logic        aresetn,
    output logic        nclk,
    output logic        nresetn,
    output logic        uclk,
    output logic        uresetn,
    output logic        lckresetn,
    input  logic        sys_reset
);

design_ctrl inst_design_ctrl (
    .axi_main_araddr(axi_main.araddr),
    .axi_main_arburst(axi_main.arburst),
    .axi_main_arcache(axi_main.arcache),
    .axi_main_arid(axi_main.arid),
    .axi_main_arlen(axi_main.arlen),
    .axi_main_arlock(axi_main.arlock),
    .axi_main_arprot(axi_main.arprot),
    .axi_main_arqos(axi_main.arqos),
    .axi_main_arregion(axi_main.arregion),
    .axi_main_arsize(axi_main.arsize),
    .axi_main_arready(axi_main.arready),
    .axi_main_arvalid(axi_main.arvalid),
    .axi_main_awaddr(axi_main.awaddr),
    .axi_main_awburst(axi_main.awburst),
    .axi_main_awcache(axi_main.awcache),
    .axi_main_awid(axi_main.awid),
    .axi_main_awlen(axi_main.awlen),
    .axi_main_awlock(axi_main.awlock),
    .axi_main_awprot(axi_main.awprot),
    .axi_main_awqos(axi_main.awqos),
    .axi_main_awregion(axi_main.awregion),
    .axi_main_awsize(axi_main.awsize),
    .axi_main_awready(axi_main.awready),
    .axi_main_awvalid(axi_main.awvalid),
    .axi_main_bid(axi_main.bid),
    .axi_main_bready(axi_main.bready),
    .axi_main_bresp(axi_main.bresp),
    .axi_main_bvalid(axi_main.bvalid),
    .axi_main_rdata(axi_main.rdata),
    .axi_main_rid(axi_main.rid),
    .axi_main_rlast(axi_main.rlast),
    .axi_main_rready(axi_main.rready),
    .axi_main_rresp(axi_main.rresp),
    .axi_main_rvalid(axi_main.rvalid),
    .axi_main_wdata(axi_main.wdata),
    .axi_main_wlast(axi_main.wlast),
    .axi_main_wready(axi_main.wready),
    .axi_main_wstrb(axi_main.wstrb),
    .axi_main_wvalid(axi_main.wvalid),
    
    .axi_cnfg_araddr(axi_cnfg.araddr),
    .axi_cnfg_arprot(axi_cnfg.arprot),
    .axi_cnfg_arready(axi_cnfg.arready),
    .axi_cnfg_arvalid(axi_cnfg.arvalid),
    .axi_cnfg_awaddr(axi_cnfg.awaddr),
    .axi_cnfg_awprot(axi_cnfg.awprot),
    .axi_cnfg_awready(axi_cnfg.awready),
    .axi_cnfg_awvalid(axi_cnfg.awvalid),
    .axi_cnfg_bready(axi_cnfg.bready),
    .axi_cnfg_bresp(axi_cnfg.bresp),
    .axi_cnfg_bvalid(axi_cnfg.bvalid),
    .axi_cnfg_rdata(axi_cnfg.rdata),
    .axi_cnfg_rready(axi_cnfg.rready),
    .axi_cnfg_rresp(axi_cnfg.rresp),
    .axi_cnfg_rvalid(axi_cnfg.rvalid),
    .axi_cnfg_wdata(axi_cnfg.wdata),
    .axi_cnfg_wready(axi_cnfg.wready),
    .axi_cnfg_wstrb(axi_cnfg.wstrb),
    .axi_cnfg_wvalid(axi_cnfg.wvalid),

    .axi_ctrl_0_araddr(axi_ctrl[0].araddr),
    .axi_ctrl_0_arprot(axi_ctrl[0].arprot),
    .axi_ctrl_0_arready(axi_ctrl[0].arready),
    .axi_ctrl_0_arvalid(axi_ctrl[0].arvalid),
    .axi_ctrl_0_awaddr(axi_ctrl[0].awaddr),
    .axi_ctrl_0_awprot(axi_ctrl[0].awprot),
    .axi_ctrl_0_awready(axi_ctrl[0].awready),
    .axi_ctrl_0_awvalid(axi_ctrl[0].awvalid),
    .axi_ctrl_0_bready(axi_ctrl[0].bready),
    .axi_ctrl_0_bresp(axi_ctrl[0].bresp),
    .axi_ctrl_0_bvalid(axi_ctrl[0].bvalid),
    .axi_ctrl_0_rdata(axi_ctrl[0].rdata),
    .axi_ctrl_0_rready(axi_ctrl[0].rready),
    .axi_ctrl_0_rresp(axi_ctrl[0].rresp),
    .axi_ctrl_0_rvalid(axi_ctrl[0].rvalid),
    .axi_ctrl_0_wdata(axi_ctrl[0].wdata),
    .axi_ctrl_0_wready(axi_ctrl[0].wready),
    .axi_ctrl_0_wstrb(axi_ctrl[0].wstrb),
    .axi_ctrl_0_wvalid(axi_ctrl[0].wvalid),
    .axim_ctrl_0_araddr(axim_ctrl[0].araddr),
    .axim_ctrl_0_arburst(axim_ctrl[0].arburst),
    .axim_ctrl_0_arcache(axim_ctrl[0].arcache),
    .axim_ctrl_0_arlen(axim_ctrl[0].arlen),
    .axim_ctrl_0_arlock(axim_ctrl[0].arlock),
    .axim_ctrl_0_arprot(axim_ctrl[0].arprot),
    .axim_ctrl_0_arqos(axim_ctrl[0].arqos),
    .axim_ctrl_0_arready(axim_ctrl[0].arready),
    .axim_ctrl_0_arregion(axim_ctrl[0].arregion),
    .axim_ctrl_0_arsize(axim_ctrl[0].arsize),
    .axim_ctrl_0_arvalid(axim_ctrl[0].arvalid),
    .axim_ctrl_0_awaddr(axim_ctrl[0].awaddr),
    .axim_ctrl_0_awburst(axim_ctrl[0].awburst),
    .axim_ctrl_0_awcache(axim_ctrl[0].awcache),
    .axim_ctrl_0_awlen(axim_ctrl[0].awlen),
    .axim_ctrl_0_awlock(axim_ctrl[0].awlock),
    .axim_ctrl_0_awprot(axim_ctrl[0].awprot),
    .axim_ctrl_0_awqos(axim_ctrl[0].awqos),
    .axim_ctrl_0_awready(axim_ctrl[0].awready),
    .axim_ctrl_0_awregion(axim_ctrl[0].awregion),
    .axim_ctrl_0_awsize(axim_ctrl[0].awsize),
    .axim_ctrl_0_awvalid(axim_ctrl[0].awvalid),
    .axim_ctrl_0_bready(axim_ctrl[0].bready),
    .axim_ctrl_0_bresp(axim_ctrl[0].bresp),
    .axim_ctrl_0_bvalid(axim_ctrl[0].bvalid),
    .axim_ctrl_0_rdata(axim_ctrl[0].rdata),
    .axim_ctrl_0_rlast(axim_ctrl[0].rlast),
    .axim_ctrl_0_rready(axim_ctrl[0].rready),
    .axim_ctrl_0_rresp(axim_ctrl[0].rresp),
    .axim_ctrl_0_rvalid(axim_ctrl[0].rvalid),
    .axim_ctrl_0_wdata(axim_ctrl[0].wdata),
    .axim_ctrl_0_wlast(axim_ctrl[0].wlast),
    .axim_ctrl_0_wready(axim_ctrl[0].wready),
    .axim_ctrl_0_wstrb(axim_ctrl[0].wstrb),
    .axim_ctrl_0_wvalid(axim_ctrl[0].wvalid),

    .xclk(xclk),
    .xresetn(xresetn),
    .aclk(aclk),
    .aresetn(aresetn),
    .nclk(nclk),
    .nresetn(nresetn),
    .uclk(uclk),
    .uresetn(uresetn),
    .lckresetn(lckresetn),
    .sys_reset(sys_reset)
);

endmodule