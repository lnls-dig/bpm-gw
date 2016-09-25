files = [ "dbe_wishbone_pkg.vhd" ];

modules = { "local" : [
                        "wb_stream",
                        "wb_trigger_iface",
                        "wb_trigger_mux",
                        "wb_trigger",
                        "wb_afc_diag",
                        "wb_fmc150",
                        "wb_fmc516",
                        "wb_fmc130m_4ch",
                        "wb_fmc250m_4ch",
                        "wb_ethmac_adapter",
                        "wb_ethmac",
                        "wb_dbe_periph",
                        "wb_rs232_syscon",
                        "wb_acq_core",
                        "wb_acq_core_mux",
                        "wb_facq_core",
                        "wb_facq_core_mux",
                        "wb_pcie",
                        "wb_fmc_adc_common",
                        "wb_fmc_active_clk"
                      ] };
