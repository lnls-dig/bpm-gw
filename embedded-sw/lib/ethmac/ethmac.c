//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Ethernet MAC driver functions                               ////
////                                                              ////
////  Description                                                 ////
////  A collection of functions to help control the OpenCores     ////
////  10/100 ethernet mac (ethmac) core.                          ////
////                                                              ////
////                                                              ////
////  Author(s):                                                  ////
////      - Julius Baxter, julius@opencores.org                   ////
////      - Parts taken from Linux kernel's open_eth driver.      ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009,2010 Authors and OPENCORES.ORG            ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

#include "eth-phy-mii.h"
#include "ethmac.h"
#include "board.h"
#include "debug_print.h"

static int next_tx_buf_num;

void eth_mii_write(char phynum, short regnum, short data)
{
	static volatile oeth_regs *regs = (oeth_regs *)(OETH_REG_BASE);
	regs->miiaddress = (regnum << 8) | phynum;
	regs->miitx_data = data;
	regs->miicommand = OETH_MIICOMMAND_WCTRLDATA;
	regs->miicommand = 0;
	while(regs->miistatus & OETH_MIISTATUS_BUSY);
}

short eth_mii_read(char phynum, short regnum)
{
	static volatile oeth_regs *regs = (oeth_regs *)(OETH_REG_BASE);
	regs->miiaddress = (regnum << 8) | phynum;
	regs->miicommand = OETH_MIICOMMAND_RSTAT;
	regs->miicommand = 0;
	while(regs->miistatus & OETH_MIISTATUS_BUSY);

	return regs->miirx_data;
}

void ethmac_setup(int phynum, unsigned int buf)
{
	// from arch/or32/drivers/open_eth.c
	volatile oeth_regs *regs;
	unsigned short cr;

	pp_printf("ethmac_setup:\n");

	regs = (oeth_regs *)(OETH_REG_BASE);

	/* Reset MII mode module */
	regs->miimoder = OETH_MIIMODER_RST; /* MII Reset ON */
	regs->miimoder &= ~OETH_MIIMODER_RST; /* MII Reset OFF */
	regs->miimoder = 0x64; /* Clock divider for MII Management interface */

	/* Reset the controller.
	 */
	regs->moder = OETH_MODER_RST; /* Reset ON */
	regs->moder &= ~OETH_MODER_RST;   /* Reset OFF */

	/* Setting TXBD base to OETH_TXBD_NUM.
	 */
	regs->tx_bd_num = OETH_TXBD_NUM;


	/* Set min/max packet length
	 */
	regs->packet_len = 0x00400600;

	/* Set IPGT register to recomended value
	 */
	regs->ipgt = 0x12;

	/* Set IPGR1 register to recomended value
	 */
	regs->ipgr1 = 0x0000000c;

	/* Set IPGR2 register to recomended value
	 */
	regs->ipgr2 = 0x00000012;

	/* Set COLLCONF register to recomended value
	 */
	regs->collconf = 0x000f003f;

	/* Set control module mode
	 */
#if 0
	regs->ctrlmoder = OETH_CTRLMODER_TXFLOW | OETH_CTRLMODER_RXFLOW;
#else
	regs->ctrlmoder = 0;
#endif

	/* Clear MIIM registers */
	regs->miitx_data = 0;
	regs->miiaddress = 0;
	regs->miicommand = 0;

	regs->mac_addr1 = ETH_MACADDR0 << 8 | ETH_MACADDR1;
	regs->mac_addr0 = ETH_MACADDR2 << 24 | ETH_MACADDR3 << 16 | ETH_MACADDR4 << 8 | ETH_MACADDR5;

	/* Clear all pending interrupts
	 */
	regs->int_src = 0xffffffff;

	/* IFG, CRCEn
	 */
	regs->moder |= OETH_MODER_PAD | OETH_MODER_IFG | OETH_MODER_CRCEN | OETH_MODER_FULLD;

	/* Enable interrupt sources.
	 */

	regs->int_mask = OETH_INT_MASK_TXB    |
		OETH_INT_MASK_TXE   |
		OETH_INT_MASK_RXF   |
		OETH_INT_MASK_RXE   |
		OETH_INT_MASK_BUSY  |
		OETH_INT_MASK_TXC   |
		OETH_INT_MASK_RXC;

	// Buffer setup stuff
	volatile oeth_bd *tx_bd, *rx_bd;
	int i;

	/* Initialize TXBD pointer
	 */
	tx_bd = (volatile oeth_bd *)OETH_BD_BASE;

	/* Initialize RXBD pointer
	 */
	rx_bd = ((volatile oeth_bd *)OETH_BD_BASE) + OETH_TXBD_NUM;

	/* Preallocated ethernet buffer setup */
	unsigned long mem_addr = buf;

	// Setup TX Buffers
	for(i = 0; i < OETH_TXBD_NUM; i++) {
		//tx_bd[i].len_status = OETH_TX_BD_PAD | OETH_TX_BD_CRC | OETH_RX_BD_IRQ;
		tx_bd[i].len_status = OETH_TX_BD_PAD | OETH_TX_BD_CRC;
		tx_bd[i].addr = mem_addr;
		mem_addr += OETH_TX_BUFF_SIZE;

		pp_printf("> tx_bd[%d].addr: 0X%8X\n", i, tx_bd[i].addr);
		pp_printf("> mem_addr: 0X%8X\n", mem_addr);
	}
	tx_bd[OETH_TXBD_NUM - 1].len_status |= OETH_TX_BD_WRAP;

	// Setup RX buffers
	for(i = 0; i < OETH_RXBD_NUM; i++) {
		rx_bd[i].len_status = OETH_RX_BD_EMPTY | OETH_RX_BD_IRQ; // Init. with IRQ
		rx_bd[i].addr = mem_addr;
		mem_addr += OETH_RX_BUFF_SIZE;

		pp_printf("> rx_bd[%d].addr: 0X%8X\n", i, rx_bd[i].addr);
		pp_printf("> mem_addr: 0X%8X\n", mem_addr);
	}
	rx_bd[OETH_RXBD_NUM - 1].len_status |= OETH_RX_BD_WRAP; // Last buffer wraps

	// Advertise support for 10/100 FD/HD
	cr = eth_mii_read(phynum, MII_ADVERTISE);
	cr |= ADVERTISE_ALL;
	eth_mii_write(phynum, MII_ADVERTISE, cr);

	// Do NOT advertise support for 1000BT
	cr = eth_mii_read(phynum, MII_CTRL1000);
	cr &= ~(ADVERTISE_1000FULL|ADVERTISE_1000HALF);
	eth_mii_write(phynum, MII_CTRL1000, cr);

	// Disable 1000BT
	cr = eth_mii_read(phynum, MII_EXPANSION);
	cr &= ~(ESTATUS_1000_THALF|ESTATUS_1000_TFULL);
	eth_mii_write(phynum, MII_EXPANSION, cr);

	// Restart autonegotiation
	cr = eth_mii_read(0, MII_BMCR);
	cr |= (BMCR_ANRESTART|BMCR_ANENABLE);
	eth_mii_write(phynum, MII_BMCR, cr);

	/* Enable BOTH the transmiter and receiver
	 */
	regs->moder |= (OETH_MODER_RXEN | OETH_MODER_TXEN);

	next_tx_buf_num = 0; // init tx buffer pointer

	return;
}

