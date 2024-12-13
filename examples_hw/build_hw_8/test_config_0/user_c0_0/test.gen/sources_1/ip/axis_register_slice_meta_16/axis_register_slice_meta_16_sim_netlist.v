// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (lin64) Build 3526262 Mon Apr 18 15:47:01 MDT 2022
// Date        : Wed Nov 27 16:32:15 2024
// Host        : amy running 64-bit NixOS 24.05 (Uakari)
// Command     : write_verilog -force -mode funcsim
//               /scratch/anubhav/Coyote/examples_hw/build_hw_8/test_config_0/user_c0_0/test.gen/sources_1/ip/axis_register_slice_meta_16/axis_register_slice_meta_16_sim_netlist.v
// Design      : axis_register_slice_meta_16
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xcu280-fsvh2892-2L-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "axis_register_slice_meta_16,axis_register_slice_v1_1_26_axis_register_slice,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* X_CORE_INFO = "axis_register_slice_v1_1_26_axis_register_slice,Vivado 2022.1" *) 
(* NotValidForBitStream *)
module axis_register_slice_meta_16
   (aclk,
    aresetn,
    s_axis_tvalid,
    s_axis_tready,
    s_axis_tdata,
    m_axis_tvalid,
    m_axis_tready,
    m_axis_tdata);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLKIF CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLKIF, FREQ_HZ 10000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *) input aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RSTIF RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RSTIF, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input aresetn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TVALID" *) input s_axis_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TREADY" *) output s_axis_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS, TDATA_NUM_BYTES 2, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *) input [15:0]s_axis_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TVALID" *) output m_axis_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TREADY" *) input m_axis_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXIS, TDATA_NUM_BYTES 2, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *) output [15:0]m_axis_tdata;

  wire aclk;
  wire aresetn;
  wire [15:0]m_axis_tdata;
  wire m_axis_tready;
  wire m_axis_tvalid;
  wire [15:0]s_axis_tdata;
  wire s_axis_tready;
  wire s_axis_tvalid;
  wire NLW_inst_m_axis_tlast_UNCONNECTED;
  wire [0:0]NLW_inst_m_axis_tdest_UNCONNECTED;
  wire [0:0]NLW_inst_m_axis_tid_UNCONNECTED;
  wire [1:0]NLW_inst_m_axis_tkeep_UNCONNECTED;
  wire [1:0]NLW_inst_m_axis_tstrb_UNCONNECTED;
  wire [0:0]NLW_inst_m_axis_tuser_UNCONNECTED;

  (* C_AXIS_SIGNAL_SET = "3" *) 
  (* C_AXIS_TDATA_WIDTH = "16" *) 
  (* C_AXIS_TDEST_WIDTH = "1" *) 
  (* C_AXIS_TID_WIDTH = "1" *) 
  (* C_AXIS_TUSER_WIDTH = "1" *) 
  (* C_FAMILY = "virtexuplusHBM" *) 
  (* C_NUM_SLR_CROSSINGS = "0" *) 
  (* C_PIPELINES_MASTER = "0" *) 
  (* C_PIPELINES_MIDDLE = "0" *) 
  (* C_PIPELINES_SLAVE = "0" *) 
  (* C_REG_CONFIG = "8" *) 
  (* DowngradeIPIdentifiedWarnings = "yes" *) 
  (* G_INDX_SS_TDATA = "1" *) 
  (* G_INDX_SS_TDEST = "6" *) 
  (* G_INDX_SS_TID = "5" *) 
  (* G_INDX_SS_TKEEP = "3" *) 
  (* G_INDX_SS_TLAST = "4" *) 
  (* G_INDX_SS_TREADY = "0" *) 
  (* G_INDX_SS_TSTRB = "2" *) 
  (* G_INDX_SS_TUSER = "7" *) 
  (* G_MASK_SS_TDATA = "2" *) 
  (* G_MASK_SS_TDEST = "64" *) 
  (* G_MASK_SS_TID = "32" *) 
  (* G_MASK_SS_TKEEP = "8" *) 
  (* G_MASK_SS_TLAST = "16" *) 
  (* G_MASK_SS_TREADY = "1" *) 
  (* G_MASK_SS_TSTRB = "4" *) 
  (* G_MASK_SS_TUSER = "128" *) 
  (* G_TASK_SEVERITY_ERR = "2" *) 
  (* G_TASK_SEVERITY_INFO = "0" *) 
  (* G_TASK_SEVERITY_WARNING = "1" *) 
  (* P_TPAYLOAD_WIDTH = "16" *) 
  axis_register_slice_meta_16_axis_register_slice_v1_1_26_axis_register_slice inst
       (.aclk(aclk),
        .aclk2x(1'b0),
        .aclken(1'b1),
        .aresetn(aresetn),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tdest(NLW_inst_m_axis_tdest_UNCONNECTED[0]),
        .m_axis_tid(NLW_inst_m_axis_tid_UNCONNECTED[0]),
        .m_axis_tkeep(NLW_inst_m_axis_tkeep_UNCONNECTED[1:0]),
        .m_axis_tlast(NLW_inst_m_axis_tlast_UNCONNECTED),
        .m_axis_tready(m_axis_tready),
        .m_axis_tstrb(NLW_inst_m_axis_tstrb_UNCONNECTED[1:0]),
        .m_axis_tuser(NLW_inst_m_axis_tuser_UNCONNECTED[0]),
        .m_axis_tvalid(m_axis_tvalid),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tdest(1'b0),
        .s_axis_tid(1'b0),
        .s_axis_tkeep({1'b1,1'b1}),
        .s_axis_tlast(1'b1),
        .s_axis_tready(s_axis_tready),
        .s_axis_tstrb({1'b1,1'b1}),
        .s_axis_tuser(1'b0),
        .s_axis_tvalid(s_axis_tvalid));
endmodule

(* C_AXIS_SIGNAL_SET = "3" *) (* C_AXIS_TDATA_WIDTH = "16" *) (* C_AXIS_TDEST_WIDTH = "1" *) 
(* C_AXIS_TID_WIDTH = "1" *) (* C_AXIS_TUSER_WIDTH = "1" *) (* C_FAMILY = "virtexuplusHBM" *) 
(* C_NUM_SLR_CROSSINGS = "0" *) (* C_PIPELINES_MASTER = "0" *) (* C_PIPELINES_MIDDLE = "0" *) 
(* C_PIPELINES_SLAVE = "0" *) (* C_REG_CONFIG = "8" *) (* DowngradeIPIdentifiedWarnings = "yes" *) 
(* G_INDX_SS_TDATA = "1" *) (* G_INDX_SS_TDEST = "6" *) (* G_INDX_SS_TID = "5" *) 
(* G_INDX_SS_TKEEP = "3" *) (* G_INDX_SS_TLAST = "4" *) (* G_INDX_SS_TREADY = "0" *) 
(* G_INDX_SS_TSTRB = "2" *) (* G_INDX_SS_TUSER = "7" *) (* G_MASK_SS_TDATA = "2" *) 
(* G_MASK_SS_TDEST = "64" *) (* G_MASK_SS_TID = "32" *) (* G_MASK_SS_TKEEP = "8" *) 
(* G_MASK_SS_TLAST = "16" *) (* G_MASK_SS_TREADY = "1" *) (* G_MASK_SS_TSTRB = "4" *) 
(* G_MASK_SS_TUSER = "128" *) (* G_TASK_SEVERITY_ERR = "2" *) (* G_TASK_SEVERITY_INFO = "0" *) 
(* G_TASK_SEVERITY_WARNING = "1" *) (* ORIG_REF_NAME = "axis_register_slice_v1_1_26_axis_register_slice" *) (* P_TPAYLOAD_WIDTH = "16" *) 
module axis_register_slice_meta_16_axis_register_slice_v1_1_26_axis_register_slice
   (aclk,
    aclk2x,
    aresetn,
    aclken,
    s_axis_tvalid,
    s_axis_tready,
    s_axis_tdata,
    s_axis_tstrb,
    s_axis_tkeep,
    s_axis_tlast,
    s_axis_tid,
    s_axis_tdest,
    s_axis_tuser,
    m_axis_tvalid,
    m_axis_tready,
    m_axis_tdata,
    m_axis_tstrb,
    m_axis_tkeep,
    m_axis_tlast,
    m_axis_tid,
    m_axis_tdest,
    m_axis_tuser);
  input aclk;
  input aclk2x;
  input aresetn;
  input aclken;
  input s_axis_tvalid;
  output s_axis_tready;
  input [15:0]s_axis_tdata;
  input [1:0]s_axis_tstrb;
  input [1:0]s_axis_tkeep;
  input s_axis_tlast;
  input [0:0]s_axis_tid;
  input [0:0]s_axis_tdest;
  input [0:0]s_axis_tuser;
  output m_axis_tvalid;
  input m_axis_tready;
  output [15:0]m_axis_tdata;
  output [1:0]m_axis_tstrb;
  output [1:0]m_axis_tkeep;
  output m_axis_tlast;
  output [0:0]m_axis_tid;
  output [0:0]m_axis_tdest;
  output [0:0]m_axis_tuser;

  wire \<const0> ;
  wire aclk;
  wire areset_r;
  wire areset_r_i_1_n_0;
  wire aresetn;
  wire [15:0]m_axis_tdata;
  wire m_axis_tready;
  wire m_axis_tvalid;
  wire [15:0]s_axis_tdata;
  wire s_axis_tready;
  wire s_axis_tvalid;

  assign m_axis_tdest[0] = \<const0> ;
  assign m_axis_tid[0] = \<const0> ;
  assign m_axis_tkeep[1] = \<const0> ;
  assign m_axis_tkeep[0] = \<const0> ;
  assign m_axis_tlast = \<const0> ;
  assign m_axis_tstrb[1] = \<const0> ;
  assign m_axis_tstrb[0] = \<const0> ;
  assign m_axis_tuser[0] = \<const0> ;
  GND GND
       (.G(\<const0> ));
  LUT1 #(
    .INIT(2'h1)) 
    areset_r_i_1
       (.I0(aresetn),
        .O(areset_r_i_1_n_0));
  FDRE #(
    .INIT(1'b0)) 
    areset_r_reg
       (.C(aclk),
        .CE(1'b1),
        .D(areset_r_i_1_n_0),
        .Q(areset_r),
        .R(1'b0));
  axis_register_slice_meta_16_axis_register_slice_v1_1_26_axisc_register_slice axisc_register_slice_0
       (.Q(m_axis_tvalid),
        .aclk(aclk),
        .areset_r(areset_r),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tready(m_axis_tready),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tready(s_axis_tready),
        .s_axis_tvalid(s_axis_tvalid));
endmodule

(* ORIG_REF_NAME = "axis_register_slice_v1_1_26_axisc_register_slice" *) 
module axis_register_slice_meta_16_axis_register_slice_v1_1_26_axisc_register_slice
   (s_axis_tready,
    Q,
    m_axis_tdata,
    aclk,
    m_axis_tready,
    s_axis_tvalid,
    s_axis_tdata,
    areset_r);
  output s_axis_tready;
  output [0:0]Q;
  output [15:0]m_axis_tdata;
  input aclk;
  input m_axis_tready;
  input s_axis_tvalid;
  input [15:0]s_axis_tdata;
  input areset_r;

  wire [0:0]Q;
  wire aclk;
  wire areset_r;
  wire \aresetn_d_reg_n_0_[0] ;
  wire \aresetn_d_reg_n_0_[1] ;
  wire [15:0]m_axis_tdata;
  wire m_axis_tready;
  wire [15:0]p_0_in;
  wire [0:0]p_1_out;
  wire [15:0]s_axis_tdata;
  wire s_axis_tready;
  wire s_axis_tvalid;
  wire s_ready_i0;
  wire s_ready_i_i_1_n_0;
  wire s_ready_i_i_2_n_0;
  wire [1:0]state;
  wire \state[0]_i_1_n_0 ;
  wire \state[0]_i_2_n_0 ;
  wire \state_reg_n_0_[1] ;
  wire storage_data1;
  wire [15:0]storage_data2;
  wire storage_data2_0;

  LUT4 #(
    .INIT(16'hE420)) 
    \__2/i_ 
       (.I0(\state_reg_n_0_[1] ),
        .I1(Q),
        .I2(s_axis_tvalid),
        .I3(m_axis_tready),
        .O(storage_data1));
  LUT1 #(
    .INIT(2'h1)) 
    \aresetn_d[0]_i_1 
       (.I0(areset_r),
        .O(p_1_out));
  (* equivalent_register_removal = "no" *) 
  FDRE #(
    .INIT(1'b0)) 
    \aresetn_d_reg[0] 
       (.C(aclk),
        .CE(1'b1),
        .D(p_1_out),
        .Q(\aresetn_d_reg_n_0_[0] ),
        .R(1'b0));
  (* equivalent_register_removal = "no" *) 
  FDRE #(
    .INIT(1'b0)) 
    \aresetn_d_reg[1] 
       (.C(aclk),
        .CE(1'b1),
        .D(\aresetn_d_reg_n_0_[0] ),
        .Q(\aresetn_d_reg_n_0_[1] ),
        .R(1'b0));
  LUT6 #(
    .INIT(64'h00000000E2E2EEE2)) 
    s_ready_i_i_1
       (.I0(s_axis_tready),
        .I1(s_ready_i_i_2_n_0),
        .I2(s_ready_i0),
        .I3(m_axis_tready),
        .I4(\state_reg_n_0_[1] ),
        .I5(areset_r),
        .O(s_ready_i_i_1_n_0));
  LUT6 #(
    .INIT(64'h2808FFFF00000000)) 
    s_ready_i_i_2
       (.I0(Q),
        .I1(m_axis_tready),
        .I2(\state_reg_n_0_[1] ),
        .I3(s_axis_tvalid),
        .I4(\aresetn_d_reg_n_0_[1] ),
        .I5(\aresetn_d_reg_n_0_[0] ),
        .O(s_ready_i_i_2_n_0));
  LUT2 #(
    .INIT(4'h2)) 
    s_ready_i_i_3
       (.I0(\aresetn_d_reg_n_0_[0] ),
        .I1(\aresetn_d_reg_n_0_[1] ),
        .O(s_ready_i0));
  FDRE #(
    .INIT(1'b0)) 
    s_ready_i_reg
       (.C(aclk),
        .CE(1'b1),
        .D(s_ready_i_i_1_n_0),
        .Q(s_axis_tready),
        .R(1'b0));
  LUT3 #(
    .INIT(8'hBA)) 
    \state[0]_i_1 
       (.I0(areset_r),
        .I1(\aresetn_d_reg_n_0_[1] ),
        .I2(\aresetn_d_reg_n_0_[0] ),
        .O(\state[0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2A808A8A)) 
    \state[0]_i_2 
       (.I0(\aresetn_d_reg_n_0_[0] ),
        .I1(m_axis_tready),
        .I2(Q),
        .I3(s_axis_tvalid),
        .I4(\state_reg_n_0_[1] ),
        .O(\state[0]_i_2_n_0 ));
  LUT4 #(
    .INIT(16'h7808)) 
    \state[0]_i_3 
       (.I0(m_axis_tready),
        .I1(Q),
        .I2(\state_reg_n_0_[1] ),
        .I3(s_axis_tvalid),
        .O(state[0]));
  LUT4 #(
    .INIT(16'hFD2D)) 
    \state[1]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(s_axis_tvalid),
        .I2(Q),
        .I3(m_axis_tready),
        .O(state[1]));
  (* FSM_ENCODING = "none" *) 
  FDRE #(
    .INIT(1'b0)) 
    \state_reg[0] 
       (.C(aclk),
        .CE(\state[0]_i_2_n_0 ),
        .D(state[0]),
        .Q(Q),
        .R(\state[0]_i_1_n_0 ));
  (* FSM_ENCODING = "none" *) 
  FDSE #(
    .INIT(1'b1)) 
    \state_reg[1] 
       (.C(aclk),
        .CE(\state[0]_i_2_n_0 ),
        .D(state[1]),
        .Q(\state_reg_n_0_[1] ),
        .S(\state[0]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hCCAC)) 
    \storage_data1[0]_i_1 
       (.I0(storage_data2[0]),
        .I1(s_axis_tdata[0]),
        .I2(Q),
        .I3(\state_reg_n_0_[1] ),
        .O(p_0_in[0]));
  LUT4 #(
    .INIT(16'hCCAC)) 
    \storage_data1[10]_i_1 
       (.I0(storage_data2[10]),
        .I1(s_axis_tdata[10]),
        .I2(Q),
        .I3(\state_reg_n_0_[1] ),
        .O(p_0_in[10]));
  LUT4 #(
    .INIT(16'hCCAC)) 
    \storage_data1[11]_i_1 
       (.I0(storage_data2[11]),
        .I1(s_axis_tdata[11]),
        .I2(Q),
        .I3(\state_reg_n_0_[1] ),
        .O(p_0_in[11]));
  LUT4 #(
    .INIT(16'hCCAC)) 
    \storage_data1[12]_i_1 
       (.I0(storage_data2[12]),
        .I1(s_axis_tdata[12]),
        .I2(Q),
        .I3(\state_reg_n_0_[1] ),
        .O(p_0_in[12]));
  LUT4 #(
    .INIT(16'hCCAC)) 
    \storage_data1[13]_i_1 
       (.I0(storage_data2[13]),
        .I1(s_axis_tdata[13]),
        .I2(Q),
        .I3(\state_reg_n_0_[1] ),
        .O(p_0_in[13]));
  LUT4 #(
    .INIT(16'hCCAC)) 
    \storage_data1[14]_i_1 
       (.I0(storage_data2[14]),
        .I1(s_axis_tdata[14]),
        .I2(Q),
        .I3(\state_reg_n_0_[1] ),
        .O(p_0_in[14]));
  LUT4 #(
    .INIT(16'hCCAC)) 
    \storage_data1[15]_i_1 
       (.I0(storage_data2[15]),
        .I1(s_axis_tdata[15]),
        .I2(Q),
        .I3(\state_reg_n_0_[1] ),
        .O(p_0_in[15]));
  LUT4 #(
    .INIT(16'hCCAC)) 
    \storage_data1[1]_i_1 
       (.I0(storage_data2[1]),
        .I1(s_axis_tdata[1]),
        .I2(Q),
        .I3(\state_reg_n_0_[1] ),
        .O(p_0_in[1]));
  LUT4 #(
    .INIT(16'hCCAC)) 
    \storage_data1[2]_i_1 
       (.I0(storage_data2[2]),
        .I1(s_axis_tdata[2]),
        .I2(Q),
        .I3(\state_reg_n_0_[1] ),
        .O(p_0_in[2]));
  LUT4 #(
    .INIT(16'hCCAC)) 
    \storage_data1[3]_i_1 
       (.I0(storage_data2[3]),
        .I1(s_axis_tdata[3]),
        .I2(Q),
        .I3(\state_reg_n_0_[1] ),
        .O(p_0_in[3]));
  LUT4 #(
    .INIT(16'hCCAC)) 
    \storage_data1[4]_i_1 
       (.I0(storage_data2[4]),
        .I1(s_axis_tdata[4]),
        .I2(Q),
        .I3(\state_reg_n_0_[1] ),
        .O(p_0_in[4]));
  LUT4 #(
    .INIT(16'hCCAC)) 
    \storage_data1[5]_i_1 
       (.I0(storage_data2[5]),
        .I1(s_axis_tdata[5]),
        .I2(Q),
        .I3(\state_reg_n_0_[1] ),
        .O(p_0_in[5]));
  LUT4 #(
    .INIT(16'hCCAC)) 
    \storage_data1[6]_i_1 
       (.I0(storage_data2[6]),
        .I1(s_axis_tdata[6]),
        .I2(Q),
        .I3(\state_reg_n_0_[1] ),
        .O(p_0_in[6]));
  LUT4 #(
    .INIT(16'hCCAC)) 
    \storage_data1[7]_i_1 
       (.I0(storage_data2[7]),
        .I1(s_axis_tdata[7]),
        .I2(Q),
        .I3(\state_reg_n_0_[1] ),
        .O(p_0_in[7]));
  LUT4 #(
    .INIT(16'hCCAC)) 
    \storage_data1[8]_i_1 
       (.I0(storage_data2[8]),
        .I1(s_axis_tdata[8]),
        .I2(Q),
        .I3(\state_reg_n_0_[1] ),
        .O(p_0_in[8]));
  LUT4 #(
    .INIT(16'hCCAC)) 
    \storage_data1[9]_i_1 
       (.I0(storage_data2[9]),
        .I1(s_axis_tdata[9]),
        .I2(Q),
        .I3(\state_reg_n_0_[1] ),
        .O(p_0_in[9]));
  FDRE \storage_data1_reg[0] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[0]),
        .Q(m_axis_tdata[0]),
        .R(1'b0));
  FDRE \storage_data1_reg[10] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[10]),
        .Q(m_axis_tdata[10]),
        .R(1'b0));
  FDRE \storage_data1_reg[11] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[11]),
        .Q(m_axis_tdata[11]),
        .R(1'b0));
  FDRE \storage_data1_reg[12] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[12]),
        .Q(m_axis_tdata[12]),
        .R(1'b0));
  FDRE \storage_data1_reg[13] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[13]),
        .Q(m_axis_tdata[13]),
        .R(1'b0));
  FDRE \storage_data1_reg[14] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[14]),
        .Q(m_axis_tdata[14]),
        .R(1'b0));
  FDRE \storage_data1_reg[15] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[15]),
        .Q(m_axis_tdata[15]),
        .R(1'b0));
  FDRE \storage_data1_reg[1] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[1]),
        .Q(m_axis_tdata[1]),
        .R(1'b0));
  FDRE \storage_data1_reg[2] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[2]),
        .Q(m_axis_tdata[2]),
        .R(1'b0));
  FDRE \storage_data1_reg[3] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[3]),
        .Q(m_axis_tdata[3]),
        .R(1'b0));
  FDRE \storage_data1_reg[4] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[4]),
        .Q(m_axis_tdata[4]),
        .R(1'b0));
  FDRE \storage_data1_reg[5] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[5]),
        .Q(m_axis_tdata[5]),
        .R(1'b0));
  FDRE \storage_data1_reg[6] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[6]),
        .Q(m_axis_tdata[6]),
        .R(1'b0));
  FDRE \storage_data1_reg[7] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[7]),
        .Q(m_axis_tdata[7]),
        .R(1'b0));
  FDRE \storage_data1_reg[8] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[8]),
        .Q(m_axis_tdata[8]),
        .R(1'b0));
  FDRE \storage_data1_reg[9] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[9]),
        .Q(m_axis_tdata[9]),
        .R(1'b0));
  LUT2 #(
    .INIT(4'h8)) 
    \storage_data2[15]_i_1 
       (.I0(s_axis_tvalid),
        .I1(s_axis_tready),
        .O(storage_data2_0));
  FDRE \storage_data2_reg[0] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[0]),
        .Q(storage_data2[0]),
        .R(1'b0));
  FDRE \storage_data2_reg[10] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[10]),
        .Q(storage_data2[10]),
        .R(1'b0));
  FDRE \storage_data2_reg[11] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[11]),
        .Q(storage_data2[11]),
        .R(1'b0));
  FDRE \storage_data2_reg[12] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[12]),
        .Q(storage_data2[12]),
        .R(1'b0));
  FDRE \storage_data2_reg[13] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[13]),
        .Q(storage_data2[13]),
        .R(1'b0));
  FDRE \storage_data2_reg[14] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[14]),
        .Q(storage_data2[14]),
        .R(1'b0));
  FDRE \storage_data2_reg[15] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[15]),
        .Q(storage_data2[15]),
        .R(1'b0));
  FDRE \storage_data2_reg[1] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[1]),
        .Q(storage_data2[1]),
        .R(1'b0));
  FDRE \storage_data2_reg[2] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[2]),
        .Q(storage_data2[2]),
        .R(1'b0));
  FDRE \storage_data2_reg[3] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[3]),
        .Q(storage_data2[3]),
        .R(1'b0));
  FDRE \storage_data2_reg[4] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[4]),
        .Q(storage_data2[4]),
        .R(1'b0));
  FDRE \storage_data2_reg[5] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[5]),
        .Q(storage_data2[5]),
        .R(1'b0));
  FDRE \storage_data2_reg[6] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[6]),
        .Q(storage_data2[6]),
        .R(1'b0));
  FDRE \storage_data2_reg[7] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[7]),
        .Q(storage_data2[7]),
        .R(1'b0));
  FDRE \storage_data2_reg[8] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[8]),
        .Q(storage_data2[8]),
        .R(1'b0));
  FDRE \storage_data2_reg[9] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[9]),
        .Q(storage_data2[9]),
        .R(1'b0));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
