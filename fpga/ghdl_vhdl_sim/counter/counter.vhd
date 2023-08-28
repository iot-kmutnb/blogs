library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
  generic( WIDTH : natural := 8 );
  port(
    CLK  : in std_logic;
    nRST : in std_logic;
    CE   : in std_logic;
    Q    : out std_logic_vector( WIDTH-1 downto 0 )
  );
end counter;

architecture behave of counter is
  constant ZEROS : unsigned(WIDTH-1 downto 0) := (others => '0');
  signal    regs : unsigned(WIDTH-1 downto 0) := ZEROS;
begin
  process (nRST, CLK) 
  begin
    if nRST = '0' then
      regs <= ZEROS;    -- reset the register to zero
    elsif rising_edge(CLK) and CE = '1' then
      regs <= regs + 1; -- increment the register by 1
    end if;
  end process;

  Q <= std_logic_vector(regs);

end behave;

