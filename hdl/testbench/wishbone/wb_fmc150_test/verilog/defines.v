/*******************************
 * Wishbone definitions
 *******************************/

// Wishbone Reference Clock
`define WB_CLOCK_PERIOD 10.00
`define WB_RESET_DELAY (4*`WB_CLOCK_PERIOD)
// Wishbone Data Width
`define WB_DATA_BUS_WIDTH 32
// Wishbone Address Width
`define WB_ADDRESS_BUS_WIDTH 32

/*******************************
 * ADC (FMC150) definitions
 *******************************/
 `define ADC_DATA_WIDTH 14 

/*******************************
 * General definitions
 *******************************/

// 100 MHz clock
`define CLK_SYS_PERIOD 10.00
// 100 MHz clock
`define CLK_100MHZ_PERIOD 10.00
// 200 MHz clock
`define CLK_200MHZ_PERIOD 5.00
// 61.44 MHz clock
`define CLK_ADC_PERIOD 16.28
// 122.88 MHz clock
`define CLK_ADC_2X_PERIOD 8.14

// Reset Delay
`define RST_SYS_DELAY  (4*CLK_SYS_PERIOD)
