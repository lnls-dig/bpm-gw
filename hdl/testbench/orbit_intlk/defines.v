/*******************************
 * General definitions
 *******************************/

// 100 MHz clock
`define CLK_SYS_PERIOD 10.00 //ns

// Reset Delay, in Clock Cycles
`define RST_SYS_DELAY  		10

/*******************************
 * Wishbone definitions
 *******************************/

// Wishbone Reference Clock
`define WB_CLOCK_PERIOD 10.00
`define WB_RESET_DELAY (10*`WB_CLOCK_PERIOD)
`define WB_RESET_COUNTS 6
// Wishbone Data Width
`define WB_DATA_BUS_WIDTH 32
// Wishbone Address Width
`define WB_ADDRESS_BUS_WIDTH 32
`define WB_BWSEL_WIDTH ((`WB_DATA_BUS_WIDTH + 7) / 8)
`define WB_WORD_ACC 2
