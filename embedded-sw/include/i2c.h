#ifndef _I2C_H_
#define _I2C_H_

/* Hardware definitions */
#include <hw/wb_i2c.h>

/*
 *              wb_clk_i
 * prescaler = --------- - 1
 *               5*scl
 *
 * For wb_clk_i = 100MHz and desired scl = 100 KHz:
 *   prescaler = 0.2*10^3 - 1
 */

#define DEFAULT_I2C_PRESCALER 100

/* Type definitions */
typedef volatile struct I2C_WB i2c_t;

/* I2C API */


#endif
