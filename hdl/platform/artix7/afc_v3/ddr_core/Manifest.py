if (action == "synthesis"):
    files = ["ddr_core.xci"]

else:
    files = ["ddr_core/user_design/rtl/ddr_core.v",
         "ddr_core/user_design/rtl/ddr_core_mig_sim.v",
         "ddr_core/user_design/rtl/axi/",
         "ddr_core/user_design/rtl/clocking/",
         "ddr_core/user_design/rtl/controller/",
         "ddr_core/user_design/rtl/ecc/",
         "ddr_core/user_design/rtl/ip_top/",
         "ddr_core/user_design/rtl/phy/",
         "ddr_core/user_design/rtl/ui/"]
