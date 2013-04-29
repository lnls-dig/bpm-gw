#ifndef _BOARD_H_
#define _BOARD_H_

#include <hw/memlayout.h>

/****************************/
/*    General Definitions  */
/****************************/
/* CPU Clock frequency in hertz */
#define CPU_CLOCK 100000000ULL

/* Baud rate of the builtin UART (does not apply to the VUART) */
#define UART_BAUDRATE 115200ULL

/* Ethernet MAC definitions */
// dynamic defined through SDB
#define ETH0_IRQ 0
//#define ETH0_PHY 0
// Taken from ML605 user manual
#define ETH0_PHY 0x7U

#define ETH_MACADDR5 0x2d
#define ETH_MACADDR4 0x53
#define ETH_MACADDR3 0x02
#define ETH_MACADDR2 0x35
#define ETH_MACADDR1 0x0a
#define ETH_MACADDR0 0x00

/*
 * Buffer number (must be 2^n)
 */
#define OETH_RXBD_NUM 8
#define OETH_TXBD_NUM 8
#define OETH_RXBD_NUM_MASK (OETH_RXBD_NUM-1)
#define OETH_TXBD_NUM_MASK (OETH_TXBD_NUM-1)

/*
 * Buffer size
 */
//#define BUFF_SIZE (0x600-4)
#define BUFF_SIZE (0x600)
#define OETH_RX_BUFF_SIZE BUFF_SIZE
#define OETH_TX_BUFF_SIZE BUFF_SIZE

/****************************/
/*           IDs            */
/****************************/

/*
 * IDs of general components
 */
#define GEN_LED_GPIO_ID 0
#define GEN_BUTTON_GPIO_ID 1

#define FMC150_ID 0
#define FMC516_ID 0
#define TICS_ID 0

/*
 * IDs of FMC516 components
 */
#define FMC516_SYS_I2C_ID 0
#define FMC516_VCXO_I2C_ID 1
#define FMC516_ISLA216P25_SPI_ID 0
#define FMC516_LMK02000_SPI_ID 1
#define FMC516_DS2431_OWR_ID 0
#define FMC516_DS2432_OWR_ID 1

int board_init();
int board_update();

int delay(int x);

#endif
