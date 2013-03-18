/*
 * Copyright (C) 2013 LNLS (www.lnls.br)
 * Author: Lucas Russo <lucas.russo@lnls.br>
 *
 * Released according to the GNU GPL, version 2 or any later version.
 */

#include <inttypes.h>
#include "board.h"      // Board definitions: SPI device structure
#include "debug_print.h"
#include "hw/wb_fmc516.h"
#include "isla216p25.h"
#include "lmk02000.h"

#define DEFAULT_FMC516_ID 0

/* Type definitions */
typedef volatile struct FMC516_WB fmc516_t;

int fmc516_init(void);
int fmc516_exit(void);
// For now just ta few registers are initialized
void fmc516_init_regs(unsigned int id);
void fmc516_clk_sel(unsigned int id, int ext_clk);
void fmc516_led0(unsigned int id, int on);
void fmc516_led1(unsigned int id, int on);
void fmc516_reset_adcs(unsigned int id);

void fmc516_update_clk_dly(unsigned int id);
void fmc516_update_data_dly(unsigned int id);

/* Fix This! Code repetition! Fixed? */
void fmc516_adj_delay(unsigned int id, int ch, int clk_dly, int data_dly, int commit);
//void fmc516_adj_ch0_delay(unsigned int id, int clk_dly, int data_dly, int commit);
//void fmc516_adj_ch1_delay(unsigned int id, int clk_dly, int data_dly, int commit);
//void fmc516_adj_ch2_delay(unsigned int id, int clk_dly, int data_dly, int commit);
//void fmc516_adj_ch3_delay(unsigned int id, int clk_dly, int data_dly, int commit);
void fmc516_sweep_delays(unsigned int id);
uint32_t fmc516_read_adc0(unsigned int id);
uint32_t fmc516_read_adc1(unsigned int id);
uint32_t fmc516_read_adc2(unsigned int id);
uint32_t fmc516_read_adc3(unsigned int id);

