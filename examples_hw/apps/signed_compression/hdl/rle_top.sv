`timescale 1ns / 1ps

import lynxTypes::*;

`include "axi_macros.svh"

// AXI4SR wrapper around the HLS rle_encode IP. Splays interface members
// into per-port wires; tkeep forced all-ones since upstream guarantees
// full beats.
module rle_top (
    AXI4SR.s axis_sink,
    AXI4SR.m axis_src,
    input logic aclk,
    input logic aresetn
);
    logic [511:0] axis_sink_tdata;
    logic [63:0]  axis_sink_tkeep;
    logic         axis_sink_tvalid;
    logic         axis_sink_tlast;
    logic         axis_sink_tready;

    logic [511:0] axis_src_tdata;
    logic [63:0]  axis_src_tkeep;
    logic         axis_src_tvalid;
    logic         axis_src_tlast;
    logic         axis_src_tready;

    assign axis_sink_tdata  = axis_sink.tdata;
    assign axis_sink_tvalid = axis_sink.tvalid;
    assign axis_sink_tlast  = axis_sink.tlast;
    assign axis_sink.tready = axis_sink_tready;
    assign axis_sink_tkeep  = 64'hFFFFFFFFFFFFFFFF;

    assign axis_src.tdata   = axis_src_tdata;
    assign axis_src.tvalid  = axis_src_tvalid;
    assign axis_src.tlast   = axis_src_tlast;
    assign axis_src_tready  = axis_src.tready;
    assign axis_src.tkeep   = 64'hFFFFFFFFFFFFFFFF;

    rle_encode inst_rle (
        .ap_clk(aclk),
        .ap_rst_n(aresetn),

        .input_stream_TVALID(axis_sink_tvalid),
        .input_stream_TREADY(axis_sink_tready),
        .input_stream_TDATA(axis_sink_tdata),
        .input_stream_TLAST(axis_sink_tlast),
        .input_stream_TKEEP(axis_sink_tkeep),

        .output_stream_TVALID(axis_src_tvalid),
        .output_stream_TREADY(axis_src_tready),
        .output_stream_TDATA(axis_src_tdata),
        .output_stream_TLAST(axis_src_tlast),
        .output_stream_TKEEP(axis_src_tkeep)
    );

endmodule
