#!/bin/bash

wbgen2 -V wb_fmc516_regs.vhd -H record -p wb_fmc516_regs_pkg.vhd -K ../../../../sim/regs/wb_fmc516_regs.vh -s struct -C fmc516_regs.h -f html -D doc/fmc516_regs_wb.html wb_fmc516_regs.wb
