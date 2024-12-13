// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (lin64) Build 3526262 Mon Apr 18 15:47:01 MDT 2022
// Date        : Wed Nov 27 16:33:17 2024
// Host        : amy running 64-bit NixOS 24.05 (Uakari)
// Command     : write_verilog -force -mode funcsim
//               /scratch/anubhav/Coyote/examples_hw/build_hw_8/test_config_0/user_c0_0/test.gen/sources_1/ip/debug_bridge_user/bd_0/ip/ip_1/bd_4611_lut_buffer_0_sim_netlist.v
// Design      : bd_4611_lut_buffer_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xcu280-fsvh2892-2L-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "bd_4611_lut_buffer_0,lut_buffer_v2_0_0_lut_buffer,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* X_CORE_INFO = "lut_buffer_v2_0_0_lut_buffer,Vivado 2022.1" *) 
(* NotValidForBitStream *)
module bd_4611_lut_buffer_0
   (tdi_i,
    tms_i,
    tck_i,
    drck_i,
    sel_i,
    shift_i,
    update_i,
    capture_i,
    runtest_i,
    reset_i,
    bscanid_en_i,
    tdo_o,
    tdi_o,
    tms_o,
    tck_o,
    drck_o,
    sel_o,
    shift_o,
    update_o,
    capture_o,
    runtest_o,
    reset_o,
    bscanid_en_o,
    tdo_i);
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 s_bscan TDI" *) input tdi_i;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 s_bscan TMS" *) input tms_i;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 s_bscan TCK" *) input tck_i;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 s_bscan DRCK" *) input drck_i;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 s_bscan SEL" *) input sel_i;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 s_bscan SHIFT" *) input shift_i;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 s_bscan UPDATE" *) input update_i;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 s_bscan CAPTURE" *) input capture_i;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 s_bscan RUNTEST" *) input runtest_i;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 s_bscan RESET" *) input reset_i;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 s_bscan BSCANID_EN" *) input bscanid_en_i;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 s_bscan TDO" *) output tdo_o;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 m_bscan TDI" *) output tdi_o;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 m_bscan TMS" *) output tms_o;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 m_bscan TCK" *) output tck_o;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 m_bscan DRCK" *) output drck_o;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 m_bscan SEL" *) output sel_o;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 m_bscan SHIFT" *) output shift_o;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 m_bscan UPDATE" *) output update_o;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 m_bscan CAPTURE" *) output capture_o;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 m_bscan RUNTEST" *) output runtest_o;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 m_bscan RESET" *) output reset_o;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 m_bscan BSCANID_EN" *) output bscanid_en_o;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bscan:1.0 m_bscan TDO" *) input tdo_i;

  wire bscanid_en_i;
  wire bscanid_en_o;
  wire capture_i;
  wire capture_o;
  wire drck_i;
  wire drck_o;
  wire reset_i;
  wire reset_o;
  wire runtest_i;
  wire runtest_o;
  wire sel_i;
  wire sel_o;
  wire shift_i;
  wire shift_o;
  wire tck_i;
  wire tck_o;
  wire tdi_i;
  wire tdi_o;
  wire tdo_i;
  wire tdo_o;
  wire tms_i;
  wire tms_o;
  wire update_i;
  wire update_o;
  wire [31:0]NLW_inst_bscanid_o_UNCONNECTED;

  (* C_EN_BSCANID_VEC = "0" *) 
  (* DONT_TOUCH *) 
  (* KEEP_HIERARCHY = "soft" *) 
  (* is_du_within_envelope = "true" *) 
  bd_4611_lut_buffer_0_lut_buffer_v2_0_0_lut_buffer inst
       (.bscanid_en_i(bscanid_en_i),
        .bscanid_en_o(bscanid_en_o),
        .bscanid_i({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .bscanid_o(NLW_inst_bscanid_o_UNCONNECTED[31:0]),
        .capture_i(capture_i),
        .capture_o(capture_o),
        .drck_i(drck_i),
        .drck_o(drck_o),
        .reset_i(reset_i),
        .reset_o(reset_o),
        .runtest_i(runtest_i),
        .runtest_o(runtest_o),
        .sel_i(sel_i),
        .sel_o(sel_o),
        .shift_i(shift_i),
        .shift_o(shift_o),
        .tck_i(tck_i),
        .tck_o(tck_o),
        .tdi_i(tdi_i),
        .tdi_o(tdi_o),
        .tdo_i(tdo_i),
        .tdo_o(tdo_o),
        .tms_i(tms_i),
        .tms_o(tms_o),
        .update_i(update_i),
        .update_o(update_o));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2022.1"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
f1j0yiOflyV2kLMBe+hsL0MouEX0Wv67RiMU1n4QYTAQ1VnAgpLBrFb17v/9GYVLUPddIDNOGPRZ
u2WV424zInW/Vmf6dhRXe1SsADWvbW7FiGPDw4jSrHnTNCEJCn+cfjSxhjMmAkuHG1fir3l+gxGz
L/X05RxFmZ2QL5UIwRk=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
0i7KENkA2NQO3GXaWrbdCJnWHApRZRcJ0tLb3D4baBRVZkAd2BJDMxoSUwnRKToSUEazPqGR4ywK
WqTfdpMetoN7s7CYXDjMoygLqtE11hWxTqG3rxD4MHY+oxhHIbr0ICQdK58tH2gBIeD4Y8rjtc1M
L01bGVrzL348HIiDA0SPDZYJeem4+87SeBTvZP3vuJPPdCuxDmudnIAXnqy6CGab6C9RgMyi/LlF
L0I7jQB9ONBLqrj8KcUrPrduGmiyShXt/NwzRFGoTEY3E0lYXHgJkdReoCCCmYa5+FNOs18Qwno+
YkWOQhWFcPvWa4g6Y/ouRdk7jPEz/jq+GzkkPg==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
KNOVCEjQhCCxVJzUYfNJKAf2haBXTHL4u8VRnkMGr2AZ4CjhCD2LNR3uxAto+kgqlGvllYk6mDuX
ehYphfcWZHnD/uMO9Mlgm2xYmmqRUjk15bM5mfH+RhWUKFD6VRSygM9P06naXp5l6yAxCjsaJoia
sn/MOoxmT2wVf3n+Xdg=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
V2yPa0MI9WR304IOhrhuSQ9Ldvhw0yC0csbY2Yup99Z9agkgpsDjW+77nBHVwkwZmgUyfGSo0TK2
5+kz3fJgn/RD2oSYkSaBVXzvKItV8acak2gfA2kdbaCCDklOwfdWWqRGAWts/1Mg5clfcdwoNOZ1
m3ZVTEFXXRdnaVotagNm2zuupNsX/J509sWqJwxqY/tkapVzbizogJQlBDpHRmeI8Wy9MHgl+ez8
ErgBkS1v84iUGQ0VVXOdzfpn7Rr+JkKzknuKR21+imEMhw/nro+d3J6z9gL9sw/hot77/E45Wlv0
J6rMye1iHGBgTJ/ongJJ/bF2sU0UIep3jo3Ycw==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Gsa5eR6EJ+H0y0tfeQrSF62h+z9EjOrg9Nx7r8uw/ePJ78O1ebL7fqko1w5NXOXLbrE6GH0vB5PG
/sp4Ez/hK7CAozkTRRLKNpEiEjYs2xf/XWbCy8m7MjJL3tGVSrP4bCa5emQEsIcEi8ZXNnVw4khq
FTPzKuxstMIRAptl0GnPBlQC7elSuw6Li8Olj1CTQU7VlBFtuNyAt5Onc/FWt3H78x5rf4h+wZAC
rCL/7OKx01xqTpSd7s35OB0kE6C75KSwa0lxluUz3o07qQoZ1FuaWMdqLjSuwyBAqL97DAkcrtNs
SGDdpgTIT+dK7ICRArioBCEKt/kMjmL/uID0Hg==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
h+kjW5M8Dem541WFtDf09jjHpUR1/+CL7YNUyFmXM5qvgxmmSz2XXkwnCuEbvknqy0Yh9fpgPEtw
P8UmTkW5JrTQVdJEaqXXg5foMh4iNGQJirjH4SbGQ/YuI2eV97IrrEygr9Cs4lTCJJxvBYMzkZ8O
7k00rA51JoBJVpXt/5T5upbqQiFhJ6MU6avXSC4vezl93MB5UrxRfDP7E7q9m0W+xAcLwxYEwl4B
1E52gJSYNRV3KH5tXZTsXURVzpZ4rgpGuhnTqaRIbzdHDFBO5R2HLAM6qPpwH3iXqmCPpwhcuL/C
jBAzhuIZ3U12mvg6St28AxyWYwWi2IAz4uzfgg==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2021_07", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
dtmv56Ko4bFw0rY2VV0lIolvnvL8ZqJOHXaQX9ROldne6mUD/6S3uCZJeduFtssQ5PyvwzGhKGxi
7um7D/9xiCOrGpJTZ8BXDmmL9x6GCuNjAfNCfBGJsQEf6celtP5Wb+/KyqzKylMTmOn4jYDpwKnv
7aGYgDcY7bLQPstQJ1lqpnIzpsXokk2yfTXesH1TE5QAebLuUzMJkhjk+/0Png8FOhnM2GWK/nNN
tYDjJVOBtj/HBwhT/lFXucnPSnqCy/bh0ObsNNSD5sUoHhUk00KBNeDEdIGHT7MgOiRMEgRxIVBr
fE2b4uHkwE3B9zjQ5ayuPIdobQKIH9uajxa1Cw==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
nP7sH9m1/BWzEDOejD42H89YXpl36cWXtZO9mIisNlEpVUC6G6NkFQXuEvVhxWDlr/ANE2zhdLuk
pUjX5zCIatBQEjjG7DxiP93OzjAUtlcezRl2EdP8WONFhAXwbtW+FjwvaygqnYLOFuX1NySRVtIm
JnNXiZV1065+1Z3tuINtTEoj7vWpyiY6keja/lhk6y7N1vDfbpJnxwC8XF6qagRF2f3BSidj4gRD
kLvmVWetDWRwL3rbqsFqAryiMwdmn+bzBSuKJX0DvUZ9Mf5pfVjh6oeaUiV+N8VsCoGG4AYJMW6a
BDdl5Vq35R9zL+M25sLYEKaG07cYl0Exhxk6oVzhqw/+PO//HHdYa8S6U3zet2RHV0BUpC+IxVj6
r/daUxvI5ChIZKtIsApJvvJjybQUYIZz/lMNvxQY//moq88zjpwQ13CeVbxZA4cEo3LTdka/RIet
ScU9pHox1Y+im5MusVfpMJQNihowibveX0/XnfK1an+3HLXxA2daxGiD

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
gZo52SHmX+/9ltS9SXeTGQ5BAPUpW+A6ImhJo+12gKxivRKWEgEcZyBRgM7Hj6mtw9eEPmcH7UuO
9vD90A9QvItgrbujaZxLVL7i94ZAamx40/J5wjA0HPDTV75t68r0vy1qwPQ3sZeu6XwipquHvOWj
ujFI8+tIW+YWMlunpQwGZ3rGMizIBhMobkp1BGodxvf99yEznW3Oi9Y/TJINC1QCqR6JK9Z4AscZ
EZf7XVSb7dPw0bFtiw6ZaZQmyvhRQYrO8FiaZJj2P7cxrUIuDAEpK0DY1MdJ5NKVuNFFKweNyC3/
3oyciyDOZSr6a1Ow3A2imATmKbSnAKV6h9qoMg==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 2992)
`pragma protect data_block
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
LwgZOMGkt7I6sxZwyRWDRcMlZ3XLGLsWQuFMiA==
`pragma protect end_protected
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
