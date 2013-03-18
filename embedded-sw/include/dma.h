#ifndef _DMA_H_
#define _DMA_H_

#include "inttypes.h"

/*
     This structure must conform to what it is specified in the
     FPGA software-acessible registers. See general-cores/cores/wishbone/wb_dma.vhd
 */
struct DMA_WB
{
    uint32_t RD_ADDR;            /* Read issue address register */
    uint32_t WR_ADDR;            /* Write issue address register */
    uint32_t RD_STRD;            /* Read stride */
    uint32_t WR_STRD;            /* Write stride */
    uint32_t TR_COUNT;          /* Transfer count */
};

typedef volatile struct DMA_WB dma_t;

/* DMA user interface */
int dma_init(void);
int read_is_addr(unsigned int id);
void write_is_addr(unsigned int id, int addr);
int read_strd(unsigned int id);
void write_strd(unsigned int id, int strd);
int read_tr_count(unsigned int id);

#endif

