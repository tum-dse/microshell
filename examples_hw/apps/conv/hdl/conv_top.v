`include "conv_constants.v"

`define START_CREDS 6

module conv_top (
    input clk,
    input rst,
    
    // Configuration interface
    input [15:0] cfg_image_size,
    input cfg_start,
    output reg cfg_busy,
    output reg cfg_done,
    
    // Stream input interface 
    input [511:0] s_axis_tdata,
    input s_axis_tvalid,
    output reg s_axis_tready,
    input s_axis_tlast,
    
    // Stream output interface
    output reg [511:0] m_axis_tdata,
    output reg m_axis_tvalid, 
    input m_axis_tready,
    output reg m_axis_tlast
);

reg [2:0] rst_sync;
always @(posedge clk) begin
    rst_sync <= {rst_sync[1:0], rst};
end
wire rst_synced = rst_sync[2];

localparam TRANS_SIZE = 512; // bits

// Image size and burst calculation registers
reg [$clog2(`I_SIZE_MAX)+1:0] vI_SIZE;
reg [31:0] vBURSTS_IMG;
reg [31:0] burst_count;
localparam BURSTS_PER_PAGE = 4096 / (TRANS_SIZE / 8);
reg [31:0] vPAGES;
reg [31:0] vLEFTOVER_SIZE_;
reg [31:0] vLEFTOVER_SIZE;

// Configuration and control
reg processing_active;
wire processing_done;

// Size validation and configuration
always @(posedge clk) begin
    if (rst_synced) begin
        vI_SIZE <= 0;
        vBURSTS_IMG <= 0;
        cfg_busy <= 1'b0;
        processing_active <= 1'b0;
    end
    else if (cfg_start && !cfg_busy) begin
        // Validate image size
        if (cfg_image_size <= `I_SIZE_MAX && cfg_image_size > 0 && 
            (cfg_image_size * 8) % (TRANS_SIZE/8) == 0) begin
            
            vI_SIZE <= cfg_image_size;
            vBURSTS_IMG <= (cfg_image_size * cfg_image_size * 8) / TRANS_SIZE;
            cfg_busy <= 1'b1;
            processing_active <= 1'b1;
        end
    end
    else if (processing_done) begin
        cfg_busy <= 1'b0;
        processing_active <= 1'b0;
    end
    
    // Burst calculations
    vPAGES <= (vBURSTS_IMG-1) / BURSTS_PER_PAGE + 1;
    vLEFTOVER_SIZE_ <= vBURSTS_IMG % BURSTS_PER_PAGE;
    vLEFTOVER_SIZE <= (vLEFTOVER_SIZE_ == 0) ? BURSTS_PER_PAGE : vLEFTOVER_SIZE_;
end

// Burst counting
always @(posedge clk) begin
    if (rst_synced || !processing_active) begin
        burst_count <= 0;
    end
    else if (m_axis_tvalid && m_axis_tready) begin
        if (burst_count == vBURSTS_IMG - 1) begin
            burst_count <= 0;
        end
        else begin
            burst_count <= burst_count + 1;
        end
    end
end

// Core processing logic
reg dut_ready_out;
reg [TRANS_SIZE-1:0] input_buffer;
reg input_valid;

// Output buffer signals
wire out_buf_wrreq;
wire [TRANS_SIZE-1:0] out_buf_data;
wire out_buf_full;
wire out_buf_rdreq;
wire [TRANS_SIZE-1:0] out_buf_q;
wire out_buf_empty;

// Output buffer FIFO
HullFIFO #(
    .WIDTH(TRANS_SIZE),
    .LOG_DEPTH($clog2(`PIPELINE_SIZE)+1)
) out_buf (
    .clock(clk),
    .reset_n(!rst_synced),
    .wrreq(out_buf_wrreq),
    .data(out_buf_data),
    .full(out_buf_full),
    .rdreq(out_buf_rdreq),
    .q(out_buf_q),
    .empty(out_buf_empty)
);

// Convolution Grid instance
wire valid_out;
wire [TRANS_SIZE-1:0] image_out;
reg [$clog2(`PIPELINE_SIZE)+1:0] out_buf_size;

ConvGrid #(
    .TRANS_SIZE(TRANS_SIZE)
) dut (
    .clk(clk),
    .rst(rst_synced || !processing_active),
    .valid_in(s_axis_tvalid && processing_active),
    .image(s_axis_tdata),
    .krnl_loaded(cfg_busy),
    .ready_out(dut_ready_out),
    .valid_out(valid_out),
    .image_out(image_out),
    .done(processing_done),
    .vI_SIZE(vI_SIZE)
);

// Output buffer management
assign out_buf_rdreq = m_axis_tready && !out_buf_empty;
assign out_buf_data = image_out;
assign out_buf_wrreq = valid_out;

always @(posedge clk) begin
    if (rst_synced) begin
        dut_ready_out <= 0;
        out_buf_size <= 0;
        cfg_done <= 0;
    end 
    else begin
        if (processing_done) begin
            dut_ready_out <= 0;
            out_buf_size <= 0;
            cfg_done <= 1;
        end 
        else if (processing_active) begin
            dut_ready_out <= m_axis_tready && out_buf_size < 2;
            
            if (out_buf_rdreq && out_buf_wrreq) begin
                // Size stays the same
            end 
            else if (out_buf_rdreq) begin
                out_buf_size <= out_buf_size - 1;
            end 
            else if (out_buf_wrreq) begin
                out_buf_size <= out_buf_size + 1;
            end
            
            cfg_done <= 0;
        end
    end
end

// Output assignments
always @(*) begin
    m_axis_tdata <= out_buf_q;
    m_axis_tvalid <= !out_buf_empty && processing_active;
    s_axis_tready <= dut_ready_out && processing_active;
    m_axis_tlast <= (burst_count == vBURSTS_IMG - 1) && m_axis_tvalid;
end

endmodule
