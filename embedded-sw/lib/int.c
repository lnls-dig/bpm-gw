#include "int.h"
#include "pp-printf.h"

static struct ihnd handlers[MAX_INT_HANDLERS];

static void set_mask(unsigned int mask) {
	asm volatile ("wcsr IM, %0" : : "r" (mask));
}

static unsigned int get_mask(void) {
	unsigned int mask;
	asm volatile ("rcsr %0, IM" : "=r" (mask));
	return mask;
}

static unsigned int get_pending(void) {
	unsigned int mask;
	asm volatile ("rcsr %0, IP" : "=r" (mask));
	return mask;
}

static void clear_pending(void) {
	unsigned int one = 0xffffffff;
	asm volatile ("wcsr IP, %0" : : "r" (one));
}

//void MicoISRHandler(void) {
void _irq_entry(void){
	unsigned int work = get_pending();
	clear_pending();

	/* flush cache */
	unsigned int one = 1;
	asm volatile ("wcsr DCC, %0" : : "r" (one));
	asm volatile ("nop");
	asm volatile ("nop");
	asm volatile ("nop");
	asm volatile ("nop");

	int i;
	for (i = 0; i < MAX_INT_HANDLERS; ++i)
		if ((work & (1 << i)) != 0 && handlers[i].handler)
			(*handlers[i].handler)(handlers[i].arg);
}

int int_init(void) {
	int i;
	unsigned int on = 1;

	for (i = 0; i < MAX_INT_HANDLERS; ++i) {
		handlers[i].handler = 0;
		handlers[i].arg = 0;
	}

	set_mask(0);

	/* Enable interrupts: */
	//enable_irq();
	asm volatile ("wcsr IE, %0" : : "r" (on));
	return 0;
}

int int_add(unsigned long i, void (*handler)(void*), void* arg) {
	handlers[i].handler = handler;
	handlers[i].arg = arg;
	set_mask(get_mask() | (0x1 << i));
	return 0;
}
