// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Sun Jun 27 01:01:26 2021
// Host        : DESKTOP-98BNIGG running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               D:/PROJECTS/PERSONAL/activecore/activecore/designs/rtl/sigma/syn/syn_4stage/NEXYS4-DDR/NEXYS4_DDR.runs/sys_clk_synth_1/sys_clk_stub.v
// Design      : sys_clk
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-3
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module sys_clk(clk_out1, reset, locked, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="clk_out1,reset,locked,clk_in1" */;
  output clk_out1;
  input reset;
  output locked;
  input clk_in1;
endmodule
