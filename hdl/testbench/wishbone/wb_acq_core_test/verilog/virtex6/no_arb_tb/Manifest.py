action = "simulation"
target = "xilinx"

modules = {"local" : ["../../../../../../",
                    "../../../../../../sim/ddr_model"]}

files = ["wb_acq_core_tb.v", "defines.v", "timescale.v",
			"clk_rst.v"]

vlog_opt = "+incdir+../../../../../../sim/regs +incdir+../../../../../../sim +incdir+../../../../../../sim/ddr_model"
