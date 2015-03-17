-- Authors: Grzegorz Kasprowicz, Andrzej Wojenski
library ieee;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;


entity spi_link  is
  PORT
    (
     clk            : in  STD_LOGIC;
     reset          : in  STD_LOGIC;
     SCK            : in  STD_LOGIC;
     SDI            : in  STD_LOGIC;
     SDO            : out STD_LOGIC;
     SCS            : in  std_logic;
     data_in        : in  STD_LOGIC_VECTOR (7 downto 0);
     data_out       : out STD_LOGIC_VECTOR(7 downto 0);
     command_out    : out STD_LOGIC_VECTOR(7 downto 0);
     write_en       : out STD_LOGIC;
     transfer_done  : out STD_LOGIC;
     byte_sel       : out STD_LOGIC_VECTOR (3 downto 0);
     addr_sel       : out STD_LOGIC_VECTOR (1 downto 0);
     addr_complete  : out std_logic;
     testout        : out STD_LOGIC_VECTOR (7 downto 0)
     );


end spi_link ;

architecture a  of spi_link is

    TYPE STATE_TYPE IS (
    idle,
    cs_low,
    clk_h,
    wait_clk_l,
    clk_l,
    latch_cmd,
    latch_byte,
    transfer_end
    );

    SIGNAL state: STATE_TYPE;

        signal bit_count : integer range 0 to 8;
        signal byte_count : integer range 0 to 7;
        signal command : std_logic_vector(7 downto 0);
        signal write_nread : std_logic;
        signal shift_dat_in  : std_logic_vector(7 downto 0);
        signal shift_dat_out  : std_logic_vector(7 downto 0);
        signal shift_en : std_logic;
        signal shift_load : std_logic;
        signal shift_sclr,SCK_synch,SDI_synch,SCS_synch,
                update_byte,
                load_byte,
                transfer_done_tmp,transfer_done_edge_det,
                shift_din : std_logic;
        signal byte_sel_tmp : std_logic_vector(3 downto 0);


--component shiftreg
--  PORT
--  (
--      clock       : IN STD_LOGIC ;
--      data        : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
--      enable      : IN STD_LOGIC ;
--      load        : IN STD_LOGIC ;
--      sclr        : IN STD_LOGIC ;
--      shiftin     : IN STD_LOGIC ;
--      q           : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
--      shiftout    : OUT STD_LOGIC
--  );
--end component;

component shiftreg
    port (
     CLK    : in std_logic;
     clr    : in std_logic;
     shift  : in std_logic;
     ld     : in std_logic;
     Din    : in std_logic_vector(7 downto 0);
     SI     : in std_logic;
     Dout   : out std_logic_vector(7 downto 0);
    shiftout : out std_logic
     );
end component;

begin  -- a

--***********************************************************************************************************************************************
--*******************************************   main control state machine  *********************************************************************
--***********************************************************************************************************************************************


--input signals synchronisation
PROCESS (clk,reset)
    BEGIN
        IF reset = '1' THEN
            SCK_synch <= '0';
            SDI_synch <= '0';
            SCS_synch <= '0';
        ELSIF clk'EVENT AND clk = '0' THEN
            SCK_synch <= SCK;
            SDI_synch <= SDI;
            SCS_synch <= SCS;
        end if;
end process;




