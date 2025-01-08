`include "conv_constants.v"

// Interface declarations
import lynxTypes::*;
AXI4SR axis_sink_int();
AXI4SR axis_src_int();

reg [2:0] rst_sync;
always_ff @(posedge aclk) begin
    rst_sync <= {rst_sync[1:0], ~aresetn};
end
wire rst_synced = rst_sync[2];

// Internal signal declarations
logic rd_tvalid;
logic rd_tlast;
logic rd_tready;
logic [511:0] rd_tdata;
logic wr_tvalid;
logic wr_tready;
logic wr_tlast;
logic [511:0] wr_tdata;

// Configuration and control signals
logic [15:0] cfg_image_size;
logic cfg_start;
logic cfg_busy;
logic cfg_done;
logic conv_in_ready;
logic conv_out_valid;

// Size tracking
logic [$clog2(`I_SIZE_MAX)+1:0] vI_SIZE;
logic [31:0] vBURSTS_IMG;
logic [31:0] burst_count;

// Stream routing with proper interface connections
axisr_reg inst_reg_sink (.aclk(aclk), .aresetn(aresetn), .s_axis(axis_host_recv[0]), .m_axis(axis_sink_int));
axisr_reg inst_reg_src (.aclk(aclk), .aresetn(aresetn), .s_axis(axis_src_int), .m_axis(axis_host_send[0]));

// Input data stream assignments
assign rd_tdata = axis_sink_int.tdata;
assign rd_tvalid = axis_sink_int.tvalid;
assign rd_tlast = axis_sink_int.tlast;
assign axis_sink_int.tready = conv_in_ready;

reg [511:0] output_buffer;
reg         output_valid;
reg         output_last;

always_ff @(posedge aclk) begin
    if (rst_synced) begin
        output_valid <= 1'b0;
        output_last <= 1'b0;
    end else begin
        if (axis_src_int.tready && output_valid) begin
            output_valid <= 1'b0;
        end else if (wr_tvalid && !output_valid) begin
            output_buffer <= wr_tdata;
            output_valid <= 1'b1;
            output_last <= wr_tlast;
        end
    end
end

assign axis_src_int.tdata = output_buffer;
assign axis_src_int.tkeep = 64'hffffffffffffffff;
assign axis_src_int.tid = '0;
assign axis_src_int.tvalid = output_valid;
assign axis_src_int.tlast = output_last && output_valid;
assign wr_tready = !output_valid || axis_src_int.tready;

// Image size calculation and configuration
always_ff @(posedge aclk) begin
    if (rst_synced) begin
        cfg_image_size <= '0;
        cfg_start <= '0;
        vI_SIZE <= '0;
        vBURSTS_IMG <= '0;
    end
    else if (cfg_start && !cfg_busy) begin
        vI_SIZE <= cfg_image_size;
        vBURSTS_IMG <= (cfg_image_size * cfg_image_size * 8) / 512;
        cfg_start <= 1'b0;  // Auto-clear start bit
    end
end

// Convolution core instantiation
conv_top conv_inst (
    .clk(aclk),
    .rst(rst_synced),
    
    // Configuration interface
    .cfg_image_size(cfg_image_size),
    .cfg_start(cfg_start),
    .cfg_busy(cfg_busy),
    .cfg_done(cfg_done),
    
    // Stream input interface
    .s_axis_tdata(rd_tdata),
    .s_axis_tvalid(rd_tvalid),
    .s_axis_tready(conv_in_ready),
    .s_axis_tlast(rd_tlast),
    
    // Stream output interface
    .m_axis_tdata(wr_tdata),
    .m_axis_tvalid(wr_tvalid),
    .m_axis_tready(wr_tready),
    .m_axis_tlast(wr_tlast)
);
    
// Burst counter
always_ff @(posedge aclk) begin
    if (rst_synced) begin
        burst_count <= '0;
    end 
    else if (wr_tvalid && wr_tready) begin
        if (burst_count == vBURSTS_IMG - 1)
            burst_count <= '0;
        else
            burst_count <= burst_count + 1;
    end
end

// Tie-off unused interfaces
always_comb axi_ctrl.tie_off_s();
always_comb notify.tie_off_m();
always_comb sq_rd.tie_off_m();
always_comb sq_wr.tie_off_m();
always_comb cq_rd.tie_off_s();
always_comb cq_wr.tie_off_s();
