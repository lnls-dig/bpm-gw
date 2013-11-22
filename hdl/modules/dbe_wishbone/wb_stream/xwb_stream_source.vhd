-- Based on xwb_fabric_source.vhd from Tomasz Wlostowski
-- Modified by Lucas Russo <lucas.russo@lnls.br>

library ieee;
use ieee.std_logic_1164.all;

use work.genram_pkg.all;
use work.wb_stream_pkg.all;

entity xwb_stream_source is

  port (
    clk_i                                       : in std_logic;
    rst_n_i                                     : in std_logic;

    -- Wishbone Fabric Interface I/O
    src_i                                       : in  t_wbs_source_in;
    src_o                                       : out t_wbs_source_out;

    -- Decoded & buffered logic
    addr_i                                      : in  std_logic_vector(c_wbs_address_width-1 downto 0);
    data_i                                      : in  std_logic_vector(c_wbs_data_width-1 downto 0);
    dvalid_i                                    : in  std_logic;
    sof_i                                       : in  std_logic;
    eof_i                                       : in  std_logic;
    error_i                                     : in  std_logic;
    bytesel_i                                   : in  std_logic_vector((c_wbs_data_width/8)-1 downto 0);
    dreq_o                                      : out std_logic
    );

end xwb_stream_source;

architecture rtl of xwb_stream_source is
  -- FIFO ranges and control bits location
  constant c_data_lsb                           : natural := 0;
  constant c_data_msb                           : natural := c_data_lsb + c_wbs_data_width - 1;

  constant c_addr_lsb                           : natural := c_data_msb + 1;
  constant c_addr_msb                           : natural := c_addr_lsb + c_wbs_address_width -1;

  constant c_valid_bit                          : natural := c_addr_msb + 1;

  constant c_sel_lsb                            : natural := c_valid_bit + 1;
  constant c_sel_msb                            : natural := c_sel_lsb + (c_wbs_data_width/8) - 1;

  constant c_eof_bit                            : natural := c_sel_msb + 1;
  constant c_sof_bit                            : natural := c_eof_bit + 1;

  constant c_logic_width                        : integer := c_sof_bit - c_valid_bit + 1;
  constant c_fifo_width                         : integer := c_sof_bit - c_data_lsb + 1;
  constant c_fifo_depth                         : integer := 32;

  -- Signals
  signal q_valid, full, we, rd, rd_d0           : std_logic;
  signal fin, fout                              : std_logic_vector(c_fifo_width-1 downto 0);

  signal pre_dvalid                             : std_logic;
  signal pre_eof                                : std_logic;

  signal pre_data                               : std_logic_vector(c_wbs_data_width-1 downto 0);
  signal pre_addr                               : std_logic_vector(c_wbs_address_width-1 downto 0);

  signal post_dvalid, post_eof, post_sof        : std_logic;
  signal post_eof_d                             : std_logic;
  signal post_bytesel                           : std_logic_vector((c_wbs_data_width/8)-1 downto 0);
  signal post_data                              : std_logic_vector(c_wbs_data_width-1 downto 0);
  signal post_adr                               : std_logic_vector(c_wbs_address_width-1 downto 0);

  signal err_status                             : t_wbs_status_reg;
  signal cyc_int                                : std_logic;

