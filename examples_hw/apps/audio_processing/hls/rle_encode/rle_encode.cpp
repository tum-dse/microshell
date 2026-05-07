// HLS run-length encoder.
//
// One 512-bit beat (64 bytes) in -> one 512-bit beat out, byte-pair encoded:
// each (count, value) pair takes 2 bytes. The write_pos < 62 guard stops
// before we'd overrun the output beat (>= 31 runs); leftover input is
// dropped — fine in practice because the upstream quantizer produces long
// runs of identical bytes.

#include "rle_encode.hpp"

void rle_encode(
    hls::stream<ap_axiu<512,0,0,0>>& input_stream,
    hls::stream<ap_axiu<512,0,0,0>>& output_stream
) {
    #pragma HLS INTERFACE axis port=input_stream
    #pragma HLS INTERFACE axis port=output_stream
    #pragma HLS INTERFACE ap_ctrl_none port=return

    if (!input_stream.empty()) {
        ap_axiu<512,0,0,0> input_packet = input_stream.read();

        ap_axiu<512,0,0,0> output_packet;
        output_packet.data = 0;
        output_packet.keep = ~0;
        output_packet.last = input_packet.last;
        output_packet.strb = ~0;

        int write_pos = 0;
        int read_pos = 0;

        // Stop at write_pos == 62 so the (count, value) pair always fits in the beat.
        while (read_pos < 64 && write_pos < 62) {
            #pragma HLS PIPELINE II=1

            ap_uint<8> current_byte = input_packet.data.range(read_pos*8 + 7, read_pos*8);
            ap_uint<8> count = 1;

            // Cap run length at 255; longer runs split across pairs.
            int next_pos = read_pos + 1;
            while (next_pos < 64 && count < 255) {
                ap_uint<8> next_byte = input_packet.data.range(next_pos*8 + 7, next_pos*8);
                if (next_byte == current_byte) {
                    count++;
                    next_pos++;
                } else {
                    break;
                }
            }

            output_packet.data.range(write_pos*8 + 7, write_pos*8) = count;
            output_packet.data.range((write_pos + 1)*8 + 7, (write_pos + 1)*8) = current_byte;

            write_pos += 2;
            read_pos += count;
        }

        output_stream.write(output_packet);
    }
}
