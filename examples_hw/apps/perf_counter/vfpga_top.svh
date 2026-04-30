import lynxTypes::*;

`ifdef EN_STRM
perf_counter inst_host_link (
    .axis_sink       (axis_host_recv[0]),
    .axis_src        (axis_host_send[0]),
    .last_idle_cycles(user_data),

    .aclk            (aclk),
    .aresetn         (aresetn)
);

ila_perf_host inst_ila_perf_host_c1 (
    .clk(aclk),
    .probe0(axis_host_recv[0].tvalid),
    .probe1(axis_host_recv[0].tready),
    .probe2(axis_host_recv[0].tlast),
    .probe3(axis_host_send[0].tvalid),
    .probe4(axis_host_send[0].tready),
    .probe5(axis_host_send[0].tlast)
);

`endif

`ifdef EN_MEM
perf_counter inst_card_link (
    .axis_sink(axis_card_recv[0]),
    .axis_src (axis_card_send[0]),

    .aclk     (aclk),
    .aresetn  (aresetn)
);

ila_perf_host inst_ila_perf_card_c1 (
    .clk(aclk),
    .probe0(axis_card_recv[0].tvalid),
    .probe1(axis_card_recv[0].tready),
    .probe2(axis_card_recv[0].tlast),
    .probe3(axis_card_send[0].tvalid),
    .probe4(axis_card_send[0].tready),
    .probe5(axis_card_send[0].tlast)
);
`endif

always_comb axi_ctrl.tie_off_s();
always_comb notify.tie_off_m();
always_comb sq_rd.tie_off_m();
always_comb sq_wr.tie_off_m();
always_comb cq_rd.tie_off_s();
always_comb cq_wr.tie_off_s();
