#ifndef _UART_H_
#define _UART_H_

/* Hardware definitions */
#include <hw/wb_vuart.h>

// Default UART index to output text
#define DEFAULT_UART 0

/* Type definitions */
typedef volatile struct UART_WB uart_t;

int mprintf(char const *format, ...);

/* UART API */
int uart_init(void);
int uart_exit(void);
void uart_write_byte(unsigned int id, int b);
void uart_write_string(unsigned int id, char *s);
int puts(const char *s);
int uart_poll(unsigned int id);
int uart_read_byte(unsigned int id);

#endif
