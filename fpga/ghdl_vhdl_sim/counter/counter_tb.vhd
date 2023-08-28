library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_tb is
  -- empty
end counter_tb;

architecture testbench of counter_tb is

  -- This is the VHDL component that will be instantiated.
  component counter is
    generic( WIDTH : natural := 8 );
    port(
      CLK  : in std_logic;
      nRST : in std_logic;
      CE   : in std_logic;
      Q    : out std_logic_vector( WIDTH-1 downto 0 ) 
    );
  end component;

  -- internal test signals
  constant WIDTH : natural := 8;
  signal t_nRST, t_CLK, t_CE : std_ulogic := '0';
  signal t_Q : std_logic_vector( WIDTH-1 downto 0 );

begin
  -- Instantiate the upcounter as DUT (design under test).
  DUT: counter 
    generic map ( WIDTH => 8 )
    port map( CLK => t_CLK, nRST => t_nRST, CE => t_CE, Q => t_Q );

  -- create a reset signal
  process begin 
     t_nRST <= '0';
     wait for 100 ns;
     t_nRST <= '1';
     wait; -- wait forever
  end process;

  -- create a 50MHz clock (periodic) signal
  process begin 
     t_CLK <= '0';
     wait for 10 ns;
     t_CLK <= '1';
     wait for 10 ns;
  end process;

  -- create a clock enable (CE) signal
  t_CE <= '0', '1' after 200 ns, '0' after 10 us;

end testbench;

