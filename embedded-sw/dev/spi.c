// Parts taken from pts (http://www.ohwr.org/projects/pts/repository)
// Parts taken from wr-switch-sw (http://www.ohwr.org/projects/wr-switch-sw/repository)

#include <inttypes.h>

#include "board.h"      // Board definitions: SPI device structure
#include "spi.h"        // SPI device functions
#include "memmgr.h"     // malloc and free clones

// Global SPI handler.
spi_t **spi;
uint32_t *spi_config;

int spi_init(void)
{
    int i;
    struct dev_node *dev_p = 0;

    if (!spi_devl->devices)
        return -1;

    // get all base addresses
    spi = (spi_t **) memmgr_alloc(sizeof(spi)*spi_devl->size);
    spi_config = (uint32_t *) memmgr_alloc(sizeof(spi_config)*spi_devl->size);

    //dbg_print("> spi size: %d\n", spi_devl->size);

    for (i = 0, dev_p = spi_devl->devices; i < spi_devl->size;
        ++i, dev_p = dev_p->next) {
        spi[i] = (spi_t *) dev_p->base;
        // Default configuration
        spi[i]->DIVIDER = DEFAULT_SPI_DIVIDER & SPI_DIV_MASK;
        spi[i]->CTRL = SPI_CTRL_ASS | SPI_CTRL_TXNEG;
        //dbg_print("> spi addr[%d]: %08X\n", i, spi[i]);
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
    return spi[id]->CTRL & SPI_CTRL_BSY;
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

    spi[id]->SS = (1 << ss);

    // Initiate transaction
    spi[id]->CTRL |= SPI_CTRL_GO_BSY;

    // Wait for completion
    while(oc_spi_poll(id));

    return 0;
}

// For use only with spi three-wire mode
int oc_spi_three_mode_rx(unsigned int id, int ss, int nbits, uint32_t *out)
{
    // Write configuration to SPI core. SPI_CTRL_DIR = 0
    spi[id]->CTRL = spi_config[id] | SPI_CTRL_CHAR_LEN(nbits);
    spi[id]->SS = (1 << ss);

    // Initiate transaction
    spi[id]->CTRL |= SPI_CTRL_GO_BSY;

    // Wait for reception
    while(oc_spi_poll(id));

    *out = spi[id]->RX0;

    return 0;
}

int oc_spi_txrx(unsigned int id, int ss, int nbits, int write, uint32_t in, uint32_t *out)
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

    while(oc_spi_poll(id));

    *out = spi[id]->RX0;

    return 0;
}
