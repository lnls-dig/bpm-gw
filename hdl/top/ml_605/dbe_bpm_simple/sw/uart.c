#include "board.h"
#include "inttypes.h"
#include "uart.h"

#define CALC_BAUD(baudrate) (((((unsigned long long)baudrate*8ULL)<<(16-7))+(CPU_CLOCK>>8))/(CPU_CLOCK>>7))
 
//static volatile struct UART_WB *uart = (volatile struct UART_WB *) BASE_UART;

void uart_init(uart_t uart)
{
	uart->BCR = CALC_BAUD(UART_BAUDRATE);
}

void uart_write_byte(uart_t uart, unsigned char c)
{
    /* wait until not busy */
	while(uart->SR & UART_SR_TX_BUSY);

	uart->TDR = c;
	if(c == '\n')
		uart_write_byte(uart, '\r');
}

int uart_poll(uart_t uart)
{
 	return uart->SR & UART_SR_RX_RDY;
}

int uart_read_byte(uart_t uart)
{
 	return uart->RDR & 0xff;
}
