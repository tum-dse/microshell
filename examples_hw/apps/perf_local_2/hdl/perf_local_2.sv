`timescale 1ns / 1ps

import lynxTypes::*;

`include "axi_macros.svh"

// Same body as perf_local: bumps every 32-bit lane by 1. perf_local_2's
// vfpga_top instantiates two of these chained through an internal AXI4SR
// to test back-to-back streaming.
module perf_local_2 (
    AXI4SR.s axis_sink,
    AXI4SR.m axis_src,

    input  logic aclk,
    input  logic aresetn
);

// Skid registers isolate kernel timing from upstream/downstream.
AXI4SR axis_sink_int ();
AXI4SR axis_src_int ();

axisr_reg inst_reg_sink (.aclk(aclk), .aresetn(aresetn), .s_axis(axis_sink),     .m_axis(axis_sink_int));
axisr_reg inst_reg_src  (.aclk(aclk), .aresetn(aresetn), .s_axis(axis_src_int), .m_axis(axis_src));

// 16 × 32-bit lanes = 512 bits, matching the AXI4SR data width.
always_comb begin
    axis_src_int.tvalid  = axis_sink_int.tvalid;
    for(int i = 0; i < 16; i++)
        axis_src_int.tdata[i*32+:32] = axis_sink_int.tdata[i*32+:32] + 1;
    axis_src_int.tkeep   = axis_sink_int.tkeep;
    axis_src_int.tid     = axis_sink_int.tid;
    axis_src_int.tlast   = axis_sink_int.tlast;
    axis_src_int.tid     = 0;  // overrides line above; downstream ignores tid

    axis_sink_int.tready = axis_src_int.tready;
end

endmodule
