/*
 * This work is part of the White Rabbit project
 *
 * Copyright (C) 2011 CERN (www.cern.ch)
 * Author: Tomasz Wlostowski <tomasz.wlostowski@cern.ch>
 * Author: Lucas Russo <lucas.russo@lnls.br>
 *
 * Released according to the GNU GPL, version 2 or any later version.
 */

#include "board.h"
#include "timer.h"
#include "memmgr.h"
#include "debug_print.h"

// Global TICS handler.
tics_t **tics;

int timer_init()
{
    int i;
    struct dev_node *dev_p = 0;

    if (!tics_devl->devices)
        return -1;

    // get all base addresses
    tics = (tics_t **) memmgr_alloc(sizeof(tics_t *)*tics_devl->size);

    for (i = 0, dev_p = tics_devl->devices; i < tics_devl->size;
            ++i, dev_p = dev_p->next) {
        tics[i] = (tics_t *) dev_p->base;
        DBE_DEBUG(DBG_GENERIC | DBE_DBG_INFO,"> timer addr[%d]: %08X\n", i, dev_p->base);
    }

    DBE_DEBUG(DBG_GENERIC | DBE_DBG_INFO, "> timer size: %d\n", tics_devl->size);
    return 0;
}

int timer_exit(void)
{
  memmgr_free(tics);

  return 0;
}

uint32_t timer_get_tics(void)
{
  return tics[TICS_ID]->TICS_REG;
}

/* Alias for lwIP timers */
uint32_t sys_now(void) __attribute__((alias("timer_get_tics")));

void timer_delay(uint32_t how_long)
{
  uint32_t t_start;

  t_start = timer_get_tics();

  while (t_start + how_long > timer_get_tics()) ;
}
