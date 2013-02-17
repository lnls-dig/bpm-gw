//#include <inttypes.h>

#include "board.h"
#include "ethmac_adapt.h"    // Etherbone MAC Adapter device functions
#include "debug_print.h"

// Global handler.
ethmac_adapt_t *ethmac_adapt;

int ethmac_adapt_init(/*gpio_t * gpio, int id*/)
{
	if (ethmac_adapt_devl->devices){
		// get first device found
		ethmac_adapt = (ethmac_adapt_t *)ethmac_adapt_devl->devices->base;//BASE_ETHAMC_ADAPTER;
		return 0;
	}

	return -1;
}

int ethmac_adapt_set_base(unsigned int base_rx, unsigned int base_tx)
{
	ethmac_adapt->base_rx = base_rx;
	ethmac_adapt->base_tx = base_tx;

	return 0;
}

int ethmac_adapt_set_length(unsigned int length)
{
	ethmac_adapt->length = length;

	return 0;
}

int ethmac_adapt_go(void)
{
	// write anything to trigger a transaction
	ethmac_adapt->doit = 1;

	return 0;
}



