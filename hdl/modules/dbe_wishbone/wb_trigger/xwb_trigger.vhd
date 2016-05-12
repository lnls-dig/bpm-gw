library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- Custom Wishbone Modules
use work.dbe_wishbone_pkg.all;
-- Trigger package
use work.trigger_pkg.all;

entity xwb_trigger is
  generic
    (
      g_interface_mode       : t_wishbone_interface_mode      := CLASSIC;
      g_address_granularity  : t_wishbone_address_granularity := WORD;
      g_sync_edge            : string                         := "positive";
      g_trig_num             : natural range 1 to 24          := 8; -- channels facing outside the FPGA. Limit defined by wb_trigger_regs.vhd
      g_intern_num           : natural range 1 to 24          := 8; -- channels facing inside the FPGA. Limit defined by wb_trigger_regs.vhd
      g_rcv_intern_num       : natural range 1 to 24          := 2; -- signals from inside the FPGA that can be used as input at a rcv mux.
                                                                    -- Limit defined by wb_trigger_regs.vhd
      g_num_mux_interfaces   : natural                        := 2;  -- Number of wb_trigger_mux modules
      g_out_resolver         : string                         := "fanout"; -- Resolver policy for output triggers
      g_in_resolver          : string                         := "or";     -- Resolver policy for input triggers
      g_with_input_sync      : boolean                        := true;
      g_with_output_sync     : boolean                        := true
    );
  port
    (
      clk_i   : in std_logic;
      rst_n_i : in std_logic;

      ref_clk_i   : in std_logic;
      ref_rst_n_i : in std_logic;

      fs_clk_array_i    : in std_logic_vector(g_num_mux_interfaces-1 downto 0);
      fs_rst_n_array_i  : in std_logic_vector(g_num_mux_interfaces-1 downto 0);

      -----------------------------
      -- Wishbone signals
      -----------------------------

      wb_slv_trigger_iface_i : in  t_wishbone_slave_in;
      wb_slv_trigger_iface_o : out t_wishbone_slave_out;

      wb_slv_trigger_mux_i : in  t_wishbone_slave_in_array(g_num_mux_interfaces-1 downto 0);
      wb_slv_trigger_mux_o : out t_wishbone_slave_out_array(g_num_mux_interfaces-1 downto 0);

      -----------------------------
      -- External ports
      -----------------------------

      trig_b      : inout std_logic_vector(g_trig_num-1 downto 0);
      trig_dir_o  : out   std_logic_vector(g_trig_num-1 downto 0);

      -----------------------------
      -- Internal ports
      -----------------------------

      trig_rcv_intern_i   : in  t_trig_channel_array2d(g_num_mux_interfaces-1 downto 0, g_rcv_intern_num-1 downto 0);  -- signals from inside the FPGA that can be used as input at a rcv mux

      trig_pulse_transm_i : in  t_trig_channel_array2d(g_num_mux_interfaces-1 downto 0, g_intern_num-1 downto 0);
      trig_pulse_rcv_o    : out t_trig_channel_array2d(g_num_mux_interfaces-1 downto 0, g_intern_num-1 downto 0)
    );

end xwb_trigger;

architecture rtl of xwb_trigger is

  -- Trigger 2d <-> 1d conversion
  signal trig_rcv_intern_compat : t_trig_channel_array(g_num_mux_interfaces*g_rcv_intern_num-1 downto 0);

  -- Trigger 2d <-> 1d conversion
  signal trig_pulse_transm_compat : t_trig_channel_array(g_num_mux_interfaces*g_intern_num-1 downto 0);
  signal trig_pulse_rcv_compat    : t_trig_channel_array(g_num_mux_interfaces*g_intern_num-1 downto 0);

  signal wb_slv_trigger_mux_adr_in_int    : std_logic_vector(g_num_mux_interfaces*c_wishbone_address_width-1 downto 0);
  signal wb_slv_trigger_mux_dat_in_int    : std_logic_vector(g_num_mux_interfaces*c_wishbone_data_width-1 downto 0);
  signal wb_slv_trigger_mux_dat_out_int   : std_logic_vector(g_num_mux_interfaces*c_wishbone_data_width-1 downto 0);
  signal wb_slv_trigger_mux_sel_in_int    : std_logic_vector(g_num_mux_interfaces*c_wishbone_data_width/8-1 downto 0);
  signal wb_slv_trigger_mux_we_in_int     : std_logic_vector(g_num_mux_interfaces-1 downto 0);
  signal wb_slv_trigger_mux_cyc_in_int    : std_logic_vector(g_num_mux_interfaces-1 downto 0);
  signal wb_slv_trigger_mux_stb_in_int    : std_logic_vector(g_num_mux_interfaces-1 downto 0);
  signal wb_slv_trigger_mux_ack_out_int   : std_logic_vector(g_num_mux_interfaces-1 downto 0);
  signal wb_slv_trigger_mux_err_out_int   : std_logic_vector(g_num_mux_interfaces-1 downto 0);
  signal wb_slv_trigger_mux_rty_out_int   : std_logic_vector(g_num_mux_interfaces-1 downto 0);
  signal wb_slv_trigger_mux_stall_out_int : std_logic_vector(g_num_mux_interfaces-1 downto 0);

