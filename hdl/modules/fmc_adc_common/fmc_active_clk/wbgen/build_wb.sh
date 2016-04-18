#!/bin/bash

wbgen2 -V wb_fmc_active_clk_regs.vhd -H record -p wb_fmc_active_clk_regs_pkg.vhd -K ../../../../sim/regs/wb_fmc_active_clk_regs.vh -s defines -C wb_fmc_active_clk_regs.h -f html -D doc/fmc_active_clk_regs_wb.html wb_fmc_active_clk_regs.wb