begin  -- rtl

  err_status.error <= '1';

  dreq_o <= not full;

  rd <= not src_i.stall;
  we <= sof_i or eof_i or error_i or dvalid_i;

  pre_dvalid <= dvalid_i or error_i;
  pre_data   <= data_i when (error_i = '0') else f_marshall_wbs_status(err_status);
  pre_addr   <= addr_i when (error_i = '0') else std_logic_vector(c_WBS_STATUS);
  pre_eof    <= error_i or eof_i;

  fin <= sof_i & pre_eof & bytesel_i & pre_dvalid & pre_addr & pre_data;

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

  post_sof    <= fout(c_sof_bit);
  post_eof    <= fout(c_eof_bit);
  post_dvalid <= fout(c_valid_bit);
  post_bytesel <= fout(c_sel_msb downto c_sel_lsb);
  post_data <= fout(c_data_msb downto c_data_lsb);
  post_adr <= fout(c_addr_msb downto c_addr_lsb);

  p_gen_cyc : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        cyc_int <= '0';
      else
        if(src_i.stall = '0' and q_valid = '1') then
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

  src_o.cyc <= cyc_int or post_sof;
  src_o.we  <= '1';
  src_o.stb <= post_dvalid and q_valid;
  --src_o.sel <= almost_all_ones & not fout(c_sel_bit);
  src_o.sel <= post_bytesel;
  src_o.dat <= post_data;--fout(c_data_msb downto c_data_lsb);
  src_o.adr <= post_adr;--fout(c_addr_msb downto c_addr_lsb);

end rtl;

library ieee;
use ieee.std_logic_1164.all;

use work.wb_stream_pkg.all;

entity wb_stream_source is

  port (
    clk_i   : in std_logic;
    rst_n_i : in std_logic;

    -- Wishbone Fabric Interface I/O

    src_dat_o   : out std_logic_vector(c_wbs_data_width-1 downto 0);
    src_adr_o   : out std_logic_vector(c_wbs_address_width-1 downto 0);
    src_sel_o   : out std_logic_vector((c_wbs_data_width/8)-1 downto 0);
    src_cyc_o   : out std_logic;
    src_stb_o   : out std_logic;
    src_we_o    : out std_logic;
    src_stall_i : in  std_logic;
    src_ack_i   : in  std_logic;
    src_err_i   : in  std_logic;

    -- Decoded & buffered fabric
    addr_i    : in  std_logic_vector(c_wbs_address_width-1 downto 0);
    data_i    : in  std_logic_vector(c_wbs_data_width-1 downto 0);
    dvalid_i  : in  std_logic;
    sof_i     : in  std_logic;
    eof_i     : in  std_logic;
    error_i   : in  std_logic;
    bytesel_i : in  std_logic;
    dreq_o    : out std_logic
    );

end wb_stream_source;

architecture wrapper of wb_stream_source is
  component xwb_stream_source
    port (
      clk_i     : in  std_logic;
      rst_n_i   : in  std_logic;
      src_i     : in  t_wbs_source_in;
      src_o     : out t_wbs_source_out;
      addr_i    : in  std_logic_vector(c_wbs_address_width-1 downto 0);
      data_i    : in  std_logic_vector(c_wbs_data_width-1 downto 0);
      dvalid_i  : in  std_logic;
      sof_i     : in  std_logic;
      eof_i     : in  std_logic;
      error_i   : in  std_logic;
      bytesel_i : in  std_logic;
      dreq_o    : out std_logic);
  end component;

  signal src_in  : t_wbs_source_in;
  signal src_out : t_wbs_source_out;

begin  -- wrapper

  cmp_stream_source_wrapper : xwb_stream_source
    port map (
      clk_i     => clk_i,
      rst_n_i   => rst_n_i,
      src_i     => src_in,
      src_o     => src_out,
      addr_i    => addr_i,
      data_i    => data_i,
      dvalid_i  => dvalid_i,
      sof_i     => sof_i,
      eof_i     => eof_i,
      error_i   => error_i,
      bytesel_i => bytesel_i,
      dreq_o    => dreq_o
    );

  src_cyc_o <= src_out.cyc;
  src_stb_o <= src_out.stb;
  src_we_o  <= src_out.we;
  src_sel_o <= src_out.sel;
  src_adr_o <= src_out.adr;
  src_dat_o <= src_out.dat;

  src_in.rty   <= '0';
  src_in.err   <= src_err_i;
  src_in.ack   <= src_ack_i;
  src_in.stall <= src_stall_i;


end wrapper;
