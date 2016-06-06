library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.dbe_wishbone_pkg.all;
use work.wishbone_pkg.all;

entity wb_dbe_periph is
generic(
  -- NOT used!
  g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
  -- NOT used!
  g_address_granularity                     : t_wishbone_address_granularity := WORD;
  g_cntr_period                             : integer                        := 100000; -- 100MHz clock, ms granularity
  g_num_leds                                : natural                        := 8;
  g_with_led_heartbeat                      : t_boolean_array                ;          -- must match g_num_leds width
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
  wb_adr_i                                  : in  std_logic_vector(c_wishbone_address_width-1 downto 0) := (others => '0');
  wb_dat_i                                  : in  std_logic_vector(c_wishbone_data_width-1 downto 0) := (others => '0');
  wb_dat_o                                  : out std_logic_vector(c_wishbone_data_width-1 downto 0);
  wb_sel_i                                  : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0) := (others => '0');
  wb_we_i                                   : in  std_logic := '0';
  wb_cyc_i                                  : in  std_logic := '0';
  wb_stb_i                                  : in  std_logic := '0';
  wb_ack_o                                  : out std_logic;
  wb_err_o                                  : out std_logic;
  wb_rty_o                                  : out std_logic;
  wb_stall_o                                : out std_logic
);
end wb_dbe_periph;

architecture rtl of wb_dbe_periph is

  -----------------------------
  -- Crossbar component constants
  -----------------------------
    -- Internal crossbar layout
  -- 0 -> Simple UART.
  -- 1 -> Board LEDs.
  -- 2 -> Board Buttons.
  -- 3 -> TICs counter.
  constant c_slaves                         : natural := 4;
  -- Number of masters
  constant c_masters                        : natural := 1;            -- Top master.

  -- WB SDB (Self describing bus) layout
  constant c_layout : t_sdb_record_array(c_slaves-1 downto 0) :=
  ( 0 => f_sdb_embed_device(c_xwb_uart_sdb,             x"00000000"),   -- UART
    1 => f_sdb_embed_device(c_xwb_gpio32_sdb,           x"00000100"),   -- LEDs
    2 => f_sdb_embed_device(c_xwb_gpio32_sdb,           x"00000200"),   -- Buttons
    3 => f_sdb_embed_device(c_xwb_tics_counter_sdb,     x"00000300")    -- TICs counter
  );

  -- Self Describing Bus ROM Address. It will be an addressed slave as well.
  constant c_sdb_address                    : t_wishbone_address := x"00000400";

  signal cbar_slave_in                      : t_wishbone_slave_in_array (c_masters-1 downto 0);
  signal cbar_slave_out                     : t_wishbone_slave_out_array(c_masters-1 downto 0);
  signal cbar_master_in                     : t_wishbone_master_in_array(c_slaves-1 downto 0);
  signal cbar_master_out                    : t_wishbone_master_out_array(c_slaves-1 downto 0);

  signal led_gpio_out_int                   : std_logic_vector(g_num_leds-1 downto 0) := (others => '0');
  signal led_heartbeat_out_int              : std_logic_vector(g_num_leds-1 downto 0) := (others => '0');

