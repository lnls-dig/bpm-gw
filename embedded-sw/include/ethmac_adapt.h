#ifndef _ETHMAC_ADAPT_H_
#define _ETHMAC_ADAPT_H_

#include "inttypes.h"

struct ETHMAC_ADAPT {
	uint32_t doit;
	uint32_t base_tx;
	uint32_t base_rx;
	uint32_t length;
};

typedef volatile struct ETHMAC_ADAPT ethmac_adapt_t;

/* Ethernet MAC adapter init */
int ethmac_adapt_init(void);

/* User interface */
int ethmac_adapt_set_base(unsigned int id, unsigned int base_rx, unsigned int base_tx);
int ethmac_adapt_set_length(unsigned int id, unsigned int length);
int ethmac_adapt_go(unsigned int id);

#endif

