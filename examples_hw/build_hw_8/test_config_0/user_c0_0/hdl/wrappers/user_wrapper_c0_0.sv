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

`include "axi_macros.svh"
`include "lynx_macros.svh"
	
/**
 * User logic wrapper
 * 
 */
module design_user_wrapper_0 (
    // AXI4L CONTROL
    (* io_buffer_type = "none" *) input  logic[AXI_ADDR_BITS-1:0]             axi_ctrl_araddr,
    (* io_buffer_type = "none" *) input  logic[2:0]                           axi_ctrl_arprot,
    (* io_buffer_type = "none" *) output logic                                axi_ctrl_arready,
    (* io_buffer_type = "none" *) input  logic                                axi_ctrl_arvalid,
    (* io_buffer_type = "none" *) input  logic[AXI_ADDR_BITS-1:0]             axi_ctrl_awaddr,
    (* io_buffer_type = "none" *) input  logic[2:0]                           axi_ctrl_awprot,
    (* io_buffer_type = "none" *) output logic                                axi_ctrl_awready,
    (* io_buffer_type = "none" *) input  logic                                axi_ctrl_awvalid, 
    (* io_buffer_type = "none" *) input  logic                                axi_ctrl_bready,
    (* io_buffer_type = "none" *) output logic[1:0]                           axi_ctrl_bresp,
    (* io_buffer_type = "none" *) output logic                                axi_ctrl_bvalid,
    (* io_buffer_type = "none" *) output logic[AXI_ADDR_BITS-1:0]             axi_ctrl_rdata,
    (* io_buffer_type = "none" *) input  logic                                axi_ctrl_rready,
    (* io_buffer_type = "none" *) output logic[1:0]                           axi_ctrl_rresp,
    (* io_buffer_type = "none" *) output logic                                axi_ctrl_rvalid,
    (* io_buffer_type = "none" *) input  logic[AXIL_DATA_BITS-1:0]            axi_ctrl_wdata,
    (* io_buffer_type = "none" *) output logic                                axi_ctrl_wready,
    (* io_buffer_type = "none" *) input  logic[(AXIL_DATA_BITS/8)-1:0]        axi_ctrl_wstrb,
    (* io_buffer_type = "none" *) input  logic                                axi_ctrl_wvalid,

    // NOTIFY
    (* io_buffer_type = "none" *) output logic                                notify_valid,
    (* io_buffer_type = "none" *) input  logic                                notify_ready,
    (* io_buffer_type = "none" *) output irq_not_t                            notify_data,

    // HOST DESCRIPTORS
    (* io_buffer_type = "none" *) input  logic 							      host_sq_valid,
    (* io_buffer_type = "none" *) output logic 							      host_sq_ready,
    (* io_buffer_type = "none" *) input  dreq_t 							  host_sq_data,

    // BYPASS DESCRIPTORS
    (* io_buffer_type = "none" *) output logic                                bpss_rd_sq_valid,
    (* io_buffer_type = "none" *) input  logic                                bpss_rd_sq_ready,
    (* io_buffer_type = "none" *) output req_t                                bpss_rd_sq_data,
    (* io_buffer_type = "none" *) output logic                                bpss_wr_sq_valid,
    (* io_buffer_type = "none" *) input  logic                                bpss_wr_sq_ready,
    (* io_buffer_type = "none" *) output req_t                                bpss_wr_sq_data,
    (* io_buffer_type = "none" *) input  logic                                bpss_rd_cq_valid,
    (* io_buffer_type = "none" *) output logic                                bpss_rd_cq_ready,
    (* io_buffer_type = "none" *) input  ack_t                                bpss_rd_cq_data,
    (* io_buffer_type = "none" *) input  logic                                bpss_wr_cq_valid,
    (* io_buffer_type = "none" *) output logic                                bpss_wr_cq_ready,
    (* io_buffer_type = "none" *) input  ack_t                                bpss_wr_cq_data,

    // AXI4S HOST SINK
    (* io_buffer_type = "none" *) input  logic[AXI_DATA_BITS-1:0]             axis_host_sink_tdata,
    (* io_buffer_type = "none" *) input  logic[AXI_DATA_BITS/8-1:0]           axis_host_sink_tkeep,
    (* io_buffer_type = "none" *) input  logic                                axis_host_sink_tlast,
    (* io_buffer_type = "none" *) output logic                                axis_host_sink_tready,
    (* io_buffer_type = "none" *) input  logic                                axis_host_sink_tvalid,

	// AXI4S HOST SOURCE
    (* io_buffer_type = "none" *) output logic[AXI_DATA_BITS-1:0]             axis_host_src_tdata,
    (* io_buffer_type = "none" *) output logic[AXI_DATA_BITS/8-1:0]           axis_host_src_tkeep,
    (* io_buffer_type = "none" *) output logic                                axis_host_src_tlast,
    (* io_buffer_type = "none" *) input  logic                                axis_host_src_tready,
    (* io_buffer_type = "none" *) output logic                                axis_host_src_tvalid,
  
    // BSCAN
    (* io_buffer_type = "none" *) input  logic                                S_BSCAN_drck,
    (* io_buffer_type = "none" *) input  logic                                S_BSCAN_shift,
    (* io_buffer_type = "none" *) input  logic                                S_BSCAN_tdi,
    (* io_buffer_type = "none" *) input  logic                                S_BSCAN_update,
    (* io_buffer_type = "none" *) input  logic                                S_BSCAN_sel,
    (* io_buffer_type = "none" *) output logic                                S_BSCAN_tdo,
    (* io_buffer_type = "none" *) input  logic                                S_BSCAN_tms,
    (* io_buffer_type = "none" *) input  logic                                S_BSCAN_tck,
    (* io_buffer_type = "none" *) input  logic                                S_BSCAN_runtest,
    (* io_buffer_type = "none" *) input  logic                                S_BSCAN_reset,
    (* io_buffer_type = "none" *) input  logic                                S_BSCAN_capture,
    (* io_buffer_type = "none" *) input  logic                                S_BSCAN_bscanid_en,

    // Clock and reset
    (* io_buffer_type = "none" *) input  logic                                aclk,
    (* io_buffer_type = "none" *) input  logic[0:0]                           aresetn,
    (* io_buffer_type = "none" *) input  logic                                dclk
);


    // 
    // INTERFACE CONV.
    //

    // AXIL control
    AXI4L axi_ctrl_user();
    AXI4L axi_ctrl_user_int();

    assign axi_ctrl_user.araddr                 = axi_ctrl_araddr;
    assign axi_ctrl_user.arprot                 = axi_ctrl_arprot;
    assign axi_ctrl_user.arvalid                = axi_ctrl_arvalid;
    assign axi_ctrl_user.awaddr                 = axi_ctrl_awaddr;
    assign axi_ctrl_user.awprot                 = axi_ctrl_awprot;
    assign axi_ctrl_user.awvalid                = axi_ctrl_awvalid;
    assign axi_ctrl_user.bready                 = axi_ctrl_bready;
    assign axi_ctrl_user.rready                 = axi_ctrl_rready;
    assign axi_ctrl_user.wdata                  = axi_ctrl_wdata;
    assign axi_ctrl_user.wstrb                  = axi_ctrl_wstrb;
    assign axi_ctrl_user.wvalid                 = axi_ctrl_wvalid;
    assign axi_ctrl_arready                     = axi_ctrl_user.arready;
    assign axi_ctrl_awready                     = axi_ctrl_user.awready;
    assign axi_ctrl_bresp                       = axi_ctrl_user.bresp;
    assign axi_ctrl_bvalid                      = axi_ctrl_user.bvalid;
    assign axi_ctrl_rdata                       = axi_ctrl_user.rdata;
    assign axi_ctrl_rresp                       = axi_ctrl_user.rresp;
    assign axi_ctrl_rvalid                      = axi_ctrl_user.rvalid;
    assign axi_ctrl_wready                      = axi_ctrl_user.wready;

    // Notify
    metaIntf #(.STYPE(irq_not_t)) notify ();
    metaIntf #(.STYPE(irq_not_t)) notify_int ();

    assign notify_valid                         = notify.valid;
    assign notify_data                          = notify.data;
    assign notify.ready                         = notify_ready;

    // Host descriptors
    metaIntf #(.STYPE(dreq_t)) host_sq ();
    metaIntf #(.STYPE(dreq_t)) host_sq_int ();
    
    assign host_sq.valid                        = host_sq_valid;
    assign host_sq_ready                        = host_sq.ready;
    assign host_sq.data                         = host_sq_data;

    // Bypass descriptors
    metaIntf #(.STYPE(req_t)) bpss_rd_req ();
    metaIntf #(.STYPE(req_t)) bpss_wr_req ();
    metaIntf #(.STYPE(req_t)) bpss_rd_req_int ();
    metaIntf #(.STYPE(req_t)) bpss_wr_req_int ();
    
    assign bpss_rd_sq_valid                     = bpss_rd_req.valid;
    assign bpss_rd_req.ready                    = bpss_rd_sq_ready; 
    assign bpss_rd_sq_data                      = bpss_rd_req.data;

    assign bpss_wr_sq_valid                     = bpss_wr_req.valid;
    assign bpss_wr_req.ready                    = bpss_wr_sq_ready; 
    assign bpss_wr_sq_data                      = bpss_wr_req.data; 

    metaIntf #(.STYPE(ack_t)) bpss_rd_cq ();
    metaIntf #(.STYPE(ack_t)) bpss_wr_cq ();
    metaIntf #(.STYPE(ack_t)) bpss_rd_cq_int ();
    metaIntf #(.STYPE(ack_t)) bpss_wr_cq_int ();

    assign bpss_rd_cq.valid                     = bpss_rd_cq_valid;
    assign bpss_rd_cq.data                      = bpss_rd_cq_data;
    assign bpss_rd_cq_ready                     = bpss_rd_cq.ready;

    assign bpss_wr_cq.valid                     = bpss_wr_cq_valid;
    assign bpss_wr_cq.data                      = bpss_wr_cq_data;
    assign bpss_wr_cq_ready                     = bpss_wr_cq.ready;

    AXI4S axis_host_sink ();
    AXI4S axis_host_sink_int ();

    assign axis_host_sink.tvalid                = axis_host_sink_tvalid;
    assign axis_host_sink.tdata                 = axis_host_sink_tdata;
    assign axis_host_sink.tkeep                 = axis_host_sink_tkeep;
    assign axis_host_sink.tlast                 = axis_host_sink_tlast;
    assign axis_host_sink_tready                = axis_host_sink.tready;

    AXI4S axis_host_src ();
    AXI4S axis_host_src_int ();

    assign axis_host_src_tvalid                 = axis_host_src.tvalid;
    assign axis_host_src_tdata                  = axis_host_src.tdata;
    assign axis_host_src_tkeep                  = axis_host_src.tkeep;
    assign axis_host_src_tlast                  = axis_host_src.tlast;
    assign axis_host_src.tready                 = axis_host_src_tready;


    // 
    // ASSIGN (NO REGS)
    //

    // AXIL control
    `AXIL_ASSIGN(axi_ctrl_user, axi_ctrl_user_int)

    // Notify
    `META_ASSIGN(notify_int, notify)

    // Host request
    `META_ASSIGN(host_sq, host_sq_int)

    // Bypass
    `META_ASSIGN(bpss_rd_req_int, bpss_rd_req)
    `META_ASSIGN(bpss_wr_req_int, bpss_wr_req)
    `META_ASSIGN(bpss_rd_cq, bpss_rd_cq_int)
    `META_ASSIGN(bpss_wr_cq, bpss_wr_cq_int)

 
 
    // AXIS host
    `AXIS_ASSIGN(axis_host_sink, axis_host_sink_int)
    `AXIS_ASSIGN(axis_host_src_int, axis_host_src)



    //
    // SQ
    //

    metaIntf #(.STYPE(req_t)) user_sq_rd_int ();
    metaIntf #(.STYPE(req_t)) user_sq_wr_int ();

    metaIntf #(.STYPE(req_t)) host_local_sq_rd ();
    metaIntf #(.STYPE(req_t)) host_local_sq_wr ();
    metaIntf #(.STYPE(req_t)) user_local_sq_rd ();
    metaIntf #(.STYPE(req_t)) user_local_sq_wr ();

    metaIntf #(.STYPE(req_t)) local_sq_rd ();
    metaIntf #(.STYPE(req_t)) local_sq_wr ();


    // Host request mux
    host_req_mux inst_host_mux (
        .host_sq(host_sq_int),
        .host_local_rd(host_local_sq_rd),
        .host_local_wr(host_local_sq_wr),
        .aclk(aclk),
        .aresetn(aresetn)
    );

    // User request mux
    user_req_mux #(
        .ID_REG(0)
    ) inst_user_mux (
        .user_sq_rd(user_sq_rd_int),
        .user_sq_wr(user_sq_wr_int),
        .user_local_rd(user_local_sq_rd),
        .user_local_wr(user_local_sq_wr),
        .aclk(aclk),
        .aresetn(aresetn)
    );

    // Host user arbiters
    req_arb_2_1 inst_arb_local_rd (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_req_0(user_local_sq_rd),
        .s_req_1(host_local_sq_rd),
        .m_req(local_sq_rd)
    );

    req_arb_2_1 inst_arb_local_wr (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_req_0(user_local_sq_wr),
        .s_req_1(host_local_sq_wr),
        .m_req(local_sq_wr)
    );


    //
    // Local credits
    // 
    metaIntf #(.STYPE(req_t)) local_sq_rd_host ();
    metaIntf #(.STYPE(req_t)) local_sq_rd_card ();
    metaIntf #(.STYPE(req_t)) local_sq_wr_host ();
    metaIntf #(.STYPE(req_t)) local_sq_wr_card ();

    metaIntf #(.STYPE(req_t)) local_cred_rd_host ();
    metaIntf #(.STYPE(req_t)) local_cred_rd_card ();
    metaIntf #(.STYPE(req_t)) local_cred_wr_host ();
    metaIntf #(.STYPE(req_t)) local_cred_wr_card ();

    AXI4SR axis_host_send_int [N_STRM_AXI] ();
    AXI4SR axis_host_recv_int [N_STRM_AXI] ();
    AXI4SR axis_card_send_int [N_CARD_AXI] ();
    AXI4SR axis_card_recv_int [N_CARD_AXI] (); 
    
    `META_ASSIGN(local_sq_rd, local_sq_rd_host)
    `META_ASSIGN(local_sq_wr, local_sq_wr_host)

    local_credits_host_rd #(
        .N_DESTS(N_STRM_AXI)
    ) inst_local_credits_host_rd (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_req(local_sq_rd_host),
        .m_req(local_cred_rd_host),
        .s_axis(axis_host_sink_int),
        .m_axis(axis_host_recv_int)
    );

    local_credits_host_wr #(
        .N_DESTS(N_STRM_AXI)
    ) inst_local_credits_host_wr (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_req(local_sq_wr_host),
        .m_req(local_cred_wr_host),
        .s_axis(axis_host_send_int),
        .m_axis(axis_host_src_int)
    );

    `META_ASSIGN(local_cred_rd_host, bpss_rd_req_int)
    `META_ASSIGN(local_cred_wr_host, bpss_wr_req_int)


    //
    // Remote credits
    // 


    //
    // CQ
    // 

    metaIntf #(.STYPE(ack_t)) user_cq_rd_int ();
    metaIntf #(.STYPE(ack_t)) user_cq_wr_int ();

    `META_ASSIGN(bpss_rd_cq, user_cq_rd_int)
    `META_ASSIGN(bpss_wr_cq, user_cq_wr_int)

    //
	// USER LOGIC
    //

    design_user_logic_c0_0 inst_user_c0_0 (
	    .axi_ctrl(axi_ctrl_user),
        .notify(notify),
        .sq_rd(user_sq_rd_int),
        .sq_wr(user_sq_wr_int),
        .cq_rd(user_cq_rd_int),
        .cq_wr(user_cq_wr_int),
        
        .axis_host_recv(axis_host_recv_int),
        .axis_host_send(axis_host_send_int),
        .aclk(aclk),
	    .aresetn(aresetn)
	);

    //
    // DEBUG
    //
    debug_bridge_user inst_debug_bridge_user (
        .clk(dclk),
        .S_BSCAN_bscanid_en(S_BSCAN_bscanid_en),
        .S_BSCAN_capture(S_BSCAN_capture),
        .S_BSCAN_drck(S_BSCAN_drck),
        .S_BSCAN_reset(S_BSCAN_reset),
        .S_BSCAN_runtest(S_BSCAN_runtest),
        .S_BSCAN_sel(S_BSCAN_sel),
        .S_BSCAN_shift(S_BSCAN_shift),
        .S_BSCAN_tck(S_BSCAN_tck),
        .S_BSCAN_tdi(S_BSCAN_tdi),
        .S_BSCAN_tdo(S_BSCAN_tdo),
        .S_BSCAN_tms(S_BSCAN_tms),
        .S_BSCAN_update(S_BSCAN_update)
    );

	
endmodule
	