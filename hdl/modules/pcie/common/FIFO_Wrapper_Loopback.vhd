----------------------------------------------------------------------------------
-- Company:  ZITI
-- Engineer:  wgao
-- 
-- Create Date:    16:37:22 12 Feb 2009
-- Design Name: 
-- Module Name:    eb_wrapper - Behavioral 
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

entity eb_wrapper_loopback is
  generic (
    C_ASYNFIFO_WIDTH : integer := 72
    );
  port (
    wr_clk : in  std_logic;
    wr_en  : in  std_logic;
    din    : in  std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
    pfull  : out std_logic;
    full   : out std_logic;

    rd_clk : in  std_logic;
    rd_en  : in  std_logic;
    dout   : out std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
    pempty : out std_logic;
    empty  : out std_logic;

    data_count : out std_logic_vector(C_EMU_FIFO_DC_WIDTH-1 downto 0);
    rst        : in  std_logic
    );
end entity eb_wrapper_loopback;


architecture Behavioral of eb_wrapper_loopback is

  ---  16384 x 72
  component eb_fifo
    port (
      wr_clk    : in  std_logic;
      wr_en     : in  std_logic;
      din       : in  std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
      prog_full : out std_logic;
      full      : out std_logic;

      rd_clk     : in  std_logic;
      rd_en      : in  std_logic;
      dout       : out std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
      prog_empty : out std_logic;
      empty      : out std_logic;

      rst : in std_logic
      );
  end component;

  ---  16384 x 64, with data count synchronized to rd_clk
  component eb_fifo_counted_resized
    port (
      wr_clk    : in  std_logic;
      wr_en     : in  std_logic;
      din       : in  std_logic_vector(C_ASYNFIFO_WIDTH-1-8 downto 0);
      prog_full : out std_logic;
      full      : out std_logic;

      rd_clk        : in  std_logic;
      rd_en         : in  std_logic;
      dout          : out std_logic_vector(C_ASYNFIFO_WIDTH-1-8 downto 0);
      prog_empty    : out std_logic;
      empty         : out std_logic;
      rd_data_count : out std_logic_vector(C_EMU_FIFO_DC_WIDTH-1 downto 0);

      rst : in std_logic
      );
  end component;

  signal data_count_wire : std_logic_vector(C_EMU_FIFO_DC_WIDTH-1 downto 0);
  signal data_count_i    : std_logic_vector(C_EMU_FIFO_DC_WIDTH-1 downto 0);


  signal my_din  : std_logic_vector(64-1 downto 0);
  signal my_dout : std_logic_vector(64-1 downto 0);

begin

  data_count <= data_count_i;

  my_din             <= din(64-1 downto 0);
  dout(71 downto 64) <= C_ALL_ZEROS(71 downto 64);
  dout(63 downto 0)  <= my_dout;

  --  ------------------------------------------
  Syn_EB_FIFO_data_count :
  process (rd_clk)
  begin
    if rd_clk'event and rd_clk = '1' then
      data_count_i <= data_count_wire;
    end if;
  end process;

  --  ------------------------------------------
  U0 :
    eb_fifo_counted_resized
      port map (
        wr_clk    => wr_clk ,
        wr_en     => wr_en ,
        din       => my_din ,
        prog_full => pfull ,
        full      => full ,

        rd_clk        => rd_clk ,
        rd_en         => rd_en ,
        dout          => my_dout ,
        prog_empty    => pempty ,
        empty         => empty ,
        rd_data_count => data_count_wire ,

        rst => rst
        );

end architecture Behavioral;
