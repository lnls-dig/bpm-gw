#ifndef _UART_H_
#define _UART_H_

#include "wb_uart.h"

/* Type definitions */
typedef volatile struct UART_WB  * uart_t;

int mprintf(char const *format, ...);

void uart_init(uart_t uart);
void uart_write_byte(uart_t uart, unsigned char c);
int uart_poll(uart_t uart);
int uart_read_byte(uart_t uart);
  
#endif
