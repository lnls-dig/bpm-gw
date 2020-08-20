#!/bin/bash

cheby -i wb_pos_calc_regs.cheby --hdl vhdl --gen-wbgen-hdl wb_pos_calc_regs.vhd --doc html --gen-doc doc/wb_pos_calc_regs_wb.html --gen-c wb_pos_calc_regs.h --consts-style verilog --gen-consts ../../../sim/regs/wb_pos_calc_regs.vh
