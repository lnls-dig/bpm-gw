#include <inttypes.h>

#include "board.h"
#include "uart.h"

#define CALC_BAUD(baudrate) \
    ( ((( (unsigned long long)baudrate * 8ULL) << (16 - 7)) + \
      (CPU_CLOCK >> 8)) / (CPU_CLOCK >> 7) )

void uart_init(uart_t uart)
{
	uart->BCR = CALC_BAUD(UART_BAUDRATE);
}

void uart_write_byte(uart_t uart, int b)
{
	if (b == '\n')
		uart_write_byte(uart, '\r');
	while (uart->SR & UART_SR_TX_BUSY) ;
	uart->TDR = b;
}

void uart_write_string(uart_t uart, char *s)
{
	while (*s)
		uart_write_byte(uart, *(s++));
}

int uart_poll(uart_t uart)
{
	return uart->SR & UART_SR_RX_RDY;
}

int uart_read_byte(uart_t uart)
{
	if (!uart_poll(uart))
		return -1;

	return uart->RDR & 0xff;
}
