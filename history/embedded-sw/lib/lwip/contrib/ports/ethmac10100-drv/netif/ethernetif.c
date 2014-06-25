/*
 * Copyright (c) 2001-2004 Swedish Institute of Computer Science.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
 * SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
 * OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 *
 * This file is part of the lwIP TCP/IP stack.
 *
 * Author: Adam Dunkels <adam@sics.se>
 *
 */

/*
 * This file is a skeleton for developing Ethernet network interface
 * drivers for lwIP. Add code to the low_level functions and do a
 * search-and-replace for the word "ethernetif" to replace it with
 * something that better describes your network interface.
 */

#include "lwip/opt.h"
#include "lwip/def.h"
#include "lwip/mem.h"
#include "lwip/pbuf.h"
#include "lwip/sys.h"
#include <lwip/stats.h>

#include "netif/etharp.h"

/*
 * #include "system_conf.h"
 * #include "ts_mac_config.h"
 * #include "ts_mac_drvr.h"
 * #include "LEDStatus.h" */

#include "ethmac.h"
#include "eth-phy-mii.h"
#include "ethmac_config.h"
#include "board.h"

#include "ethernetif.h"
#include "pp-printf.h"

/* Define those to better describe your network interface. */
#define IFNAME0 'e'
#define IFNAME1 'n'

//static const struct eth_addr ethbroadcast = {{0xff,0xff,0xff,0xff,0xff,0xff}};

/**
 * Helper struct to hold private data used to operate your ethernet interface.
 * Keeping the ethernet address of the MAC in this struct is not necessary
 * as it is already kept in the struct netif.
 * But this is only an example, anyway...
 */

/* Forward declarations. */
void  ethernetif_input(struct netif *netif);
static err_t ethernetif_output(struct netif *netif, struct pbuf *p,
             struct ip_addr *ipaddr);

/**
 * In this function, the hardware should be initialized.
 * Called from ethernetif_init().
 *
 * @param netif the already initialized lwip network interface structure
 *        for this ethernetif
 */

static void
low_level_init(struct netif *netif)
{
  struct ethernetif *ethernetif = netif->state;

  /* set MAC hardware address length */
  netif->hwaddr_len = 6;

  /* get MAC hardware address */
  netif->hwaddr[0] = (char)(MAC_CFG_MAC_ADDR_UPPER_16 >> 8);
  netif->hwaddr[1] = (char)(MAC_CFG_MAC_ADDR_UPPER_16);
  netif->hwaddr[2] = (char)(MAC_CFG_MAC_ADDR_LOWER_32 >> 24);
  netif->hwaddr[3] = (char)(MAC_CFG_MAC_ADDR_LOWER_32 >> 16);
  netif->hwaddr[4] = (char)(MAC_CFG_MAC_ADDR_LOWER_32 >> 8);
  netif->hwaddr[5] = (char)(MAC_CFG_MAC_ADDR_LOWER_32);

  /* maximum transfer unit */
  /*
   * MTU for ethernet is payload i.e. total frame
   * - minus CRC (4 bytes)
   * - minus ethernet header (14 bytes)
   */
  /* netif->mtu = MAC_CFG_MAX_PKT_SIZE-18; */
  netif->mtu = OETH_PKTLEN_DEFAULT_ETH-18;

  /* device capabilities */
  /* don't set NETIF_FLAG_ETHARP if this device is not an ethernet one */
  netif->flags = NETIF_FLAG_BROADCAST | NETIF_FLAG_ETHARP;

  /* initialize ethmac structures */
  ethmac_init();

  /* all done! */
  ethmac_setup(PHY_NUM);

  return;
}


static unsigned int OutputBuffer[(OETH_PKTLEN_DEFAULT_ETH >> 2)+4];

/**
 * This function should do the actual transmission of the packet. The packet is
 * contained in the pbuf that is passed to the function. This pbuf
 * might be chained.
 *
 * @param netif the lwip network interface structure for this ethernetif
 * @param p the MAC packet to send (e.g. IP packet including MAC addresses and type)
 * @return ERR_OK if the packet could be sent
 *         an err_t value if the packet couldn't be sent
 *
 * @note Returning ERR_MEM here if a DMA queue of your MAC is full can lead to
 *       strange results. You might consider waiting for space in the DMA queue
 *       to become availale since the stack doesn't retry to send a packet
 *       dropped because of memory failure (except for the TCP timers).
 */
