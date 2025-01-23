/**
 * VFPGA Top Module
 */
import lynxTypes::*;
    
    logic        axis_sink_tvalid;
    logic        axis_sink_tready;
    logic [511:0] axis_sink_tdata;  
    logic        axis_sink_tlast;
    logic        axis_sink_tkeep;
    
    logic        axis_src_tvalid;
    logic        axis_src_tready;
    logic [511:0] axis_src_tdata;
    logic        axis_src_tlast;
    logic        axis_src_tkeep;
    
    // Parameters
    //parameter rows_in = 1080;             // Input image height (rows)
    //parameter cols_in = 1920;             // Input image width (columns)
    //parameter rows_out = 720;             // Output image height (fixed size)
    //parameter cols_out = 720;            // Output image width (fixed size)
    
    // Internal AXI-Stream interfaces
    AXI4SR axis_sink_int ();
    AXI4SR axis_src_int ();
    
    // Stream routing with proper interface connections
    axisr_reg inst_reg_sink (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis(axis_host_recv[0]),
        .m_axis(axis_sink_int)
    );
    
    axisr_reg inst_reg_src (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis(axis_src_int),
        .m_axis(axis_host_send[0])
    );
            
    // Static assignments
    always_comb begin
        axis_sink_int.tkeep = '1;
        axis_src_int.tkeep = '1;
        axis_sink_int.tid = '0;
        axis_src_int.tid = '0;
    end
    
        // Convert interface to signals
    assign axis_sink_tvalid = axis_sink_int.tvalid;
    assign axis_sink_int.tready = axis_sink_tready;
    assign axis_sink_tdata = axis_sink_int.tdata;
    assign axis_sink_tlast = axis_sink_int.tlast;
    
    assign axis_src_int.tvalid = axis_src_tvalid;
    assign axis_src_tready = axis_src_int.tready;
    assign axis_src_int.tdata = axis_src_tdata;
    assign axis_src_int.tlast = axis_src_tlast;

    // Letterbox instance with streaming interfaces
    letterbox_accel inst_letterbox_accel (
        .ap_clk(aclk),
        .ap_rst_n(aresetn),
        
        // AXI-Lite Control Interface
        .s_axi_control_AWVALID(axi_ctrl.awvalid),
        .s_axi_control_AWREADY(axi_ctrl.awready),
        .s_axi_control_AWADDR(axi_ctrl.awaddr),
        .s_axi_control_WVALID(axi_ctrl.wvalid),
        .s_axi_control_WREADY(axi_ctrl.wready),
        .s_axi_control_WDATA(axi_ctrl.wdata),
        .s_axi_control_WSTRB(axi_ctrl.wstrb),
        .s_axi_control_ARVALID(axi_ctrl.arvalid),
        .s_axi_control_ARREADY(axi_ctrl.arready),
        .s_axi_control_ARADDR(axi_ctrl.araddr),
        .s_axi_control_RVALID(axi_ctrl.rvalid),
        .s_axi_control_RREADY(axi_ctrl.rready),
        .s_axi_control_RDATA(axi_ctrl.rdata),
        .s_axi_control_RRESP(axi_ctrl.rresp),
        .s_axi_control_BVALID(axi_ctrl.bvalid),
        .s_axi_control_BREADY(axi_ctrl.bready),
        .s_axi_control_BRESP(axi_ctrl.bresp),

        // Streaming interfaces
        .img_inp_TVALID(axis_sink_tvalid),
        .img_inp_TREADY(axis_sink_tready),
        .img_inp_TDATA(axis_sink_tdata),
        .img_inp_TLAST(axis_sink_tlast),
        
        .img_out_TVALID(axis_src_tvalid),
        .img_out_TREADY(axis_src_tready),
        .img_out_TDATA(axis_src_tdata),
        .img_out_TLAST(axis_src_tlast)
    );
        
    // Tie off unused interfaces
    always_comb begin
        //axi_ctrl.tie_off_s();
        notify.tie_off_m();
        sq_rd.tie_off_m();
        sq_wr.tie_off_m();
        cq_rd.tie_off_s();
        cq_wr.tie_off_s();
    end
