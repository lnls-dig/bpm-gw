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
#include "memmgr.h"
#include "lwip/netif.h"

/* Global ETHMAC handler */
//static ethmac_t **ethmac;
//static ethmac_bd_t **ethmac_bd;
//static ethmac_buf_t **ethmac_buf;

/* lwIP input function. To be called when new packets arrive */
extern void ethernetif_input(struct netif *netif);
//extern struct netif *netif;

/* The buffer descriptors track the ring buffers.
 */
typedef struct _oeth_private {
  unsigned short  tx_next;  /* Next buffer to be sent */
  unsigned short  tx_last;  /* Next buffer to be checked if packet sent */
  unsigned short  tx_full;  /* Buffer ring full indicator */
  unsigned short  rx_cur;   /* Next buffer to be checked if packet received */

  ethmac_t      *regs;          /* Address of controller registers. */
  ethmac_bd_t   *rx_bd_base;    /* Address of Rx BDs. */
  ethmac_bd_t   *tx_bd_base;    /* Address of Tx BDs. */
  ethmac_buf_t  *buf;            /* Buffer for rx/tx packets */
} oeth_private;

oeth_private *ethmac_private;

int ethmac_init()
{
    int i;
    struct dev_node *dev_p = 0;
    struct dev_node *ethmac_buf_dev_p = 0;

    if (!ethmac_devl->devices)
        return -1;

    // check for buffer ram devices
    if (!mem_devl->devices)
      return -1;

    // alloc structures for all devices
    //ethmac = (ethmac_t **) memmgr_alloc(sizeof(ethmac_t *)*ethmac_devl->size);
    //ethmac_bd = (ethmac_bd_t **) memmgr_alloc(sizeof(ethmac_bd_t *)*ethmac_devl->size);
    //ethmac_buf = (ethmac_buf_t **) memmgr_alloc(sizeof(ethmac_buf_t *)*ethmac_devl->size);
    ethmac_private = (oeth_private *) memmgr_alloc(sizeof(oeth_private *)*ethmac_devl->size);

    /* Search for ethmac buffer. Must be the last device on the list */
    for (i = 0, ethmac_buf_dev_p = mem_devl->devices; i < mem_devl->size-1;
            ++i, ethmac_buf_dev_p = ethmac_buf_dev_p->next);

    for (i = 0, dev_p = ethmac_devl->devices; i < ethmac_devl->size;
            ++i, dev_p = dev_p->next) {
        //ethmac[i] = (ethmac_t *) dev_p->base;
        //ethmac_bd[i] = (ethmac_bd_t *) (dev_p->base + OETH_BD_BASE_OFFS);

        ethmac_private[i].regs = (ethmac_t *) dev_p->base;
        ethmac_private[i].tx_bd_base = (ethmac_bd_t *) (dev_p->base + OETH_BD_BASE_OFFS);
        ethmac_private[i].rx_bd_base = (ethmac_bd_t *) (dev_p->base + OETH_BD_BASE_OFFS) + OETH_RXBD_NUM;

        /* set all devices to the same buffer. FIXME! */
        ethmac_private[i].buf = (ethmac_buf_t *) ethmac_buf_dev_p->base;

        /* Zero all bd pointers */
        ethmac_private[i].tx_next = 0;
        ethmac_private[i].tx_last = 0;
        ethmac_private[i].tx_full = 0;
        ethmac_private[i].rx_cur = 0;

        DBE_DEBUG(DBG_ETH | DBE_DBG_INFO, "> ethmac regs addr[%d]: %08X\n", i, ethmac_private[i].regs);
        DBE_DEBUG(DBG_ETH | DBE_DBG_INFO, "> ethmac_bd tx addr[%d]: %08X\n", i, ethmac_private[i].tx_bd_base);
        DBE_DEBUG(DBG_ETH | DBE_DBG_INFO, "> ethmac_bd rx addr[%d]: %08X\n", i, ethmac_private[i].rx_bd_base);
        DBE_DEBUG(DBG_ETH | DBE_DBG_INFO, "> ethmac_buf addr[%d]: %08X\n", i,  ethmac_private[i].buf);
    }

    //ethmac_private[i].buf = ethmac_buf[OETH_BUF_ID] = (ethmac_buf_t *) dev_p->base;

    return 0;
}

