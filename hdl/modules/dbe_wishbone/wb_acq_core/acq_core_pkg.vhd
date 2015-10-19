library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wishbone_pkg.all;
use work.genram_pkg.all;

package acq_core_pkg is

  -- Constants
  constant c_acq_samples_size               : natural := 32;
  constant c_pkt_size_width                 : natural := 32;
  constant c_shots_size_width               : natural := 16;
  constant c_addr_width                     : natural := 32;
  constant c_chan_id_width                  : natural := 5;

  constant c_data_valid_width               : natural := 1;
  constant c_data_oob_width                 : natural := 2; -- SOF and EOF

  constant c_data_oob_sof_ofs               : natural := 1; -- SOF offset
  constant c_data_oob_eof_ofs               : natural := 0; -- EOF offset

  constant c_acq_chan_width                 : natural := 64;
  constant c_acq_chan_max_w                 : natural := 2*c_acq_chan_width;
  constant c_acq_chan_max_w_log2            : natural := f_log2_size(c_acq_chan_max_w)+1;

  constant c_acq_num_atoms_width            : natural := 32;
  constant c_acq_num_atoms_width_log2       : natural := f_log2_size(c_acq_num_atoms_width)+1;

  constant c_acq_atom_width                 : natural := c_acq_chan_max_w;
  constant c_acq_atom_width_log2            : natural := f_log2_size(c_acq_atom_width)+1;

  constant c_ddr3_ui_diff_threshold         : natural := 3;

  -- ADC + TBT + FOFB + MONIT + MONIT_1
  constant c_acq_num_channels               : natural := 5;

  constant c_num_payload_ratios             : natural := 3;
  constant c_max_payload_ratio              : natural := 8;

  -- Acquisition data fields
  constant c_acq_header_width               : natural := 4; -- trigger + data_id
  constant c_acq_header_trigger_idx         : natural := 0; -- trigger bit position
  constant c_acq_header_id_bot_idx          : natural := 1; -- id bit bottom position
  constant c_acq_header_id_top_idx          : natural := 3; -- id bit top position

  -- Type declarations

  type t_acq_bool_array is array (natural range <>) of boolean;

  subtype t_payld_ratio is integer range 0 to c_max_payload_ratio;
  type t_payld_ratio_array is array (natural range <>) of t_payld_ratio;

  subtype t_acq_width is unsigned(c_acq_chan_max_w_log2-1 downto 0);
  type t_acq_width_array is array (natural range <>) of t_acq_width;

  subtype t_acq_num_atoms is unsigned(c_acq_num_atoms_width_log2-1 downto 0);
  type t_acq_num_atoms_array is array (natural range <>) of t_acq_num_atoms;

  subtype t_acq_atom_width is unsigned(c_acq_atom_width_log2-1 downto 0);
  type t_acq_atom_width_array is array (natural range <>) of t_acq_atom_width;

  subtype t_property_value is natural;
  type t_property_value_array is array (natural range <>) of t_property_value;

  type t_acq_chan_property is (WIDTH, NUM_ATOMS, ATOM_WIDTH);

  -- Parameters for acquisition core channels. Max of 128-bit in width
  type t_acq_chan_param is record
    width : t_acq_width;
    num_atoms : t_acq_num_atoms;
    atom_width : t_acq_atom_width;
  end record;

  type t_acq_chan_param_array is array (natural range <>) of t_acq_chan_param;

  type t_acq_chan_slice is record
    use_high_part : boolean;
  end record;

  type t_acq_chan_slice_array is array (natural range <>) of t_acq_chan_slice;

  subtype t_acq_val_half is std_logic_vector(c_acq_chan_width-1 downto 0);

  type t_acq_val_half_array is array (natural range <>) of t_acq_val_half;

  type t_acq_val_full is record
    val_low : t_acq_val_half;
    val_high : t_acq_val_half;
  end record;

  type t_acq_val_full_array is array (natural range <>) of t_acq_val_full;

  -- Acquisition core channels. No VHDL-2008 support.
  -- We constrain the c_acq_chan_width to hold 128-bit tops (low + high). if we
  -- want to use only the "low" part we expect the synthetizer to optimize the
  -- unused signals.
  type t_acq_chan is record
    val_low : t_acq_val_half;
    val_high : t_acq_val_half;
    dvalid : std_logic;
    trig : std_logic;
  end record;

  type t_acq_chan_array is array (natural range <>) of t_acq_chan;

  constant c_default_acq_num_channels : natural := 5;
  constant c_default_acq_chan_param64 : t_acq_chan_param := (
                                                width => to_unsigned(64, c_acq_chan_max_w_log2),
                                                num_atoms => to_unsigned(4, c_acq_num_atoms_width_log2),
                                                atom_width => to_unsigned(16, c_acq_atom_width_log2) -- 2^4 = 16-bit
                                                );
  constant c_default_acq_chan_param128 : t_acq_chan_param := (
                                                width => to_unsigned(128, c_acq_chan_max_w_log2),
                                                num_atoms => to_unsigned(4, c_acq_num_atoms_width_log2),
                                                atom_width => to_unsigned(32, c_acq_atom_width_log2) -- 2^5 = 32-bit
                                                );
  constant c_default_acq_chan_param: t_acq_chan_param := c_default_acq_chan_param64;
  constant c_default_acq_chan_param_array : t_acq_chan_param_array(c_default_acq_num_channels-1 downto 0) :=
                                              (
                                                0 => c_default_acq_chan_param64,
                                                1 => c_default_acq_chan_param128,
                                                2 => c_default_acq_chan_param128,
                                                3 => c_default_acq_chan_param128,
                                                4 => c_default_acq_chan_param128
                                              );
  constant c_default_acq_chan : t_acq_chan := (val_low => (others => '0'),
                                                 val_high => (others => '0'),
                                                 dvalid => '0',
                                                 trig => '0');

  -----------------------------
  -- Functions declaration
  ----------------------------
  function f_extract_property_array(acq_chan_param_array : t_acq_chan_param_array;
      property : t_acq_chan_property)
    return t_property_value_array;

  function f_acq_chan_find(acq_chan_param_array : t_acq_chan_param_array;
      find_widest : boolean; property : t_acq_chan_property)
    return natural;

  --Find the widest channel
  function f_acq_chan_find_widest(acq_chan_param_array : t_acq_chan_param_array)
    return natural;

  --Find the narrowest channel
  function f_acq_chan_find_narrowest(acq_chan_param_array : t_acq_chan_param_array)
    return natural;

  function f_acq_chan_find_widest_atom(acq_chan_param_array : t_acq_chan_param_array)
    return natural;

  function f_acq_chan_find_narrowest_atom(acq_chan_param_array : t_acq_chan_param_array)
    return natural;

  function f_acq_chan_find_widest_num_atoms(acq_chan_param_array : t_acq_chan_param_array)
    return natural;

  function f_acq_chan_find_narrowest_num_atoms(acq_chan_param_array : t_acq_chan_param_array)
    return natural;

  function f_acq_chan_det_slice(acq_chan_param_array : t_acq_chan_param_array)
    return t_acq_chan_slice_array;

  function f_fc_payload_ratio(payload_width : natural; acq_chan_slice_array : t_acq_chan_slice_array)
    return t_payld_ratio_array;

  function f_acq_chan_marshall_val(acq_val_high : t_acq_val_half; acq_val_low : t_acq_val_half)
    return t_acq_val_full;

  function f_acq_chan_conv_val(acq_val : t_acq_val_full)
    return std_logic_vector;

  function f_acq_chan_unmarshall_val(acq_val : t_acq_val_full; acq_sel : natural)
    return t_acq_val_half;

  -- Move this function to appropriate package
  function f_log2_size_array(payld_ratio_array : t_payld_ratio_array)
    return t_payld_ratio_array;

  -----------------------------
  -- Components declaration
  ----------------------------

  function f_gen_std_logic_vector(size : natural; value : std_logic)
    return std_logic_vector;

  component acq_sel_chan
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

    -- Current channel selection ID
    lmt_curr_chan_id_i                        : in unsigned(c_chan_id_width-1 downto 0);
    -- Acquisition limits valid signal
    lmt_valid_i                               : in std_logic;

    -----------------------------
    -- Output Interface.
    -----------------------------
    acq_data_o                                : out std_logic_vector(c_acq_chan_max_w-1 downto 0);
    acq_dvalid_o                              : out std_logic;
    acq_trig_o                                : out std_logic
  );
  end component;

  component acq_trigger
  generic
  (
    g_data_in_width                           : natural := 128;
    g_acq_num_channels                        : natural := 1;
    g_acq_channels                            : t_acq_chan_param_array := c_default_acq_chan_param_array
  );
  port
  (
    fs_clk_i                                  : in std_logic;
    fs_ce_i                                   : in std_logic;
    fs_rst_n_i                                : in std_logic;

    -- Configuration trigger inputs
    cfg_hw_trig_sel_i                         : in std_logic;
    cfg_hw_trig_pol_i                         : in std_logic;
    cfg_hw_trig_en_i                          : in std_logic;
    cfg_sw_trig_t_i                           : in std_logic;
    cfg_sw_trig_en_i                          : in std_logic;
    cfg_trig_dly_i                            : in std_logic_vector(31 downto 0);
    cfg_int_trig_sel_i                        : in std_logic_vector(1 downto 0);
    cfg_int_trig_thres_i                      : in std_logic_vector(31 downto 0);
    cfg_int_trig_thres_filt_i                 : in std_logic_vector(7 downto 0);

    -- Acquisition input
    acq_data_i                                : in std_logic_vector(g_data_in_width-1 downto 0);
    acq_valid_i                               : in std_logic;
    acq_trig_i                                : in std_logic;

    -- Current channel selection ID
    lmt_curr_chan_id_i                        : in unsigned(c_chan_id_width-1 downto 0);
    -- Acquisition limits valid signal
    lmt_valid_i                               : in std_logic;

    -- Acquisition data with data + metadata
    acq_data_o                                : out std_logic_vector(g_data_in_width-1 downto 0);
    acq_valid_o                               : out std_logic;
    acq_trig_o                                : out std_logic
  );
  end component;

  component acq_fsm
  port
  (
    fs_clk_i                                  : in std_logic;
    fs_ce_i                                   : in std_logic;
    fs_rst_n_i                                : in std_logic;

    ext_clk_i                                 : in std_logic;
    ext_rst_n_i                               : in std_logic;

    -----------------------------
    -- FSM Commands (Inputs)
    -----------------------------
    acq_start_i                               : in  std_logic := '0';
    acq_now_i                                 : in  std_logic := '0';
    acq_stop_i                                : in  std_logic := '0';
    acq_trig_i                                : in  std_logic := '0';
    acq_dvalid_i                              : in  std_logic := '0';

    -----------------------------
    -- FSM Number of Samples
    -----------------------------
    pre_trig_samples_i                        : in unsigned(c_acq_samples_size-1 downto 0);
    post_trig_samples_i                       : in unsigned(c_acq_samples_size-1 downto 0);
    shots_nb_i                                : in unsigned(15 downto 0);
    samples_cnt_o                             : out unsigned(c_acq_samples_size-1 downto 0);

    -----------------------------
    -- FSM Monitoring
    -----------------------------
    acq_end_o                                 : out std_logic;
    acq_single_shot_o                         : out std_logic;
    acq_in_pre_trig_o                         : out std_logic;
    acq_in_wait_trig_o                        : out std_logic;
    acq_in_post_trig_o                        : out std_logic;
    acq_pre_trig_done_o                       : out std_logic;
    acq_wait_trig_skip_done_o                 : out std_logic;
    acq_post_trig_done_o                      : out std_logic;
    acq_fsm_req_rst_o                         : out std_logic;
    acq_fsm_state_o                           : out std_logic_vector(2 downto 0);
    acq_fsm_rstn_fs_sync_o                    : out std_logic;
    acq_fsm_rstn_ext_sync_o                   : out std_logic;

    -----------------------------
    -- Acquistion limits
    -----------------------------
    lmt_acq_pre_pkt_size_o                    : out unsigned(c_acq_samples_size-1 downto 0);
    lmt_acq_pos_pkt_size_o                    : out unsigned(c_acq_samples_size-1 downto 0);
    lmt_acq_full_pkt_size_o                   : out unsigned(c_acq_samples_size-1 downto 0);
    lmt_shots_nb_o                            : out unsigned(15 downto 0);
    lmt_valid_o                               : out std_logic;

    -----------------------------
    -- FSM Outputs
    -----------------------------
    shots_decr_o                              : out std_logic;
    acq_trig_o                                : out std_logic;
    multishot_buffer_sel_o                    : out std_logic;
    samples_wr_en_o                           : out std_logic
  );
  end component;

  component acq_multishot_dpram
  generic
  (
    g_header_out_width                        : natural := 1;
    g_data_width                              : natural := 64;
    g_multishot_ram_size                      : natural := 2048
  );
  port
  (
    fs_clk_i                                  : in std_logic;
    fs_ce_i                                   : in std_logic;
    fs_rst_n_i                                : in std_logic;

    data_i                                    : in std_logic_vector(g_data_width-1 downto 0);
    data_id_i                                 : in std_logic_vector(2 downto 0);
    dvalid_i                                  : in std_logic;
    wr_en_i                                   : in std_logic;
    addr_rst_i                                : in std_logic;

    buffer_sel_i                              : in std_logic;
    acq_trig_i                                : in std_logic;

    pre_trig_samples_i                        : in unsigned(c_acq_samples_size-1 downto 0);
    post_trig_samples_i                       : in unsigned(c_acq_samples_size-1 downto 0);

    acq_pre_trig_done_i                       : in std_logic;
    acq_wait_trig_skip_done_i                 : in std_logic;
    acq_post_trig_done_i                      : in std_logic;

    dpram_dout_o                              : out std_logic_vector(g_header_out_width+g_data_width-1 downto 0);
    dpram_valid_o                             : out std_logic
  );
  end component;

  component acq_fc_fifo
  generic
  (
    g_header_in_width                         : natural := 1;
    g_data_in_width                           : natural := 128;
    g_header_out_width                        : natural := 2;
    g_data_out_width                          : natural := 256;
    g_addr_width                              : natural := 32;
    g_acq_num_channels                        : natural := 1;
    g_acq_channels                            : t_acq_chan_param_array;
    g_fifo_size                               : natural := 64;
    g_fc_pipe_size                            : natural := 4
  );
  port
  (
    fs_clk_i                                  : in  std_logic;
    fs_ce_i                                   : in  std_logic;
    fs_rst_n_i                                : in  std_logic;

    -- DDR3 external clock
    ext_clk_i                                 : in  std_logic;
    ext_rst_n_i                               : in  std_logic;

    -- DPRAM data
    dpram_data_i                              : in std_logic_vector(g_header_in_width+g_data_in_width-1 downto 0);
    dpram_dvalid_i                            : in std_logic;

    -- Passthough data
    pt_data_i                                 : in std_logic_vector(g_data_in_width-1 downto 0);
    pt_data_id_i                              : in std_logic_vector(2 downto 0);
    pt_trig_i                                 : in std_logic;
    pt_dvalid_i                               : in std_logic;
    pt_wr_en_i                                : in std_logic;

    -- Request transaction reset as soon as possible (when all outstanding
    -- transactions have been commited)
    req_rst_trans_i                           : in std_logic;
    -- Select between multi-buffer mode and pass-through mode (data directly
    -- through external module interface)
    passthrough_en_i                          : in std_logic;
    -- which buffer (0 or 1) to store data in. valid only when passthrough_en_i = '0'
    buffer_sel_i                              : in std_logic;

    -- Current channel selection ID
    lmt_curr_chan_id_i                        : in unsigned(c_chan_id_width-1 downto 0);
    -- Size of the pre trigger transaction in g_fifo_size bytes
    lmt_pre_pkt_size_i                        : in unsigned(c_pkt_size_width-1 downto 0);
    -- Size of the post trigger transaction in g_fifo_size bytes
    lmt_pos_pkt_size_i                        : in unsigned(c_pkt_size_width-1 downto 0);
    -- Size of the full transaction in g_fifo_size bytes
    lmt_full_pkt_size_i                       : in unsigned(c_pkt_size_width-1 downto 0);
    -- Number of shots in this acquisition
    lmt_shots_nb_i                            : in unsigned(15 downto 0);
    -- Acquisition limits valid signal. Qualifies lmt_pkt_size_i and lmt_shots_nb_i
    lmt_valid_i                               : in std_logic;

    -- Asserted when all words are transfered to the external memory
    fifo_fc_all_trans_done_p_o                : out std_logic;
    -- Asserted when the Acquisition FIFO is full. Data is lost when this signal is
    -- set and valid data keeps coming
    fifo_fc_full_o                            : out std_logic;

    -- Flow protocol to interface with external SDRAM. Evaluate the use of
    -- Wishbone Streaming protocol.
    fifo_fc_dout_o                            : out std_logic_vector(g_header_out_width+g_data_out_width-1 downto 0);
    fifo_fc_valid_o                           : out std_logic;
    fifo_fc_addr_o                            : out std_logic_vector(g_addr_width-1 downto 0);
    fifo_fc_sof_o                             : out std_logic;
    fifo_fc_eof_o                             : out std_logic;
    fifo_fc_dreq_i                            : in std_logic;
    fifo_fc_stall_i                           : in std_logic;

    dbg_fifo_we_o                             : out std_logic;
    dbg_fifo_wr_count_o                       : out std_logic_vector(f_log2_size(g_fifo_size)-1 downto 0);
    dbg_fifo_re_o                             : out std_logic;
    dbg_fifo_fc_rd_en_o                       : out std_logic;
    dbg_fifo_rd_empty_o                       : out std_logic;
    dbg_fifo_wr_full_o                        : out std_logic;
    dbg_fifo_fc_valid_fwft_o                  : out std_logic;
    dbg_source_pl_dreq_o                      : out std_logic;
    dbg_source_pl_stall_o                     : out std_logic;
    dbg_pkt_ct_cnt_o                          : out std_logic_vector(c_pkt_size_width-1 downto 0);
    dbg_shots_cnt_o                           : out std_logic_vector(c_shots_size_width-1 downto 0)
  );
  end component;

  component acq_fwft_fifo
  generic
  (
    g_data_width                              : natural := 64;
    g_size                                    : natural := 64;

    g_with_rd_empty                           : boolean := true;
    g_with_rd_full                            : boolean := false;
    g_with_rd_almost_empty                    : boolean := false;
    g_with_rd_almost_full                     : boolean := false;
    g_with_rd_count                           : boolean := false;

    g_with_wr_empty                           : boolean := false;
    g_with_wr_full                            : boolean := true;
    g_with_wr_almost_empty                    : boolean := false;
    g_with_wr_almost_full                     : boolean := false;
    g_with_wr_count                           : boolean := false;

    g_with_fifo_inferred                      : boolean := false;

    g_almost_empty_threshold                  : integer;
    g_almost_full_threshold                   : integer;
    g_async                                   : boolean := true
  );
  port
  (
    -- Write clock
    wr_clk_i                                  : in  std_logic;
    wr_rst_n_i                                : in  std_logic;

    wr_data_i                                 : in std_logic_vector(g_data_width-1 downto 0);
    wr_en_i                                   : in std_logic;
    wr_full_o                                 : out std_logic;
    wr_count_o                                : out std_logic_vector(f_log2_size(g_size)-1 downto 0);
    wr_almost_empty_o                         : out std_logic;
    wr_almost_full_o                          : out std_logic;

    -- Read clock
    rd_clk_i                                  : in  std_logic;
    rd_rst_n_i                                : in  std_logic;

    rd_data_o                                 : out std_logic_vector(g_data_width-1 downto 0);
    rd_valid_o                                : out std_logic;
    rd_en_i                                   : in  std_logic;
    rd_empty_o                                : out std_logic;
    rd_count_o                                : out std_logic_vector(f_log2_size(g_size)-1 downto 0);
    rd_almost_empty_o                         : out std_logic;
    rd_almost_full_o                          : out std_logic
  );
  end component;

  component fc_source
  generic
  (
    g_header_in_width                         : natural := 4;
    g_data_width                              : natural := 64;
    g_pkt_size_width                          : natural := 32;
    g_addr_width                              : natural := 32;
    g_with_fifo_inferred                      : boolean := false;
    g_pipe_size                               : natural := 4
  );
  port
  (
    clk_i                                     : in std_logic;
    rst_n_i                                   : in std_logic;

    -- Plain Interface
    pl_data_i                                 : in std_logic_vector(g_header_in_width+g_data_width-1 downto 0);
    pl_addr_i                                 : in std_logic_vector(g_addr_width-1 downto 0);
    pl_valid_i                                : in std_logic;

    pl_dreq_o                                 : out std_logic; -- optional for driving another FC interface
    pl_stall_o                                : out std_logic; -- optional for driving another FC interface
    pl_pkt_sent_o                             : out std_logic; -- optional for knowing the exact time a packet was sent

    pl_rst_trans_i                            : in std_logic;

    -- Limits
    lmt_pre_pkt_size_i                        : in unsigned(c_pkt_size_width-1 downto 0);
    lmt_pos_pkt_size_i                        : in unsigned(c_pkt_size_width-1 downto 0);
    lmt_full_pkt_size_i                       : in unsigned(c_pkt_size_width-1 downto 0);
    lmt_valid_i                               : in std_logic;

    -- Flow Control Interface
    fc_dout_o                                 : out std_logic_vector(g_header_in_width+g_data_width-1 downto 0);
    fc_valid_o                                : out std_logic;
    fc_addr_o                                 : out std_logic_vector(g_addr_width-1 downto 0);
    fc_sof_o                                  : out std_logic;
    fc_eof_o                                  : out std_logic;

    fc_stall_i                                : in std_logic;
    fc_dreq_i                                 : in std_logic
  );
  end component;

  component acq_cnt
  port
  (
    -- DDR3 external clock
    clk_i                                     : in  std_logic;
    rst_n_i                                   : in  std_logic;

    cnt_all_pkts_ct_done_p_o                  : out std_logic; -- all current transaction packets done
    cnt_all_trans_done_p_o                    : out std_logic; -- all transactions done
    cnt_en_i                                  : in std_logic;

    -- Size of the transaction in g_fifo_size bytes
    lmt_pkt_size_i                            : in unsigned(c_pkt_size_width-1 downto 0);
    -- Number of shots in this acquisition
    lmt_shots_nb_i                            : in unsigned(c_shots_size_width-1 downto 0);
    -- Acquisition limits valid signal. Qualifies lmt_pkt_size_i and lmt_shots_nb_i
    lmt_valid_i                               : in std_logic;

    dbg_pkt_ct_cnt_o                          : out std_logic_vector(c_pkt_size_width-1 downto 0);
    dbg_shots_cnt_o                           : out std_logic_vector(c_shots_size_width-1 downto 0)
  );
  end component;

  component acq_2_diff_cnt
  generic
  (
    -- Threshold in which the counters can differ
    g_threshold_max                           : natural := 2
  );
  port
  (
    -- DDR3 external clock
    clk_i                                     : in  std_logic;
    rst_n_i                                   : in  std_logic;

    cnt0_en_i                                 : in std_logic;
    cnt0_thres_hit_o                          : out std_logic;

    cnt1_en_i                                 : in std_logic;
    cnt1_thres_hit_o                          : out std_logic
  );
  end component;

  component acq_pulse_level_sync
  generic
  (
    g_num_inputs                              : natural := 1;
    g_with_pulse_sync                         : t_acq_bool_array;
    g_with_pulse2level                        : t_acq_bool_array
  );
  port
  (
    -- Input pulse clock
    clk_in_i                                  : in  std_logic_vector(g_num_inputs-1 downto 0);
    -- Input pulse reset
    rst_in_n_i                                : in  std_logic_vector(g_num_inputs-1 downto 0);
    -- Synched pulse clock
    clk_out_i                                 : in  std_logic_vector(g_num_inputs-1 downto 0);
    -- Input pulse reset
    rst_out_n_i                               : in  std_logic_vector(g_num_inputs-1 downto 0);

    -- Pulse input
    pulse_i                                   : in std_logic_vector(g_num_inputs-1 downto 0);
    -- Clear level_o
    clr_i                                     : in std_logic_vector(g_num_inputs-1 downto 0);

    -- clk_out_i synched pulse (using full feedback synchronizer)
    pulse_synched_o                           : out std_logic_vector(g_num_inputs-1 downto 0);
    -- level generated by pulse_i and synched with clk_out_i
    level_synched_o                           : out std_logic_vector(g_num_inputs-1 downto 0)
  );
  end component;

  component acq_ddr3_iface
  generic
  (
    g_acq_num_channels                        : natural := 1;
    g_acq_channels                            : t_acq_chan_param_array;
    g_fc_pipe_size                            : natural := 4;
    -- Do not modify these! As they are dependent of the memory controller generated!
    g_ddr_header_width                        : natural := 4;
    g_ddr_payload_width                       : natural := 256;     -- be careful changing these!
    g_ddr_dq_width                            : natural := 64;      -- be careful changing these!
    g_ddr_addr_width                          : natural := 32       -- be careful changing these!
  );
  port
  (
    -- DDR3 external clock
    ext_clk_i                                 : in  std_logic;
    ext_rst_n_i                               : in  std_logic;

    -- Flow protocol to interface with external SDRAM. Evaluate the use of
    -- Wishbone Streaming protocol.
    fifo_fc_din_i                             : in std_logic_vector(g_ddr_header_width+g_ddr_payload_width-1 downto 0);
    fifo_fc_valid_i                           : in std_logic;
    fifo_fc_addr_i                            : in std_logic_vector(g_ddr_addr_width-1 downto 0);
    fifo_fc_sof_i                             : in std_logic;
    fifo_fc_eof_i                             : in std_logic;
    fifo_fc_dreq_o                            : out std_logic;
    fifo_fc_stall_o                           : out std_logic;

    wr_start_i                                : in std_logic;
    wr_init_addr_i                            : in std_logic_vector(g_ddr_addr_width-1 downto 0);
    wr_end_addr_i                             : in std_logic_vector(g_ddr_addr_width-1 downto 0);

    lmt_all_trans_done_p_o                    : out std_logic;
    lmt_ddr_trig_addr_o                       : out std_logic_vector(g_ddr_addr_width-1 downto 0);
    lmt_rst_i                                 : in std_logic;

    -- Current channel selection ID
    lmt_curr_chan_id_i                        : in unsigned(c_chan_id_width-1 downto 0);
    -- Size of the pre trigger transaction in g_fifo_size bytes
    lmt_pre_pkt_size_i                        : in unsigned(c_pkt_size_width-1 downto 0);
    -- Size of the post trigger transaction in g_fifo_size bytes
    lmt_pos_pkt_size_i                        : in unsigned(c_pkt_size_width-1 downto 0);
    -- Size of the full transaction in g_fifo_size bytes
    lmt_full_pkt_size_i                       : in unsigned(c_pkt_size_width-1 downto 0);
    -- Number of shots in this acquisition
    lmt_shots_nb_i                            : in unsigned(15 downto 0);
    -- Acquisition limits valid signal. Qualifies lmt_pkt_size_i and lmt_shots_nb_i
    lmt_valid_i                               : in std_logic;

    -- Xilinx DDR3 UI Interface
    ui_app_addr_o                             : out std_logic_vector(g_ddr_addr_width-1 downto 0);
    ui_app_cmd_o                              : out std_logic_vector(2 downto 0);
    ui_app_en_o                               : out std_logic;
    ui_app_rdy_i                              : in std_logic;

    ui_app_wdf_data_o                         : out std_logic_vector(g_ddr_payload_width-1 downto 0);
    ui_app_wdf_end_o                          : out std_logic;
    ui_app_wdf_mask_o                         : out std_logic_vector(g_ddr_payload_width/8-1 downto 0);
    ui_app_wdf_wren_o                         : out std_logic;
    ui_app_wdf_rdy_i                          : in std_logic;

    ui_app_rd_data_i                          : in std_logic_vector(g_ddr_payload_width-1 downto 0);
    ui_app_rd_data_end_i                      : in std_logic;
    ui_app_rd_data_valid_i                    : in std_logic;

    ui_app_req_o                              : out std_logic;
    ui_app_gnt_i                              : in std_logic
  );
  end component;

  component acq_ddr3_read
  generic
  (
    g_acq_addr_width                          : natural := 32;
    g_acq_num_channels                        : natural := 1;
    g_acq_channels                            : t_acq_chan_param_array;
    -- Do not modify these! As they are dependent of the memory controller generated!
    g_ddr_payload_width                       : natural := 256;     -- be careful changing these!
    g_ddr_dq_width                            : natural := 64;      -- be careful changing these!
    g_ddr_addr_width                          : natural := 32       -- be careful changing these!
  );
  port
  (
    -- DDR3 external clock
    ext_clk_i                                 : in  std_logic;
    ext_rst_n_i                               : in  std_logic;

    -- Flow protocol to interface with external SDRAM. Evaluate the use of
    -- Wishbone Streaming protocol.
    fifo_fc_din_o                             : out std_logic_vector(g_ddr_payload_width-1 downto 0);
    fifo_fc_valid_o                           : out std_logic;
    fifo_fc_addr_o                            : out std_logic_vector(g_acq_addr_width-1 downto 0);
    fifo_fc_sof_o                             : out std_logic; -- ignored
    fifo_fc_eof_o                             : out std_logic; -- ignored
    fifo_fc_dreq_i                            : in std_logic;  -- ignored
    fifo_fc_stall_i                           : in std_logic;  -- ignored

    rb_start_i                                : in std_logic;
    rb_init_addr_i                            : in std_logic_vector(g_ddr_addr_width-1 downto 0);
    rb_ddr_trig_addr_i                        : in std_logic_vector(g_ddr_addr_width-1 downto 0);

    lmt_all_trans_done_p_o                    : out std_logic;
    lmt_rst_i                                 : in std_logic;

    -- Current channel selection ID
    lmt_curr_chan_id_i                        : in unsigned(c_chan_id_width-1 downto 0);
    -- Size of the pre trigger transaction in g_fifo_size bytes
    lmt_pre_pkt_size_i                        : in unsigned(c_pkt_size_width-1 downto 0);
    -- Size of the post trigger transaction in g_fifo_size bytes
    lmt_pos_pkt_size_i                        : in unsigned(c_pkt_size_width-1 downto 0);
    -- Size of the full transaction in g_fifo_size bytes
    lmt_full_pkt_size_i                       : in unsigned(c_pkt_size_width-1 downto 0);
    -- Number of shots in this acquisition
    lmt_shots_nb_i                            : in unsigned(15 downto 0);
    -- Acquisition limits valid signal. Qualifies lmt_pkt_size_i and lmt_shots_nb_i
    lmt_valid_i                               : in std_logic;

    -- Xilinx DDR3 UI Interface
    ui_app_addr_o                             : out std_logic_vector(g_ddr_addr_width-1 downto 0);
    ui_app_cmd_o                              : out std_logic_vector(2 downto 0);
    ui_app_en_o                               : out std_logic;
    ui_app_rdy_i                              : in std_logic;

    ui_app_rd_data_i                          : in std_logic_vector(g_ddr_payload_width-1 downto 0);
    ui_app_rd_data_end_i                      : in std_logic;
    ui_app_rd_data_valid_i                    : in std_logic;

    ui_app_req_o                              : out std_logic;
    ui_app_gnt_i                              : in std_logic
  );
  end component;

  component data_checker
  generic
  (
    g_data_width                              : natural := 64;
    g_addr_width                              : natural := 32;
    g_fifo_size                               : natural := 64
  );
  port
  (
    -- DDR3 external clock
    ext_clk_i                                 : in  std_logic;
    ext_rst_n_i                               : in  std_logic;

    -- Expected data
    exp_din_i                                 : in std_logic_vector(g_data_width-1 downto 0);
    exp_valid_i                               : in std_logic;
    exp_addr_i                                : in std_logic_vector(g_addr_width-1 downto 0);

    -- Actual data
    act_din_i                                 : in std_logic_vector(g_data_width-1 downto 0);
    act_valid_i                               : in std_logic;
    act_addr_i                                : in std_logic_vector(g_addr_width-1 downto 0);

    -- Size of the transaction in g_fifo_size bytes
    lmt_pkt_size_i                            : in unsigned(c_pkt_size_width-1 downto 0);
    -- Number of shots in this acquisition
    lmt_shots_nb_i                            : in unsigned(c_shots_size_width-1 downto 0);
    -- Acquisition limits valid signal. Qualifies lmt_fifo_pkt_size_i and lmt_shots_nb_i
    lmt_valid_i                               : in std_logic;

    chk_data_err_o                            : out std_logic;
    chk_addr_err_o                            : out std_logic;
    chk_data_err_cnt_o                        : out unsigned(15 downto 0);
    chk_addr_err_cnt_o                        : out unsigned(15 downto 0);
    chk_end_o                                 : out std_logic;
    chk_pass_o                                : out std_logic
  );
  end component;

  constant c_xwb_acq_core_sdb : t_sdb_device := (
    abi_class     => x"0000",                 -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"00",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"7",                     -- 8/16/32-bit port granularity (0111)
    sdb_component => (
    addr_first    => x"0000000000000000",
    addr_last     => x"0000000000000FFF",
    product => (
    vendor_id     => x"1000000000001215",     -- LNLS
    device_id     => x"4519a0ad",
    version       => x"00000001",
    date          => x"20131011",
    name          => "LNLS_BPM_ACQ_CORE  ")));

