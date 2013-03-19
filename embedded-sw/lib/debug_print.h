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

void debug_print(const char *fmt, ...);
//__attribute__((format(printf,1,2)));

void debug_print2(const char *fmt, const char *data, int len);

#ifdef DEBUG_PRINT
#define dbg_print(fmt, ...) \
    pp_printf("%s: %s (%d): "fmt, __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#define dbg_print2(fmt, data, len) \
    debug_print2(fmt, data, len)
#else
#define dbg_print(...)
#define dbg_print2(fmt, data, len)
#endif

#endif
