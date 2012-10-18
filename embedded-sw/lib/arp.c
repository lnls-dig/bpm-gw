#include <string.h>

#include "ipv4.h"
#include "ptpd_netif.h"

static wr_socket_t *arp_socket;

#define ARP_HTYPE	0
#define ARP_PTYPE	(ARP_HTYPE+2)
#define ARP_HLEN	(ARP_PTYPE+2)
#define ARP_PLEN	(ARP_HLEN+1)
#define ARP_OPER	(ARP_PLEN+1)
#define ARP_SHA		(ARP_OPER+2)
#define ARP_SPA		(ARP_SHA+6)
#define ARP_THA		(ARP_SPA+4)
#define ARP_TPA		(ARP_THA+6)
#define ARP_END		(ARP_TPA+4)

void arp_init(const char *if_name)
{
	wr_sockaddr_t saddr;

	/* Configure socket filter */
	memset(&saddr, 0, sizeof(saddr));
	strcpy(saddr.if_name, if_name);
	memset(&saddr.mac, 0xFF, 6);	/* Broadcast */
	saddr.ethertype = htons(0x0806);	/* ARP */
	saddr.family = PTPD_SOCK_RAW_ETHERNET;

	arp_socket = ptpd_netif_create_socket(PTPD_SOCK_RAW_ETHERNET,
					      0, &saddr);
}

static int process_arp(uint8_t * buf, int len)
{
	uint8_t hisMAC[6];
	uint8_t hisIP[4];
	uint8_t myIP[4];

	if (len < ARP_END)
		return 0;

	/* Is it ARP request targetting our IP? */
	getIP(myIP);
	if (buf[ARP_OPER + 0] != 0 ||
	    buf[ARP_OPER + 1] != 1 || memcmp(buf + ARP_TPA, myIP, 4))
		return 0;

	memcpy(hisMAC, buf + ARP_SHA, 6);
	memcpy(hisIP, buf + ARP_SPA, 4);

	// ------------- ARP ------------
	// HW ethernet
	buf[ARP_HTYPE + 0] = 0;
	buf[ARP_HTYPE + 1] = 1;
	// proto IP
	buf[ARP_PTYPE + 0] = 8;
	buf[ARP_PTYPE + 1] = 0;
	// lengths
	buf[ARP_HLEN] = 6;
	buf[ARP_PLEN] = 4;
	// Response
	buf[ARP_OPER + 0] = 0;
	buf[ARP_OPER + 1] = 2;
	// my MAC+IP
	get_mac_addr(buf + ARP_SHA);
	memcpy(buf + ARP_SPA, myIP, 4);
	// his MAC+IP
	memcpy(buf + ARP_THA, hisMAC, 6);
	memcpy(buf + ARP_TPA, hisIP, 4);

	return ARP_END;
}

void arp_poll(void)
{
	uint8_t buf[ARP_END + 100];
	wr_sockaddr_t addr;
	int len;

	if (needIP)
		return;		/* can't do ARP w/o an address... */

	if ((len = ptpd_netif_recvfrom(arp_socket,
				       &addr, buf, sizeof(buf), 0)) > 0)
		if ((len = process_arp(buf, len)) > 0)
			ptpd_netif_sendto(arp_socket, &addr, buf, len, 0);
}
