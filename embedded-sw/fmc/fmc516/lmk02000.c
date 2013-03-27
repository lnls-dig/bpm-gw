/*
 * Copyright (C) 2013 LNLS (www.lnls.br)
 * Author: Lucas Russo <lucas.russo@lnls.br>
 *
 * Released according to the GNU GPL, version 2 or any later version.
 */

#include <inttypes.h>

#include "board.h"      // Board definitions: SPI device structure
#include "spi.h"        // SPI device functions
#include "debug_print.h"
#include "lmk02000.h"
#include "lmk02000_regs.h"

/*
 * Which SPI ID is lmk02000? See board.h for definitions.
 * Should be dynamically detected...
 */

static void fmc516_lmk02000_load_regset(const struct default_dev_regs_t *regs);

int fmc516_lmk02000_init(void)
{
    dbg_print("> fmc516_lmk02000_init...\n");
    fmc516_lmk02000_load_regset(lmk02000_regs_default);
    return 0;
}

// lmk02000 has 28 msb value and 4 lsb addr
void fmc516_lmk02000_write_reg(int val)
{
    dbg_print("> fmc516_lmk02000_write_reg...\n");
    oc_spi_txrx(FMC516_LMK02000_SPI_ID, FMC516_LMK02000_CS,
                    FMC516_LMK02000_SIZE, val, 0);
}

// No readback is available for lmk02000
/*
int fmc516_lmk02000_read_reg(int addr)
{
}
*/

static void fmc516_lmk02000_load_regset(const struct default_dev_regs_t *regs)
{
    int i = 0;

    dbg_print("> fmc516_lmk02000_load_regset...\n");
    while (regs[i].type != REGS_DEFAULT_END){
        dbg_print("> fmc516_lmk02000_load_regset while: %d...\n", i);
        if (regs[i].type == REGS_DEFAULT_INIT)
            fmc516_lmk02000_write_reg(regs[i].val);
        ++i;
    }
}
