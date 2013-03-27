-- Based on wb_fabric_pkg.vhd from Tomasz Wlostowski
-- Modified by Lucas Russo <lucas.russo@lnls.br>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Multiple size definitions as Xilinx tools does not support
-- VHDL 2008
package wb_stream_generic_pkg is

  -- Must be at least 2 bits wide
  constant c_wbs_adr4_width             : natural := 4;
  constant c_wbs_adr8_width             : natural := 8;
  constant c_wbs_adr16_width            : natural := 16;

  -- Must be at least 16 bits wide.
  constant c_wbs_dat16_width            : natural := 16;
  constant c_wbs_dat32_width            : natural := 32;
  constant c_wbs_dat64_width            : natural := 64;
  constant c_wbs_dat128_width           : natural := 128;

  constant c_wbs_sel16_width            : natural := c_wbs_dat16_width/8;
  constant c_wbs_sel32_width            : natural := c_wbs_dat32_width/8;
  constant c_wbs_sel64_width            : natural := c_wbs_dat64_width/8;
  constant c_wbs_sel128_width           : natural := c_wbs_dat128_width/8;

  constant c_wbs_status_width           : natural := 8;

  type t_wbs_interface_width is (NARROW2, NARROW1, LARGE1, LARGE2);

  subtype t_wbs_adr4 is
    std_logic_vector(c_wbs_adr4_width-1 downto 0);
  subtype t_wbs_adr8 is
    std_logic_vector(c_wbs_adr8_width-1 downto 0);
  subtype t_wbs_adr16 is
    std_logic_vector(c_wbs_adr16_width-1 downto 0);

  subtype t_wbs_dat16 is
    std_logic_vector(c_wbs_dat16_width-1 downto 0);
  subtype t_wbs_dat32 is
    std_logic_vector(c_wbs_dat32_width-1 downto 0);
  subtype t_wbs_dat64 is
    std_logic_vector(c_wbs_dat64_width-1 downto 0);
  subtype t_wbs_dat128 is
    std_logic_vector(c_wbs_dat128_width-1 downto 0);

  subtype t_wbs_sel16 is
    std_logic_vector((c_wbs_dat16_width/8)-1 downto 0);
  subtype t_wbs_sel32 is
    std_logic_vector((c_wbs_dat32_width/8)-1 downto 0);
  subtype t_wbs_sel64 is
    std_logic_vector((c_wbs_dat64_width/8)-1 downto 0);
  subtype t_wbs_sel128 is
    std_logic_vector((c_wbs_dat128_width/8)-1 downto 0);

  constant c_WBS_DATA   : unsigned := to_unsigned(0, 32);
  constant c_WBS_OOB    : unsigned := to_unsigned(1, 32);
  constant c_WBS_STATUS : unsigned := to_unsigned(2, 32);
  constant c_WBS_USER   : unsigned := to_unsigned(3, 32);

  --constant c_WRF_OOB_TYPE_RX : std_logic_vector(3 downto 0) := "0000";
  --constant c_WRF_OOB_TYPE_TX : std_logic_vector(3 downto 0) := "0001";

  type t_wbs_status_reg is record
    error         : std_logic;
    reserved      : std_logic_vector(6 downto 0);
  end record;

  --type t_wbs_source_out is record
  --  adr : std_logic_vector;
  --  dat : std_logic_vector;
  --  cyc : std_logic;
  --  stb : std_logic;
  --  we  : std_logic;
  --  sel : std_logic_vector;
  --end record;

  type t_wbs_source_out16 is record
    adr : t_wbs_adr4;
    dat : t_wbs_dat16;
    cyc : std_logic;
    stb : std_logic;
    we  : std_logic;
    sel : t_wbs_sel16;
  end record;

  type t_wbs_source_out32 is record
    adr : t_wbs_adr4;
    dat : t_wbs_dat32;
    cyc : std_logic;
    stb : std_logic;
    we  : std_logic;
    sel : t_wbs_sel32;
  end record;

  type t_wbs_source_out64 is record
    adr : t_wbs_adr4;
    dat : t_wbs_dat64;
    cyc : std_logic;
    stb : std_logic;
    we  : std_logic;
    sel : t_wbs_sel64;
  end record;

  type t_wbs_source_out128 is record
    adr : t_wbs_adr4;
    dat : t_wbs_dat128;
    cyc : std_logic;
    stb : std_logic;
    we  : std_logic;
    sel : t_wbs_sel128;
  end record;

  subtype t_wbs_sink_in16 is t_wbs_source_out16;
  subtype t_wbs_sink_in32 is t_wbs_source_out32;
  subtype t_wbs_sink_in64 is t_wbs_source_out64;
  subtype t_wbs_sink_in128 is t_wbs_source_out128;

  type t_wbs_source_com_in is record
    ack   : std_logic;
    stall : std_logic;
    err   : std_logic;
    rty   : std_logic;
  end record;

  -- Convinient type names for consistency
  subtype t_wbs_source_in16 is t_wbs_source_com_in;
  subtype t_wbs_source_in32 is t_wbs_source_com_in;
  subtype t_wbs_source_in64 is t_wbs_source_com_in;
  subtype t_wbs_source_in128 is t_wbs_source_com_in;

  subtype t_wbs_sink_out16 is t_wbs_source_com_in;
  subtype t_wbs_sink_out32 is t_wbs_source_com_in;
  subtype t_wbs_sink_out64 is t_wbs_source_com_in;
  subtype t_wbs_sink_out128 is t_wbs_source_com_in;

  --type t_wrf_oob is record
  --  valid: std_logic;
  --  oob_type : std_logic_vector(3 downto 0);
  --  ts_r     : std_logic_vector(27 downto 0);
  --  ts_f     : std_logic_vector(3 downto 0);
  --  frame_id : std_logic_vector(15 downto 0);
  --  port_id  : std_logic_vector(5 downto 0);
  --end record;

  type t_wbs_source_in_array is array (natural range <>) of t_wbs_source_com_in;
  type t_wbs_source_out16_array is array (natural range <>) of t_wbs_source_out16;
  type t_wbs_source_out32_array is array (natural range <>) of t_wbs_source_out32;
  type t_wbs_source_out64_array is array (natural range <>) of t_wbs_source_out64;
  type t_wbs_source_out128_array is array (natural range <>) of t_wbs_source_out128;

  type t_wbs_source_in16_array is array (natural range <>) of t_wbs_source_in16;
  type t_wbs_source_in32_array is array (natural range <>) of t_wbs_source_in32;
  type t_wbs_source_in64_array is array (natural range <>) of t_wbs_source_in64;
  type t_wbs_source_in128_array is array (natural range <>) of t_wbs_source_in128;

  subtype t_wbs_sink_out_array is t_wbs_source_in_array;
  subtype t_wbs_sink_in16_array is t_wbs_source_out16_array;
  subtype t_wbs_sink_in32_array is t_wbs_source_out32_array;
  subtype t_wbs_sink_in64_array is t_wbs_source_out64_array;
  subtype t_wbs_sink_in128_array is t_wbs_source_out128_array;

  subtype t_wbs_sink_out16_array is t_wbs_source_in16_array;
  subtype t_wbs_sink_out32_array is t_wbs_source_in32_array;
  subtype t_wbs_sink_out64_array is t_wbs_source_in64_array;
  subtype t_wbs_sink_out128_array is t_wbs_source_in128_array;

  function f_marshall_wbs_status (stat  : t_wbs_status_reg) return std_logic_vector;
  function f_unmarshall_wbs_status(stat : std_logic_vector) return t_wbs_status_reg;

  function f_packet_num_bits(packet_size : natural) return natural;
  function f_conv_wbs_interface_width(wbs_interface_width : t_wbs_interface_width)
    return natural;

  constant cc_dummy_wbs_adr4 : std_logic_vector(c_wbs_adr4_width-1 downto 0) := (others => 'X');
  constant cc_dummy_wbs_dat16 : std_logic_vector(c_wbs_dat16_width-1 downto 0) := (others => 'X');
  constant cc_dummy_wbs_dat32 : std_logic_vector(c_wbs_dat32_width-1 downto 0) := (others => 'X');
  constant cc_dummy_wbs_dat64 : std_logic_vector(c_wbs_dat64_width-1 downto 0) := (others => 'X');
  constant cc_dummy_wbs_dat128 : std_logic_vector(c_wbs_dat128_width-1 downto 0) := (others => 'X');
  constant cc_dummy_wbs_sel16 : std_logic_vector(c_wbs_sel16_width-1 downto 0) := (others => 'X');
  constant cc_dummy_wbs_sel32 : std_logic_vector(c_wbs_sel32_width-1 downto 0) := (others => 'X');
  constant cc_dummy_wbs_sel64 : std_logic_vector(c_wbs_sel64_width-1 downto 0) := (others => 'X');
  constant cc_dummy_wbs_sel128 : std_logic_vector(c_wbs_sel128_width-1 downto 0) := (others => 'X');

  constant cc_dummy_src_com_in : t_wbs_source_com_in := ('1', '0', '0', '0');
  constant cc_dummy_snk_in16 : t_wbs_sink_in16 :=
      (cc_dummy_wbs_adr4, cc_dummy_wbs_dat16, '0', '0', '0', cc_dummy_wbs_sel16);
  constant cc_dummy_snk_in32 : t_wbs_sink_in32 :=
      (cc_dummy_wbs_adr4, cc_dummy_wbs_dat32, '0', '0', '0', cc_dummy_wbs_sel32);
  constant cc_dummy_snk_in64 : t_wbs_sink_in64 :=
      (cc_dummy_wbs_adr4, cc_dummy_wbs_dat64, '0', '0', '0', cc_dummy_wbs_sel64);
  constant cc_dummy_snk_in128 : t_wbs_sink_in128 :=
      (cc_dummy_wbs_adr4, cc_dummy_wbs_dat128, '0', '0', '0', cc_dummy_wbs_sel128);

  -- Convinient type names for consistency
  alias cc_dummy_src_in16 is cc_dummy_src_com_in;
  alias cc_dummy_src_in32 is cc_dummy_src_com_in;
  alias cc_dummy_src_in64 is cc_dummy_src_com_in;
  alias cc_dummy_src_in128 is cc_dummy_src_com_in;

  -----------------------------
  -- Components
  -----------------------------
  -- 16 (narrow2)/32 (narrow1)/64 (large1)/128 (large2) bit Wishbone Streaming Interfaces
  component wb_stream_source_gen
  generic (
    --g_wbs_adr_width                         : natural := c_wbs_adr4_width;
    g_wbs_interface_width                     : t_wbs_interface_width := LARGE1
  );
  port (
    clk_i                                     : in std_logic;
    rst_n_i                                   : in std_logic;

    -- Wishbone Streaming Interface I/O.
    -- Only the used interface should be connected. The others can be left unconnected
    -- 16-bit interface
    src_adr16_o                               : out t_wbs_adr4;
    src_dat16_o                               : out t_wbs_dat16;
    src_sel16_o                               : out t_wbs_sel16;

    -- 32-bit interface
    src_adr32_o                               : out t_wbs_adr4;
    src_dat32_o                               : out t_wbs_dat32;
    src_sel32_o                               : out t_wbs_sel32;

    -- 64-bit interface
    src_adr64_o                               : out t_wbs_adr4;
    src_dat64_o                               : out t_wbs_dat64;
    src_sel64_o                               : out t_wbs_sel64;

    -- 128-bit interface
    src_adr128_o                              : out t_wbs_adr4;
    src_dat128_o                              : out t_wbs_dat128;
    src_sel128_o                              : out t_wbs_sel128;

    -- Common Wishbone Streaming lines
    src_cyc_o                                 : out std_logic;
    src_stb_o                                 : out std_logic;
    src_we_o                                  : out std_logic;
    src_ack_i                                 : in std_logic := '0';
    src_stall_i                               : in std_logic := '0';
    src_err_i                                 : in std_logic := '0';
    src_rty_i                                 : in std_logic := '0';

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
  end component;

  -- 16 (narrow2)/32 (narrow1)/64 (large1)/128 (large2) bit Wishbone Streaming Interfaces
  component xwb_stream_source_gen
  generic (
    --g_wbs_adr_width                         : natural := c_wbs_adr4_width;
    g_wbs_interface_width                   : t_wbs_interface_width := LARGE1
  );
  port (
    clk_i                                   : in std_logic;
    rst_n_i                                 : in std_logic;

    -- Wishbone Fabric Interface I/O.
    -- Only the used interface must be connected. The others can be left unconnected
    -- 16-bit interface
    src16_i                                 : in  t_wbs_source_in16 := cc_dummy_src_in16;
    src16_o                                 : out t_wbs_source_out16;
    -- 32-bit interface
    src32_i                                 : in  t_wbs_source_in32 := cc_dummy_src_in32;
    src32_o                                 : out t_wbs_source_out32;
    -- 64-bit interface
    src64_i                                 : in  t_wbs_source_in64 := cc_dummy_src_in64;
    src64_o                                 : out t_wbs_source_out64;
    -- 128-bit interface
    src128_i                                : in  t_wbs_source_in128 := cc_dummy_src_in128;
    src128_o                                : out t_wbs_source_out128;

    -- Decoded & buffered logic
    -- Only the used interface must be connected. The others can be left unconnected
    -- 16-bit interface
    adr16_i                                 : in  std_logic_vector(c_wbs_adr4_width-1 downto 0) := (others => '0');
    dat16_i                                 : in  std_logic_vector(c_wbs_dat16_width-1 downto 0) := (others => '0');
    sel16_i                                 : in  std_logic_vector(c_wbs_sel16_width-1 downto 0) := (others => '0');
    -- 32-bit interface
    adr32_i                                 : in  std_logic_vector(c_wbs_adr4_width-1 downto 0) := (others => '0');
    dat32_i                                 : in  std_logic_vector(c_wbs_dat32_width-1 downto 0) := (others => '0');
    sel32_i                                 : in  std_logic_vector(c_wbs_sel32_width-1 downto 0) := (others => '0');
    -- 64-bit interface
    adr64_i                                 : in  std_logic_vector(c_wbs_adr4_width-1 downto 0) := (others => '0');
    dat64_i                                 : in  std_logic_vector(c_wbs_dat64_width-1 downto 0) := (others => '0');
    sel64_i                                 : in  std_logic_vector(c_wbs_sel64_width-1 downto 0) := (others => '0');
    -- 128-bit interface
    adr128_i                                : in  std_logic_vector(c_wbs_adr4_width-1 downto 0) := (others => '0');
    dat128_i                                : in  std_logic_vector(c_wbs_dat128_width-1 downto 0) := (others => '0');
    sel128_i                                : in  std_logic_vector(c_wbs_sel128_width-1 downto 0) := (others => '0');

    -- Common lines
    dvalid_i                                : in  std_logic := '0';
    sof_i                                   : in  std_logic := '0';
    eof_i                                   : in  std_logic := '0';
    error_i                                 : in  std_logic := '0';
    dreq_o                                  : out std_logic
  );
  end component;

  component wb_stream_sink_gen
  generic (
    --g_wbs_adr_width                         : natural := c_wbs_adr4_width;
    g_wbs_interface_width                     : t_wbs_interface_width := LARGE1
  );
  port (
    clk_i                                     : in std_logic;
    rst_n_i                                   : in std_logic;

    -- Wishbone Streaming Interface I/O.
    -- Only the used interface should be connected. The others can be left unconnected
    -- 16-bit interface
    snk_adr16_i                               : in t_wbs_adr4 := cc_dummy_wbs_adr4;
    snk_dat16_i                               : in t_wbs_dat16 := cc_dummy_wbs_dat16;
    snk_sel16_i                               : in t_wbs_sel16 := cc_dummy_wbs_sel16;

    -- 32-bit interface
    snk_adr32_i                               : in t_wbs_adr4 := cc_dummy_wbs_adr4;
    snk_dat32_i                               : in t_wbs_dat32 := cc_dummy_wbs_dat32;
    snk_sel32_i                               : in t_wbs_sel32 := cc_dummy_wbs_sel32;

    -- 64-bit interface
    snk_adr64_i                               : in t_wbs_adr4 := cc_dummy_wbs_adr4;
    snk_dat64_i                               : in t_wbs_dat64 := cc_dummy_wbs_dat64;
    snk_sel64_i                               : in t_wbs_sel64 := cc_dummy_wbs_sel64;

    -- 128-bit interface
    snk_adr128_i                              : in t_wbs_adr4 := cc_dummy_wbs_adr4;
    snk_dat128_i                              : in t_wbs_dat128 := cc_dummy_wbs_dat128;
    snk_sel128_i                              : in t_wbs_sel128 := cc_dummy_wbs_sel128;

    -- Common Wishbone Streaming lines
    snk_cyc_i                                 : in std_logic := '0';
    snk_stb_i                                 : in std_logic := '0';
    snk_we_i                                  : in std_logic := '0';
    snk_ack_o                                 : out std_logic;
    snk_stall_o                               : out std_logic;
    snk_err_o                                 : out std_logic;
    snk_rty_o                                 : out std_logic;

    -- Decoded & buffered logic
    -- Only the used interface must be connected. The others can be left unconnected
    -- 16-bit interface
    adr16_o                                 : out std_logic_vector(c_wbs_adr4_width-1 downto 0);
    dat16_o                                 : out std_logic_vector(c_wbs_dat16_width-1 downto 0);
    sel16_o                                 : out std_logic_vector(c_wbs_sel16_width-1 downto 0);
    -- 32-bit interface
    adr32_o                                 : out std_logic_vector(c_wbs_adr4_width-1 downto 0);
    dat32_o                                 : out std_logic_vector(c_wbs_dat32_width-1 downto 0);
    sel32_o                                 : out std_logic_vector(c_wbs_sel32_width-1 downto 0);
    -- 64-bit interface
    adr64_o                                 : out std_logic_vector(c_wbs_adr4_width-1 downto 0);
    dat64_o                                 : out std_logic_vector(c_wbs_dat64_width-1 downto 0);
    sel64_o                                 : out std_logic_vector(c_wbs_sel64_width-1 downto 0);
    -- 128-bit interface
    adr128_o                                : out std_logic_vector(c_wbs_adr4_width-1 downto 0);
    dat128_o                                : out std_logic_vector(c_wbs_dat128_width-1 downto 0);
    sel128_o                                : out std_logic_vector(c_wbs_sel128_width-1 downto 0);

    -- Common lines
    dvalid_o                                : out std_logic;
    sof_o                                   : out std_logic;
    eof_o                                   : out std_logic;
    error_o                                 : out std_logic;
    dreq_i                                  : in std_logic := '0'
  );
  end component;

  -- 16 (narrow2)/32 (narrow1)/64 (large1)/128 (large2) bit Wishbone Streaming Interfaces
  component xwb_stream_sink_gen
  generic (
    --g_wbs_adr_width                         : natural := c_wbs_adr4_width;
    g_wbs_interface_width                   : t_wbs_interface_width := LARGE1
  );
  port (
    clk_i                                   : in std_logic;
    rst_n_i                                 : in std_logic;

    -- Wishbone Fabric Interface I/O.
    -- Only the used interface must be connected. The others can be left unconnected
    -- 16-bit interface
    snk16_i                                 : in  t_wbs_sink_in16 := cc_dummy_snk_in16;
    snk16_o                                 : out t_wbs_sink_out16;
    -- 32-bit interface
    snk32_i                                 : in  t_wbs_sink_in32 := cc_dummy_snk_in32;
    snk32_o                                 : out t_wbs_sink_out32;
    -- 64-bit interface
    snk64_i                                 : in  t_wbs_sink_in64 := cc_dummy_snk_in64;
    snk64_o                                 : out t_wbs_sink_out64;
    -- 128-bit interface
    snk128_i                                : in  t_wbs_sink_in128 := cc_dummy_snk_in128;
    snk128_o                                : out t_wbs_sink_out128;

    -- Decoded & buffered logic
    -- Only the used interface must be connected. The others can be left unconnected
    -- 16-bit interface
    adr16_o                                 : out std_logic_vector(c_wbs_adr4_width-1 downto 0);
    dat16_o                                 : out std_logic_vector(c_wbs_dat16_width-1 downto 0);
    sel16_o                                 : out std_logic_vector(c_wbs_sel16_width-1 downto 0);
    -- 32-bit interface
    adr32_o                                 : out std_logic_vector(c_wbs_adr4_width-1 downto 0);
    dat32_o                                 : out std_logic_vector(c_wbs_dat32_width-1 downto 0);
    sel32_o                                 : out std_logic_vector(c_wbs_sel32_width-1 downto 0);
    -- 64-bit interface
    adr64_o                                 : out std_logic_vector(c_wbs_adr4_width-1 downto 0);
    dat64_o                                 : out std_logic_vector(c_wbs_dat64_width-1 downto 0);
    sel64_o                                 : out std_logic_vector(c_wbs_sel64_width-1 downto 0);
    -- 128-bit interface
    adr128_o                                : out std_logic_vector(c_wbs_adr4_width-1 downto 0);
    dat128_o                                : out std_logic_vector(c_wbs_dat128_width-1 downto 0);
    sel128_o                                : out std_logic_vector(c_wbs_sel128_width-1 downto 0);

    -- Common lines
    dvalid_o                                : out std_logic;
    sof_o                                   : out std_logic;
    eof_o                                   : out std_logic;
    error_o                                 : out std_logic;
    dreq_i                                  : in std_logic := '0'
  );
  end component;

end wb_stream_generic_pkg;

package body wb_stream_generic_pkg is

  function f_marshall_wbs_status(stat : t_wbs_status_reg)
    return std_logic_vector
  is
    variable tmp : std_logic_vector(c_wbs_status_width-1 downto 0) := (others => '0');
  begin
    tmp(0)           := stat.error;
    return tmp;
  end;

  function f_unmarshall_wbs_status(stat : std_logic_vector)
    return t_wbs_status_reg
  is
    variable tmp : t_wbs_status_reg;
  begin
    tmp.error       := stat(0);
    return tmp;
  end f_unmarshall_wbs_status;

  function f_packet_num_bits(packet_size : natural)
    return natural
  is
    -- Slightly different behaviour than the one located at wishbone_pkg.vhd
    function f_ceil_log2(x : natural) return natural is
    begin
      if x <= 2
      then return 1;
      else return f_ceil_log2((x+1)/2) +1;
      end if;
    end f_ceil_log2;

  begin
    return f_ceil_log2(packet_size);
  end f_packet_num_bits;

  -- Convert t_wbs_dat_width type to natural
  function f_conv_wbs_interface_width(wbs_interface_width : t_wbs_interface_width)
    return natural
  is
    variable size : natural;
  begin
    case (wbs_interface_width) is
      when NARROW2 =>
        size := 16;
      when NARROW1 =>
        size := 32;
      when LARGE1 =>
        size := 64;
      when LARGE2 =>
        size := 128;
      -- Should not happen
      when others =>
        size := 64;
    end case;
    return size;
  end f_conv_wbs_interface_width;

end wb_stream_generic_pkg;
