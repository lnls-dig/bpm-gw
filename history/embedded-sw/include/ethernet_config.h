
/*
 * This file defines constants that control
 * application-configuration
 */

#ifndef _ETHERNET_CONFIG_H_
#define _ETHERNET_CONFIG_H_
#include "lwip/opt.h"

/* PHY Number */
#define PHY_NUM 7

/*
 * MAC Address (Software configured)
 * (e.g. 00-01-02-03-04-05)
 */
#define MAC_CFG_MAC_ADDR_UPPER_16 (0x000A)
#define MAC_CFG_MAC_ADDR_LOWER_32 (0x3502532D)


/*
 * IP Addresses when not using DHCP
 */
#if !LWIP_DHCP
/* Host ip-address: 10.0.18.148 */

#define HST_IP_ADDR_0 (10)
#define HST_IP_ADDR_1 (0)
#define HST_IP_ADDR_2 (18)
#define HST_IP_ADDR_3 (148)

/* Gateway IP Address: 10.0.18.1 */
#define GW_IP_ADDR_0  (10)
#define GW_IP_ADDR_1  (0)
#define GW_IP_ADDR_2  (18)
#define GW_IP_ADDR_3  (1)

/* Subnet: 255.255.255.0 */
#define SUBNET_MASK_0 (255)
#define SUBNET_MASK_1 (255)
#define SUBNET_MASK_2 (255)
#define SUBNET_MASK_3 (0)

#endif
#endif /*ETHERNET_CONFIG_H_*/