begin

  cmp_interconnect : xwb_sdb_crossbar
  generic map(
    g_num_masters                             => c_masters,
    g_num_slaves                              => c_slaves,
    g_registered                              => true,
    g_wraparound                              => true, -- Should be true for nested buses
    g_layout                                  => c_layout,
    g_sdb_addr                                => c_sdb_address
  )
  port map(
    clk_sys_i                                 => clk_sys_i,
    rst_n_i                                   => rst_n_i,
    -- Master connections (INTERCON is a slave)
    slave_i                                   => cbar_slave_in,
    slave_o                                   => cbar_slave_out,
    -- Slave connections (INTERCON is a master)
    master_i                                  => cbar_master_in,
    master_o                                  => cbar_master_out
  );

  -- External master connection
  cbar_slave_in(0).adr                        <= wb_adr_i;
  cbar_slave_in(0).dat                        <= wb_dat_i;
  cbar_slave_in(0).sel                        <= wb_sel_i;
  cbar_slave_in(0).we                         <= wb_we_i;
  cbar_slave_in(0).cyc                        <= wb_cyc_i;
  cbar_slave_in(0).stb                        <= wb_stb_i;

  wb_dat_o                                    <= cbar_slave_out(0).dat;
  wb_ack_o                                    <= cbar_slave_out(0).ack;
  wb_err_o                                    <= cbar_slave_out(0).err;
  wb_rty_o                                    <= cbar_slave_out(0).rty;
  wb_stall_o                                  <= cbar_slave_out(0).stall;

  -- Slave 0 is the UART
  cmp_uart : xwb_simple_uart
  generic map (
    g_interface_mode                        => PIPELINED,
    g_address_granularity                   => BYTE
  )
  port map (
    clk_sys_i                               => clk_sys_i,
    rst_n_i                                 => rst_n_i,
    slave_i                                 => cbar_master_out(0),
    slave_o                                 => cbar_master_in(0),
    uart_rxd_i                              => uart_rxd_i,
    uart_txd_o                              => uart_txd_o
  );

  -- Slave 1 is the LED driver
  cmp_leds : xwb_gpio_port
  generic map(
    g_interface_mode                        => PIPELINED,
    g_address_granularity                   => BYTE,
    g_num_pins                              => g_num_leds,
    g_with_builtin_tristates                => false
  )
  port map(
    clk_sys_i                               => clk_sys_i,
    rst_n_i                                 => rst_n_i,

    -- Wishbone
    slave_i                                 => cbar_master_out(1),
    slave_o                                 => cbar_master_in(1),
    desc_o                                  => open,    -- Not implemented

    --gpio_b : inout std_logic_vector(g_num_pins-1 downto 0);

    gpio_out_o                              => led_gpio_out_int,
    gpio_in_i                               => led_in_i,
    gpio_oen_o                              => led_oen_o
  );

  gen_leds_heartbeat : for i in g_num_leds-1 downto 0 generate

      gen_with_heartbeat : if g_with_led_heartbeat(i) generate
        -- Heartbeat module controls the Blue LED
        cmp_blue_led : heartbeat
        port map
        (
          clk_i                                   => clk_sys_i,
          rst_n_i                                 => rst_n_i,

          heartbeat_o                             => led_heartbeat_out_int(i)
        );
      end generate;

      gen_without_heartbeat : if not g_with_led_heartbeat(i) generate
        led_heartbeat_out_int(i) <= '0';
      end generate;

  end generate;

  gen_leds_outputs : for i in g_num_leds-1 downto 0 generate
    led_out_o(i) <= led_gpio_out_int(i) or led_heartbeat_out_int(i);
  end generate;

  -- Slave 2 is the Button driver
  cmp_buttons : xwb_gpio_port
  generic map(
    g_interface_mode                        => PIPELINED,
    g_address_granularity                   => BYTE,
    g_num_pins                              => g_num_buttons,
    g_with_builtin_tristates                => false
  )
  port map(
    clk_sys_i                               => clk_sys_i,
    rst_n_i                                 => rst_n_i,

    -- Wishbone
    slave_i                                 => cbar_master_out(2),
    slave_o                                 => cbar_master_in(2),
    desc_o                                  => open,    -- Not implemented

    --gpio_b : inout std_logic_vector(g_num_pins-1 downto 0);

    gpio_out_o                              => button_out_o,
    gpio_in_i                               => button_in_i,
    gpio_oen_o                              => button_oen_o
  );

  -- Slave 3 is the TICs counter
  cmp_xwb_tics : xwb_tics
  generic map(
    g_interface_mode                        => PIPELINED,
    g_address_granularity                   => WORD,
    --g_interface_mode                        => g_interface_mode,
    --g_address_granularity                   => g_address_granularity,
    g_period                                => g_cntr_period
  )
  port map(
    clk_sys_i                               => clk_sys_i,
    rst_n_i                                 => rst_n_i,

    -- Wishbone
    slave_i                                 => cbar_master_out(3),
    slave_o                                 => cbar_master_in(3)
  );

end rtl;
