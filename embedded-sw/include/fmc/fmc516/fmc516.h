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
void fmc516_led0(unsigned int id, int ext_clk);
void fmc516_led1(unsigned int id, int ext_clk);
