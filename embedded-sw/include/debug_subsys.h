/*
 * Copyright (C) 2013 LNLS (www.lnls.br)
 * Author: Lucas Russo <lucas.russo@lnls.br>
 *
 * Released according to the GNU GPL, version 2 or any later version.
 */

#ifndef _DEBUG_SUBSYS_
#define _DEBUG_SUBSYS_

#define DBG_GENERIC   (0x1 << 4)
#define DBG_GPIO      (0x2 << 4)
#define DBG_SPI       (0x4 << 4)
#define DBG_I2C       (0x8 << 4)
#define DBG_OWR       (0x10 << 4)
#define DBG_ETH       (0x20 << 4)

#define DBG_SUBSYS_ON (DBG_GENERIC | DBG_GPIO | DBG_SPI | DBG_I2C | DBG_OWR | DBG_ETH)

#endif
