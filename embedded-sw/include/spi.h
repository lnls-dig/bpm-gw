#ifndef _SPI_H_
#define _SPI_H_

/* Hardware definitions */
#include <hw/wb_spi.h>

#define DEFAULT_SPI_DIVIDER 100

/* Type definitions */
typedef volatile struct SPI_WB spi_t;

/* SPI API */
int spi_init(void);
void spi_exit(void);
int oc_spi_poll(unsigned int id);
void oc_spi_config(unsigned int id, int ass, int rx_neg, int tx_neg,
                    int lsb, int ie);
int oc_spi_txrx(unsigned int id, int ss, int nbits, uint32_t in, uint32_t *out);


#endif
