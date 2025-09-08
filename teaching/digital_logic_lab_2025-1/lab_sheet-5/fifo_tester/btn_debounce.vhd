LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY btn_debounce IS
    GENERIC (
        WIDTH : NATURAL := 16 -- counter width, adjust for clock/frequency
    );
    PORT (
        clk : IN STD_LOGIC;
        rst_n : IN STD_LOGIC;
        btn_in : IN STD_LOGIC;
        btn_out : OUT STD_LOGIC; -- debounced button
        btn_edge : OUT STD_LOGIC -- rising edge pulse
    );
END ENTITY;

ARCHITECTURE rtl OF btn_debounce IS
    SIGNAL cnt : unsigned(WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL btn_sync : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '1');
    SIGNAL btn_db : STD_LOGIC := '0';
    SIGNAL btn_db_d : STD_LOGIC := '0';
BEGIN

    -- =============================================================
    -- Synchronize input
    -- =============================================================
    PROCESS (rst_n, clk)
    BEGIN
        IF rst_n = '0' THEN
            btn_sync <= (OTHERS => '1');
        ELSIF rising_edge(clk) THEN
            btn_sync <= btn_sync(0) & btn_in;
        END IF;
    END PROCESS;

    -- =============================================================
    -- Debounce counter
    -- =============================================================
    PROCESS (rst_n, clk)
    BEGIN
        IF rst_n = '0' THEN
            cnt <= (OTHERS => '0');
            btn_db <= '0';
        ELSIF rising_edge(clk) THEN
            IF btn_sync(1) = '1' THEN
                IF cnt < 2 ** WIDTH - 1 THEN
                    cnt <= cnt + 1;
                ELSE
                    btn_db <= '1';
                END IF;
            ELSE
                cnt <= (OTHERS => '0');
                btn_db <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- =============================================================
    -- Edge detection
    -- =============================================================
    PROCESS (rst_n, clk)
    BEGIN
        IF rst_n = '0' THEN
            btn_edge <= '0';
            btn_db_d <= '0';
        ELSIF rising_edge(clk) THEN
            btn_edge <= '0';
            btn_db_d <= btn_db;
            IF btn_db = '1' AND btn_db_d = '0' THEN
                btn_edge <= '1';
            END IF;
        END IF;
    END PROCESS;

    btn_out <= btn_db;

END ARCHITECTURE;