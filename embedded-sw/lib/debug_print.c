#include "debug_print.h"
#include "pp-printf.h"

void debug_print(const char *fmt, ...)
{
	va_list l;

	va_start(l, fmt);
	pp_printf(fmt, l);
	va_end(l);
}

void debug_print2(const char *fmt, const char *data, int len)
{
	int i;

	for (i = 0; i < len; ++i)
		pp_printf(fmt, data[i]);

	pp_printf("\n");
}
