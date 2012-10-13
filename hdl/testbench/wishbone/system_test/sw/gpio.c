#include "gpio.h"

/* GPIO user interface definition */
inline void gpio_out(gpio_t gpio, int pin, int val)
{
	if(val)
		gpio->SODR = (1<<pin);
	else
		gpio->CODR = (1<<pin);
}

inline void gpio_dir(gpio_t gpio, int pin, int val)
{
	if(val)
		gpio->DDR |= (1<<pin);
  	else
    	gpio->DDR &= ~(1<<pin);
}

inline int gpio_in(gpio_t gpio, int pin)
{
  return gpio->PSR & (1<<pin) ? 1 : 0;
}
