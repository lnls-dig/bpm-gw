/*
 * Copyright (C) 2013 LNLS (www.lnls.br)
 * Author: Lucas Russo <lucas.russo@lnls.br>
 *
 * Released according to the GNU GPL, version 2 or any later version.
 *
 */

#include "regs.h"

// lmk02000 has 28 msb value and 4 lsb addr
const struct default_dev_regs_t lmk02000_regs_default[] =
{
  {REGS_DEFAULT_INIT,     4, 0x0, 1 << 31             },
  {REGS_DEFAULT_INIT,     4, 0x0, 1 << 8              },

  {REGS_DEFAULT_NO_INIT,  4, 0x1, 0                   },
  {REGS_DEFAULT_INIT,     4, 0x2, (1<<16)|(1<<8)|2    },
  {REGS_DEFAULT_NO_INIT,  4, 0x3, 0                   },
  {REGS_DEFAULT_INIT,     4, 0x4, (1<<16)|(1<<8)| 4   },
  {REGS_DEFAULT_INIT,     4, 0x5, (1<<16)|(1<<8)| 5   },
  {REGS_DEFAULT_INIT,     4, 0x6, (1<<16)|(1<<8)| 6   },
  {REGS_DEFAULT_INIT,     4, 0x7, (1<<16)|(1<<8)| 7   },

  /*
     {REGS_TYPE_RESERVED,    4, 0x8, 0                   },
     {REGS_TYPE_RESERVED,    4, 0x9, 0                   },
     {REGS_TYPE_RESERVED,    4, 0xa, 0                   },
   */

  {REGS_DEFAULT_NO_INIT,  4, 0xb, 0                   },

  /*
     {REGS_TYPE_RESERVED,  4, 0xc, 0                     },
     {REGS_TYPE_RESERVED,  4, 0xd, 0                     },
   */

  {REGS_DEFAULT_INIT,     4, 0xe, 0x2b100100|14       },
  {REGS_DEFAULT_NO_INIT,  4, 0xf, 0x4003e800|15       },
  {REGS_DEFAULT_END,      0, 0  , 0                   }
};

//const struct default_dev_regs_t lmk02000_regs_default[] =
//{
//    // Power down LMK02000 (1<<26)
//    {REGS_DEFAULT_INIT,     4, 0xe, (1<<26)|14          },
//    {REGS_DEFAULT_END,      0, 0  , 0                   }
//};
