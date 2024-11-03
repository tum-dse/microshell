import lynxTypes::*;

module stream_adder (
    input  logic        aclk,
    input  logic        aresetn,
    AXI4SR.s            axis_sink,
    AXI4SR.m           axis_src
);

logic [31:0] tmp_sum;

always_comb begin
    axis_src.tvalid = axis_sink.tvalid;
    axis_src.tkeep  = axis_sink.tkeep;
    axis_src.tid    = axis_sink.tid;
    axis_src.tlast  = axis_sink.tlast;

    axis_sink.tready = axis_src.tready;
    axis_src.tdata = axis_sink.tdata + 1;
end
    
endmodule