begin

  cmp_wb_trigger : wb_trigger
    generic map (
      g_interface_mode       => g_interface_mode,
      g_address_granularity  => g_address_granularity,
      g_sync_edge            => g_sync_edge,
      g_trig_num             => g_trig_num,
      g_intern_num           => g_intern_num,
      g_rcv_intern_num       => g_rcv_intern_num,
      g_num_mux_interfaces   => g_num_mux_interfaces,
      g_out_resolver         => g_out_resolver,
      g_in_resolver          => g_in_resolver,
      g_with_input_sync      => g_with_input_sync,
      g_with_output_sync     => g_with_output_sync
    )
    port map (
      clk_i             => clk_i,
      rst_n_i           => rst_n_i,

      ref_clk_i         => ref_clk_i,
      ref_rst_n_i       => ref_rst_n_i,

      fs_clk_array_i    => fs_clk_array_i,
      fs_rst_n_array_i  => fs_rst_n_array_i,

      wb_trigger_iface_adr_i   => wb_slv_trigger_iface_i.adr,
      wb_trigger_iface_dat_i   => wb_slv_trigger_iface_i.dat,
      wb_trigger_iface_dat_o   => wb_slv_trigger_iface_o.dat,
      wb_trigger_iface_sel_i   => wb_slv_trigger_iface_i.sel,
      wb_trigger_iface_we_i    => wb_slv_trigger_iface_i.we,
      wb_trigger_iface_cyc_i   => wb_slv_trigger_iface_i.cyc,
      wb_trigger_iface_stb_i   => wb_slv_trigger_iface_i.stb,
      wb_trigger_iface_ack_o   => wb_slv_trigger_iface_o.ack,
      wb_trigger_iface_err_o   => wb_slv_trigger_iface_o.err,
      wb_trigger_iface_rty_o   => wb_slv_trigger_iface_o.rty,
      wb_trigger_iface_stall_o => wb_slv_trigger_iface_o.stall,

      wb_trigger_mux_adr_i   => wb_slv_trigger_mux_adr_in_int,
      wb_trigger_mux_dat_i   => wb_slv_trigger_mux_dat_in_int,
      wb_trigger_mux_dat_o   => wb_slv_trigger_mux_dat_out_int,
      wb_trigger_mux_sel_i   => wb_slv_trigger_mux_sel_in_int,
      wb_trigger_mux_we_i    => wb_slv_trigger_mux_we_in_int,
      wb_trigger_mux_cyc_i   => wb_slv_trigger_mux_cyc_in_int,
      wb_trigger_mux_stb_i   => wb_slv_trigger_mux_stb_in_int,
      wb_trigger_mux_ack_o   => wb_slv_trigger_mux_ack_out_int,
      wb_trigger_mux_err_o   => wb_slv_trigger_mux_err_out_int,
      wb_trigger_mux_rty_o   => wb_slv_trigger_mux_rty_out_int,
      wb_trigger_mux_stall_o => wb_slv_trigger_mux_stall_out_int,

      trig_b       => trig_b,
      trig_dir_o   => trig_dir_o,

      trig_rcv_intern_i   => trig_rcv_intern_compat,
      trig_pulse_transm_i => trig_pulse_transm_compat,
      trig_pulse_rcv_o    => trig_pulse_rcv_compat
    );

  gen_wb_slv_trigger_interfaces : for i in 0 to g_num_mux_interfaces-1 generate

    wb_slv_trigger_mux_adr_in_int((i+1)*c_wishbone_address_width-1 downto i*c_wishbone_address_width) <= wb_slv_trigger_mux_i(i).adr;
    wb_slv_trigger_mux_sel_in_int((i+1)*c_wishbone_data_width/8-1 downto i*c_wishbone_data_width/8)   <= wb_slv_trigger_mux_i(i).sel;
    wb_slv_trigger_mux_dat_in_int((i+1)*c_wishbone_data_width-1 downto i*c_wishbone_data_width)       <= wb_slv_trigger_mux_i(i).dat;
    wb_slv_trigger_mux_cyc_in_int(i)                                                                  <= wb_slv_trigger_mux_i(i).cyc;
    wb_slv_trigger_mux_stb_in_int(i)                                                                  <= wb_slv_trigger_mux_i(i).stb;
    wb_slv_trigger_mux_we_in_int(i)                                                                   <= wb_slv_trigger_mux_i(i).we;

    wb_slv_trigger_mux_o(i).dat                       <= wb_slv_trigger_mux_dat_out_int((i+1)*c_wishbone_data_width-1 downto i*c_wishbone_data_width);
    wb_slv_trigger_mux_o(i).ack                       <= wb_slv_trigger_mux_ack_out_int(i);
    wb_slv_trigger_mux_o(i).stall                     <= wb_slv_trigger_mux_stall_out_int(i);
    wb_slv_trigger_mux_o(i).err                       <= wb_slv_trigger_mux_err_out_int(i);
    wb_slv_trigger_mux_o(i).rty                       <= wb_slv_trigger_mux_rty_out_int(i);

  end generate;

  -- Convert 1d <-> 2d vectors
  gen_compat_interfaces : for i in 0 to g_num_mux_interfaces-1 generate

    gen_rcv_intern_compat_trigger_channels : for j in 0 to g_rcv_intern_num-1 generate
      trig_rcv_intern_compat(i*g_rcv_intern_num + j) <= trig_rcv_intern_i(i, j);
    end generate;

    gen_compat_trigger_channels : for j in 0 to g_intern_num-1 generate
      trig_pulse_transm_compat(i*g_intern_num + j) <= trig_pulse_transm_i(i, j);
      trig_pulse_rcv_o(i, j) <= trig_pulse_rcv_compat(i*g_intern_num + j);
    end generate;

  end generate;

end rtl;
