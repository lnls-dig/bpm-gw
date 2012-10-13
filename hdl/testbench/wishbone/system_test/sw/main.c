#include "gpio.h"
#include "dma.h"
//#include "fmc150.h"
#include "uart.h"

/* 	Each loop iteration takes 4 cycles.
* 	It runs at 100MHz.
* 	Sleep 0.2 second.
*/
#define LED_DELAY (100000000/4/5)
#define UART_DELAY (100000000/4/5)

static inline int delay(int x)
{
  while(x--) asm volatile("nop");
}

/* Placeholder for IRQ vector */
void _irq_entry(void){}

int main(void)
{
	int i, j;
	gpio_t leds = (volatile struct GPIO_WB *) BASE_LEDS_ADDR;
	gpio_t buttons = (volatile struct GPIO_WB *) BASE_BUTTONS_ADDR;
    dma_t dma = (volatile struct DMA_WB *) BASE_DMA_ADDR;
    uart_t uart = (volatile struct UART_WB *) BASE_UART_ADDR;

    /* Initialize Board. Should be in a speparete function and file */
	uart_init(uart);

    /* It would be nice to employ a callback system. For this to work,
        a hardware timer should be running with a eishbone interface
        and a interrupt pin to LM32 processor */

    /* Test UART */
	uart_write_byte(uart, 'A');
    delay(UART_DELAY);
	uart_write_byte(uart, 'B');
    delay(UART_DELAY);
	uart_write_byte(uart, 'C');
    delay(UART_DELAY);
	uart_write_byte(uart, 'D');
    delay(UART_DELAY);
	uart_write_byte(uart, 'E');
    delay(UART_DELAY);
	uart_write_byte(uart, 'F');
    delay(UART_DELAY);
	uart_write_byte(uart, 'G');
    delay(UART_DELAY);
	uart_write_byte(uart, 'H');
    delay(UART_DELAY);

    /* Test LEDs */
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
 	}

	return 0;
}
