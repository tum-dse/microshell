// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (lin64) Build 3526262 Mon Apr 18 15:47:01 MDT 2022
// Date        : Wed Nov 27 16:23:40 2024
// Host        : amy running 64-bit NixOS 24.05 (Uakari)
// Command     : write_verilog -force -mode funcsim
//               /scratch/anubhav/Coyote/examples_hw/build_hw_8/test_shell/test.gen/sources_1/ip/debug_bridge_dynamic/bd_0/ip/ip_1/bd_2f3d_lut_buffer_0_sim_netlist.v
// Design      : bd_2f3d_lut_buffer_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xcu280-fsvh2892-2L-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "bd_2f3d_lut_buffer_0,lut_buffer_v2_0_0_lut_buffer,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* X_CORE_INFO = "lut_buffer_v2_0_0_lut_buffer,Vivado 2022.1" *) 
(* NotValidForBitStream *)
module bd_2f3d_lut_buffer_0
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
  bd_2f3d_lut_buffer_0_lut_buffer_v2_0_0_lut_buffer inst
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
G3jNnwrmSpznvfbAauWN9mS81jEfWj+2RqVYFw==
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
