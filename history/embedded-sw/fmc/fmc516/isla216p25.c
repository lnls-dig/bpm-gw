/*
 * Copyright (C) 2013 LNLS (www.lnls.br)
 * Author: Lucas Russo <lucas.russo@lnls.br>
 *
 * Released according to the GNU GPL, version 2 or any later version.
 */

#include <inttypes.h>

#include "board.h"      // Board definitions: SPI device structure
#include "spi.h"        // SPI device functions
#include "isla216p25.h"
#include "isla216p25_regs.h"
#include "debug_print.h"

/*
 * Which SPI ID is isla216p25? See board.h for definitions.
 * Should be dynamically detected...
 */

static void fmc516_isla216_load_regset(const struct default_dev_regs_t *regs, int ss);
static void fmc516_isla216_write_instaddr_raw(uint32_t val, int ss);
static void fmc516_isla216_readw_raw(uint32_t *val, int ss);
static void fmc516_isla216_writew_raw(uint32_t val, int ss);

int fmc516_isla216_all_init()
{
    int i;

    for (i = 0; i < FMC516_NUM_ISLA216; ++i)
        fmc516_isla216_load_regset(isla216p25_regs_default, i);

    return 0;
}

int fmc516_isla216_init(int ss)
{
    fmc516_isla216_load_regset(isla216p25_regs_default, ss);
    return 0;
}

// isla216p25 has 16 bits for instruction/address: addr(13)+length(2)+rw(1)
static void fmc516_isla216_write_instaddr_raw(uint32_t val, int ss)
{
    // three-wire mode
    oc_spi_three_mode_tx(FMC516_ISLA216P25_SPI_ID, ss,
                    FMC516_ISLA216_INSTADDR_SIZE, val);
}

static void fmc516_isla216_readw_raw(uint32_t *val, int ss)
{
    // three-wire mode
    oc_spi_three_mode_rx(FMC516_ISLA216P25_SPI_ID, ss,
                    FMC516_ISLA216_WORD_SIZE, val);
}

static void fmc516_isla216_writew_raw(uint32_t val, int ss)
{
    // three-wire mode
    oc_spi_three_mode_tx(FMC516_ISLA216P25_SPI_ID, ss,
                    FMC516_ISLA216_WORD_SIZE, val);
}

void fmc516_isla216_write_instaddr(int addr, int length, int read, int ss)
{
    uint32_t fmc516_isla216_reg;

    // 1-byte length
    fmc516_isla216_reg = FMC516_ISLA216_ADDR(addr) |
                            FMC516_ISLA216_LENGTH(length-1);

    if (read)
        fmc516_isla216_reg |= FMC516_ISLA216_READ;

    fmc516_isla216_write_instaddr_raw(fmc516_isla216_reg, ss);
}
//ISLA216_CALSTATUS_REG
// word is 8-bit (1 byte) long for isla216p25
int fmc516_isla216_read_byte(int addr, int ss)
{
    uint32_t val;

    // TESTING! LENGTH MUST BE 1
    fmc516_isla216_write_instaddr(addr, 1, 1, ss);

    // Read the desired byte
    fmc516_isla216_readw_raw(&val, ss);

    DBE_DEBUG(DBG_SPI | DBE_DBG_TRACE, "fmc_read_byte: 0X%8X\n", val);

    return val & 0xff;
}

void fmc516_isla216_write_byte(int val, int addr, int ss)
{
    fmc516_isla216_write_instaddr(addr, 1, 0, ss);

    // Write the desired byte
    fmc516_isla216_writew_raw(val, ss);
}

// Read up to 4 bytes
int fmc516_isla216_read_n(int addr, int length, int ss)
{
    int i;
    int ret = 0;
    int mask = 0;
    uint32_t fmc516_isla216_val;

    // n-byte length
    fmc516_isla216_write_instaddr(addr, length, 1, ss);

    // Read the desired bytes
    for (i = 0; i < length; ++i) {
        fmc516_isla216_readw_raw(&fmc516_isla216_val, ss);
        ret |= (fmc516_isla216_val & 0xff) << 8*i;
        mask |= (0xff << 8*i);
    }

    return ret & mask;
}

// Write up to 4 bytes
void fmc516_isla216_write_n(int val, int addr, int length, int ss)
{
    int i;

    // n-byte length
    fmc516_isla216_write_instaddr(addr, length, 0, ss);

    // Write the desired bytes
    for (i = 0; i < length; ++i) {
        fmc516_isla216_writew_raw(val >> 8*i, ss);
    }
}

static void fmc516_isla216_load_regset(const struct default_dev_regs_t *regs, int ss)
{
    int i = 0;

    while (regs[i].type != REGS_DEFAULT_END){
        if (regs[i].type == REGS_DEFAULT_INIT)
            fmc516_isla216_write_byte(regs[i].val, regs[i].addr, ss);
        ++i;
    }
}

/*
 * Specififc ISLA216P Functions
 */

int fmc516_isla216_chkcal_stat(int ss)
{
    return fmc516_isla216_read_byte(ISLA216_CALSTATUS_REG, ss) & 0x01;
}

void fmc516_isla216_test_ramp(int ss)
{
    fmc516_isla216_write_byte(ISLA216_OUT_TESTMODE(ISLA216_OUT_TESTIO_RAMP),
                                ISLA216_TESTIO_REG, ss);
}

void fmc516_isla216_test_midscale(int ss)
{
    fmc516_isla216_write_byte(ISLA216_OUT_TESTMODE(ISLA216_OUT_TESTIO_MIDSHORT),
                                ISLA216_TESTIO_REG, ss);
}

int fmc516_isla216_get_chipid(int ss)
{
    return fmc516_isla216_read_byte(ISLA216_CHIPID_REG, ss) & 0xff;
}

int fmc516_isla216_get_chipver(int ss)
{
    return fmc516_isla216_read_byte(ISLA216_CHIPVER_REG, ss) & 0xff;
}
