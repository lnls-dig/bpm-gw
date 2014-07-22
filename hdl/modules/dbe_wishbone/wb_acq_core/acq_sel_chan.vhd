------------------------------------------------------------------------------
-- Title      : Acquisition Select Channel
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2013-06-11
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Simple MUX for selecting an acquisition channel. Basically a
--               1 clock cycle latency MUX
-------------------------------------------------------------------------------
-- Copyright (c) 2013 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2014-21-07  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.acq_core_pkg.all;

entity acq_sel_chan is
generic
(
  g_acq_num_channels                        : natural := 1
);
port
(
  clk_i                                     : in  std_logic;
  rst_n_i                                   : in  std_logic;
  
  -----------------------------
  -- Acquisiton Interface
  -----------------------------
  acq_val_low_i                             : in t_acq_val_half_array(g_acq_num_channels-1 downto 0);
  acq_val_high_i                            : in t_acq_val_half_array(g_acq_num_channels-1 downto 0);
  acq_dvalid_i                              : in std_logic_vector(g_acq_num_channels-1 downto 0);
  acq_trig_i                                : in std_logic_vector(g_acq_num_channels-1 downto 0);
  acq_curr_chan_id_i                        : in unsigned(c_chan_id_width-1 downto 0);
  
  -----------------------------
  -- Output Interface. 
  -----------------------------
  acq_data_o                                : out std_logic_vector(c_acq_chan_max_w-1 downto 0);
  acq_dvalid_o                              : out std_logic;
  acq_trig_o                                : out std_logic
);
end acq_sel_chan;

architecture rtl of acq_sel_chan is
  
  signal acq_data_marsh_demux               : std_logic_vector(c_acq_chan_max_w-1 downto 0);
  signal acq_trig_demux                     : std_logic;
  signal acq_dvalid_demux                   : std_logic;
  
  signal acq_data_marsh_demux_reg           : std_logic_vector(c_acq_chan_max_w-1 downto 0);
  signal acq_trig_demux_reg                 : std_logic;
  signal acq_dvalid_demux_reg               : std_logic;

begin
  
  acq_data_marsh_demux                   <=
    f_acq_chan_conv_val(f_acq_chan_marshall_val(acq_val_high_i(to_integer(acq_curr_chan_id_i)),
      acq_val_low_i(to_integer(acq_curr_chan_id_i))));
  acq_trig_demux                         <= acq_trig_i(to_integer(acq_curr_chan_id_i));
  acq_dvalid_demux                       <= acq_dvalid_i(to_integer(acq_curr_chan_id_i));

 p_reg_demux : process (clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        acq_data_marsh_demux_reg <= (others => '0');
	acq_dvalid_demux_reg <= '0';
	acq_trig_demux_reg <= '0';
      else
        acq_data_marsh_demux_reg <= acq_data_marsh_demux;
	acq_dvalid_demux_reg <= acq_dvalid_demux;
	acq_trig_demux_reg <= acq_trig_demux;
      end if;
    end if;
  end process;
  
  acq_data_o                               <= acq_data_marsh_demux_reg; 
  acq_dvalid_o                             <= acq_dvalid_demux_reg;
  acq_trig_o                               <= acq_trig_demux_reg; 

end rtl;
