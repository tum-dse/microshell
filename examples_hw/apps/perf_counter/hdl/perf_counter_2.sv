`timescale 1ns / 1ps

import lynxTypes::*;

`include "axi_macros.svh"

/**
 * Perf counter 2 example
 * 
 */
module perf_couter_2 (
    AXI4SR.s                                axis_sink,
    AXI4SR.m                                axis_src,

    input  logic                            aclk,
    input  logic                            aresetn,

    // New control and counter ports
    input  logic                            start_ctrl,
    output logic [31:0]                     cycle_count
);

// I/O
AXI4SR axis_sink_int ();
AXI4SR axis_src_int ();

axisr_reg inst_reg_sink (.aclk(aclk), .aresetn(aresetn), .s_axis(axis_sink), .m_axis(axis_sink_int));
axisr_reg inst_reg_src (.aclk(aclk), .aresetn(aresetn), .s_axis(axis_src_int), .m_axis(axis_src));

// State machine and control signals
typedef enum { IDLE, SEND_TEST, COUNTING } state_t;
state_t state, next_state;

logic [31:0] counter;
logic [31:0] captured_count; // Register to hold the completed test's cycle count
logic counter_en;
logic test_packet_sent;
logic response_detected;

// Test packet generation
logic [511:0] test_tdata;  // Assuming 16*32=512 bits tdata
logic test_tvalid;
logic test_tlast;
logic [15:0] test_tkeep;
logic test_tid;

// Detect when test packet is sent
assign test_packet_sent = test_tvalid && axis_src_int.tready;

// Check if received data matches expected response (all 0x00000001)
always_comb begin
    response_detected = 1'b1;
    for (int i = 0; i < 16; i++) begin
        if (axis_sink_int.tdata[i*32+:32] != 32'h00000001) begin
            response_detected = 1'b0;
        end
    end
end

// Detect when response is received
wire data_received = axis_sink_int.tvalid && axis_sink_int.tready && response_detected;

// State machine and counter
always_ff @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        state <= IDLE;
        counter <= 0;
        counter_en <= 0;
        captured_count <= 0; // Initialize captured_count on reset
    end else begin
        state <= next_state;
        if (counter_en) begin
            counter <= counter + 1;
        end else if (state == IDLE) begin
            counter <= 0;
        end

        // Capture counter value when test completes
        if (data_received) begin
            captured_count <= counter;
        end
    end
end

// Next state logic
always_comb begin
    next_state = state;
    case (state)
        IDLE: begin
            if (start_ctrl) begin
                next_state = SEND_TEST;
            end
        end
        SEND_TEST: begin
            if (test_packet_sent) begin
                next_state = COUNTING;
            end
        end
        COUNTING: begin
            if (data_received) begin
                next_state = IDLE;
            end
        end
    endcase
end

// Counter enable logic
assign counter_en = (state == COUNTING);

// Test packet signals
assign test_tvalid = (state == SEND_TEST);
assign test_tdata = {16{32'h00000001}}; // Test data (all zeros)
assign test_tkeep = 16'hFFFF;           // All bytes valid
assign test_tlast = 1'b1;               // Single beat packet
assign test_tid = 0;

// Mux between normal data and test packet
always_comb begin
    if (state == SEND_TEST) begin
        axis_src_int.tvalid = test_tvalid;
        axis_src_int.tdata = test_tdata;
        axis_src_int.tkeep = test_tkeep;
        axis_src_int.tlast = test_tlast;
        axis_src_int.tid = test_tid;
        axis_sink_int.tready = 1'b0; // Backpressure normal data
    end
end

// Assign cycle_count output
assign cycle_count = captured_count;

// Benchmark slave
logic [1:0] bench_ctrl;
logic [31:0] bench_done;
logic [63:0] bench_timer;
logic [PID_BITS-1:0] bench_pid;
logic [DEST_BITS-1:0] bench_dest;
logic [VADDR_BITS-1:0] bench_vaddr;
logic [LEN_BITS-1:0] bench_len;
logic [31:0] bench_n_reps;
logic [63:0] bench_n_beats;


perf_axi_slv inst_slave (
    .aclk(aclk),
    .aresetn(aresetn),
    .axi_ctrl(axi_ctrl),
    .bench_ctrl(bench_ctrl),
    .bench_done(bench_done),
    .bench_timer(bench_timer),
    .bench_pid(bench_pid),
    .bench_dest(bench_dest),
    .bench_vaddr(bench_vaddr),
    .bench_len(bench_len),
    .bench_n_reps(bench_n_reps),
    .bench_n_beats(bench_n_beats)
);


endmodule