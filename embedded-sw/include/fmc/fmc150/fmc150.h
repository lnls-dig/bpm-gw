#ifndef _FMC150_H_
#define _FMC150_H_

#include "hw/wb_fmc150.h"
#include "debug_print.h"

// Number of CDCE72010 registers
#define CDCE72010_NUMREGS 12

// Global definitions
extern uint32_t cdce72010_regs[CDCE72010_NUMREGS];

/* Type definitions */
typedef volatile struct FMC150_WB fmc150_t;

/* FMC150 user interface */
int fmc150_init(void);
int fmc150_spi_busy(void);

void update_fmc150_adc_delay(uint8_t adc_strobe_delay, uint8_t adc_cha_delay, uint8_t adc_chb_delay);
int read_fmc150_register(uint32_t cs, uint32_t addr, uint32_t* data);
int write_fmc150_register(uint32_t cs, uint32_t addr, uint32_t data);

#endif

