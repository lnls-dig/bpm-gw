library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;


entity fmc150_dac_if is
port
(
    rst_i           : in  std_logic;
    clk_dac_i       : in  std_logic;
    clk_dac_2x_i    : in  std_logic;
    dac_din_c_i     : in  std_logic_vector(15 downto 0);
    dac_din_d_i     : in  std_logic_vector(15 downto 0);
    dac_data_p_o    : out std_logic_vector(7 downto 0);
    dac_data_n_o    : out std_logic_vector(7 downto 0);
    dac_dclk_p_o    : out std_logic;
    dac_dclk_n_o    : out std_logic;
    dac_frame_p_o   : out std_logic;
    dac_frame_n_o   : out std_logic;
    txenable_o      : out std_logic
);
end fmc150_dac_if;


architecture rtl of fmc150_dac_if is

    signal frame                : std_logic;
    signal io_rst               : std_logic;
       
    signal dac_dclk_prebuf      : std_logic;
    signal dac_data_prebuf      : std_logic_vector(7 downto 0);
    signal dac_frame_prebuf     : std_logic;

begin
    ---------------------------------------------------------------------------------------------------
    -- Reset sequence
    ----------------------------------------------------------------------------------------------------
    process (rst_i, clk_dac_i)
      variable cnt : integer range 0 to 1023 := 0;
    begin
      if (rst_i = '0') then

        cnt := 0;
        io_rst <= '0';
        frame <= '0';
        txenable_o <= '0';

      elsif (rising_edge(clk_dac_i)) then

        if (cnt < 1023) then
          cnt := cnt + 1;
        else
          cnt := cnt;
        end if;

        -- The OSERDES blocks are synchronously reset for one clock cycle...
        if (cnt = 255) then
          io_rst <= '1';
        else
          io_rst <= '0';
        end if;

        -- Then a frame pulse is transmitted to the DAC...
        if (cnt = 511) then
          frame <= '1';
        else
          frame <= '0';
        end if;

        -- Finally the TX enable for the DAC can be pulled high.
        if (cnt = 1023) then
          txenable_o <= '1';
        end if;

      end if;
    end process;

    -- Output SERDES and LVDS buffer for DAC clock
    oserdes_clock : oserdes
    generic map (
      DATA_RATE_OQ => "DDR",
      DATA_RATE_TQ => "DDR",
      DATA_WIDTH => 4,
      INIT_OQ => '0',
      INIT_TQ => '0',
      SERDES_MODE => "MASTER",
      SRVAL_OQ => '0',
      SRVAL_TQ => '0',
      TRISTATE_WIDTH => 1
    )
    port map (
      oq        => dac_dclk_prebuf,
      shiftout1 => open,
      shiftout2 => open,
      tq        => open,
      clk       => clk_dac_2x_i,
      clkdiv    => clk_dac_i,
      d1        => '1',
      d2        => '0',
      d3        => '1',
      d4        => '0',
      d5        => '0',
      d6        => '0',
      oce       => '1',
      rev       => '0',
      shiftin1  => '0',
      shiftin2  => '0',
      sr        => io_rst,
      t1        => '0',
      t2        => '0',
      t3        => '0',
      t4        => '0',
      tce       => '0'
    );

    -- Output buffer
    obufds_clock : obufds_lvdsext_25
    port map (
      i  => dac_dclk_prebuf,
      o  => dac_dclk_p_o,
      ob => dac_dclk_n_o
    );

    -- Output serdes and LVDS buffers for DAC data
    dac_data: for i in 0 to 7 generate

      oserdes_data : oserdes
      generic map (
        DATA_RATE_OQ => "DDR",
        DATA_RATE_TQ => "DDR",
        DATA_WIDTH => 4,
        INIT_OQ => '0',
        INIT_TQ => '0',
        SERDES_MODE => "MASTER",
        SRVAL_OQ => '0',
        SRVAL_TQ => '0',
        TRISTATE_WIDTH => 1
      )
      port map (
        oq        => dac_data_prebuf(i),
        shiftout1 => open,
        shiftout2 => open,
        tq        => open,
        clk       => clk_dac_2x_i,
        clkdiv    => clk_dac_i,
        d1        => dac_din_c_i(i + 8),
        d2        => dac_din_c_i(i),
        d3        => dac_din_d_i(i + 8),
        d4        => dac_din_d_i(i),
        d5        => '0',
        d6        => '0',
        oce       => '1',
        rev       => '0',
        shiftin1  => '0',
        shiftin2  => '0',
        sr        => io_rst,
        t1        => '0',
        t2        => '0',
        t3        => '0',
        t4        => '0',
        tce       => '0'
      );

      --output buffers
      obufds_data : obufds_lvdsext_25
      port map (
        i  => dac_data_prebuf(i),
        o  => dac_data_p_o(i),
        ob => dac_data_n_o(i)
      );

    end generate;

    -- Output serdes and LVDS buffer for DAC frame
    oserdes_frame : oserdes
    generic map (
      DATA_RATE_OQ => "DDR",
      DATA_RATE_TQ => "DDR",
      DATA_WIDTH => 4,
      INIT_OQ => '0',
      INIT_TQ => '0',
      SERDES_MODE => "MASTER",
      SRVAL_OQ => '0',
      SRVAL_TQ => '0',
      TRISTATE_WIDTH => 1
    )
    port map (
      oq        => dac_frame_prebuf,
      shiftout1 => open,
      shiftout2 => open,
      tq        => open,
      clk       => clk_dac_2x_i,
      clkdiv    => clk_dac_i,
      d1        => frame,
      d2        => frame,
      d3        => frame,
      d4        => frame,
      d5        => '0',
      d6        => '0',
      oce       => '1',
      rev       => '0',
      shiftin1  => '0',
      shiftin2  => '0',
      sr        => io_rst,
      t1        => '0',
      t2        => '0',
      t3        => '0',
      t4        => '0',
      tce       => '0'
    );

    --output buffer
    obufds_frame : obufds_lvdsext_25
    port map (
      i  => dac_frame_prebuf,
      o  => dac_frame_p_o,
      ob => dac_frame_n_o
    );


end rtl;