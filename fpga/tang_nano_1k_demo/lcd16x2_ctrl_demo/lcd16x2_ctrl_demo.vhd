

-- based on: https://github.com/freecores/16x2_lcd_controller/

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-------------------------------------------------------------------------------

ENTITY lcd16x2_ctrl_demo IS
    PORT (
        CLK    : IN STD_LOGIC;
        RST_N  : IN STD_LOGIC;
        LCD_E  : OUT STD_LOGIC;
        LCD_RS : OUT STD_LOGIC;
        LCD_RW : OUT STD_LOGIC;
        LCD_D  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
  );
END lcd16x2_ctrl_demo;

ARCHITECTURE behavior OF lcd16x2_ctrl_demo IS

    ---------------------------------------------------------------------------
    -- Helper function: convert string to 128-bit STD_LOGIC_VECTOR
    ---------------------------------------------------------------------------
    FUNCTION str_to_slv(s : STRING) RETURN STD_LOGIC_VECTOR IS
        VARIABLE result : STD_LOGIC_VECTOR(127 DOWNTO 0) := (OTHERS => '0');
        VARIABLE j : INTEGER;
    BEGIN
        FOR j IN 1 TO s'length LOOP
            IF j <= 16 THEN
                result(((16 - j) * 8 + 7) DOWNTO ((16 - j) * 8)) :=
                    STD_LOGIC_VECTOR(to_unsigned(CHARACTER'POS(s(j)), 8));
            END IF;
        END LOOP;
        RETURN result;
    END FUNCTION;

    ---------------------------------------------------------------------------
    SIGNAL line1_buf : STD_LOGIC_VECTOR(127 DOWNTO 0);
    SIGNAL line2_buf : STD_LOGIC_VECTOR(127 DOWNTO 0);

    SIGNAL LCD_DB : STD_LOGIC_VECTOR( 7 DOWNTO 4);
    SIGNAL reset  : STD_LOGIC;

    CONSTANT CLK_PERIOD_NS : INTEGER := 37; -- 27MHz clock

BEGIN

    LCD_D <= LCD_DB(7 DOWNTO 4);

    -- component instantiation
    DUT : ENTITY work.lcd16x2_ctrl
        GENERIC MAP(
            CLK_PERIOD_NS => CLK_PERIOD_NS)
        PORT MAP(
            clk => clk,
            rst => reset,
            lcd_e => lcd_e,
            lcd_rs => lcd_rs,
            lcd_rw => lcd_rw,
            lcd_db => lcd_db,
            line1_buf => line1_buf,
            line2_buf => line2_buf);

    reset <= NOT RST_N;

    ---------------------------------------------------------------------------
    -- Set messages using ASCII strings (exactly 16 characters)
    ---------------------------------------------------------------------------
    line1_buf <= str_to_slv("Hello Gowin FPGA");
    line2_buf <= str_to_slv("Sipeed Tang 1K  ");
 
END behavior;
