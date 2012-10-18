#include <string.h>

#include "ipv4.h"

#define IP_VERSION	0
#define IP_TOS		(IP_VERSION+1)
#define IP_LEN		(IP_TOS+1)
#define IP_ID		(IP_LEN+2)
#define IP_FLAGS	(IP_ID+2)
#define IP_TTL		(IP_FLAGS+2)
#define IP_PROTOCOL	(IP_TTL+1)
#define IP_CHECKSUM	(IP_PROTOCOL+1)
#define IP_SOURCE	(IP_CHECKSUM+2)
#define IP_DEST		(IP_SOURCE+4)
#define IP_END		(IP_DEST+4)

#define UDP_VIRT_SADDR	(IP_END-12)
#define UDP_VIRT_DADDR	(UDP_VIRT_SADDR+4)
#define UDP_VIRT_ZEROS	(UDP_VIRT_DADDR+4)
#define UDP_VIRT_PROTO	(UDP_VIRT_ZEROS+1)
#define UDP_VIRT_LENGTH	(UDP_VIRT_PROTO+1)

#define UDP_SPORT	(IP_END)
#define UDP_DPORT	(UDP_SPORT+2)
#define UDP_LENGTH	(UDP_DPORT+2)
#define UDP_CHECKSUM	(UDP_LENGTH+2)
#define UDP_END		(UDP_CHECKSUM+2)

#define BOOTP_OP	(UDP_END)
#define BOOTP_HTYPE	(BOOTP_OP+1)
#define BOOTP_HLEN	(BOOTP_HTYPE+1)
#define BOOTP_HOPS	(BOOTP_HLEN+1)
#define BOOTP_XID	(BOOTP_HOPS+1)
#define BOOTP_SECS	(BOOTP_XID+4)
#define BOOTP_UNUSED	(BOOTP_SECS+2)
#define BOOTP_CIADDR	(BOOTP_UNUSED+2)
#define BOOTP_YIADDR	(BOOTP_CIADDR+4)
#define BOOTP_SIADDR	(BOOTP_YIADDR+4)
#define BOOTP_GIADDR	(BOOTP_SIADDR+4)
#define BOOTP_CHADDR	(BOOTP_GIADDR+4)
#define BOOTP_SNAME	(BOOTP_CHADDR+16)
#define BOOTP_FILE	(BOOTP_SNAME+64)
#define BOOTP_VEND	(BOOTP_FILE+128)
#define BOOTP_END	(BOOTP_VEND+64)

int send_bootp(uint8_t * buf, int retry)
{
	unsigned short sum;

	// ----------- BOOTP ------------
	buf[BOOTP_OP] = 1;	/* bootrequest */
	buf[BOOTP_HTYPE] = 1;	/* ethernet */
	buf[BOOTP_HLEN] = 6;	/* MAC length */
	buf[BOOTP_HOPS] = 0;

	/* A unique identifier for the request !!! FIXME */
	get_mac_addr(buf + BOOTP_XID);
	buf[BOOTP_XID + 0] ^= buf[BOOTP_XID + 4];
	buf[BOOTP_XID + 1] ^= buf[BOOTP_XID + 5];
	buf[BOOTP_XID + 2] ^= (retry >> 8) & 0xFF;
	buf[BOOTP_XID + 3] ^= retry & 0xFF;

	buf[BOOTP_SECS] = (retry >> 8) & 0xFF;
	buf[BOOTP_SECS + 1] = retry & 0xFF;
	memset(buf + BOOTP_UNUSED, 0, 2);

	memset(buf + BOOTP_CIADDR, 0, 4);	/* own IP if known */
	memset(buf + BOOTP_YIADDR, 0, 4);
	memset(buf + BOOTP_SIADDR, 0, 4);
	memset(buf + BOOTP_GIADDR, 0, 4);

	memset(buf + BOOTP_CHADDR, 0, 16);
	get_mac_addr(buf + BOOTP_CHADDR);	/* own MAC address */

	memset(buf + BOOTP_SNAME, 0, 64);	/* desired BOOTP server */
	memset(buf + BOOTP_FILE, 0, 128);	/* desired BOOTP file */
	memset(buf + BOOTP_VEND, 0, 64);	/* vendor extensions */

	// ------------ UDP -------------
	memset(buf + UDP_VIRT_SADDR, 0, 4);
	memset(buf + UDP_VIRT_DADDR, 0xFF, 4);
	buf[UDP_VIRT_ZEROS] = 0;
	buf[UDP_VIRT_PROTO] = 0x11;	/* UDP */
	buf[UDP_VIRT_LENGTH] = (BOOTP_END - IP_END) >> 8;
	buf[UDP_VIRT_LENGTH + 1] = (BOOTP_END - IP_END) & 0xff;

	buf[UDP_SPORT] = 0;
	buf[UDP_SPORT + 1] = 68;	/* BOOTP client */
	buf[UDP_DPORT] = 0;
	buf[UDP_DPORT + 1] = 67;	/* BOOTP server */
	buf[UDP_LENGTH] = (BOOTP_END - IP_END) >> 8;
	buf[UDP_LENGTH + 1] = (BOOTP_END - IP_END) & 0xff;
	buf[UDP_CHECKSUM] = 0;
	buf[UDP_CHECKSUM + 1] = 0;

	sum =
	    ipv4_checksum((unsigned short *)(buf + UDP_VIRT_SADDR),
			  (BOOTP_END - UDP_VIRT_SADDR) / 2);
	if (sum == 0)
		sum = 0xFFFF;

	buf[UDP_CHECKSUM + 0] = (sum >> 8);
	buf[UDP_CHECKSUM + 1] = sum & 0xff;

	// ------------ IP --------------
	buf[IP_VERSION] = 0x45;
	buf[IP_TOS] = 0;
	buf[IP_LEN + 0] = (BOOTP_END) >> 8;
	buf[IP_LEN + 1] = (BOOTP_END) & 0xff;
	buf[IP_ID + 0] = 0;
	buf[IP_ID + 1] = 0;
	buf[IP_FLAGS + 0] = 0;
	buf[IP_FLAGS + 1] = 0;
	buf[IP_TTL] = 63;
	buf[IP_PROTOCOL] = 17;	/* UDP */
	buf[IP_CHECKSUM + 0] = 0;
	buf[IP_CHECKSUM + 1] = 0;
	memset(buf + IP_SOURCE, 0, 4);
	memset(buf + IP_DEST, 0xFF, 4);

	sum =
	    ipv4_checksum((unsigned short *)(buf + IP_VERSION),
			  (IP_END - IP_VERSION) / 2);
	buf[IP_CHECKSUM + 0] = sum >> 8;
	buf[IP_CHECKSUM + 1] = sum & 0xff;

	mprintf("Sending BOOTP request...\n");
	return BOOTP_END;
}

int process_bootp(uint8_t * buf, int len)
{
	uint8_t mac[6];

	get_mac_addr(mac);

	if (len != BOOTP_END)
		return 0;

	if (buf[IP_VERSION] != 0x45)
		return 0;

	if (buf[IP_PROTOCOL] != 17 ||
	    buf[UDP_DPORT] != 0 || buf[UDP_DPORT + 1] != 68 ||
	    buf[UDP_SPORT] != 0 || buf[UDP_SPORT + 1] != 67)
		return 0;

	if (memcmp(buf + BOOTP_CHADDR, mac, 6))
		return 0;

	mprintf("Discovered IP address!\n");
	setIP(buf + BOOTP_YIADDR);

	return 1;
}
