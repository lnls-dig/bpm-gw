----------------------------------------------------------------------------------
-- Company:  Creotech
-- Engineer:  abyszuk
--
-- Create Date:    19:47:45 18/01/2013
-- Design Name:
-- Module Name:    ddr_Transact - Behavioral
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
use IEEE.NUMERIC_STD.all;

library work;
use work.abb64Package.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DDR_Transact is
  generic (
    SIMULATION       : string;
    DATA_WIDTH       : integer;
    ADDR_WIDTH       : integer;
    DDR_UI_DATAWIDTH : integer;
    DDR_DQ_WIDTH     : integer
    );
  port (
    --ext logic interface to memory core
    -- memory controller interface --
    memc_ui_clk    : out std_logic;
    memc_cmd_rdy   : out std_logic;
    memc_cmd_en    : in  std_logic;
    memc_cmd_instr : in  std_logic_vector(2 downto 0);
    memc_cmd_addr  : in  std_logic_vector(31 downto 0);
    memc_wr_en     : in  std_logic;
    memc_wr_end    : in  std_logic;
    memc_wr_mask   : in  std_logic_vector(DDR_UI_DATAWIDTH/8-1 downto 0);
    memc_wr_data   : in  std_logic_vector(DDR_UI_DATAWIDTH-1 downto 0);
    memc_wr_rdy    : out std_logic;
    memc_rd_data   : out std_logic_vector(DDR_UI_DATAWIDTH-1 downto 0);
    memc_rd_valid  : out std_logic;
    -- memory arbiter interface
    memarb_acc_req : in  std_logic;
    memarb_acc_gnt : out std_logic;
    --/ext logic interface

    -- PCIE interface
    DDR_wr_eof   : in  std_logic;
    DDR_wr_v     : in  std_logic;
    DDR_wr_Shift : in  std_logic;
    DDR_wr_Mask  : in  std_logic_vector(2-1 downto 0);
    DDR_wr_din   : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    DDR_wr_full  : out std_logic;

    DDR_rdc_v     : in  std_logic;
    DDR_rdc_Shift : in  std_logic;
    DDR_rdc_din   : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    DDR_rdc_full  : out std_logic;

    -- DDR payload FIFO Read Port
    DDR_FIFO_RdEn   : in  std_logic;
    DDR_FIFO_Empty  : out std_logic;
    DDR_FIFO_RdQout : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    --/PCIE interface

    -- Common interface
    DDR_Ready : out std_logic;

    app_addr            : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    app_cmd             : out std_logic_vector(2 downto 0);
    app_en              : out std_logic;
    app_wdf_data        : out std_logic_vector((DDR_UI_DATAWIDTH)-1 downto 0);
    app_wdf_end         : out std_logic;
    app_wdf_mask        : out std_logic_vector((DDR_UI_DATAWIDTH)/8-1 downto 0);
    app_wdf_wren        : out std_logic;
    app_rd_data         : in  std_logic_vector((DDR_UI_DATAWIDTH)-1 downto 0);
    app_rd_data_end     : in  std_logic;
    app_rd_data_valid   : in  std_logic;
    app_rdy             : in  std_logic;
    app_wdf_rdy         : in  std_logic;
    ui_clk              : in  std_logic;
    ui_clk_sync_rst     : in  std_logic;
    init_calib_complete : in  std_logic;

    --clocking & reset
    user_clk      : in std_logic;
    user_reset    : in std_logic
    );
end entity DDR_Transact;

