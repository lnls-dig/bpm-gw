// -- Author: Andrzej Wojenski

`timescale 1ns / 1ps
module shiftreg (CLK, clr, shift, ld, Din, SI, Dout, shiftout);

input CLK;
input clr; // clear register
input shift; // shift
input ld; // load register from Din
input [7:0] Din; // Data input for load
input SI; // Input bit to shift in
output [7:0] Dout;
output shiftout;
reg [7:0] Dout;

assign shiftout = Dout[7];

always @(posedge CLK)
begin
	if (clr) 	 	 Dout <= 0;
	else if (ld)    Dout <= Din;
	else if (shift) Dout <= { Dout[6:0], SI };
end

endmodule // shiftreg

