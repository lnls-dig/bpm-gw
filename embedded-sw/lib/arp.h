#ifndef _ARP_H_
#define _ARP_H_

#define ARP_HTYPE 0
#define ARP_PTYPE (ARP_HTYPE+2)
#define ARP_HLEN  (ARP_PTYPE+2)
#define ARP_PLEN  (ARP_HLEN+1)
#define ARP_OPER  (ARP_PLEN+1)
#define ARP_SHA   (ARP_OPER+2)
#define ARP_SPA   (ARP_SHA+6)
#define ARP_THA   (ARP_SPA+4)
#define ARP_TPA   (ARP_THA+6)
#define ARP_END   (ARP_TPA+4)

extern volatile int sawARP;

//void arp_poll();
//void arp_init(const char *if_name, uint32_t ip);

void sendARP(void);

#endif
