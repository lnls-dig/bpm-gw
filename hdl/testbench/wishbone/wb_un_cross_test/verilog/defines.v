/*******************************
 * Wishbone definitions
 *******************************/

// Wishbone Reference Clock
`define WB_CLOCK_PERIOD 10.00
`define WB_RESET_DELAY (4*`WB_CLOCK_PERIOD)
`define WB_RESET_COUNTS 6
// Wishbone Data Width
`define WB_DATA_BUS_WIDTH 32
// Wishbone Address Width
`define WB_ADDRESS_BUS_WIDTH 32

/*******************************
 * ADC (FMC516) definitions
 *******************************/
 `define ADC_DATA_WIDTH 16

/*******************************
 * General definitions
 *******************************/

// 100 MHz clock
`define CLK_SYS_PERIOD 10.00
// 100 MHz clock
`define CLK_100MHZ_PERIOD 10.00
// 200 MHz clock
`define CLK_200MHZ_PERIOD 5.00
// 250 MHz clock
`define CLK_ADC_PERIOD 4.0

// Reset Delay
`define RST_SYS_DELAY  (4*CLK_SYS_PERIOD)

// Debug
`define debug 1 // write 1 to debug mode, 
		//and 0 to normal mode.