end acq_core_pkg;

package body acq_core_pkg is

  function f_extract_property_array(acq_chan_param_array : t_acq_chan_param_array;
      property : t_acq_chan_property)
    return t_property_value_array
  is
    variable property_value_array : t_property_value_array(acq_chan_param_array'length-1 downto 0) :=
        (others => 0);
  begin
    -- Generate arrays depending on the selected property
    loop_property_array : for i in 0 to property_value_array'length-1 loop

      case property is
          when WIDTH =>
              property_value_array(i) := to_integer(acq_chan_param_array(i).width);
          when NUM_ATOMS =>
              property_value_array(i) := to_integer(acq_chan_param_array(i).num_atoms);
          when ATOM_WIDTH =>
              property_value_array(i) := to_integer(acq_chan_param_array(i).atom_width);
          when others =>
            null;
      end case;

    end loop;

    return property_value_array;

  end;

  --Find the widest (find_widest = true) or narrowest (find_widest = false) channel
  function f_acq_chan_find(acq_chan_param_array : t_acq_chan_param_array;
      find_widest : boolean; property : t_acq_chan_property)
    return natural
  is
    variable property_current_best : natural;
    variable property_array : t_property_value_array(acq_chan_param_array'length-1 downto 0);
  begin

    -- Fill array with property values
    property_array := f_extract_property_array(acq_chan_param_array, property);

    -- Initialize current_best with the first element in the array
    property_current_best := property_array(0);

    -- Compare generated array to the current best and return the best overall
    for i in 1 to property_array'length-1 loop
      -- Search for the widest
      if (find_widest and property_array(i) > property_current_best) or
         -- Search for the narrowest
         (not find_widest and property_array(i) < property_current_best) then
        property_current_best := property_array(i);
      end if;
    end loop;

    return property_current_best;
  end;

  function f_acq_chan_find_widest(acq_chan_param_array : t_acq_chan_param_array)
    return natural
  is
    variable find_widest : boolean := true;
    variable property_type : t_acq_chan_property;
  begin
    property_type := WIDTH;
    return f_acq_chan_find(acq_chan_param_array, find_widest, property_type);
  end;

  function f_acq_chan_find_narrowest(acq_chan_param_array : t_acq_chan_param_array)
    return natural
  is
    variable find_narrowest : boolean := false;
    variable property_type : t_acq_chan_property;
  begin
    property_type := WIDTH;
    return f_acq_chan_find(acq_chan_param_array, find_narrowest, property_type);
  end;

  function f_acq_chan_find_widest_atom(acq_chan_param_array : t_acq_chan_param_array)
    return natural
  is
    variable find_widest : boolean := true;
    variable property_type : t_acq_chan_property;
  begin
    property_type := ATOM_WIDTH;
    return f_acq_chan_find(acq_chan_param_array, find_widest, property_type);
  end;

  function f_acq_chan_find_narrowest_atom(acq_chan_param_array : t_acq_chan_param_array)
    return natural
  is
    variable find_widest : boolean := false;
    variable property_type : t_acq_chan_property;
  begin
    property_type := ATOM_WIDTH;
    return f_acq_chan_find(acq_chan_param_array, find_widest, property_type);
  end;

  function f_acq_chan_find_widest_num_atoms(acq_chan_param_array : t_acq_chan_param_array)
    return natural
  is
    variable find_widest : boolean := true;
    variable property_type : t_acq_chan_property;
  begin
    property_type := NUM_ATOMS;
    return f_acq_chan_find(acq_chan_param_array, find_widest, property_type);
  end;

  function f_acq_chan_find_narrowest_num_atoms(acq_chan_param_array : t_acq_chan_param_array)
    return natural
  is
    variable find_widest : boolean := false;
    variable property_type : t_acq_chan_property;
  begin
    property_type := NUM_ATOMS;
    return f_acq_chan_find(acq_chan_param_array, find_widest, property_type);
  end;

  -- Determine which part of the vector is valid
  function f_acq_chan_det_slice(acq_chan_param_array : t_acq_chan_param_array)
    return t_acq_chan_slice_array
  is
    variable acq_chan_slice : t_acq_chan_slice_array(acq_chan_param_array'length-1 downto 0);
  begin

    for i in 0 to acq_chan_param_array'length-1 loop
      if acq_chan_param_array(i).width > c_acq_chan_width then -- use high part
        acq_chan_slice(i).use_high_part := true;
      else
        acq_chan_slice(i).use_high_part := false;
      end if;
    end loop;

    return acq_chan_slice;
  end;

  function f_fc_payload_ratio(payload_width : natural; acq_chan_slice_array : t_acq_chan_slice_array)
    return t_payld_ratio_array
  is
    variable fc_payload_ratio : t_payld_ratio_array(acq_chan_slice_array'length-1 downto 0);
  begin
    for i in 0 to acq_chan_slice_array'length-1 loop
      if (acq_chan_slice_array(i).use_high_part) then -- c_acq_chan_max_w
        fc_payload_ratio(i) := payload_width/c_acq_chan_max_w;
      else
        fc_payload_ratio(i) := payload_width/c_acq_chan_width;
      end if;
    end loop;

    return fc_payload_ratio;

  end;

  function f_acq_chan_marshall_val(acq_val_high : t_acq_val_half; acq_val_low : t_acq_val_half)
    return t_acq_val_full
  is
    variable ret : t_acq_val_full;
  begin
    ret.val_low := acq_val_low;
    ret.val_high := acq_val_high;

    return ret;
  end;

  function f_acq_chan_conv_val(acq_val : t_acq_val_full)
    return std_logic_vector
  is
    variable ret : std_logic_vector(c_acq_chan_max_w-1 downto 0);
  begin
    ret(acq_val.val_low'left downto 0) := acq_val.val_low;
    ret(acq_val.val_high'left + acq_val.val_low'left + 1 downto
                         acq_val.val_low'left + 1) := acq_val.val_high;

    return ret;
  end;

  function f_acq_chan_unmarshall_val(acq_val : t_acq_val_full; acq_sel : natural)
    return t_acq_val_half
  is
    variable ret : t_acq_val_half;
  begin
    case acq_sel is
      when 0 => -- low
        ret := acq_val.val_low;
      when 1 => -- high
        ret := acq_val.val_high;
      when others =>
        ret := acq_val.val_low;
    end case;

    return ret;
  end;

  function f_gen_std_logic_vector(size : natural; value : std_logic)
    return std_logic_vector
  is
    variable ret : std_logic_vector(size-1 downto 0);
  begin
    for i in 0 to size-1 loop
      ret(i) := value;
    end loop;

    return ret;
  end;

  function f_log2_size_array(payld_ratio_array : t_payld_ratio_array)
    return t_payld_ratio_array
  is
    variable log2_size_array : t_payld_ratio_array(payld_ratio_array'length-1 downto 0);
  begin

    for i in 0 to payld_ratio_array'length-1 loop
      log2_size_array(i) := f_log2_size(payld_ratio_array(i));
    end loop;

    return log2_size_array;
  end;

end acq_core_pkg;
