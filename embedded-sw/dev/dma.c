#include "board.h"          // Board definitions: DMA device structure
#include "dma.h"                // DMA device functions

// Global DMA handler.
//dma_t *dma;
dma_t **dma;

int dma_init(void)
{
    int i;
    struct dev_node *dev_p = 0;

    if (!dma_devl->devices)
        return -1;

    // get all base addresses
    dma = (dma_t **) memmgr_alloc(sizeof(dma_t *)*dma_devl->size);

    //dbg_print("> dma size: %d\n", dma_devl->size);

    for (i = 0, dev_p = dma_devl->devices; i < dma_devl->size;
        ++i, dev_p = dev_p->next) {
        dma[i] = (dma_t *) dev_p->base;
        //dbg_print("> dma addr[%d]: %08X\n", i, gpio[i]);
    }
    //dma = (dma_t *)dma_devl->devices->base;//BASE_GPIO;
    return 0;
}

/* DMA user interface definition */
int read_is_addr(unsigned int id)
{
    return dma[id]->RD_ADDR;
}

void write_is_addr(unsigned int id, int addr)
{
    dma[id]->WR_ADDR = (uint32_t)addr;
}

int read_strd(unsigned int id)
{
    return dma[id]->RD_STRD;
}

void write_strd(unsigned int id, int strd)
{
    dma[id]->WR_STRD = (uint32_t) strd;
}

int read_tr_count(unsigned int id)
{
    return dma[id]->TR_COUNT;
}
