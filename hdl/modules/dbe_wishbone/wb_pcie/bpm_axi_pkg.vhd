library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

package bpm_axi_pkg is

  constant c_aximm_id_width                 : integer := 1;
  constant c_aximm_addr_width               : integer := 32;
  constant c_aximm_len_width                : integer := 8;
  constant c_aximm_size_width               : integer := 3;
  constant c_aximm_burst_width              : integer := 2;
  constant c_aximm_cache_width              : integer := 4;
  constant c_aximm_prot_width               : integer := 3;
  constant c_aximm_qos_width                : integer := 4;
  constant c_aximm_data_width               : integer := 256;
  constant c_aximm_strb_width               : integer := c_aximm_data_width/8;
  constant c_aximm_resp_width               : integer := 2;

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

  type t_aximm_slave_out is record
    awready  : std_logic;
    wready   : std_logic;
    bid      : t_aximm_id;
    bresp    : t_aximm_resp;
    bvalid   : std_logic;
    arready  : std_logic;
    rid      : t_aximm_id;
    rdata    : t_aximm_data;
    rresp    : t_aximm_resp;
    rlast    : std_logic;
    rvalid   : std_logic;
  end record t_aximm_slave_out;

  subtype t_aximm_master_in is t_aximm_slave_out;

  type t_aximm_slave_in is record
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
  end record t_aximm_slave_in;

  subtype t_aximm_master_out is t_aximm_slave_in;

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

  constant cc_dummy_aximm_slave_in : t_aximm_slave_in :=
    (cc_dummy_aximm_id, cc_dummy_aximm_addr, cc_dummy_aximm_len, cc_dummy_aximm_size, cc_dummy_aximm_burst,
    'X',  cc_dummy_aximm_cache, cc_dummy_aximm_prot, cc_dummy_aximm_qos, '0', cc_dummy_aximm_data,
    cc_dummy_aximm_strb, 'X', '0', 'X', cc_dummy_aximm_id, cc_dummy_aximm_addr, cc_dummy_aximm_len,
    cc_dummy_aximm_size, cc_dummy_aximm_burst, 'X', cc_dummy_aximm_cache, cc_dummy_aximm_prot, cc_dummy_aximm_qos,
    '0', 'X');
  constant cc_dummy_aximm_master_in : t_aximm_master_in := ('X', 'X', cc_dummy_aximm_id,
    cc_dummy_aximm_resp, '0', 'X', cc_dummy_aximm_id, cc_dummy_aximm_data, cc_dummy_aximm_resp,
    cc_dummy_aximm_last, '0');

end bpm_axi_pkg;
