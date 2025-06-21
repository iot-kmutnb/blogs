-- File: disp_7seg_demo.vhd
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY disp_7seg_demo IS
    GENERIC (
        CLK_HZ     : NATURAL := 27_000_000; -- system clock frequency
        NUM_DIGITS : NATURAL := 4 -- number of digits used
    );
    PORT (
        CLK    : IN STD_LOGIC;
        RST_N  : IN STD_LOGIC;
        SEG7   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- 7-segment + DP
        DIGITS : OUT STD_LOGIC_VECTOR(NUM_DIGITS - 1 DOWNTO 0) -- 7seg control bits
    );
END disp_7seg_demo;

ARCHITECTURE behavioral OF disp_7seg_demo IS
    CONSTANT SCAN_CNT_MAX : NATURAL := (CLK_HZ/500) - 1;

    TYPE digit_array_t IS ARRAY (0 TO NUM_DIGITS - 1) OF INTEGER RANGE 0 TO 9;
    SIGNAL bcd_count   : digit_array_t;

    SIGNAL data_buf    : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL digits_sel  : STD_LOGIC_VECTOR(NUM_DIGITS - 1 DOWNTO 0);
    SIGNAL digit_index : NATURAL RANGE 0 TO NUM_DIGITS - 1 := 0;

    SUBTYPE nibble IS unsigned(3 DOWNTO 0);
    -- This function implements a BCD to 7-Segment decoder.
    FUNCTION BCD2SEG7(data : nibble) RETURN STD_LOGIC_VECTOR IS
        VARIABLE seg7bits  : STD_LOGIC_VECTOR(6 DOWNTO 0);
    BEGIN
        CASE data IS
            WHEN "0000" => seg7bits := "0111111"; -- 0
            WHEN "0001" => seg7bits := "0000110"; -- 1
            WHEN "0010" => seg7bits := "1011011"; -- 2
            WHEN "0011" => seg7bits := "1001111"; -- 3
            WHEN "0100" => seg7bits := "1100110"; -- 4
            WHEN "0101" => seg7bits := "1101101"; -- 5
            WHEN "0110" => seg7bits := "1111101"; -- 6
            WHEN "0111" => seg7bits := "0000111"; -- 7
            WHEN "1000" => seg7bits := "1111111"; -- 8
            WHEN "1001" => seg7bits := "1101111"; -- 9
            WHEN OTHERS => seg7bits := "0000000"; -- off
        END CASE;
        RETURN seg7bits;
    END BCD2SEG7;

BEGIN

    PROCESS (RST_N, CLK)
    BEGIN
        IF RST_N = '0' THEN
            bcd_count(0) <= 0;
            bcd_count(1) <= 0;
            bcd_count(2) <= 0;
            bcd_count(3) <= 0;
        ELSIF rising_edge(CLK) THEN
            bcd_count(0) <= 0;
            bcd_count(1) <= 1;
            bcd_count(2) <= 2;
            bcd_count(3) <= 3;
        END IF;
    END PROCESS;

    -- This process implements a 7-segment driver using time-multiplexing.
    PROCESS (RST_N, CLK)
        VARIABLE wait_cnt    : NATURAL RANGE 0 TO SCAN_CNT_MAX := 0;
        VARIABLE clk_enabled : BOOLEAN;
        VARIABLE bcd_value   : unsigned(3 DOWNTO 0);
    BEGIN
        IF RST_N = '0' THEN
            wait_cnt := 0;
            data_buf <= x"00";
            digits_sel <= (OTHERS => '0');
            digit_index <= 0;
        ELSIF rising_edge(CLK) THEN
            IF wait_cnt = SCAN_CNT_MAX THEN
                wait_cnt := 0;
                clk_enabled := true;
            ELSE
                wait_cnt := wait_cnt + 1;
                clk_enabled := false;
            END IF;
            IF clk_enabled THEN
                IF digit_index = NUM_DIGITS - 1 THEN
                    digit_index <= 0;
                ELSE
                    digit_index <= digit_index + 1;
                END IF;
                FOR i IN 0 TO NUM_DIGITS - 1 LOOP
                    IF i = digit_index THEN
                        digits_sel(i) <= '1'; -- active
                    ELSE
                        digits_sel(i) <= '0'; -- inactive
                    END IF;
                END LOOP;
                bcd_value := to_unsigned(bcd_count(digit_index), 4);
                data_buf <= '0' & BCD2SEG7(bcd_value);
            END IF;
        END IF;
    END PROCESS;

    DIGITS <= NOT digits_sel; -- active-low
    SEG7   <= NOT data_buf; -- for common-anode 7-segment LEDs

END behavioral;

