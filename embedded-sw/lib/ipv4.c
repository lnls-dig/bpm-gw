#include <string.h>

#include "endpoint.h"
#include "ipv4.h"
#include "ptpd_netif.h"
#include "hw/memlayout.h"
#include "hw/etherbone-config.h"

int needIP = 1;
static uint8_t myIP[4];
static wr_socket_t *ipv4_socket;

unsigned int ipv4_checksum(unsigned short *buf, int shorts)
{
	int i;
	unsigned int sum;

	sum = 0;
	for (i = 0; i < shorts; ++i)
		sum += buf[i];

	sum = (sum >> 16) + (sum & 0xffff);
	sum += (sum >> 16);

	return (~sum & 0xffff);
}

void ipv4_init(const char *if_name)
{
	wr_sockaddr_t saddr;

	/* Configure socket filter */
	memset(&saddr, 0, sizeof(saddr));
	strcpy(saddr.if_name, if_name);
	get_mac_addr(&saddr.mac[0]);	/* Unicast */
	saddr.ethertype = htons(0x0800);	/* IPv4 */
	saddr.family = PTPD_SOCK_RAW_ETHERNET;

	ipv4_socket = ptpd_netif_create_socket(PTPD_SOCK_RAW_ETHERNET,
					       0, &saddr);
}

static int bootp_retry = 0;
static int bootp_timer = 0;

void ipv4_poll(void)
{
	uint8_t buf[400];
	wr_sockaddr_t addr;
	int len;

	if ((len = ptpd_netif_recvfrom(ipv4_socket, &addr,
				       buf, sizeof(buf), 0)) > 0) {
		if (needIP)
			process_bootp(buf, len - 14);

		if (!needIP && (len = process_icmp(buf, len - 14)) > 0)
			ptpd_netif_sendto(ipv4_socket, &addr, buf, len, 0);
	}

	if (needIP && bootp_timer == 0) {
		len = send_bootp(buf, ++bootp_retry);

		memset(addr.mac, 0xFF, 6);
		addr.ethertype = htons(0x0800);	/* IPv4 */
		ptpd_netif_sendto(ipv4_socket, &addr, buf, len, 0);
	}

	if (needIP && ++bootp_timer == 100000)
		bootp_timer = 0;
}

void getIP(unsigned char *IP)
{
	memcpy(IP, myIP, 4);
}

void setIP(unsigned char *IP)
{
	volatile unsigned int *eb_ip =
	    (unsigned int *)(BASE_ETHERBONE_CFG + EB_IPV4);
	unsigned int ip;

	memcpy(myIP, IP, 4);

	ip = (myIP[0] << 24) | (myIP[1] << 16) | (myIP[2] << 8) | (myIP[3]);
	while (*eb_ip != ip)
		*eb_ip = ip;

	needIP = (ip == 0);
	if (!needIP) {
		bootp_retry = 0;
		bootp_timer = 0;
	}
}
