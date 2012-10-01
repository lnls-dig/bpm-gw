#ifndef __BOARD_H
#define __BOARD_H

/* Automate the address peripheral discover */
#define BASE_DMA_ADDR 0x20000400
#define BASE_LEDS_ADDR 0x20000500
#define BASE_BUTTONS_ADDR 0x20000600

static inline int delay(int x)
{
  while(x--) asm volatile("nop");
}
  
#endif
