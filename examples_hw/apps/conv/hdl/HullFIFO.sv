/*
    This module abstracts the different types of FIFOs that can be used in the system
    Type Xilinx Auto FIFO
*/

module HullFIFO #(parameter WIDTH = 32, LOG_DEPTH = 2)
(
    // General signals
    input  clock,
    input  reset_n,
    // Data in and write enable
    input             wrreq, //enq
    input[WIDTH-1:0]  data,// data in
    output            full,
    output[WIDTH-1:0] q, // data out
    output logic      empty,
    input             rdreq // deq
);

	wire half_full;
	wire data_valid;

	wire xaf_empty;
	wire xaf_full;
	wire xaf_rd_rst_busy;
	wire xaf_wr_rst_busy;
	wire xaf_rd_en;
	wire xaf_wr_en;
	
	xpm_fifo_sync #(
		.DOUT_RESET_VALUE("0"),
		.ECC_MODE("no_ecc"),
		.FIFO_MEMORY_TYPE("auto"),
		.FIFO_READ_LATENCY(0),
		.FIFO_WRITE_DEPTH(1 << LOG_DEPTH),
		.FULL_RESET_VALUE(1),
		.READ_DATA_WIDTH(WIDTH),
		.READ_MODE("fwft"),
		.USE_ADV_FEATURES("0000"),
		.WAKEUP_TIME(0),
		.WRITE_DATA_WIDTH(WIDTH)
	) xpm_auto_fifo (
		.dout(q),
		.empty(xaf_empty),
		.full(xaf_full),
		.rd_rst_busy(xaf_rd_rst_busy),
		.wr_rst_busy(xaf_wr_rst_busy),
		.din(data),
		.rd_en(xaf_rd_en),
		.rst(~reset_n),
		.wr_clk(clock),
		.wr_en(xaf_wr_en)
	);
	
	assign empty = xaf_rd_rst_busy || xaf_wr_rst_busy || xaf_empty;
	assign full  = xaf_rd_rst_busy || xaf_wr_rst_busy || xaf_full;
	assign xaf_rd_en = reset_n && !xaf_rd_rst_busy && !xaf_wr_rst_busy && rdreq;
	assign xaf_wr_en = reset_n && !xaf_rd_rst_busy && !xaf_wr_rst_busy && wrreq;

endmodule
