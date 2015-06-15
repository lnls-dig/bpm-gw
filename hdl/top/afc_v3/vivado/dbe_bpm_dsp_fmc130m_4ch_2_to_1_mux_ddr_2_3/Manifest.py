files = [ "dbe_bpm_dsp.vhd",
          "sys_pll.vhd",
          "clk_gen.vhd",
          "dbe_bpm_dsp.xdc",
          "pcie_core.xdc",
          "ddr_core.xdc",
          "dbe_bpm_dsp.xcf" ];

modules = { "local" :
             ["../../../..",
              "../../../../ip_cores/pcie/7a200ffg1156"
             ]
          };

