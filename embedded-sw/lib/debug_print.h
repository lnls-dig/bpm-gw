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
#include "debug_subsys.h"

/* temporary */
#define DBG_MIN_LEVEL DBE_DBG_INFO

/* Debug levels */
#define DBE_DBG_TRACE   (0x1 << 1)
#define DBE_DBG_INFO    (0x2 << 1)
#define DBE_DBG_WARN    (0x3 << 1)
#define DBE_DBG_ERR     (0x4 << 1)
#define DBE_DBG_FATAL   (0x5 << 1)

#define DBE_DBG_MASK    (0xF << 1)

/* Debug halt */
#define DBE_DBG_HALT    (0x1)

void debug_print(const char *fmt, ...);
void debug_print2(const char *fmt, const char *data, int len);

#ifdef DBE_DBG
#define dbg_print(fmt, ...) \
    pp_printf("%s (%d): "fmt, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#define dbg_print2(fmt, data, len) \
    debug_print2(fmt, data, len)
#else
#define dbg_print(...)
#define dbg_print2(fmt, data, len)
#endif

/* dbg has the following format:
 *    31 - 4      3 - 1      0-0
 *  DBG_SUBSYS   DBG_LVL   DBG_HALT
 */

#ifdef DBE_DBG

#define DBE_DEBUG(dbg, fmt, ...) do { if (((dbg) & DBG_SUBSYS_ON) && (((dbg) & DBE_DBG_MASK) >= DBG_MIN_LEVEL)) { dbg_print(fmt, ##__VA_ARGS__); if ((dbg) & DBE_DBG_HALT) while(1); } } while(0)
#define DBE_DEBUG_ARRAY(dbg, fmt, ...) do { if (((dbg) & DBG_SUBSYS_ON) && (((dbg) & DBE_DBG_MASK) >= DBG_MIN_LEVEL)) { dbg_print2(fmt, ##__VA_ARGS__); if ((dbg) & DBE_DBG_HALT) while(1); } } while(0)
#define DBE_ERR(...)   do { dbg_print(fmt, ##__VA_ARGS__); } while(0)
#else /* DBE_DEBUG */
#define DBE_DEBUG(dbg, fmt, ...)
#define DBE_DEBUG_ARRAY(dbg, fmt, ...)
#define DBE_ERR(...)

#endif

#endif
