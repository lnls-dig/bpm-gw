#ifndef _ONEWIRE_H_
#define _ONEWIRE_H_

/* Hardware definitions */
#include <hw/wb_onewire.h>

//clk_div_nor = clock divider normal operation, clk_div_nor = Fclk * 5E-6 - 1
//clk_div_ovd = clock divider overdrive operation, clk_div_ovd = Fclk * 1E-6 - 1
// Clock divider for 100MHz bus clock
#define DEFAULT_OWR_DIVIDER_NOR 499
#define DEFAULT_OWR_DIVIDER_OVD 99

/* Type definitions */
typedef volatile struct OWR_WB owr_t;

/* Onewire API */
int owr_init(void);
void owr_exit(void);
int oc_owr_poll(unsigned int id);
int oc_owr_reset(unsigned int id, int port);
int oc_owr_slot(unsigned int id, int port, uint32_t in_bit, uint32_t *out_bit);
int oc_owr_read_bit(unsigned int id, int port, uint32_t *out_bit);
int oc_owr_write_bit(unsigned int id, int port, uint32_t in_bit, uint32_t *out_bit);
int read_byte(unsigned int id, int port, uint32_t *out_byte);
int write_byte(unsigned int id, int port, uint32_t in_byte);


#endif
