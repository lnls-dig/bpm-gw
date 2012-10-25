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

entity eb_wrapper is
  generic (
    C_ASYNFIFO_WIDTH : integer := 72
    );
  port (

    --FIFO PCIe-->USER
    H2B_wr_clk        : in  std_logic;
    H2B_wr_en         : in  std_logic;
    H2B_wr_din        : in  std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
    H2B_wr_pfull      : out std_logic;
    H2B_wr_full       : out std_logic;
    H2B_wr_data_count : out std_logic_vector(C_EMU_FIFO_DC_WIDTH-1 downto 0);
    H2B_rd_clk        : in  std_logic;
    H2B_rd_en         : in  std_logic;
    H2B_rd_dout       : out std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
    H2B_rd_pempty     : out std_logic;
    H2B_rd_empty      : out std_logic;
    H2B_rd_data_count : out std_logic_vector(C_EMU_FIFO_DC_WIDTH-1 downto 0);
    H2B_rd_valid      : out std_logic;
    --FIFO USER-->PCIe
    B2H_wr_clk        : in  std_logic;
    B2H_wr_en         : in  std_logic;
    B2H_wr_din        : in  std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
    B2H_wr_pfull      : out std_logic;
    B2H_wr_full       : out std_logic;
    B2H_wr_data_count : out std_logic_vector(C_EMU_FIFO_DC_WIDTH-1 downto 0);
    B2H_rd_clk        : in  std_logic;
    B2H_rd_en         : in  std_logic;
    B2H_rd_dout       : out std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
    B2H_rd_pempty     : out std_logic;
    B2H_rd_empty      : out std_logic;
    B2H_rd_data_count : out std_logic_vector(C_EMU_FIFO_DC_WIDTH-1 downto 0);
    B2H_rd_valid      : out std_logic;
    --RESET from PCIe
    rst               : in  std_logic
    );
end entity eb_wrapper;


architecture Behavioral of eb_wrapper is

  ---  32768 x 64, with data count synchronized to rd_clk
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
      wr_data_count : out std_logic_vector(C_EMU_FIFO_DC_WIDTH-1 downto 0);
      valid         : out std_logic;
      rst           : in  std_logic
      );
  end component;

  signal B2H_rd_data_count_wire : std_logic_vector(C_EMU_FIFO_DC_WIDTH-1 downto 0);
  signal B2H_rd_data_count_i    : std_logic_vector(C_EMU_FIFO_DC_WIDTH-1 downto 0);
  signal H2B_rd_data_count_wire : std_logic_vector(C_EMU_FIFO_DC_WIDTH-1 downto 0);
  signal H2B_rd_data_count_i    : std_logic_vector(C_EMU_FIFO_DC_WIDTH-1 downto 0);
  signal B2H_wr_data_count_wire : std_logic_vector(C_EMU_FIFO_DC_WIDTH-1 downto 0);
  signal B2H_wr_data_count_i    : std_logic_vector(C_EMU_FIFO_DC_WIDTH-1 downto 0);
  signal H2B_wr_data_count_wire : std_logic_vector(C_EMU_FIFO_DC_WIDTH-1 downto 0);
  signal H2B_wr_data_count_i    : std_logic_vector(C_EMU_FIFO_DC_WIDTH-1 downto 0);


  signal resized_H2B_wr_din  : std_logic_vector(64-1 downto 0);
  signal resized_H2B_rd_dout : std_logic_vector(64-1 downto 0);
  signal resized_B2H_wr_din  : std_logic_vector(64-1 downto 0);
  signal resized_B2H_rd_dout : std_logic_vector(64-1 downto 0);


begin

  B2H_rd_data_count <= B2H_rd_data_count_i;
  H2B_rd_data_count <= H2B_rd_data_count_i;
  B2H_wr_data_count <= B2H_wr_data_count_i;
  H2B_wr_data_count <= H2B_wr_data_count_i;

  resized_H2B_wr_din <= H2B_wr_din(64-1 downto 0);
  resized_B2H_wr_din <= B2H_wr_din(64-1 downto 0);


  H2B_rd_dout(71 downto 64) <= C_ALL_ZEROS(71 downto 64);
  H2B_rd_dout(63 downto 0)  <= resized_H2B_rd_dout;

  B2H_rd_dout(71 downto 64) <= C_ALL_ZEROS(71 downto 64);
  B2H_rd_dout(63 downto 0)  <= resized_B2H_rd_dout;




  --  ------------------------------------------
  Syn_B2H_rd_data_count :
  process (B2H_rd_clk)
  begin
    if B2H_rd_clk'event and B2H_rd_clk = '1' then
      B2H_rd_data_count_i <= B2H_rd_data_count_wire;
    end if;
  end process;

  Syn_H2B_rd_data_count :
  process (H2B_rd_clk)
  begin
    if H2B_rd_clk'event and H2B_rd_clk = '1' then
      H2B_rd_data_count_i <= H2B_rd_data_count_wire;
    end if;
  end process;

  Syn_H2B_wr_data_count :
  process (H2B_wr_clk)
  begin
    if H2B_wr_clk'event and H2B_wr_clk = '1' then
      H2B_wr_data_count_i <= H2B_wr_data_count_wire;
    end if;
  end process;

  Syn_B2H_wr_data_count :
  process (B2H_wr_clk)
  begin
    if B2H_wr_clk'event and B2H_wr_clk = '1' then
      B2H_wr_data_count_i <= B2H_wr_data_count_wire;
    end if;
  end process;
  --  ------------------------------------------


----- Host2Board FIFO ----------
  U0_H2B :
    eb_fifo_counted_resized
      port map (
        wr_clk        => H2B_wr_clk ,
        wr_en         => H2B_wr_en ,
        din           => resized_H2B_wr_din ,
        prog_full     => H2B_wr_pfull ,
        full          => H2B_wr_full ,
        rd_clk        => H2B_rd_clk ,
        rd_en         => H2B_rd_en ,
        dout          => resized_H2B_rd_dout ,
        prog_empty    => H2B_rd_pempty ,
        empty         => H2B_rd_empty ,
        rd_data_count => H2B_rd_data_count_wire ,
        wr_data_count => H2B_wr_data_count_wire ,
        valid         => H2B_rd_valid ,
        rst           => rst
        );


----- Board2Host FIFO ----------
  U0_B2H :
    eb_fifo_counted_resized
      port map (
        wr_clk        => B2H_wr_clk ,
        wr_en         => B2H_wr_en ,
        din           => resized_B2H_wr_din ,
        prog_full     => B2H_wr_pfull ,
        full          => B2H_wr_full ,
        rd_clk        => B2H_rd_clk ,
        rd_en         => B2H_rd_en ,
        dout          => resized_B2H_rd_dout ,
        prog_empty    => B2H_rd_pempty ,
        empty         => B2H_rd_empty ,
        rd_data_count => B2H_rd_data_count_wire ,
        wr_data_count => B2H_wr_data_count_wire ,
        valid         => B2H_rd_valid ,
        rst           => rst
        );

end architecture Behavioral;
