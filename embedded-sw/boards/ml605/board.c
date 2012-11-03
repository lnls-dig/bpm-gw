#include "board.h"

/* Board-specific initialization code */

int board_init()
{
	return 0;
}

int board_update()
{
	return 0;
}

/*	 Each loop iteration takes 4 cycles.
*	 It runs at 100MHz (LM32 clock).
*/
int delay(int x)
{
	while(x--) asm volatile("nop");
}
