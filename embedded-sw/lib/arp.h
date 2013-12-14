#ifndef _ARP_H_
#define _ARP_H_

#include "proto.h"

extern volatile int sawARP;

//void arp_poll();
//void arp_init(const char *if_name, uint32_t ip);

void sendARP(void);

#endif
