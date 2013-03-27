action = "simulation"
target = "xilinx"

modules = {"local" : "../../../.." }
files = ["wb_fmc516_tb.v", "defines.v", "timescale.v",
			"clk_rst.v"]

vlog_opt = "-i ../../../../sim/regs -i ../../../../sim"
