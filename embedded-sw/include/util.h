#ifndef _UTIL_H_
#define _UTIL_H_

/* Color codes for cprintf()/pcprintf() */
#define C_DIM 0x80
#define C_WHITE 7
#define C_GREY (C_WHITE | C_DIM)
#define C_RED 1
#define C_GREEN 2
#define C_BLUE 4

/* Return TAI date/time in human-readable form. Non-reentrant. */
char *format_time(uint64_t sec);

/* Color printf() variant. */
void cprintf(int color, const char *fmt, ...);

/* Color printf() variant, sets curspor position to (row, col) before printing. */
void pcprintf(int row, int col, int color, const char *fmt, ...);

/* Clears the terminal scree. */
void term_clear();

#endif
