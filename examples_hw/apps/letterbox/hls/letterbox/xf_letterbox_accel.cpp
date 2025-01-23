/*
 * Copyright 2019 Xilinx, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "xf_letterbox_config.h"

extern "C" {
void letterbox_c0_0_accel(
    hls::stream<ap_axiu<INPUT_PTR_WIDTH,0,0,0>>& img_inp,
    hls::stream<ap_axiu<OUTPUT_PTR_WIDTH,0,0,0>>& img_out,
    int rows_in,
    int cols_in,
    int rows_out,
    int cols_out,
    int insert_pad_value) 
{
#pragma HLS INLINE
#pragma HLS INTERFACE axis port=img_inp
#pragma HLS INTERFACE axis port=img_out
#pragma HLS INTERFACE s_axilite port=rows_in               
#pragma HLS INTERFACE s_axilite port=cols_in               
#pragma HLS INTERFACE s_axilite port=rows_out
#pragma HLS INTERFACE s_axilite port=cols_out
#pragma HLS INTERFACE s_axilite port=insert_pad_value
#pragma HLS INTERFACE s_axilite port=return
#pragma HLS DATAFLOW

    // clang-format on

    // Compute Resize output image size for Letterbox
    float scale_height = (float)rows_out / (float)rows_in;
    float scale_width = (float)cols_out / (float)cols_in;
    int rows_out_resize, cols_out_resize;
    if (scale_width < scale_height) {
        cols_out_resize = cols_out;
        rows_out_resize = (int)((float)(rows_in * cols_out) / (float)cols_in);
    } else {
        cols_out_resize = (int)((float)(cols_in * rows_out) / (float)rows_in);
        rows_out_resize = rows_out;
    }

    xf::cv::Mat<TYPE, HEIGHT, WIDTH, NPC_T, XF_CV_DEPTH_IN_0> imgInput0(rows_in, cols_in);
    xf::cv::Mat<TYPE, NEWHEIGHT, NEWWIDTH, NPC_T, XF_CV_DEPTH_OUT_1> out_mat_resize(rows_out_resize, cols_out_resize);
    xf::cv::Mat<TYPE, NEWHEIGHT, NEWWIDTH, NPC_T, XF_CV_DEPTH_OUT_2> out_mat(rows_out, cols_out);
// clang-format off
    #pragma HLS DATAFLOW
// clang-format on	
    xf::cv::AXI_Strm2xFMat<INPUT_PTR_WIDTH,TYPE,HEIGHT, WIDTH, NPC_T, XF_CV_DEPTH_IN_0>  (img_inp, imgInput0);
    xf::cv::resize<INTERPOLATION,TYPE,HEIGHT,WIDTH,NEWHEIGHT,NEWWIDTH,NPC_T, XF_CV_DEPTH_IN_0, XF_CV_DEPTH_OUT_1,MAXDOWNSCALE> (imgInput0, out_mat_resize);
    xf::cv::insertBorder<TYPE, NEWHEIGHT, NEWWIDTH, NEWHEIGHT, NEWWIDTH, NPC_T, XF_CV_DEPTH_OUT_1, XF_CV_DEPTH_OUT_2>(out_mat_resize, out_mat, insert_pad_value);
    xf::cv::xFMat2AXI_Strm<OUTPUT_PTR_WIDTH, TYPE, NEWHEIGHT, NEWWIDTH, NPC_T, XF_CV_DEPTH_IN_0>(out_mat, img_out);
    return;
}// end kernel
}// end extern C