void ethmac_exit()
{
  //memmgr_free(ethmac);
  //memmgr_free(ethmac_bd);
  //memmgr_free(ethmac_buf);
  memmgr_free(ethmac_private);
}

/* Should be in a structure along with other private info */
/* next tx buffer descriptor number */
//static int next_tx_buf_num;
/* next rx buffer descriptor number */
//static int next_rx_buf_num;

void eth_mii_write(char phynum, short regnum, short data)
{
  //volatile oeth_regs *regs = ethmac[OETH_ID];
  volatile oeth_regs *regs = ethmac_private[OETH_ID].regs;
  regs->miiaddress = (regnum << 8) | phynum;
  regs->miitx_data = data;
  regs->miicommand = OETH_MIICOMMAND_WCTRLDATA;
  regs->miicommand = 0;
  while(regs->miistatus & OETH_MIISTATUS_BUSY);
}

short eth_mii_read(char phynum, short regnum)
{
  //volatile oeth_regs *regs = ethmac[OETH_ID];
  volatile oeth_regs *regs = ethmac_private[OETH_ID].regs;
  regs->miiaddress = (regnum << 8) | phynum;
  regs->miicommand = OETH_MIICOMMAND_RSTAT;
  regs->miicommand = 0;
  while(regs->miistatus & OETH_MIISTATUS_BUSY);

  return regs->miirx_data;
}

