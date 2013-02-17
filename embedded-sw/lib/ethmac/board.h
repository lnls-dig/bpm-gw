#ifndef BOARD_H
#define BOARD_H

#define ETH0_BASE 0x80000000U
#define ETH0_BUF  0x90000000U
#define ETH0_IRQ 0
#define ETH0_PHY 0

#define ETH_MACADDR5 0x92
#define ETH_MACADDR4 0x76
#define ETH_MACADDR3 0x48
#define ETH_MACADDR2 0xe8
#define ETH_MACADDR1 0x24
#define ETH_MACADDR0 0x00

/* Buffer number (must be 2^n) 
 */
#define OETH_RXBD_NUM		4
#define OETH_TXBD_NUM		4
#define OETH_RXBD_NUM_MASK	(OETH_RXBD_NUM-1)
#define OETH_TXBD_NUM_MASK	(OETH_TXBD_NUM-1)

/* Buffer size 
 */
#define BUFF_SIZE		0x600
#define OETH_RX_BUFF_SIZE	BUFF_SIZE
#define OETH_TX_BUFF_SIZE	BUFF_SIZE

#endif
