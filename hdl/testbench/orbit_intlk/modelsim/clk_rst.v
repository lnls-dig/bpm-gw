`include "timescale.v"
`include "defines.v"

module clk_rst(
  clk_sys_o,
  sys_rstn_o
);

  // Defaults parameters
  parameter CLK_SYS_PERIOD = `CLK_SYS_PERIOD;

  // Output Clocks
  output reg
    clk_sys_o;

  // Output Reset
  output reg
    sys_rstn_o;

  initial
  begin
    clk_sys_o = 0;
  end

  // Reset generate
  initial
  begin
    sys_rstn_o <= 1'b0;

    repeat (`RST_SYS_DELAY) begin
      @(posedge clk_sys_o);
    end

    @(posedge clk_sys_o);
    sys_rstn_o <= 1'b1;
  end

  // Clock Generation
  always #(CLK_SYS_PERIOD/2)
    clk_sys_o <= ~clk_sys_o;

endmodule
