// -- Author: Andrzej Wojenski
`timescale 1ns / 1ps

module spi2wb(

    input wb_clk_i,
    input spi_clk_i, // fast spi clock
    input wb_rst_i,

    // SPI bus
    input SPI_CS,
    input SPI_SI,
    output SPI_SO,
    input SPI_CLK,

    output dbg_spi_clk,
    output dbg_SERIAL_valid,
    output dbg_en,
    output [7:0] dbg_SERIAL_addr,
    output [31:0]dbg_SERIAL_data,
    output [31:0]dbg_SPI_data,

    // Wishbone bus
    input [15:0]wb_addr_i,
    input [31:0]wb_data_i,
    output reg [31:0]wb_data_o,
    input wb_cyc_i,
    input [3:0]wb_sel_i,
    input wb_stb_i,
    input wb_we_i,
    output reg wb_ack_o

    );

wire [31:0]SERIAL_data;
wire [31:0]SPI_data_i;
wire [15:0]SERIAL_addr;
wire [31:0]dpram_data_a;

localparam T_IDLE = 3'b001;
localparam T_DATA_OUT = 3'b010;
localparam T_ACK_CLEAR = 3'b100;
reg [2:0] state; 

spi_link_top spi_link_top_i(

       //.clk(wb_clk_i),
       .clk(spi_clk_i),
       .reset(wb_rst_i),
       // spi interface for accessing the processor and serial number chip
       .SPI_CS(SPI_CS), // -- SPI slave select
       .SPI_SI(SPI_SI), // -- slave in
       .SPI_SO(SPI_SO), // -- slave out
       .SPI_CLK(SPI_CLK), // -- slave clock

       .SERIAL_data(SERIAL_data[31:0]), // out STD_LOGIC_VECTOR(31 downto 0);
       .SPI_data_i(SPI_data_i[31:0]),  // in std_logic_vector(31 downto 0);
       .SERIAL_addr(SERIAL_addr[15:0]), // out STD_LOGIC_VECTOR(15 downto 0);
       .SERIAL_valid(SERIAL_valid) // out STD_LOGIC

    );

// True dual port block RAM
spi2wb_dpram spi2wb_dpram_i (

  // Access from Wishbone bus
  .clka(wb_clk_i), // input clka
  .wea(1'b0), // input [0 : 0] wea
  .addra(wb_addr_i[7:0]), // input [7 : 0] addra
  .dina(32'h00000000), // input [31 : 0] dina
  .douta(dpram_data_a[31:0]), // output [31 : 0] douta

  // Access from SPI core
  //.clkb(wb_clk_i), // input clkb
  .clkb(spi_clk_i), // input clkb
  //.enb(SERIAL_valid), // input enb
  .enb(!SPI_CS), // input enb
  .web(SERIAL_valid), // input [0 : 0] web
  .addrb(SERIAL_addr[7:0]), // input [7 : 0] addrb
  .dinb(SERIAL_data[31:0]), // input [31 : 0] dinb
  .doutb(SPI_data_i[31:0]) // output [31 : 0] doutb
);

// debug signals
assign dbg_spi_clk = spi_clk_i;
assign dbg_SERIAL_valid = SERIAL_valid;
assign dbg_en = !SPI_CS;
assign dbg_SERIAL_addr = SERIAL_addr[7:0];
assign dbg_SERIAL_data = SERIAL_data[31:0];
assign dbg_SPI_data = SPI_data_i[31:0];

// Wishbone data access (read only)
// Wb data out
  always @(posedge wb_clk_i or posedge wb_rst_i)
  begin
    if (wb_rst_i) begin
      state <= T_IDLE;
      wb_data_o <= 32'b0;
      wb_ack_o <= 1'b0;
    end
    else begin
        case (state)
	        T_IDLE: if (wb_cyc_i & wb_stb_i) begin
	           wb_data_o <= wb_data_o;
	           wb_ack_o <= 1'b0;
	           state <= T_DATA_OUT;
	        end
	        
	        T_DATA_OUT: begin
	           wb_data_o <= dpram_data_a[31:0];
	           wb_ack_o <= 1'b1;
	           state <= T_ACK_CLEAR;
	        end
	        
		T_ACK_CLEAR: begin
	           wb_data_o <= wb_data_o;
	           wb_ack_o <= 1'b0;
	           state <= T_IDLE;
	        end

	        default: begin
	           wb_data_o <= wb_data_o;
	           wb_ack_o <= 1'b0;
	           state <= T_IDLE;
	        end
	    endcase
	 end
  end

endmodule
