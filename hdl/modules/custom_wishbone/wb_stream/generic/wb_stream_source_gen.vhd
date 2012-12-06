-- Based on xwb_fabric_source.vhd from Tomasz Wlostowski
--
-- Modified by Lucas Russo <lucas.russo@lnls.br> for multiple width support

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.genram_pkg.all;
use work.wb_stream_generic_pkg.all;

entity wb_stream_source_gen is
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
  adr16_i                                   : in  std_logic_vector(c_wbs_adr4_width-1 downto 0) := cc_dummy_wbs_adr4;
  dat16_i                                   : in  std_logic_vector(c_wbs_dat16_width-1 downto 0) := cc_dummy_wbs_dat16;
  sel16_i                                   : in  std_logic_vector(c_wbs_sel16_width-1 downto 0) := cc_dummy_wbs_sel16;

  -- 32-bit interface
  adr32_i                                   : in  std_logic_vector(c_wbs_adr4_width-1 downto 0) := cc_dummy_wbs_adr4;
  dat32_i                                   : in  std_logic_vector(c_wbs_dat32_width-1 downto 0) := cc_dummy_wbs_dat32;
  sel32_i                                   : in  std_logic_vector(c_wbs_sel32_width-1 downto 0) := cc_dummy_wbs_sel32;

  -- 64-bit interface
  adr64_i                                   : in  std_logic_vector(c_wbs_adr4_width-1 downto 0) := cc_dummy_wbs_adr4;
  dat64_i                                   : in  std_logic_vector(c_wbs_dat64_width-1 downto 0) := cc_dummy_wbs_dat64;
  sel64_i                                   : in  std_logic_vector(c_wbs_sel64_width-1 downto 0) := cc_dummy_wbs_sel64;

  -- 128-bit interface
  adr128_i                                  : in  std_logic_vector(c_wbs_adr4_width-1 downto 0) := cc_dummy_wbs_adr4;
  dat128_i                                  : in  std_logic_vector(c_wbs_dat128_width-1 downto 0) := cc_dummy_wbs_dat128;
  sel128_i                                  : in  std_logic_vector(c_wbs_sel128_width-1 downto 0) := cc_dummy_wbs_sel128;

  -- Common lines
  dvalid_i                                  : in  std_logic := '0';
  sof_i                                     : in  std_logic := '0';
  eof_i                                     : in  std_logic := '0';
  error_i                                   : in  std_logic := '0';
  dreq_o                                    : out std_logic
);
end wb_stream_source_gen;

architecture rtl of wb_stream_source_gen is

  -- Convert enum to natural
  constant c_wbs_dat_width : natural := f_conv_wbs_interface_width(g_wbs_interface_width);
  constant c_wbs_sel_width : natural := c_wbs_dat_width/8;
  -- Fixed 4-bit address as we do not exceptct it to address real peripheral
  -- just to inform some other conditions
  constant c_wbs_adr_width : natural := c_wbs_adr4_width;

  -- FIFO ranges and control bits location
  constant c_dat_lsb                        : natural := 0;
  constant c_dat_msb                        : natural := c_dat_lsb + c_wbs_dat_width - 1;

  constant c_adr_lsb                        : natural := c_dat_msb + 1;
  constant c_adr_msb                        : natural := c_adr_lsb + c_wbs_adr_width - 1;

  constant c_valid_bit                      : natural := c_adr_msb + 1;

  constant c_sel_lsb                        : natural := c_valid_bit + 1;
  constant c_sel_msb                        : natural := c_sel_lsb + c_wbs_sel_width - 1;

  constant c_eof_bit                        : natural := c_sel_msb + 1;
  constant c_sof_bit                        : natural := c_eof_bit + 1;

  constant c_logic_width                    : integer := c_sof_bit - c_valid_bit + 1;
  constant c_fifo_width                     : integer := c_sof_bit - c_dat_lsb + 1;
  constant c_fifo_depth                     : integer := 32;

  -- Signals
  signal q_valid, full, we, rd, rd_d0       : std_logic;
  signal fin, fout                          : std_logic_vector(c_fifo_width-1 downto 0);

  signal pre_dvalid, pre_sof                : std_logic;
  signal pre_eof                            : std_logic;
  signal pre_dat                            : std_logic_vector(c_wbs_dat_width-1 downto 0);
  signal pre_adr                            : std_logic_vector(c_wbs_adr_width-1 downto 0);
  signal pre_sel                            : std_logic_vector(c_wbs_sel_width-1 downto 0);

  signal post_dvalid, post_sof              : std_logic;
  signal post_eof                           : std_logic;
  signal post_sel                           : std_logic_vector(c_wbs_sel_width-1 downto 0);
  signal post_dat                           : std_logic_vector(c_wbs_dat_width-1 downto 0);
  signal post_adr                           : std_logic_vector(c_wbs_adr_width-1 downto 0);

  signal err_status                         : t_wbs_status_reg;
  signal cyc_int                            : std_logic;

  function f_gen_zeros(size : natural)
    return std_logic_vector is
    variable zeros : std_logic_vector(size-1 downto 0) := (others => '0');
  begin
    return zeros;
  end f_gen_zeros;

