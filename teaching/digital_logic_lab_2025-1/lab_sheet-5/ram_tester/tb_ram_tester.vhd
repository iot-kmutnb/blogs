library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_ram_tester is
end entity;

architecture sim of tb_ram_tester is

  constant DATA_WIDTH : integer := 8;
  constant ADDR_WIDTH : integer := 4;  -- keep small for simulation (16 locations)

  -- DUT signals
  signal clk       : std_logic := '0';
  signal rst_n     : std_logic := '0';
  signal start     : std_logic := '0';
  signal sw        : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal led_done  : std_logic;
  signal led_error : std_logic;

begin

  -- clock generator: 10 ns period (100 MHz)
  clk <= not clk after 5 ns;

  -- DUT
  uut: entity work.ram_tester
    generic map (
      DATA_WIDTH => DATA_WIDTH,
      ADDR_WIDTH => ADDR_WIDTH
    )
    port map (
      CLK       => clk,
      RST_N     => rst_n,
      START     => start,
      SW        => sw,
      LED_DONE  => led_done,
      LED_ERROR => led_error
    );

  -- Stimulus process
  process
  begin
    -- seed value for LFSR
    sw <= x"FF";   -- arbitrary non-zero
  
    -- initial reset
    rst_n <= '0';
    wait for 50 ns;
    rst_n <= '1';
    wait for 20 ns;
  
    sw <= x"AB";   -- arbitrary non-zero
 
    -- start pulse
    start <= '1';
    wait for 10 ns;
  wait until rising_edge(clk);
    start <= '0';

    -- wait until done
    wait until led_done = '1';

    -- report result
    if led_error = '1' then
      report "RAM TEST FAILED" severity error;
    else
      report "RAM TEST PASSED" severity note;
    end if;

    wait for 50 ns;
    report "Simulation finished" severity note;
    wait;
  end process;

end architecture;

-- $ ghdl -a ram_sp.vhd lfsr.vhd de10lite_ram_test.vhd  tb_ram_tester.vhd
-- $ ghdl -e tb_ram_tester
-- $ ghdl -r tb_ram_tester --stop-time=2us --vcd=wave.vcd
