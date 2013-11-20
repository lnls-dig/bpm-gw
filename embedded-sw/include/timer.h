#ifndef _TIMER_H_
#define _TIMER_H_

#include "inttypes.h"

#define TICS_PER_SECOND 1000

struct TICS_WB
{
  uint32_t  TICS_REG;
};

typedef volatile struct TICS_WB tics_t;

int timer_init();
int timer_exit();
uint32_t timer_get_tics();
void timer_delay(uint32_t how_long);

#endif