architecture Behavioral of DDR_Transact is
  -- ----------------------------------------------------------------------------
  -- Component declarations
  -- ----------------------------------------------------------------------------
  component DDRs_Control
    generic (
      C_ASYNFIFO_WIDTH  : integer := 72;
      DATA_WIDTH        : integer := 64;
      ADDR_WIDTH        : integer;
      DDR_DQ_WIDTH      : integer;
      DDR_PAYLOAD_WIDTH : integer;
      P_SIMULATION      : string  := "FALSE"
      );
    port (
      -- FPGA interface --
      wr_clk   : in  std_logic;
      wr_eof   : in  std_logic;
      wr_v     : in  std_logic;
      wr_shift : in  std_logic;
      wr_mask  : in  std_logic_vector(2-1 downto 0);
      wr_din   : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      wr_full  : out std_logic;

      rd_clk    : in  std_logic;
      rdc_v     : in  std_logic;
      rdc_shift : in  std_logic;
      rdc_din   : in  std_logic_vector(c_dbus_width-1 downto 0);
      rdc_full  : out std_logic;

      -- ddr payload fifo read port
      rdd_fifo_rden  : in  std_logic;
      rdd_fifo_empty : out std_logic;
      rdd_fifo_dout  : out std_logic_vector(c_dbus_width-1 downto 0);

      -- memory controller interface --
      memc_cmd_rdy   : in   std_logic;
      memc_cmd_en    : out  std_logic;
      memc_cmd_instr : out  std_logic_vector(2 downto 0);
      memc_cmd_addr  : out  std_logic_vector(ADDR_WIDTH-1 downto 0);
      memc_wr_en     : out  std_logic;
      memc_wr_end    : out  std_logic;
      memc_wr_mask   : out  std_logic_vector(DDR_UI_DATAWIDTH/8-1 downto 0);
      memc_wr_data   : out  std_logic_vector(DDR_UI_DATAWIDTH-1 downto 0);
      memc_wr_rdy    : in   std_logic;
      memc_rd_en     : out  std_logic;
      memc_rd_data   : in   std_logic_vector(DDR_UI_DATAWIDTH-1 downto 0);
      memc_rd_valid  : in   std_logic;

      -- memory arbiter interface
      memarb_acc_req : out std_logic;
      memarb_acc_gnt : in  std_logic;

      memc_ui_clk : in std_logic;
      ddr_rdy     : in std_logic;
      reset       : in std_logic
      );
  end component;

  -- ----------------------------------------------------------------------------
  -- Signal & type declarations
  -- ----------------------------------------------------------------------------

  type ddr_switch_t is (EXT, PCIE);
  signal ddr_switch : ddr_switch_t := PCIE;
  signal arb_req    : std_logic_vector(1 downto 0);

  signal pcie_cmd_rdy   : std_logic;
  signal pcie_cmd_en    : std_logic;
  signal pcie_cmd_instr : std_logic_vector(2 downto 0);
  signal pcie_cmd_addr  : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal pcie_wr_en     : std_logic;
  signal pcie_wr_end    : std_logic;
  signal pcie_wr_mask   : std_logic_vector(DDR_UI_DATAWIDTH/8-1 downto 0);
  signal pcie_wr_data   : std_logic_vector(DDR_UI_DATAWIDTH-1 downto 0);
  signal pcie_wr_rdy    : std_logic;
  signal pcie_rd_en     : std_logic;
  signal pcie_rd_data   : std_logic_vector(DDR_UI_DATAWIDTH-1 downto 0);
  signal pcie_rd_valid  : std_logic;
  signal pcie_arb_gnt   : std_logic;
  signal pcie_arb_req   : std_logic;

  signal ext_cmd_rdy   : std_logic;
  signal ext_cmd_en    : std_logic;
  signal ext_cmd_instr : std_logic_vector(2 downto 0);
  signal ext_cmd_addr  : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal ext_wr_en     : std_logic;
  signal ext_wr_end    : std_logic;
  signal ext_wr_mask   : std_logic_vector(DDR_UI_DATAWIDTH/8-1 downto 0);
  signal ext_wr_data   : std_logic_vector(DDR_UI_DATAWIDTH-1 downto 0);
  signal ext_wr_rdy    : std_logic;
  signal ext_rd_en     : std_logic;
  signal ext_rd_data   : std_logic_vector(DDR_UI_DATAWIDTH-1 downto 0);
  signal ext_rd_valid  : std_logic;
  signal ext_arb_gnt   : std_logic;
  signal ext_arb_req   : std_logic;

  signal ddr_reset_n : std_logic;

