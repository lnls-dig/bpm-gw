/*
 * Copyright (C) 2013 LNLS (www.lnls.br)
 * Author: Lucas Russo <lucas.russo@lnls.br>
 *
 * Released according to the GNU GPL, version 2 or any later version.
 *
 * Parts taken from PTS OHWR repository
 */

#include <inttypes.h>

#include "board.h"      // Board definitions: I2C device structure
#include "i2c.h"        // I2C device functions
#include "regs.h"

/* SI57X register Definitions */
#define SI57X_R_HS 0x07
#define SI57X_R_RFREQ4 0x08
#define SI57X_R_RFREQ3 0x09
#define SI57X_R_RFREQ2 0x0A
#define SI57X_R_RFREQ1 0x0B
#define SI57X_R_RFREQ0 0x0C
#define SI57X_R_RFMC 0x87
#define SI57X_R_FDCO 0x89

#define SI57X_HS_DIV_MASK 0xE0
#define SI57X_N1_H_MASK 0x1F
#define SI57X_N1_L_MASK 0xC0
#define SI57X_RFREQ4_MASK 0x3F

#define SI57X_RFMC_RST (1<<7)
#define SI57X_RFMC_NEW_FREQ (1<<6)
#define SI57X_RFMC_FREEZE_M (1<<5)
#define SI57X_RFMC_FREEZE_VCADC (1<<4)
#define SI57X_RFMC_RECALL (1<<0)

#define SI57X_FDCO_FREEZE_DCO (1<<4)

//#define FMC516_SI57X_VAL_SIZE 28
//#define FMC516_SI57X_VAL_OFS 4
//#define FMC516_SI57X_ADDR_SIZE 4
//#define FMC516_SI57X_ADDR_OFS 0
//
//#define FMC516_SI57X_SIZE (FMC516_LMK02000_VAL_SIZE + FMC516_LMK02000_ADDR_SIZE)

int fmc516_si57x_init(void);

// lmk02000 has 28 msb value and 4 lsb addr
void fmc516_si57x_write_reg(int val);

