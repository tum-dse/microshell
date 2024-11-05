/**
 * VFPGA Top Module
 * 
 */
import lynxTypes::*;
       
    logic        fft_tvalid;
    logic        fft_tready;
    logic [31:0] fft_tdata;
    logic        fft_tlast;
    logic [3:0]  fft_tkeep;
    logic [15:0] fft_tid;

    logic        fft2svm_tvalid;
    logic        fft2svm_tready;
    logic [31:0] fft2svm_tdata;
    logic        fft2svm_tlast;
    logic [3:0]  fft2svm_tkeep;
    logic [15:0] fft2svm_tid;

    logic        svm_in_tvalid;
    logic        svm_in_tready;
    logic [31:0] svm_in_tdata;
    logic        svm_in_tlast;
    logic [3:0]  svm_in_tkeep;
    logic [15:0] svm_in_tid;

    logic        svm_out_tvalid;
    logic        svm_out_tready;
    logic [31:0] svm_out_tdata;
    logic        svm_out_tlast;
    logic [3:0]  svm_out_tkeep;
    logic [15:0] svm_out_tid;
     
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
    
    // Clock and reset signals
    logic clk_100M;
    logic clk_10M;
    logic clk_locked;
    logic rst_n_100M;
    logic rst_n_10M;
    
    // Add constant signals for FFT
    logic [15:0] xlconstant_0_dout;
    logic        xlconstant_1_dout;

    assign xlconstant_0_dout = 16'h1;
    assign xlconstant_1_dout = 1'b1;
    assign axis_src_int.tkeep = '1;
    assign axis_sink_int.tkeep = '1;
    assign axis_src_int_tid = '0;
    assign axis_sink_int_tid = '0; 
    
    always_comb begin
        fft_tkeep = '1;
        fft2svm_tkeep = '1;
        svm_in_tkeep = '1;
        svm_out_tkeep = '1;
        axis_host_recv_tkeep = '1;
        axis_host_send_tkeep = '1;

        fft_tid = '0;
        fft2svm_tid = '0;
        svm_in_tid = '0;
        svm_out_tid = '0;
        axis_host_recv_tid = '0;
        axis_host_send_tid = '0;
    end	
        
    // Clock wizard instance
    clk_wiz_0 inst_user_clk_wiz (
        .clk_in1          (aclk),              
        .reset           (!aresetn),           
        .clk_out1        (clk_100M),
        .clk_out2        (clk_10M),
        .locked          (clk_locked)
    );
    
    // Reset modules
    proc_sys_reset_1 inst_rst_100M (
        .slowest_sync_clk (clk_100M),
        .ext_reset_in     (!aresetn),
        .aux_reset_in     (1'b1),
        .mb_debug_sys_rst (1'b0),
        .dcm_locked       (clk_locked),
        .mb_reset            (),            
        .bus_struct_reset    (),
        .peripheral_reset    (),
        .interconnect_aresetn(),
        .peripheral_aresetn(rst_n_100M)
    );

    proc_sys_reset_0 inst_rst_10M (
        .slowest_sync_clk (clk_10M),
        .ext_reset_in     (!aresetn),
        .aux_reset_in     (1'b1),
        .mb_debug_sys_rst (1'b0),
        .dcm_locked       (clk_locked),
        .mb_reset            (),            
        .bus_struct_reset    (),
        .peripheral_reset    (),
        .interconnect_aresetn(),
        .peripheral_aresetn(rst_n_10M)
    );
    
    // I/O 
    dwidth_converter_512_32 inst_dwidth_recv (
		.aclk(clk_100M),
		.aresetn(rst_n_100M),
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
        
    // SVM IP
    svm_speech_30_0 inst_svm (  
    .ap_clk                (clk_10M),
    .ap_rst_n              (rst_n_10M),
    .s_axis_input_TDATA         (svm_in_tdata),
    .s_axis_input_TVALID        (svm_in_tvalid),
    .s_axis_input_TREADY        (svm_in_tready),
    .s_axis_input_TLAST         (svm_in_tlast),
    .m_axis_output_TDATA        (svm_out_tdata),
    .m_axis_output_TVALID       (svm_out_tvalid),
    .m_axis_output_TREADY       (svm_out_tready),
    .m_axis_output_TLAST        (svm_out_tlast)
    );

    // FFT instance (100MHz)
    xfft_0 inst_xfft (
    .aclk                      (clk_100M),
    .aresetn                   (rst_n_100M),
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
    .s_axis_config_tready      (),                      
    .event_frame_started       (),                      
    .event_tlast_unexpected    (),                      
    .event_tlast_missing       (),                      
    .event_status_channel_halt (),                     
    .event_data_in_channel_halt(),                      
    .event_data_out_channel_halt()                      
    );

    // FFT2SVM instance (100MHz)
    fft2svm_0 inst_fft2svm (
    .ap_clk             (clk_100M),
    .ap_rst_n           (rst_n_100M),
    .s_axis_fft_TDATA   (fft_tdata),
    .s_axis_fft_TVALID  (fft_tvalid),
    .s_axis_fft_TREADY  (fft_tready),
    .s_axis_fft_TKEEP   (fft_tkeep),
    .s_axis_fft_TSTRB   ('1),        
    .s_axis_fft_TLAST   (fft_tlast),
    .m_axis_svm_TDATA   (fft2svm_tdata),
    .m_axis_svm_TVALID  (fft2svm_tvalid),
    .m_axis_svm_TREADY  (fft2svm_tready),
    .m_axis_svm_TKEEP   (fft2svm_tkeep),
    .m_axis_svm_TSTRB   (),           
    .m_axis_svm_TLAST   (fft2svm_tlast)
    );

    // Clock Converter FFT2SVM -> SVM (100MHz -> 10MHz)
    axis_clock_converter_1 inst_cc_1 (
        .s_axis_aclk     (clk_100M),
        .s_axis_aresetn  (rst_n_100M),
        .s_axis_tdata    (fft2svm_tdata),
        .s_axis_tvalid   (fft2svm_tvalid),
        .s_axis_tready   (fft2svm_tready),
        .s_axis_tlast    (fft2svm_tlast),
        .m_axis_aclk     (clk_10M),
        .m_axis_aresetn  (rst_n_10M),
        .m_axis_tdata    (svm_in_tdata),
        .m_axis_tvalid   (svm_in_tvalid),
        .m_axis_tready   (svm_in_tready),
        .m_axis_tlast    (svm_in_tlast)
    );

    // Clock Converter SVM -> DWidth Converter (10MHz -> 100MHz)
    axis_clock_converter_0 inst_cc_0 (
        .s_axis_aclk     (clk_10M),
        .s_axis_aresetn  (rst_n_10M),
        .s_axis_tdata    (svm_out_tdata),
        .s_axis_tvalid   (svm_out_tvalid),
        .s_axis_tready   (svm_out_tready),
        .s_axis_tlast    (svm_out_tlast),
        .m_axis_aclk     (clk_100M),
        .m_axis_aresetn  (rst_n_100M),
        .m_axis_tdata    (axis_host_send_tdata),    
        .m_axis_tvalid   (axis_host_send_tvalid),
        .m_axis_tready   (axis_host_send_tready),
        .m_axis_tlast    (axis_host_send_tlast)
    );
    
    
    // Tie off unused interfaces
    always_comb begin
    notify.tie_off_m();
    sq_rd.tie_off_m();
    sq_wr.tie_off_m();
    cq_rd.tie_off_s();
    cq_wr.tie_off_s();
    end
   
    // DBG
    ila_0 inst_ila_0 (
      .clk            (aclk),
      .probe0         (axis_host_recv_tvalid),    // Internal host input valid
      .probe1         (axis_host_recv_tready),    // Internal host input ready
      .probe2         (axis_host_recv_tdata),     // Internal host input data
      .probe3         (axis_host_recv_tlast),     // Internal host input last
      .probe4         (fft_tvalid),                  // FFT output valid
      .probe5         (fft_tready),                  // FFT output ready
      .probe6         (fft_tdata),                   // FFT output data
      .probe7         (fft_tlast),                   // FFT output last
      .probe8         (fft2svm_tvalid),              // FFT2SVM output valid
      .probe9         (fft2svm_tready),              // FFT2SVM output ready
      .probe10        (fft2svm_tdata),               // FFT2SVM output data
      .probe11        (fft2svm_tlast),               // FFT2SVM output last
      .probe12        (svm_in_tvalid),               // SVM input valid
      .probe13        (svm_in_tready),               // SVM input ready
      .probe14        (svm_in_tdata),                // SVM input data
      .probe15        (svm_in_tlast),                // SVM input last
      .probe16        (svm_out_tvalid),              // SVM output valid
      .probe17        (svm_out_tready),              // SVM output ready
      .probe18        (svm_out_tdata),               // SVM output data
      .probe19        (svm_out_tlast),               // SVM output last
      .probe20        (axis_host_send_tvalid),    // Internal host output valid
      .probe21        (axis_host_send_tready),    // Internal host output ready
      .probe22        (axis_host_send_tdata),     // Internal host output data
      .probe23        (axis_host_send_tlast),     // Internal host output last
      .probe24        (clk_locked),                  // Clock wizard locked
      .probe25        (rst_n_100M),                  // 100MHz reset
      .probe26        (rst_n_10M)                    // 10MHz reset
    );

