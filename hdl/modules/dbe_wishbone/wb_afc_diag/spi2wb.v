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

// Wishbone data access (read only)
// Wb data out
  always @(posedge wb_clk_i or posedge wb_rst_i)
  begin
    if (wb_rst_i)
      wb_data_o <= 32'b0;
    else
        if (wb_cyc_i & wb_stb_i)
            wb_data_o <= dpram_data_a[31:0]; // output from memory block
        else
            wb_data_o <= wb_data_o;
  end

  // Wb acknowledge
  always @(posedge wb_clk_i or posedge wb_rst_i)
  begin
    if (wb_rst_i)
      wb_ack_o <= 1'b0;
    else
      wb_ack_o <= wb_cyc_i & wb_stb_i & ~wb_ack_o;
  end

endmodule
