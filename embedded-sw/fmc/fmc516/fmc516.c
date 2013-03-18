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
        delay(10000);
        dbg_print("> fmc516 addr[%d]: %08X\n", i, dev_p->base);

        delay(10000);
        dbg_print("> resetting ADCs\n");
        fmc516[i]->ADC_CTL = FMC516_ADC_CTL_RST_ADCS;
        delay(100);
        fmc516[i]->ADC_CTL = FMC516_ADC_CTL_RST_DIV_ADCS;
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
    dbg_print("> fmc516_init_regs... Leds and clock select\n");

    // No test data. External reference on. Led0 on. Led1 on. VCXO off
    fmc516[id]->FMC_CTL = //FMC516_FMC_CTL_TEST_DATA_EN |
                            FMC516_FMC_CTL_CLK_SEL |
                            //FMC516_FMC_CTL_LED_0;
                            FMC516_FMC_CTL_LED_1;

    // Delay the falling edge of all channels by one
    fmc516_fe_dly(DEFAULT_FMC516_ID, FMC516_ISLA216_ADC0, 1, 0);
    fmc516_fe_dly(DEFAULT_FMC516_ID, FMC516_ISLA216_ADC1, 1, 0);
    fmc516_fe_dly(DEFAULT_FMC516_ID, FMC516_ISLA216_ADC2, 1, 0);
    fmc516_fe_dly(DEFAULT_FMC516_ID, FMC516_ISLA216_ADC3, 1, 0);
}

void fmc516_sweep_delays(unsigned int id)
{
    int commit = 1;
    int i;

    //dbg_print("> ADC%d data delay: %d...\n", 0, FMC516_CH0_CTL_DATA_CHAIN_DLY_R(fmc516[id]->CH0_CTL));
    //dbg_print("> ADC%d data delay: %d...\n", 1, FMC516_CH1_CTL_DATA_CHAIN_DLY_R(fmc516[id]->CH1_CTL));
    //dbg_print("> ADC%d data delay: %d...\n", 2, FMC516_CH2_CTL_DATA_CHAIN_DLY_R(fmc516[id]->CH2_CTL));
    //dbg_print("> ADC%d data delay: %d...\n", 3, FMC516_CH3_CTL_DATA_CHAIN_DLY_R(fmc516[id]->CH3_CTL));

    fmc516_adj_delay(id, FMC516_ISLA216_ADC0, 5, 26, commit);
    fmc516_adj_delay(id, FMC516_ISLA216_ADC1, 5, 27, commit);
    fmc516_adj_delay(id, FMC516_ISLA216_ADC2, 5, 27, commit);
    fmc516_adj_delay(id, FMC516_ISLA216_ADC3, 5, 27, commit);

    dbg_print("> ADC%d data delay: %d...\n", 0, FMC516_CH0_CTL_DATA_CHAIN_DLY_R(fmc516[id]->CH0_CTL));
    dbg_print("> ADC%d data delay: %d...\n", 1, FMC516_CH1_CTL_DATA_CHAIN_DLY_R(fmc516[id]->CH1_CTL));
    dbg_print("> ADC%d data delay: %d...\n", 2, FMC516_CH2_CTL_DATA_CHAIN_DLY_R(fmc516[id]->CH2_CTL));
    dbg_print("> ADC%d data delay: %d...\n", 3, FMC516_CH3_CTL_DATA_CHAIN_DLY_R(fmc516[id]->CH3_CTL));

    for (i = 25; i < 32; ++i){
        dbg_print("> sweeping ADC%d data delay values: %d...\n", 1, i);
        fmc516_adj_delay(id, 1, -1, i, commit);
        delay(200000000);
        dbg_print("> ADC%d data delay: %d...\n", 1, FMC516_CH1_CTL_DATA_CHAIN_DLY_R(fmc516[id]->CH1_CTL));
    }

    fmc516_adj_delay(id, 1, -1, 27, commit);

    for (i = 0; i < 32; ++i){
        dbg_print("> sweeping ADC%d clk delay values: %d...\n", 1, i);
        fmc516_adj_delay(id, 1, i, -1, commit);
        delay(80000000);
        dbg_print("> ADC%d data delay: %d...\n", 1, FMC516_CH1_CTL_CLK_CHAIN_DLY_R(fmc516[id]->CH1_CTL));
      }

    //for (i = 0; i < 32; ++i){
    //    dbg_print("> sweeping ADC%d delay values: %d...\n", 2, i);
    //    fmc516_adj_ch2_delay(id, -1, i, commit);
    //    delay(50000000);
    //    dbg_print("> ADC%d data delay: %d...\n", 2, FMC516_CH2_CTL_DATA_CHAIN_DLY_R(fmc516[id]->CH2_CTL));
    //}
}

