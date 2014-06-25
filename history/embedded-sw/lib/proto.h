#ifndef _PROTO_H_
#define _PROTO_H_

/* ETHERNET protocol */
#define ETH_DEST  0
#define ETH_SOURCE  (ETH_DEST+6)
#define ETH_TYPE  (ETH_SOURCE+6)
#define ETH_END   (ETH_TYPE+2)

/* IP protocol */
#define IP_VERSION  (ETH_END)
#define IP_TOS    (IP_VERSION+1)
#define IP_LEN    (IP_TOS+1)
#define IP_ID   (IP_LEN+2)
#define IP_FLAGS  (IP_ID+2)
#define IP_TTL    (IP_FLAGS+2)
#define IP_PROTOCOL (IP_TTL+1)
#define IP_CHECKSUM (IP_PROTOCOL+1)
#define IP_SOURCE (IP_CHECKSUM+2)
#define IP_DEST   (IP_SOURCE+4)
#define IP_END    (IP_DEST+4)

/* ARP protocol */
#define ARP_HTYPE (ETH_END)
#define ARP_PTYPE (ARP_HTYPE+2)
#define ARP_HLEN  (ARP_PTYPE+2)
#define ARP_PLEN  (ARP_HLEN+1)
#define ARP_OPER  (ARP_PLEN+1)
#define ARP_SHA   (ARP_OPER+2)
#define ARP_SPA   (ARP_SHA+6)
#define ARP_THA   (ARP_SPA+4)
#define ARP_TPA   (ARP_THA+6)
#define ARP_END   (ARP_TPA+4)

/* ICMP protocol */
#define ICMP_TYPE (IP_END)
#define ICMP_CODE (ICMP_TYPE+1)
#define ICMP_CHECKSUM (ICMP_CODE+1)
/* compatibility with test code */
#define ICMP_QUENCH (ICMP_CHECKSUM+2)
#define ICMP_END  (ICMP_CHECKSUM+2)

void sendARP(void);

#endif
