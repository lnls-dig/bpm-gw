#!/bin/bash

wbgen2 -V wb_fmc250m_4ch_regs.vhd -H record -p wb_fmc250m_4ch_regs_pkg.vhd -K ../../../../sim/regs/wb_fmc250m_4ch_regs.vh -s defines -C wb_fmc250m_4ch_regs.h -f html -D doc/fmc250m_4ch_regs_wb.html wb_fmc250m_4ch_regs.wb