void fmc516_update_clk_dly(unsigned int id)
{
    //dbg_print("> fmc516_update_dly: 0x%08X...\n", fmc516[id]->ADC_CTL & FMC516_ADC_CTL_UPDATE_CLK_DLY);
    fmc516[id]->ADC_CTL &= ~FMC516_ADC_CTL_UPDATE_CLK_DLY;
    //dbg_print("> fmc516_update_dly: 0x%08X...\n", fmc516[id]->ADC_CTL & FMC516_ADC_CTL_UPDATE_CLK_DLY);
    fmc516[id]->ADC_CTL |= FMC516_ADC_CTL_UPDATE_CLK_DLY;
    //delay(100);
    //dbg_print("> fmc516_update_dly: 0x%08X...\n", fmc516[id]->ADC_CTL & FMC516_ADC_CTL_UPDATE_CLK_DLY);
}

void fmc516_update_data_dly(unsigned int id)
{
    //dbg_print("> fmc516_update_dly: 0x%08X...\n", fmc516[id]->ADC_CTL & FMC516_ADC_CTL_UPDATE_DATA_DLY);
    fmc516[id]->ADC_CTL &= ~FMC516_ADC_CTL_UPDATE_DATA_DLY;
    //dbg_print("> fmc516_update_dly: 0x%08X...\n", fmc516[id]->ADC_CTL & FMC516_ADC_CTL_UPDATE_DATA_DLY);
    fmc516[id]->ADC_CTL |= FMC516_ADC_CTL_UPDATE_DATA_DLY;
    //delay(100);
    //dbg_print("> fmc516_update_dly: 0x%08X...\n", fmc516[id]->ADC_CTL & FMC516_ADC_CTL_UPDATE_DATA_DLY);
}

/* Fix! Code repetition! */
//void fmc516_adj_ch0_delay(unsigned int id, int clk_dly, int data_dly, int commit)
//{
//    uint32_t clk_dly_reg;
//    uint32_t data_dly_reg;
//
//    if (clk_dly != -1) {
//        /* Clear clk delay bits */
//        clk_dly_reg = fmc516[id]->CH0_CTL & ~FMC516_CH0_CTL_CLK_CHAIN_DLY_MASK;
//        fmc516[id]->CH0_CTL = clk_dly_reg | FMC516_CH0_CTL_CLK_CHAIN_DLY_W(clk_dly);
//    }
//
//    if (data_dly != -1) {
//        data_dly_reg = fmc516[id]->CH0_CTL & ~FMC516_CH0_CTL_DATA_CHAIN_DLY_MASK;
//        fmc516[id]->CH0_CTL = data_dly_reg | FMC516_CH0_CTL_DATA_CHAIN_DLY_W(data_dly);
//    }
//
//    delay(100);
//    if (commit)
//        fmc516_update_dly(id);
//}
//
//void fmc516_adj_ch1_delay(unsigned int id, int clk_dly, int data_dly, int commit)
//{
//    uint32_t clk_dly_reg;
//    uint32_t data_dly_reg;
//
//    if (clk_dly != -1) {
//        /* Clear clk delay bits */
//        clk_dly_reg = fmc516[id]->CH1_CTL & ~FMC516_CH1_CTL_CLK_CHAIN_DLY_MASK;
//        fmc516[id]->CH1_CTL = clk_dly_reg | FMC516_CH1_CTL_CLK_CHAIN_DLY_W(clk_dly);
//    }
//
//    if (data_dly != -1) {
//        data_dly_reg = fmc516[id]->CH1_CTL & ~FMC516_CH1_CTL_DATA_CHAIN_DLY_MASK;
//        fmc516[id]->CH1_CTL = data_dly_reg | FMC516_CH1_CTL_DATA_CHAIN_DLY_W(data_dly);
//    }
//
//    delay(100);
//    if (commit){
//        dbg_print("> fmc516_adj_ch1_delay: commit!\n");
//        fmc516_update_dly(id);
//    }
//}
//
//void fmc516_adj_ch2_delay(unsigned int id, int clk_dly, int data_dly, int commit)
//{
//    uint32_t clk_dly_reg;
//    uint32_t data_dly_reg;
//
//    if (clk_dly != -1) {
//        /* Clear clk delay bits */
//        clk_dly_reg = fmc516[id]->CH2_CTL & ~FMC516_CH2_CTL_CLK_CHAIN_DLY_MASK;
//        fmc516[id]->CH2_CTL = clk_dly_reg | FMC516_CH2_CTL_CLK_CHAIN_DLY_W(clk_dly);
//    }
//
//    if (data_dly != -1) {
//        data_dly_reg = fmc516[id]->CH2_CTL & ~FMC516_CH2_CTL_DATA_CHAIN_DLY_MASK;
//        fmc516[id]->CH2_CTL = data_dly_reg | FMC516_CH2_CTL_DATA_CHAIN_DLY_W(data_dly);
//    }
//
//    delay(100);
//    if (commit)
//        fmc516_update_dly(id);
//}
//
//void fmc516_adj_ch3_delay(unsigned int id, int clk_dly, int data_dly, int commit)
//{
//    uint32_t clk_dly_reg;
//    uint32_t data_dly_reg;
//
//    if (clk_dly != -1) {
//        /* Clear clk delay bits */
//        clk_dly_reg = fmc516[id]->CH3_CTL & ~FMC516_CH3_CTL_CLK_CHAIN_DLY_MASK;
//        fmc516[id]->CH3_CTL = clk_dly_reg | FMC516_CH3_CTL_CLK_CHAIN_DLY_W(clk_dly);
//    }
//
//    if (data_dly != -1) {
//        data_dly_reg = fmc516[id]->CH3_CTL & ~FMC516_CH3_CTL_DATA_CHAIN_DLY_MASK;
//        fmc516[id]->CH3_CTL = data_dly_reg | FMC516_CH3_CTL_DATA_CHAIN_DLY_W(data_dly);
//    }
//
//    delay(100);
//    if (commit)
//        fmc516_update_dly(id);
//}

