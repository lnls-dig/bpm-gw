`include "timescale.v"
`include "defines.v"

module clk_rst(
  clk_sys_o,
  clk_adc_o,
  clk_100mhz_o,
  clk_200mhz_o,
  rstn_o
);

  // Defaults parameters
  parameter CLK_SYS_PERIOD = `CLK_SYS_PERIOD;
  parameter CLK_ADC_PERIOD = `CLK_ADC_PERIOD;

  localparam CLK_100MHZ_PERIOD = `CLK_100MHZ_PERIOD;
  localparam CLK_200MHZ_PERIOD = `CLK_200MHZ_PERIOD;

  // Output Clocks
  output reg
    clk_sys_o,
    clk_adc_o,
    clk_100mhz_o,
    clk_200mhz_o;

  // Output Reset
  output reg rstn_o;

  // Reset generate
  initial
  begin
    clk_sys_o = 0;
    clk_adc_o = 0;
    clk_100mhz_o = 0;
    clk_200mhz_o = 0;
    rstn_o = 0;
    #(`RST_SYS_DELAY)
    rstn_o = 1;
  end

  // Clock Generation
  always #(CLK_SYS_PERIOD/2) clk_sys_o <= ~clk_sys_o;
  always #(CLK_ADC_PERIOD/2) clk_adc_o <= ~clk_adc_o;
  always #(CLK_100MHZ_PERIOD/2) clk_100mhz_o <= ~clk_100mhz_o;
  always #(CLK_200MHZ_PERIOD/2) clk_200mhz_o <= ~clk_200mhz_o;

endmodule
