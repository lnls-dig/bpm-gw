------------------------------------------------------------------------------
-- Title      : Wishbone FMC516 ADC Interface
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2013-18-03
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Synchronization between all data chains to a single clock
--                domain. The necessity of such module has to be better
--                understood, but so far, it does not appear necessary
-------------------------------------------------------------------------------
-- Copyright (c) 2013 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2013-18-03  1.0      lucas.russo      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.fmc_adc_pkg.all;
use work.genram_pkg.all;

entity fmc_adc_sync_chains is
--generic
--(
--)
port
(
  sys_clk_i                                 : std_logic;
  sys_rst_n_i                               : std_logic;

  -----------------------------
  -- ADC Data Input signals. Each data chain is synchronous to its
  -- own clock.
  -----------------------------
  adc_out_i                                 : in t_adc_out_array(c_num_adc_channels-1 downto 0);

  -- Reference clock for synchronization with all data chains
  adc_refclk_i                              : in t_adc_clk_chain_glob;

  -----------------------------
  -- ADC output signals. Synchronous to a single clock
  -----------------------------
  adc_out_o                                 : out t_adc_out_array(c_num_adc_channels-1 downto 0)
);
end fmc_adc_sync_chains;

architecture rtl of fmc_adc_sync_chains is

  constant c_async_fifo_size                : natural := 16;

  signal adc_ref_clk                        : std_logic;
  signal adc_ref_clk2x                      : std_logic;
  signal adc_data_fifo_in                   : std_logic_vector(c_num_adc_bits*c_num_adc_channels-1 downto 0);
  signal adc_data_fifo_out                  : std_logic_vector(c_num_adc_bits*c_num_adc_channels-1 downto 0);

  -- FIFO signals
  signal adc_fifo_wr                        : std_logic;
  signal adc_fifo_rd                        : std_logic;
  signal adc_fifo_full                      : std_logic;
  signal adc_fifo_empty                     : std_logic;
  signal adc_data_valid_out                 : std_logic;

begin

  adc_ref_clk                               <= adc_refclk_i.adc_clk_bufg;
  adc_ref_clk2x                             <= adc_refclk_i.adc_clk2x_bufg;

  -- Merge FIFO data
  gen_merge_adc_data_channel : for i in 0 to c_num_adc_channels-1 generate -- 0 to 3
    gen_merge_adc_data_bits : for j in 0 to c_num_adc_bits-1 generate -- 0 to 15

      adc_data_fifo_in(i*c_num_adc_bits + j)
                                            <= adc_out_i(i).adc_data(j);

    end generate;
  end generate;

  cmp_adc_data_sync_fifo : generic_sync_fifo
  generic map(
    g_data_width                            => c_num_adc_bits*c_num_adc_channels,
    g_size                                  => c_async_fifo_size
  )
  port map(
    rst_n_i                                 => sys_rst_n_i,

    clk_i                                   => adc_ref_clk,
    d_i                                     => adc_data_fifo_in,
    we_i                                    => adc_fifo_wr,

    q_o                                     => adc_data_fifo_out,
    rd_i                                    => adc_fifo_rd,

    full_o                                  => adc_fifo_full,
    empty_o                                 => adc_fifo_empty
  );

  --Generate valid signal for adc_data_o.
  p_gen_valid : process (adc_ref_clk)
  begin
    if rising_edge (adc_ref_clk) then
      adc_data_valid_out <= adc_fifo_rd;

      if adc_fifo_empty = '1' then
        adc_data_valid_out <= '0';
      end if;
    end if;
  end process;

  adc_fifo_wr                               <= '1';
  adc_fifo_rd                               <= '1';

  -- Unmerge FIFO data
  gen_unmerge_adc_data_channel : for i in 0 to c_num_adc_channels-1 generate -- 0 to 3
    gen_unmerge_adc_data_bits : for j in 0 to c_num_adc_bits-1 generate -- 0 to 15

      adc_out_o(i).adc_data(j) <= adc_data_fifo_out(i*c_num_adc_bits + j);

    end generate;

    adc_out_o(i).adc_clk                  <= adc_ref_clk;
    adc_out_o(i).adc_clk2x                <= adc_ref_clk2x;
    adc_out_o(i).adc_data_valid           <= adc_data_valid_out;

  end generate;

end rtl;
