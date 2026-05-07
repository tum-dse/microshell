`timescale 1ns / 1ps
import lynxTypes::*;
`include "axi_macros.svh"

// Pass-through latency probe: forwards every beat unchanged and reports
// cycles between the first valid beat of a packet and its tlast on
// cycle_count / count_valid.
module counter_top (
    AXI4SR.s             axis_sink,
    AXI4SR.m             axis_src,

    input  logic         aclk,
    input  logic         aresetn,

    output logic [31:0]  cycle_count,
    output logic         count_valid
);
    logic first_data_seen;
    logic pipeline_start_event;
    logic pipeline_end_event;

    assign axis_src.tdata   = axis_sink.tdata;
    assign axis_src.tvalid  = axis_sink.tvalid;
    assign axis_src.tlast   = axis_sink.tlast;
    assign axis_src.tkeep   = axis_sink.tkeep;
    assign axis_src.tid     = axis_sink.tid;
    assign axis_sink.tready = axis_src.tready;

    // Latches on the first accepted beat, clears on tlast.
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            first_data_seen <= 1'b0;
        end else if (axis_sink.tvalid && axis_sink.tready && !first_data_seen) begin
            first_data_seen <= 1'b1;
        end else if (axis_sink.tvalid && axis_sink.tready && axis_sink.tlast) begin
            first_data_seen <= 1'b0;
        end
    end

    assign pipeline_start_event = axis_sink.tvalid && axis_sink.tready && !first_data_seen;
    assign pipeline_end_event   = axis_sink.tvalid && axis_sink.tready && axis_sink.tlast;

    cycle_counter #(
        .COUNTER_WIDTH(32)
    ) inst_counter (
        .aclk        (aclk),
        .aresetn     (aresetn),
        .start_event (pipeline_start_event),
        .end_event   (pipeline_end_event),
        .cycle_count (cycle_count),
        .count_valid (count_valid)
    );

endmodule

// start_event resets and starts counting; end_event freezes the count
// and asserts count_valid until the next start.
module cycle_counter #(
    parameter COUNTER_WIDTH = 32
)(
    input  logic                     aclk,
    input  logic                     aresetn,
    input  logic                     start_event,
    input  logic                     end_event,
    output logic [COUNTER_WIDTH-1:0] cycle_count,
    output logic                     count_valid
);
    typedef enum logic [1:0] {
        IDLE,
        COUNTING,
        DONE
    } counter_state_t;

    counter_state_t state, next_state;
    logic [COUNTER_WIDTH-1:0] counter;
    logic counter_reset, counter_enable;

    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state = state;
        counter_reset = 1'b0;
        counter_enable = 1'b0;

        case (state)
            IDLE: begin
                if (start_event) begin
                    next_state = COUNTING;
                    counter_reset = 1'b1;
                end
            end

            COUNTING: begin
                counter_enable = 1'b1;
                if (end_event) begin
                    next_state = DONE;
                    counter_enable = 1'b0;
                end
            end

            DONE: begin
                // Stay in DONE so count_valid stays high until the next packet.
                if (start_event) begin
                    next_state = COUNTING;
                    counter_reset = 1'b1;
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            counter <= '0;
        end else if (counter_reset) begin
            counter <= '0;
        end else if (counter_enable) begin
            counter <= counter + 1'b1;
        end
    end

    assign cycle_count = counter;
    assign count_valid = (state == DONE);

endmodule