static err_t
low_level_output(struct netif *netif, struct pbuf *p)
{
/*  struct ethernetif *ethernetif = netif->state;*/
  struct pbuf *q;
  char *dst;
  char *src;
  int total_bytes = 0;
  LWIP_DEBUGF(NETIF_DEBUG, ("low_level_output: enter\n"));

  /* wait until half the TX BD are free */
  wait_for_tx_bd_clear(OETH_TXBD_NUM/2);

#if ETH_PAD_SIZE
  pbuf_header(p, -ETH_PAD_SIZE);      /* drop the padding word */
#endif

  dst = (char *)OutputBuffer;
  for(q = p; q != NULL; q = q->next) {
    int i = 0;
    /* Send the data from the pbuf to the interface, one pbuf at a
       time. The size of the data in each pbuf is kept in the ->len
       variable.
    send data from(q->payload, q->len);*/
    if(total_bytes + q->len > OETH_PKTLEN_DEFAULT_ETH){
        LWIP_DEBUGF(NETIF_DEBUG, ("low_level_output: ERR packet truncated!!\n"));
        break;
    }else{
        total_bytes += q->len;
    }
    src = q->payload;
    for(i = 0; i < q->len; i++){
        *dst++ = *src++;
    }
  }

  /* Send packet */
  tx_packet(OutputBuffer, total_bytes);

  /* UPDATE LED STATUS */
  /* LEDStatusUpdate(TSMAC_TX); */

#if ETH_PAD_SIZE
  pbuf_header(p, ETH_PAD_SIZE);     /* reclaim the padding word */
#endif

  LINK_STATS_INC(link.xmit);

  LWIP_DEBUGF(NETIF_DEBUG, ("low_level_output: exit\n"));

  return ERR_OK;
}

/**
 * Should allocate a pbuf and transfer the bytes of the incoming
 * packet from the interface into the pbuf.
 *
 * @param netif the lwip network interface structure for this ethernetif
 * @return a pbuf filled with the received packet (including MAC header)
 *         NULL on memory error
 */
static struct pbuf *
low_level_input(struct netif *netif)
{
  /*struct ethernetif *ethernetif = netif->state;*/
  struct pbuf *p, *q;
  u16_t len;
  int bytesToRead;

  LWIP_DEBUGF(NETIF_DEBUG, ("low_level_input: begin\n"));

  /* Obtain the size of the packet and put it into the "len"
     variable. */
  bytesToRead = len = oeth_check_rx_bd();

  /* don't process further if there is no data to read or if there was an error*/
  if(bytesToRead <= 0)
    return(NULL);

  LWIP_DEBUGF(NETIF_DEBUG, ("low_level_input: lw_lvl_inp - frm bytes: %d\n", bytesToRead));

#if ETH_PAD_SIZE
  len += ETH_PAD_SIZE;            /* allow room for Ethernet padding */
#endif

  /* We allocate a pbuf chain of pbufs from the pool. */
  p = pbuf_alloc(PBUF_RAW, len, PBUF_POOL);

  if (p != NULL) {

#if ETH_PAD_SIZE
    pbuf_header(p, -ETH_PAD_SIZE);      /* drop the padding word */
#endif

    /* We iterate over the pbuf chain until we have read the entire
     * packet into the pbuf. */
    for(q = p; q != NULL; q = q->next) {
       int size;

       /* Read enough bytes to fill this pbuf in the chain. The
        * available data in the pbuf is given by the q->len
        * variable.
          read data into(q->payload, q->len);*/
       size = (bytesToRead > q->len) ? q->len : bytesToRead;
       bytesToRead -= size;
       LWIP_DEBUGF(NETIF_DEBUG, ("low_level_input: bytes to read: %d\n", size));
       /* Read data from ethmac core to pbuf buffer */
       rx_packet(q->payload, size);
    }

#if ETH_PAD_SIZE
    pbuf_header(p, ETH_PAD_SIZE);     /* reclaim the padding word */
#endif

  LINK_STATS_INC(link.recv);

  } else {
    /* Drop RX packet. We just have to set the empty bit on the corresponding BD */
    oeth_drop_rx_bd();
    LINK_STATS_INC(link.memerr);
    LINK_STATS_INC(link.drop);
  }

  LWIP_DEBUGF(NETIF_DEBUG, ("low_level_input: end\n"));
  return p;
}

/*
 * ethernetif_output():
 *
 * This function is called by the TCP/IP stack when an IP packet
 * should be sent. It calls the function called low_level_output() to
 * do the actual transmission of the packet.
 *
 */

static err_t
ethernetif_output(struct netif *netif, struct pbuf *p,
      struct ip_addr *ipaddr)
{

