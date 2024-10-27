// Interface declarations
import lynxTypes::*;

// Internal interface declarations
AXI4SR axis_sink_int ();
AXI4SR axis_src_int ();

// Stream routing with proper interface connections
`ifdef EN_STRM
    `ifdef EN_MEM
        axisr_reg_slice inst_reg_slice_sink (
            .aclk(aclk),
            .aresetn(aresetn),
            .s_axis_tvalid(axis_host_recv[0].tvalid),
            .s_axis_tready(axis_host_recv[0].tready),
            .s_axis_tdata(axis_host_recv[0].tdata),
            .s_axis_tlast(axis_host_recv[0].tlast),
            .s_axis_tkeep(axis_host_recv[0].tkeep),
            .s_axis_tid(axis_host_recv[0].tid),
            .m_axis_tvalid(axis_sink_int.tvalid),
            .m_axis_tready(axis_sink_int.tready),
            .m_axis_tdata(axis_sink_int.tdata),
            .m_axis_tlast(axis_sink_int.tlast),
            .m_axis_tkeep(axis_sink_int.tkeep),
            .m_axis_tid(axis_sink_int.tid)
        );

        axisr_reg_slice inst_reg_slice_src (
            .aclk(aclk),
            .aresetn(aresetn),
            .s_axis_tvalid(axis_src_int.tvalid),
            .s_axis_tready(axis_src_int.tready),
            .s_axis_tdata(axis_src_int.tdata),
            .s_axis_tlast(axis_src_int.tlast),
            .s_axis_tkeep(axis_src_int.tkeep),
            .s_axis_tid(axis_src_int.tid),
            .m_axis_tvalid(axis_host_send[0].tvalid),
            .m_axis_tready(axis_host_send[0].tready),
            .m_axis_tdata(axis_host_send[0].tdata),
            .m_axis_tlast(axis_host_send[0].tlast),
            .m_axis_tkeep(axis_host_send[0].tkeep),
            .m_axis_tid(axis_host_send[0].tid)
        );
    `endif
`endif

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

