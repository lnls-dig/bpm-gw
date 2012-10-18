#ifndef ARP_H
#define ARP_H

void arp_poll();
void arp_init(const char *if_name, uint32_t ip);

#endif
