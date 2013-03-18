#!/bin/bash

wbgen2 -V wb_fmc516_regs.vhd -H record -p wb_fmc516_regs_pkg.vhd -K ../../../../sim/regs/wb_fmc516_regs.vh -s struct -C fmc516_regs.h -D doc/fmc516_regs_wb.html -f HTML wb_fmc516_regs.wb
