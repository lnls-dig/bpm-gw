#include <string.h>

#include "ipv4.h"
#include "icmp.h"
#include "board.h"
#include "debug_print.h"
//#include "ptpd_netif.h"

volatile int sawPING = 0;
volatile int hisBodyLen;
unsigned char hisBody[1516];

//int process_icmp(uint8_t * buf, int len)
//{
//  int iplen, hisBodyLen;
//  uint8_t hisIP[4];
//  uint8_t myIP[4];
//  uint16_t sum;
//
//  /* Is it IP targetting us? */
//  getIP(myIP);
//  if (buf[IP_VERSION] != 0x45 || memcmp(buf + IP_DEST, myIP, 4))
//    return 0;
//
//  iplen = (buf[IP_LEN + 0] << 8 | buf[IP_LEN + 1]);
//
//  /* An ICMP ECHO request? */
//  if (buf[IP_PROTOCOL] != 0x01 || buf[ICMP_TYPE] != 0x08)
//    return 0;
//
//  hisBodyLen = iplen - 24;
//  if (hisBodyLen > 64)
//    hisBodyLen = 64;
//
//  memcpy(hisIP, buf + IP_SOURCE, 4);
//
//  // ------------ IP --------------
//  buf[IP_VERSION] = 0x45;
//  buf[IP_TOS] = 0;
//  buf[IP_LEN + 0] = (hisBodyLen + 24) >> 8;
//  buf[IP_LEN + 1] = (hisBodyLen + 24) & 0xff;
//  buf[IP_ID + 0] = 0;
//  buf[IP_ID + 1] = 0;
//  buf[IP_FLAGS + 0] = 0;
//  buf[IP_FLAGS + 1] = 0;
//  buf[IP_TTL] = 63;
//  buf[IP_PROTOCOL] = 1; /* ICMP */
//  buf[IP_CHECKSUM + 0] = 0;
//  buf[IP_CHECKSUM + 1] = 0;
//  memcpy(buf + IP_SOURCE, myIP, 4);
//  memcpy(buf + IP_DEST, hisIP, 4);
//
//  // ------------ ICMP ---------
//  buf[ICMP_TYPE] = 0x0; // echo reply
//  buf[ICMP_CODE] = 0;
//  buf[ICMP_CHECKSUM + 0] = 0;
//  buf[ICMP_CHECKSUM + 1] = 0;
//  // No need to copy payload; we modified things in-place
//
//  sum =
//      ipv4_checksum((unsigned short *)(buf + ICMP_TYPE),
//        (hisBodyLen + 4 + 1) / 2);
//  buf[ICMP_CHECKSUM + 0] = sum >> 8;
//  buf[ICMP_CHECKSUM + 1] = sum & 0xff;
//
//  sum = ipv4_checksum((unsigned short *)(buf + IP_VERSION), 10);
//  buf[IP_CHECKSUM + 0] = sum >> 8;
//  buf[IP_CHECKSUM + 1] = sum & 0xff;
//
//  return 24 + hisBodyLen;
//}

void sendECHO() {
	unsigned char buf[500];
	unsigned int sum;

	pp_printf("> sending ECHO packet\n");

	// ------------- Ethernet ------------
	// MAC address
	memcpy(buf+ETH_DEST,   hisMAC, 6);
	memcpy(buf+ETH_SOURCE, myMAC,  6);
	// ethertype IP
	buf[ETH_TYPE+0] = 0x08;
	buf[ETH_TYPE+1] = 0x00;

	// ------------ IP --------------
	buf[IP_VERSION] = 0x45;
	buf[IP_TOS] = 0;
	buf[IP_LEN+0] = (hisBodyLen+24) >> 8;
	buf[IP_LEN+1] = (hisBodyLen+24) & 0xff;
	buf[IP_ID+0] = 0;
	buf[IP_ID+1] = 0;
	buf[IP_FLAGS+0] = 0;
	buf[IP_FLAGS+1] = 0;
	buf[IP_TTL] = 63;
	buf[IP_PROTOCOL] = 1; /* ICMP */
	buf[IP_CHECKSUM+0] = 0;
	buf[IP_CHECKSUM+1] = 0;
	memcpy(buf+IP_SOURCE, myIP, 4);
	memcpy(buf+IP_DEST, hisIP, 4);

	// ------------ ICMP ---------
	buf[ICMP_TYPE] = 0x0; // echo reply
	buf[ICMP_CODE] = 0;
	buf[ICMP_CHECKSUM+0] = 0;
	buf[ICMP_CHECKSUM+1] = 0;
	memcpy(buf+ICMP_QUENCH, hisBody, hisBodyLen);
	if ((hisBodyLen & 1) != 0)
		buf[ICMP_QUENCH+hisBodyLen] = 0;

	sum = ipv4_checksum((unsigned short*)(buf+ICMP_TYPE), (hisBodyLen+4+1)/2);
	buf[ICMP_CHECKSUM+0] = sum >> 8;
	buf[ICMP_CHECKSUM+1] = sum & 0xff;

	sum = ipv4_checksum((unsigned short*)(buf+IP_VERSION), 10);
	buf[IP_CHECKSUM+0] = sum >> 8;
	buf[IP_CHECKSUM+1] = sum & 0xff;

	tx_packet(buf, hisBodyLen+ICMP_QUENCH);
	sawPING = 0;
}
