#ifndef _ETHMAC_CONFIG_H_
#define _ETHMAC_CONFIG_H_

/* include user-provided file that
 * will override definitions in this
 * standard include file.
 */
#include "ethernet_config.h"
/* NOTE:
 * ethernet_config.h is a user-supplied file
 * that can be blank if the defaults specified
 * in this file are acceptable.
 */

/* Interface PHY number */
#ifndef PHY_NUM
#define PHY_NUM 0
#endif

/*
 * MAC Address (Software configurable)
 * (e.g. 00-0A-35-02-53-2D)
 */
#ifndef MAC_CFG_MAC_ADDR_UPPER_16
#define MAC_CFG_MAC_ADDR_UPPER_16 (0x0001)
#endif
#ifndef MAC_CFG_MAC_ADDR_LOWER_32
#define MAC_CFG_MAC_ADDR_LOWER_32 (0x02030405)
#endif

#endif /*_ETHMAC_CONFIG_H_*/
