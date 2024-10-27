// Interface declarations
import lynxTypes::*;

module md5_top (
    AXI4SR.slave         axis_sink,
    AXI4SR.master        axis_src,
    input  logic         aclk,
    input  logic         aresetn
);

logic rd_tvalid;
logic rd_tlast;
logic rd_tready;
logic [511:0] rd_tdata;
logic wr_tvalid;
logic wr_tready;
logic wr_tlast;
logic [511:0] wr_tdata;

// Internal signals
logic idf_wrreq, idf_full;
logic [511:0] idf_din;
logic idf_rdreq, idf_valid;
logic [511:0] idf_dout;
logic idf_empty;

// Register stage for input stream 
logic [511:0] sink_data_reg;
logic sink_valid_reg;
logic sink_last_reg;

// Input stream registration
always_ff @(posedge aclk) begin
    if (~aresetn) begin
        sink_data_reg <= '0;
        sink_valid_reg <= 1'b0;
        sink_last_reg <= 1'b0;
    end else if (axis_sink.tready) begin
        sink_data_reg <= axis_sink.tdata;
        sink_valid_reg <= axis_sink.tvalid;
        sink_last_reg <= axis_sink.tlast;
    end
end

// Input assignments with registered signals
assign rd_tdata = sink_data_reg;
assign rd_tvalid = sink_valid_reg;
assign rd_tlast = sink_last_reg;
assign axis_sink.tready = !idf_full;

// FIFO connections with explicit timing control
always_comb begin
    idf_wrreq = rd_tvalid && !idf_full;
    idf_din = rd_tdata;
end

// Output stream assignments
assign axis_src.tdata = wr_tdata;
assign axis_src.tkeep = 64'hffffffffffffffff;
assign axis_src.tid = '0;
assign axis_src.tvalid = wr_tvalid;
assign axis_src.tlast = wr_tlast;
assign wr_tready = axis_src.tready;

// FIFO instance
quick_fifo #(
    .FIFO_WIDTH(512),
    .FIFO_DEPTH_BITS(9),
    .FIFO_ALMOSTFULL_THRESHOLD(508)
) InDataFIFO (
    .clk(aclk),
    .reset_n(aresetn),
    .din(idf_din),
    .we(idf_wrreq),
    .re(idf_rdreq),
    .dout(idf_dout),
    .empty(idf_empty),
    .valid(idf_valid),
    .full(idf_full),
    .count(),
    .almostfull()
);

// MD5 core logic
logic [64:0] md5_valid;
logic [63:0] md5_words;
logic md5_in_valid;
logic md5_out_valid;
logic md5_out_valid_prev;
logic md5_done;

logic [31:0] md5_a_reg;
logic [31:0] md5_b_reg;
logic [31:0] md5_c_reg;
logic [31:0] md5_d_reg;

logic [127:0] md5_hash;
logic [31:0] md5_a, md5_b, md5_c, md5_d;

// MD5 signal assignments
assign md5_in_valid = !idf_empty && !md5_done;
assign md5_out_valid = md5_valid[64];
assign md5_out_valid_prev = md5_valid[63];

assign md5_a = md5_hash[31:0];
assign md5_b = md5_hash[63:32];
assign md5_c = md5_hash[95:64];
assign md5_d = md5_hash[127:96];

// Output assignments
assign wr_tdata = {md5_d_reg, md5_c_reg, md5_b_reg, md5_a_reg};
assign wr_tvalid = md5_done && !idf_empty;
assign wr_tlast = md5_done && !idf_empty;
assign idf_rdreq = md5_in_valid && !md5_done;

// MD5 processing logic
always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        md5_valid <= '0;
        md5_a_reg <= 32'h67452301;
        md5_b_reg <= 32'hefcdab89;
        md5_c_reg <= 32'h98badcfe;
        md5_d_reg <= 32'h10325476;
        md5_words <= '0;
        md5_done  <= '0;
    end else begin
        md5_valid <= {md5_valid[63:0], md5_in_valid};
        
        if (md5_out_valid) begin
            md5_a_reg <= md5_a_reg + md5_a;
            md5_b_reg <= md5_b_reg + md5_b;
            md5_c_reg <= md5_c_reg + md5_c;
            md5_d_reg <= md5_d_reg + md5_d;
            md5_words <= md5_words + 1;
            
            if (!md5_out_valid_prev) begin
                md5_done <= 1'b1;
            end
        end
    end
end

// MD5 core 
Md5Core md5_core (
    .clk(aclk),
    .wb(idf_dout),
    .a0(32'h67452301),
    .b0(32'hefcdab89),
    .c0(32'h98badcfe),
    .d0(32'h10325476),
    .a64(md5_a),
    .b64(md5_b),
    .c64(md5_c),
    .d64(md5_d)
);

endmodule
