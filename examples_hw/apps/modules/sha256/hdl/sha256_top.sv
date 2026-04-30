`timescale 1ns / 1ps
import lynxTypes::*;
`include "axi_macros.svh"

module sha256_top (
    AXI4SR.s axis_sink,
    AXI4SR.m axis_src,
    input logic aclk,
    input logic aresetn
);
    logic [511:0] axis_sink_tdata;
    logic         axis_sink_tvalid;
    logic         axis_sink_tlast;
    logic         axis_sink_tready;

    logic [255:0] axis_src_tdata;
    logic [63:0]  axis_src_tkeep;
    logic [7:0]   axis_src_tid;
    logic         axis_src_tvalid;
    logic         axis_src_tlast;
    logic         axis_src_tready;

    assign axis_sink_tdata  = axis_sink.tdata;
    assign axis_sink_tvalid = axis_sink.tvalid;
    assign axis_sink_tlast  = axis_sink.tlast;
    assign axis_sink.tready = axis_sink_tready;

    sha256 inst_sha (
        .aclk            (aclk),
        .aresetn         (aresetn),
        .axis_sink_tdata (axis_sink_tdata),
        .axis_sink_tvalid(axis_sink_tvalid),
        .axis_sink_tlast (axis_sink_tlast),
        .axis_sink_tready(axis_sink_tready),
        .axis_src_tdata  (axis_src_tdata),
        .axis_src_tkeep  (axis_src_tkeep),
        .axis_src_tid    (axis_src_tid),
        .axis_src_tvalid (axis_src_tvalid),
        .axis_src_tlast  (axis_src_tlast),
        .axis_src_tready (axis_src_tready)
    );

    dwidth_converter_256_512 inst_dwidth_send (
        .aclk         (aclk),
        .aresetn      (aresetn),
        .s_axis_tvalid(axis_src_tvalid),
        .s_axis_tready(axis_src_tready),
        .s_axis_tdata (axis_src_tdata),
        .s_axis_tlast (axis_src_tlast),
        .s_axis_tid   (axis_src_tid),
        .m_axis_tvalid(axis_src.tvalid),
        .m_axis_tready(axis_src.tready),
        .m_axis_tdata (axis_src.tdata),
        .m_axis_tlast (axis_src.tlast),
        .m_axis_tid   (axis_src.tid)
    );
endmodule