 /* resolve hardware address, then send (or queue) packet */
  return etharp_output(netif, ipaddr, p);
}

/**
 * This function should be called when a packet is ready to be read
 * from the interface. It uses the function low_level_input() that
 * should handle the actual reception of bytes from the network
 * interface. Then the type of the received packet is determined and
 * the appropriate input function is called.
 *
 * @param netif the lwip network interface structure for this ethernetif
 */
void
ethernetif_input(struct netif *netif)
{
  struct ethernetif *ethernetif;
  struct eth_hdr *ethhdr;
  struct pbuf *p;

  LWIP_DEBUGF(NETIF_DEBUG, ("ethernetif_input: begin\n"));

  ethernetif = netif->state;

  /* move received packet into a new pbuf */
  p = low_level_input(netif);
  /* no packet could be read, silently ignore this */
  if (p == NULL) return;
  /* points to packet payload, which starts with an Ethernet header */
  ethhdr = p->payload;

#if LINK_STATS
  LINK_STATS_INC(link.recv);
  //lwip_stats.link.recv++;
#endif /* LINK_STATS */

  LWIP_DEBUGF(NETIF_DEBUG, ("eth type: 0X%08X\n", htons(ethhdr->type)));

  switch (htons(ethhdr->type)) {
    /* IP packet? */
    case ETHTYPE_IP:
      /* update ARP table */
      /* lwIP 1.4.1 does not need to mannualy update ARP tables */
      /* etharp_ip_input(netif, p); */
      /* update LED Status */
      /* LEDStatusUpdate(TSMAC_RX); */
      //break;
    case ETHTYPE_ARP:
#if PPPOE_SUPPORT
    /* PPPoE packet? */
    case ETHTYPE_PPPOEDISC:
    case ETHTYPE_PPPOE:
#endif /* PPPOE_SUPPORT */
      /* lwIP 1.4.1 does not need to call this mannualy as of now it is declared static
        etharp_arp_input(netif, ethernetif->ethaddr, p);*/
      /* Do not skip ethenet header! full packet send to tcpip_thread to process
        pbuf_header(p, -1*((s16_t)sizeof(struct eth_hdr)));*/
      /* pass to network layer */
      if (netif->input(p, netif)!=ERR_OK){
        LWIP_DEBUGF(NETIF_DEBUG, ("ethernetif_input: IP input error\n"));
        pbuf_free(p);
        p = NULL;
      }
      /* Update LED Status */
      /* LEDStatusUpdate(TSMAC_RX); */
      break;

    default:
      pbuf_free(p);
      p = NULL;
      break;
  }

  LWIP_DEBUGF(NETIF_DEBUG, ("ethernetif_input: end\n"));
}

#if (NO_SYS == 0)
static void
arp_timer(void *arg)
{
  etharp_tmr();
  sys_timeout(ARP_TMR_INTERVAL, arp_timer, NULL);
}
#endif

/**
 * Should be called at the beginning of the program to set up the
 * network interface. It calls the function low_level_init() to do the
 * actual setup of the hardware.
 *
 * This function should be passed as a parameter to netif_add().
 *
 * @param netif the lwip network interface structure for this ethernetif
 * @return ERR_OK if the loopif is initialized
 *         ERR_MEM if private data couldn't be allocated
 *         any other err_t on error
 */
err_t
ethernetif_init(struct netif *netif)
{
  struct ethernetif *ethernetif;

  ethernetif = mem_malloc(sizeof(struct ethernetif));
  if (ethernetif == NULL) {
    LWIP_DEBUGF(NETIF_DEBUG, ("ethernetif_init: out of memory\n"));
    return ERR_MEM;
  }

  /* If ethernetif is allocated outside and passed to netif_add in state argument */
  /* ethernetif = netif->state; */

#if LWIP_NETIF_HOSTNAME
  /* Initialize interface hostname */
  netif->hostname = "lwip";
#endif /* LWIP_NETIF_HOSTNAME */

  netif->state = ethernetif;
  netif->name[0] = IFNAME0;
  netif->name[1] = IFNAME1;
  /* We directly use etharp_output() here to save a function call.
   * You can instead declare your own function an call etharp_output()
   * from it if you have to do some checks before sending (e.g. if link
   * is available...) */
  netif->output = ethernetif_output;
  netif->linkoutput = low_level_output;

  ethernetif->ethaddr = (struct eth_addr *)&(netif->hwaddr[0]);

  low_level_init(netif);

  return ERR_OK;
}
