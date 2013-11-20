action = "simulation"
target = "xilinx"

modules = {"local" : "../../../.." }

files = [ "wb_bpm_swap_tb.v",
          "timescale.v",
          "defines.v"
         ];

vlog_opt = "-i ../../../../sim/regs -i ../../../../sim"


