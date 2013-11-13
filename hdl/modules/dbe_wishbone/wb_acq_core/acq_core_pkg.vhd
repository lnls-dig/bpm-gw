library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wishbone_pkg.all;
use work.genram_pkg.all;

package acq_core_pkg is

  -- Constants
  --constant c_data_width                     : natural := 64;
  --constant c_pkt_width                      : natural := 32;
  --constant c_addr_width                     : natural := 32;
  constant c_acq_samples_size               : natural := 32;
  constant c_pkt_size_width                 : natural := 32;
  constant c_shots_size_width               : natural := 16;

  --constant c_fc_buff_size                   : natural := 4;
  constant c_data_oob_width                 : natural := 2; -- SOF and EOF

  constant c_data_oob_sof_ofs               : natural := 1; -- SOF offset
  constant c_data_oob_eof_ofs               : natural := 0; -- EOF offset

  -- Type declarations
  --subtype t_fc_data is std_logic_vector(c_data_width-1 downto 0);
  --type t_fc_data_array is array (natural range <>) of t_fc_data;
  --
  --type t_fc_dvalid_array is array (natural range <>) of std_logic;
  --
  --subtype t_fc_data_oob is std_logic_vector(c_data_oob_width -1 downto 0);
  --type t_fc_data_oob_array is array (natural range <>) of t_fc_data_oob;
  --
  --subtype t_fc_pkt is unsigned(c_pkt_width-1 downto 0);
  --subtype t_fc_addr is std_logic_vector(c_addr_width-1 downto 0);

  component wb_acq_core
  generic
  (
    g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity                     : t_wishbone_address_granularity := WORD;
    g_data_width                              : natural := 64;
    g_addr_width                              : natural := 32;
    g_ddr_payload_width                       : natural := 256;
    g_ddr_addr_width                          : natural := 32;
    g_multishot_ram_size                      : natural := 2048;
    g_fifo_fc_size                            : natural := 64;
    g_sim_readback                            : boolean := false
  );
  port
  (
    fs_clk_i                                  : in std_logic;
    fs_ce_i                                   : in std_logic;
    fs_rst_n_i                                : in std_logic;

    sys_clk_i                                 : in std_logic;
    sys_rst_n_i                               : in std_logic;

    ext_clk_i                                 : in std_logic;
    ext_rst_n_i                               : in std_logic;

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------

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
    wb_stall_o                                : out std_logic;

    -----------------------------
    -- External Interface
    -----------------------------
    data_i                                    : in  std_logic_vector(g_data_width-1 downto 0);
    dvalid_i                                  : in  std_logic := '0';
    ext_trig_i                                : in  std_logic := '0';

    -----------------------------
    -- DRRAM Interface
    -----------------------------
    dpram_dout_o                              : out std_logic_vector(g_data_width-1 downto 0);
    dpram_valid_o                             : out std_logic;

    -----------------------------
    -- External Interface (w/ FLow Control)
    -----------------------------
    ext_dout_o                                : out std_logic_vector(g_data_width-1 downto 0);
    ext_valid_o                               : out std_logic;
    ext_addr_o                                : out std_logic_vector(g_ddr_addr_width-1 downto 0);
    ext_sof_o                                 : out std_logic;
    ext_eof_o                                 : out std_logic;
    ext_dreq_o                                : out std_logic; -- for debbuging purposes
    ext_stall_o                               : out std_logic; -- for debbuging purposes

    -----------------------------
    -- DDR3 SDRAM Interface
    -----------------------------
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

    -- DDR3 arbitrer for multiple accesses
    ui_app_req_o                              : out std_logic;
    ui_app_gnt_i                              : in std_logic;

    -----------------------------
    -- Debug Interface
    -----------------------------
    dbg_ddr_rb_data_o                         : out std_logic_vector(g_ddr_payload_width-1 downto 0);
    dbg_ddr_rb_addr_o                         : out std_logic_vector(g_ddr_addr_width-1 downto 0);
    dbg_ddr_rb_valid_o                        : out std_logic
  );
  end component;

  component xwb_acq_core
  generic
  (
    g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity                     : t_wishbone_address_granularity := WORD;
    g_data_width                              : natural := 64;
    g_addr_width                              : natural := 32;
    g_ddr_payload_width                       : natural := 256;
    g_ddr_addr_width                          : natural := 32;
    g_multishot_ram_size                      : natural := 2048;
    g_fifo_fc_size                            : natural := 64;
    g_sim_readback                            : boolean := false
  );
  port
  (
    fs_clk_i                                  : in std_logic;
    fs_ce_i                                   : in std_logic;
    fs_rst_n_i                                : in std_logic;

    sys_clk_i                                 : in std_logic;
    sys_rst_n_i                               : in std_logic;

    ext_clk_i                                 : in std_logic;
    ext_rst_n_i                               : in std_logic;

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------

    wb_slv_i                                  : in t_wishbone_slave_in;
    wb_slv_o                                  : out t_wishbone_slave_out;

    -----------------------------
    -- External Interface
    -----------------------------
    data_i                                    : in  std_logic_vector(g_data_width-1 downto 0);
    dvalid_i                                  : in  std_logic := '0';
    ext_trig_i                                : in  std_logic := '0';

    -----------------------------
    -- DRRAM Interface
    -----------------------------
    dpram_dout_o                              : out std_logic_vector(g_data_width-1 downto 0);
    dpram_valid_o                             : out std_logic;

    -----------------------------
    -- External Interface (w/ FLow Control)
    -----------------------------
    ext_dout_o                                : out std_logic_vector(g_data_width-1 downto 0);
    ext_valid_o                               : out std_logic;
    ext_addr_o                                : out std_logic_vector(g_addr_width-1 downto 0);
    ext_sof_o                                 : out std_logic;
    ext_eof_o                                 : out std_logic;
    ext_dreq_o                                : out std_logic; -- for debbuging purposes
    ext_stall_o                               : out std_logic; -- for debbuging purposes

    -----------------------------
    -- DDR3 SDRAM Interface
    -----------------------------
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
    ui_app_gnt_i                              : in std_logic;
    -----------------------------
    -- Debug Interface
    -----------------------------
    dbg_ddr_rb_data_o                         : out std_logic_vector(g_data_width-1 downto 0);
    dbg_ddr_rb_addr_o                         : out std_logic_vector(g_addr_width-1 downto 0);
    dbg_ddr_rb_valid_o                        : out std_logic
  );
  end component;

  component acq_fsm
  --generic
  --(
  --);
  port
  (
    fs_clk_i                                  : in std_logic;
    fs_ce_i                                   : in std_logic;
    fs_rst_n_i                                : in std_logic;

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
    --acq_end_p_o                               : out std_logic;
    acq_end_o                                 : out std_logic;
    acq_single_shot_o                         : out std_logic;
    acq_in_pre_trig_o                         : out std_logic;
    acq_in_wait_trig_o                        : out std_logic;
    acq_in_post_trig_o                        : out std_logic;
    acq_pre_trig_done_o                       : out std_logic;
    acq_wait_trig_skip_done_o                 : out std_logic;
    acq_post_trig_done_o                      : out std_logic;
    acq_fsm_state_o                           : out std_logic_vector(2 downto 0);

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
    g_data_width                              : natural := 64;
    g_multishot_ram_size                      : natural := 2048
  );
  port
  (
    fs_clk_i                                  : in std_logic;
    fs_ce_i                                   : in std_logic;
    fs_rst_n_i                                : in std_logic;

    data_i                                    : in std_logic_vector(g_data_width-1 downto 0);
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

    dpram_dout_o                              : out std_logic_vector(g_data_width-1 downto 0);
    dpram_valid_o                             : out std_logic
  );
  end component;

  component acq_fc_fifo
  generic
  (
    g_data_width                              : natural := 64;
    g_addr_width                              : natural := 32;
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
    dpram_data_i                              : in std_logic_vector(g_data_width-1 downto 0);
    dpram_dvalid_i                            : in std_logic;

    -- Passthough data
    pt_data_i                                 : in std_logic_vector(g_data_width-1 downto 0);
    pt_dvalid_i                               : in std_logic;
    pt_wr_en_i                                : in std_logic;

    -- Request transaction reset as soon as possible (when all outstanding
    -- transactions have been commited)
    req_rst_trans_i                           : in std_logic;
    -- select between multi-buffer mode and pass-through mode (data directly
    -- through external module interface)
    passthrough_en_i                          : in std_logic;
    -- which buffer (0 or 1) to store data in. valid only when passthrough_en_i = '0'
    buffer_sel_i                              : in std_logic;

    -- Size of the transaction in g_fifo_size bytes
    lmt_pkt_size_i                       : in unsigned(c_pkt_size_width-1 downto 0); -- t_fc_pkt
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
    fifo_fc_dout_o                            : out std_logic_vector(g_data_width-1 downto 0);
    fifo_fc_valid_o                           : out std_logic;
    fifo_fc_addr_o                            : out std_logic_vector(g_addr_width-1 downto 0);
    fifo_fc_sof_o                             : out std_logic;
    fifo_fc_eof_o                             : out std_logic;
    fifo_fc_dreq_i                            : in std_logic;
    fifo_fc_stall_i                           : in std_logic
  );
  end component;

  component fc_source
  generic
  (
    --g_hold_valid_on_stall                     : boolean := true;
    g_data_width                              : natural := 64;
    g_pkt_size_width                          : natural := 32;
    g_addr_width                              : natural := 32;
    g_pipe_size                               : natural := 4
  --g_pipe_almost_full                        : natural := 3
  );
  port
  (
    clk_i                                     : in std_logic;
    rst_n_i                                   : in std_logic;

    -- Plain Interface
    pl_data_i                                 : in std_logic_vector(g_data_width-1 downto 0);
    pl_addr_i                                 : in std_logic_vector(g_addr_width-1 downto 0);
    pl_valid_i                                : in std_logic;

    pl_dreq_o                                 : out std_logic; -- optional for driving another FC interface
    pl_stall_o                                : out std_logic; -- optional for driving another FC interface
    pl_pkt_sent_o                             : out std_logic; -- optional for knowing the exact time a packet was sent

    pl_rst_trans_i                            : in std_logic;

    -- Limits
    lmt_pkt_size_i                            : in unsigned(c_pkt_size_width-1 downto 0);
    lmt_valid_i                               : in std_logic;

    -- Flow Control Interface
    fc_dout_o                                 : out std_logic_vector(g_data_width-1 downto 0);
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
    --cnt_rst_i                                 : in std_logic;

    -- Size of the transaction in g_fifo_size bytes
    lmt_pkt_size_i                            : in unsigned(c_pkt_size_width-1 downto 0);
    -- Number of shots in this acquisition
    lmt_shots_nb_i                            : in unsigned(c_shots_size_width-1 downto 0);
    -- Acquisition limits valid signal. Qualifies lmt_pkt_size_i and lmt_shots_nb_i
    lmt_valid_i                               : in std_logic
  );
  end component;

  component acq_ddr3_iface
  generic
  (
    g_data_width                              : natural := 64;
    g_addr_width                              : natural := 32;
    -- Do not modify these! As they are dependent of the memory controller generated!
    g_ddr_payload_width                       : natural := 256;
    g_ddr_addr_width                          : natural := 32
  );
  port
  (
    -- DDR3 external clock
    ext_clk_i                                 : in  std_logic;
    ext_rst_n_i                               : in  std_logic;

    -- Flow protocol to interface with external SDRAM. Evaluate the use of
    -- Wishbone Streaming protocol.
    fifo_fc_din_i                             : in std_logic_vector(g_data_width-1 downto 0);
    fifo_fc_valid_i                           : in std_logic;
    fifo_fc_addr_i                            : in std_logic_vector(g_addr_width-1 downto 0);
    fifo_fc_sof_i                             : in std_logic;
    fifo_fc_eof_i                             : in std_logic;
    fifo_fc_dreq_o                            : out std_logic;
    fifo_fc_stall_o                           : out std_logic;

    wr_start_i                                : in std_logic;
    wr_init_addr_i                            : in std_logic_vector(g_ddr_addr_width-1 downto 0);

    lmt_all_trans_done_p_o                    : out std_logic;
    lmt_rst_i                                 : in std_logic;

    -- Size of the transaction in g_fifo_size bytes
    lmt_pkt_size_i                            : in unsigned(c_pkt_size_width-1 downto 0);
    -- Number of shots in this acquisition
    lmt_shots_nb_i                            : in unsigned(c_shots_size_width-1 downto 0);
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
    g_data_width                              : natural := 64;
    g_addr_width                              : natural := 32;
    -- Do not modify these! As they are dependent of the memory controller generated!
    g_ddr_payload_width                       : natural := 256;
    g_ddr_addr_width                          : natural := 32
  );
  port
  (
    -- DDR3 external clock
    ext_clk_i                                 : in  std_logic;
    ext_rst_n_i                               : in  std_logic;

    -- Flow protocol to interface with external SDRAM. Evaluate the use of
    -- Wishbone Streaming protocol.
    fifo_fc_din_o                             : out std_logic_vector(g_data_width-1 downto 0);
    fifo_fc_valid_o                           : out std_logic;
    fifo_fc_addr_o                            : out std_logic_vector(g_addr_width-1 downto 0);
    fifo_fc_sof_o                             : out std_logic; -- ignored
    fifo_fc_eof_o                             : out std_logic; -- ignored
    fifo_fc_dreq_i                            : in std_logic;  -- ignored
    fifo_fc_stall_i                           : in std_logic;  -- ignored

    rb_start_i                                : in std_logic;
    rb_init_addr_i                            : in std_logic_vector(g_ddr_addr_width-1 downto 0);

    lmt_all_trans_done_p_o                    : out std_logic;
    lmt_rst_i                                 : in std_logic;

    -- Size of the transaction in g_fifo_size bytes
    lmt_pkt_size_i                            : in unsigned(c_pkt_size_width-1 downto 0); -- t_fc_pkt
    -- Number of shots in this acquisition
    lmt_shots_nb_i                            : in unsigned(c_shots_size_width-1 downto 0);
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
    device_id     => x"1bafbf1e",
    version       => x"00000001",
    date          => x"20131011",
    name          => "LNLS_BPM_ACQ_CORE  ")));

end acq_core_pkg;
