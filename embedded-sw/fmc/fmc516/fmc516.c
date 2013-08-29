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

// Global FMC516 handler.
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
        dbg_print("> fmc516 addr[%d]: %08X\n", i, dev_p->base);

        delay(1000);
        dbg_print("> resetting ADCs\n");
        fmc516_reset_adcs(i);
        delay(1000);
        fmc516_resetdiv_adcs(i);
        delay(1000);
        dbg_print("> ADCs reset values(rst|divrst)): %08X|%08X\n",
            fmc516[i]->ADC_CTL & FMC516_ADC_CTL_RST_ADCS,
            fmc516[i]->ADC_CTL & FMC516_ADC_CTL_RST_DIV_ADCS);

        dbg_print("> initilizing fmc516 isla216\n");
        fmc516_isla216_all_init();
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

// For now just a few registers are initialized
void fmc516_init_regs(unsigned int id)
{
    int commit= 1;

    dbg_print("> Leds and clock select\n");

    // No test data. External reference on. Led0 on. VCXO off
    fmc516_clk_sel(id, 1);
    fmc516_led0(id, 1);

    // Adjust the delays of all channels. Don't change these values
    // unless you really have to!
    fmc516_adj_delay(id, FMC516_ISLA216_ADC0, 5, 24, commit);
    //fmc516_adj_delay(id, FMC516_ISLA216_ADC0, 5, 15, commit);
    fmc516_adj_delay(id, FMC516_ISLA216_ADC1, 5, 14, commit);
    fmc516_adj_delay(id, FMC516_ISLA216_ADC2, 5, 15, commit);
    //fmc516_adj_delay(id, FMC516_ISLA216_ADC3, 5, 25, commit);
    fmc516_adj_delay(id, FMC516_ISLA216_ADC3, 5, 28, commit);

    // Delay the falling edge of all channels
    fmc516_fe_rg_dly(id, FMC516_ISLA216_ADC0, 0, 0, 0, 0);
    fmc516_fe_rg_dly(id, FMC516_ISLA216_ADC1, 0, 0, 0, 0);
    fmc516_fe_rg_dly(id, FMC516_ISLA216_ADC2, 0, 0, 0, 0);
    fmc516_fe_rg_dly(id, FMC516_ISLA216_ADC3, 0, 0, 0, 0);
}

void fmc516_sweep_delays(unsigned int id)
{
    int commit = 1;
    int i, j;

    dbg_print("> ADC%d data delay: %d...\n", 0, FMC516_CH0_FN_DLY_DATA_CHAIN_DLY_R(fmc516[id]->CH0_FN_DLY));
    dbg_print("> ADC%d data delay: %d...\n", 1, FMC516_CH1_FN_DLY_DATA_CHAIN_DLY_R(fmc516[id]->CH1_FN_DLY));
    dbg_print("> ADC%d data delay: %d...\n", 2, FMC516_CH2_FN_DLY_DATA_CHAIN_DLY_R(fmc516[id]->CH2_FN_DLY));
    dbg_print("> ADC%d data delay: %d...\n", 3, FMC516_CH3_FN_DLY_DATA_CHAIN_DLY_R(fmc516[id]->CH3_FN_DLY));

    //for (i = 0; i < FMC516_NUM_ISLA216; ++i) {
    //  //for (j = 0; j < 32; ++j) {
    //  //    dbg_print("> sweeping ADC%d clk delay values: %d...\n", 0, j);
    //  //    fmc516_adj_delay(id, FMC516_ISLA216_ADC0, -1, j, commit);
    //  //    delay(80000000);
    //  //    dbg_print("> ADC%d data delay: %d...\n", 0, FMC516_CH0_FN_DLY_DATA_CHAIN_DLY_R(fmc516[id]->CH0_FN_DLY));
    //  //}
    //
    //  for (j = 0; j < 32; ++j) {
    //      dbg_print("> sweeping ADC%d clk delay values: %d...\n", 3, j);
    //      fmc516_adj_delay(id, FMC516_ISLA216_ADC3, -1, j, commit);
    //      delay(150000000);
    //      dbg_print("> ADC%d data delay: %d...\n", 3, FMC516_CH3_FN_DLY_DATA_CHAIN_DLY_R(fmc516[id]->CH3_FN_DLY));
    //  }
    //}
}

void fmc516_update_clk_dly(unsigned int id)
{
    fmc516[id]->ADC_CTL |= FMC516_ADC_CTL_UPDATE_CLK_DLY;
}

void fmc516_update_data_dly(unsigned int id)
{
    fmc516[id]->ADC_CTL |= FMC516_ADC_CTL_UPDATE_DATA_DLY;
}

