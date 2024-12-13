module ConvPixel #(
    parameter DEBUG = 0
) (
    input wire clk,
    input wire rst,
    input wire [71:0] localPixels_mem,
    input wire ready_out,
    output reg [7:0] o_color
);
    // Pipeline valid tracking
    reg [3:0] pixel_valid;
    reg [71:0] pixels0, pixels;
    wire [71:0] kernel_raw = `IMAGE_KERNEL;
    wire [7:0] krnl_shift = `IMAGE_KERNEL_SHIFT;
    
    // Stage 1: Input registration with valid
    always @(posedge clk) begin
        if (rst) begin
            pixel_valid[0] <= 1'b0;
            pixels0 <= 0;
            pixels <= 0;
        end else begin
            pixel_valid[0] <= ready_out;
            pixels0 <= localPixels_mem;
            pixels <= pixels0;
        end
    end

    // Stage 2: Multiplication
    reg signed [19:0] products[8:0];
    integer i;
    
    always @(posedge clk) begin
        if (rst) begin
            pixel_valid[1] <= 1'b0;
            for(i = 0; i < 9; i = i + 1)
                products[i] <= 0;
        end else begin
            pixel_valid[1] <= pixel_valid[0];
            for(i = 0; i < 9; i = i + 1)
                products[i] <= pixels[i*8 +: 8] * kernel_raw[i*8 +: 8];
        end
    end

    // Stage 3: Accumulation
    reg signed [19:0] sum;
    
    always @(posedge clk) begin
        if (rst) begin
            pixel_valid[2] <= 1'b0;
            sum <= 0;
        end else begin
            pixel_valid[2] <= pixel_valid[1];
            sum <= products[0] + products[1] + products[2] +
                   products[3] + products[4] + products[5] +
                   products[6] + products[7] + products[8];
        end
    end

    // Stage 4: Output with shift and saturation
    always @(posedge clk) begin
        if (rst) begin
            pixel_valid[3] <= 1'b0;
            o_color <= 0;
        end else begin
            pixel_valid[3] <= pixel_valid[2];
            if (pixel_valid[2]) begin
                o_color <= (sum >>> krnl_shift) > 255 ? 255 :
                          (sum >>> krnl_shift) < 0   ? 0   :
                          sum >>> krnl_shift;
            end
        end
    end

endmodule
