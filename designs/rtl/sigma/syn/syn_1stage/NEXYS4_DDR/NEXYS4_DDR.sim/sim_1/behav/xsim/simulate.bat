@echo off
REM ****************************************************************************
REM Vivado (TM) v2019.1 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Wed Oct 04 23:05:42 +0300 2023
REM SW Build 2552052 on Fri May 24 14:49:42 MDT 2019
REM
REM Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
echo "xsim riscv_tb_behav -key {Behavioral:sim_1:Functional:riscv_tb} -tclbatch riscv_tb.tcl -view E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/riscv_tb_behav1.wcfg -log simulate.log"
call xsim  riscv_tb_behav -key {Behavioral:sim_1:Functional:riscv_tb} -tclbatch riscv_tb.tcl -view E:/ITMO/Vivado/activecore/activecore-master/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/riscv_tb_behav1.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
