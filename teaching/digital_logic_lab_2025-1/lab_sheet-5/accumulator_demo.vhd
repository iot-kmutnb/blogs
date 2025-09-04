LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY accumulator_demo IS
    GENERIC (
        N : INTEGER := 8;
        M : INTEGER := 12
    );
    PORT (
        RST_N : IN STD_LOGIC; -- global async. active-low reset
        CLK   : IN STD_LOGIC; -- clock
        BTN   : IN STD_LOGIC; -- push button
        SW    : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        HEX0  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- 7seg digit 3
        HEX1  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- 7seg digit 2
        HEX2  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- 7seg digit 1
        HEX3  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)  -- 7seg digit 0
    );
END ENTITY accumulator_demo;

ARCHITECTURE rtl OF top IS
    -- Internal signals
    SIGNAL pulse : STD_LOGIC;
    SIGNAL acc_val : STD_LOGIC_VECTOR(M - 1 DOWNTO 0);

BEGIN

    ----------------------------------------------------------------
    -- 1) Button debounce module
    ----------------------------------------------------------------
    debounce_inst : ENTITY work.btn_debounce
        PORT MAP(
            RST_N => RST_N,
            CLK => CLK,
            BTN => BTN,
            PULSE => pulse
        );

    ----------------------------------------------------------------
    -- 2) Accumulator unit
    ----------------------------------------------------------------
    acc_inst : ENTITY work.accumulator
        GENERIC MAP(N => N, M => M)
        PORT MAP(
            RST_N => RST_N,
            CLK => CLK,
            CE => pulse,
            DATA => SW,
            Q => acc_val
        );

    ----------------------------------------------------------------
    -- 3) BCD to 7-segment display
    ----------------------------------------------------------------
    display_inst : ENTITY work.bcd_7seg_display
        PORT MAP(
            data => acc_val,
            seg1 => HEX3,
            seg2 => HEX2,
            seg3 => HEX1,
            seg4 => HEX0
        );

END ARCHITECTURE rtl;

---------------------------------------------------------------