// Parts taken from pts (http://www.ohwr.org/projects/pts/repository)
// Parts taken from wr-switch-sw (http://www.ohwr.org/projects/wr-switch-sw/repository)

#include <inttypes.h>

#include "board.h"      // Board definitions: SPI device structure
#include "spi.h"        // SPI device functions
#include "memmgr.h"     // malloc and free clones
#include "debug_print.h"

#define SPI_DELAY 300

// Global SPI handler.
spi_t **spi;
static uint32_t *spi_config;

int spi_init(void)
{
    int i;
    struct dev_node *dev_p = 0;

    if (!spi_devl->devices)
        return -1;

    // get all base addresses
    spi = (spi_t **) memmgr_alloc(sizeof(spi)*spi_devl->size);
    spi_config = (uint32_t *) memmgr_alloc(sizeof(spi_config)*spi_devl->size);

    DBE_DEBUG(DBG_SPI | DBE_DBG_INFO, "> spi size: %d\n", spi_devl->size);

    for (i = 0, dev_p = spi_devl->devices; i < spi_devl->size;
        ++i, dev_p = dev_p->next) {
        spi[i] = (spi_t *) dev_p->base;
        // Default configuration
        spi[i]->DIVIDER = DEFAULT_SPI_DIVIDER & SPI_DIV_MASK;
        spi_config[i] = SPI_CTRL_ASS | SPI_CTRL_TXNEG;
        spi[i]->CTRL = spi_config[i];
        DBE_DEBUG(DBG_SPI | DBE_DBG_INFO, "> spi addr[%d]: %08X\n", i, spi[i]);
        DBE_DEBUG(DBG_SPI | DBE_DBG_INFO, "> spi rx0 addr[%d]: %08X\n", i, &spi[i]->RX0);
        DBE_DEBUG(DBG_SPI | DBE_DBG_INFO, "> spi tx0 addr[%d]: %08X\n", i, &spi[i]->TX0);
        DBE_DEBUG(DBG_SPI | DBE_DBG_INFO, "> spi rx1 addr[%d]: %08X\n", i, &spi[i]->RX1);
        DBE_DEBUG(DBG_SPI | DBE_DBG_INFO, "> spi tx1 addr[%d]: %08X\n", i, &spi[i]->TX1);
        DBE_DEBUG(DBG_SPI | DBE_DBG_INFO, "> spi rx2 addr[%d]: %08X\n", i, &spi[i]->RX2);
        DBE_DEBUG(DBG_SPI | DBE_DBG_INFO, "> spi tx2 addr[%d]: %08X\n", i, &spi[i]->TX2);
        DBE_DEBUG(DBG_SPI | DBE_DBG_INFO, "> spi rx3 addr[%d]: %08X\n", i, &spi[i]->RX3);
        DBE_DEBUG(DBG_SPI | DBE_DBG_INFO, "> spi tx3 addr[%d]: %08X\n", i, &spi[i]->TX3);
        DBE_DEBUG(DBG_SPI | DBE_DBG_INFO, "> spi ctrl addr[%d]: %08X\n", i, &spi[i]->CTRL);
        DBE_DEBUG(DBG_SPI | DBE_DBG_INFO, "> spi divider addr[%d]: %08X\n", i, &spi[i]->DIVIDER);
        DBE_DEBUG(DBG_SPI | DBE_DBG_INFO, "> spi ss addr[%d]: %08X\n", i, &spi[i]->SS);
        DBE_DEBUG(DBG_SPI | DBE_DBG_INFO, "> reading some fields back:\n");
        DBE_DEBUG(DBG_SPI | DBE_DBG_INFO, "> spi ctrl_busy: %08X\n", spi[i]->CTRL & SPI_CTRL_GO_BSY);
        DBE_DEBUG(DBG_SPI | DBE_DBG_INFO, "> spi ctrl_ass: %08X\n", spi[i]->CTRL & SPI_CTRL_ASS);
        DBE_DEBUG(DBG_SPI | DBE_DBG_INFO, "> spi ctrl_txneg: %08X\n", spi[i]->CTRL & SPI_CTRL_TXNEG);
        DBE_DEBUG(DBG_SPI | DBE_DBG_INFO, "> spi ctrl_lsb: %08X\n", spi[i]->CTRL & SPI_CTRL_LSB);
        DBE_DEBUG(DBG_SPI | DBE_DBG_INFO, "> spi ctrl_dir: %08X\n", spi[i]->CTRL & SPI_CTRL_DIR);
        DBE_DEBUG(DBG_SPI | DBE_DBG_INFO, "> spi ctrl_three_mode: %08X\n", spi[i]->CTRL & SPI_CTRL_THREE_WIRE);
    }
    //spi = (spi_t *)spi_devl->devices->base;;
    return 0;
}

