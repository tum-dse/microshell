/**
* VFPGA Top Module - Digital Signature Pipeline
*/
import lynxTypes::*;

logic        axis_host_recv_tvalid;
logic        axis_host_recv_tready;
logic [511:0] axis_host_recv_tdata;
logic [31:0]  axis_host_recv_tkeep;
logic [15:0] axis_host_recv_tid;
logic        axis_host_recv_tlast;

logic        axis_host_send_tvalid;
logic        axis_host_send_tready;
logic [255:0] axis_host_send_tdata;
logic [31:0]  axis_host_send_tkeep;
logic [15:0] axis_host_send_tid;
logic        axis_host_send_tlast;

// Interface declarations
AXI4SR axis_sink_int ();
AXI4SR axis_src_int ();

// Host stream routing
axisr_reg inst_reg_sink (.aclk(aclk), .aresetn(aresetn), .s_axis(axis_host_recv[0]), .m_axis(axis_sink_int));
axisr_reg inst_reg_src (.aclk(aclk), .aresetn(aresetn), .s_axis(axis_src_int), .m_axis(axis_host_send[0]));


always_comb begin
    axis_host_recv_tkeep = 1;
    axis_host_send_tkeep = 1;
    axis_host_recv_tid = 0;
    axis_host_send_tid = 0;
end

// Input assignments
assign axis_host_recv_tdata  = axis_sink_int.tdata;
assign axis_host_recv_tvalid = axis_sink_int.tvalid;
assign axis_host_recv_tlast  = axis_sink_int.tlast;
assign axis_sink_int.tready  = axis_host_recv_tready;

/////////////////////// SHA2 Module ///////////////////////

// Signals for SHA2 output
logic [255:0] sha2_out_tdata;
logic [63:0]  sha2_out_tkeep;
logic [7:0]   sha2_out_tid;
logic         sha2_out_tvalid;
logic         sha2_out_tlast;
logic         sha2_out_tready;

// SHA2 instance
sha2 inst_sha2 (
    .aclk(aclk),
    .aresetn(aresetn),
    .axis_sink_tdata(axis_host_recv_tdata),
    .axis_sink_tvalid(axis_host_recv_tvalid),
    .axis_sink_tlast(axis_host_recv_tlast),
    .axis_sink_tready(axis_host_recv_tready),
    .axis_src_tdata(sha2_out_tdata),
    .axis_src_tkeep(sha2_out_tkeep),
    .axis_src_tid(sha2_out_tid),
    .axis_src_tvalid(sha2_out_tvalid),
    .axis_src_tlast(sha2_out_tlast),
    .axis_src_tready(sha2_out_tready)
);

// Use registered signals for connection to RSA
wire        sha_done = sha2_out_tvalid && sha2_out_tlast;
wire [255:0] sha_out = sha2_out_tdata;
assign sha2_out_tready = sha_to_rsa_tready;

/////////////////////// RSA Module ///////////////////////

// State and signals
wire sha_to_rsa_tready;
logic [255:0] rsa_modulus;
logic [19:0] rsa_exponent;

// Default RSA key assignments
assign rsa_modulus = 256'hF4F5E3D2C1B0A9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA98;
assign rsa_exponent = 20'h10001;

// RSA instance
rsa inst_rsa (
    .ap_clk(aclk),
    .ap_rst_n(aresetn),
    // Connect to SHA-256 output
    .message_TVALID(sha_done),
    .message_TREADY(sha_to_rsa_tready),
    .message_TDATA(sha_out),
    .message_TLAST(sha_done),
    // Static inputs
    .modulus(rsa_modulus),
    .exponent(rsa_exponent),
    // Output to width converter
    .result_TVALID(axis_host_send_tvalid),
    .result_TREADY(axis_host_send_tready),
    .result_TDATA(axis_host_send_tdata),
    .result_TLAST(axis_host_send_tlast)
);

// Width converter for final output (256->512)
dwidth_converter_256_512 inst_dwidth_send (
    .aclk(aclk),
    .aresetn(aresetn),
    .s_axis_tvalid(axis_host_send_tvalid),
    .s_axis_tready(axis_host_send_tready),
    .s_axis_tdata(axis_host_send_tdata),
    .s_axis_tlast(axis_host_send_tlast),
    .s_axis_tid(axis_host_send_tid),
    .m_axis_tvalid(axis_src_int.tvalid),
    .m_axis_tready(axis_src_int.tready),
    .m_axis_tdata(axis_src_int.tdata),
    .m_axis_tlast(axis_src_int.tlast),
    .m_axis_tid(axis_src_int.tid)
);


// ============================================================================
// Cycle Counter Integration
// ============================================================================

logic start_signal_sha2, end_signal_sha2;
logic start_signal_rsa, end_signal_rsa;

assign start_signal_sha2 = axis_host_recv[0].tvalid && axis_host_recv[0].tready;
assign end_signal_sha2 = sha_done;

assign start_signal_rsa = sha_done;
assign end_signal_rsa = axis_host_send[0].tvalid && axis_host_send[0].tready;

logic [31:0]                     cycle_count_sha2;
logic [31:0]                     cycle_count_rsa;
logic                            count_valid_sha2;
logic                            count_valid_rsa;

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

assign bench_timer[31:0] = cycle_count_sha2;
assign bench_timer[63:32] = cycle_count_rsa;
assign bench_done = count_valid_rsa;

// Instantiate cycle counter
cycle_counter cycle_counter_sha2 (
    .clk          (aclk),
    .resetn       (aresetn),
    .start        (start_signal_sha2),
    .stop         (end_signal_sha2),
    .cycle_count  (cycle_count_sha2),
    .count_valid  (count_valid_sha2)
);

cycle_counter cycle_counter_rsa (
    .clk          (aclk),
    .resetn       (aresetn),
    .start        (start_signal_rsa),
    .stop         (end_signal_rsa),
    .cycle_count  (cycle_count_rsa),
    .count_valid  (count_valid_rsa)
);

ctrl_slv inst_slave (
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


ila_ctrl_fpga inst_ila_ctrl_fpga (
    .clk(aclk),
    .probe0(bench_ctrl), // 2
    .probe1(bench_done), // 32
    .probe2(bench_timer), // 64
    .probe3(start_signal_sha2), // 1
    .probe4(end_signal_sha2), // 1
    .probe5(start_signal_rsa), // 1
    .probe6(end_signal_rsa), // 1
    .probe7(cycle_count_rsa), // 32
    .probe8(cycle_count_rsa), // 32
    .probe9(count_valid_sha2), // 1
    .probe10(count_valid_rsa) // 1
);

// Tie-off unused
// always_comb axi_ctrl.tie_off_s();
always_comb notify.tie_off_m();
always_comb sq_rd.tie_off_m();
always_comb sq_wr.tie_off_m();
always_comb cq_rd.tie_off_s();
always_comb cq_wr.tie_off_s();