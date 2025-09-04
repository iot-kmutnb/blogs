LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY lfsr IS
    GENERIC (
        N_BITS : INTEGER := 8 -- LFSR length (4..16 supported)
    );
    PORT (
        RST_N : IN STD_LOGIC; -- active low
        CLK   : IN STD_LOGIC;
        CE    : IN STD_LOGIC;
        LOAD  : IN STD_LOGIC;
        SEED  : IN STD_LOGIC_VECTOR(N_BITS - 1 DOWNTO 0);
        Q     : OUT STD_LOGIC_VECTOR(N_BITS - 1 DOWNTO 0);
        FB    : OUT STD_LOGIC
    );
END ENTITY lfsr;

ARCHITECTURE rtl OF lfsr IS
    SIGNAL reg : STD_LOGIC_VECTOR(N_BITS - 1 DOWNTO 0) := (OTHERS => '1');
    SIGNAL fb_bit : STD_LOGIC := '0';
BEGIN
    -- valid range
    ASSERT (N_BITS >= 4 AND N_BITS <= 16)
    REPORT "LFSR: N_BITS must be between 4 and 16"
        SEVERITY FAILURE;

    feedback_proc : PROCESS (reg)
    BEGIN
        CASE N_BITS IS
                -- n = 4:  x^4 + x^3 + 1 
            WHEN 4 =>
                fb_bit <= reg(N_BITS - 1) XOR reg(2);

                -- n = 5:  x^5 + x^3 + 1
            WHEN 5 =>
                fb_bit <= reg(N_BITS - 1) XOR reg(2);

                -- n = 6:  x^6 + x^5 + 1
            WHEN 6 =>
                fb_bit <= reg(N_BITS - 1) XOR reg(4);

                -- n = 7:  x^7 + x^6 + 1 
            WHEN 7 =>
                fb_bit <= reg(N_BITS - 1) XOR reg(5);

                -- n = 8:  x^8 + x^6 + x^5 + x^4 + 1
            WHEN 8 =>
                fb_bit <= reg(N_BITS - 1) XOR reg(5) XOR reg(4) XOR reg(3);

                -- n = 9:  x^9 + x^5 + 1
            WHEN 9 =>
                fb_bit <= reg(N_BITS - 1) XOR reg(4);

                -- n = 10: x^10 + x^7 + 1 
            WHEN 10 =>
                fb_bit <= reg(N_BITS - 1) XOR reg(6);

                -- n = 11: x^11 + x^9 + 1
            WHEN 11 =>
                fb_bit <= reg(N_BITS - 1) XOR reg(8);

                -- n = 12: x^12 + x^6 + x^4 + x + 1
            WHEN 12 =>
                fb_bit <= reg(N_BITS - 1) XOR reg(5) XOR reg(3) XOR reg(0);

                -- n = 13: x^13 + x^4 + x^3 + x + 1 
            WHEN 13 =>
                fb_bit <= reg(N_BITS - 1) XOR reg(3) XOR reg(2) XOR reg(0);

                -- n = 14: x^14 + x^5 + x^3 + x + 1 
            WHEN 14 =>
                fb_bit <= reg(N_BITS - 1) XOR reg(4) XOR reg(2) XOR reg(0);

                -- n = 15: x^15 + x^14 + 1 
            WHEN 15 =>
                fb_bit <= reg(N_BITS - 1) XOR reg(13);

                -- n = 16: x^16 + x^15 + x^13 + x^4 + 1
            WHEN 16 =>
                fb_bit <= reg(N_BITS - 1) XOR reg(14) XOR reg(12) XOR reg(3);

            WHEN OTHERS =>
                -- fallback: simple tap (not maximal-length)
                fb_bit <= reg(N_BITS - 1) XOR reg(N_BITS - 2);
        END CASE;
    END PROCESS;

    ----------------------------------------------------------------------------
    -- Shift register
    ----------------------------------------------------------------------------
    PROCESS (CLK, RST_N)
    BEGIN
        IF RST_N = '0' THEN
            reg <= SEED; -- async load on reset (active low)
        ELSIF rising_edge(CLK) THEN
            IF CE = '1' THEN
                IF LOAD = '1' THEN
                    reg <= SEED; -- synchronous load
                ELSE
                    -- shift left (MSB at N_BITS-1), new bit becomes LSB
                    reg <= reg(N_BITS - 2 DOWNTO 0) & fb_bit;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    Q <= reg;
    FB <= fb_bit;

END ARCHITECTURE;
