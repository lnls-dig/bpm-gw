// Parts taken from pts (http://www.ohwr.org/projects/pts/repository)
// Parts taken from wr-switch-sw (http://www.ohwr.org/projects/wr-switch-sw/repository)

#include <inttypes.h>

#include "board.h"      // Board definitions: SPI device structure
#include "onewire.h"        // SPI device functions
#include "memmgr.h"     // malloc and free clones

// Global SPI handler.
onewire_t **onewire;

int onewire_init(void)
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

    while(oc_spi_poll(id));

    *out = spi[id]->RX0;

    return 0;
}

