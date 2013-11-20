-- Simple IRQ Manager
-- Based on the original design by:
--    
-- Fabrice Mousset (fabrice.mousset@laposte.net)
-- Project       :  Wishbone Interruption Manager (ARMadeus wishbone example)

-- See: http://www.armadeus.com/wiki/index.php?title=A_simple_design_with_Wishbone_bus

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.wishbone_pkg.all;
use work.gencores_pkg.all;

entity xwb_irq_mngr is
    generic(
        g_irq_count                    : integer := 16;
        g_irq_level                 : std_logic := '1';
        g_interface_mode            : t_wishbone_interface_mode      := CLASSIC;
        g_address_granularity       : t_wishbone_address_granularity := BYTE
    );
    port(
        -- Global Signals
        clk_sys_i                     : in std_logic;
        rst_n_i                       : in std_logic;
      
        -- Wishbone interface signals
        slave_i                     : in  t_wishbone_slave_in;
        slave_o                     : out t_wishbone_slave_out;
    
        -- irq from other IP
        irq_req_i                    : in  std_logic_vector(g_irq_count-1 downto 0);
      
        -- Component external signals
        irq_req_o                   : out std_logic
    );
end entity;
    
architecture rtl of xwb_irq_mngr is

    component wb_irq_mngr
    generic(
        g_irq_count                    : integer := 16;
        g_irq_level                 : std_logic := '1';
        g_interface_mode            : t_wishbone_interface_mode      := CLASSIC;
        g_address_granularity       : t_wishbone_address_granularity := BYTE
    );
    port(
        -- Global Signals
        clk_sys_i                     : in std_logic;
        rst_n_i                       : in std_logic;
      
        -- Wishbone interface signals
        wb_sel_i                    : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0);
        wb_cyc_i                    : in  std_logic;
        wb_stb_i                    : in  std_logic;
        wb_we_i                     : in  std_logic;
        wb_adr_i                    : in  std_logic_vector(c_wishbone_data_width-1 downto 0);
        wb_dat_i                    : in  std_logic_vector(c_wishbone_data_width-1 downto 0);
        wb_dat_o                    : out std_logic_vector(c_wishbone_data_width-1 downto 0);
        wb_ack_o                    : out std_logic;
        wb_stall_o                  : out std_logic;
        --slave_i                     : in  t_wishbone_slave_in;
        --slave_o                     : out t_wishbone_slave_out;
    
        -- irq from other IP
        irq_req_i                    : in  std_logic_vector(g_irq_count-1 downto 0);
      
        -- Component external signals
        irq_req_o                   : out std_logic
    );
    end component;

begin

    cmp_wrapped_irq_mngr : wb_irq_mngr
    generic map (
        g_irq_count                    => g_irq_count,            
        g_irq_level                 => g_irq_level,
        g_interface_mode            => g_interface_mode,     
        g_address_granularity       => g_address_granularity
    )
    port map (
        clk_sys_i                   => clk_sys_i,
        rst_n_i                     => rst_n_i,
        wb_sel_i                    => slave_i.sel,
        wb_cyc_i                    => slave_i.cyc,
        wb_stb_i                    => slave_i.stb,
        wb_we_i                     => slave_i.we,
        wb_adr_i                    => slave_i.adr,
        wb_dat_i                    => slave_i.dat,
        wb_dat_o                    => slave_o.dat,
        wb_ack_o                    => slave_o.ack,
        wb_stall_o                  => slave_o.stall,
        
        irq_req_i                   => irq_req_i,
        irq_req_o                   => irq_req_o
    );

    slave_o.err   <= '0';
    slave_o.int   <= '0';
    slave_o.rty   <= '0';
    
end rtl;
