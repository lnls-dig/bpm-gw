------------------------------------------------------------------------------
-- dma_if.vhd - entity/architecture pair
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wishbone_pkg.all;
use work.custom_wishbone_pkg.all;

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------

entity xwb_dma_interface is
    port(
        -- Asynchronous Reset signal
        arst_n_i                               : in std_logic;
        
        -- Write Domain Clock        
        dma_clk_i                             : in  std_logic;
        --dma_valid_o                            : out std_logic;
        --dma_data_o                             : out std_logic_vector(C_NBITS_DATA_INPUT-1 downto 0);
        --dma_be_o                               : out std_logic_vector(C_NBITS_DATA_INPUT/8 - 1 downto 0);
        --dma_last_o                             : out std_logic;
        --dma_ready_i                            : in  std_logic;
     
        -- Slave Data Flow port
        --dma_dflow_slave_i                   : in  t_wishbone_dflow_slave_in;
        --dma_dflow_slave_o                   : out t_wishbone_dflow_slave_out;
        dma_slave_i                         : in  t_wishbone_slave_in;
        dma_slave_o                         : out t_wishbone_slave_out;
        
        -- Slave Data Input Port
        --data_slave_i                         : in  t_wishbone_slave_in;
        --data_slave_o                         : out t_wishbone_slave_out;
        data_clk_i                               : in std_logic;
        data_i                                   : in std_logic_vector(c_wishbone_data_width-1 downto 0);
        data_valid_i                        : in std_logic;
        data_ready_o                        : out std_logic;
        
        -- Slave control port. use wbgen2 tool or not if it is simple.
        --control_slave_i                         : in  t_wishbone_slave_in;
        --control_slave_o                         : out t_wishbone_slave_out;
        capture_ctl_i                           : in std_logic_vector(c_wishbone_data_width-1 downto 0);
        dma_complete_o                        : out std_logic;
        dma_ovf_o                            : out std_logic

        -- Debug Signals
        --dma_debug_clk_o                           : out std_logic;
        --dma_debug_data_o                          : out std_logic_vector(255 downto 0);
        --dma_debug_trigger_o                       : out std_logic_vector(15 downto 0)
    );
end xwb_dma_interface;

architecture rtl of xwb_dma_interface is
begin

    cmp_wb_dma_interface : wb_dma_interface
    port map(
        -- Asynchronous Reset signal
        arst_n_i                               => arst_n_i,
        
        -- Write Domain Clock        
        dma_clk_i                             => dma_clk_i,
        --dma_valid_o                            : out std_logic;
        --dma_data_o                             : out std_logic_vector(C_NBITS_DATA_INPUT-1 downto 0);
        --dma_be_o                               : out std_logic_vector(C_NBITS_DATA_INPUT/8 - 1 downto 0);
        --dma_last_o                             : out std_logic;
        --dma_ready_i                            : in  std_logic;
     
        -- Slave Data Flow port
        --dma_dflow_slave_i                   : in  t_wishbone_dflow_slave_in;
        --dma_dflow_slave_o                   : out t_wishbone_dflow_slave_out;
        wb_sel_i                            => dma_slave_i.sel,
        wb_cyc_i                            => dma_slave_i.cyc,
        wb_stb_i                            => dma_slave_i.stb,
        wb_we_i                             => dma_slave_i.we,
        wb_adr_i                            => dma_slave_i.adr,
        wb_dat_i                            => dma_slave_i.dat,
        --wb_cti_i                            => dma_dflow_slave_i.cti,
        --wb_bte_i                            => dma_dflow_slave_i.bte,
        wb_dat_o                            => dma_slave_o.dat,
        wb_ack_o                            => dma_slave_o.ack,
        wb_stall_o                          => dma_slave_o.stall,
        
        -- Slave Data Input Port
        --data_slave_i                         : in  t_wishbone_slave_in;
        --data_slave_o                         : out t_wishbone_slave_out;
        data_clk_i                               => data_clk_i,    
        data_i                                   => data_i,      
        data_valid_i                        => data_valid_i,
        data_ready_o                        => data_ready_o,
        
        -- Slave control port. use wbgen2 tool or not if it is simple.
        --control_slave_i                         : in  t_wishbone_slave_in;
        --control_slave_o                         : out t_wishbone_slave_out;
        capture_ctl_i                           => capture_ctl_i,
        dma_complete_o                        => dma_complete_o,    
        dma_ovf_o                            => dma_ovf_o    

        -- Debug Signals
        --dma_debug_clk_o                           : out std_logic;
        --dma_debug_data_o                          : out std_logic_vector(255 downto 0);
        --dma_debug_trigger_o                       : out std_logic_vector(15 downto 0)
    );
    
    dma_slave_o.rty                   <= '0';
    dma_slave_o.err                   <= '0';
    dma_slave_o.int                   <= '0';
end rtl;
