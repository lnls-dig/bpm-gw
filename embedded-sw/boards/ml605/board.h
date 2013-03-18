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
//#define ETH0_BASE 0x30015000U   //ethmac_devl
//#define ETH0_BUF  0x20000000U   //ethmac_buf_devl
#define ETH0_BASE 0x30005000U   //ethmac_devl
#define ETH0_BUF  0x20000000U   //ethmac_buf_devl
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

// temporary place for these constants. Testing only!
#define ETH_DEST 0
#define ETH_SOURCE (ETH_DEST+6)
#define ETH_TYPE (ETH_SOURCE+6)
#define ETH_END (ETH_TYPE+2)

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
#define BUFF_SIZE (0x800)
#define OETH_RX_BUFF_SIZE BUFF_SIZE
#define OETH_TX_BUFF_SIZE BUFF_SIZE

int board_init();
int board_update();

int delay(int x);

#endif
