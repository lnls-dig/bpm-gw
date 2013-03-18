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
 *   prescaler = 0.2*10^3 - 1 = 199
 */

#define DEFAULT_I2C_PRESCALER 199

/* Type definitions */
typedef volatile struct I2C_WB i2c_t;

/* I2C API */
int i2c_init(void);
void i2c_exit(void);
int oc_i2c_poll(unsigned int id);
int oc_i2c_start(unsigned int id, int addr, int read);
int oc_i2c_rx(unsigned int id, uint32_t *out, int last);
int oc_i2c_tx(unsigned int id, uint32_t in, int last);
int oc_i2c_scan(unsigned int id);


#endif
