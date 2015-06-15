-- Author: Andrzej Wojenski
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY spi2wb_tb IS
END spi2wb_tb;

ARCHITECTURE behavior OF spi2wb_tb IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT spi2wb
    PORT(
         wb_clk_i : IN  std_logic;
            spi_clk_i : in std_logic;
         wb_rst_i : IN  std_logic;
         SPI_CS : IN  std_logic;
         SPI_SI : IN  std_logic;
         SPI_SO : OUT  std_logic;
         SPI_CLK : IN  std_logic;
         wb_addr_i : IN  std_logic_vector(15 downto 0);
         wb_data_i : IN  std_logic_vector(31 downto 0);
         wb_data_o : OUT  std_logic_vector(31 downto 0);
         wb_cyc_i : IN  std_logic;
         wb_sel_i : IN  std_logic_vector(3 downto 0);
         wb_stb_i : IN  std_logic;
         wb_we_i : IN  std_logic;
         wb_ack_o : OUT  std_logic
        );
    END COMPONENT;


   --Inputs
   signal wb_clk_i : std_logic := '0';
   signal wb_rst_i : std_logic := '0';
   signal SPI_CS : std_logic := '0';
   signal SPI_SI : std_logic;
   signal SPI_CLK : std_logic := '0';
   signal wb_addr_i : std_logic_vector(15 downto 0) := (others => '0');
   signal wb_data_i : std_logic_vector(31 downto 0) := (others => '0');
   signal wb_cyc_i : std_logic := '0';
   signal wb_sel_i : std_logic_vector(3 downto 0) := (others => '0');
   signal wb_stb_i : std_logic := '0';
   signal wb_we_i : std_logic := '0';

    --Outputs
   signal SPI_SO : std_logic;
   signal wb_data_o : std_logic_vector(31 downto 0);
   signal wb_ack_o : std_logic;

    signal FAST_CLK : std_logic;
    -- 56 bits
    -- command read (0x0) from addr 0x1
    signal data_pattern : std_logic_vector(55 downto 0) := "00000000" & "00000000" & "00000011" & "01110000" & "10000001" & "00000000" & "00000001";

   -- Clock period definitions
    constant WB_CLK_period : time := 10 ns;
    constant FAST_CLK_period : time := 5 ns;
   constant SPI_CLK_period : time := 100 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
   uut: spi2wb PORT MAP (
          wb_clk_i => wb_clk_i,
             spi_clk_i => FAST_CLK,
          wb_rst_i => wb_rst_i,
          SPI_CS => SPI_CS,
          SPI_SI => SPI_SI,
          SPI_SO => SPI_SO,
          SPI_CLK => SPI_CLK,
          wb_addr_i => wb_addr_i,
          wb_data_i => wb_data_i,
          wb_data_o => wb_data_o,
          wb_cyc_i => wb_cyc_i,
          wb_sel_i => wb_sel_i,
          wb_stb_i => wb_stb_i,
          wb_we_i => wb_we_i,
          wb_ack_o => wb_ack_o
        );

   -- Clock process definitions
   SPI_CLK_process :process
   begin
        SPI_CLK <= '0';
        wait for SPI_CLK_period/2;
        SPI_CLK <= '1';
        wait for SPI_CLK_period/2;
   end process;

    FAST_CLK_process :process
   begin
        FAST_CLK <= '0';
        wait for FAST_CLK_period/2;
        FAST_CLK <= '1';
        wait for FAST_CLK_period/2;
   end process;

    WB_SPI_CLK_process :process
   begin

        wb_clk_i <= '0';
        wait for WB_CLK_period/2;
        wb_clk_i <= '1';
        wait for WB_CLK_period/2;
   end process;

   wb_rst_i <= '1', '0' after 10 ns;

-- command + 2x addr + 4x byte data
-- 24 bits (max 56 bits)
-- generate some rx response - buffer of aabbcc55aa123456
 spi_miso_line: process is
    begin
          SPI_CS <= '1'; -- disable transmission
          wait until wb_rst_i = '1';
          SPI_SI <= data_pattern(55);
          data_pattern(55 downto 0) <= data_pattern(54 downto 0) & data_pattern(0); -- rotation of the buffer
        wait until wb_rst_i = '0';

          -- generate cs
          SPI_CS <= '0'; -- enable transmission
     loop
          wait until SPI_CLK'event and SPI_CLK = '0';
          SPI_SI <= data_pattern(55);
          data_pattern(55 downto 0) <= data_pattern(54 downto 0) & data_pattern(0); -- rotation of the buffer
      end loop;

 end process spi_miso_line;

END;
