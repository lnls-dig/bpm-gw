files = [ "dbe_bpm.vhd",
          "sys_pll.vhd",
          "clk_gen.vhd",
          "dbe_bpm.xdc",
          "pcie_core.xdc",
          "ddr_core.xdc",
          "dbe_bpm.xcf" ];

modules = { "local" :
             ["../../../..",
              "../../../../ip_cores/pcie/7a200ffg1156"
             ]
          };

