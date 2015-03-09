-- Authors: Grzegorz Kasprowicz, Andrzej Wojenski
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spi_link_top is
    Port (
          clk       : in   STD_LOGIC;
          reset     : in   STD_LOGIC;
          -- spi interface for accessing the processor and serial number chip
          SPI_CS      : in std_logic;          -- SPI slave select
          SPI_SI      : in  std_logic;           -- slave in
          SPI_SO      : out std_logic;           -- slaveout
          SPI_CLK     : in std_logic;         -- slave clock

          SERIAL_data : out STD_LOGIC_VECTOR(31 downto 0);
          SPI_data_i  : in std_logic_vector(31 downto 0);
          SERIAL_addr : out STD_LOGIC_VECTOR(15 downto 0);
          SERIAL_valid : out STD_LOGIC

);
end spi_link_top;

architecture Behavioral of spi_link_top is

  -- spi interface:
  component spi_link
    port (
      clk               : in  STD_LOGIC;
      reset             : in  STD_LOGIC;
      SCK               : in  STD_LOGIC;
      SDI               : in  STD_LOGIC;
      SDO               : out STD_LOGIC;
      SCS               : in  std_logic;
      data_in           : in  STD_LOGIC_VECTOR (7 downto 0);
      data_out          : out STD_LOGIC_VECTOR(7 downto 0);
      command_out       : out STD_LOGIC_VECTOR(7 downto 0);
      write_en          : out STD_LOGIC;
      transfer_done     : out STD_LOGIC;
      byte_sel          : out STD_LOGIC_VECTOR (3 downto 0);
      addr_sel          : out STD_LOGIC_VECTOR (1 downto 0);
      addr_complete     : out std_logic;
      testout           : out STD_LOGIC_VECTOR (7 downto 0)
        );
  end component;

  --SPI block signals
   signal  spi_data_in : std_logic_vector(7 downto 0);
   signal  spi_data_out,SPI_testout : std_logic_vector(7 downto 0);
   signal  spi_write_en, spi_transfer_done : std_logic;
   signal  spi_byte_sel : std_logic_vector(3 downto 0);
   signal  spi_addr_sel : std_logic_vector(1 downto 0);
   signal  spi_command_out : std_logic_vector(7 downto 0);
   signal  spi_address : std_logic_vector(15 downto 0);
   signal  SPI_data_o : std_logic_vector(31 downto 0);
   SIGNAL  Controlled_by_SPI, SPI_valid_address    : STD_LOGIC ;
   signal spi_addr_complete : std_logic;

begin

-- spi memory interface accesible via VME
      spi_link_1: spi_link
      port map (
      clk         => clk,
      reset       => reset,
      SCK         => SPI_CLK,
      SDI         => SPI_SI,
      SDO         => SPI_SO ,
      SCS         => SPI_CS,
      data_in     => spi_data_in,
      data_out    => spi_data_out,
      command_out => spi_command_out,
      write_en    => spi_write_en,
       transfer_done =>  spi_transfer_done,
      byte_sel    => spi_byte_sel,
       addr_sel   => spi_addr_sel,
        addr_complete => open,
       testout    => open ); --SPI_testout );

--SPI_data_i <= x"12345677";
--  SPI_data_i <= intbus;
--SPi output data register write
 process (reset,Clk)
  begin
    if reset='1' then
     SPI_data_o <=(others => '0');
    elsif rising_edge(Clk) then
--latch SPI data
            if spi_byte_sel(0) = '1' and spi_write_en = '1' then
                SPI_data_o(7 downto 0) <= spi_data_out;
            elsif spi_byte_sel(1) = '1' and spi_write_en = '1' then
                SPI_data_o(15 downto 8) <= spi_data_out;
            elsif spi_byte_sel(2) = '1' and spi_write_en = '1' then
                SPI_data_o(23 downto 16) <= spi_data_out;
            elsif spi_byte_sel(3) = '1' and spi_write_en = '1' then
                SPI_data_o(31 downto 24) <= spi_data_out;
            end if;
--latch SPI address
            if spi_addr_sel(0) = '1' then
                SPI_address(7 downto 0) <= spi_data_out;
            elsif spi_addr_sel(1) = '1'  then
                SPI_address(15 downto 8) <= spi_data_out;
            end if;

    end if;
end process;

--SPI COMMAND
with spi_byte_sel select
spi_data_in <=  SPI_data_i(7 downto 0)   when "0001",
                SPI_data_i(15 downto 8)  when "0010",
                SPI_data_i(23 downto 16) when "0100",
                SPI_data_i(31 downto 24) when others;

--SERIAL_valid <= spi_transfer_done and spi_command_out(7);
SERIAL_addr <= SPI_address;

process (reset,Clk)
  begin
    if reset='1' then
     SERIAL_data <=(others => '0');
      SERIAL_valid <= '0';
    elsif rising_edge(Clk) then

        if spi_transfer_done = '1' then
            SERIAL_valid <= spi_transfer_done and spi_command_out(7); -- 1 cycle delay
        --  SERIAL_addr <= SPI_address;
        else
            SERIAL_valid <= '0';
        end if;

        if spi_transfer_done = '1' and spi_command_out(7) = '1' then
                SERIAL_data <= SPI_data_o;
        end if;

            -- SERIAL_valid <= '1';
        --else
            --SERIAL_valid <= '0';
        --end if;
    end if;
end process;

end Behavioral;

