#include <string.h>

#include "ipv4.h"
#include "board.h"
#include "arp.h"
#include "debug_print.h"

volatile int sawARP = 0;
//#include "ptpd_netif.h"

//static int process_arp(uint8_t * buf, int len)
//{
//  uint8_t hisMAC[6];
//  uint8_t hisIP[4];
//  uint8_t myIP[4];
//
//  if (len < ARP_END)
//    return 0;
//
//  /* Is it ARP request targetting our IP? */
//  getIP(myIP);
//  if (buf[ARP_OPER + 0] != 0 ||
//      buf[ARP_OPER + 1] != 1 || memcmp(buf + ARP_TPA, myIP, 4))
//    return 0;
//
//  memcpy(hisMAC, buf + ARP_SHA, 6);
//  memcpy(hisIP, buf + ARP_SPA, 4);
//
//  // ------------- ARP ------------
//  // HW ethernet
//  buf[ARP_HTYPE + 0] = 0;
//  buf[ARP_HTYPE + 1] = 1;
//  // proto IP
//  buf[ARP_PTYPE + 0] = 8;
//  buf[ARP_PTYPE + 1] = 0;
//  // lengths
//  buf[ARP_HLEN] = 6;
//  buf[ARP_PLEN] = 4;
//  // Response
//  buf[ARP_OPER + 0] = 0;
//  buf[ARP_OPER + 1] = 2;
//  // my MAC+IP
//  get_mac_addr(buf + ARP_SHA);
//  memcpy(buf + ARP_SPA, myIP, 4);
//  // his MAC+IP
//  memcpy(buf + ARP_THA, hisMAC, 6);
//  memcpy(buf + ARP_TPA, hisIP, 4);
//
//  return ARP_END;
//}

void sendARP() {
  unsigned char buf[ARP_END];

  pp_printf("> sending ARP packet\n");

  // ------------- Ethernet ------------
  // MAC address
  memcpy(buf+ETH_DEST,   hisMAC, 6);
  memcpy(buf+ETH_SOURCE, myMAC,  6);
  // ethertype ARP
  buf[ETH_TYPE+0] = 0x08;
  buf[ETH_TYPE+1] = 0x06;

  // ------------- ARP ------------
  // HW ethernet
  buf[ARP_HTYPE+0] = 0;
  buf[ARP_HTYPE+1] = 1;
  // proto IP
  buf[ARP_PTYPE+0] = 8;
  buf[ARP_PTYPE+1] = 0;
  // lengths
  buf[ARP_HLEN] = 6;
  buf[ARP_PLEN] = 4;
  // Response
  buf[ARP_OPER+0] = 0;
  buf[ARP_OPER+1] = 2;
  // my MAC+IP
  memcpy(buf+ARP_SHA, myMAC, 6);
  memcpy(buf+ARP_SPA, myIP,  4);
  // his MAC+IP
  memcpy(buf+ARP_THA, hisMAC, 6);
  memcpy(buf+ARP_TPA, hisIP,  4);

  tx_packet(buf, sizeof(buf));
  sawARP = 0;
}
