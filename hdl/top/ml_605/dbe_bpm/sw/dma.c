#include "dma.h"

/* DMA user interface definition */
static inline int read_is_addr(dma_t dma)
{
    return dma->RD_ADDR;
}

static inline void write_is_addr(dma_t dma, int addr)
{
    dma->WR_ADDR = (uint32_t) addr;
}

static inline int read_strd(dma_t dma)
{
    return dma->RD_STRD;
}

static inline void write_strd(dma_t dma, int strd)
{
    dma->WR_STRD = (uint32_t) strd;
}

static inline int read_tr_count(dma_t dma)
{
    return dma->TR_COUNT;
}
      
#endif
        