void spi_exit(void)
{
    memmgr_free(spi);
    memmgr_free(spi_config);
}

int oc_spi_poll(unsigned int id)
{
    return (spi[id]->CTRL & SPI_CTRL_BSY) ? 1 : 0;
}

int oc_spi_three_mode(unsigned int id)
{
    return spi[id]->CTRL & SPI_CTRL_THREE_WIRE;
}

void oc_spi_config(unsigned int id, int ass, int rx_neg, int tx_neg,
                    int lsb, int ie)
{
    spi_config[id] = 0;

    if(ass)
        spi_config[id] |= SPI_CTRL_ASS;

    if(tx_neg)
        spi_config[id] |= SPI_CTRL_TXNEG;

    if(rx_neg)
        spi_config[id] |= SPI_CTRL_RXNEG;

    if(lsb)
        spi_config[id] |= SPI_CTRL_LSB;

    if(ie)
        spi_config[id] |= SPI_CTRL_IE;
}

// For use only with spi three-wire mode
int oc_spi_three_mode_tx(unsigned int id, int ss, int nbits, uint32_t in)
{
    // Write configuration to SPI core. SPI_CTRL_DIR = 1
    spi[id]->CTRL = spi_config[id] | SPI_CTRL_DIR | SPI_CTRL_CHAR_LEN(nbits);

    // Transmit to core
    spi[id]->TX0 = in;
    //spi[id]->TX1 = 0;
    //spi[id]->TX2 = 0;
    //spi[id]->TX3 = 0;
    DBE_DEBUG(DBG_SPI | DBE_DBG_TRACE, "> spi[id]->TX0: 0x%8X\n", spi[id]->TX0);
    DBE_DEBUG(DBG_SPI | DBE_DBG_TRACE, "> spi[id]->RX0: 0x%8X\n", spi[id]->RX0);

    spi[id]->SS = (1 << ss);

    // Initiate transaction
    spi[id]->CTRL |= SPI_CTRL_GO_BSY;

    // Wait for completion
    DBE_DEBUG(DBG_SPI | DBE_DBG_TRACE, "> waiting for spi...\n");
    while(oc_spi_poll(id))
       delay(SPI_DELAY);

    delay(SPI_DELAY);

    DBE_DEBUG(DBG_SPI | DBE_DBG_TRACE, "> spi[id]->TX0: 0x%8X\n", spi[id]->TX0);
    DBE_DEBUG(DBG_SPI | DBE_DBG_TRACE, "> spi[id]->RX0: 0x%8X\n", spi[id]->RX0);

    return 0;
}

// For use only with spi three-wire mode
int oc_spi_three_mode_rx(unsigned int id, int ss, int nbits, uint32_t *out)
{
    // Write configuration to SPI core. SPI_CTRL_DIR = 0
    spi[id]->CTRL = spi_config[id] | SPI_CTRL_CHAR_LEN(nbits);
    spi[id]->SS = (1 << ss);

    DBE_DEBUG(DBG_SPI | DBE_DBG_TRACE, "> spi[id]->TX0: 0x%8X\n", spi[id]->TX0);
    DBE_DEBUG(DBG_SPI | DBE_DBG_TRACE, "> spi[id]->RX0: 0x%8X\n", spi[id]->RX0);

    // Initiate transaction
    spi[id]->CTRL |= SPI_CTRL_GO_BSY;

    // Wait for reception
    DBE_DEBUG(DBG_SPI | DBE_DBG_TRACE, "> waiting for spi...\n");
    while(oc_spi_poll(id))
       delay(SPI_DELAY);

    delay(SPI_DELAY);

    *out = spi[id]->RX0;

    DBE_DEBUG(DBG_SPI | DBE_DBG_TRACE, "> spi[id]->TX0: 0x%8X\n", spi[id]->TX0);
    DBE_DEBUG(DBG_SPI | DBE_DBG_TRACE, "> spi[id]->RX0: 0x%8X\n", spi[id]->RX0);

    return 0;
}

int oc_spi_txrx(unsigned int id, int ss, int nbits, uint32_t in, uint32_t *out)
{
    uint32_t rval;

    // Avoid breaking the code when just issuing a read command (out can be null)
    if (!out)
        out = &rval;

    // Write configuration to SPI core
    spi[id]->CTRL = spi_config[id] | SPI_CTRL_CHAR_LEN(nbits);

    // Transmit to core
    spi[id]->TX0 = in;

    // Receive from core
    spi[id]->SS = (1 << ss);
    spi[id]->CTRL |= SPI_CTRL_GO_BSY;

    DBE_DEBUG(DBG_SPI | DBE_DBG_TRACE, "> waiting for spi...\n");
    while(oc_spi_poll(id))
       delay(SPI_DELAY);

    *out = spi[id]->RX0;

    return 0;
}
