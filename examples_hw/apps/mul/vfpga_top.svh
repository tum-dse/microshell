/**
* VFPGA Top Module
*/
import lynxTypes::*;
       
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
        
    AXI4SR axis_sink_int ();
    AXI4SR axis_src_int ();
	
    // Stream routing with proper interface connections
    axisr_reg inst_reg_sink (.aclk(aclk),.aresetn(aresetn),.s_axis(axis_host_recv[0]),.m_axis(axis_sink_int));
    axisr_reg inst_reg_src (.aclk(aclk),.aresetn(aresetn),.s_axis(axis_src_int),.m_axis(axis_host_send[0]));
    
    always_comb begin
        axis_host_recv_tkeep = '1;
        axis_host_send_tkeep = '1;
        axis_host_recv_tid = '0;
        axis_host_send_tid = '0;
    end	

    // Input width converter (512->64 bits)
    dwidth_converter_512_64 inst_dwidth_recv (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tvalid(axis_sink_int.tvalid),
        .s_axis_tready(axis_sink_int.tready),
        .s_axis_tdata(axis_sink_int.tdata),
        .s_axis_tlast(axis_sink_int.tlast),
        .s_axis_tid(axis_sink_int.tid),
        .m_axis_tvalid(axis_host_recv_tvalid),
        .m_axis_tready(axis_host_recv_tready),
        .m_axis_tdata(axis_host_recv_tdata),
        .m_axis_tlast(axis_host_recv_tlast),
        .m_axis_tid(axis_host_recv_tid)
    );
   
    // Split input data into real and imaginary parts
    logic [31:0] real_a, imag_a;
    assign real_a = axis_host_recv_tdata[31:0];
    assign imag_a = axis_host_recv_tdata[63:32];

    // Real part multiplication
    fp_mult_real inst_mult_real (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_a_tvalid(axis_host_recv_tvalid),
        .s_axis_a_tdata(real_a),
        .s_axis_b_tvalid(axis_host_recv_tvalid),
        .s_axis_b_tdata(real_a),  
        .m_axis_result_tvalid(axis_host_send_tvalid),
        .m_axis_result_tdata(axis_host_send_tdata[31:0])
    );
    
    logic        axis_imag_send_tvalid;
    assign axis_host_send_tvalid = axis_imag_send_tvalid;
    
    // Imaginary part multiplication
    fp_mult_imag inst_mult_imag (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_a_tvalid(axis_host_recv_tvalid),
        .s_axis_a_tdata(imag_a), 
        .s_axis_b_tvalid(axis_host_recv_tvalid),
        .s_axis_b_tdata(imag_a), 
        .m_axis_result_tvalid(axis_imag_send_tvalid),
        .m_axis_result_tdata(axis_host_send_tdata[63:32])
    );

   // Output width converter (64->512 bits)
   dwidth_converter_64_512 inst_dwidth_send (
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

   // Tie off unused interfaces
   always_comb axi_ctrl.tie_off_s();
   always_comb notify.tie_off_m();
   always_comb sq_rd.tie_off_m();
   always_comb sq_wr.tie_off_m();
   always_comb cq_rd.tie_off_s();
   always_comb cq_wr.tie_off_s();
