------------------------------------------------------------------------------
-- dma_if.vhd - entity/architecture pair
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.genram_pkg.all;
use work.gencores_pkg.all;
use work.wishbone_pkg.all;
use work.custom_wishbone_pkg.all;
use work.custom_common_pkg.all;

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------

entity wb_dma_interface is
	port(
        ---------------------
        -- Source Interface
        ---------------------
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
        bytesel_i                                   : in  std_logic;
        dreq_o                                      : out std_logic
        
        ---------------------
        -- Sink Interface
        ---------------------
        clk_i                                       : in std_logic;
        rst_n_i                                     : in std_logic;

        -- Wishbone Fabric Interface I/O
        snk_i                                       : in  t_wbs_sink_in;
        snk_o                                       : out t_wbs_sink_out;

        -- Decoded & buffered fabric
        addr_o                                      : out std_logic_vector(c_wbs_address_width-1 downto 0);
        data_o                                      : out std_logic_vector(c_wbs_data_width-1 downto 0);
        dvalid_o                                    : out std_logic;
        sof_o                                       : out std_logic;
        eof_o                                       : out std_logic;
        error_o                                     : out std_logic;
        bytesel_o                                   : out std_logic;
        dreq_i                                      : in  std_logic
	);
end wb_dma_interface;

architecture rtl of wb_dma_interface is
	--constant C_DATA_SIZE					: natural := 32;
	--constant C_OVF_COUNTER_SIZE			: natural := 10;
	-- FIFO signals index 	
	--constant c_X_DATA						: natural := 3;
	--constant c_Y_DATA						: natural := 2;
	--constant c_Z_DATA						: natural := 1;
	--constant c_W_DATA						: natural := 0;
    -- Fifo Depth = 8K words * 32 bits/word
    constant c_fifo_size                    : natural := 1024;
    
    -- Register definition
    constant c_FIFO_REG                     : std_logic_vector(2 downto 0) := "000";
    
    ------------------------------------------
	-- Wishbone and Finite State Machine Signals
	------------------------------------------
    --type t_wishbone_state is (IDLE, CLASSIC, CABURST, EOBURST);
    
    --signal wb_state                          : t_wishbone_state := IDLE;  
    
    signal cycle_progress                    : std_logic;
    signal read_cycle_progress               : std_logic;
    signal write_cycle_progress              : std_logic;
    signal ack_int                           : std_logic;
    signal stall_int                         : std_logic;
	
	------------------------------------------
	-- FIFO Signals
	------------------------------------------
	subtype fifo_data is std_logic_vector(c_wishbone_data_width downto 0);
	--subtype fifo_count is  std_logic_vector(12 downto 0);
	subtype fifo_ctrl is std_logic;
	
	--signal fifo_do_concat					: std_logic_vector(C_NBITS_VALID_INPUT-1 downto 0);
	signal data_i_d1						: std_logic_vector(c_wishbone_data_width-1 downto 0);

	-- read data_i: 32-bit (each) output: read output data_i
	signal fifo_do 							: fifo_data;
	-- status: 1-bit (each) output: flags and other fifo status outputs
	signal fifo_empty						: fifo_ctrl; 
	signal fifo_full						: fifo_ctrl;
	-- read control signals: 1-bit (each) input: read clock, enable and reset input signals
	signal fifo_rdclk    					: fifo_ctrl;	         
	signal fifo_rden                    	: fifo_ctrl;
	signal fifo_rst_n                  		: fifo_ctrl;
	-- counter fifo signals
	--signal fifo_rd_data_count				: fifo_count;
	--signal fifo_wr_data_count				: fifo_count;
	-- write control signals: 1-bit (each) input: write clock and enable input signals
	signal fifo_wrclk   					: fifo_ctrl;             		
	signal fifo_wren                      	: fifo_ctrl;
	-- write data_i: 32-bit (each) input: write input data_i
	signal fifo_di							: fifo_data;                  
	signal last_data_reg					: std_logic;
	-- Overflow counter. One extra bit for easy overflow detection
	signal s_fifo_ovf_c						: std_logic_vector(g_ovf_counter_width downto 0);
	signal s_fifo_ovf						: std_logic;
  
  ------------------------------------------
  -- Internal Control
  ------------------------------------------
	signal capture_ctl_reg					: std_logic_vector(c_wishbone_data_width-1 downto 0);
	signal start_acq						: std_logic;
	signal start_acq_trig					: std_logic; 
  
  ------------------------------------------
  -- Reset Synch
  ------------------------------------------
	signal data_clk_rst_n           		: std_logic;
	signal dma_clk_rst_n					: std_logic;
  
  ------------------------------------------
  -- DMA output signals
  ------------------------------------------
	-- C_NBITS_DATA_INPUT+1 bits. C_NBITS_DATA_INPUT bits (LSBs) for data_i and 1 bit (MSB) for last data_i bit
	signal dma_data_out0					: std_logic_vector(c_wishbone_data_width downto 0);
	signal dma_valid_out0					: std_logic;
	
	signal dma_data_out1					: std_logic_vector(c_wishbone_data_width downto 0);
	signal dma_valid_out1					: std_logic;
	
	signal dma_data_out2					: std_logic_vector(c_wishbone_data_width downto 0);
	signal dma_valid_out2					: std_logic;
	
	signal dma_data_out3					: std_logic_vector(c_wishbone_data_width downto 0);
	signal dma_valid_out3					: std_logic;
		
	signal dma_valid_s						: std_logic;
	signal dma_ready_s						: std_logic;
	signal dma_last_s						: std_logic;
	signal s_last_data						: std_logic;
	signal dma_valid_reg0					: std_logic;
   
	-- Counter to coordinate the FIFO output - DMA input
	signal output_counter_rd				: std_logic_vector(1 downto 0);
	signal pre_output_counter_wr			: std_logic_vector(1 downto 0);
	
	-- Internal signals
	signal dma_complete_int					: std_logic;
	signal dma_last_int				        : std_logic;
	signal dma_valid_int			        : std_logic;
	signal dma_data_int					    : std_logic_vector(c_wishbone_data_width-1 downto 0);
    
    -- Functions. Improve this function. Not generic.
    function f_end_counter(counter : std_logic_vector(c_wishbone_data_width-1 downto 0))
     return boolean is
    begin
        if counter(c_wishbone_data_width-1) = '1' and 
            unsigned(counter(c_wishbone_data_width-2 downto 0)) = 0 then
            return true;
        else 
            return false;
        end if;
    end f_end_counter;
  
  begin
  
	-- DMA signals glue
	--dma_last_o								<= s_dma_last_glue;
	--dma_valid_o								<= s_dma_valid_glue;	
	--dma_data_o								<= s_dma_data_glue;
	
	-- Debug data_i
	--dma_debug_clk_o    						<= dma_clk_i;
	--
	--dma_debug_trigger_o(15 downto 6)   		<= (others => '0');
	--dma_debug_trigger_o(5)					<= fifo_full(C_W_DATA);
	--dma_debug_trigger_o(4)					<= start_acq_trig;
	--dma_debug_trigger_o(3)					<= capture_ctl_reg(21);
	--dma_debug_trigger_o(2)   				<= dma_ready_i;
	--dma_debug_trigger_o(1)   				<= s_dma_last_glue;
	--dma_debug_trigger_o(0)   				<= s_dma_valid_glue;
	--
	--dma_debug_data_o(255 downto 120) 		<= (others => '0');
	--dma_debug_data_o(119 downto 109)		<= s_fifo_ovf_c(10 downto 0);
	--dma_debug_data_o(108)					<= s_dma_complete;
	--dma_debug_data_o(107)					<= start_acq_trig;
	--dma_debug_data_o(106)					<= fifo_full(C_W_DATA);
	--dma_debug_data_o(105 downto 84)			<= capture_ctl_reg;
	--dma_debug_data_o(83 downto 52) 			<= s_dma_data_glue(31 downto 0);	
	--dma_debug_data_o(51 downto 36) 			<= fifo_do(C_W_DATA)(15 downto 0);-- FIXXXX
	--dma_debug_data_o(35 downto 34) 			<= output_counter_rd;
	--dma_debug_data_o(33 downto 32) 			<= pre_output_counter_wr;
	--dma_debug_data_o(31 downto 19) 			<= fifo_wr_data_count(C_W_DATA);--(5 downto 0);
	--dma_debug_data_o(18 downto  6) 			<= fifo_rd_data_count(C_W_DATA);--(5 downto 0);
	--dma_debug_data_o(5) 					<= dma_ready_s;
	--dma_debug_data_o(4) 					<= dma_valid_reg0;
	--dma_debug_data_o(3) 					<= dma_valid_s;
	--dma_debug_data_o(2) 					<= dma_ready_i;
	--dma_debug_data_o(1) 					<= s_dma_last_glue;
	--dma_debug_data_o(0) 					<= s_dma_valid_glue;
    
    --------------------------------
	-- Wishbone interface instantiation
	--------------------------------
    
    --wb_sel_i                            : in std_logic_vector(c_wishbone_data_width/8-1 downto 0);
    --wb_cyc_i                            : in std_logic;
    --wb_stb_i                            : in std_logic;
    --wb_we_i                             : in std_logic;
    --wb_adr_i                            : in std_logic_vector(c_wishbone_data_width-1 downto 0);
    --wb_dat_i                            : in std_logic_vector(c_wishbone_data_width-1 downto 0);
    --wb_cti_i                            : in std_logic_vector(2 downto 0);
    --wb_bte_i                            : in std_logic_vector(1 downto 0);
    wb_dat_o                            <= dma_data_int;
    wb_ack_o                            <= ack_int;
    wb_stall_o                          <= stall_int;
    
    --FIXXX
    -- Hard-wired slave pins
    --slave_o.ACK   <= slave_o_ACK;
    --slave_o.ERR   <= '0';
    --slave_o.RTY   <= '0';
    --slave_o.STALL <= '0';
    --slave_o.DAT   <= slave_o_DAT;
    
    -- Hard-wired master pins
    --r_master_o.CYC <= r_master_o_CYC;
    --w_master_o.CYC <= w_master_o_CYC;
    --r_master_o.STB <= r_master_o_STB;
    --w_master_o.STB <= w_master_o_STB;
    --r_master_o.ADR <= read_issue_address;
    --w_master_o.ADR <= write_issue_address;
    --r_master_o.SEL <= (others => '1');
    --w_master_o.SEL <= (others => '1');
    --r_master_o.WE  <= '0';
    --w_master_o.WE  <= '1';
    --r_master_o.DAT <= (others => '0');
    --w_master_o.DAT <= ring(index(write_issue_offset));
	
	--------------------------------
	-- Reset Logic		
	--------------------------------
	-- FIFO reset cycle:  RST must be held high for at least three RDCLK clock cycles,
	--	and RDEN must be low for four clock cycles before RST becomes active high, and RDEN 
	-- remains low during this reset cycle.
	
	-- Guarantees the synchronicity with the input clock on reset deassertion
	cmp_reset_synch_dma : reset_synch
	port map(
		clk_i     		    => dma_clk_i,
		arst_n_i		    => arst_n_i,
		rst_n_o      		=> dma_clk_rst_n
	);
	
	cmp_reset_synch_data : reset_synch
	port map(
		clk_i     		    => data_clk_i,
		arst_n_i		    => arst_n_i,
		rst_n_o      		=> data_clk_rst_n
	);
	
	--------------------------------
	-- Start Acquisition logic		
	--------------------------------
	-- Simple trigger detector 0 -> 1 for start_acq.
	-- Synchronize with bus clock data_clk_i might not be the same
    p_start_acq_trig : gc_sync_ffs
    generic map (
        g_sync_edge => "positive")
    port map (
        rst_n_i  => data_clk_rst_n,
        clk_i    => data_clk_i,
        data_i   => start_acq,
        synced_o => start_acq_trig,
        npulse_o => open
    );

   -- MSB bit representing the start acquisition signal
	start_acq							<= capture_ctl_i(c_wishbone_data_width-1);
	
	--------------------------------
	-- Samples Counter Logic		
	--------------------------------
	-- Hold counter for "capture_count" clock cycles
	p_samples_counter : process (data_clk_i, data_clk_rst_n)
	begin
        if data_clk_rst_n = '0' then
			capture_ctl_reg <= (others => '0');
        elsif rising_edge(data_clk_i) then
            -- start counting and stop only when we have input all data to fifos
            if capture_ctl_reg(c_wishbone_data_width-1) = '1' and
                    data_valid_i = '1' and fifo_full = '0' then
                capture_ctl_reg <= std_logic_vector(unsigned(capture_ctl_reg) - 1);
            -- assign only when 0 -> 1 transition of MSB of start_acq. MSB of capture_ctl_reg
            elsif start_acq_trig = '1' then				
                if data_valid_i = '1' then
                    -- MSB of capture_ctl_i might not be 1 by this time. Force to 1 then...
                    capture_ctl_reg <= '1' & std_logic_vector(unsigned(capture_ctl_i(c_wishbone_data_width-2 downto 0)) - 1);
                else		
                    -- Do not decrement now. wait until data_valid is set
                    capture_ctl_reg <= '1' & std_logic_vector(unsigned(capture_ctl_i(c_wishbone_data_width-2 downto 0)));
                end if;
            end if;
        end if;
	end process p_samples_counter;
	
	--------------------------------
	-- DMA Last Data Logic		
	--------------------------------
   
	p_last_data_proc : process(data_clk_i, data_clk_rst_n)
	begin
        if data_clk_rst_n = '0' then
            last_data_reg <= '0';
		elsif rising_edge(data_clk_i) then
            last_data_reg <= s_last_data;
        end if;
	end process p_last_data_proc;
	
	-- bit c_wishbone_data_width-1 = 1 and bits c_wishbone_data_width-2 downto 0 = 0
	s_last_data								<= '1' when 
            f_end_counter(capture_ctl_reg(c_wishbone_data_width-1 downto 0)) and data_valid_i = '1' else '0';
	
	--------------------------------
	-- FIFO Write Enable Logic		
	--------------------------------
	
	p_fifo_wr_en : process(data_clk_i, data_clk_rst_n)
	begin
        if data_clk_rst_n = '0' then
            fifo_wren <= '0';  
            data_i_d1 <= (others => '0');
        elsif rising_edge(data_clk_i) then
		-- We only need to consider one as all FIFOs are synchronized with each other
            if fifo_full = '0' then
                -- input data to fifo only when data is valid
                fifo_wren <= capture_ctl_reg(c_wishbone_data_width-1) and data_valid_i;
            end if;
		
            --Necessary in order to input data to FIFO correctly as fifo_wren is registered
            data_i_d1 <= data_i;
        end if;
	end process p_fifo_wr_en;
    
    
    p_gen_ack : process (dma_clk_i, dma_clk_rst_n)
    begin
        if dma_clk_rst_n = '0' then
            ack_int <= '0';
        elsif rising_edge(dma_clk_i) then
            if cycle_progress = '1' and wb_we_i = '0' and dma_valid_int = '1' then
                ack_int <= '1';
            else 
                ack_int <= '0';
            end if;
        end if;
    end process;
    
    p_gen_stall : process (dma_valid_s)
    begin
        stall_int <= dma_valid_s;
    end process;
    
	--------------------------------
	-- DMA Output Logic		
	--------------------------------
    cycle_progress <= wb_cyc_i and wb_stb_i; --and wb_we_i = '0';
    read_cycle_progress <= cycle_progress and not wb_we_i;
    write_cycle_progress <= cycle_progress and wb_we_i;
	--dma_ready_s <= dma_ready_i or not s_dma_valid_glue;
    dma_ready_s <= read_cycle_progress or not dma_valid_int;
	-- fifo is not empty and dma is ready
	--dma_valid_s <= '0' when fifo_empty = '1' else read_cycle_progress;
    dma_valid_s <= not fifo_empty or read_cycle_progress;
	
	-- We have a 2 output delay for FIFO. That being said, if we have a dma_ready_i signal it will take 2 dma clock cycles
	-- in order to read the data_i from FIFO.
	-- By this time, dma_ready_i might not be set and we have to wait for it. To solve this 2 delay read cycle
	-- it is employed a small 4 position "buffer" to hold the values read from fifo but not yet passed to the DMA.
	-- Note that dma_valid_reg0 is 1 clock cycle delayed in relation to dma_valid_s. That should give time to
	-- FIFO output the data_i requested. Also not that that difference between pre_output_counter_wr and output_counter_rd
	-- is at most (at any given point in time) not greater than 2. Thus, with a 2 bit counter, we will not have overflow
	p_dma_pre_output : process(dma_clk_i, dma_clk_rst_n)
	begin
		if dma_clk_rst_n = '0' then
			dma_data_out0 <= (others => '0');
			dma_valid_out0 <= '0';	
			dma_data_out1 <= (others => '0');
			dma_valid_out1 <= '0';	
			dma_data_out2 <= (others => '0');
			dma_valid_out2 <= '0';	
			dma_data_out3 <= (others => '0');
			dma_valid_out3 <= '0';	
			
			dma_valid_reg0 <= '0';
			pre_output_counter_wr <= (others => '0');		
		-- fifo is not empty and dma is ready
        elsif rising_edge(dma_clk_i) then
            --if dma_valid_reg1 = '1' then -- fifo output should be valid by now as fifo_rden was enabled and it id not empty!
			-- Store output from FIFO in the correct dma_data_outX if dma_valid_reg1 is valid.
			-- On the next dma_valid_reg1 operation (next clock cycle if dma_valid_reg1 remains 1),
			-- clear the past dma_data_outX if dma has read from it (read pointer is in the past write position).
			if  pre_output_counter_wr = "00" and dma_valid_reg0 = '1' then
				-- Output only the last_data bit of fifo_do
				dma_data_out0(c_wishbone_data_width) <= fifo_do(c_wishbone_data_width);
				-- Output the data from fifo itself
				dma_data_out0(c_wishbone_data_width-1 downto 0) <= fifo_do(c_wishbone_data_width-1 downto 0);
				dma_valid_out0 <= '1';
			elsif output_counter_rd = "00" and dma_ready_s = '1' then
				dma_data_out0 <= (others => '0');
				dma_valid_out0 <= '0';
			end if;
			
			if  pre_output_counter_wr = "01" and dma_valid_reg0 = '1' then
				dma_data_out1(c_wishbone_data_width) <= fifo_do(c_wishbone_data_width);
				dma_data_out1(c_wishbone_data_width-1 downto 0) <= fifo_do(c_wishbone_data_width-1 downto 0);
				dma_valid_out1 <= '1';
			elsif output_counter_rd = "01" and dma_ready_s = '1' then
				dma_data_out1 <= (others => '0');
				dma_valid_out1 <= '0';
			end if;
			
			if  pre_output_counter_wr = "10" and dma_valid_reg0 = '1' then
				dma_data_out2(c_wishbone_data_width) <= fifo_do(c_wishbone_data_width);
				dma_data_out2(c_wishbone_data_width-1 downto 0) <= fifo_do(c_wishbone_data_width-1 downto 0);
				dma_valid_out2 <= '1';
			elsif output_counter_rd = "10" and dma_ready_s = '1' then
				dma_data_out2 <= (others => '0');
				dma_valid_out2 <= '0';
			end if;
			
			if  pre_output_counter_wr = "11" and dma_valid_reg0 = '1' then
				dma_data_out3(c_wishbone_data_width) <= fifo_do(c_wishbone_data_width);
				dma_data_out3(c_wishbone_data_width-1 downto 0) <= fifo_do(c_wishbone_data_width-1 downto 0);
				dma_valid_out3 <= '1';
			elsif output_counter_rd = "11" and dma_ready_s = '1' then
				dma_data_out3 <= (others => '0');
				dma_valid_out3 <= '0';
			end if;
			
			if dma_valid_reg0 = '1' then --dma_valid_reg0 = '1' then
				pre_output_counter_wr <= std_logic_vector(unsigned(pre_output_counter_wr) + 1);	
			end if;
		
            -- 2 clock cycle delay for read from fifo.
            -- Nedded to break logic into one more FF as timing constraint wasn't met,
            -- due to the use of dma_valid_s directly into fifo_rden.
            -- This is not a problem since there is a 4 position "buffer" after this
            -- to absorb dma_ready_i deassertion
            dma_valid_reg0 <= dma_valid_s;
		end if;
	end process p_dma_pre_output;
	
	-- Send to DMA the correct data_i from dma_data_out, based on the currently read pointer position
	p_dma_output_proc : process(dma_clk_i, dma_clk_rst_n)
	begin
		if dma_clk_rst_n = '0' then		
			dma_data_int <= (others => '0');
			dma_valid_int <= '0';
			--dma_be_o <= (others => '0');	
			-- The MSB is an indicator of the last data_i requested!
			dma_last_int <= '0';
			output_counter_rd <= (others => '0');
        elsif rising_edge(dma_clk_i) then
            if dma_ready_s = '1' then
                -- verify wr counter and output corresponding output
                case output_counter_rd is
                    when "11" =>
                        dma_data_int <= dma_data_out3(c_wishbone_data_width-1 downto 0);
                        dma_valid_int <= dma_valid_out3;
                        --dma_be_o <= (others => '1');
                        -- The MSB is an indicator of the last data_i requested!
                        dma_last_int <= dma_data_out3(c_wishbone_data_width) and dma_valid_out3;
                    when "10" =>
                        dma_data_int <= dma_data_out2(c_wishbone_data_width-1 downto 0);
                        dma_valid_int <= dma_valid_out2;
                        --dma_be_o <= (others => '1');
                        -- The MSB is an indicator of the last data_i requested!
                        dma_last_int <= dma_data_out2(c_wishbone_data_width) and dma_valid_out2;
                    when "01" =>
                        dma_data_int <= dma_data_out1(c_wishbone_data_width-1 downto 0);
                        dma_valid_int <= dma_valid_out1;
                        --dma_be_o <= (others => '1');
                        -- The MSB is an indicator of the last data_i requested!
                        dma_last_int <= dma_data_out1(c_wishbone_data_width) and dma_valid_out1;
                    --when "01" =>
                    when others => 
                        dma_data_int <= dma_data_out0(c_wishbone_data_width-1 downto 0);
                        dma_valid_int <= dma_valid_out0;
                        --dma_be_o <= (others => '1');
                        -- The MSB is an indicator of the last data_i requested!
                        dma_last_int <= dma_data_out0(c_wishbone_data_width) and dma_valid_out0;	
                end case;
                
                -- Only increment output_counter_rd if it is different from pre_output_counter_wr
                -- to prevent overflow!
                if output_counter_rd /= pre_output_counter_wr then
                    output_counter_rd <= std_logic_vector(unsigned(output_counter_rd) + 1);
                end if;
            end if;	
        end if;
	end process p_dma_output_proc;
	
	-- Simple backpressure scheme. Should be almost full for correct behavior.
	-- fifo_full is already synchronized with fifo write_clock
	data_ready_o							<= not fifo_full;
	
	--------------------------------
	-- DMA complete status		
	--------------------------------
	dma_last_s 								<= dma_valid_int and read_cycle_progress and dma_last_int;

	p_dma_complete : process (dma_clk_i, dma_clk_rst_n)
	begin
		if dma_clk_rst_n = '0' then	
			dma_complete_int <= '0';
        elsif rising_edge(dma_clk_i) then
            if dma_last_s = '1' then
                -- DMA could be held to 1 when completed, but it would be more difficult
                -- to bring it back to 0, since the dma transfer is initiated in the data_clk_i domain
                dma_complete_int <= not dma_complete_int;
            end if;
        end if;
	end process p_dma_complete;
	
	dma_complete_o							<= dma_complete_int;
	
	--------------------------------
	-- DMA overflow (fifo full) status and counter	
	--------------------------------
	
	-- Data is lost when this is asserted.
	-- FIFO is full, there is data valid on input and we are in the middle of a dma transfer
	s_fifo_ovf								<= fifo_full and data_valid_i and
        capture_ctl_reg(c_wishbone_data_width-1);
	
	p_dma_overflow : process (data_clk_i, data_clk_rst_n)
	begin
        if data_clk_rst_n = '0' then 
            s_fifo_ovf_c <= (others => '0');
        elsif rising_edge(data_clk_i) then
            if start_acq_trig = '1' then
                s_fifo_ovf_c <= (others => '0');
            elsif s_fifo_ovf = '1' then
                -- Even if the counter wrapps around, an overflow will still be detected!
                s_fifo_ovf_c <= '1' & std_logic_vector(unsigned(s_fifo_ovf_c(g_ovf_counter_width-1 downto 0)) + 1);
            end if;
        end if;
	end process p_dma_overflow;
	
	dma_ovf_o								<= s_fifo_ovf_c(g_ovf_counter_width);
	
	--------------------------------
	-- FIFO instantiation
	--------------------------------
        
    cmp_fifo : generic_async_fifo
    generic map(
        g_data_width                        => c_wishbone_data_width+1,
        g_size                              => c_fifo_size,
        
        -- Read-side flag selection     
        g_with_rd_empty                     => true,   -- with empty flag
        --g_with_rd_count                   => false,  -- with words counter
        
        --g_with_wr_empty                   => false,
        g_with_wr_full                      => true
        --g_with_wr_count                   => false,
        
        --g_almost_empty_threshold          => ?,  -- threshold for almost empty flag
        --g_almost_full_threshold           => ?   -- threshold for almost full flag
    )
    port map(
        rst_n_i                             => fifo_rst_n,
        
        -- write port       
        clk_wr_i                            => fifo_wrclk,
        d_i                                 => fifo_di,
        we_i                                => fifo_wren,
        
        wr_empty_o                          => open,
        wr_full_o                           => fifo_full,
        wr_almost_empty_o                   => open,
        wr_almost_full_o                    => open,
        wr_count_o                          => open,
        
        -- read port        
        clk_rd_i                            => fifo_rdclk,
        q_o                                 => fifo_do,
        rd_i                                => fifo_rden,
        
        rd_empty_o                          => fifo_empty,
        rd_full_o                           => open,
        rd_almost_empty_o                   => open,
        rd_almost_full_o                    => open,
        rd_count_o                          => open
    );

    fifo_rst_n						        <= arst_n_i;
	fifo_rden						        <= dma_valid_s; 
	fifo_rdclk						        <= dma_clk_i;
	-- Observe the FIFO reset cycle! dma_clk_buf is the clock for fifo_rd_en
	fifo_wrclk						        <= data_clk_i;
	-- c_wishbone_data_width + 1 bits.
	-- It doesn't matter if the data_i is signed or unsigned since we do not care what the input data is.
	-- The user has to treat this and extend the sign if necessary.
	fifo_di		                            <= last_data_reg & data_i_d1;

end rtl;
