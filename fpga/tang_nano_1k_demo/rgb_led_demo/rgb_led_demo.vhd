------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
------------------------------------------------------------------

entity rgb_led_demo is
  generic (
     CLK_HZ   : natural := 27000000;
     NUM_LEDS : natural := 3
  );
  port(
     CLK   : in std_logic; -- system clock
     RST_N : in std_logic; -- global asynchronous reset (active-low)
     RGB   : out std_logic_vector(NUM_LEDS-1 downto 0) -- LED Pins
  );
end rgb_led_demo;

architecture SYNTH of rgb_led_demo is
  constant COUNT_PERIOD : integer := CLK_HZ/2;
  subtype count_t is integer range 0 to (COUNT_PERIOD-1); 
  signal  count : count_t := 0;
  signal  leds_reg : std_logic_vector(NUM_LEDS-1 downto 0);
  signal  shift_en : std_logic;

begin

  -- Use the register's bits (inverted) for LED outputs
  RGB <= not leds_reg; 

  process (RST_N, CLK) begin
    if RST_N = '0' then
      count <= 0;
      shift_en <= '0';
    elsif rising_edge(CLK) then
      -- check whether the counter reaches the max. value.
      if count = (COUNT_PERIOD-1) then 
        count <= 0;       -- reset the counter.
        shift_en <= '1';  -- enable register shift.
      else
        count <= count+1; -- increment counter by 1.
        shift_en <= '0';  -- disable register shift.
      end if;
    end if;
  end process;

  process (RST_N, CLK) begin
    if RST_N = '0' then
      -- Initialize the LEDs register.
      leds_reg(0) <= '1'; 
      leds_reg(leds_reg'left downto 1) <= (others => '0');
    elsif rising_edge(CLK) then
      if shift_en='1' then -- Bit shifting is enabled.  
        -- Rotate-left shift.
        leds_reg <= leds_reg(leds_reg'left-1 downto 0) 
                  & leds_reg(leds_reg'left); 
      end if;
    end if;
  end process;

end SYNTH;
