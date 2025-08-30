-- File: keypad_scan.vhd

-- Keypad layout:
--  R0C0 (1) R0C1 (2) R0C2 (3)  R0C3 (A)
--  R1C0 (4) R1C1 (5) R1C2 (6)  R1C3 (B)
--  R2C0 (7) R2C1 (8) R2C2 (9)  R2C3 (C)
--  R3C0 (*) R3C1 (0) R3C2 (#)  R3C3 (D)

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY keypad_scan IS
    GENERIC (
        CLK_FREQ_HZ : INTEGER := 50_000_000;
        SCAN_RATE : INTEGER := 500
    );
    PORT (
        CLK   : IN STD_LOGIC; -- Clock input
        RST_N : IN STD_LOGIC; -- Active-low asynchronous reset
        ROWS  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0); -- Row inputs
        COLS  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- Column outputs
        HEX0  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- Detected row index
        HEX1  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- Detected column index
        LEDS  : OUT STD_LOGIC_VECTOR(9 DOWNTO 0); -- LEDs
        DBG   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)  -- Debug signals 
    );
END keypad_scan;
ARCHITECTURE behavioral OF keypad_scan IS

    CONSTANT COUNT_MAX : INTEGER := CLK_FREQ_HZ / SCAN_RATE;

    SIGNAL clk_cnt : INTEGER RANGE 0 TO COUNT_MAX - 1 := 0;
    SIGNAL clk_en : STD_LOGIC := '0';

    SIGNAL col_index : INTEGER RANGE 0 TO 3 := 0;
    SIGNAL col_reg   : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1110";

    SIGNAL key_row   : INTEGER RANGE 0 TO 15 := 0;
    SIGNAL key_col   : INTEGER RANGE 0 TO 15 := 0;
    SIGNAL key_valid : STD_LOGIC := '0';
    SIGNAL key_code  : INTEGER RANGE 0 TO 15 := 0;
    SIGNAL key_cnt   : INTEGER RANGE 0 TO 15 := 0;
    SIGNAL key_released : STD_LOGIC := '1';
    SIGNAL key_released_prev : STD_LOGIC := '1';

    -- PIN buffer
    TYPE pin_array_t IS ARRAY (0 TO 5) OF INTEGER RANGE 0 TO 9;
    SIGNAL entered_pin : pin_array_t := (OTHERS => 0);
    SIGNAL pin_index : INTEGER RANGE 0 TO 6 := 0;
    SIGNAL pin_ok : STD_LOGIC := '0';

    -- Secret PIN constant: "123456"
    CONSTANT SECRET_PIN : pin_array_t := (1, 2, 3, 4, 5, 6);

    ----------------------------------------------------------------
    FUNCTION bcd2seg7(bcd : INTEGER) RETURN STD_LOGIC_VECTOR IS
        VARIABLE seg : STD_LOGIC_VECTOR(6 DOWNTO 0);
    BEGIN
        CASE bcd IS
            WHEN 0 => seg := "1000000"; -- 0
            WHEN 1 => seg := "1111001"; -- 1
            WHEN 2 => seg := "0100100"; -- 2
            WHEN 3 => seg := "0110000"; -- 3
            WHEN 4 => seg := "0011001"; -- 4
            WHEN 5 => seg := "0010010"; -- 5
            WHEN 6 => seg := "0000010"; -- 6
            WHEN 7 => seg := "1111000"; -- 7
            WHEN 8 => seg := "0000000"; -- 8
            WHEN 9 => seg := "0010000"; -- 9
            WHEN OTHERS => seg := "1111111"; -- blank
        END CASE;
        RETURN seg;
    END bcd2seg7;

    ----------------------------------------------------------------
    TYPE int_array_t IS ARRAY (NATURAL RANGE <>) OF INTEGER;
    FUNCTION map_key(code : INTEGER) RETURN INTEGER IS
        VARIABLE lut : int_array_t(0 TO 15) :=
        (1, 2, 3, 10, 4, 5, 6, 11, 7, 8, 9, 12, 14, 0, 15, 13);
    BEGIN
        RETURN lut(code);
    END FUNCTION map_key;

