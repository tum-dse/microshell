`include "conv_constants.v"
// hardcoded parameters - 1-byte color width, 3x3 kernel

`include "conv_constants.v"

module ConvGrid #(
    parameter TRANS_SIZE = 512
) (
    // Clock and reset
    input wire clk,
    input wire rst,
    
    // Inputs
    input wire valid_in,
    input wire [TRANS_SIZE-1:0] image,
    input wire krnl_loaded,
    
    input wire ready_out,
    // Outputs
    output wire valid_out,
    output wire [TRANS_SIZE-1:0] image_out,
    input wire done,
    // Image size, MUST be a multiple of (TRANS_SIZE_B)
    input wire [$clog2(`I_SIZE_MAX)+1:0] vI_SIZE
);
    
    localparam TRANS_SIZE_B = TRANS_SIZE/8;
    localparam FIFO_SIZE = `I_SIZE_MAX / TRANS_SIZE_B - 3;
    localparam MAX_FIFO_DEPTH = (1 << $clog2(FIFO_SIZE + 1)) - 1;
    localparam LIVEZONE_SIZE = 3*TRANS_SIZE_B;
    
    // Control signals and counters
    wire[31:0] vEOF = vI_SIZE*(vI_SIZE/TRANS_SIZE_B);
    wire[31:0] vEOW = (vI_SIZE + 1) * (vI_SIZE/TRANS_SIZE_B) + 1;
    reg [$clog2(`I_SIZE_MAX+10)-1:0] readRow;
    reg [$clog2(`I_SIZE_MAX+10)-1:0] rowsDone;
    reg [31:0] cycles;

    // Live buffer zones
    reg [7:0] top_live [LIVEZONE_SIZE-1:0];
    reg [7:0] mid_live [LIVEZONE_SIZE-1:0];
    reg [7:0] btm_live [LIVEZONE_SIZE-1:0];

    // State tracking
    wire live_next = cycles+1 > ((vI_SIZE/TRANS_SIZE_B) + 1);
    wire momentum_next = cycles+1 >= vEOF;
    wire notPast_next = cycles+1 <= vEOW;

    reg live;
    reg momentum;
    reg notPast;

    // FIFO control signals
    wire stalling = !(ready_out && (valid_in || momentum));
    
    // FIFO write/read control
    reg bmwr, bmrr, mtwr, mtrr;
    wire bmwr_n = (1+cycles >= 3) && (1+cycles < 3 + vEOF);
    wire bmrr_n = (1+cycles >= 3 + FIFO_SIZE) && (1+cycles < 3 + FIFO_SIZE + vEOF);
    wire mtwr_n = (1+cycles >= 6 + FIFO_SIZE) && (1+cycles < 6 + FIFO_SIZE + vEOF);
    wire mtrr_n = (1+cycles >= 6 + 2*FIFO_SIZE) && (1+cycles < 6 + 2*FIFO_SIZE + vEOF) || 
                  (1+cycles < 6 + FIFO_SIZE && !mid_top_empty);

    // FIFO interfaces
    wire btm_mid_wrreq = !stalling && bmwr;
    wire [TRANS_SIZE-1:0] btm_mid_data;
    wire btm_mid_full;
    wire btm_mid_rdreq = !stalling && bmrr;
    wire [TRANS_SIZE-1:0] btm_mid_q;
    wire btm_mid_empty;

    wire mid_top_wrreq = !stalling && mtwr;
    wire [TRANS_SIZE-1:0] mid_top_data;
    wire mid_top_full;
    wire mid_top_rdreq = !stalling && mtrr;
    wire [TRANS_SIZE-1:0] mid_top_q;
    wire mid_top_empty;

    // Map live buffers to FIFO data
    genvar bmg;
    for (bmg = 0; bmg < TRANS_SIZE_B; bmg = bmg + 1) begin: MAP_FIFO_DATA
        assign btm_mid_data[bmg*8+:8] = btm_live[bmg];
        assign mid_top_data[bmg*8+:8] = mid_live[bmg];
    end

    // Main control logic
    always @(posedge clk) begin
        if (rst) begin
            readRow <= 0;
            rowsDone <= 0;
            cycles <= 0;
            live <= 0;
            momentum <= 0;
            notPast <= 1;
            bmwr <= 0;
            bmrr <= 0;
            mtwr <= 0;
            mtrr <= 0;
        end 
        else if (done) begin
            readRow <= 0;
            rowsDone <= 0;
            cycles <= 0;
            live <= 0;
            momentum <= 0;
            notPast <= 1;
            bmwr <= 0;
            bmrr <= 0;
            mtwr <= 0;
            mtrr <= 0;
        end 
        else begin
            if (ready_out && valid_in) begin
                for (integer ii = 0; ii < TRANS_SIZE_B; ii = ii + 1) begin
                    btm_live[(LIVEZONE_SIZE - TRANS_SIZE_B) + ii] <= image[ii*8+:8];
                end
            end
            
            if (!stalling) begin
                cycles <= cycles + 1;
                live <= live_next;
                momentum <= momentum_next;
                notPast <= notPast_next;
                bmwr <= bmwr_n;
                bmrr <= bmrr_n;
                mtwr <= mtwr_n;
                mtrr <= mtrr_n;

                // Shift live buffers
                for (integer jk = 0; jk < LIVEZONE_SIZE - TRANS_SIZE_B; jk = jk + 1) begin
                    btm_live[jk] <= btm_live[jk + TRANS_SIZE_B];
                    mid_live[jk] <= mid_live[jk + TRANS_SIZE_B];
                    top_live[jk] <= top_live[jk + TRANS_SIZE_B];
                end

                // Update from FIFOs
                for (integer mtg = 0; mtg < TRANS_SIZE_B; mtg = mtg + 1) begin
                    mid_live[(LIVEZONE_SIZE - TRANS_SIZE_B) + mtg] <= btm_mid_q[mtg*8+:8];
                    top_live[(LIVEZONE_SIZE - TRANS_SIZE_B) + mtg] <= mid_top_q[mtg*8+:8];
                end

                if (live) begin
                    readRow <= readRow == vI_SIZE-TRANS_SIZE_B ? 0 : readRow + TRANS_SIZE_B;
                    rowsDone <= rowsDone + (readRow == vI_SIZE-TRANS_SIZE_B ? 1 : 0);
                end
            end
        end
    end

    // FIFO overflow protection
    reg fifo_overflow;
    always @(posedge clk) begin
        if (rst) begin
            fifo_overflow <= 1'b0;
        end 
        else if ((btm_mid_wrreq && btm_mid_full) || (mid_top_wrreq && mid_top_full)) begin
            fifo_overflow <= 1'b1;
        end
    end

    wire btm_mid_safe_wrreq = btm_mid_wrreq && !fifo_overflow && !btm_mid_full;
    wire mid_top_safe_wrreq = mid_top_wrreq && !fifo_overflow && !mid_top_full;

    // FIFO instantiations
    HullFIFO #(
        .WIDTH(TRANS_SIZE),
        .LOG_DEPTH($clog2(FIFO_SIZE+1))
    ) btm_mid (
        .clock(clk),
        .reset_n(!rst),
        .wrreq(btm_mid_safe_wrreq),
        .data(btm_mid_data),
        .full(btm_mid_full),
        .rdreq(btm_mid_rdreq),
        .q(btm_mid_q),
        .empty(btm_mid_empty)
    );

    HullFIFO #(
        .WIDTH(TRANS_SIZE),
        .LOG_DEPTH($clog2(FIFO_SIZE+1))
    ) mid_top (
        .clock(clk),
        .reset_n(!rst),
        .wrreq(mid_top_safe_wrreq),
        .data(mid_top_data),
        .full(mid_top_full),
        .rdreq(mid_top_rdreq),
        .q(mid_top_q),
        .empty(mid_top_empty)
    );

    // Convolution processing
    wire goodInput = !stalling && live && notPast;
    wire topIsEdge = rowsDone == 0;
    wire bottomIsEdge = rowsDone == vI_SIZE - 1;
    wire leftIsEdge = readRow == 0;
    wire rightIsEdge = readRow == vI_SIZE-TRANS_SIZE_B;

    // Generate pixel processing instances
    genvar pix;
    generate
        for (pix = 0; pix < TRANS_SIZE_B; pix = pix + 1) begin: PIXELS
            wire myLeftIsEdge = leftIsEdge && pix == 0;
            wire myRightIsEdge = rightIsEdge && pix == TRANS_SIZE_B-1;
            
            // Local pixel window selection
            localparam myReadI = TRANS_SIZE_B + pix;
            localparam topMemAddr = myReadI;
            localparam bottomMemAddr = myReadI;

            wire [8:0] valids;
            assign valids[0] = !(myLeftIsEdge || topIsEdge);
            assign valids[1] = !topIsEdge;
            assign valids[2] = !(myRightIsEdge || topIsEdge);
            assign valids[3] = !myLeftIsEdge;
            assign valids[4] = 1;
            assign valids[5] = !myRightIsEdge;
            assign valids[6] = !(myLeftIsEdge || bottomIsEdge);
            assign valids[7] = !bottomIsEdge;
            assign valids[8] = !(myRightIsEdge || bottomIsEdge);

            // Construct pixel window
            wire [71:0] localPixels_mem;
            assign localPixels_mem[7:0]   = valids[0] ? top_live[topMemAddr-1]    : 0;
            assign localPixels_mem[15:8]  = valids[1] ? top_live[topMemAddr]      : 0;
            assign localPixels_mem[23:16] = valids[2] ? top_live[topMemAddr+1]    : 0;
            assign localPixels_mem[31:24] = valids[3] ? mid_live[myReadI-1]       : 0;
            assign localPixels_mem[39:32] = valids[4] ? mid_live[myReadI]         : 0;
            assign localPixels_mem[47:40] = valids[5] ? mid_live[myReadI+1]       : 0;
            assign localPixels_mem[55:48] = valids[6] ? btm_live[bottomMemAddr-1] : 0;
            assign localPixels_mem[63:56] = valids[7] ? btm_live[bottomMemAddr]   : 0;
            assign localPixels_mem[71:64] = valids[8] ? btm_live[bottomMemAddr+1] : 0;

            // Instantiate ConvPixel from conv_pixel.v
            ConvPixel pixel (
                .clk(clk),
                .rst(rst),
                .localPixels_mem(localPixels_mem),
                .ready_out(ready_out),
                .o_color(image_out[pix*8+:8])
            );
        end
    endgenerate

    // Pipeline valid signal tracking
    reg [`PIPELINE_SIZE-1:0] validP;
    always @(posedge clk) begin
        if (rst) begin
            validP <= 0;
        end 
        else begin
            validP[0] <= goodInput;
            for (integer ppp = 1; ppp < `PIPELINE_SIZE; ppp = ppp + 1) begin
                validP[ppp] <= validP[ppp-1];
            end
        end
    end

    assign valid_out = validP[`PIPELINE_SIZE-1];

endmodule