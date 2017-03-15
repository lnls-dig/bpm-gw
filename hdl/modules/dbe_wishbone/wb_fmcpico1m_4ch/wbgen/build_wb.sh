#!/bin/bash

wbgen2 -V fmc_pico1m_4ch_regs.vhd -H record -p fmc_pico1m_4ch_regs_pkg.vhd -K ../../../../sim/regs/wb_fmcpico1m_4ch_regs.vh -s defines -C fmcpico1m_4ch_regs.h -f html -D doc/fmcpico1m_4ch_regs_wb.html fmc_pico1m_4ch_regs.wb
