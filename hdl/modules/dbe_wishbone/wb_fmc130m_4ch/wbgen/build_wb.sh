#!/bin/bash

wbgen2 -V fmc_130m_4ch_regs.vhd -H record -p fmc_130m_4ch_regs_pkg.vhd -K ../../../../sim/regs/wb_fmc130m_4ch_regs.vh -s defines -C wb_fmc130m_4ch_regs.h -f html -D doc/fmc130m_4ch_regs_wb.html fmc_130m_4ch_regs.wb
