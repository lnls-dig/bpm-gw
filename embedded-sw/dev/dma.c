#include "board.h"			// Board definitions: DMA device structure
#include "dma.h"				// DMA device functions

// Global DMA handler.
dma_t *dma;

int dma_init(void)
{
	if (dma_devl->devices){
		// get first dma device found
		dma = (dma_t *)dma_devl->devices->base;//BASE_DMA;
		return 0;
	}

	return -1;
}

/* DMA user interface definition */
int read_is_addr(void)
{
	return dma->RD_ADDR;
}

void write_is_addr(int addr)
{
	dma->WR_ADDR = (uint32_t)addr;
}

int read_strd(void)
{
	return dma->RD_STRD;
}

void write_strd(int strd)
{
	dma->WR_STRD = (uint32_t) strd;
}

int read_tr_count(void)
{
	return dma->TR_COUNT;
}
