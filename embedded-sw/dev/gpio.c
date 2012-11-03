#include "board.h"			// Board definitions: GPIO device structure
#include "gpio.h"			 // GPIO device functions

// Global GPIO handler.
gpio_t *gpio;

int gpio_init(gpio_t * gpio, int id)
{
	if (gpio_devl->devices){
		// get first gpio device found
		gpio = (gpio_t *)gpio_devl->devices->base;//BASE_GPIO;
		return 0;
	}

	return -1;
}

/* GPIO user interface definition */
void gpio_out(int pin, int val)
{
	if(val)
		gpio->SODR = (1<<pin);
	else
		gpio->CODR = (1<<pin);
}

void gpio_dir(int pin, int val)
{
	if(val)
		gpio->DDR |= (1<<pin);
	else
		gpio->DDR &= ~(1<<pin);
}

int gpio_in(int pin)
{
	return gpio->PSR & (1<<pin) ? 1 : 0;
}