void fmc516_adj_delay(unsigned int id, int ch, int clk_dly, int data_dly, int commit)
{
    uint32_t adc_ctl_reg;
    uint32_t *fmc_ch_handler;

    // Find the correct ADC instance to operate on
    switch(ch) {
        case FMC516_ISLA216_ADC0:
            fmc_ch_handler = (uint32_t *) &fmc516[id]->CH0_FN_DLY;
            break;
        case FMC516_ISLA216_ADC1:
            fmc_ch_handler = (uint32_t *) &fmc516[id]->CH1_FN_DLY;
            break;
        case FMC516_ISLA216_ADC2:
            fmc_ch_handler = (uint32_t *) &fmc516[id]->CH2_FN_DLY;
            break;
        case FMC516_ISLA216_ADC3:
            fmc_ch_handler = (uint32_t *) &fmc516[id]->CH3_FN_DLY;
            break;

        default:
            dbg_print("> Unsupported FMC516 ADC channel\n");
            fmc_ch_handler = (uint32_t *) &fmc516[id]->CH0_FN_DLY;
    }

    // Read the register value once
    adc_ctl_reg = *fmc_ch_handler;

    /* All Masks are the same for all channels. Use the first one */
    /* All Read/Write macros are the same for all channels. Use the first one */
    if (clk_dly != -1) {
        /* Clear clk delay bits and write the desired value*/
        adc_ctl_reg = (adc_ctl_reg & ~FMC516_CH0_FN_DLY_CLK_CHAIN_DLY_MASK) |
                            FMC516_CH0_FN_DLY_CLK_CHAIN_DLY_W(clk_dly);

    }

    if (data_dly != -1) {
        /* Clear clk delay bits and write the desired value*/
        adc_ctl_reg = (adc_ctl_reg & ~FMC516_CH0_FN_DLY_DATA_CHAIN_DLY_MASK) |
                          FMC516_CH0_FN_DLY_DATA_CHAIN_DLY_W(data_dly);

    }

    // Write the register value once
    *fmc_ch_handler = adc_ctl_reg;

    // Update data/clock delay values
    if (commit) {
        fmc516_update_data_dly(id);
        fmc516_update_clk_dly(id);
    }
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

void fmc516_reset_adcs(unsigned int id)
{
    fmc516[id]->ADC_CTL |= FMC516_ADC_CTL_RST_ADCS;
}

void fmc516_resetdiv_adcs(unsigned int id)
{
    fmc516[id]->ADC_CTL |= FMC516_ADC_CTL_RST_DIV_ADCS;
}

//#define fmc516_read_adc0(id) (FMC516_CH0_STA_VAL_R(fmc516[id]->CH0_STA))
uint32_t fmc516_read_adc0(unsigned int id)
{
    return FMC516_CH0_STA_VAL_R(fmc516[id]->CH0_STA);
}

//#define fmc516_read_adc1(id) (FMC516_CH1_STA_VAL_R(fmc516[id]->CH1_STA))
uint32_t fmc516_read_adc1(unsigned int id)
{
    return FMC516_CH1_STA_VAL_R(fmc516[id]->CH1_STA);
}

//#define fmc516_read_adc2(id) (FMC516_CH2_STA_VAL_R(fmc516[id]->CH2_STA))
uint32_t fmc516_read_adc2(unsigned int id)
{
    return FMC516_CH2_STA_VAL_R(fmc516[id]->CH2_STA);
}

//#define fmc516_read_adc3(id) (FMC516_CH3_STA_VAL_R(fmc516[id]->CH3_STA))
uint32_t fmc516_read_adc3(unsigned int id)
{
    return FMC516_CH3_STA_VAL_R(fmc516[id]->CH3_STA);
}

// ADC delay falling edge control
void fmc516_fe_rg_dly(unsigned int id, int ch, int fe_dly_d1, int fe_dly_d2,
                    int rg_dly_d1, int rg_dly_d2)
{
    uint32_t *fmc_ch_handler;
    uint32_t dly_ctl_reg;

    switch(ch) {
        case FMC516_ISLA216_ADC0:
            fmc_ch_handler = (uint32_t *) &fmc516[id]->CH0_CS_DLY;
            break;
        case FMC516_ISLA216_ADC1:
            fmc_ch_handler = (uint32_t *) &fmc516[id]->CH1_CS_DLY;
            break;
        case FMC516_ISLA216_ADC2:
            fmc_ch_handler = (uint32_t *) &fmc516[id]->CH2_CS_DLY;
            break;
        case FMC516_ISLA216_ADC3:
            fmc_ch_handler = (uint32_t *) &fmc516[id]->CH3_CS_DLY;
            break;

        default:
            dbg_print("> Unsupported FMC516 ADC channel\n");
            fmc_ch_handler = (uint32_t *) &fmc516[id]->CH0_CS_DLY;
    }

    // Read register value once
    dly_ctl_reg = *fmc_ch_handler;

    if (fe_dly_d2)
        dly_ctl_reg = (dly_ctl_reg & ~FMC516_CH0_CS_DLY_FE_DLY_MASK) |
                        FMC516_CH0_CS_DLY_FE_DLY_W(0x3);
    else if (fe_dly_d1)
        dly_ctl_reg = (dly_ctl_reg & ~FMC516_CH0_CS_DLY_FE_DLY_MASK) |
                        FMC516_CH0_CS_DLY_FE_DLY_W(0x1);
    else
        dly_ctl_reg = (dly_ctl_reg & ~FMC516_CH0_CS_DLY_FE_DLY_MASK) |
                    FMC516_CH0_CS_DLY_FE_DLY_W(0x0);

    if (rg_dly_d2)
        dly_ctl_reg = (dly_ctl_reg & ~FMC516_CH0_CS_DLY_RG_DLY_MASK) |
                        FMC516_CH0_CS_DLY_RG_DLY_W(0x3);
    else if (rg_dly_d1)
        dly_ctl_reg = (dly_ctl_reg & ~FMC516_CH0_CS_DLY_RG_DLY_MASK) |
                        FMC516_CH0_CS_DLY_RG_DLY_W(0x1);
    else
        dly_ctl_reg = (dly_ctl_reg & ~FMC516_CH0_CS_DLY_RG_DLY_MASK) |
                    FMC516_CH0_CS_DLY_RG_DLY_W(0x0);

    // Write register value once
    *fmc_ch_handler = dly_ctl_reg;

    dbg_print("dly_ctl_reg, *fmc_ch_handler = %08X, %08X\n", dly_ctl_reg, *fmc_ch_handler);
}
