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
  * EVEN IF ADVISED OF THE POSSIBILITY OF    SUCH DAMAGE.
  */

`timescale 1ns / 1ps

import lynxTypes::*;

`include "axi_macros.svh"
`include "lynx_macros.svh"

module shell_top (
    // Shell clocks
    (* io_buffer_type = "none" *) input  logic                              xresetn,
    (* io_buffer_type = "none" *) input  logic                              xclk,
    (* io_buffer_type = "none" *) input  logic                              dresetn,
    (* io_buffer_type = "none" *) input  logic                              dclk,



    // ISR
    (* io_buffer_type = "none" *) output logic [14:0]                       m_usr_irq,

    //
    // Shell interfaces
    //

    // AXI
    (* io_buffer_type = "none" *) input  logic[AXI_ADDR_BITS-1:0]    	    s_axi_main_araddr,
    (* io_buffer_type = "none" *) input  logic[1:0]		                    s_axi_main_arburst,
    (* io_buffer_type = "none" *) input  logic[3:0]		                    s_axi_main_arcache,
    (* io_buffer_type = "none" *) input  logic[AXI_ID_BITS-1:0]             s_axi_main_arid,
    (* io_buffer_type = "none" *) input  logic[7:0]		                    s_axi_main_arlen,
    (* io_buffer_type = "none" *) input  logic[0:0]		                    s_axi_main_arlock,
    (* io_buffer_type = "none" *) input  logic[2:0]		                    s_axi_main_arprot,
    (* io_buffer_type = "none" *) input  logic[3:0]		                    s_axi_main_arqos,
    (* io_buffer_type = "none" *) input  logic[3:0]		                    s_axi_main_arregion,
    (* io_buffer_type = "none" *) input  logic[2:0]		                    s_axi_main_arsize,
    (* io_buffer_type = "none" *) output logic			                    s_axi_main_arready,
    (* io_buffer_type = "none" *) input  logic			                    s_axi_main_arvalid,
    (* io_buffer_type = "none" *) input  logic[AXI_ADDR_BITS-1:0]    	    s_axi_main_awaddr,
    (* io_buffer_type = "none" *) input  logic[1:0]		                    s_axi_main_awburst,
    (* io_buffer_type = "none" *) input  logic[3:0]		                    s_axi_main_awcache,
    (* io_buffer_type = "none" *) input  logic[AXI_ID_BITS-1:0]             s_axi_main_awid,
    (* io_buffer_type = "none" *) input  logic[7:0]		                    s_axi_main_awlen,
    (* io_buffer_type = "none" *) input  logic[0:0]		                    s_axi_main_awlock,
    (* io_buffer_type = "none" *) input  logic[2:0]		                    s_axi_main_awprot,
    (* io_buffer_type = "none" *) input  logic[3:0]		                    s_axi_main_awqos,
    (* io_buffer_type = "none" *) input  logic[3:0]		                    s_axi_main_awregion,
    (* io_buffer_type = "none" *) input  logic[2:0]		                    s_axi_main_awsize,
    (* io_buffer_type = "none" *) output logic			                    s_axi_main_awready,
    (* io_buffer_type = "none" *) input  logic			                    s_axi_main_awvalid,
    (* io_buffer_type = "none" *) output logic[AXI_DATA_BITS-1:0]           s_axi_main_rdata,
    (* io_buffer_type = "none" *) output logic[AXI_ID_BITS-1:0]             s_axi_main_rid,
    (* io_buffer_type = "none" *) output logic                              s_axi_main_rlast,
    (* io_buffer_type = "none" *) output logic[1:0]                         s_axi_main_rresp,
    (* io_buffer_type = "none" *) input  logic                              s_axi_main_rready,
    (* io_buffer_type = "none" *) output logic                              s_axi_main_rvalid,
    (* io_buffer_type = "none" *) input  logic[AXI_DATA_BITS-1:0]           s_axi_main_wdata,
    (* io_buffer_type = "none" *) input  logic                              s_axi_main_wlast,
    (* io_buffer_type = "none" *) input  logic[AXI_DATA_BITS/8-1:0]         s_axi_main_wstrb,
    (* io_buffer_type = "none" *) output logic                              s_axi_main_wready,
    (* io_buffer_type = "none" *) input  logic                              s_axi_main_wvalid,
    (* io_buffer_type = "none" *) output logic[AXI_ID_BITS-1:0]             s_axi_main_bid,
    (* io_buffer_type = "none" *) output logic[1:0]                         s_axi_main_bresp,
    (* io_buffer_type = "none" *) input  logic                              s_axi_main_bready,
    (* io_buffer_type = "none" *) output logic                              s_axi_main_bvalid,

    // AXIS
    (* io_buffer_type = "none" *) input  logic[AXI_DATA_BITS-1:0]           s_axis_dyn_in_0_tdata,
    (* io_buffer_type = "none" *) input  logic[AXI_DATA_BITS/8-1:0]         s_axis_dyn_in_0_tkeep,
    (* io_buffer_type = "none" *) input  logic                              s_axis_dyn_in_0_tlast,
    (* io_buffer_type = "none" *) input  logic                              s_axis_dyn_in_0_tvalid,
    (* io_buffer_type = "none" *) output logic                              s_axis_dyn_in_0_tready,

    (* io_buffer_type = "none" *) output logic[AXI_DATA_BITS-1:0]           m_axis_dyn_out_0_tdata,
    (* io_buffer_type = "none" *) output logic[AXI_DATA_BITS/8-1:0]         m_axis_dyn_out_0_tkeep,
    (* io_buffer_type = "none" *) output logic                              m_axis_dyn_out_0_tlast,
    (* io_buffer_type = "none" *) output logic                              m_axis_dyn_out_0_tvalid,
    (* io_buffer_type = "none" *) input  logic                              m_axis_dyn_out_0_tready,

    (* io_buffer_type = "none" *) output logic[$bits(dma_req_t)-1:0]        m_dma_rd_req_0_req,
    (* io_buffer_type = "none" *) input  logic[$bits(dma_rsp_t)-1:0]        m_dma_rd_req_0_rsp,
    (* io_buffer_type = "none" *) output logic                              m_dma_rd_req_0_valid,
    (* io_buffer_type = "none" *) input  logic                              m_dma_rd_req_0_ready,

    (* io_buffer_type = "none" *) output logic[$bits(dma_req_t)-1:0]        m_dma_wr_req_0_req,
    (* io_buffer_type = "none" *) input  logic[$bits(dma_rsp_t)-1:0]        m_dma_wr_req_0_rsp,
    (* io_buffer_type = "none" *) output logic                              m_dma_wr_req_0_valid,
    (* io_buffer_type = "none" *) input  logic                              m_dma_wr_req_0_ready,
    
    (* io_buffer_type = "none" *) input  logic[AXI_DATA_BITS-1:0]           s_axis_dyn_in_1_tdata,
    (* io_buffer_type = "none" *) input  logic[AXI_DATA_BITS/8-1:0]         s_axis_dyn_in_1_tkeep,
    (* io_buffer_type = "none" *) input  logic                              s_axis_dyn_in_1_tlast,
    (* io_buffer_type = "none" *) input  logic                              s_axis_dyn_in_1_tvalid,
    (* io_buffer_type = "none" *) output logic                              s_axis_dyn_in_1_tready,

    (* io_buffer_type = "none" *) output logic[AXI_DATA_BITS-1:0]           m_axis_dyn_out_1_tdata,
    (* io_buffer_type = "none" *) output logic[AXI_DATA_BITS/8-1:0]         m_axis_dyn_out_1_tkeep,
    (* io_buffer_type = "none" *) output logic                              m_axis_dyn_out_1_tlast,
    (* io_buffer_type = "none" *) output logic                              m_axis_dyn_out_1_tvalid,
    (* io_buffer_type = "none" *) input  logic                              m_axis_dyn_out_1_tready,

    (* io_buffer_type = "none" *) output logic[$bits(dma_req_t)-1:0]        m_dma_rd_req_1_req,
    (* io_buffer_type = "none" *) input  logic[$bits(dma_rsp_t)-1:0]        m_dma_rd_req_1_rsp,
    (* io_buffer_type = "none" *) output logic                              m_dma_rd_req_1_valid,
    (* io_buffer_type = "none" *) input  logic                              m_dma_rd_req_1_ready,

    (* io_buffer_type = "none" *) output logic[$bits(dma_req_t)-1:0]        m_dma_wr_req_1_req,
    (* io_buffer_type = "none" *) input  logic[$bits(dma_rsp_t)-1:0]        m_dma_wr_req_1_rsp,
    (* io_buffer_type = "none" *) output logic                              m_dma_wr_req_1_valid,
    (* io_buffer_type = "none" *) input  logic                              m_dma_wr_req_1_ready,
    

    // WB
    (* io_buffer_type = "none" *) output logic                              m_wback_valid,
    (* io_buffer_type = "none" *) input  logic                              m_wback_ready,
    (* io_buffer_type = "none" *) output logic[$bits(wback_t)-1:0]          m_wback_data,

    // GT 0
    (* io_buffer_type = "none" *) input  logic[3:0]                         gt0_rxp_in,
    (* io_buffer_type = "none" *) input  logic[3:0]                         gt0_rxn_in,
    (* io_buffer_type = "none" *) output  logic[3:0]                        gt0_txp_out,
    (* io_buffer_type = "none" *) output  logic[3:0]                        gt0_txn_out,
    (* io_buffer_type = "none" *) input  logic                              gt0_refclk_p,
    (* io_buffer_type = "none" *) input  logic                              gt0_refclk_n,
    
  
    // GT 1     
    (* io_buffer_type = "none" *) input  logic[3:0]                         gt1_rxp_in,
    (* io_buffer_type = "none" *) input  logic[3:0]                         gt1_rxn_in,
    (* io_buffer_type = "none" *) output  logic[3:0]                        gt1_txp_out,
    (* io_buffer_type = "none" *) output  logic[3:0]                        gt1_txn_out,
    (* io_buffer_type = "none" *)  input  logic                             gt1_refclk_p,
    (* io_buffer_type = "none" *)  input  logic                             gt1_refclk_n,

    // DDR4 0
    (* io_buffer_type = "none" *) output logic                              c0_ddr4_act_n,
    (* io_buffer_type = "none" *) output logic[16:0]                        c0_ddr4_adr,
    (* io_buffer_type = "none" *) output logic[1:0]                         c0_ddr4_ba,
    (* io_buffer_type = "none" *) output logic[1:0]                         c0_ddr4_bg,
    (* io_buffer_type = "none" *) output logic[0:0]                         c0_ddr4_ck_c,
    (* io_buffer_type = "none" *) output logic[0:0]                         c0_ddr4_ck_t,
    (* io_buffer_type = "none" *) output logic[0:0]                         c0_ddr4_cke,
    (* io_buffer_type = "none" *) output logic[0:0]                         c0_ddr4_cs_n,
    (* io_buffer_type = "none" *) inout  logic[71:0]                        c0_ddr4_dq,
    (* io_buffer_type = "none" *) inout  logic[17:0]                        c0_ddr4_dqs_c,
    (* io_buffer_type = "none" *) inout  logic[17:0]                        c0_ddr4_dqs_t,
    (* io_buffer_type = "none" *) output logic[0:0]                         c0_ddr4_odt,
    (* io_buffer_type = "none" *) output logic                              c0_ddr4_par,
    (* io_buffer_type = "none" *) output logic                              c0_ddr4_reset_n,
    (* io_buffer_type = "none" *) input  logic                              c0_sys_clk_p,
    (* io_buffer_type = "none" *) input  logic                              c0_sys_clk_n,
    
    // DDR4 1
    (* io_buffer_type = "none" *) output logic                              c1_ddr4_act_n,
    (* io_buffer_type = "none" *) output logic[16:0]                        c1_ddr4_adr,
    (* io_buffer_type = "none" *) output logic[1:0]                         c1_ddr4_ba,
    (* io_buffer_type = "none" *) output logic[1:0]                         c1_ddr4_bg,
    (* io_buffer_type = "none" *) output logic[0:0]                         c1_ddr4_ck_c,
    (* io_buffer_type = "none" *) output logic[0:0]                         c1_ddr4_ck_t,
    (* io_buffer_type = "none" *) output logic[0:0]                         c1_ddr4_cke,
    (* io_buffer_type = "none" *) output logic[0:0]                         c1_ddr4_cs_n,
    (* io_buffer_type = "none" *) inout  logic[71:0]                        c1_ddr4_dq,
    (* io_buffer_type = "none" *) inout  logic[17:0]                        c1_ddr4_dqs_c,
    (* io_buffer_type = "none" *) inout  logic[17:0]                        c1_ddr4_dqs_t,
    (* io_buffer_type = "none" *) output logic[0:0]                         c1_ddr4_odt,
    (* io_buffer_type = "none" *) output logic                              c1_ddr4_par,
    (* io_buffer_type = "none" *) output logic                              c1_ddr4_reset_n,
    (* io_buffer_type = "none" *) input  logic                              c1_sys_clk_p,
    (* io_buffer_type = "none" *) input  logic                              c1_sys_clk_n,
    (* io_buffer_type = "none" *) input  wire[0:0]                          hbm_clk_clk_n,
    (* io_buffer_type = "none" *) input  wire[0:0]                          hbm_clk_clk_p,
    // Debug
    (* io_buffer_type = "none" *) input  logic                              dyn_bscan_drck,
    (* io_buffer_type = "none" *) input  logic                              dyn_bscan_shift,
    (* io_buffer_type = "none" *) input  logic                              dyn_bscan_tdi,
    (* io_buffer_type = "none" *) input  logic                              dyn_bscan_update,
    (* io_buffer_type = "none" *) input  logic                              dyn_bscan_sel,
    (* io_buffer_type = "none" *) output logic                              dyn_bscan_tdo,
    (* io_buffer_type = "none" *) input  logic                              dyn_bscan_tms,
    (* io_buffer_type = "none" *) input  logic                              dyn_bscan_tck,
    (* io_buffer_type = "none" *) input  logic                              dyn_bscan_runtest,
    (* io_buffer_type = "none" *) input  logic                              dyn_bscan_reset,
    (* io_buffer_type = "none" *) input  logic                              dyn_bscan_capture,
    (* io_buffer_type = "none" *) input  logic                              dyn_bscan_bscanid_en
);

    // ================-----------------------------------------------------------------
    // CTRL CCROSS
    // ================-----------------------------------------------------------------
    
    logic aclk;
    logic aresetn;
    logic nclk;
    logic nresetn;
    logic uclk;
    logic uresetn;
    logic hclk;
    logic hresetn;
    logic lckresetn;
    
    AXI4 s_axi_main();
    `AXI_ASSIGN_S2I(s_axi_main, s_axi_main)    
    AXI4L axi_cnfg ();
    AXI4L axi_ctrl [N_REGIONS] ();
    AXI4 #(.AXI4_DATA_BITS(AVX_DATA_BITS)) axim_ctrl [N_REGIONS] ();
    
    shell_ctrl_cc inst_shell_ctrl_cc (
        .xclk(xclk),
        .xresetn(xresetn),
        .aclk(aclk),
        .aresetn(aresetn),
        .uclk(uclk),
        .uresetn(uresetn),
        .nclk(nclk),
        .nresetn(nresetn),
        .lckresetn(lckresetn),
        .sys_reset(1'b0),
        
        .axi_main(s_axi_main),
        .axi_cnfg(axi_cnfg),
        .axi_ctrl(axi_ctrl),
        .axim_ctrl(axim_ctrl) 
    );



    // ================-----------------------------------------------------------------
    // DATA CCROSS
    // ================----------------------------------------------------------------- 

    AXI4S s_axis_dyn_in [N_SCHAN] ();
    AXI4S m_axis_dyn_out [N_SCHAN] ();
    dmaIntf m_dma_rd_req [N_SCHAN] ();
    dmaIntf m_dma_wr_req [N_SCHAN] ();  

    `AXIS_ASSIGN_S2I(s_axis_dyn_in_0, s_axis_dyn_in[0])
    `AXIS_ASSIGN_I2S(m_axis_dyn_out[0], m_axis_dyn_out_0)
    `DMA_REQ_ASSIGN_I2S(m_dma_rd_req[0], m_dma_rd_req_0)
    `DMA_REQ_ASSIGN_I2S(m_dma_wr_req[0], m_dma_wr_req_0)
    `AXIS_ASSIGN_S2I(s_axis_dyn_in_1, s_axis_dyn_in[1])
    `AXIS_ASSIGN_I2S(m_axis_dyn_out[1], m_axis_dyn_out_1)
    `DMA_REQ_ASSIGN_I2S(m_dma_rd_req[1], m_dma_rd_req_1)
    `DMA_REQ_ASSIGN_I2S(m_dma_wr_req[1], m_dma_wr_req_1)

    metaIntf #(.STYPE(wback_t)) m_wback ();
    `META_ASSIGN_I2S(m_wback, m_wback)

    logic [14:0] usr_irq;
    AXI4S axis_dyn_in_int [N_SCHAN] ();
    AXI4S axis_dyn_out_int [N_SCHAN] ();
    dmaIntf dma_rd_req_int [N_SCHAN] ();
    dmaIntf dma_wr_req_int [N_SCHAN] ();
    metaIntf #(.STYPE(wback_t)) wback ();

    shell_data_cc #(
        .N_STAGES_0(N_REG_SHELL_S0),
        .N_STAGES_1(N_REG_SHELL_S1)
    ) inst_shell_data_cc (
        .s_usr_irq(usr_irq),
        .m_usr_irq(m_usr_irq),

        .s_axis_dyn_in(s_axis_dyn_in),
        .m_axis_dyn_in(axis_dyn_in_int),
        .s_axis_dyn_out(axis_dyn_out_int),
        .m_axis_dyn_out(m_axis_dyn_out),
        .s_dma_rd_req(dma_rd_req_int),
        .m_dma_rd_req(m_dma_rd_req),
        .s_dma_wr_req(dma_wr_req_int),
        .m_dma_wr_req(m_dma_wr_req),
        .s_wback(wback),
        .m_wback(m_wback),
        .xclk(xclk),
        .xresetn(xresetn),
        .aclk(aclk),
        .aresetn(aresetn)
    );

    AXI4S axis_dyn_in [N_CHAN] ();
    AXI4S axis_dyn_out [N_CHAN] ();
    dmaIntf dma_rd_req [N_CHAN] ();
    dmaIntf dma_wr_req [N_CHAN] ();

        always_comb axis_dyn_in_int[1].tie_off_s();
        always_comb axis_dyn_out_int[1].tie_off_m();
        always_comb dma_rd_req_int[1].tie_off_m();
        always_comb dma_wr_req_int[1].tie_off_m();
        `AXIS_ASSIGN(axis_dyn_in_int[0], axis_dyn_in[0])
        `AXIS_ASSIGN(axis_dyn_out[0], axis_dyn_out_int[0])
        `DMA_REQ_ASSIGN(dma_rd_req[0], dma_rd_req_int[0])
        `DMA_REQ_ASSIGN(dma_wr_req[0], dma_wr_req_int[0])

    // ================-----------------------------------------------------------------
    // DEBUG BRIDGE
    // ================----------------------------------------------------------------- 

    logic [N_REGIONS-1:0] m_bscan_bscanid_en;
    logic [N_REGIONS-1:0] m_bscan_capture;
    logic [N_REGIONS-1:0] m_bscan_drck;
    logic [N_REGIONS-1:0] m_bscan_reset;
    logic [N_REGIONS-1:0] m_bscan_runtest;
    logic [N_REGIONS-1:0] m_bscan_sel;
    logic [N_REGIONS-1:0] m_bscan_shift;
    logic [N_REGIONS-1:0] m_bscan_tck;
    logic [N_REGIONS-1:0] m_bscan_tdi;
    logic [N_REGIONS-1:0] m_bscan_tdo;
    logic [N_REGIONS-1:0] m_bscan_tms;
    logic [N_REGIONS-1:0] m_bscan_update;

    debug_bridge_dynamic inst_debug_bridge_dynamic (
        .clk(dclk),
        .m0_bscan_bscanid_en(m_bscan_bscanid_en[0]),
        .m0_bscan_capture(m_bscan_capture[0]),
        .m0_bscan_drck(m_bscan_drck[0]),
        .m0_bscan_reset(m_bscan_reset[0]),
        .m0_bscan_runtest(m_bscan_runtest[0]),
        .m0_bscan_sel(m_bscan_sel[0]),
        .m0_bscan_shift(m_bscan_shift[0]),
        .m0_bscan_tck(m_bscan_tck[0]),
        .m0_bscan_tdi(m_bscan_tdi[0]),
        .m0_bscan_tdo(m_bscan_tdo[0]),
        .m0_bscan_tms(m_bscan_tms[0]),
        .m0_bscan_update(m_bscan_update[0]),
        .S_BSCAN_bscanid_en(dyn_bscan_bscanid_en),
        .S_BSCAN_capture(dyn_bscan_capture),
        .S_BSCAN_drck(dyn_bscan_drck),
        .S_BSCAN_reset(dyn_bscan_reset),
        .S_BSCAN_runtest(dyn_bscan_runtest),
        .S_BSCAN_sel(dyn_bscan_sel),
        .S_BSCAN_shift(dyn_bscan_shift),
        .S_BSCAN_tck(dyn_bscan_tck),
        .S_BSCAN_tdi(dyn_bscan_tdi),
        .S_BSCAN_tdo(dyn_bscan_tdo),
        .S_BSCAN_tms(dyn_bscan_tms),
        .S_BSCAN_update(dyn_bscan_update)
    );

        
    // ================-----------------------------------------------------------------
    // SHELL CONFIG
    // ================-----------------------------------------------------------------

  

    // Decopuling
    logic [N_REGIONS-1:0] decouple;

    
    // DMA Stats
    xdma_stat_t xdma_stats_0;

    shell_slave inst_shell_slave (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_xdma_stats_0(xdma_stats_0),
        .m_decouple(decouple),
        .s_axi_ctrl(axi_cnfg)
    );

    // ================-----------------------------------------------------------------
    // DYNAMIC WRAPPER
    // ================-----------------------------------------------------------------

    design_dynamic_top inst_dynamic (
        .s_axi_ctrl(axi_ctrl[0+:1]),
        .s_axim_ctrl(axim_ctrl[0+:1]),
        .m_host_dma_rd_req(dma_rd_req[0]),
        .m_host_dma_wr_req(dma_wr_req[0]),
        .s_axis_host(axis_dyn_in[0]),
        .m_axis_host(axis_dyn_out[0]),
        .m_wback(wback),
        .s_decouple_sw(decouple[0+:1]),
        .m_usr_irq(usr_irq[0+:1]),
        .S_BSCAN_drck(m_bscan_drck),
        .S_BSCAN_shift(m_bscan_shift),
        .S_BSCAN_tdi(m_bscan_tdi),
        .S_BSCAN_update(m_bscan_update),
        .S_BSCAN_sel(m_bscan_sel),
        .S_BSCAN_tdo(m_bscan_tdo),
        .S_BSCAN_tms(m_bscan_tms),
        .S_BSCAN_tck(m_bscan_tck),
        .S_BSCAN_runtest(m_bscan_runtest),
        .S_BSCAN_reset(m_bscan_reset),
        .S_BSCAN_capture(m_bscan_capture),
        .S_BSCAN_bscanid_en(m_bscan_bscanid_en),
        .dclk(dclk),
        .aresetn(aresetn),
        .aclk(aclk),
        .uresetn(uresetn),
        .uclk(uclk)
    );

    // ================-----------------------------------------------------------------
    // DMA STATS
    // ================-----------------------------------------------------------------

    dma_stats inst_xch_0 (
        .aclk(aclk),
        .aresetn(aresetn),
        .dma_rd_req(dma_rd_req[0].valid && dma_rd_req[0].ready),
        .dma_rd_done(dma_rd_req[0].rsp.done),
        .axis_rd(axis_dyn_in[0].tvalid && axis_dyn_in[0].tready),
        .dma_wr_req(dma_wr_req[0].valid && dma_wr_req[0].ready),
        .dma_wr_done(dma_wr_req[0].rsp.done),
        .axis_wr(axis_dyn_out[0].tvalid && axis_dyn_out[0].tready),
        .xdma_stats(xdma_stats_0)
    );

    vio_shell_xstats inst_vio_shell_xstats_ch0 (
        .clk(aclk),
        .probe_in0(xdma_stats_0.bpss_h2c_req_counter), // 32 all
        .probe_in1(xdma_stats_0.bpss_c2h_req_counter),
        .probe_in2(xdma_stats_0.bpss_h2c_cmpl_counter),
        .probe_in3(xdma_stats_0.bpss_c2h_cmpl_counter),
        .probe_in4(xdma_stats_0.bpss_h2c_axis_counter),
        .probe_in5(xdma_stats_0.bpss_c2h_axis_counter)
    );





endmodule