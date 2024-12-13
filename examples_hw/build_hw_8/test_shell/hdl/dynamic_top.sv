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
	
module design_dynamic_top #(
    parameter integer                           ID_DYN = 0
) (
    // AXI4 Lite control
    AXI4L.s                                     s_axi_ctrl [N_REGIONS],
    
    // AXI4 AVX control
    AXI4.s                                      s_axim_ctrl [N_REGIONS],
        
    // AXI4S host
    dmaIntf.m                                   m_host_dma_rd_req,
    dmaIntf.m                                   m_host_dma_wr_req,
    AXI4S.s                                     s_axis_host,
    AXI4S.m                                     m_axis_host,
        
     
    // Writeback
    metaIntf.m                                  m_wback,

    // Decoupling
    input  logic[N_REGIONS-1:0]                 s_decouple_sw,

    // IRQ
    output logic[N_REGIONS-1:0]                 m_usr_irq,

    // Debug
    input  logic [N_REGIONS-1:0]                S_BSCAN_drck,
    input  logic [N_REGIONS-1:0]                S_BSCAN_shift,
    input  logic [N_REGIONS-1:0]                S_BSCAN_tdi,
    input  logic [N_REGIONS-1:0]                S_BSCAN_update,
    input  logic [N_REGIONS-1:0]                S_BSCAN_sel,
    output logic [N_REGIONS-1:0]                S_BSCAN_tdo,
    input  logic [N_REGIONS-1:0]                S_BSCAN_tms,
    input  logic [N_REGIONS-1:0]                S_BSCAN_tck,
    input  logic [N_REGIONS-1:0]                S_BSCAN_runtest,
    input  logic [N_REGIONS-1:0]                S_BSCAN_reset,
    input  logic [N_REGIONS-1:0]                S_BSCAN_capture,
    input  logic [N_REGIONS-1:0]                S_BSCAN_bscanid_en,
    input  logic                                dclk,

    // Clock and reset
    input  logic                                aresetn,
    input  logic                                aclk,
    input  logic                                uresetn,
    input  logic                                uclk
);
	
    // ================-----------------------------------------------------------------
    // DECOUPLING 
    // ================-----------------------------------------------------------------

    // Decoupling signals
    logic [N_REGIONS-1:0] decouple;
    logic [N_REGIONS-1:0] decouple_uclk;
    
    dcpl_select inst_dcpl_select (
        .aclk(aclk),
        .aresetn(aresetn),

        .decouple_sw(s_decouple_sw), 
        .decouple(decouple)
    );

    assign decouple_uclk = decouple;
	
    // ================-----------------------------------------------------------------
    // HOST 
    // ================-----------------------------------------------------------------
    
    // XDMA host sync
    // ----------------------------------------------------------------------
    dmaIntf rd_XDMA_host();
    dmaIntf wr_XDMA_host();
    
    dma_reg_array #(.N_STAGES(N_REG_DYN_HOST_S0)) inst_host_dma_reg_arr_s0_rd (.aclk(aclk), .aresetn(aresetn), .s_req(rd_XDMA_host), .m_req(m_host_dma_rd_req));
    dma_reg_array #(.N_STAGES(N_REG_DYN_HOST_S0)) inst_host_dma_reg_arr_s0_wr (.aclk(aclk), .aresetn(aresetn), .s_req(wr_XDMA_host), .m_req(m_host_dma_wr_req));
    
    // Slice 0 
    // ----------------------------------------------------------------------
    AXI4S axis_host_in_s0();
    AXI4S axis_host_out_s0();

    axis_reg_array #(.N_STAGES(N_REG_DYN_HOST_S0)) inst_host_axis_reg_arr_s0_in  (.aclk(aclk), .aresetn(aresetn), .s_axis(s_axis_host),      .m_axis(axis_host_in_s0));
    axis_reg_array #(.N_STAGES(N_REG_DYN_HOST_S0)) inst_host_axis_reg_arr_s0_out (.aclk(aclk), .aresetn(aresetn), .s_axis(axis_host_out_s0), .m_axis(m_axis_host));
    
    // Multiplexing 
    // ----------------------------------------------------------------------
    AXI4S axis_host_in_s1 [N_REGIONS] ();
    AXI4S axis_host_out_s1 [N_REGIONS] ();
    metaIntf #(.STYPE(mux_host_t)) mux_host_rd_user ();
    metaIntf #(.STYPE(mux_host_t)) mux_host_wr_user ();

    axis_mux_host_src  inst_host_mux_in  (.aclk(aclk), .aresetn(aresetn), .s_mux(mux_host_rd_user), .s_axis(axis_host_in_s0),  .m_axis(axis_host_in_s1));
    axis_mux_host_sink inst_host_mux_out (.aclk(aclk), .aresetn(aresetn), .s_mux(mux_host_wr_user), .s_axis(axis_host_out_s1), .m_axis(axis_host_out_s0));
    
    // Credits 
    // ----------------------------------------------------------------------
    AXI4S axis_host_in_s2 [N_REGIONS] ();
    AXI4S axis_host_out_s2 [N_REGIONS] ();

    for(genvar i = 0; i < N_REGIONS; i++) begin
        `AXIS_ASSIGN(axis_host_in_s1[i], axis_host_in_s2[i])
        `AXIS_ASSIGN(axis_host_out_s2[i], axis_host_out_s1[i])
    end


    // Clock crossing (if enabled)
    // ----------------------------------------------------------------------
    AXI4S axis_host_in_s3 [N_REGIONS] ();
    AXI4S axis_host_out_s3 [N_REGIONS] ();

    for(genvar i = 0; i < N_REGIONS; i++) begin
        `AXIS_ASSIGN(axis_host_in_s2[i],  axis_host_in_s3[i])
        `AXIS_ASSIGN(axis_host_out_s3[i], axis_host_out_s2[i])
    end

	

    // Slice 1
    // ----------------------------------------------------------------------
    AXI4S axis_host_in_s4 [N_REGIONS] ();
    AXI4S axis_host_out_s4 [N_REGIONS] ();

    for(genvar i = 0; i < N_REGIONS; i++) begin
        axis_reg_array #(.N_STAGES(N_REG_DYN_HOST_S1)) inst_host_axis_reg_arr_s1_in  (.aclk(aclk), .aresetn(aresetn), .s_axis(axis_host_in_s3[i]),  .m_axis(axis_host_in_s4[i]));
        axis_reg_array #(.N_STAGES(N_REG_DYN_HOST_S1)) inst_host_axis_reg_arr_s1_out (.aclk(aclk), .aresetn(aresetn), .s_axis(axis_host_out_s4[i]), .m_axis(axis_host_out_s3[i]));
    end

    // Decoupling 
    // ----------------------------------------------------------------------
    AXI4S axis_host_in_ul [N_REGIONS] ();
    AXI4S axis_host_out_ul [N_REGIONS] ();

    axis_decoupler inst_host_dcpl_in  (.decouple(decouple_uclk), .s_axis(axis_host_in_s4),    .m_axis(axis_host_in_ul));
    axis_decoupler inst_host_dcpl_out (.decouple(decouple_uclk), .s_axis(axis_host_out_ul), .m_axis(axis_host_out_s4));

	
	

    // ================-----------------------------------------------------------------
	// Rest of interfaces
	// ================-----------------------------------------------------------------
    
    // Control lTLB
	AXI4L axi_ctrl_lTlb [N_REGIONS] ();
	
	// Control sTLB
	AXI4L axi_ctrl_sTlb [N_REGIONS] ();
	
    // Control config
    AXI4L axi_ctrl_cnfg [N_REGIONS] ();
    
    // Control user logic
    AXI4L axi_ctrl_user [N_REGIONS] ();
    
    // Slice 0 
    // ----------------------------------------------------------------------
    AXI4L axi_ctrl_s0 [N_REGIONS] ();

    for(genvar i = 0; i < N_REGIONS; i++) begin
        axil_reg_array #(.N_STAGES(N_REG_DYN_HOST_S0)) (.aclk(aclk), .aresetn(aresetn), .s_axi(s_axi_ctrl[i]), .m_axi(axi_ctrl_s0[i]));
    end

    AXI4 #(.AXI4_DATA_BITS(AVX_DATA_BITS)) axim_ctrl_s0 [N_REGIONS] ();

    for(genvar i = 0; i < N_REGIONS; i++) begin
        axim_reg_array #(.N_STAGES(N_REG_DYN_HOST_S0)) (.aclk(aclk), .aresetn(aresetn), .s_axi(s_axim_ctrl[i]), .m_axi(axim_ctrl_s0[i]));
    end


    // Clock crossing (if enabled)
    // ----------------------------------------------------------------------
    AXI4L axi_ctrl_user_s0 [N_REGIONS] ();
    metaIntf #(.STYPE(irq_not_t)) notify [N_REGIONS] ();
    metaIntf #(.STYPE(irq_not_t)) notify_s0 [N_REGIONS] ();
    metaIntf #(.STYPE(dreq_t)) host_sq [N_REGIONS] ();
    metaIntf #(.STYPE(dreq_t)) host_sq_s0 [N_REGIONS] ();
    metaIntf #(.STYPE(req_t)) bpss_rd_sq [N_REGIONS] ();
    metaIntf #(.STYPE(req_t)) bpss_wr_sq [N_REGIONS] ();
    metaIntf #(.STYPE(req_t)) bpss_rd_sq_s0 [N_REGIONS] ();
    metaIntf #(.STYPE(req_t)) bpss_wr_sq_s0 [N_REGIONS] ();
    metaIntf #(.STYPE(ack_t)) bpss_rd_cq [N_REGIONS] ();
    metaIntf #(.STYPE(ack_t)) bpss_wr_cq [N_REGIONS] ();
    metaIntf #(.STYPE(ack_t)) bpss_rd_cq_s0 [N_REGIONS] ();
    metaIntf #(.STYPE(ack_t)) bpss_wr_cq_s0 [N_REGIONS] ();


    for(genvar i = 0; i < N_REGIONS; i++) begin
        `AXIL_ASSIGN(axi_ctrl_user[i], axi_ctrl_user_s0[i])
        `META_ASSIGN(notify_s0[i], notify[i])
        `META_ASSIGN(host_sq[i], host_sq_s0[i])
        `META_ASSIGN(bpss_rd_sq_s0[i], bpss_rd_sq[i])
        `META_ASSIGN(bpss_wr_sq_s0[i], bpss_wr_sq[i])
        `META_ASSIGN(bpss_rd_cq[i], bpss_rd_cq_s0[i])
        `META_ASSIGN(bpss_wr_cq[i], bpss_wr_cq_s0[i])
    end

	

    // Slice 1
	// ----------------------------------------------------------------------
    AXI4L axi_ctrl_user_s1 [N_REGIONS] ();
    metaIntf #(.STYPE(irq_not_t)) notify_s1 [N_REGIONS] ();
    metaIntf #(.STYPE(dreq_t)) host_sq_s1 [N_REGIONS] ();
    metaIntf #(.STYPE(req_t)) bpss_rd_sq_s1 [N_REGIONS] ();
    metaIntf #(.STYPE(req_t)) bpss_wr_sq_s1 [N_REGIONS] ();
    metaIntf #(.STYPE(ack_t)) bpss_rd_cq_s1 [N_REGIONS] ();
    metaIntf #(.STYPE(ack_t)) bpss_wr_cq_s1 [N_REGIONS] ();

    for(genvar i = 0; i < N_REGIONS; i++) begin
        axil_reg_array #(.N_STAGES(N_REG_DYN_HOST_S0)) (.aclk(aclk), .aresetn(aresetn), .s_axi(axi_ctrl_user_s0[i]), .m_axi(axi_ctrl_user_s1[i]));
        meta_reg_array #(.DATA_BITS(NOTIFY_BITS), .N_STAGES(N_REG_DYN_HOST_S1)) (.aclk(aclk), .aresetn(aresetn), .s_meta(notify_s1[i]), .m_meta(notify_s0[i]));
        meta_reg_array #(.DATA_BITS($bits(dreq_t)), .N_STAGES(N_REG_DYN_HOST_S1)) (.aclk(aclk), .aresetn(aresetn), .s_meta(host_sq_s0[i]), .m_meta(host_sq_s1[i]));
        meta_reg_array #(.DATA_BITS($bits(req_t)), .N_STAGES(N_REG_DYN_HOST_S1)) (.aclk(aclk), .aresetn(aresetn), .s_meta(bpss_rd_sq_s1[i]), .m_meta(bpss_rd_sq_s0[i]));
        meta_reg_array #(.DATA_BITS($bits(req_t)), .N_STAGES(N_REG_DYN_HOST_S1)) (.aclk(aclk), .aresetn(aresetn), .s_meta(bpss_wr_sq_s1[i]), .m_meta(bpss_wr_sq_s0[i]));
        meta_reg_array #(.DATA_BITS($bits(ack_t)), .N_STAGES(N_REG_DYN_HOST_S1)) (.aclk(aclk), .aresetn(aresetn), .s_meta(bpss_rd_cq_s0[i]), .m_meta(bpss_rd_cq_s1[i]));
        meta_reg_array #(.DATA_BITS($bits(ack_t)), .N_STAGES(N_REG_DYN_HOST_S1)) (.aclk(aclk), .aresetn(aresetn), .s_meta(bpss_wr_cq_s0[i]), .m_meta(bpss_wr_cq_s1[i]));
    end	

	// Decoupling 
	// ----------------------------------------------------------------------
	AXI4L axi_ctrl_user_ul [N_REGIONS] ();
    metaIntf #(.STYPE(irq_not_t)) notify_ul [N_REGIONS] ();
    metaIntf #(.STYPE(dreq_t)) host_sq_ul [N_REGIONS] ();
    metaIntf #(.STYPE(req_t)) bpss_rd_sq_ul [N_REGIONS] ();
    metaIntf #(.STYPE(req_t)) bpss_wr_sq_ul [N_REGIONS] ();
    metaIntf #(.STYPE(ack_t)) bpss_rd_cq_ul [N_REGIONS] ();
    metaIntf #(.STYPE(ack_t)) bpss_wr_cq_ul [N_REGIONS] ();
    

    axil_decoupler (.decouple(decouple_uclk), .s_axi(axi_ctrl_user_s1), .m_axi(axi_ctrl_user_ul));
    meta_decoupler (.decouple(decouple_uclk), .s_meta(notify_ul), .m_meta(notify_s1));
    meta_decoupler (.decouple(decouple_uclk), .s_meta(host_sq_s1), .m_meta(host_sq_ul));
    meta_decoupler (.decouple(decouple_uclk), .s_meta(bpss_rd_sq_ul), .m_meta(bpss_rd_sq_s1));
    meta_decoupler (.decouple(decouple_uclk), .s_meta(bpss_wr_sq_ul), .m_meta(bpss_wr_sq_s1));
    meta_decoupler (.decouple(decouple_uclk), .s_meta(bpss_rd_cq_s1), .m_meta(bpss_rd_cq_ul));
    meta_decoupler (.decouple(decouple_uclk), .s_meta(bpss_wr_cq_s1), .m_meta(bpss_wr_cq_ul));

    // ================-----------------------------------------------------------------
	// MMU and CONFIG 
	// ================-----------------------------------------------------------------
    
    dynamic_crossbar #(
        .ID_DYN(ID_DYN)
	) inst_dyn_crossbar (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axi_ctrl(axi_ctrl_s0),
        .m_axi_ctrl_cnfg(axi_ctrl_cnfg),
        .m_axi_ctrl_sTlb(axi_ctrl_sTlb),
        .m_axi_ctrl_lTlb(axi_ctrl_lTlb),
        .m_axi_ctrl_user(axi_ctrl_user)
	);
	
    for(genvar i = 0; i < N_REGIONS; i++) begin
        `AXIL_TIE_OFF_S(axi_ctrl_cnfg[i])
    end

	
    // Dynamic management
	mmu_top #(
        .ID_DYN(ID_DYN)
	) inst_mmu_top (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axi_ctrl_lTlb(axi_ctrl_lTlb),
        .s_axi_ctrl_sTlb(axi_ctrl_sTlb),
		.s_axim_ctrl_cnfg(axim_ctrl_s0),
	
        .s_notify(notify),
        .m_host_sq(host_sq),
        .s_bpss_rd_sq(bpss_rd_sq),
        .s_bpss_wr_sq(bpss_wr_sq),
        .m_bpss_rd_cq(bpss_rd_cq),
        .m_bpss_wr_cq(bpss_wr_cq),
        .m_rd_XDMA_host(rd_XDMA_host),
        .m_wr_XDMA_host(wr_XDMA_host),
        .m_mux_host_rd(mux_host_rd_user),
        .m_mux_host_wr(mux_host_wr_user),
	
	
        .m_wback(m_wback),
	
        .usr_irq(m_usr_irq)
	);
	
	// ================-----------------------------------------------------------------
	// USER 
	// ================-----------------------------------------------------------------
    design_user_wrapper_0 inst_user_wrapper_0 ( 
        
        // AXIL CTRL
        .axi_ctrl_araddr                (axi_ctrl_user_ul[0].araddr),
        .axi_ctrl_arprot                (axi_ctrl_user_ul[0].arprot),
        .axi_ctrl_arready               (axi_ctrl_user_ul[0].arready),
        .axi_ctrl_arvalid               (axi_ctrl_user_ul[0].arvalid),
        .axi_ctrl_awaddr                (axi_ctrl_user_ul[0].awaddr),
        .axi_ctrl_awprot                (axi_ctrl_user_ul[0].awprot),
        .axi_ctrl_awready               (axi_ctrl_user_ul[0].awready),
        .axi_ctrl_awvalid               (axi_ctrl_user_ul[0].awvalid),
        .axi_ctrl_bready                (axi_ctrl_user_ul[0].bready),
        .axi_ctrl_bresp                 (axi_ctrl_user_ul[0].bresp),
        .axi_ctrl_bvalid                (axi_ctrl_user_ul[0].bvalid),
        .axi_ctrl_rdata                 (axi_ctrl_user_ul[0].rdata),
        .axi_ctrl_rready                (axi_ctrl_user_ul[0].rready),
        .axi_ctrl_rresp                 (axi_ctrl_user_ul[0].rresp),
        .axi_ctrl_rvalid                (axi_ctrl_user_ul[0].rvalid),
        .axi_ctrl_wdata                 (axi_ctrl_user_ul[0].wdata),
        .axi_ctrl_wready                (axi_ctrl_user_ul[0].wready),
        .axi_ctrl_wstrb                 (axi_ctrl_user_ul[0].wstrb),
        .axi_ctrl_wvalid                (axi_ctrl_user_ul[0].wvalid),

        // NOTIFY
        .notify_valid                   (notify_ul[0].valid),
        .notify_ready                   (notify_ul[0].ready),
        .notify_data                    (notify_ul[0].data),

        // HOST DESC
        .host_sq_valid	                (host_sq_ul[0].valid),
        .host_sq_ready	                (host_sq_ul[0].ready),
        .host_sq_data	                (host_sq_ul[0].data),

        // BPSS DESC
        .bpss_rd_sq_valid	            (bpss_rd_sq_ul[0].valid),
        .bpss_rd_sq_ready	            (bpss_rd_sq_ul[0].ready),
        .bpss_rd_sq_data	            (bpss_rd_sq_ul[0].data),
        .bpss_wr_sq_valid	            (bpss_wr_sq_ul[0].valid),
        .bpss_wr_sq_ready	            (bpss_wr_sq_ul[0].ready),
        .bpss_wr_sq_data	            (bpss_wr_sq_ul[0].data),
        .bpss_rd_cq_valid               (bpss_rd_cq_ul[0].valid),
        .bpss_rd_cq_ready               (bpss_rd_cq_ul[0].ready),
        .bpss_rd_cq_data                (bpss_rd_cq_ul[0].data),
        .bpss_wr_cq_valid               (bpss_wr_cq_ul[0].valid),
        .bpss_wr_cq_ready               (bpss_wr_cq_ul[0].ready),
        .bpss_wr_cq_data                (bpss_wr_cq_ul[0].data),
        
        // HOST STREAMS
        .axis_host_sink_tdata           (axis_host_in_ul[0].tdata),
        .axis_host_sink_tkeep           (axis_host_in_ul[0].tkeep),
        .axis_host_sink_tlast           (axis_host_in_ul[0].tlast),
        .axis_host_sink_tready          (axis_host_in_ul[0].tready),
        .axis_host_sink_tvalid          (axis_host_in_ul[0].tvalid),
        .axis_host_src_tdata            (axis_host_out_ul[0].tdata),
        .axis_host_src_tkeep            (axis_host_out_ul[0].tkeep),
        .axis_host_src_tlast            (axis_host_out_ul[0].tlast),
        .axis_host_src_tready           (axis_host_out_ul[0].tready),
        .axis_host_src_tvalid           (axis_host_out_ul[0].tvalid),
        .S_BSCAN_drck(S_BSCAN_drck[0]),
        .S_BSCAN_shift(S_BSCAN_shift[0]),
        .S_BSCAN_tdi(S_BSCAN_tdi[0]),
        .S_BSCAN_update(S_BSCAN_update[0]),
        .S_BSCAN_sel(S_BSCAN_sel[0]),
        .S_BSCAN_tdo(S_BSCAN_tdo[0]),
        .S_BSCAN_tms(S_BSCAN_tms[0]),
        .S_BSCAN_tck(S_BSCAN_tck[0]),
        .S_BSCAN_runtest(S_BSCAN_runtest[0]),
        .S_BSCAN_reset(S_BSCAN_reset[0]),
        .S_BSCAN_capture(S_BSCAN_capture[0]),
        .S_BSCAN_bscanid_en(S_BSCAN_bscanid_en[0]),
        .aclk                   (aclk),
        .aresetn                (aresetn),
        .dclk                   (dclk)
    );

	
endmodule
	