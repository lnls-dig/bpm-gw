#ifndef _BOARD_H_
#define _BOARD_H_

/* Automate the address peripheral discover */
/****************************/
/*    General Definitions   */
/****************************/
/* CPU Clock frequency in hertz */
#define CPU_CLOCK 100000000ULL

/*************************/
/*    Base addresses     */
/*************************/

/* RAM Definitions */
/* First RAM port */
#define BASE_RAM_PORT_0 0x00000000
/* Second RAM port */
#define BASE_RAM_PORT_1 0x10000000

/* DMA definitions */
#define BASE_DMA_ADDR 0x20000400

/* FMC definitions */
#define BASE_FMC150_ADDR 0x20000500

/* Simple UART definitions */
#define BASE_UART_ADDR 0x20000600
/* UART Baud Rate */
#define UART_BAUDRATE 115200ULL

/* Simple LED GPIO definitions */
#define BASE_LEDS_ADDR 0x20000700

/* Simple Button GPIO definitions */
#define BASE_BUTTONS_ADDR 0x20000800
  
#endif