void fmc516_adj_delay(unsigned int id, int ch, int clk_dly, int data_dly, int commit)
{
    uint32_t *fmc_ch_handler;

    switch(ch) {
        case FMC516_ISLA216_ADC0:
            fmc_ch_handler = (uint32_t *) &fmc516[id]->CH0_CTL;
            break;
        case FMC516_ISLA216_ADC1:
            fmc_ch_handler = (uint32_t *) &fmc516[id]->CH1_CTL;
            break;
        case FMC516_ISLA216_ADC2:
            fmc_ch_handler = (uint32_t *) &fmc516[id]->CH2_CTL;
            break;
        case FMC516_ISLA216_ADC3:
            fmc_ch_handler = (uint32_t *) &fmc516[id]->CH3_CTL;
            break;

        default:
            fmc_ch_handler = (uint32_t *) &fmc516[id]->CH0_CTL;
    }

    /* All masks are the asme for all channels. Use the first one */
    /* All Read/Write macros are the same for all channels. Use the first one */
    if (clk_dly != -1) {
        /* Clear clk delay bits and write the desired value*/
        *fmc_ch_handler = (*fmc_ch_handler & ~FMC516_CH0_CTL_CLK_CHAIN_DLY_MASK) |
                            FMC516_CH0_CTL_CLK_CHAIN_DLY_W(clk_dly);

        if (commit)
            fmc516_update_clk_dly(id);
    }

    if (data_dly != -1) {
        *fmc_ch_handler = (*fmc_ch_handler & ~FMC516_CH0_CTL_DATA_CHAIN_DLY_MASK) |
                          FMC516_CH0_CTL_DATA_CHAIN_DLY_W(data_dly);

        if (commit)
            fmc516_update_data_dly(id);
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

uint32_t fmc516_read_adc0(unsigned int id)
{
    return FMC516_CH0_STA_VAL_R(fmc516[id]->CH0_STA);
}

uint32_t fmc516_read_adc1(unsigned int id)
{
    return FMC516_CH1_STA_VAL_R(fmc516[id]->CH1_STA);
}

uint32_t fmc516_read_adc2(unsigned int id)
{
    return FMC516_CH2_STA_VAL_R(fmc516[id]->CH2_STA);
}

uint32_t fmc516_read_adc3(unsigned int id)
{
    return FMC516_CH3_STA_VAL_R(fmc516[id]->CH3_STA);
}

// ADC delay falling edge control
void fmc516_fe_dly(unsigned int id, int ch, int fe_dly_d1, int fe_dly_d2)
{
    uint32_t *fmc_ch_handler;
    uint32_t fe_dly_reg = 0;

    switch(ch) {
        case FMC516_ISLA216_ADC0:
            fmc_ch_handler = (uint32_t *) &fmc516[id]->CH0_DLY_CTL;
            break;
        case FMC516_ISLA216_ADC1:
            fmc_ch_handler = (uint32_t *) &fmc516[id]->CH1_DLY_CTL;
            break;
        case FMC516_ISLA216_ADC2:
            fmc_ch_handler = (uint32_t *) &fmc516[id]->CH2_DLY_CTL;
            break;
        case FMC516_ISLA216_ADC3:
            fmc_ch_handler = (uint32_t *) &fmc516[id]->CH3_DLY_CTL;
            break;

        default:
            fmc_ch_handler = (uint32_t *) &fmc516[id]->CH0_DLY_CTL;
    }

    if (fe_dly_d2)
        fe_dly_reg = FMC516_CH0_DLY_CTL_FE_DLY_W(0x3);
    else if (fe_dly_d1)
        fe_dly_reg = FMC516_CH0_DLY_CTL_FE_DLY_W(0x1);

    *fmc_ch_handler = fe_dly_reg;
}
