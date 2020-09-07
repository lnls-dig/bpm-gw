action = "simulation"
sim_tool = "modelsim"
vcom_opt = "-2008"
top_module = "position_tb"
sim_top = "cic_bench"

target = "xilinx"
syn_device = "xc7a200t"

machine_pkg = "sirius_sr_250M"

modules = {
    "local" : [
        "../../modules",
        "../../ip_cores/general-cores",
        "../../ip_cores/dsp-cores",
        "../../sim/test_pkg"
    ]
}

files = ["position_tb.vhd"]

include_dirs = ["../../sim", "../../sim/regs", ".",
                "../../ip_cores/general-cores/modules/wishbone/wb_lm32/src",
                "../../ip_cores/general-cores/modules/wishbone/wb_lm32/platform/generic",
                "../../ip_cores/general-cores/modules/wishbone/wb_spi_bidir",
                "../../ip_cores/infra-cores/modules/wishbone/wb_ethmac",
                "../../ip_cores/general-cores/modules/wishbone/wb_spi"]

vlog_opt = "+incdir+../../sim/regs +incdir+../../sim  +incdir+."
