//#include <inttypes.h>

#include "board.h"
#include "ethmac_adapt.h"    // Etherbone MAC Adapter device functions
#include "memmgr.h"
#include "debug_print.h"

// Global handler.
ethmac_adapt_t **ethmac_adapt;

int ethmac_adapt_init(void)
{
    int i;
    struct dev_node *dev_p = 0;

    if (!ethmac_adapt_devl->devices)
        return -1;

    // get all base addresses
    ethmac_adapt = (ethmac_adapt_t **) memmgr_alloc(sizeof(ethmac_adapt_t *)*ethmac_adapt_devl->size);

    for (i = 0, dev_p = ethmac_adapt_devl->devices; i < ethmac_adapt_devl->size;
            ++i, dev_p = dev_p->next) {
        ethmac_adapt[i] = (ethmac_adapt_t *) dev_p->base;
        DBE_DEBUG(DBG_GENERIC | DBE_DBG_INFO, "> ethmac_adapt addr[%d]: %08X\n", i, ethmac_adapt[i]);
    }

    DBE_DEBUG(DBG_GENERIC | DBE_DBG_INFO, "> ethmac_adapt size: %d\n", ethmac_adapt_devl->size);

    return 0;
}

int ethmac_adapt_set_base(unsigned int id, unsigned int base_rx, unsigned int base_tx)
{
    ethmac_adapt[id]->base_rx = base_rx;
    ethmac_adapt[id]->base_tx = base_tx;

    return 0;
}

int ethmac_adapt_set_length(unsigned int id, unsigned int length)
{
    ethmac_adapt[id]->length = length;

    return 0;
}

int ethmac_adapt_go(unsigned int id)
{
    // write anything to trigger a transaction
    ethmac_adapt[id]->doit = 1;

    return 0;
}



