import lynxTypes::*;

`ifdef EN_STRM
perf_local inst_host_link (
    .axis_sink(axis_host_recv[0]),
    .axis_src (axis_host_send[0]),

    .aclk     (aclk),
    .aresetn  (aresetn)
);
`endif

`ifdef EN_MEM
perf_local inst_card_link (
    .axis_sink(axis_card_recv[0]),
    .axis_src (axis_card_send[0]),

    .aclk     (aclk),
    .aresetn  (aresetn)
);
`endif

always_comb axi_ctrl.tie_off_s();
always_comb notify.tie_off_m();
always_comb sq_rd.tie_off_m();
always_comb sq_wr.tie_off_m();
always_comb cq_rd.tie_off_s();
always_comb cq_wr.tie_off_s();
