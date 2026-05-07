// FFT-magnitude quantizer.
//   [FFT 512b] -> dwidth_512_64 -> fft_quantizer -> [512b out]
//
// fft_quantizer emits one ASCII byte per 64-bit complex sample; 64 such
// bytes pack into one 512-bit beat. The 4:1 reduction produces long runs
// the downstream RLE encoder can compress.

module quant_top (
    AXI4SR.s axis_sink,
    AXI4SR.m axis_src,
    input logic aclk,
    input logic aresetn
);

    logic        axis_conv_tvalid;
    logic        axis_conv_tready;
    logic [63:0] axis_conv_tdata;
    logic        axis_conv_tlast;
    logic [15:0] axis_conv_tid;

    dwidth_converter_512_64 inst_dwidth_converter (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tvalid(axis_sink.tvalid),
        .s_axis_tready(axis_sink.tready),
        .s_axis_tdata(axis_sink.tdata),
        .s_axis_tlast(axis_sink.tlast),
        .s_axis_tid(axis_sink.tid),
        .m_axis_tvalid(axis_conv_tvalid),
        .m_axis_tready(axis_conv_tready),
        .m_axis_tdata(axis_conv_tdata),
        .m_axis_tlast(axis_conv_tlast),
        .m_axis_tid(axis_conv_tid)
    );

    fft_quantizer inst_quantizer (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tvalid(axis_conv_tvalid),
        .s_axis_tready(axis_conv_tready),
        .s_axis_tdata(axis_conv_tdata),
        .s_axis_tlast(axis_conv_tlast),
        .m_axis_tvalid(axis_src.tvalid),
        .m_axis_tready(axis_src.tready),
        .m_axis_tdata(axis_src.tdata),
        .m_axis_tlast(axis_src.tlast)
    );

endmodule

// Collects 64 complex FFT samples (32b real + 32b imag), bins each |re|+|im|
// magnitude into one of five ASCII bytes, packs 64 bytes into a 512-bit beat.
// Bin thresholds tuned for speech-like FFT magnitudes.
module fft_quantizer (
    input  logic         aclk,
    input  logic         aresetn,

    input  logic         s_axis_tvalid,
    output logic         s_axis_tready,
    input  logic [63:0]  s_axis_tdata,
    input  logic         s_axis_tlast,

    output logic         m_axis_tvalid,
    input  logic         m_axis_tready,
    output logic [511:0] m_axis_tdata,
    output logic         m_axis_tlast
);

    // IDLE -> COLLECT (pack 64 quantised bytes) -> OUTPUT (emit beat) -> ...
    typedef enum logic [1:0] {
        IDLE,
        COLLECT,
        OUTPUT
    } state_t;

    state_t state, next_state;

    logic [5:0]   sample_count;     // 0..63
    logic [511:0] output_buffer;    // packed LSB-first
    logic         output_tlast;
    logic         saw_tlast;        // latched if any sample in the window had tlast

    // Magnitude approximation = |Re| + |Im|.
    logic [31:0] real_part, imag_part;
    assign real_part = s_axis_tdata[31:0];
    assign imag_part = s_axis_tdata[63:32];

    logic [31:0] real_abs, imag_abs, magnitude_approx;
    assign real_abs = real_part[31] ? (~real_part + 1) : real_part;
    assign imag_abs = imag_part[31] ? (~imag_part + 1) : imag_part;
    assign magnitude_approx = real_abs + imag_abs;

    // 'A'=quiet, 'P'=peak.
    logic [7:0] quantized_byte;
    always_comb begin
        if      (magnitude_approx < 32'd500)    quantized_byte = 8'h41; // 'A'
        else if (magnitude_approx < 32'd5000)   quantized_byte = 8'h42; // 'B'
        else if (magnitude_approx < 32'd25000)  quantized_byte = 8'h43; // 'C'
        else if (magnitude_approx < 32'd100000) quantized_byte = 8'h44; // 'D'
        else                                    quantized_byte = 8'h50; // 'P'
    end

    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            state <= IDLE;
            sample_count <= 0;
            output_buffer <= 0;
            output_tlast <= 0;
            saw_tlast <= 0;
        end
        else begin
            state <= next_state;

            case (state)
                IDLE: begin
                    sample_count <= 0;
                    output_buffer <= 0;
                    output_tlast <= 0;
                    saw_tlast <= 0;
                end

                COLLECT: begin
                    if (s_axis_tvalid && s_axis_tready) begin
                        output_buffer[sample_count*8 +: 8] <= quantized_byte;
                        sample_count <= sample_count + 1;
                        if (s_axis_tlast) begin
                            saw_tlast <= 1'b1;
                        end
                    end
                end

                OUTPUT: begin
                    if (m_axis_tready) begin
                        sample_count <= 0;
                        output_buffer <= 0;
                        output_tlast <= saw_tlast;
                        saw_tlast <= 0;
                    end
                end
            endcase
        end
    end

    // Emit early if we saw tlast partway through the 64-sample window.
    always_comb begin
        next_state = state;

        case (state)
            IDLE: begin
                if (s_axis_tvalid) begin
                    next_state = COLLECT;
                end
            end

            COLLECT: begin
                if (s_axis_tvalid && s_axis_tready) begin
                    if ((sample_count == 6'd63) ||
                        (s_axis_tlast && (sample_count > 6'd0))) begin
                        next_state = OUTPUT;
                    end
                end
            end

            OUTPUT: begin
                if (m_axis_tready) begin
                    next_state = saw_tlast ? IDLE : COLLECT;
                end
            end
        endcase
    end

    assign s_axis_tready = (state == COLLECT);
    assign m_axis_tvalid = (state == OUTPUT);
    assign m_axis_tdata  = output_buffer;
    assign m_axis_tlast  = saw_tlast && (state == OUTPUT);

endmodule
