LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY accumulator IS
    GENERIC (
        N : INTEGER := 8; -- input width
        M : INTEGER := 12 -- accumulator width, M > N
    );
    PORT (
        RST_N : IN STD_LOGIC; -- async reset, active-low
        CLK : IN STD_LOGIC;
        CE : IN STD_LOGIC; -- single-cycle clock enable
        DATA : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        Q : OUT STD_LOGIC_VECTOR(M - 1 DOWNTO 0)
    );
END ENTITY accumulator;

ARCHITECTURE rtl OF accumulator IS

    -- zero-extended input
    SIGNAL input_ext : STD_LOGIC_VECTOR(M - 1 DOWNTO 0);
    SIGNAL acc_reg : STD_LOGIC_VECTOR(M - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL sum : STD_LOGIC_VECTOR(M - 1 DOWNTO 0);

    -- Component declaration of ADDER
    COMPONENT ADDER
        GENERIC (
            N : INTEGER := 8
        );
        PORT (
            CIN : IN STD_LOGIC;
            A, B : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            SUM : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            COUT : OUT STD_LOGIC
        );
    END COMPONENT;

BEGIN

    -- zero-extend N-bit input to M bits
    input_ext <= (M - 1 DOWNTO N => '0') & DATA;

    -- instantiate adder (Ripple-Carry or CSA can be chosen via configuration)
    U_ADDER : ENTITY work.ADDER(CSA)
        GENERIC MAP(
            N => M
        )
        PORT MAP(
            CIN => '0',
            A => acc_reg,
            B => input_ext,
            SUM => sum,
            COUT => OPEN
        );

    -- update accumulator on rising edge of btn_pulse
    PROCESS (CLK, RST_N)
    BEGIN
        IF RST_N = '0' THEN
            acc_reg <= (OTHERS => '0');
        ELSIF rising_edge(CLK) THEN
            IF CE = '1' THEN
                acc_reg <= sum;
            END IF;
        END IF;
    END PROCESS;

    Q <= acc_reg;

END ARCHITECTURE rtl;

---------------------------------------------------------------