PROCESS (clk,reset)
    BEGIN
        IF reset = '1' THEN
            state <= idle;
        ELSIF clk'EVENT AND clk = '1' THEN
                CASE state IS
                    WHEN idle =>
                        byte_count <= 0;
                        command <= (others => '0');
                        IF SCS_synch = '0' THEN
                            state <=cs_low;
                        END IF;

                    when cs_low =>
                        bit_count <= 8;
                        IF  SCK_synch = '1' THEN
                            state <=clk_h;
                        ELSIF SCS_synch = '1' THEN
                            state <=idle;
                        END IF;

                    when clk_h =>
                        bit_count <= bit_count - 1;
                        state <=wait_clk_l;

                    when wait_clk_l =>
                        IF SCK_synch = '0' THEN
                            state <=clk_l;
                        ELSIF SCS_synch = '1' THEN
                            state <=idle;
                        END IF;

                    when clk_l =>
                        IF bit_count = 0 and byte_count = 0 THEN
                            state <=latch_cmd;
                        ELSIF bit_count = 0 and byte_count /= 0 THEN
                            state <=latch_byte;
                        ELSIF  SCK_synch = '1' THEN
                            state <=clk_h;
                        ELSIF SCS_synch = '1' THEN
                            state <=idle;
                        END IF;

                    when latch_cmd =>
                            byte_count <= byte_count + 1 ;
                            command <= shift_dat_out;
                            state <=cs_low;

                    when latch_byte =>
                        byte_count <= byte_count + 1 ;
                        IF byte_count = 6  THEN
                            state <=transfer_end;
                        ELSIF SCS_synch = '1' THEN
                            state <=idle;
                        else
                            state <=cs_low;
                        END IF;

                    when transfer_end =>
                        IF SCS_synch = '1' THEN
                            state <=idle;
                        END IF;


                END CASE;
        END IF;
    END PROCESS;

    WITH state  SELECT
        shift_sclr  <=      '1' when idle,
                            '0' when cs_low,
                            '0' when clk_h,
                            '0' when clk_l,
                            '0' when others;

    WITH state  SELECT
        shift_en    <=      '0' when idle,
                            '1' when clk_h,
                            '1' when cs_low,
                            '0' when others;


    WITH state  SELECT
        update_byte     <=  '0' when idle,
                            '1' when latch_byte,
                            '0' when others;


    WITH state  SELECT
        load_byte       <=  '0' when idle,
                            '1' when cs_low,
                            '0' when others;
    WITH state  SELECT
        transfer_done_tmp   <=  '0' when idle,
                            '1' when transfer_end,
                            '0' when others;

PROCESS (clk,reset)
    BEGIN
        IF reset = '1' THEN
            transfer_done_edge_det <= '0';
        ELSIF clk'EVENT AND clk = '1' THEN
            transfer_done_edge_det <= transfer_done_tmp;
            transfer_done <= transfer_done_tmp and not transfer_done_edge_det;
        end if;
end process;

WITH byte_count  SELECT
    byte_sel_tmp    <=      "1000" when 3,
                            "0100" when 4,
                            "0010" when 5,
                            "0001" when 6,
                            "0000" when others;
    byte_sel <= byte_sel_tmp;

    addr_sel(1) <= '1' when state = latch_byte  and byte_count = 1 else '0';
    addr_sel(0) <= '1' when state = latch_byte  and byte_count = 2 else '0';
    addr_complete <= '1' when byte_count = 3 else '0';

write_nread <= command(7);
--read / write selection
shift_load <= '1' when load_byte = '1' and write_nread = '0' else '0';
write_en <= '1' when update_byte = '1' and write_nread = '1' else '0' ;
--shift_din <= SDI_synch when write_nread = '1' else '0' ;
shift_din <= SDI_synch when (write_nread = '1' or byte_count < 3) else '0' ;


command_out <= command;

--  shiftreg_1: shiftreg
--    port map (
--      clock    => clk, -
--      data     => shift_dat_in, -
--      enable   => shift_en,
--      load     => shift_load, -
--      sclr     => shift_sclr, -
--      shiftin  => shift_din, -
--      q        => shift_dat_out, -
--      shiftout => SDO);

  shiftreg_1: shiftreg
    port map (
     CLK    => clk,
     clr    => shift_sclr,
     shift    => shift_en,
     ld    => shift_load,
     Din    => shift_dat_in,
     SI    => shift_din,
     Dout    => shift_dat_out,
    shiftout => SDO);

  shift_dat_in  <= data_in;
  data_out <= shift_dat_out;

testout(0) <= shift_din;
testout(1) <= shift_en;
testout(2) <= shift_load;
testout(3) <= shift_sclr;
testout(7 downto 4) <= shift_dat_out (7 downto 4);

end a ;
