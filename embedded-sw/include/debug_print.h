/*
 * Copyright (C) 2012 LNLS (www.lnls.br)
 * Author: Lucas Russo <lucas.russo@lnls.br>
 *
 * Released according to the GNU GPL, version 2 or any later version.
 */

#ifndef _DEBUG_PRINT_
#define _DEBUG_PRINT_

#include <stdarg.h>
#include "pp-printf.h"

//void debug_print(const char *fmt, ...);
void debug_print2(const char *fmt, const char *data, int len);

#ifdef DEBUG_PRINT
#define dbg_print(fmt, ...) \
	pp_printf(fmt, ...)
#define dbg_print2(fmt, data, len) \
	debug_print2(fmt, data, len)
#else
#define dbg_print(const char *fmt, ...)
#define dbg_print2(fmt, data, len)
#endif

#endif
