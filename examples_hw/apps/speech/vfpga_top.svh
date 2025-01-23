/**
 * VFPGA Top Module
 * 
 */
import lynxTypes::*;
       
    logic        fft_tvalid;
    logic        fft_tready;
    logic [63:0] fft_tdata;
    logic        fft_tlast;
    logic [3:0]  fft_tkeep;
    logic [15:0] fft_tid;

    logic        svm_tvalid;
    logic        svm_tready;
    logic [31:0] svm_tdata;
    logic        svm_tlast;
    logic [3:0]  svm_tkeep;
    logic [15:0] svm_tid;
     
    logic        axis_host_recv_tvalid;
    logic        axis_host_recv_tready;
    logic [31:0] axis_host_recv_tdata;
    logic [3:0]  axis_host_recv_tkeep;
    logic [15:0] axis_host_recv_tid;
    logic        axis_host_recv_tlast;
    
    logic        axis_host_send_tvalid;
    logic        axis_host_send_tready;
    logic [31:0] axis_host_send_tdata;
    logic [3:0]  axis_host_send_tkeep;
    logic [15:0] axis_host_send_tid;
    logic        axis_host_send_tlast;
        
    AXI4SR axis_sink_int ();
    AXI4SR axis_src_int ();
	
    // Stream routing with proper interface connections
    axisr_reg inst_reg_sink (.aclk(aclk),.aresetn(aresetn),.s_axis(axis_host_recv[0]),.m_axis(axis_sink_int));
    axisr_reg inst_reg_src (.aclk(aclk),.aresetn(aresetn),.s_axis(axis_src_int),.m_axis(axis_host_send[0]));
   
    // Add constant signals for FFT
    logic [15:0] xlconstant_0_dout;
    logic        xlconstant_1_dout;

    assign xlconstant_0_dout = 16'h1;
    assign xlconstant_1_dout = 1'b1;
    
    always_comb begin
        fft_tkeep = 1;
        svm_tkeep = 1;
        axis_host_recv_tkeep = 1;
        axis_host_send_tkeep = 1;

        fft_tid = 0;
        svm_tid = 0;
        axis_host_recv_tid = 0;
        axis_host_send_tid = 0;
    end	
            
    // I/O 
    dwidth_converter_512_32 inst_dwidth_recv (
    .aclk(aclk),
    .aresetn(aresetn),
    .s_axis_tvalid(axis_sink_int.tvalid),
    .s_axis_tready(axis_sink_int.tready),
    .s_axis_tdata (axis_sink_int.tdata),
    .s_axis_tlast (axis_sink_int.tlast),
    .s_axis_tid   (axis_sink_int.tid),  
    .m_axis_tvalid(axis_host_recv_tvalid),
    .m_axis_tready(axis_host_recv_tready),
    .m_axis_tdata (axis_host_recv_tdata),
    .m_axis_tlast (axis_host_recv_tlast),
    .m_axis_tid   (axis_host_recv_tid) 
    );
            
    // FFT instance (100MHz)
    xfft_0 inst_xfft (
    .aclk                      (aclk),
    .aresetn                   (aresetn),
    .s_axis_data_tdata         (axis_host_recv_tdata),  
    .s_axis_data_tvalid        (axis_host_recv_tvalid),
    .s_axis_data_tready        (axis_host_recv_tready),
    .s_axis_data_tlast         (axis_host_recv_tlast),
    .m_axis_data_tdata         (fft_tdata),
    .m_axis_data_tvalid        (fft_tvalid),
    .m_axis_data_tready        (fft_tready),
    .m_axis_data_tlast         (fft_tlast),      
    .s_axis_config_tdata       (xlconstant_0_dout),     
    .s_axis_config_tvalid      (xlconstant_1_dout),     
    .s_axis_config_tready      ()                                       
    );

    // FFT2SVM instance (100MHz)
    fft2svm_0 inst_fft2svm (
    .ap_clk             (aclk),
    .ap_rst_n           (aresetn),
    .s_axis_fft_TDATA   (fft_tdata),
    .s_axis_fft_TVALID  (fft_tvalid),
    .s_axis_fft_TREADY  (fft_tready),
    .s_axis_fft_TKEEP   (fft_tkeep),
    .s_axis_fft_TSTRB   (1),        
    .s_axis_fft_TLAST   (fft_tlast),
    .m_axis_svm_TDATA   (svm_tdata),
    .m_axis_svm_TVALID  (svm_tvalid),
    .m_axis_svm_TREADY  (svm_tready),
    .m_axis_svm_TKEEP   (svm_tkeep),
    .m_axis_svm_TSTRB   (),           
    .m_axis_svm_TLAST   (svm_tlast)
    );
    
    // SVM IP
    svm_speech_30_0 inst_svm (
    .ap_clk          (aclk),
    .ap_rst_n        (aresetn),
    .input_r_TDATA   (svm_tdata),
    .input_r_TVALID  (svm_tvalid),
    .input_r_TREADY  (svm_tready),
    .input_r_TLAST   (svm_tlast),
    .output_r_TDATA  (axis_host_send_tdata),
    .output_r_TVALID (axis_host_send_tvalid),
    .output_r_TREADY (axis_host_send_tready),
    .output_r_TLAST  (axis_host_send_tlast)
    );

    dwidth_converter_32_512 inst_dwidth_send (
    .aclk(clk_100M),
    .aresetn(rst_n_100M),
    .s_axis_tvalid(axis_host_send_tvalid),
    .s_axis_tready(axis_host_send_tready),
    .s_axis_tdata (axis_host_send_tdata),
    .s_axis_tlast (axis_host_send_tlast),
    .s_axis_tid   (axis_host_send_tid), 
    .m_axis_tvalid(axis_src_int.tvalid),
    .m_axis_tready(axis_src_int.tready),
    .m_axis_tdata (axis_src_int.tdata),
    .m_axis_tlast (axis_src_int.tlast),
    .m_axis_tid   (axis_src_int.tid) 
    );
    
    // Tie off unused interfaces
    always_comb axi_ctrl.tie_off_s();
    always_comb notify.tie_off_m();
    always_comb sq_rd.tie_off_m();
    always_comb sq_wr.tie_off_m();
    always_comb cq_rd.tie_off_s();
    always_comb cq_wr.tie_off_s();
