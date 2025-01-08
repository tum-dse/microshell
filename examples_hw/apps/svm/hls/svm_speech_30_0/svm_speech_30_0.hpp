// svm_speech_30_0.hpp
#ifndef SVM_SPEECH_30_0_HPP
#define SVM_SPEECH_30_0_HPP

#include "rtwtypes.h"
#include <stddef.h>
#include <stdlib.h>
#include <hls_stream.h>
#include "ap_axi_sdata.h"
#include "ap_int.h"


/* Function Declarations */
void svm_speech_30_0(
    hls::stream<ap_axiu<32, 0, 0, 0> >& s_axis_input,
    hls::stream<ap_axiu<32, 0, 0, 0> >& m_axis_output
);

#endif


