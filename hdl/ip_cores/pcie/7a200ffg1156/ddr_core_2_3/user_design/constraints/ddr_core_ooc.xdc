###################################################################################################
## This constraints file contains default clock frequencies to be used during creation of a 
## Synthesis Design Checkpoint (DCP). For best results the frequencies should be modified 
## to match the target frequencies. 
## This constraints file is not used in top-down/global synthesis (not the default flow of Vivado).
###################################################################################################


##################################################################################################
## 
##  Xilinx, Inc. 2010            www.xilinx.com 
##  sáb fev 21 11:40:05 2015
##  Generated by MIG Version 2.3
##  
##################################################################################################
##  File name :       ddr_core.xdc
##  Details :     Constraints file
##                    FPGA Family:       ARTIX7
##                    FPGA Part:         XC7A200T-FFG1156
##                    Speedgrade:        -1
##                    Design Entry:      VHDL
##                    Frequency:         0 MHz
##                    Time Period:       2500 ps
##################################################################################################

##################################################################################################
## Controller 0
## Memory Device: DDR3_SDRAM->Components->MT41J512M8XX-125
## Data Width: 32
## Time Period: 2500
## Data Mask: 1
##################################################################################################

create_clock -period -2.14748e+06 [get_ports sys_clk_i]
set_propagated_clock sys_clk_i
          