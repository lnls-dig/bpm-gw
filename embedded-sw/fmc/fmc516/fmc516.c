/*
 * Copyright (C) 2013 LNLS (www.lnls.br)
 * Author: Lucas Russo <lucas.russo@lnls.br>
 *
 * Released according to the GNU GPL, version 2 or any later version.
 */

#include <inttypes.h>

#include "board.h"      // Board definitions: SPI device structure
#include "spi.h"        // SPI device functions
#include "memmgr.h"
#include "fmc516.h"

// Global UART handler.
fmc516_t **fmc516;

int fmc516_init(void)
{
    int i;
    struct dev_node *dev_p = 0;

    if (!fmc516_devl->devices)
        return -1;

    // get all base addresses
    fmc516 = (fmc516_t **) memmgr_alloc(sizeof(fmc516_t *)*fmc516_devl->size);

    for (i = 0, dev_p = fmc516_devl->devices; i < fmc516_devl->size;
            ++i, dev_p = dev_p->next) {
        fmc516[i] = (fmc516_t *) dev_p->base;

        // Initialize fmc516 components
        dbg_print("> initilizing fmc516 regs\n");
        fmc516_init_regs(i);
        dbg_print("> initilizing fmc516 lmk02000\n");
        fmc516_lmk02000_init();
        dbg_print("> initilizing fmc516 isla216\n");
        fmc516_isla216_all_init();
        dbg_print("> fmc516 addr[%d]: %08X\n", i, dev_p->base);
    }

    dbg_print("> fmc516 size: %d\n", fmc516_devl->size);
    //fmc516 = (fmc516_t *)fmc516_devl->devices->base;//BASE_FMC516;
    return 0;
}

int fmc516_exit()
{
    // free fmc516 structure
    memmgr_free(fmc516);

    return 0;
}

// For now just ta few registers are initialized
void fmc516_init_regs(unsigned int id)
{
    uint32_t fmc516_reg = 0;

    dbg_print("> fmc516_init_regs...\n");
    // No test data. External reference on. Led0 on. Led1 on. VCXO off
    fmc516_reg |= FMC516_FMC_CTL_CLK_SEL |
                    FMC516_FMC_CTL_LED_0;
                    //FMC516_FMC_CTL_LED_0;

    fmc516[id]->FMC_CTL = fmc516_reg;
}

void fmc516_clk_sel(unsigned int id, int ext_clk)
{
    if (ext_clk)
        fmc516[id]->FMC_CTL |= FMC516_FMC_CTL_CLK_SEL;
}

void fmc516_led0(unsigned int id, int on)
{
    if (on)
        fmc516[id]->FMC_CTL |= FMC516_FMC_CTL_LED_0;
}

void fmc516_led1(unsigned int id, int on)
{
    if (on)
        fmc516[id]->FMC_CTL |= FMC516_FMC_CTL_LED_1;
}
