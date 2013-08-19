library ieee;
use ieee.std_logic_1164.all;

package dbe_common_pkg is

    --------------------------------------------------------------------
    -- Components
    --------------------------------------------------------------------

    component reset_synch
    port
    (
        clk_i                     : in  std_logic;
        arst_n_i                : in  std_logic;
        rst_n_o                  : out std_logic
    );
    end component;

end dbe_common_pkg;
