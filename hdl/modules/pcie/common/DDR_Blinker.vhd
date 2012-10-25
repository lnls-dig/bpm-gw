----------------------------------------------------------------------------------
-- Company:  ZITI
-- Engineer:  wgao
-- 
-- Create Date:    16:38:03 06 Oct 2008 
-- Design Name: 
-- Module Name:    DDR_Blink - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library work;
use work.abb64Package.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DDR_Blink is
  port (
    DDR_blinker : out std_logic;

    DDR_Write : in std_logic;
    DDR_Read  : in std_logic;
    DDR_Both  : in std_logic;

    ddr_Clock : in std_logic;
    DDr_Rst_n : in std_logic
    );
end entity DDR_Blink;


architecture Behavioral of DDR_Blink is


  -- Blinking -_-_-_-_
  constant C_BLINKER_MSB     : integer := 15;  -- 4;  -- 15;
  constant CBIT_SLOW_BLINKER : integer := 11;  -- 2;  -- 11;

  signal DDR_blinker_i       : std_logic;
  signal Fast_blinker        : std_logic_vector(C_BLINKER_MSB downto 0);
  signal Fast_blinker_MSB_r1 : std_logic;
  signal Blink_Pulse         : std_logic;
  signal Slow_blinker        : std_logic_vector(CBIT_SLOW_BLINKER downto 0);

  signal DDR_write_extension     : std_logic;
  signal DDR_write_extension_Cnt : std_logic_vector(1 downto 0);
  signal DDR_read_extension      : std_logic;
  signal DDR_read_extension_Cnt  : std_logic_vector(1 downto 0);


begin


  -- 
  Syn_DDR_Fast_blinker :
  process (ddr_Clock, DDr_Rst_n)
  begin
    if DDr_Rst_n = '0' then
      Fast_blinker        <= (others => '0');
      Fast_blinker_MSB_r1 <= '0';
      Blink_Pulse         <= '0';

      Slow_blinker <= (others => '0');

    elsif ddr_Clock'event and ddr_Clock = '1' then
      Fast_blinker        <= Fast_blinker + '1';
      Fast_blinker_MSB_r1 <= Fast_blinker(C_BLINKER_MSB);
      Blink_Pulse         <= Fast_blinker(C_BLINKER_MSB) and not Fast_blinker_MSB_r1;

      Slow_blinker <= Slow_blinker + Blink_Pulse;

    end if;
  end process;


  -- 
  Syn_DDR_Write_Extenstion :
  process (ddr_Clock, DDr_Rst_n)
  begin
    if DDr_Rst_n = '0' then
      DDR_write_extension_Cnt <= (others => '0');
      DDR_write_extension     <= '0';

    elsif ddr_Clock'event and ddr_Clock = '1' then

      case DDR_write_extension_Cnt is

        when "00" =>
          if DDR_Write = '1' then
            DDR_write_extension_Cnt <= "01";
            DDR_write_extension     <= '1';
          else
            DDR_write_extension_Cnt <= DDR_write_extension_Cnt;
            DDR_write_extension     <= DDR_write_extension;
          end if;

        when "01" =>
          if Slow_blinker(CBIT_SLOW_BLINKER) = '1' then
            DDR_write_extension_Cnt <= "11";
            DDR_write_extension     <= '1';
          else
            DDR_write_extension_Cnt <= DDR_write_extension_Cnt;
            DDR_write_extension     <= DDR_write_extension;
          end if;

        when "11" =>
          if Slow_blinker(CBIT_SLOW_BLINKER) = '0' then
            DDR_write_extension_Cnt <= "10";
            DDR_write_extension     <= '1';
          else
            DDR_write_extension_Cnt <= DDR_write_extension_Cnt;
            DDR_write_extension     <= DDR_write_extension;
          end if;

        when others =>
          if Slow_blinker(CBIT_SLOW_BLINKER) = '1' then
            DDR_write_extension_Cnt <= "00";
            DDR_write_extension     <= '0';
          else
            DDR_write_extension_Cnt <= DDR_write_extension_Cnt;
            DDR_write_extension     <= DDR_write_extension;
          end if;

      end case;

    end if;
  end process;


  -- 
  Syn_DDR_Read_Extenstion :
  process (ddr_Clock, DDr_Rst_n)
  begin
    if DDr_Rst_n = '0' then
      DDR_read_extension_Cnt <= (others => '0');
      DDR_read_extension     <= '1';

    elsif ddr_Clock'event and ddr_Clock = '1' then

      case DDR_read_extension_Cnt is

        when "00" =>
          if DDR_Read = '1' then
            DDR_read_extension_Cnt <= "01";
            DDR_read_extension     <= '0';
          else
            DDR_read_extension_Cnt <= DDR_read_extension_Cnt;
            DDR_read_extension     <= DDR_read_extension;
          end if;

        when "01" =>
          if Slow_blinker(CBIT_SLOW_BLINKER) = '1' then
            DDR_read_extension_Cnt <= "11";
            DDR_read_extension     <= '0';
          else
            DDR_read_extension_Cnt <= DDR_read_extension_Cnt;
            DDR_read_extension     <= DDR_read_extension;
          end if;

        when "11" =>
          if Slow_blinker(CBIT_SLOW_BLINKER) = '0' then
            DDR_read_extension_Cnt <= "10";
            DDR_read_extension     <= '0';
          else
            DDR_read_extension_Cnt <= DDR_read_extension_Cnt;
            DDR_read_extension     <= DDR_read_extension;
          end if;

        when others =>
          if Slow_blinker(CBIT_SLOW_BLINKER) = '1' then
            DDR_read_extension_Cnt <= "00";
            DDR_read_extension     <= '1';
          else
            DDR_read_extension_Cnt <= DDR_read_extension_Cnt;
            DDR_read_extension     <= DDR_read_extension;
          end if;

      end case;

    end if;
  end process;


  -- 
  Syn_DDR_Working_blinker :
  process (ddr_Clock, DDr_Rst_n)
  begin
    if DDr_Rst_n = '0' then
      DDR_Blinker_i <= '0';

    elsif ddr_Clock'event and ddr_Clock = '1' then

      DDR_Blinker_i <= (Slow_blinker(CBIT_SLOW_BLINKER-2) or DDR_write_extension) and DDR_read_extension;
--         DDR_Blinker_i      <= Slow_blinker(CBIT_SLOW_BLINKER-2);

    end if;
  end process;

  DDR_blinker <= DDR_blinker_i;

end architecture Behavioral;
