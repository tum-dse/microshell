`timescale 1ns / 1ps
import lynxTypes::*;
`include "axi_macros.svh"

// AXI4SR wrapper around the third-party AES_engine, plus an ILA on the
// 128-bit head of the input/output streams for hardware bring-up.
module aes_top (
    AXI4SR.s axis_sink,
    AXI4SR.m axis_src,

    input logic aclk,
    input logic aresetn
);

logic [1:0] m_credit_control_internal;

logic [511:0] axis_sink_tdata;
logic [63:0]  axis_sink_tkeep;
logic         axis_sink_tvalid;
logic         axis_sink_tlast;
logic         axis_sink_tready;
logic [2:0]   axis_sink_tdest;
logic         axis_sink_tuser;

logic [511:0] axis_src_tdata;
logic [63:0]  axis_src_tkeep;
logic         axis_src_tvalid;
logic         axis_src_tlast;
logic         axis_src_tready;
logic [2:0]   axis_src_tdest;
logic         axis_src_tuser;

assign axis_sink_tdata  = axis_sink.tdata;
assign axis_sink_tvalid = axis_sink.tvalid;
assign axis_sink_tlast  = axis_sink.tlast;
assign axis_sink_tkeep  = axis_sink.tkeep;
assign axis_sink.tready = axis_sink_tready;

assign axis_sink_tdest = 3'b000;
assign axis_sink_tuser = 1'b0;

assign axis_src.tdata  = axis_src_tdata;
assign axis_src.tvalid = axis_src_tvalid;
assign axis_src.tlast  = axis_src_tlast;
assign axis_src.tkeep  = axis_src_tkeep;
assign axis_src.tid    = axis_sink.tid;
assign axis_src_tready = axis_src.tready;

AES_engine #(
    .AXI_DATA_WIDTH(512),
    .AXI_ADDR_WIDTH(16),
    .AXI_STRB_WIDTH(64),
    .AXI_ID_WIDTH(8),
    .AXIS_DATA_WIDTH(512),
    .AXIS_KEEP_ENABLE(1),
    .AXIS_KEEP_WIDTH(64),
    .AXIS_LAST_ENABLE(1),
    .AXIS_ID_ENABLE(0),
    .AXIS_ID_WIDTH(8),
    .AXIS_DEST_ENABLE(1),
    .AXIS_DEST_WIDTH(8),
    .AXIS_USER_ENABLE(1),
    .AXIS_USER_WIDTH(1),
    .LEN_WIDTH(16),
    .TAG_WIDTH(8),
    .SWITCH_DATA_WIDTH(512),
    .SWITCH_KEEP_WIDTH(64),
    .SWITCH_DEST_WIDTH(3),
    .SWITCH_USER_ENABLE(1),
    .SWITCH_USER_WIDTH(1),
    .NODE_ID(1),
    .INIT_CREDIT_NUM(64)
) aes_engine_inst (
    .clk(aclk),
    .rst(~aresetn),

    .m_credit_control(m_credit_control_internal),

    .s_switch_axis_tdata(axis_sink_tdata),
    .s_switch_axis_tkeep(axis_sink_tkeep),
    .s_switch_axis_tvalid(axis_sink_tvalid),
    .s_switch_axis_tready(axis_sink_tready),
    .s_switch_axis_tlast(axis_sink_tlast),
    .s_switch_axis_tdest(axis_sink_tdest),
    .s_switch_axis_tuser(axis_sink_tuser),

    .m_switch_axis_tdata(axis_src_tdata),
    .m_switch_axis_tkeep(axis_src_tkeep),
    .m_switch_axis_tvalid(axis_src_tvalid),
    .m_switch_axis_tready(axis_src_tready),
    .m_switch_axis_tlast(axis_src_tlast),
    .m_switch_axis_tdest(axis_src_tdest),
    .m_switch_axis_tuser(axis_src_tuser)
);

ila_0 ila_aes (
    .clk(aclk),

    .probe0(axis_sink_tvalid),
    .probe1(axis_sink_tready),
    .probe2(axis_sink_tlast),
    .probe3(axis_sink_tdata[127:0]),
    .probe4(axis_sink_tkeep[15:0]),
    .probe5(axis_sink_tdest),
    .probe6(axis_sink_tuser),

    .probe7(axis_src_tvalid),
    .probe8(axis_src_tready),
    .probe9(axis_src_tlast),
    .probe10(axis_src_tdata[127:0]),
    .probe11(axis_src_tkeep[15:0]),
    .probe12(axis_src_tdest),
    .probe13(axis_src_tuser)
);

endmodule