BEGIN
    ----------------------------------------------------------------
    -- Clock enable generator
    clk_en_proc : PROCESS (CLK, RST_N)
    BEGIN
        IF RST_N = '0' THEN
            clk_cnt <= 0;
            clk_en <= '0';
        ELSIF rising_edge(CLK) THEN
            IF clk_cnt = COUNT_MAX - 1 THEN
                clk_cnt <= 0;
                clk_en <= '1';
            ELSE
                clk_cnt <= clk_cnt + 1;
                clk_en <= '0';
            END IF;
        END IF;
    END PROCESS;

    ----------------------------------------------------------------
    -- Column scan pattern generator
    cols_scan_proc : PROCESS (CLK, RST_N)
        VARIABLE next_col_index : INTEGER RANGE 0 TO 3;
    BEGIN
        IF RST_N = '0' THEN
            col_index <= 0;
            col_reg <= "1110";
        ELSIF rising_edge(CLK) THEN
            IF clk_en = '1' THEN
                next_col_index := (col_index + 1) MOD 4;
                col_index <= next_col_index;
                CASE next_col_index IS
                    WHEN 0 => col_reg <= "1110";
                    WHEN 1 => col_reg <= "1101";
                    WHEN 2 => col_reg <= "1011";
                    WHEN 3 => col_reg <= "0111";
                    WHEN OTHERS => col_reg <= "1111";
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    ----------------------------------------------------------------
    -- Row read and key decode
    read_rows_proc : PROCESS (CLK, RST_N)
    BEGIN
        IF RST_N = '0' THEN
            key_row <= 0;
            key_col <= 0;
            key_valid <= '0';
        ELSIF rising_edge(CLK) THEN
            IF clk_en = '1' THEN
                key_row <= 0;
                key_col <= col_index;
                key_valid <= '1';
                CASE ROWS IS
                    WHEN "1110" => key_row <= 0;
                    WHEN "1101" => key_row <= 1;
                    WHEN "1011" => key_row <= 2;
                    WHEN "0111" => key_row <= 3;
                    WHEN OTHERS => key_valid <= '0';
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    COLS <= col_reg;

    ----------------------------------------------------------------
    -- Key decode and release detection
    PROCESS (CLK, RST_N)
    BEGIN
        IF RST_N = '0' THEN
            key_code <= 0;
            key_released <= '1';
            key_cnt <= 15;
        ELSIF rising_edge(clk) AND clk_en = '1' THEN
            IF key_valid = '1' THEN
                key_code <= map_key(4 * key_row + key_col);
                key_cnt <= 15;
                key_released <= '0';
            ELSE
                IF key_cnt = 0 THEN
                    key_released <= '1';
                ELSE
                    key_cnt <= key_cnt - 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    ----------------------------------------------------------------
    -- PIN entry logic
    PROCESS (CLK, RST_N)
        VARIABLE match : BOOLEAN;
    BEGIN
        IF RST_N = '0' THEN
            key_released_prev <= '1';
            pin_index <= 0;
            pin_ok <= '0';

        ELSIF rising_edge(CLK) AND clk_en = '1' THEN
            key_released_prev <= key_released;

            IF key_released = '0' AND key_released_prev = '1' THEN
                -- New key press detected
                IF key_code >= 0 AND key_code <= 9 THEN
                    IF pin_index < 6 THEN
                        entered_pin(pin_index) <= key_code;
                        pin_index <= pin_index + 1;
                    END IF;

                ELSIF key_code = 15 THEN -- '#' pressed
                    -- Compare with secret PIN
                    match := TRUE;
                    FOR i IN 0 TO 5 LOOP
                        IF entered_pin(i) /= SECRET_PIN(i) THEN
                            match := FALSE;
                        END IF;
                    END LOOP;

                    IF match = TRUE THEN
                        pin_ok <= '1';
                    ELSE
                        pin_ok <= '0';
                    END IF;
                    pin_index <= 0; -- reset buffer

                ELSIF key_code = 14 THEN -- '*' pressed → clear
                    pin_index <= 0;
                    pin_ok <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS;

    ----------------------------------------------------------------
    -- Show row and column indices of the pressed key on the 2-digit 7-segment display
    HEX1 <= '1' & bcd2seg7(key_code / 10) WHEN key_valid = '1' ELSE
        (OTHERS => '1');
    HEX0 <= '1' & bcd2seg7(key_code MOD 10) WHEN key_valid = '1' ELSE
        (OTHERS => '1');

    ----------------------------------------------------------------
    -- LED output
    LEDS(0) <= pin_ok;
    LEDS(9 DOWNTO 1) <= (OTHERS => '0');

    DBG(3 DOWNTO 0) <= STD_LOGIC_VECTOR(TO_UNSIGNED(key_code, 4));
    DBG(7 DOWNTO 4) <= "00" & key_released & key_valid;

END behavioral;