void ethmac_setup(int phynum)
{
  // from arch/or32/drivers/open_eth.c
  volatile oeth_regs *regs = ethmac_private[OETH_ID].regs;
  unsigned short cr;

  DBE_DEBUG(DBG_ETH | DBE_DBG_INFO, "> setting up ethmac...\n");

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
  DBE_DEBUG(DBG_ETH | DBE_DBG_INFO, "TX BD num = 0X%08X\n", regs->tx_bd_num);

  /* Set min/max packet length
   */
  /* regs->packet_len = 0x00400600; */
  regs->packet_len = OETH_PKTLEN_MINFL << 16 | OETH_PKTLEN_MAXFL;

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
  //tx_bd = (volatile oeth_bd *)ethmac_bd[OETH_ID];
  tx_bd = ethmac_private[OETH_ID].tx_bd_base;
  DBE_DEBUG(DBG_ETH | DBE_DBG_INFO, "> tx_bd = 0X%08X\n", tx_bd);

  /* Initialize RXBD pointer
   */

  //rx_bd = ((volatile oeth_bd *)ethmac_bd[OETH_ID]) + OETH_TXBD_NUM;
  rx_bd = ethmac_private[OETH_ID].rx_bd_base;
  DBE_DEBUG(DBG_ETH | DBE_DBG_INFO, "> rx_bd = 0X%08X\n", rx_bd);

  /* Preallocated ethernet buffer setup */
  //unsigned long mem_addr = buf;
  unsigned long mem_addr = (unsigned long) ethmac_private[OETH_ID].buf;
  DBE_DEBUG(DBG_ETH | DBE_DBG_INFO, "> ethmac buffer addr = 0X%08X\n", mem_addr);

  // Setup TX Buffers
  for(i = 0; i < OETH_TXBD_NUM; i++) {
    //tx_bd[i].len_status = OETH_TX_BD_PAD | OETH_TX_BD_CRC | OETH_RX_BD_IRQ;
    tx_bd[i].len_status = OETH_TX_BD_PAD | OETH_TX_BD_CRC;
    tx_bd[i].addr = mem_addr;
    mem_addr += OETH_TX_BUFF_SIZE;

    DBE_DEBUG(DBG_ETH | DBE_DBG_INFO, "> tx_bd[%d].addr: 0X%8X\n", i, tx_bd[i].addr);
  }
  tx_bd[OETH_TXBD_NUM - 1].len_status |= OETH_TX_BD_WRAP;

  // Setup RX buffers
  for(i = 0; i < OETH_RXBD_NUM; i++) {
    rx_bd[i].len_status = OETH_RX_BD_EMPTY | OETH_RX_BD_IRQ; // Init. with IRQ
    rx_bd[i].addr = mem_addr;
    mem_addr += OETH_RX_BUFF_SIZE;

    DBE_DEBUG(DBG_ETH | DBE_DBG_INFO, "> rx_bd[%d].addr: 0X%8X\n", i, rx_bd[i].addr);
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

  //next_tx_buf_num = 0; // init tx buffer pointer
  //next_rx_buf_num = 0; // init rx buffer pointer

  return;
}

/* Enable RX in ethernet MAC */
void oeth_enable_rx(void)
{
  volatile oeth_regs *regs = ethmac_private[OETH_ID].regs;
  regs->moder |= OETH_MODER_RXEN;
}

/* Disable RX in ethernet MAC */
void oeth_disable_rx(void)
{
  volatile oeth_regs *regs = ethmac_private[OETH_ID].regs;;
  regs->moder &= ~(OETH_MODER_RXEN);
}

/* Disable RX and TX */
void ethmac_halt(void)
{
  volatile oeth_regs *regs = ethmac_private[OETH_ID].regs;;

  // Disable receive and transmit
  regs->moder &= ~(OETH_MODER_RXEN | OETH_MODER_TXEN);
}

int num_tx_ready_bd(void)
{
  volatile oeth_bd *tx_bd = ethmac_private[OETH_ID].tx_bd_base;
  int num_tx_ready_bd = 0;
  int i;

  /* Go through the TX buffs, search for unused one */
  for(i = 0; i < OETH_TXBD_NUM; ++i) {
    // Looking for buffer ready for transmit
    if((tx_bd[i].len_status & OETH_TX_BD_READY))
      num_tx_ready_bd++;
  }

  return num_tx_ready_bd;
}

// Wait here until all packets have been transmitted
int all_tx_bd_clear(void)
{
  return (num_tx_ready_bd() == 0) ? 1 : 0;
}

/* Wait for at least num tx bd are clear */
void wait_for_tx_bd_clear(int num_tx_clear)
{
  int num_tx_ready;

  /* Caller should have check this. */
  if (num_tx_clear > OETH_TXBD_NUM)
    num_tx_clear = OETH_TXBD_NUM;
  else if (num_tx_clear < 0)
    num_tx_clear = 0;

  num_tx_ready = OETH_TXBD_NUM - num_tx_clear;

  while(num_tx_ready_bd() > num_tx_ready);
}

void ethphy_set_10mbit(int phynum)
{
  while(!all_tx_bd_clear());
  // Hardset PHY to just use 10Mbit mode
  short cr = eth_mii_read(phynum, MII_BMCR);
  cr &= ~BMCR_ANENABLE; // Clear auto negotiate bit
  cr &= ~BMCR_SPEED100; // Clear fast eth. bit
  eth_mii_write(phynum, MII_BMCR, cr);
}

void ethphy_set_100mbit(int phynum)
{
  while(!all_tx_bd_clear());
  // Hardset PHY to just use 100Mbit mode
  short cr = eth_mii_read(phynum, MII_BMCR);
  cr |= BMCR_ANENABLE; // Clear auto negotiate bit
  cr |= BMCR_SPEED100; // Clear fast eth. bit
  eth_mii_write(phynum, MII_BMCR, cr);
}

/* Only call this function after oeth_check_rx_bd */
void rx_packet(void *data, int length)
{
  unsigned short rx_cur = ethmac_private[OETH_ID].rx_cur;
  volatile oeth_bd *rx_bd  = &ethmac_private[OETH_ID].rx_bd_base[rx_cur];
  unsigned char* buf = (unsigned char *)ethmac_private[OETH_ID].buf;

  /*
  * Process the incoming frame.
  */
  DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> processing incoming packet\n");

  //rx_bd = ((volatile oeth_bd *)ethmac_bd[OETH_ID]) + OETH_TXBD_NUM;
  //rx_bd = &ethmac_private[OETH_ID].rx_bd_base[rx_cur];

  /* Copy data from buf to data */
  memcpy(data, buf, length);

  /* finish up */
  rx_bd->len_status &= ~OETH_RX_BD_STATS; /* Clear stats */
  rx_bd->len_status |= OETH_RX_BD_EMPTY; /* Mark RX BD as empty */

  /* next RX to read */
  /*next_rx_buf_num = (next_rx_buf_num + 1) & OETH_RXBD_NUM_MASK;*/
  /*ethmac_private[OETH_ID].rx_cur = (ethmac_private[OETH_ID].rx_cur + 1) & OETH_RXBD_NUM_MASK;*/
}

/* Setup buffer descriptors with data */
/* length is in BYTES */
void tx_packet(void *data, int length)
{
  unsigned short tx_cur = ethmac_private[OETH_ID].tx_next;
  volatile oeth_bd *tx_bd  = &ethmac_private[OETH_ID].tx_bd_base[tx_cur];

  //volatile oeth_regs *regs = ethmac_private[OETH_ID].regs;
  //regs = ethmac[OETH_ID];
  //volatile oeth_bd *tx_bd = &ethmac_private[OETH_ID].tx_bd_base[next_tx_buf_num];

  volatile int i;

  DBE_DEBUG(DBG_ETH | DBE_DBG_INFO, "> sending tx_packet\n");

  //tx_bd = (volatile oeth_bd *) ethmac_bd[OETH_BUF_ID];
  //tx_bd = (volatile oeth_bd *) &tx_bd[next_tx_buf_num];

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
  tx_bd->len_status |= (OETH_TX_BD_READY | OETH_TX_BD_CRC | OETH_TX_BD_IRQ);

  /* next_tx_buf_num = (next_tx_buf_num + 1) & OETH_TXBD_NUM_MASK; */
  ethmac_private[OETH_ID].tx_next = (ethmac_private[OETH_ID].tx_next + 1) & OETH_TXBD_NUM_MASK;

  return;
}

int oeth_check_rx_bd()
{
  volatile oeth_bd *rx_bd = ethmac_private[OETH_ID].rx_bd_base;
  int i;
  int bad = 0;

  DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "oeth_rx:\n");

  /* Find RX buffers marked as having received data */
  for(i = 0; i < OETH_RXBD_NUM; i++) {
    DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> rxbd_num: %d\n", i);
    DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> rxbd[%d]: 0X%08X\n", i, rx_bd[i]);
    DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> rxbd[%d].addr: 0X%08X\n", i, rx_bd[i].addr);

    bad=0;
    /* Looking for buffer descriptors marked not empty */
    if(!(rx_bd[i].len_status & OETH_RX_BD_EMPTY)){
      /* Check status for errors.
       */
      DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> len_status: 0X%8X\n", rx_bd[i].len_status);
      if (rx_bd[i].len_status & (OETH_RX_BD_TOOLONG | OETH_RX_BD_SHORT)) {
        bad = 1;
        DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> short!\n");
      }
      if (rx_bd[i].len_status & OETH_RX_BD_DRIBBLE) {
        bad = 1;
        DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> dribble!\n");
      }
      if (rx_bd[i].len_status & OETH_RX_BD_CRCERR) {
        bad = 1;
        DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> CRC error!\n");
      }
      if (rx_bd[i].len_status & OETH_RX_BD_OVERRUN) {
        bad = 1;
        DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> overrun!\n");
      }
      if (rx_bd[i].len_status & OETH_RX_BD_MISS) {
        bad = 1;
        DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> missed!\n");
      }
      if (rx_bd[i].len_status & OETH_RX_BD_LATECOL) {
        bad = 1;
        DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> late collision!\n");
      }

      if (bad) {
        rx_bd[i].len_status &= ~OETH_RX_BD_STATS;
        rx_bd[i].len_status |= OETH_RX_BD_EMPTY;

        /* Return error code */
        return -1;
      }

      /* RX BD to be read next */
      ethmac_private[OETH_ID].rx_cur = i;
      //next_rx_buf_num = i;
      /* On successfully receiveing data returns the packet length */
      return rx_bd[i].len_status >> 16;
    }
  }

  return -1;
}

