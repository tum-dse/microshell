#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/share/xilinx/Vitis/2022.1/bin:/share/xilinx/Vivado/2022.1/ids_lite/ISE/bin/lin64:/share/xilinx/Vivado/2022.1/bin
else
  PATH=/share/xilinx/Vitis/2022.1/bin:/share/xilinx/Vivado/2022.1/ids_lite/ISE/bin/lin64:/share/xilinx/Vivado/2022.1/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/scratch/anubhav/Coyote/examples_hw/build_hw_8/test_shell/test.runs/axis_data_fifo_128_tlb_synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log axis_data_fifo_128_tlb.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source axis_data_fifo_128_tlb.tcl
