#ifndef __DMA_H
#define __DMA_H

#include "inttypes.h"
#include "board.h"

/* 	
	This structure must conform to what it is specified in the
	FPGA software-acessible registers. See general-cores/cores/wishbone/wb_dma.vhd
*/	
struct DMA_WB
{
	uint32_t RD_ADDR;       /* Read issue address register */
	uint32_t WR_ADDR;       /* Write issue address register */
	uint32_t RD_STRD;       /* Read stride */
	uint32_t WR_STRD;       /* Write stride */
    uint32_t TR_COUNT;      /* Transfer count */
};

typedef volatile struct DMA_WB * dma_t;

/* DMA user interface */
int read_is_addr(dma_t dma);
void write_is_addr(dma_t dma, int addr);
int read_strd(dma_t dma);
void write_strd(dma_t dma, int strd);
int read_tr_count(dma_t dma);
      
#endif
        