/* Drop the current RX packet on the BD */
void oeth_drop_rx_bd()
{
  unsigned short rx_cur = ethmac_private[OETH_ID].rx_cur;
  volatile oeth_bd *rx_bd = &ethmac_private[OETH_ID].rx_bd_base[rx_cur];

  rx_bd->len_status &= ~OETH_RX_BD_STATS;
  rx_bd->len_status |= OETH_RX_BD_EMPTY;
}

/* Interrupt routines */
static void oeth_rx(void *int_ctx)
{
  struct netif *netif = (struct netif*) int_ctx;

  /* Pass frames directly to lwIP */
  ethernetif_input(netif);

  /* Mark BD as empty */
  /*rx_bdp[i].len_status &= ~OETH_RX_BD_STATS;
  rx_bdp[i].len_status |= OETH_RX_BD_EMPTY; */
}

static void oeth_tx(void *int_ctx)
{
  volatile oeth_bd *tx_bd = ethmac_private[OETH_ID].tx_bd_base;
  int i;

  DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> oeth_tx trace\n");

  /* Go through the TX buffs, search for one that was just sent */
  for(i = 0; i < OETH_TXBD_NUM; i++)
  {
    /* Looking for buffer NOT ready for transmit. and IRQ enabled */
    if( (!(tx_bd[i].len_status & (OETH_TX_BD_READY))) && (tx_bd[i].len_status & (OETH_TX_BD_IRQ)) )
    {
      /* Single threaded so no chance we have detected a buffer that has had its IRQ bit set but not its BD_READ flag. Maybe this won't work in linux */
      tx_bd[i].len_status &= ~OETH_TX_BD_IRQ;

      /* Probably good to check for TX errors here */
    }
  }
  return;
}

