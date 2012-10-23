#include "gpio.h"     // GPIO device funtions
#include "dma.h"      // DMA device functions
#include "fmc150.h"		// FMC150 device functions
#include "uart.h"     // UART device functions
#include "memmgr.h"   // memory pool functions
#include "board.h"		// board definitions

/* 	Each loop iteration takes 4 cycles.
* 	It runs at 100MHz.
* 	Sleep 0.2 second.
*/
#define LED_DELAY (100000000/4/5)
#define UART_DELAY (100000000/4/5)
#define NUM_LED_BLINK 16

/* Placeholder for IRQ vector */
void _irq_entry(void){}

int dbe_init(void)
{
  // Initialize memory pool
  memmgr_init();

  // Fill SDB device structures
  sdb_find_devices();

  // Initialize specific components
  if(uart_init() == -1)
    return -1;

  if(dma_init() == -1)
    return -1;

  if(gpio_init() == -1)
    return -1;

  return 0;
}

void print_header(void)
{
	mprintf("---------------------------------------\n");
  mprintf("|       DBE EXAMPLE APPLICATION       |\n\n");
  mprintf("| This application aims to demostrate |\n");
  mprintf("| the capabilities of the DBE project |\n");
	mprintf("---------------------------------------\n\n");
}

void memmgr_test(void)
{
  /* Simple Memory Pool Test */
  char *p = (char *)memmgr_alloc(100*sizeof(char));
  
  mprintf("---------------------------------------\n");
  mprintf("      		Memory pool test        			\n");
	mprintf("---------------------------------------\n\n");
  
  if(p){
    strcpy(p, "This is a dynamic allocated string with memory pool\n\n");
    mprintf(p);
    mprintf("\tTest passed!\n");
  }
  else
    mprintf("\tTest failed. Could not allocate memory!\n");
    
  memmgr_print_stats();
      
  mprintf("---------------------------------------\n");
  
  memmgr_free(p);
}

void leds_test(void)
{
  /* Simple LEDs test */
  int i;

  mprintf("---------------------------------------\n");
  mprintf("\tLed test\n");
  mprintf("---------------------------------------\n\n");
  mprintf("\tTesting LEDs...\n");
	/* Rotate the LEDs  */
	for (i = 0; i < NUM_LED_BLINK; ++i){
		// Set led at position i
		gpio_out(i, 1);
	  
		/* Each loop iteration takes 4 cycles.
		* It runs at 100MHz.
		* Sleep 0.2 second.
		*/
		delay(LED_DELAY);

		// Clear led at position i
		gpio_out(i, 0);
  }   
  
  // End test with 4 leds set
  gpio_out(0, 1);
  gpio_out(1, 1);
  gpio_out(2, 1);
  gpio_out(3, 1);
}

void fmc150_test()
{
  mprintf("---------------------------------------\n");
  mprintf("\tFMC150 test\n");
  mprintf("---------------------------------------\n\n");
	mprintf("\tTesting FMC150 CDCE72010 regs...\n");
	init_cdce72010(); 
	mprintf("Done!\n");
}

int main(void)
{
	int i, j;
  char *p;

  // Board initialization
  if(board_init() == -1)
    return -1;

  // General initialization
  if(dbe_init() == -1){
    mprintf("Error initializing DBE Board! Exiting...\n");
    return -1;
  }
  
  print_header();

  /* It would be nice to employ a callback system. For this to work,
      a hardware timer should be running with a wishbone interface
      and a interrupt pin to LM32 processor */
      
  /* Output memory layout */
	sdb_print_devices();
      
  /* Test memory pool */
  memmgr_test();

    /* Test leds */
  leds_test();
  
  /* FMC150 test */
  fmc150_test();

	return 0;
}