begin  -- rtl

  err_status.error <= '1';

  dreq_o <= not full;

  rd <= not src_stall_i;
  we <= sof_i or eof_i or error_i or dvalid_i;

  pre_dvalid <= dvalid_i or error_i;
  pre_eof    <= error_i or eof_i;

  -----------------------------
  -- Wishbone Streaming Interface selection
  -----------------------------
  gen_16_bit_interface_in : if g_wbs_interface_width = NARROW2 generate
    pre_dat <= dat16_i when (error_i = '0') else f_gen_zeros(pre_dat'length-c_wbs_status_width) &
                                                    f_marshall_wbs_status(err_status);
    pre_adr <= adr16_i when (error_i = '0') else std_logic_vector(resize(c_WBS_STATUS, pre_adr'length));
    pre_sel <= sel16_i;
  end generate;

  gen_32_bit_interface_in : if g_wbs_interface_width = NARROW1 generate
    pre_dat <= dat32_i when (error_i = '0') else f_gen_zeros(pre_dat'length-c_wbs_status_width) &
                                                    f_marshall_wbs_status(err_status);
    pre_adr <= adr32_i when (error_i = '0') else std_logic_vector(resize(c_WBS_STATUS, pre_adr'length));
    pre_sel <= sel32_i;
  end generate;

  gen_64_bit_interface_in : if g_wbs_interface_width = LARGE1 generate
    pre_dat <= dat64_i when (error_i = '0') else f_gen_zeros(pre_dat'length-c_wbs_status_width) &
                                                    f_marshall_wbs_status(err_status);
    pre_adr <= adr64_i when (error_i = '0') else std_logic_vector(resize(c_WBS_STATUS, pre_adr'length));
    pre_sel <= sel64_i;
  end generate;

  gen_128_bit_interface_in : if g_wbs_interface_width = LARGE2 generate
    pre_dat <= dat128_i when (error_i = '0') else f_gen_zeros(pre_dat'length-c_wbs_status_width) &
                                                    f_marshall_wbs_status(err_status);
    pre_adr <= adr128_i when (error_i = '0') else std_logic_vector(resize(c_WBS_STATUS, pre_adr'length));
    pre_sel <= sel128_i;
  end generate;

  fin <= sof_i & pre_eof & pre_sel & pre_dvalid & pre_adr & pre_dat;

  cmp_fifo : generic_shiftreg_fifo
    generic map (
      g_data_width => c_fifo_width,
      g_size       => c_fifo_depth
    )
    port map (
      rst_n_i       => rst_n_i,
      clk_i         => clk_i,
      d_i           => fin,
      we_i          => we,
      q_o           => fout,
      rd_i          => rd,
      almost_full_o => full,
      q_valid_o     => q_valid
    );

  post_sof <= fout(c_sof_bit);
  post_eof <= fout(c_eof_bit);
  post_dvalid <= fout(c_valid_bit);
  post_sel <= fout(c_sel_msb downto c_sel_lsb);
  post_dat <= fout(c_dat_msb downto c_dat_lsb);
  post_adr <= fout(c_adr_msb downto c_adr_lsb);

  p_gen_cyc : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        cyc_int <= '0';
      else
        if(src_stall_i = '0' and q_valid = '1') then
          -- SOF and SOF signals must be one clock cycle long
          -- and must be asserted at the same clock edge as the valid
          -- signal!
          if(post_sof = '1') then --or post_eof = '1')then
            cyc_int <= '1';
          elsif(post_eof = '1') then
            cyc_int <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  src_cyc_o <= cyc_int or post_sof;
  src_we_o  <= '1';
  src_stb_o <= post_dvalid and q_valid;

  -----------------------------
  -- Wishbone Streaming Interface selection
  -----------------------------
  gen_16_bit_interface_out : if g_wbs_interface_width = NARROW2 generate
    src_sel16_o <= post_sel;
    src_dat16_o <= post_dat;
    src_adr16_o <= post_adr;
  end generate;

  gen_32_bit_interface_out : if g_wbs_interface_width = NARROW1 generate
    src_sel32_o <= post_sel;
    src_dat32_o <= post_dat;
    src_adr32_o <= post_adr;
  end generate;

  gen_64_bit_interface_out : if g_wbs_interface_width = LARGE1 generate
    src_sel64_o <= post_sel;
    src_dat64_o <= post_dat;
    src_adr64_o <= post_adr;
  end generate;

  gen_128_bit_interface_out : if g_wbs_interface_width = LARGE2 generate
    src_sel128_o <= post_sel;
    src_dat128_o <= post_dat;
    src_adr128_o <= post_adr;
  end generate;

end rtl;
