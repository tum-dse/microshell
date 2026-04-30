#ifndef XF_SECURITY_ASYMMETRIC_CRYPTOGRAPHY_HPP_
#define XF_SECURITY_ASYMMETRIC_CRYPTOGRAPHY_HPP_
#include <ap_int.h>
#include <hls_stream.h>
#include "modular.hpp"
#include <ap_axi_sdata.h>

namespace xf {
namespace security {

class rsa {
private:
    ap_uint<256> accumulator;
    bool processing_message;
    ap_uint<16> packet_count;

public:
    ap_uint<20>  exponent;
    ap_uint<256> modulus;
    ap_uint<256> rMod;

    rsa() : accumulator(0), processing_message(false), packet_count(0) {}

    void updateKey(ap_uint<256> inputModulus, ap_uint<20> inputExponent) {
        modulus = inputModulus;
        exponent = inputExponent;

        // R = 2^256 mod N, then rMod = R^2 mod N for Montgomery arithmetic.
        ap_uint<257> R = 0;
        R[256] = 1;
        ap_uint<256> R_mod = R % modulus;
        rMod = xf::security::internal::productMod<256>(R_mod, R_mod, modulus);
    }

    void process(
        hls::stream<ap_axiu<256,0,0,0>>& message_in,
        hls::stream<ap_axiu<256,0,0,0>>& result_out
    ) {
        if (!message_in.empty()) {
            ap_axiu<256,0,0,0> message_input = message_in.read();
            ap_uint<256> msg = message_input.data;

            if (!processing_message) {
                accumulator = msg;
                processing_message = true;
                packet_count = 1;
            } else {
                packet_count++;
                // Mix the packet count into the rotation+xor so a 256-chunk run
                // of identical input cannot cancel out to zero.
                ap_uint<256> rotated = (accumulator << 7) | (accumulator >> (256-7));
                accumulator = rotated ^ msg ^ ap_uint<256>(packet_count);
            }

            if (message_input.last) {
                ap_uint<256> mont_message = xf::security::internal::monProduct<256>(
                    accumulator, rMod, modulus);

                ap_uint<256> result = xf::security::internal::modularExp<256, 20>(
                    mont_message, exponent, modulus, rMod);

                ap_axiu<256,0,0,0> result_output;
                result_output.data = result;
                result_output.keep = ~0;
                result_output.last = 1;
                result_output.strb = ~0;
                result_out.write(result_output);

                processing_message = false;
                accumulator = 0;
                packet_count = 0;
            }
        }
    }
};

} // namespace security
} // namespace xf
#endif
