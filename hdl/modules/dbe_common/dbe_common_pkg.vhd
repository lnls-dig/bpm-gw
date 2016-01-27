library ieee;
use ieee.std_logic_1164.all;

package dbe_common_pkg is

  --------------------------------------------------------------------
  -- Components
  --------------------------------------------------------------------

  component reset_synch
  generic
  (
    -- Select 1 for no pipeline, and greater than 1 to insert
    -- pipeline stages
    g_pipeline                             : natural := 4
  );
  port
  (
    clk_i                                  : in  std_logic;
    arst_n_i                               : in  std_logic;
    rst_n_o                                : out std_logic
  );
  end component;

  component pulse2level
  port
  (
    clk_i                                  : in std_logic;
    rst_n_i                                : in std_logic;

    -- Pulse input
    pulse_i                                : in std_logic;
    -- Clear level
    clr_i                                  : in std_logic;
    -- Level output
    level_o                                : out std_logic
  );
  end component;


  component trigger_rcv
    generic (
      g_glitch_len_width : positive;
      g_pulse_width      : positive);
    port (
      clk_i   : in  std_logic;
      rst_i   : in  std_logic;
      len_i   : in  std_logic_vector(g_glitch_len_width-1 downto 0);
      data_i  : in  std_logic;
      pulse_o : out std_logic);
  end component;

component extend_pulse_dyn

  generic (
    -- output pulse width in clk_i cycles
    g_max_width : natural
    );
  port (
    clk_i         : in  std_logic;
    rst_n_i       : in  std_logic;
    pulse_i       : in  std_logic;
    pulse_width_i : in  natural;
    -- extended output pulse
    extended_o    : out std_logic);
end component;
  
end dbe_common_pkg;
