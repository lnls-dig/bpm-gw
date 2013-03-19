/*
 * Copyright (C) 2013 LNLS (www.lnls.br)
 * Author: Lucas Russo <lucas.russo@lnls.br>
 *
 * Released according to the GNU GPL, version 2 or any later version.
 */

#include "regs.h"

// isla216p25 has 8-bit value and 13-bit register address
const struct default_dev_regs_t isla216p25_regs_default[] =
{
    /*
    {REGS_DEFAULT_INIT,     1, 0x0, 1 << 1              },
    {REGS_DEFAULT_INIT,     1, 0x0, 1 << 0              },
    */
    {REGS_DEFAULT_INIT,     1, 0x00, 1 << 5             },
    {REGS_DEFAULT_INIT,     1, 0x00, 0 << 5             },
    {REGS_DEFAULT_INIT,     1, 0x2b, 1 << 0             },
    {REGS_DEFAULT_INIT,     1, 0x72, 1 << 0             },
    {REGS_DEFAULT_END,      0, 0  , 0                   }
};
