#ifndef _UART_H_
#define _UART_H_

/* Hardware definitions */
#include <hw/wb_vuart.h>

/* Type definitions */
typedef volatile struct UART_WB uart_t;

int mprintf(char const *format, ...);

/* UART API */
int uart_init(void);
void uart_write_byte(int b);
void uart_write_string(char *s);
int puts(const char *s);
int uart_poll(void);
int uart_read_byte(void);

#endif
