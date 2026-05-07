// FFT pipeline stage.
//   [512b in] -> dwidth_512_64 -> xfft_0 -> dwidth_64_512 -> [512b out]
//
// xfft_0 emits TLAST per FFT frame; downstream stages want TLAST only at
// host-packet boundaries. The always_ff below latches the host TLAST and
// gates the FFT's per-frame TLAST so a single end-of-packet marker is
// forwarded after the final FFT frame.

module fft_top (
    AXI4SR.s axis_sink,
    AXI4SR.m axis_src,
    input logic aclk,
    input logic aresetn
);

// 64-bit AXIS between the width converters and the FFT IP.
logic        axis_host_recv_tvalid;
logic        axis_host_recv_tready;
logic [63:0] axis_host_recv_tdata;
logic [3:0]  axis_host_recv_tkeep;
logic [15:0] axis_host_recv_tid;
logic        axis_host_recv_tlast;
logic        axis_host_send_tvalid;
logic        axis_host_send_tready;
logic [63:0] axis_host_send_tdata;
logic [3:0]  axis_host_send_tkeep;
logic [15:0] axis_host_send_tid;
logic        axis_host_send_tlast;

// xfft_0 config: forward FFT, valid stays high.
logic [7:0] xlconstant_0_dout;
logic       xlconstant_1_dout;

logic host_tlast_captured;
logic final_output_tlast;

assign xlconstant_0_dout = 8'h1;
assign xlconstant_1_dout = 1'b1;

always_comb begin
    axis_host_recv_tkeep = 1;
    axis_host_send_tkeep = 1;
    axis_host_recv_tid = 0;
    axis_host_send_tid = 0;
end

// Hold host TLAST until the FFT emits its final beat, so downstream sees a
// single end-of-frame marker per host packet.
always_ff @(posedge aclk) begin
    if (!aresetn) begin
        host_tlast_captured <= 0;
    end else begin
        if (axis_host_recv_tvalid && axis_host_recv_tready && axis_host_recv_tlast) begin
            host_tlast_captured <= 1;
        end
        if (axis_host_send_tvalid && axis_host_send_tready && final_output_tlast) begin
            host_tlast_captured <= 0;
        end
    end
end

assign final_output_tlast = host_tlast_captured && axis_host_send_tlast;

dwidth_converter_512_64 inst_dwidth_recv (
    .aclk(aclk),
    .aresetn(aresetn),
    .s_axis_tvalid(axis_sink.tvalid),
    .s_axis_tready(axis_sink.tready),
    .s_axis_tdata(axis_sink.tdata),
    .s_axis_tlast(axis_sink.tlast),
    .s_axis_tid(axis_sink.tid),
    .m_axis_tvalid(axis_host_recv_tvalid),
    .m_axis_tready(axis_host_recv_tready),
    .m_axis_tdata(axis_host_recv_tdata),
    .m_axis_tlast(axis_host_recv_tlast),
    .m_axis_tid(axis_host_recv_tid)
);

xfft_0 inst_xfft (
    .aclk(aclk),
    .aresetn(aresetn),
    .s_axis_data_tdata(axis_host_recv_tdata),
    .s_axis_data_tvalid(axis_host_recv_tvalid),
    .s_axis_data_tready(axis_host_recv_tready),
    .s_axis_data_tlast(axis_host_recv_tlast),
    .m_axis_data_tdata(axis_host_send_tdata),
    .m_axis_data_tvalid(axis_host_send_tvalid),
    .m_axis_data_tready(axis_host_send_tready),
    .m_axis_data_tlast(axis_host_send_tlast),
    .s_axis_config_tdata(xlconstant_0_dout),
    .s_axis_config_tvalid(xlconstant_1_dout),
    .s_axis_config_tready()
);

// Driven with final_output_tlast (gated above), not the FFT IP's tlast.
dwidth_converter_64_512 inst_dwidth_send (
    .aclk(aclk),
    .aresetn(aresetn),
    .s_axis_tvalid(axis_host_send_tvalid),
    .s_axis_tready(axis_host_send_tready),
    .s_axis_tdata(axis_host_send_tdata),
    .s_axis_tlast(final_output_tlast),
    .s_axis_tid(axis_host_send_tid),
    .m_axis_tvalid(axis_src.tvalid),
    .m_axis_tready(axis_src.tready),
    .m_axis_tdata(axis_src.tdata),
    .m_axis_tlast(axis_src.tlast),
    .m_axis_tid(axis_src.tid)
);

endmodule
