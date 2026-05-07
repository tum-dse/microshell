`timescale 1ns / 1ps

import lynxTypes::*;

`include "axi_macros.svh"

// Perf-local kernel (axis_src = axis_sink+1 lane-wise) plus an idle-cycle
// counter that measures the gap between the last accepted output beat and
// the next accepted input beat. last_idle_cycles is exposed for the host
// via user_data, so the host-side micro-benchmark can read how long the
// kernel sat idle between transfers without needing a separate AXI-Lite
// readback path.
module perf_counter (
    AXI4SR.s             axis_sink,
    AXI4SR.m             axis_src,
    output logic [31:0]  last_idle_cycles,

    input  logic         aclk,
    input  logic         aresetn
);

// Skid registers isolate kernel timing from upstream/downstream.
AXI4SR axis_sink_int ();
AXI4SR axis_src_int ();

axisr_reg inst_reg_sink (.aclk(aclk), .aresetn(aresetn), .s_axis(axis_sink),     .m_axis(axis_sink_int));
axisr_reg inst_reg_src  (.aclk(aclk), .aresetn(aresetn), .s_axis(axis_src_int), .m_axis(axis_src));

// Idle counter: starts when the kernel first emits an output beat,
// stops when the next input beat arrives, latches the result.
logic count_enable;
logic [31:0] idle_counter;
logic [31:0] last_idle_cycles;
logic send_end;
logic last_send_end;
logic receive_end;

always_ff @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        count_enable     <= 0;
        idle_counter     <= 0;
        last_idle_cycles <= 0;
        send_end         <= 0;
        last_send_end    <= 0;
        receive_end      <= 0;
    end else begin
        send_end    <= axis_src_int.tvalid && axis_src_int.tready;
        receive_end <= axis_sink_int.tvalid && axis_sink_int.tready;

        if (send_end && last_send_end == 0) begin
            count_enable  <= 1;
            idle_counter  <= 0;
            last_send_end <= 1;
        end else if (count_enable) begin
            if (receive_end) begin
                last_idle_cycles <= idle_counter;
                count_enable     <= 0;
                idle_counter     <= 0;
                last_send_end    <= 0;
            end else begin
                idle_counter <= idle_counter + 1;
            end
        end
    end
end

always_comb begin
    axis_src_int.tvalid  = axis_sink_int.tvalid;
    for(int i = 0; i < 16; i++)
        axis_src_int.tdata[i*32+:32] = axis_sink_int.tdata[i*32+:32] + 1;
    axis_src_int.tkeep   = axis_sink_int.tkeep;
    axis_src_int.tid     = axis_sink_int.tid;
    axis_src_int.tlast   = axis_sink_int.tlast;
    axis_src_int.tid     = 0;

    axis_sink_int.tready = axis_src_int.tready;
end

ila_perf_counter inst_ila_perf_counter_c1 (
    .clk(aclk),
    .probe0(send_end),
    .probe1(last_send_end),
    .probe2(count_enable),
    .probe3(last_idle_cycles)
);

endmodule
