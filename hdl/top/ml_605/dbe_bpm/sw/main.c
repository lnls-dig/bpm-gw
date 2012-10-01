#include "gpio.h"
#include "dma.h"

/* 	Each loop iteration takes 4 cycles.
* 	It runs at 100MHz.
* 	Sleep 0.2 second.
*/
#define LED_DELAY (100000000/4/5)
//#define LED_DELAY 100000000

/* Placeholder for IRQ vector */
void _irq_entry(void){}

int main(void)
{
	int i, j;
	gpio_t leds = (volatile struct GPIO_WB *) BASE_LEDS_ADDR;
	gpio_t buttons = (volatile struct GPIO_WB *) BASE_BUTTONS_ADDR;
    dma_t buttons = (volatile struct DMA_WB *) BASE_DMA_ADDR;

	while (1) {
		/* Rotate the LEDs  */
		for (i = 0; i < 8; ++i) {
			// Set led at position i
			gpio_out(leds, i, 1);
		  
			/* Each loop iteration takes 4 cycles.
			* It runs at 100MHz.
			* Sleep 0.2 second.
			*/
			delay(LED_DELAY);

			// Clear led at position i
			gpio_out(leds, i, 0);
		}

        /* Rotate the LEDs  */
        
 	}

	return 0;
}
