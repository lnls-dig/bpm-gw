#ifndef _GPIO_H_
#define _GPIO_H_

#include "inttypes.h"
#include "board.h"

/* 	
	This structure must conform to what it is specified in the
	FPGA software-acessible registers. See general-cores/cores/wishbone/wb_gpio_port.vhd
*/	
struct GPIO_WB
{
	uint32_t CODR;  /* Clear output register */
	uint32_t SODR;  /* Set output register */
	uint32_t DDR;   /* Data direction register (1 means out) */
	uint32_t PSR;   /* Pin state register */
};

typedef volatile struct GPIO_WB * gpio_t;
//static volatile struct GPIO_WB *__gpio = (volatile struct GPIO_WB *) BASE_GPIO;

/* GPIO user interface */
void gpio_out(gpio_t gpio, int pin, int val);
void gpio_dir(gpio_t gpio, int pin, int val);
int gpio_in(gpio_t gpio, int pin);
      
#endif
        