begin

  memc_ui_clk <= ui_clk;
  ddr_reset_n <= not(ui_clk_sync_rst);

  access_arb :
  process (ui_clk, user_reset)
  begin
    if user_reset = '1' then
      ext_arb_gnt  <= '0';
      pcie_arb_gnt <= '0';
      ddr_switch   <= PCIE;
    elsif rising_edge(ui_clk) then
      case arb_req is
        when "00" =>
          pcie_arb_gnt <= '0';
          ext_arb_gnt  <= '0';
          ddr_switch   <= ddr_switch;

        when "01" => --PCIE
          pcie_arb_gnt <= '1';
          ext_arb_gnt  <= '0';
          ddr_switch   <= PCIE;

        when "10" => --EXT
          pcie_arb_gnt <= '0';
          ext_arb_gnt  <= '1';
          ddr_switch   <= EXT;

        when "11" =>
          if (pcie_arb_gnt or ext_arb_gnt) = '1' then
            --we have already granted access, so wait until one of interested modules releases/gives up
            pcie_arb_gnt <= pcie_arb_gnt;
            ext_arb_gnt  <= ext_arb_gnt;
            ddr_switch   <= ddr_switch;
          else
            --simultaneous access request, favor PCIE
            pcie_arb_gnt <= '1';
            ext_arb_gnt  <= '0';
            ddr_switch   <= PCIE;
          end if;

        when others =>
          pcie_arb_gnt <= '0';
          ext_arb_gnt  <= '0';
          ddr_switch   <= ddr_switch;

      end case;
    end if;
  end process;

  arb_req <= ext_arb_req & pcie_arb_req;

  ddr_core_arb_mux :
  process (ddr_switch, pcie_cmd_addr, pcie_cmd_instr, pcie_cmd_en, pcie_wr_data, pcie_wr_en, pcie_wr_end, pcie_wr_mask,
           ext_cmd_addr, ext_cmd_instr, ext_cmd_en, ext_wr_data, ext_wr_en, ext_wr_end, ext_wr_mask, app_rdy,
           app_wdf_rdy, app_rd_data, app_rd_data_valid)
  begin
    case ddr_switch is
      when PCIE =>
        app_addr      <= pcie_cmd_addr;
        app_cmd       <= pcie_cmd_instr;
        app_en        <= pcie_cmd_en;
        app_wdf_data  <= pcie_wr_data;
        app_wdf_end   <= pcie_wr_end;
        app_wdf_mask  <= pcie_wr_mask;
        app_wdf_wren  <= pcie_wr_en;
        pcie_cmd_rdy  <= app_rdy;
        pcie_wr_rdy   <= app_wdf_rdy;
        pcie_rd_data  <= app_rd_data;
        pcie_rd_valid <= app_rd_data_valid;
        ext_cmd_rdy   <= '0';
        ext_wr_rdy    <= '0';
        ext_rd_data   <= (others => '0');
        ext_rd_valid  <= '0';

      when EXT =>
        app_addr      <= ext_cmd_addr;
        app_cmd       <= ext_cmd_instr;
        app_en        <= ext_cmd_en;
        app_wdf_data  <= ext_wr_data;
        app_wdf_end   <= ext_wr_end;
        app_wdf_mask  <= ext_wr_mask;
        app_wdf_wren  <= ext_wr_en;
        pcie_cmd_rdy  <= '0';
        pcie_wr_rdy   <= '0';
        pcie_rd_data  <= (others => '0');
        pcie_rd_valid <= '0';
        ext_cmd_rdy   <= app_rdy;
        ext_wr_rdy    <= app_wdf_rdy;
        ext_rd_data   <= app_rd_data;
        ext_rd_valid  <= app_rd_data_valid;

    end case;
  end process;

  memc_cmd_rdy   <= ext_cmd_rdy;
  ext_cmd_en     <= memc_cmd_en;
  ext_cmd_instr  <= memc_cmd_instr;
  ext_cmd_addr   <= memc_cmd_addr(ADDR_WIDTH-1 downto 0);
  ext_wr_en      <= memc_wr_en;
  ext_wr_end     <= memc_wr_end;
  ext_wr_mask    <= memc_wr_mask;
  ext_wr_data    <= memc_wr_data;
  memc_wr_rdy    <= ext_wr_rdy;
  memc_rd_data   <= ext_rd_data;
  memc_rd_valid  <= ext_rd_valid;
  memarb_acc_gnt <= ext_arb_gnt;
  ext_arb_req    <= memarb_acc_req;

  DDR_Ready <= init_calib_complete;

  u_ddr_control : DDRs_Control
    generic map (
      P_SIMULATION => SIMULATION,
      ADDR_WIDTH => ADDR_WIDTH,
      DDR_DQ_WIDTH => DDR_DQ_WIDTH,
      DDR_PAYLOAD_WIDTH => DDR_UI_DATAWIDTH
      )
    port map (
      -- FPGA interface --
      wr_clk   => user_clk, --: in  std_logic;
      wr_eof   => DDR_wr_eof, --: in  std_logic;
      wr_v     => DDR_wr_v, --: in  std_logic;
      wr_shift => DDR_wr_Shift, --: in  std_logic;
      wr_mask  => DDR_wr_Mask, --: in  std_logic_vector(2-1 downto 0);
      wr_din   => DDR_wr_din, --: in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      wr_full  => DDR_wr_full, --: out std_logic;

      rd_clk    => user_clk, --: in  std_logic;
      rdc_v     => DDR_rdc_v, --: in  std_logic;
      rdc_shift => DDR_rdc_Shift, --: in  std_logic;
      rdc_din   => DDR_rdc_din, --: in  std_logic_vector(c_dbus_width-1 downto 0);
      rdc_full  => DDR_rdc_full, --: out std_logic;

      -- ddr payload fifo read port
      rdd_fifo_rden  => DDR_FIFO_RdEn, --: in  std_logic;
      rdd_fifo_empty => DDR_FIFO_Empty, --: out std_logic;
      rdd_fifo_dout  => DDR_FIFO_RdQout, --: out std_logic_vector(c_dbus_width-1 downto 0);

      -- memory controller interface --
      memc_cmd_rdy   => pcie_cmd_rdy, --: in   std_logic;
      memc_cmd_en    => pcie_cmd_en, --: out  std_logic;
      memc_cmd_instr => pcie_cmd_instr, --: out  std_logic_vector(2 downto 0);
      memc_cmd_addr  => pcie_cmd_addr, --: out  std_logic_vector(31 downto 0);
      memc_wr_en     => pcie_wr_en, --: out  std_logic;
      memc_wr_end    => pcie_wr_end, --: out  std_logic;
      memc_wr_mask   => pcie_wr_mask, --: out  std_logic_vector(data_width/8-1 downto 0);
      memc_wr_data   => pcie_wr_data, --: out  std_logic_vector(data_width-1 downto 0);
      memc_wr_rdy    => pcie_wr_rdy, --: in   std_logic;
      memc_rd_en     => pcie_rd_en, --: out  std_logic;
      memc_rd_data   => pcie_rd_data, --: in   std_logic_vector(data_width-1 downto 0);
      memc_rd_valid  => pcie_rd_valid, --: in   std_logic;

      -- memory arbiter interface
      memarb_acc_req => pcie_arb_req, --: out std_logic;
      memarb_acc_gnt => pcie_arb_gnt, --: in  std_logic;

      memc_ui_clk => ui_clk, --: in std_logic;
      ddr_rdy     => ddr_reset_n, --: in std_logic;
      reset       => user_reset   --: in std_logic
    );

end architecture Behavioral;
