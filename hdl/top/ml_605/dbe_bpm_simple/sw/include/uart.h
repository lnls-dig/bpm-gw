#ifndef _UART_H_
#define _UART_H_

/* Hardware definitions */
#include <hw/wb_vuart.h>

/* Type definitions */
typedef volatile struct UART_WB * uart_t;

int mprintf(char const *format, ...);

/* UART API */
void uart_init(uart_t uart);
void uart_write_byte(uart_t uart, int b);
void uart_write_string(uart_t uart, char *s);
int uart_poll(uart_t uart);
int uart_read_byte(uart_t uart);

#endif
