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

	
endmodule
	