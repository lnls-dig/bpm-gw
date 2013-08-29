files = [ "dbe_wishbone_pkg.vhd" ];

modules = { "local" : [
                        "wb_stream",
                        "wb_fmc150",
                        "wb_fmc516",
                        "wb_ethmac_adapter",
                        "wb_ethmac",
                        "wb_dbe_periph",
                        "wb_rs232_syscon"
                      ] };
