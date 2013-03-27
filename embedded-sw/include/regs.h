/*
 * Copyright (C) 2012 LNLS (www.lnls.br)
 * Author: Lucas Russo <lucas.russo@lnls.br>
 *
 * Released according to the GNU GPL, version 2 or any later version.
 */

#ifndef _REGS_H_
#define _REGS_H_

#include <inttypes.h>

#define REGS_DEFAULT_NO_INIT 0
#define REGS_DEFAULT_INIT 1
#define REGS_DEFAULT_END 2

#define REGS_TYPE_READ_ONLY (1 << 0)
#define REGS_TYPE_WRITE_ONLY (1 << 1)
#define REGS_TYPE_READ_WRITE (1 << 2)
#define REGS_TYPE_RESERVED (1 << 3)

#define REGS_DEFAULT_SIZE 4
#define REGS_DEFAULT_TYPE REGS_READ_WRITE

struct default_dev_regs_t
{
	uint8_t type;
	uint8_t size; // in bytes
	uint32_t addr;
	uint32_t val;
};

#endif
