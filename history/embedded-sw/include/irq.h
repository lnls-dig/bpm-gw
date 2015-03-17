#ifndef _IRQ_H_
#define _IRQ_H_

static inline void clear_irq()
{
	unsigned int val = 1;
	asm volatile ("wcsr ip, %0"::"r" (val));
}

void disable_irq();
void enable_irq();

#endif
