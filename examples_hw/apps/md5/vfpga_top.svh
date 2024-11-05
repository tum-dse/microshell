// Interface declarations
import lynxTypes::*;

AXI4SR axis_sink_int ();
AXI4SR axis_src_int ();
	
// Stream routing with proper interface connections
axisr_reg inst_reg_sink (.aclk(aclk),.aresetn(aresetn),.s_axis(axis_host_recv[0]),.m_axis(axis_sink_int));
axisr_reg inst_reg_src (.aclk(aclk),.aresetn(aresetn),.s_axis(axis_src_int),.m_axis(axis_host_send[0]));

// Data stream signals
logic rd_tvalid;
logic rd_tlast;
logic rd_tready;
logic [511:0] rd_tdata;
logic wr_tvalid;
logic wr_tready;
logic wr_tlast;
logic [511:0] wr_tdata;

// Input data stream assignments
assign rd_tdata = axis_sink_int.tdata;
assign rd_tvalid = axis_sink_int.tvalid;
assign rd_tlast = axis_sink_int.tlast;

// Output data assignments with explicit connections
assign axis_src_int.tdata = wr_tdata;
assign axis_src_int.tkeep = 64'hffffffffffffffff;
assign axis_src_int.tid = '0;
assign axis_src_int.tvalid = wr_tvalid;
assign axis_src_int.tlast = wr_tlast;
assign wr_tready = axis_src_int.tready;

// FIFO instance and signals
logic idf_wrreq, idf_full;
logic [511:0] idf_din;
logic idf_rdreq, idf_valid;
logic [511:0] idf_dout;
logic idf_empty;

// FIFO connections
assign idf_wrreq = rd_tvalid && !idf_full;
assign idf_din = rd_tdata;
assign axis_sink_int.tready = !idf_full;

// Input data FIFO
quick_fifo #(
    .FIFO_WIDTH(512),
    .FIFO_DEPTH_BITS(9),
    .FIFO_ALMOSTFULL_THRESHOLD(508)
) indatafifo (
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
always_ff @(posedge aclk) begin
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

// MD5 core instantiation
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

// Tie-off unused
always_comb axi_ctrl.tie_off_s();
always_comb notify.tie_off_m();
always_comb sq_rd.tie_off_m();
always_comb sq_wr.tie_off_m();
always_comb cq_rd.tie_off_s();
always_comb cq_wr.tie_off_s();


