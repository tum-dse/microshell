// audio_processing vFPGA top.
//
//   axis_host_recv -> [FFT] -> [quantizer] -> [RLE] -> axis_host_send
//
// Streaming-only; memory and queue interfaces are tied off.

import lynxTypes::*;

AXI4SR axis_sink_int ();
AXI4SR axis_src_int ();
AXI4SR fft_to_quant ();
AXI4SR quant_to_rle ();

// Skid registers between shell streams and the kernel pipeline.
axisr_reg inst_reg_sink (.aclk(aclk), .aresetn(aresetn), .s_axis(axis_host_recv[0]), .m_axis(axis_sink_int));
axisr_reg inst_reg_src  (.aclk(aclk), .aresetn(aresetn), .s_axis(axis_src_int),     .m_axis(axis_host_send[0]));

fft_top inst_fft (
    .axis_sink(axis_sink_int),
    .axis_src (fft_to_quant),
    .aclk     (aclk),
    .aresetn  (aresetn)
);

quant_top inst_quantizer (
    .axis_sink(fft_to_quant),
    .axis_src (quant_to_rle),
    .aclk     (aclk),
    .aresetn  (aresetn)
);

rle_top inst_rle (
    .axis_sink(quant_to_rle),
    .axis_src (axis_src_int),
    .aclk     (aclk),
    .aresetn  (aresetn)
);

always_comb axi_ctrl.tie_off_s();
always_comb notify.tie_off_m();
always_comb sq_rd.tie_off_m();
always_comb sq_wr.tie_off_m();
always_comb cq_rd.tie_off_s();
always_comb cq_wr.tie_off_s();
