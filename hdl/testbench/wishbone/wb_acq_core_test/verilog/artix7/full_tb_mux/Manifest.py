action = "simulation"
target = "xilinx"
syn_device = "xc7a200t"
sim_tool = "modelsim"
top_module = "wb_acq_core_tb.v"

modules = {"local" : [
                    "../../../../../../modules/dbe_wishbone",
                    "../../../../../../modules/dbe_common",
                    "../../../../../../modules/rffe_top",
                    "../../../../../../modules/fabric",
                    "../../../../../../modules/fmc_adc_common",
#                    "../../../../../../modules/pcie",
                    "../../../../../../ip_cores/general-cores",
                    "../../../../../../ip_cores/etherbone-core",
                    "../../../../../../platform",
                    "../../../../../../sim",
                    "../../../../../../sim/ddr_model",
                     "../../../../../../platform/artix7/afc_v3"]}

files = ["wb_acq_core_tb.v", "axi_interconnect_wrapper.vhd", "ddr_core_wrapper.vhd", "defines.v", "timescale.v",
			"clk_rst.v", "../../../../../../sim/wishbone_test_master.v",
            "../../../../../../../../../../../opt/Xilinx/14.7/ISE_DS/ISE/verilog/src/glbl.v"]

include_dirs = ["../../../../../../sim", "../../../../../../sim/regs", "../../../../../../sim/ddr_model",
            "../../../../../../platform/artix7/ip_cores/axis_mux_2_to_1/hdl/verilog"]

vlog_opt = "+incdir+../../../../../../sim/regs +incdir+../../../../../../sim +incdir+../../../../../../sim/ddr_model +incdir+../../../../../../platform/artix7/ip_cores/axis_mux_2_to_1/hdl/verilog"
