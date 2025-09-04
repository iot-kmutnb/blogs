
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY btn_debounce IS
    PORT (
        RST_N : IN STD_LOGIC; -- asynchronous active-low reset
        CLK : IN STD_LOGIC;
        BTN : IN STD_LOGIC;
        PULSE : OUT STD_LOGIC -- single-cycle pulse on rising edge
    );
END ENTITY btn_debounce;

ARCHITECTURE rtl OF btn_debounce IS
    CONSTANT N : INTEGER := 16; -- width of debounce counter
    CONSTANT CNT_MAX : unsigned(N - 1 DOWNTO 0) := (OTHERS => '1');
    SIGNAL btn_sync : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL db_cnt : unsigned(N - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL btn_stable : STD_LOGIC := '1';
    SIGNAL btn_prev : STD_LOGIC := '1';
BEGIN

    -- 2-stage button synchronizer
    PROCESS (CLK, RST_N)
    BEGIN
        IF RST_N = '0' THEN
            btn_sync <= (OTHERS => '1');
        ELSIF rising_edge(CLK) THEN
            btn_sync <= btn_sync(0) & BTN;
        END IF;
    END PROCESS;

    PROCESS (CLK, RST_N)
    BEGIN
        IF RST_N = '0' THEN
            PULSE <= '0';
            btn_prev <= '1';
        ELSIF rising_edge(CLK) THEN
            -- debounce logic
            IF btn_sync(1) = btn_stable THEN
                db_cnt <= to_unsigned(0, N);
            ELSE
                db_cnt <= db_cnt + 1;
                IF db_cnt = CNT_MAX THEN
                    btn_stable <= btn_sync(1);
                    db_cnt <= (OTHERS => '0');
                END IF;
            END IF;

            btn_prev <= btn_stable;

            -- rising edge detection
            IF btn_stable = '1' AND btn_prev = '0' THEN
                PULSE <= '1';
            ELSE
                PULSE <= '0';
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;

---------------------------------------------------------------
