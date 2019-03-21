library UNISIM;
use UNISIM.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;

entity clk_gen_mgt is
port(
  sys_clk_p_i                               : in std_logic;
  sys_clk_n_i                               : in std_logic;
  sys_clk_o                                 : out std_logic;
  sys_clk_bufg_o                            : out std_logic
);
end clk_gen_mgt;

architecture syn of clk_gen_mgt is

  -- Internal clock signal
  signal s_sys_clk                          : std_logic;
  signal s_sys_clk_ibuf_p                   : std_logic;
  signal s_sys_clk_ibuf_n                   : std_logic;

begin

  cmp_ibuf_clk_gen_mgt_p : IBUF
  generic map (
    IBUF_LOW_PWR                            => TRUE,                 -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
    IOSTANDARD                              => "DEFAULT"
  )
  port map (
    O                                       => s_sys_clk_ibuf_p,     -- Buffer output
    I                                       => sys_clk_p_i           -- Buffer input (connect directly to top-level port)
  );

  cmp_ibuf_clk_gen_mgt_n : IBUF
  generic map (
    IBUF_LOW_PWR                            => TRUE,                 -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
    IOSTANDARD                              => "DEFAULT"
  )
  port map (
    O                                       => s_sys_clk_ibuf_n,     -- Buffer output
    I                                       => sys_clk_n_i           -- Buffer input (connect directly to top-level port)
  );

  cpm_ibufgds_clk_gen_mgt : IBUFDS_GTE2
  port map (
    O                                       => s_sys_clk,  -- Clock buffer output
    ODIV2                                   => open,
    CEB                                     => '0',
    I                                       => s_sys_clk_ibuf_p,     -- Diff_p clock buffer input (connect directly to top-level port)
    IB                                      => s_sys_clk_ibuf_n      -- Diff_n clock buffer input (connect directly to top-level port)
  );

  sys_clk_o <= s_sys_clk;

  cmp_bufg_clk_gen_mgt : BUFG
  port map (
    O                                       => sys_clk_bufg_o, -- 1-bit output: Clock buffer output
    I                                       => s_sys_clk  -- 1-bit input: Clock buffer input
  );

end syn;