void ethmac_halt(void)
{
	volatile oeth_regs *regs;

	regs = (oeth_regs *)(OETH_REG_BASE);

	// Disable receive and transmit
	regs->moder &= ~(OETH_MODER_RXEN | OETH_MODER_TXEN);
}

/* Setup buffer descriptors with data */
/* length is in BYTES */
void tx_packet(void* data, int length)
{
	volatile oeth_regs *regs;
	regs = (oeth_regs *)(OETH_REG_BASE);

	volatile oeth_bd *tx_bd;
	volatile int i;

	pp_printf("tx_packet:\n");

	tx_bd = (volatile oeth_bd *)OETH_BD_BASE;
	tx_bd = (oeth_bd*) &tx_bd[next_tx_buf_num];

	// If it's in use - wait
	while ((tx_bd->len_status & OETH_TX_BD_IRQ));

	/* Clear all of the status flags.
	 */
	tx_bd->len_status &= ~OETH_TX_BD_STATS;

	/* If the frame is short, tell CPM to pad it.
	 */
#define ETH_ZLEN        60   /* Min. octets in frame sans FCS */
	if (length <= ETH_ZLEN)
		tx_bd->len_status |= OETH_TX_BD_PAD;
	else
		tx_bd->len_status &= ~OETH_TX_BD_PAD;

	//Copy the data into the transmit buffer, byte at a time
	char* data_p = (char*) data;
	char* data_b = (char*) tx_bd->addr;
	for(i=0;i<length;i++)
	{
		data_b[i] = data_p[i];
	}

	/* Set the length of the packet's data in the buffer descriptor */
	tx_bd->len_status = (tx_bd->len_status & 0x0000ffff) |
		((length&0xffff) << 16);

	/* Send it on its way.  Tell controller its ready, interrupt when sent
	 * and to put the CRC on the end.
	 */
	tx_bd->len_status |= (OETH_TX_BD_READY  | OETH_TX_BD_CRC | OETH_TX_BD_IRQ);

	next_tx_buf_num = (next_tx_buf_num + 1) & OETH_TXBD_NUM_MASK;

	return;

}