/* The interrupt handler.
 */
void oeth_interrupt(void *int_ctx)
{
  volatile oeth_regs *regs = ethmac_private[OETH_ID].regs;

  uint  int_events;
  int serviced;

  serviced = 0;

  /* Get the interrupt events that caused us to be here.
   */
  int_events = regs->int_src;
  regs->int_src = int_events;

  DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> int_events = 0x%8X\n", int_events);

  /* Handle receive event in its own function.
   */
  if (int_events & (OETH_INT_RXF | OETH_INT_RXE)) {
    serviced |= 0x1;
    DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> interrupt on rx line\n");
    oeth_rx(int_ctx);
  }

  /* Handle transmit event in its own function.
   */
  if (int_events & (OETH_INT_TXB | OETH_INT_TXE)) {
    serviced |= 0x2;
    DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> interrupt on tx line\n");
    oeth_tx(int_ctx);
    serviced |= 0x2;
  }

  /* Check for receive busy, i.e. packets coming but no place to
   * put them.
   */
  if (int_events & OETH_INT_BUSY) {
    serviced |= 0x4;
    DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> receive busy\n");
    if (!(int_events & (OETH_INT_RXF | OETH_INT_RXE))) {
      oeth_rx(int_ctx);
    }
  }

  DBE_DEBUG(DBG_ETH | DBE_DBG_TRACE, "> nothing\n");

  return;
}
