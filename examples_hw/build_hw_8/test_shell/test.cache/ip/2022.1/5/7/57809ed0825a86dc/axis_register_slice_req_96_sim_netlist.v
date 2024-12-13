// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (lin64) Build 3526262 Mon Apr 18 15:47:01 MDT 2022
// Date        : Wed Nov 27 16:21:32 2024
// Host        : amy running 64-bit NixOS 24.05 (Uakari)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ axis_register_slice_req_96_sim_netlist.v
// Design      : axis_register_slice_req_96
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xcu280-fsvh2892-2L-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "axis_register_slice_req_96,axis_register_slice_v1_1_26_axis_register_slice,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* X_CORE_INFO = "axis_register_slice_v1_1_26_axis_register_slice,Vivado 2022.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
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
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS, TDATA_NUM_BYTES 12, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *) input [95:0]s_axis_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TVALID" *) output m_axis_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TREADY" *) input m_axis_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXIS, TDATA_NUM_BYTES 12, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *) output [95:0]m_axis_tdata;

  wire aclk;
  wire aresetn;
  wire [95:0]m_axis_tdata;
  wire m_axis_tready;
  wire m_axis_tvalid;
  wire [95:0]s_axis_tdata;
  wire s_axis_tready;
  wire s_axis_tvalid;
  wire NLW_inst_m_axis_tlast_UNCONNECTED;
  wire [0:0]NLW_inst_m_axis_tdest_UNCONNECTED;
  wire [0:0]NLW_inst_m_axis_tid_UNCONNECTED;
  wire [11:0]NLW_inst_m_axis_tkeep_UNCONNECTED;
  wire [11:0]NLW_inst_m_axis_tstrb_UNCONNECTED;
  wire [0:0]NLW_inst_m_axis_tuser_UNCONNECTED;

  (* C_AXIS_SIGNAL_SET = "3" *) 
  (* C_AXIS_TDATA_WIDTH = "96" *) 
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
  (* P_TPAYLOAD_WIDTH = "96" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_axis_register_slice_v1_1_26_axis_register_slice inst
       (.aclk(aclk),
        .aclk2x(1'b0),
        .aclken(1'b1),
        .aresetn(aresetn),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tdest(NLW_inst_m_axis_tdest_UNCONNECTED[0]),
        .m_axis_tid(NLW_inst_m_axis_tid_UNCONNECTED[0]),
        .m_axis_tkeep(NLW_inst_m_axis_tkeep_UNCONNECTED[11:0]),
        .m_axis_tlast(NLW_inst_m_axis_tlast_UNCONNECTED),
        .m_axis_tready(m_axis_tready),
        .m_axis_tstrb(NLW_inst_m_axis_tstrb_UNCONNECTED[11:0]),
        .m_axis_tuser(NLW_inst_m_axis_tuser_UNCONNECTED[0]),
        .m_axis_tvalid(m_axis_tvalid),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tdest(1'b0),
        .s_axis_tid(1'b0),
        .s_axis_tkeep({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .s_axis_tlast(1'b1),
        .s_axis_tready(s_axis_tready),
        .s_axis_tstrb({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .s_axis_tuser(1'b0),
        .s_axis_tvalid(s_axis_tvalid));
endmodule

(* C_AXIS_SIGNAL_SET = "3" *) (* C_AXIS_TDATA_WIDTH = "96" *) (* C_AXIS_TDEST_WIDTH = "1" *) 
(* C_AXIS_TID_WIDTH = "1" *) (* C_AXIS_TUSER_WIDTH = "1" *) (* C_FAMILY = "virtexuplusHBM" *) 
(* C_NUM_SLR_CROSSINGS = "0" *) (* C_PIPELINES_MASTER = "0" *) (* C_PIPELINES_MIDDLE = "0" *) 
(* C_PIPELINES_SLAVE = "0" *) (* C_REG_CONFIG = "8" *) (* DowngradeIPIdentifiedWarnings = "yes" *) 
(* G_INDX_SS_TDATA = "1" *) (* G_INDX_SS_TDEST = "6" *) (* G_INDX_SS_TID = "5" *) 
(* G_INDX_SS_TKEEP = "3" *) (* G_INDX_SS_TLAST = "4" *) (* G_INDX_SS_TREADY = "0" *) 
(* G_INDX_SS_TSTRB = "2" *) (* G_INDX_SS_TUSER = "7" *) (* G_MASK_SS_TDATA = "2" *) 
(* G_MASK_SS_TDEST = "64" *) (* G_MASK_SS_TID = "32" *) (* G_MASK_SS_TKEEP = "8" *) 
(* G_MASK_SS_TLAST = "16" *) (* G_MASK_SS_TREADY = "1" *) (* G_MASK_SS_TSTRB = "4" *) 
(* G_MASK_SS_TUSER = "128" *) (* G_TASK_SEVERITY_ERR = "2" *) (* G_TASK_SEVERITY_INFO = "0" *) 
(* G_TASK_SEVERITY_WARNING = "1" *) (* P_TPAYLOAD_WIDTH = "96" *) 
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_axis_register_slice_v1_1_26_axis_register_slice
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
  input [95:0]s_axis_tdata;
  input [11:0]s_axis_tstrb;
  input [11:0]s_axis_tkeep;
  input s_axis_tlast;
  input [0:0]s_axis_tid;
  input [0:0]s_axis_tdest;
  input [0:0]s_axis_tuser;
  output m_axis_tvalid;
  input m_axis_tready;
  output [95:0]m_axis_tdata;
  output [11:0]m_axis_tstrb;
  output [11:0]m_axis_tkeep;
  output m_axis_tlast;
  output [0:0]m_axis_tid;
  output [0:0]m_axis_tdest;
  output [0:0]m_axis_tuser;

  wire \<const0> ;
  wire aclk;
  wire areset_r;
  wire areset_r_i_1_n_0;
  wire aresetn;
  wire [95:0]m_axis_tdata;
  wire m_axis_tready;
  wire m_axis_tvalid;
  wire [95:0]s_axis_tdata;
  wire s_axis_tready;
  wire s_axis_tvalid;

  assign m_axis_tdest[0] = \<const0> ;
  assign m_axis_tid[0] = \<const0> ;
  assign m_axis_tkeep[11] = \<const0> ;
  assign m_axis_tkeep[10] = \<const0> ;
  assign m_axis_tkeep[9] = \<const0> ;
  assign m_axis_tkeep[8] = \<const0> ;
  assign m_axis_tkeep[7] = \<const0> ;
  assign m_axis_tkeep[6] = \<const0> ;
  assign m_axis_tkeep[5] = \<const0> ;
  assign m_axis_tkeep[4] = \<const0> ;
  assign m_axis_tkeep[3] = \<const0> ;
  assign m_axis_tkeep[2] = \<const0> ;
  assign m_axis_tkeep[1] = \<const0> ;
  assign m_axis_tkeep[0] = \<const0> ;
  assign m_axis_tlast = \<const0> ;
  assign m_axis_tstrb[11] = \<const0> ;
  assign m_axis_tstrb[10] = \<const0> ;
  assign m_axis_tstrb[9] = \<const0> ;
  assign m_axis_tstrb[8] = \<const0> ;
  assign m_axis_tstrb[7] = \<const0> ;
  assign m_axis_tstrb[6] = \<const0> ;
  assign m_axis_tstrb[5] = \<const0> ;
  assign m_axis_tstrb[4] = \<const0> ;
  assign m_axis_tstrb[3] = \<const0> ;
  assign m_axis_tstrb[2] = \<const0> ;
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
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_axis_register_slice_v1_1_26_axisc_register_slice axisc_register_slice_0
       (.Q(m_axis_tvalid),
        .aclk(aclk),
        .areset_r(areset_r),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tready(m_axis_tready),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tready(s_axis_tready),
        .s_axis_tvalid(s_axis_tvalid));
endmodule

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_axis_register_slice_v1_1_26_axisc_register_slice
   (s_axis_tready,
    Q,
    m_axis_tdata,
    aclk,
    s_axis_tvalid,
    m_axis_tready,
    s_axis_tdata,
    areset_r);
  output s_axis_tready;
  output [0:0]Q;
  output [95:0]m_axis_tdata;
  input aclk;
  input s_axis_tvalid;
  input m_axis_tready;
  input [95:0]s_axis_tdata;
  input areset_r;

  wire [0:0]Q;
  wire aclk;
  wire areset_r;
  wire \aresetn_d_reg_n_0_[0] ;
  wire \aresetn_d_reg_n_0_[1] ;
  wire [95:0]m_axis_tdata;
  wire m_axis_tready;
  wire [95:0]p_0_in;
  wire [0:0]p_1_out;
  wire [95:0]s_axis_tdata;
  wire s_axis_tready;
  wire s_axis_tvalid;
  wire s_ready_i_i_1_n_0;
  wire s_ready_i_i_2_n_0;
  wire s_ready_i_i_3_n_0;
  wire [1:0]state;
  wire \state[0]_i_1_n_0 ;
  wire \state[0]_i_2_n_0 ;
  wire \state_reg_n_0_[1] ;
  wire storage_data1;
  wire [95:0]storage_data2;
  wire storage_data2_0;

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
        .I2(s_ready_i_i_3_n_0),
        .I3(m_axis_tready),
        .I4(\state_reg_n_0_[1] ),
        .I5(areset_r),
        .O(s_ready_i_i_1_n_0));
  LUT6 #(
    .INIT(64'h5800FFFF00000000)) 
    s_ready_i_i_2
       (.I0(\state_reg_n_0_[1] ),
        .I1(s_axis_tvalid),
        .I2(m_axis_tready),
        .I3(Q),
        .I4(\aresetn_d_reg_n_0_[1] ),
        .I5(\aresetn_d_reg_n_0_[0] ),
        .O(s_ready_i_i_2_n_0));
  LUT2 #(
    .INIT(4'h2)) 
    s_ready_i_i_3
       (.I0(\aresetn_d_reg_n_0_[0] ),
        .I1(\aresetn_d_reg_n_0_[1] ),
        .O(s_ready_i_i_3_n_0));
  FDRE #(
    .INIT(1'b0)) 
    s_ready_i_reg
       (.C(aclk),
        .CE(1'b1),
        .D(s_ready_i_i_1_n_0),
        .Q(s_axis_tready),
        .R(1'b0));
  LUT3 #(
    .INIT(8'hF4)) 
    \state[0]_i_1 
       (.I0(\aresetn_d_reg_n_0_[1] ),
        .I1(\aresetn_d_reg_n_0_[0] ),
        .I2(areset_r),
        .O(\state[0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h7D8D0000)) 
    \state[0]_i_2 
       (.I0(\state_reg_n_0_[1] ),
        .I1(s_axis_tvalid),
        .I2(Q),
        .I3(m_axis_tready),
        .I4(\aresetn_d_reg_n_0_[0] ),
        .O(\state[0]_i_2_n_0 ));
  LUT4 #(
    .INIT(16'h7088)) 
    \state[0]_i_3 
       (.I0(m_axis_tready),
        .I1(Q),
        .I2(s_axis_tvalid),
        .I3(\state_reg_n_0_[1] ),
        .O(state[0]));
  LUT4 #(
    .INIT(16'hBCBB)) 
    \state[1]_i_1 
       (.I0(m_axis_tready),
        .I1(Q),
        .I2(s_axis_tvalid),
        .I3(\state_reg_n_0_[1] ),
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
    .INIT(16'hEF20)) 
    \storage_data1[0]_i_1 
       (.I0(storage_data2[0]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[0]),
        .O(p_0_in[0]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[10]_i_1 
       (.I0(storage_data2[10]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[10]),
        .O(p_0_in[10]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[11]_i_1 
       (.I0(storage_data2[11]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[11]),
        .O(p_0_in[11]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[12]_i_1 
       (.I0(storage_data2[12]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[12]),
        .O(p_0_in[12]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[13]_i_1 
       (.I0(storage_data2[13]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[13]),
        .O(p_0_in[13]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[14]_i_1 
       (.I0(storage_data2[14]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[14]),
        .O(p_0_in[14]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[15]_i_1 
       (.I0(storage_data2[15]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[15]),
        .O(p_0_in[15]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[16]_i_1 
       (.I0(storage_data2[16]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[16]),
        .O(p_0_in[16]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[17]_i_1 
       (.I0(storage_data2[17]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[17]),
        .O(p_0_in[17]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[18]_i_1 
       (.I0(storage_data2[18]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[18]),
        .O(p_0_in[18]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[19]_i_1 
       (.I0(storage_data2[19]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[19]),
        .O(p_0_in[19]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[1]_i_1 
       (.I0(storage_data2[1]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[1]),
        .O(p_0_in[1]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[20]_i_1 
       (.I0(storage_data2[20]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[20]),
        .O(p_0_in[20]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[21]_i_1 
       (.I0(storage_data2[21]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[21]),
        .O(p_0_in[21]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[22]_i_1 
       (.I0(storage_data2[22]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[22]),
        .O(p_0_in[22]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[23]_i_1 
       (.I0(storage_data2[23]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[23]),
        .O(p_0_in[23]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[24]_i_1 
       (.I0(storage_data2[24]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[24]),
        .O(p_0_in[24]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[25]_i_1 
       (.I0(storage_data2[25]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[25]),
        .O(p_0_in[25]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[26]_i_1 
       (.I0(storage_data2[26]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[26]),
        .O(p_0_in[26]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[27]_i_1 
       (.I0(storage_data2[27]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[27]),
        .O(p_0_in[27]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[28]_i_1 
       (.I0(storage_data2[28]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[28]),
        .O(p_0_in[28]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[29]_i_1 
       (.I0(storage_data2[29]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[29]),
        .O(p_0_in[29]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[2]_i_1 
       (.I0(storage_data2[2]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[2]),
        .O(p_0_in[2]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[30]_i_1 
       (.I0(storage_data2[30]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[30]),
        .O(p_0_in[30]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[31]_i_1 
       (.I0(storage_data2[31]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[31]),
        .O(p_0_in[31]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[32]_i_1 
       (.I0(storage_data2[32]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[32]),
        .O(p_0_in[32]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[33]_i_1 
       (.I0(storage_data2[33]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[33]),
        .O(p_0_in[33]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[34]_i_1 
       (.I0(storage_data2[34]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[34]),
        .O(p_0_in[34]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[35]_i_1 
       (.I0(storage_data2[35]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[35]),
        .O(p_0_in[35]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[36]_i_1 
       (.I0(storage_data2[36]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[36]),
        .O(p_0_in[36]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[37]_i_1 
       (.I0(storage_data2[37]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[37]),
        .O(p_0_in[37]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[38]_i_1 
       (.I0(storage_data2[38]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[38]),
        .O(p_0_in[38]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[39]_i_1 
       (.I0(storage_data2[39]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[39]),
        .O(p_0_in[39]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[3]_i_1 
       (.I0(storage_data2[3]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[3]),
        .O(p_0_in[3]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[40]_i_1 
       (.I0(storage_data2[40]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[40]),
        .O(p_0_in[40]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[41]_i_1 
       (.I0(storage_data2[41]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[41]),
        .O(p_0_in[41]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[42]_i_1 
       (.I0(storage_data2[42]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[42]),
        .O(p_0_in[42]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[43]_i_1 
       (.I0(storage_data2[43]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[43]),
        .O(p_0_in[43]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[44]_i_1 
       (.I0(storage_data2[44]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[44]),
        .O(p_0_in[44]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[45]_i_1 
       (.I0(storage_data2[45]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[45]),
        .O(p_0_in[45]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[46]_i_1 
       (.I0(storage_data2[46]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[46]),
        .O(p_0_in[46]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[47]_i_1 
       (.I0(storage_data2[47]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[47]),
        .O(p_0_in[47]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[48]_i_1 
       (.I0(storage_data2[48]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[48]),
        .O(p_0_in[48]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[49]_i_1 
       (.I0(storage_data2[49]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[49]),
        .O(p_0_in[49]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[4]_i_1 
       (.I0(storage_data2[4]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[4]),
        .O(p_0_in[4]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[50]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[50]),
        .I2(Q),
        .I3(s_axis_tdata[50]),
        .O(p_0_in[50]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[51]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[51]),
        .I2(Q),
        .I3(s_axis_tdata[51]),
        .O(p_0_in[51]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[52]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[52]),
        .I2(Q),
        .I3(s_axis_tdata[52]),
        .O(p_0_in[52]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[53]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[53]),
        .I2(Q),
        .I3(s_axis_tdata[53]),
        .O(p_0_in[53]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[54]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[54]),
        .I2(Q),
        .I3(s_axis_tdata[54]),
        .O(p_0_in[54]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[55]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[55]),
        .I2(Q),
        .I3(s_axis_tdata[55]),
        .O(p_0_in[55]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[56]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[56]),
        .I2(Q),
        .I3(s_axis_tdata[56]),
        .O(p_0_in[56]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[57]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[57]),
        .I2(Q),
        .I3(s_axis_tdata[57]),
        .O(p_0_in[57]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[58]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[58]),
        .I2(Q),
        .I3(s_axis_tdata[58]),
        .O(p_0_in[58]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[59]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[59]),
        .I2(Q),
        .I3(s_axis_tdata[59]),
        .O(p_0_in[59]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[5]_i_1 
       (.I0(storage_data2[5]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[5]),
        .O(p_0_in[5]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[60]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[60]),
        .I2(Q),
        .I3(s_axis_tdata[60]),
        .O(p_0_in[60]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[61]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[61]),
        .I2(Q),
        .I3(s_axis_tdata[61]),
        .O(p_0_in[61]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[62]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[62]),
        .I2(Q),
        .I3(s_axis_tdata[62]),
        .O(p_0_in[62]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[63]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[63]),
        .I2(Q),
        .I3(s_axis_tdata[63]),
        .O(p_0_in[63]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[64]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[64]),
        .I2(Q),
        .I3(s_axis_tdata[64]),
        .O(p_0_in[64]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[65]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[65]),
        .I2(Q),
        .I3(s_axis_tdata[65]),
        .O(p_0_in[65]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[66]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[66]),
        .I2(Q),
        .I3(s_axis_tdata[66]),
        .O(p_0_in[66]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[67]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[67]),
        .I2(Q),
        .I3(s_axis_tdata[67]),
        .O(p_0_in[67]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[68]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[68]),
        .I2(Q),
        .I3(s_axis_tdata[68]),
        .O(p_0_in[68]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[69]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[69]),
        .I2(Q),
        .I3(s_axis_tdata[69]),
        .O(p_0_in[69]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[6]_i_1 
       (.I0(storage_data2[6]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[6]),
        .O(p_0_in[6]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[70]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[70]),
        .I2(Q),
        .I3(s_axis_tdata[70]),
        .O(p_0_in[70]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[71]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[71]),
        .I2(Q),
        .I3(s_axis_tdata[71]),
        .O(p_0_in[71]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[72]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[72]),
        .I2(Q),
        .I3(s_axis_tdata[72]),
        .O(p_0_in[72]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[73]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[73]),
        .I2(Q),
        .I3(s_axis_tdata[73]),
        .O(p_0_in[73]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[74]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[74]),
        .I2(Q),
        .I3(s_axis_tdata[74]),
        .O(p_0_in[74]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[75]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[75]),
        .I2(Q),
        .I3(s_axis_tdata[75]),
        .O(p_0_in[75]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[76]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[76]),
        .I2(Q),
        .I3(s_axis_tdata[76]),
        .O(p_0_in[76]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[77]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[77]),
        .I2(Q),
        .I3(s_axis_tdata[77]),
        .O(p_0_in[77]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[78]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[78]),
        .I2(Q),
        .I3(s_axis_tdata[78]),
        .O(p_0_in[78]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[79]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[79]),
        .I2(Q),
        .I3(s_axis_tdata[79]),
        .O(p_0_in[79]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[7]_i_1 
       (.I0(storage_data2[7]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[7]),
        .O(p_0_in[7]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[80]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[80]),
        .I2(Q),
        .I3(s_axis_tdata[80]),
        .O(p_0_in[80]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[81]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[81]),
        .I2(Q),
        .I3(s_axis_tdata[81]),
        .O(p_0_in[81]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[82]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[82]),
        .I2(Q),
        .I3(s_axis_tdata[82]),
        .O(p_0_in[82]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[83]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[83]),
        .I2(Q),
        .I3(s_axis_tdata[83]),
        .O(p_0_in[83]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[84]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[84]),
        .I2(Q),
        .I3(s_axis_tdata[84]),
        .O(p_0_in[84]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[85]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[85]),
        .I2(Q),
        .I3(s_axis_tdata[85]),
        .O(p_0_in[85]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[86]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[86]),
        .I2(Q),
        .I3(s_axis_tdata[86]),
        .O(p_0_in[86]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[87]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[87]),
        .I2(Q),
        .I3(s_axis_tdata[87]),
        .O(p_0_in[87]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[88]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[88]),
        .I2(Q),
        .I3(s_axis_tdata[88]),
        .O(p_0_in[88]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[89]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[89]),
        .I2(Q),
        .I3(s_axis_tdata[89]),
        .O(p_0_in[89]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[8]_i_1 
       (.I0(storage_data2[8]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[8]),
        .O(p_0_in[8]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[90]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[90]),
        .I2(Q),
        .I3(s_axis_tdata[90]),
        .O(p_0_in[90]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[91]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[91]),
        .I2(Q),
        .I3(s_axis_tdata[91]),
        .O(p_0_in[91]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[92]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[92]),
        .I2(Q),
        .I3(s_axis_tdata[92]),
        .O(p_0_in[92]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[93]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[93]),
        .I2(Q),
        .I3(s_axis_tdata[93]),
        .O(p_0_in[93]));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[94]_i_1 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[94]),
        .I2(Q),
        .I3(s_axis_tdata[94]),
        .O(p_0_in[94]));
  LUT4 #(
    .INIT(16'hB088)) 
    \storage_data1[95]_i_1 
       (.I0(m_axis_tready),
        .I1(Q),
        .I2(s_axis_tvalid),
        .I3(\state_reg_n_0_[1] ),
        .O(storage_data1));
  LUT4 #(
    .INIT(16'hEF40)) 
    \storage_data1[95]_i_2 
       (.I0(\state_reg_n_0_[1] ),
        .I1(storage_data2[95]),
        .I2(Q),
        .I3(s_axis_tdata[95]),
        .O(p_0_in[95]));
  LUT4 #(
    .INIT(16'hEF20)) 
    \storage_data1[9]_i_1 
       (.I0(storage_data2[9]),
        .I1(\state_reg_n_0_[1] ),
        .I2(Q),
        .I3(s_axis_tdata[9]),
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
  FDRE \storage_data1_reg[16] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[16]),
        .Q(m_axis_tdata[16]),
        .R(1'b0));
  FDRE \storage_data1_reg[17] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[17]),
        .Q(m_axis_tdata[17]),
        .R(1'b0));
  FDRE \storage_data1_reg[18] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[18]),
        .Q(m_axis_tdata[18]),
        .R(1'b0));
  FDRE \storage_data1_reg[19] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[19]),
        .Q(m_axis_tdata[19]),
        .R(1'b0));
  FDRE \storage_data1_reg[1] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[1]),
        .Q(m_axis_tdata[1]),
        .R(1'b0));
  FDRE \storage_data1_reg[20] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[20]),
        .Q(m_axis_tdata[20]),
        .R(1'b0));
  FDRE \storage_data1_reg[21] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[21]),
        .Q(m_axis_tdata[21]),
        .R(1'b0));
  FDRE \storage_data1_reg[22] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[22]),
        .Q(m_axis_tdata[22]),
        .R(1'b0));
  FDRE \storage_data1_reg[23] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[23]),
        .Q(m_axis_tdata[23]),
        .R(1'b0));
  FDRE \storage_data1_reg[24] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[24]),
        .Q(m_axis_tdata[24]),
        .R(1'b0));
  FDRE \storage_data1_reg[25] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[25]),
        .Q(m_axis_tdata[25]),
        .R(1'b0));
  FDRE \storage_data1_reg[26] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[26]),
        .Q(m_axis_tdata[26]),
        .R(1'b0));
  FDRE \storage_data1_reg[27] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[27]),
        .Q(m_axis_tdata[27]),
        .R(1'b0));
  FDRE \storage_data1_reg[28] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[28]),
        .Q(m_axis_tdata[28]),
        .R(1'b0));
  FDRE \storage_data1_reg[29] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[29]),
        .Q(m_axis_tdata[29]),
        .R(1'b0));
  FDRE \storage_data1_reg[2] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[2]),
        .Q(m_axis_tdata[2]),
        .R(1'b0));
  FDRE \storage_data1_reg[30] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[30]),
        .Q(m_axis_tdata[30]),
        .R(1'b0));
  FDRE \storage_data1_reg[31] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[31]),
        .Q(m_axis_tdata[31]),
        .R(1'b0));
  FDRE \storage_data1_reg[32] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[32]),
        .Q(m_axis_tdata[32]),
        .R(1'b0));
  FDRE \storage_data1_reg[33] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[33]),
        .Q(m_axis_tdata[33]),
        .R(1'b0));
  FDRE \storage_data1_reg[34] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[34]),
        .Q(m_axis_tdata[34]),
        .R(1'b0));
  FDRE \storage_data1_reg[35] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[35]),
        .Q(m_axis_tdata[35]),
        .R(1'b0));
  FDRE \storage_data1_reg[36] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[36]),
        .Q(m_axis_tdata[36]),
        .R(1'b0));
  FDRE \storage_data1_reg[37] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[37]),
        .Q(m_axis_tdata[37]),
        .R(1'b0));
  FDRE \storage_data1_reg[38] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[38]),
        .Q(m_axis_tdata[38]),
        .R(1'b0));
  FDRE \storage_data1_reg[39] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[39]),
        .Q(m_axis_tdata[39]),
        .R(1'b0));
  FDRE \storage_data1_reg[3] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[3]),
        .Q(m_axis_tdata[3]),
        .R(1'b0));
  FDRE \storage_data1_reg[40] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[40]),
        .Q(m_axis_tdata[40]),
        .R(1'b0));
  FDRE \storage_data1_reg[41] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[41]),
        .Q(m_axis_tdata[41]),
        .R(1'b0));
  FDRE \storage_data1_reg[42] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[42]),
        .Q(m_axis_tdata[42]),
        .R(1'b0));
  FDRE \storage_data1_reg[43] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[43]),
        .Q(m_axis_tdata[43]),
        .R(1'b0));
  FDRE \storage_data1_reg[44] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[44]),
        .Q(m_axis_tdata[44]),
        .R(1'b0));
  FDRE \storage_data1_reg[45] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[45]),
        .Q(m_axis_tdata[45]),
        .R(1'b0));
  FDRE \storage_data1_reg[46] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[46]),
        .Q(m_axis_tdata[46]),
        .R(1'b0));
  FDRE \storage_data1_reg[47] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[47]),
        .Q(m_axis_tdata[47]),
        .R(1'b0));
  FDRE \storage_data1_reg[48] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[48]),
        .Q(m_axis_tdata[48]),
        .R(1'b0));
  FDRE \storage_data1_reg[49] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[49]),
        .Q(m_axis_tdata[49]),
        .R(1'b0));
  FDRE \storage_data1_reg[4] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[4]),
        .Q(m_axis_tdata[4]),
        .R(1'b0));
  FDRE \storage_data1_reg[50] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[50]),
        .Q(m_axis_tdata[50]),
        .R(1'b0));
  FDRE \storage_data1_reg[51] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[51]),
        .Q(m_axis_tdata[51]),
        .R(1'b0));
  FDRE \storage_data1_reg[52] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[52]),
        .Q(m_axis_tdata[52]),
        .R(1'b0));
  FDRE \storage_data1_reg[53] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[53]),
        .Q(m_axis_tdata[53]),
        .R(1'b0));
  FDRE \storage_data1_reg[54] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[54]),
        .Q(m_axis_tdata[54]),
        .R(1'b0));
  FDRE \storage_data1_reg[55] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[55]),
        .Q(m_axis_tdata[55]),
        .R(1'b0));
  FDRE \storage_data1_reg[56] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[56]),
        .Q(m_axis_tdata[56]),
        .R(1'b0));
  FDRE \storage_data1_reg[57] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[57]),
        .Q(m_axis_tdata[57]),
        .R(1'b0));
  FDRE \storage_data1_reg[58] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[58]),
        .Q(m_axis_tdata[58]),
        .R(1'b0));
  FDRE \storage_data1_reg[59] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[59]),
        .Q(m_axis_tdata[59]),
        .R(1'b0));
  FDRE \storage_data1_reg[5] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[5]),
        .Q(m_axis_tdata[5]),
        .R(1'b0));
  FDRE \storage_data1_reg[60] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[60]),
        .Q(m_axis_tdata[60]),
        .R(1'b0));
  FDRE \storage_data1_reg[61] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[61]),
        .Q(m_axis_tdata[61]),
        .R(1'b0));
  FDRE \storage_data1_reg[62] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[62]),
        .Q(m_axis_tdata[62]),
        .R(1'b0));
  FDRE \storage_data1_reg[63] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[63]),
        .Q(m_axis_tdata[63]),
        .R(1'b0));
  FDRE \storage_data1_reg[64] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[64]),
        .Q(m_axis_tdata[64]),
        .R(1'b0));
  FDRE \storage_data1_reg[65] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[65]),
        .Q(m_axis_tdata[65]),
        .R(1'b0));
  FDRE \storage_data1_reg[66] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[66]),
        .Q(m_axis_tdata[66]),
        .R(1'b0));
  FDRE \storage_data1_reg[67] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[67]),
        .Q(m_axis_tdata[67]),
        .R(1'b0));
  FDRE \storage_data1_reg[68] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[68]),
        .Q(m_axis_tdata[68]),
        .R(1'b0));
  FDRE \storage_data1_reg[69] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[69]),
        .Q(m_axis_tdata[69]),
        .R(1'b0));
  FDRE \storage_data1_reg[6] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[6]),
        .Q(m_axis_tdata[6]),
        .R(1'b0));
  FDRE \storage_data1_reg[70] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[70]),
        .Q(m_axis_tdata[70]),
        .R(1'b0));
  FDRE \storage_data1_reg[71] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[71]),
        .Q(m_axis_tdata[71]),
        .R(1'b0));
  FDRE \storage_data1_reg[72] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[72]),
        .Q(m_axis_tdata[72]),
        .R(1'b0));
  FDRE \storage_data1_reg[73] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[73]),
        .Q(m_axis_tdata[73]),
        .R(1'b0));
  FDRE \storage_data1_reg[74] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[74]),
        .Q(m_axis_tdata[74]),
        .R(1'b0));
  FDRE \storage_data1_reg[75] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[75]),
        .Q(m_axis_tdata[75]),
        .R(1'b0));
  FDRE \storage_data1_reg[76] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[76]),
        .Q(m_axis_tdata[76]),
        .R(1'b0));
  FDRE \storage_data1_reg[77] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[77]),
        .Q(m_axis_tdata[77]),
        .R(1'b0));
  FDRE \storage_data1_reg[78] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[78]),
        .Q(m_axis_tdata[78]),
        .R(1'b0));
  FDRE \storage_data1_reg[79] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[79]),
        .Q(m_axis_tdata[79]),
        .R(1'b0));
  FDRE \storage_data1_reg[7] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[7]),
        .Q(m_axis_tdata[7]),
        .R(1'b0));
  FDRE \storage_data1_reg[80] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[80]),
        .Q(m_axis_tdata[80]),
        .R(1'b0));
  FDRE \storage_data1_reg[81] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[81]),
        .Q(m_axis_tdata[81]),
        .R(1'b0));
  FDRE \storage_data1_reg[82] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[82]),
        .Q(m_axis_tdata[82]),
        .R(1'b0));
  FDRE \storage_data1_reg[83] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[83]),
        .Q(m_axis_tdata[83]),
        .R(1'b0));
  FDRE \storage_data1_reg[84] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[84]),
        .Q(m_axis_tdata[84]),
        .R(1'b0));
  FDRE \storage_data1_reg[85] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[85]),
        .Q(m_axis_tdata[85]),
        .R(1'b0));
  FDRE \storage_data1_reg[86] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[86]),
        .Q(m_axis_tdata[86]),
        .R(1'b0));
  FDRE \storage_data1_reg[87] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[87]),
        .Q(m_axis_tdata[87]),
        .R(1'b0));
  FDRE \storage_data1_reg[88] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[88]),
        .Q(m_axis_tdata[88]),
        .R(1'b0));
  FDRE \storage_data1_reg[89] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[89]),
        .Q(m_axis_tdata[89]),
        .R(1'b0));
  FDRE \storage_data1_reg[8] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[8]),
        .Q(m_axis_tdata[8]),
        .R(1'b0));
  FDRE \storage_data1_reg[90] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[90]),
        .Q(m_axis_tdata[90]),
        .R(1'b0));
  FDRE \storage_data1_reg[91] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[91]),
        .Q(m_axis_tdata[91]),
        .R(1'b0));
  FDRE \storage_data1_reg[92] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[92]),
        .Q(m_axis_tdata[92]),
        .R(1'b0));
  FDRE \storage_data1_reg[93] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[93]),
        .Q(m_axis_tdata[93]),
        .R(1'b0));
  FDRE \storage_data1_reg[94] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[94]),
        .Q(m_axis_tdata[94]),
        .R(1'b0));
  FDRE \storage_data1_reg[95] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[95]),
        .Q(m_axis_tdata[95]),
        .R(1'b0));
  FDRE \storage_data1_reg[9] 
       (.C(aclk),
        .CE(storage_data1),
        .D(p_0_in[9]),
        .Q(m_axis_tdata[9]),
        .R(1'b0));
  LUT2 #(
    .INIT(4'h8)) 
    \storage_data2[95]_i_1 
       (.I0(s_axis_tready),
        .I1(s_axis_tvalid),
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
  FDRE \storage_data2_reg[16] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[16]),
        .Q(storage_data2[16]),
        .R(1'b0));
  FDRE \storage_data2_reg[17] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[17]),
        .Q(storage_data2[17]),
        .R(1'b0));
  FDRE \storage_data2_reg[18] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[18]),
        .Q(storage_data2[18]),
        .R(1'b0));
  FDRE \storage_data2_reg[19] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[19]),
        .Q(storage_data2[19]),
        .R(1'b0));
  FDRE \storage_data2_reg[1] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[1]),
        .Q(storage_data2[1]),
        .R(1'b0));
  FDRE \storage_data2_reg[20] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[20]),
        .Q(storage_data2[20]),
        .R(1'b0));
  FDRE \storage_data2_reg[21] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[21]),
        .Q(storage_data2[21]),
        .R(1'b0));
  FDRE \storage_data2_reg[22] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[22]),
        .Q(storage_data2[22]),
        .R(1'b0));
  FDRE \storage_data2_reg[23] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[23]),
        .Q(storage_data2[23]),
        .R(1'b0));
  FDRE \storage_data2_reg[24] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[24]),
        .Q(storage_data2[24]),
        .R(1'b0));
  FDRE \storage_data2_reg[25] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[25]),
        .Q(storage_data2[25]),
        .R(1'b0));
  FDRE \storage_data2_reg[26] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[26]),
        .Q(storage_data2[26]),
        .R(1'b0));
  FDRE \storage_data2_reg[27] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[27]),
        .Q(storage_data2[27]),
        .R(1'b0));
  FDRE \storage_data2_reg[28] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[28]),
        .Q(storage_data2[28]),
        .R(1'b0));
  FDRE \storage_data2_reg[29] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[29]),
        .Q(storage_data2[29]),
        .R(1'b0));
  FDRE \storage_data2_reg[2] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[2]),
        .Q(storage_data2[2]),
        .R(1'b0));
  FDRE \storage_data2_reg[30] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[30]),
        .Q(storage_data2[30]),
        .R(1'b0));
  FDRE \storage_data2_reg[31] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[31]),
        .Q(storage_data2[31]),
        .R(1'b0));
  FDRE \storage_data2_reg[32] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[32]),
        .Q(storage_data2[32]),
        .R(1'b0));
  FDRE \storage_data2_reg[33] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[33]),
        .Q(storage_data2[33]),
        .R(1'b0));
  FDRE \storage_data2_reg[34] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[34]),
        .Q(storage_data2[34]),
        .R(1'b0));
  FDRE \storage_data2_reg[35] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[35]),
        .Q(storage_data2[35]),
        .R(1'b0));
  FDRE \storage_data2_reg[36] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[36]),
        .Q(storage_data2[36]),
        .R(1'b0));
  FDRE \storage_data2_reg[37] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[37]),
        .Q(storage_data2[37]),
        .R(1'b0));
  FDRE \storage_data2_reg[38] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[38]),
        .Q(storage_data2[38]),
        .R(1'b0));
  FDRE \storage_data2_reg[39] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[39]),
        .Q(storage_data2[39]),
        .R(1'b0));
  FDRE \storage_data2_reg[3] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[3]),
        .Q(storage_data2[3]),
        .R(1'b0));
  FDRE \storage_data2_reg[40] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[40]),
        .Q(storage_data2[40]),
        .R(1'b0));
  FDRE \storage_data2_reg[41] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[41]),
        .Q(storage_data2[41]),
        .R(1'b0));
  FDRE \storage_data2_reg[42] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[42]),
        .Q(storage_data2[42]),
        .R(1'b0));
  FDRE \storage_data2_reg[43] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[43]),
        .Q(storage_data2[43]),
        .R(1'b0));
  FDRE \storage_data2_reg[44] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[44]),
        .Q(storage_data2[44]),
        .R(1'b0));
  FDRE \storage_data2_reg[45] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[45]),
        .Q(storage_data2[45]),
        .R(1'b0));
  FDRE \storage_data2_reg[46] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[46]),
        .Q(storage_data2[46]),
        .R(1'b0));
  FDRE \storage_data2_reg[47] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[47]),
        .Q(storage_data2[47]),
        .R(1'b0));
  FDRE \storage_data2_reg[48] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[48]),
        .Q(storage_data2[48]),
        .R(1'b0));
  FDRE \storage_data2_reg[49] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[49]),
        .Q(storage_data2[49]),
        .R(1'b0));
  FDRE \storage_data2_reg[4] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[4]),
        .Q(storage_data2[4]),
        .R(1'b0));
  FDRE \storage_data2_reg[50] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[50]),
        .Q(storage_data2[50]),
        .R(1'b0));
  FDRE \storage_data2_reg[51] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[51]),
        .Q(storage_data2[51]),
        .R(1'b0));
  FDRE \storage_data2_reg[52] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[52]),
        .Q(storage_data2[52]),
        .R(1'b0));
  FDRE \storage_data2_reg[53] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[53]),
        .Q(storage_data2[53]),
        .R(1'b0));
  FDRE \storage_data2_reg[54] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[54]),
        .Q(storage_data2[54]),
        .R(1'b0));
  FDRE \storage_data2_reg[55] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[55]),
        .Q(storage_data2[55]),
        .R(1'b0));
  FDRE \storage_data2_reg[56] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[56]),
        .Q(storage_data2[56]),
        .R(1'b0));
  FDRE \storage_data2_reg[57] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[57]),
        .Q(storage_data2[57]),
        .R(1'b0));
  FDRE \storage_data2_reg[58] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[58]),
        .Q(storage_data2[58]),
        .R(1'b0));
  FDRE \storage_data2_reg[59] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[59]),
        .Q(storage_data2[59]),
        .R(1'b0));
  FDRE \storage_data2_reg[5] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[5]),
        .Q(storage_data2[5]),
        .R(1'b0));
  FDRE \storage_data2_reg[60] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[60]),
        .Q(storage_data2[60]),
        .R(1'b0));
  FDRE \storage_data2_reg[61] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[61]),
        .Q(storage_data2[61]),
        .R(1'b0));
  FDRE \storage_data2_reg[62] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[62]),
        .Q(storage_data2[62]),
        .R(1'b0));
  FDRE \storage_data2_reg[63] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[63]),
        .Q(storage_data2[63]),
        .R(1'b0));
  FDRE \storage_data2_reg[64] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[64]),
        .Q(storage_data2[64]),
        .R(1'b0));
  FDRE \storage_data2_reg[65] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[65]),
        .Q(storage_data2[65]),
        .R(1'b0));
  FDRE \storage_data2_reg[66] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[66]),
        .Q(storage_data2[66]),
        .R(1'b0));
  FDRE \storage_data2_reg[67] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[67]),
        .Q(storage_data2[67]),
        .R(1'b0));
  FDRE \storage_data2_reg[68] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[68]),
        .Q(storage_data2[68]),
        .R(1'b0));
  FDRE \storage_data2_reg[69] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[69]),
        .Q(storage_data2[69]),
        .R(1'b0));
  FDRE \storage_data2_reg[6] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[6]),
        .Q(storage_data2[6]),
        .R(1'b0));
  FDRE \storage_data2_reg[70] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[70]),
        .Q(storage_data2[70]),
        .R(1'b0));
  FDRE \storage_data2_reg[71] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[71]),
        .Q(storage_data2[71]),
        .R(1'b0));
  FDRE \storage_data2_reg[72] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[72]),
        .Q(storage_data2[72]),
        .R(1'b0));
  FDRE \storage_data2_reg[73] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[73]),
        .Q(storage_data2[73]),
        .R(1'b0));
  FDRE \storage_data2_reg[74] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[74]),
        .Q(storage_data2[74]),
        .R(1'b0));
  FDRE \storage_data2_reg[75] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[75]),
        .Q(storage_data2[75]),
        .R(1'b0));
  FDRE \storage_data2_reg[76] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[76]),
        .Q(storage_data2[76]),
        .R(1'b0));
  FDRE \storage_data2_reg[77] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[77]),
        .Q(storage_data2[77]),
        .R(1'b0));
  FDRE \storage_data2_reg[78] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[78]),
        .Q(storage_data2[78]),
        .R(1'b0));
  FDRE \storage_data2_reg[79] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[79]),
        .Q(storage_data2[79]),
        .R(1'b0));
  FDRE \storage_data2_reg[7] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[7]),
        .Q(storage_data2[7]),
        .R(1'b0));
  FDRE \storage_data2_reg[80] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[80]),
        .Q(storage_data2[80]),
        .R(1'b0));
  FDRE \storage_data2_reg[81] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[81]),
        .Q(storage_data2[81]),
        .R(1'b0));
  FDRE \storage_data2_reg[82] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[82]),
        .Q(storage_data2[82]),
        .R(1'b0));
  FDRE \storage_data2_reg[83] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[83]),
        .Q(storage_data2[83]),
        .R(1'b0));
  FDRE \storage_data2_reg[84] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[84]),
        .Q(storage_data2[84]),
        .R(1'b0));
  FDRE \storage_data2_reg[85] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[85]),
        .Q(storage_data2[85]),
        .R(1'b0));
  FDRE \storage_data2_reg[86] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[86]),
        .Q(storage_data2[86]),
        .R(1'b0));
  FDRE \storage_data2_reg[87] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[87]),
        .Q(storage_data2[87]),
        .R(1'b0));
  FDRE \storage_data2_reg[88] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[88]),
        .Q(storage_data2[88]),
        .R(1'b0));
  FDRE \storage_data2_reg[89] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[89]),
        .Q(storage_data2[89]),
        .R(1'b0));
  FDRE \storage_data2_reg[8] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[8]),
        .Q(storage_data2[8]),
        .R(1'b0));
  FDRE \storage_data2_reg[90] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[90]),
        .Q(storage_data2[90]),
        .R(1'b0));
  FDRE \storage_data2_reg[91] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[91]),
        .Q(storage_data2[91]),
        .R(1'b0));
  FDRE \storage_data2_reg[92] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[92]),
        .Q(storage_data2[92]),
        .R(1'b0));
  FDRE \storage_data2_reg[93] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[93]),
        .Q(storage_data2[93]),
        .R(1'b0));
  FDRE \storage_data2_reg[94] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[94]),
        .Q(storage_data2[94]),
        .R(1'b0));
  FDRE \storage_data2_reg[95] 
       (.C(aclk),
        .CE(storage_data2_0),
        .D(s_axis_tdata[95]),
        .Q(storage_data2[95]),
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
