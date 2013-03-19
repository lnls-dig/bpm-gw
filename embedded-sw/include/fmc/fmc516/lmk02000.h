/*
 * Copyright (C) 2013 LNLS (www.lnls.br)
 * Author: Lucas Russo <lucas.russo@lnls.br>
 *
 * Released according to the GNU GPL, version 2 or any later version.
 */

#include <inttypes.h>

#include "board.h"      // Board definitions: SPI device structure
#include "spi.h"        // SPI device functions
#include "regs.h"

#define FMC516_LMK02000_CS 0

#define FMC516_LMK02000_VAL_SIZE 28
#define FMC516_LMK02000_VAL_OFS 4
#define FMC516_LMK02000_ADDR_SIZE 4
#define FMC516_LMK02000_ADDR_OFS 0

#define FMC516_LMK02000_SIZE (FMC516_LMK02000_VAL_SIZE + FMC516_LMK02000_ADDR_SIZE)

int fmc516_lmk02000_init(void);

// lmk02000 has 28 msb value and 4 lsb addr
void fmc516_lmk02000_write_reg(int val);

