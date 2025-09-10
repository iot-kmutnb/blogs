LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY mult_signed IS
    GENERIC (
        N : INTEGER := 8 -- operand size
    );
    PORT (
        clk   : IN STD_LOGIC;
        rst_n : IN STD_LOGIC;
        start : IN STD_LOGIC; -- start multiplication
        a     : IN signed(N - 1 DOWNTO 0);
        b     : IN signed(N - 1 DOWNTO 0);
        p     : OUT signed(2 * N - 1 DOWNTO 0);
        ready : OUT STD_LOGIC -- high when result is ready
    );
END ENTITY;

ARCHITECTURE rtl_mult_seq OF mult_signed IS
    SIGNAL product : signed(2 * N - 1 DOWNTO 0);
    SIGNAL multiplicand : signed(2 * N - 1 DOWNTO 0);
    SIGNAL multiplier : signed(N - 1 DOWNTO 0);
    SIGNAL count : INTEGER RANGE 0 TO N;
    SIGNAL busy : STD_LOGIC;
BEGIN

    PROCESS (clk, rst_n)
    BEGIN
        IF rst_n = '0' THEN
            product <= (OTHERS => '0');
            multiplicand <= (OTHERS => '0');
            multiplier <= (OTHERS => '0');
            count <= 0;
            busy <= '0';
            ready <= '0';
            p <= (OTHERS => '0');

        ELSIF rising_edge(clk) THEN
            ready <= '0';
            -- load operands on start
            IF start = '1' AND busy = '0' THEN
                multiplicand <= resize(a, 2 * N);
                multiplier <= b;
                product <= (OTHERS => '0');
                count <= 0;
                busy <= '1';
            ELSIF busy = '1' THEN
                -- add shifted multiplicand if current multiplier bit is 1
                IF multiplier(count) = '1' THEN
                    IF count = N - 1 THEN
                        product <= product - (multiplicand SLL count);
                    ELSE
                        product <= product + (multiplicand SLL count);
                    END IF;
                END IF;
                -- last cycle?
                IF count = N THEN
                    busy <= '0';
                    ready <= '1';
                    p <= product;
                    count <= 0;
                ELSE
                    count <= count + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE;
