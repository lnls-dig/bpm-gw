-- Based on xwb_fabric_source.vhd from Tomasz Wlostowski
--
-- Modified by Lucas Russo <lucas.russo@lnls.br> for multiple width support

library ieee;
use ieee.std_logic_1164.all;

use work.genram_pkg.all;
use work.wb_stream_generic_pkg.all;

entity xwb_stream_source_gen is
generic (
  --g_wbs_adr_width                         : natural := c_wbs_adr4_width;
  g_wbs_interface_width                     : t_wbs_interface_width := LARGE1
);
port (
  clk_i                                     : in std_logic;
  rst_n_i                                   : in std_logic;

  -- Wishbone Fabric Interface I/O.
  -- Only the used interface must be connected. The others can be left unconnected
  -- 16-bit interface
  src16_i                                   : in  t_wbs_source_in16 := cc_dummy_src_in16;
  src16_o                                   : out t_wbs_source_out16;
  -- 32-bit interface
  src32_i                                   : in  t_wbs_source_in32 := cc_dummy_src_in32;
  src32_o                                   : out t_wbs_source_out32;
  -- 64-bit interface
  src64_i                                   : in  t_wbs_source_in64 := cc_dummy_src_in64;
  src64_o                                   : out t_wbs_source_out64;
  -- 128-bit interface
  src128_i                                  : in  t_wbs_source_in128 := cc_dummy_src_in128;
  src128_o                                  : out t_wbs_source_out128;

  -- Decoded & buffered logic
  -- Only the used interface must be connected. The others can be left unconnected
  -- 16-bit interface
  adr16_i                                   : in  std_logic_vector(c_wbs_adr4_width-1 downto 0) := (others => '0');
  dat16_i                                   : in  std_logic_vector(c_wbs_dat16_width-1 downto 0) := (others => '0');
  sel16_i                                   : in  std_logic_vector(c_wbs_sel16_width-1 downto 0) := (others => '0');
  -- 32-bit interface
  adr32_i                                   : in  std_logic_vector(c_wbs_adr4_width-1 downto 0) := (others => '0');
  dat32_i                                   : in  std_logic_vector(c_wbs_dat32_width-1 downto 0) := (others => '0');
  sel32_i                                   : in  std_logic_vector(c_wbs_sel32_width-1 downto 0) := (others => '0');
  -- 64-bit interface
  adr64_i                                   : in  std_logic_vector(c_wbs_adr4_width-1 downto 0) := (others => '0');
  dat64_i                                   : in  std_logic_vector(c_wbs_dat64_width-1 downto 0) := (others => '0');
  sel64_i                                   : in  std_logic_vector(c_wbs_sel64_width-1 downto 0) := (others => '0');
  -- 128-bit interface
  adr128_i                                  : in  std_logic_vector(c_wbs_adr4_width-1 downto 0) := (others => '0');
  dat128_i                                  : in  std_logic_vector(c_wbs_dat128_width-1 downto 0) := (others => '0');
  sel128_i                                  : in  std_logic_vector(c_wbs_sel128_width-1 downto 0) := (others => '0');

  -- Common lines
  dvalid_i                                  : in  std_logic := '0';
  sof_i                                     : in  std_logic := '0';
  eof_i                                     : in  std_logic := '0';
  error_i                                   : in  std_logic := '0';
  dreq_o                                    : out std_logic
);
end xwb_stream_source_gen;

architecture rtl of xwb_stream_source_gen is
  signal src_cyc_int                        : std_logic;
  signal src_stb_int                        : std_logic;
  signal src_we_int                         : std_logic;
  signal src_ack_int                        : std_logic;
  signal src_stall_int                      : std_logic;
  signal src_err_int                        : std_logic;
  signal src_rty_int                        : std_logic;

