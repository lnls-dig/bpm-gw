library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.custom_wishbone_pkg.all;
use work.wishbone_pkg.all;

entity xwb_dbe_periph is
generic(
  -- NOT used!
  g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
  -- NOT used!
  g_address_granularity                     : t_wishbone_address_granularity := WORD;
  g_cntr_period                             : integer                        := 100000; -- 100MHz clock, ms granularity
  g_num_leds                                : natural                        := 8;
  g_num_buttons                             : natural                        := 8
);
port(
  clk_sys_i                                 : in std_logic;
  rst_n_i                                   : in std_logic;

  -- UART
  uart_rxd_i                                : in  std_logic;
  uart_txd_o                                : out std_logic;

  -- LEDs
  led_out_o                                 : out std_logic_vector(g_num_leds-1 downto 0);
  led_in_i                                  : in  std_logic_vector(g_num_leds-1 downto 0);
  led_oen_o                                 : out std_logic_vector(g_num_leds-1 downto 0);

  -- Buttons
  button_out_o                              : out std_logic_vector(g_num_buttons-1 downto 0);
  button_in_i                               : in  std_logic_vector(g_num_buttons-1 downto 0);
  button_oen_o                              : out std_logic_vector(g_num_buttons-1 downto 0);

  -- Wishbone
  slave_i                                   : in  t_wishbone_slave_in;
  slave_o                                   : out t_wishbone_slave_out
);
end xwb_dbe_periph;

architecture rtl of xwb_dbe_periph is

begin

  cmp_wb_dbe_periph : wb_dbe_periph
  generic map (
    -- NOT used!
    g_interface_mode                          => g_interface_mode,
    -- NOT used!
    g_address_granularity                     => g_address_granularity,
    g_cntr_period                             => g_cntr_period,
    g_num_leds                                => g_num_leds,
    g_num_buttons                             => g_num_buttons
  )
  port map(
    clk_sys_i                                 => clk_sys_i,
    rst_n_i                                   => rst_n_i,

    -- UART
    uart_rxd_i                                => uart_rxd_i,
    uart_txd_o                                => uart_txd_o,

    -- LEDs
    led_out_o                                 => led_out_o,
    led_in_i                                  => led_in_i,
    led_oen_o                                 => led_oen_o,

    -- Buttons
    button_out_o                              => button_out_o,
    button_in_i                               => button_in_i,
    button_oen_o                              => button_oen_o,

    -- Wishbone
    wb_adr_i                                  => slave_i.adr,
    wb_dat_i                                  => slave_i.dat,
    wb_dat_o                                  => slave_o.dat,
    wb_sel_i                                  => slave_i.sel,
    wb_we_i                                   => slave_i.we,
    wb_cyc_i                                  => slave_i.cyc,
    wb_stb_i                                  => slave_i.stb,
    wb_ack_o                                  => slave_o.ack,
    wb_err_o                                  => slave_o.err,
    wb_rty_o                                  => slave_o.rty,
    wb_stall_o                                => slave_o.stall
  );

end rtl;
