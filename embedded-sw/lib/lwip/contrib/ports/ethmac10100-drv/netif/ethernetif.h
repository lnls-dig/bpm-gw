#ifndef _ETHERNETIF_H_
#define _ETHERNETIF_H_

/*
 * user-defined structure for containing
 * ethernet information
 */
struct ethernetif {
  struct eth_addr *ethaddr;
  unsigned int gigabit_mode_enabled; /* 0 => 10/100mbps, 1 => 1000mbps */
};

/* Ethernet interface initialization function */
err_t ethernetif_init(struct netif *netif);

#endif /*ETHERNETIF_H_*/