begin
  -----------------------------
  -- Wishbone Streaming Interface selection
  -----------------------------
  gen_16_bit_interface : if g_wbs_interface_width = NARROW2 generate
    src16_o.cyc                             <= src_cyc_int;
    src16_o.stb                             <= src_stb_int;
    src16_o.we                              <= src_we_int;
    src_ack_int                             <= src16_i.ack;
    src_stall_int                           <= src16_i.stall;
    src_err_int                             <= src16_i.err;
    src_rty_int                             <= src16_i.rty;
  end generate;

  gen_32_bit_interface : if g_wbs_interface_width = NARROW1 generate
    src32_o.cyc                             <= src_cyc_int;
    src32_o.stb                             <= src_stb_int;
    src32_o.we                              <= src_we_int;
    src_ack_int                             <= src32_i.ack;
    src_stall_int                           <= src32_i.stall;
    src_err_int                             <= src32_i.err;
    src_rty_int                             <= src32_i.rty;
  end generate;

  gen_64_bit_interface : if g_wbs_interface_width = LARGE1 generate
    src64_o.cyc                             <= src_cyc_int;
    src64_o.stb                             <= src_stb_int;
    src64_o.we                              <= src_we_int;
    src_ack_int                             <= src64_i.ack;
    src_stall_int                           <= src64_i.stall;
    src_err_int                             <= src64_i.err;
    src_rty_int                             <= src64_i.rty;
  end generate;

  gen_128_bit_interface : if g_wbs_interface_width = LARGE2 generate
    src128_o.cyc                            <= src_cyc_int;
    src128_o.stb                            <= src_stb_int;
    src128_o.we                             <= src_we_int;
    src_ack_int                             <= src128_i.ack;
    src_stall_int                           <= src128_i.stall;
    src_err_int                             <= src128_i.err;
    src_rty_int                             <= src128_i.rty;
  end generate;

  cmp_wb_stream_source_gen : wb_stream_source_gen
  generic map (
    --g_wbs_adr_width                         : natural := c_wbs_adr4_width;
    g_wbs_interface_width                     => g_wbs_interface_width
  )
  port map (
    clk_i                                     => clk_i,
    rst_n_i                                   => rst_n_i,

    -- Wishbone Streaming Interface I/O.
    -- Only the used interface should be connected. The others can be left unconnected
    -- 16-bit interface
    src_adr16_o                               => src16_o.adr,
    src_dat16_o                               => src16_o.dat,
    src_sel16_o                               => src16_o.sel,

    -- 32-bit interface
    src_adr32_o                               => src32_o.adr,
    src_dat32_o                               => src32_o.dat,
    src_sel32_o                               => src32_o.sel,

    -- 64-bit interface
    src_adr64_o                               => src64_o.adr,
    src_dat64_o                               => src64_o.dat,
    src_sel64_o                               => src64_o.sel,

    -- 128-bit interface
    src_adr128_o                              => src128_o.adr,
    src_dat128_o                              => src128_o.dat,
    src_sel128_o                              => src128_o.sel,

    -- Common Wishbone Streaming lines
    src_cyc_o                                 => src_cyc_int,
    src_stb_o                                 => src_stb_int,
    src_we_o                                  => src_we_int,
    src_ack_i                                 => src_ack_int,
    src_stall_i                               => src_stall_int,
    src_err_i                                 => src_err_int,
    src_rty_i                                 => src_rty_int,

    -- Decoded & buffered logic
    -- Only the used interface must be connected. The others can be left unconnected
    -- 16-bit interface
    adr16_i                                   => adr16_i,
    dat16_i                                   => dat16_i,
    sel16_i                                   => sel16_i,

    -- 32-bit interface
    adr32_i                                   => adr32_i,
    dat32_i                                   => dat32_i,
    sel32_i                                   => sel32_i,

    -- 64-bit interface
    adr64_i                                   => adr64_i,
    dat64_i                                   => dat64_i,
    sel64_i                                   => sel64_i,

    -- 128-bit interface
    adr128_i                                  => adr128_i,
    dat128_i                                  => dat128_i,
    sel128_i                                  => sel128_i,

    -- Common lines
    dvalid_i                                  => dvalid_i,
    sof_i                                     => sof_i,
    eof_i                                     => eof_i,
    error_i                                   => error_i,
    dreq_o                                    => dreq_o
  );
end rtl;
