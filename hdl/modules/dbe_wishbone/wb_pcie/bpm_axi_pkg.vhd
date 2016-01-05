library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

package bpm_axi_pkg is

  -- AXIMM constants
  constant c_aximm_id_width                  : natural := 4;
  constant c_aximm_addr_width                : natural := 32;
  constant c_aximm_len_width                 : natural := 8;
  constant c_aximm_size_width                : natural := 3;
  constant c_aximm_burst_width               : natural := 2;
  constant c_aximm_cache_width               : natural := 4;
  constant c_aximm_prot_width                : natural := 3;
  constant c_aximm_qos_width                 : natural := 4;
  constant c_aximm_data_width                : natural := 256;
  constant c_aximm_strb_width                : natural := c_aximm_data_width/8;
  constant c_aximm_resp_width                : natural := 2;

  -- AXIS STS constants
  constant c_axis_sts_tdata_width            : natural := 8;
  constant c_axis_sts_tkeep_width            : natural := c_axis_sts_tdata_width/8;

  -- AXIS CMD constants
  constant c_axis_cmd_tdata_width            : natural := 72;
  constant c_axis_cmd_tkeep_width            : natural := c_axis_cmd_tdata_width/8;

  -- CMD Data Ranges
  constant c_axis_cmd_tdata_btt_width        : natural := 23;
  constant c_axis_cmd_tdata_type_width       : natural := 1;
  constant c_axis_cmd_tdata_dsa_width        : natural := 6;
  constant c_axis_cmd_tdata_last_width       : natural := 1;
  constant c_axis_cmd_tdata_drr_width        : natural := 1;
  constant c_axis_cmd_tdata_addr_width       : natural := 32;
  constant c_axis_cmd_tdata_tag_width        : natural := 4;
  constant c_axis_cmd_tdata_pad_width        : natural := 4;

  constant c_axis_cmd_tdata_btt_bot_idx      : natural := 0;
  constant c_axis_cmd_tdata_btt_top_idx      : natural := c_axis_cmd_tdata_btt_bot_idx + c_axis_cmd_tdata_btt_width - 1;
  constant c_axis_cmd_tdata_type_idx         : natural := c_axis_cmd_tdata_btt_top_idx + 1;
  constant c_axis_cmd_tdata_dsa_bot_idx      : natural := c_axis_cmd_tdata_type_idx + 1;
  constant c_axis_cmd_tdata_dsa_top_idx      : natural := c_axis_cmd_tdata_dsa_bot_idx + c_axis_cmd_tdata_dsa_width - 1;
  constant c_axis_cmd_tdata_last_idx         : natural := c_axis_cmd_tdata_dsa_top_idx + 1;
  constant c_axis_cmd_tdata_drr_idx          : natural := c_axis_cmd_tdata_last_idx + 1;
  constant c_axis_cmd_tdata_addr_bot_idx     : natural := c_axis_cmd_tdata_drr_idx + 1;
  constant c_axis_cmd_tdata_addr_top_idx     : natural := c_axis_cmd_tdata_addr_bot_idx + c_axis_cmd_tdata_addr_width - 1;
  constant c_axis_cmd_tdata_tag_bot_idx      : natural := c_axis_cmd_tdata_addr_top_idx + 1;
  constant c_axis_cmd_tdata_tag_top_idx      : natural := c_axis_cmd_tdata_tag_bot_idx + c_axis_cmd_tdata_tag_width - 1;
  constant c_axis_cmd_tdata_pad_bot_idx      : natural := c_axis_cmd_tdata_tag_top_idx + 1;
  constant c_axis_cmd_tdata_pad_top_idx      : natural := c_axis_cmd_tdata_pad_bot_idx + c_axis_cmd_tdata_pad_width - 1;

  -- AXIS PAYLOAD constants
  constant c_axis_pld_tdata_width            : natural := 256;
  constant c_axis_pld_tkeep_width            : natural := c_axis_pld_tdata_width/8;

  -- Dummy constants
  constant c_axi_sl_zero                     : std_logic := '0';
  constant c_axi_slv_zero                    : std_logic_vector(0 downto 0) := "0";
  constant c_axi_qos_zeros                   : std_logic_vector(c_aximm_qos_width-1 downto 0) := (others => '0');
  constant c_axi_sl_one                      : std_logic := '1';

  -- AXIMM subtypes
  subtype t_aximm_id is
    std_logic_vector(c_aximm_id_width-1 downto 0);
  subtype t_aximm_addr is
    std_logic_vector(c_aximm_addr_width-1 downto 0);
  subtype t_aximm_len is
    std_logic_vector(c_aximm_len_width-1 downto 0);
  subtype t_aximm_size is
    std_logic_vector(c_aximm_size_width-1 downto 0);
  subtype t_aximm_burst is
    std_logic_vector(c_aximm_burst_width-1 downto 0);
  subtype t_aximm_cache is
    std_logic_vector(c_aximm_cache_width-1 downto 0);
  subtype t_aximm_prot is
    std_logic_vector(c_aximm_prot_width-1 downto 0);
  subtype t_aximm_qos is
    std_logic_vector(c_aximm_qos_width-1 downto 0);
  subtype t_aximm_data is
    std_logic_vector(c_aximm_data_width-1 downto 0);
  subtype t_aximm_strb is
    std_logic_vector(c_aximm_strb_width-1 downto 0);
  subtype t_aximm_resp is
    std_logic_vector(c_aximm_resp_width-1 downto 0);

  type t_aximm_id_array is array(natural range <>) of t_aximm_id;
  type t_aximm_addr_array is array(natural range <>) of t_aximm_addr;
  type t_aximm_len_array is array(natural range <>) of t_aximm_len;
  type t_aximm_size_array is array(natural range <>) of t_aximm_size;
  type t_aximm_burst_array is array(natural range <>) of t_aximm_burst;
  type t_aximm_cache_array is array(natural range <>) of t_aximm_cache;
  type t_aximm_prot_array is array(natural range <>) of t_aximm_prot;
  type t_aximm_qos_array is array(natural range <>) of t_aximm_qos;
  type t_aximm_data_array is array(natural range <>) of t_aximm_data;
  type t_aximm_strb_array is array(natural range <>) of t_aximm_strb;
  type t_aximm_resp_array is array(natural range <>) of t_aximm_resp;

  -- AXI STS subtypes
  subtype t_axis_sts_tdata is
    std_logic_vector(c_axis_sts_tdata_width-1 downto 0);
  subtype t_axis_sts_tkeep is
    std_logic_vector(c_axis_sts_tkeep_width-1 downto 0);

  type t_axis_sts_tdata_array is array(natural range <>) of t_axis_sts_tdata;
  type t_axis_sts_tkeep_array is array(natural range <>) of t_axis_sts_tkeep;

  -- AXI CMD subtypes
  subtype t_axis_cmd_tdata is
    std_logic_vector(c_axis_cmd_tdata_width-1 downto 0);
  subtype t_axis_cmd_tkeep is
    std_logic_vector(c_axis_cmd_tkeep_width-1 downto 0);

  type t_axis_cmd_tdata_array is array(natural range <>) of t_axis_cmd_tdata;
  type t_axis_cmd_tkeep_array is array(natural range <>) of t_axis_cmd_tkeep;

  -- AXI PLD subtypes
  subtype t_axis_pld_tdata is
    std_logic_vector(c_axis_pld_tdata_width-1 downto 0);
  subtype t_axis_pld_tkeep is
    std_logic_vector(c_axis_pld_tkeep_width-1 downto 0);

  type t_axis_pld_tdata_array is array(natural range <>) of t_axis_pld_tdata;
  type t_axis_pld_tkeep_array is array(natural range <>) of t_axis_pld_tkeep;

  -- AXIMM records
  type t_aximm_r_slave_out is record
    arready  : std_logic;
    rid      : t_aximm_id;
    rdata    : t_aximm_data;
    rresp    : t_aximm_resp;
    rlast    : std_logic;
    rvalid   : std_logic;
  end record t_aximm_r_slave_out;

  subtype t_aximm_r_master_in is t_aximm_r_slave_out;

  type t_aximm_w_slave_out is record
    awready  : std_logic;
    wready   : std_logic;
    bid      : t_aximm_id;
    bresp    : t_aximm_resp;
    bvalid   : std_logic;
  end record t_aximm_w_slave_out;

  subtype t_aximm_w_master_in is t_aximm_w_slave_out;

  type t_aximm_r_slave_in is record
    arid     : t_aximm_id;
    araddr   : t_aximm_addr;
    arlen    : t_aximm_len;
    arsize   : t_aximm_size;
    arburst  : t_aximm_burst;
    arlock   : std_logic;
    arcache  : t_aximm_cache;
    arprot   : t_aximm_prot;
    arqos    : t_aximm_qos;
    arvalid  : std_logic;
    rready   : std_logic;
  end record t_aximm_r_slave_in;

  subtype t_aximm_r_master_out is t_aximm_r_slave_in;

  type t_aximm_w_slave_in is record
    awid     : t_aximm_id;
    awaddr   : t_aximm_addr;
    awlen    : t_aximm_len;
    awsize   : t_aximm_size;
    awburst  : t_aximm_burst;
    awlock   : std_logic;
    awcache  : t_aximm_cache;
    awprot   : t_aximm_prot;
    awqos    : t_aximm_qos;
    awvalid  : std_logic;
    wdata    : t_aximm_data;
    wstrb    : t_aximm_strb;
    wlast    : std_logic;
    wvalid   : std_logic;
    bready   : std_logic;
  end record t_aximm_w_slave_in;

  subtype t_aximm_w_master_out is t_aximm_w_slave_in;

  -- AXIMM Array declarations
  type t_aximm_r_slave_out_array is array(natural range <>) of t_aximm_r_slave_out;
  subtype t_aximm_r_master_in_array is t_aximm_r_slave_out_array;
  type t_aximm_w_slave_out_array is array(natural range <>) of t_aximm_w_slave_out;
  subtype t_aximm_w_master_in_array is t_aximm_w_slave_out_array;
  type t_aximm_r_slave_in_array  is array(natural range <>) of t_aximm_r_slave_in;
  subtype t_aximm_r_master_out_array is t_aximm_r_slave_in_array;
  type t_aximm_w_slave_in_array is array(natural range <>) of t_aximm_w_slave_in;
  subtype t_aximm_w_master_out_array is t_aximm_w_slave_in_array;

  -- AXIS STS records
  type t_axis_sts_slave_out is record
    tready  : std_logic;
  end record t_axis_sts_slave_out;

  subtype t_axis_sts_master_in is t_axis_sts_slave_out;

  type t_axis_sts_slave_in is record
    tvalid : std_logic;
    tdata  : t_axis_sts_tdata;
    tkeep  : t_axis_sts_tkeep;
    tlast  : std_logic;
  end record t_axis_sts_slave_in;

  subtype t_axis_sts_master_out is t_axis_sts_slave_in;

  -- AXIS STS Array declarations
  type t_axis_sts_slave_out_array is array(natural range <>) of t_axis_sts_slave_out;
  subtype t_axis_sts_master_in_array is t_axis_sts_slave_out_array;
  type t_axis_sts_slave_in_array is array(natural range <>) of t_axis_sts_slave_in;
  subtype t_axis_sts_master_out_array is t_axis_sts_slave_in_array;

  -- AXIS CMD records
  type t_axis_cmd_slave_out is record
    tready  : std_logic;
  end record t_axis_cmd_slave_out;

  subtype t_axis_cmd_master_in is t_axis_cmd_slave_out;

  type t_axis_cmd_slave_in is record
    tvalid : std_logic;
    tdata  : t_axis_cmd_tdata;
    tkeep  : t_axis_cmd_tkeep;
    tlast  : std_logic;
  end record t_axis_cmd_slave_in;

  subtype t_axis_cmd_master_out is t_axis_cmd_slave_in;

  -- AXIS CMD Array declarations
  type t_axis_cmd_slave_out_array is array(natural range <>) of t_axis_cmd_slave_out;
  subtype t_axis_cmd_master_in_array is t_axis_cmd_slave_out_array;
  type t_axis_cmd_slave_in_array is array(natural range <>) of t_axis_cmd_slave_in;
  subtype t_axis_cmd_master_out_array is t_axis_cmd_slave_in_array;

  -- AXIS PLD records
  type t_axis_pld_slave_out is record
    tready  : std_logic;
  end record t_axis_pld_slave_out;

  subtype t_axis_pld_master_in is t_axis_pld_slave_out;

  type t_axis_pld_slave_in is record
    tvalid : std_logic;
    tdata  : t_axis_pld_tdata;
    tkeep  : t_axis_pld_tkeep;
    tlast  : std_logic;
  end record t_axis_pld_slave_in;

  subtype t_axis_pld_master_out is t_axis_pld_slave_in;

  -- AXIS PLD Array declarations
  type t_axis_pld_slave_out_array is array(natural range <>) of t_axis_pld_slave_out;
  subtype t_axis_pld_master_in_array is t_axis_pld_slave_out_array;
  type t_axis_pld_slave_in_array is array(natural range <>) of t_axis_pld_slave_in;
  subtype t_axis_pld_master_out_array is t_axis_pld_slave_in_array;

  -- AXIMM dummy constants
  constant cc_dummy_aximm_id : std_logic_vector(c_aximm_id_width-1 downto 0) :=
    (others => 'X');
  constant cc_dummy_aximm_addr : std_logic_vector(c_aximm_addr_width-1 downto 0) :=
    (others => 'X');
  constant cc_dummy_aximm_len : std_logic_vector(c_aximm_len_width-1 downto 0) :=
    (others => 'X');
  constant cc_dummy_aximm_size : std_logic_vector(c_aximm_size_width-1 downto 0) :=
    (others => 'X');
  constant cc_dummy_aximm_burst : std_logic_vector(c_aximm_burst_width-1 downto 0) :=
    (others => 'X');
  constant cc_dummy_aximm_cache : std_logic_vector(c_aximm_cache_width-1 downto 0) :=
    (others => 'X');
  constant cc_dummy_aximm_prot : std_logic_vector(c_aximm_prot_width-1 downto 0) :=
    (others => 'X');
  constant cc_dummy_aximm_qos : std_logic_vector(c_aximm_qos_width-1 downto 0) :=
    (others => 'X');
  constant cc_dummy_aximm_data : std_logic_vector(c_aximm_data_width-1 downto 0) :=
    (others => 'X');
  constant cc_dummy_aximm_strb : std_logic_vector(c_aximm_strb_width-1 downto 0) :=
    (others => 'X');
  constant cc_dummy_aximm_resp : std_logic_vector(c_aximm_resp_width-1 downto 0) :=
    (others => 'X');
  constant cc_dummy_aximm_tready : std_logic := 'X';

  constant cc_dummy_aximm_r_master_in : t_aximm_r_master_in := ('X', cc_dummy_aximm_id,
    cc_dummy_aximm_data, cc_dummy_aximm_resp, 'X', '0');
  constant cc_dummy_aximm_w_master_in : t_aximm_w_master_in := ('X', 'X', cc_dummy_aximm_id,
    cc_dummy_aximm_resp, '0');

  constant cc_dummy_aximm_r_slave_in : t_aximm_r_slave_in :=
    (cc_dummy_aximm_id, cc_dummy_aximm_addr, cc_dummy_aximm_len, cc_dummy_aximm_size, cc_dummy_aximm_burst,
    'X',  cc_dummy_aximm_cache, cc_dummy_aximm_prot, cc_dummy_aximm_qos, '0', 'X');
  constant cc_dummy_aximm_w_slave_in : t_aximm_w_slave_in :=
    (cc_dummy_aximm_id, cc_dummy_aximm_addr, cc_dummy_aximm_len, cc_dummy_aximm_size, cc_dummy_aximm_burst,
    'X',  cc_dummy_aximm_cache, cc_dummy_aximm_prot, cc_dummy_aximm_qos, '0', cc_dummy_aximm_data,
    cc_dummy_aximm_strb, 'X', '0', 'X');

  -- AXIS STS dummy constants
  constant cc_dummy_axis_sts_tdata : std_logic_vector(c_axis_sts_tdata_width-1 downto 0) :=
    (others => 'X');
  constant cc_dummy_axis_sts_tkeep : std_logic_vector(c_axis_sts_tkeep_width-1 downto 0) :=
    (others => 'X');

  constant cc_dummy_axis_sts_slave_in : t_axis_sts_slave_in :=
    ('0', cc_dummy_axis_sts_tdata, cc_dummy_axis_sts_tkeep, 'X');
  constant cc_dummy_axis_sts_master_in : t_axis_sts_master_in := (tready => 'X');

  -- AXIS CMD dummy constants
  constant cc_dummy_axis_cmd_tdata : std_logic_vector(c_axis_cmd_tdata_width-1 downto 0) :=
    (others => 'X');
  constant cc_dummy_axis_cmd_tkeep : std_logic_vector(c_axis_cmd_tkeep_width-1 downto 0) :=
    (others => 'X');

  constant cc_dummy_axis_cmd_slave_in : t_axis_cmd_slave_in :=
    ('0', cc_dummy_axis_cmd_tdata, cc_dummy_axis_cmd_tkeep, 'X');
  constant cc_dummy_axis_cmd_master_in : t_axis_cmd_master_in := (tready => 'X');

  -- AXIS PLD dummy constants
  constant cc_dummy_axis_pld_tdata : std_logic_vector(c_axis_pld_tdata_width-1 downto 0) :=
    (others => 'X');
  constant cc_dummy_axis_pld_tkeep : std_logic_vector(c_axis_pld_tkeep_width-1 downto 0) :=
    (others => 'X');

  constant cc_dummy_axis_pld_slave_in : t_axis_pld_slave_in :=
    ('0', cc_dummy_axis_pld_tdata, cc_dummy_axis_pld_tkeep, 'X');
  constant cc_dummy_axis_pld_master_in : t_axis_pld_master_in := (tready => 'X');

end bpm_axi_pkg;
