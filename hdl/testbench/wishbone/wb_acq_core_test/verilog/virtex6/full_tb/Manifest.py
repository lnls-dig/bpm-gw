action = "simulation"
target = "xilinx"
#syn_device = "xc7a200t"
syn_device = "xc6vlx240t"

modules = {"local" : ["../../../../../../modules/dbe_wishbone",
                    "../../../../../../modules/dbe_common",
                    "../../../../../../modules/rffe_top",
                    "../../../../../../modules/fabric",
                    "../../../../../../modules/fmc_adc_common",
                    "../../../../../../modules/pcie",
                    "../../../../../../ip_cores/general-cores",
                    "../../../../../../ip_cores/etherbone-core",
                    "../../../../../../platform/virtex6/chipscope",
                    "../../../../../../platform/virtex6/ip_cores",
                    "../../../../../../sim/ddr_model",
                    "../../../../../../ip_cores/pcie/ml605/ddr_v6/user_design/"]}

files = ["wb_acq_core_tb.v", "defines.v", "timescale.v",
			"clk_rst.v"]

vlog_opt = "+incdir+../../../../../../sim/regs +incdir+../../../../../../sim +incdir+../../../../../../sim/ddr_model"
