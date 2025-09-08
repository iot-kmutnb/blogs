LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_adder IS
END ENTITY tb_adder;

ARCHITECTURE sim OF tb_adder IS
    CONSTANT N  : INTEGER := 8;

    SIGNAL CIN  : STD_LOGIC := '0';
    SIGNAL A, B : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    SIGNAL SUM  : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    SIGNAL COUT : STD_LOGIC;

    -- DUT: Try RCA or CSA here
    COMPONENT ADDER IS
        GENERIC (N : INTEGER := 8);
        PORT (
            CIN  : IN STD_LOGIC;
            A, B : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            SUM  : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            COUT : OUT STD_LOGIC
        );
    END COMPONENT;

BEGIN
    -- Instantiate an adder
    uut : ENTITY work.adder(RCA)
        GENERIC MAP(N => N)
        PORT MAP(
            CIN => CIN, A => A, B => B,
            SUM => SUM, COUT => COUT
        );

    -- Test process
    stim_proc : PROCESS
        VARIABLE expected : UNSIGNED(N DOWNTO 0); -- N bits + carry
    BEGIN
        FOR intA IN 0 TO 2 ** N - 1 LOOP
            FOR intB IN 0 TO 2 ** N - 1 LOOP
                -- apply inputs
                A <= STD_LOGIC_VECTOR(to_unsigned(intA, N));
                B <= STD_LOGIC_VECTOR(to_unsigned(intB, N));

                CIN <= '0';
                WAIT FOR 10 ns;

                expected := to_unsigned(intA + intB, N + 1);
                ASSERT (unsigned(SUM) = expected(N - 1 DOWNTO 0) AND
                COUT = STD_LOGIC(expected(N)))
                REPORT "Mismatch CIN=0: A=" & INTEGER'IMAGE(intA) &
                    " B=" & INTEGER'IMAGE(intB) &
                    " SUM=" & INTEGER'IMAGE(to_integer(unsigned(SUM))) &
                    " COUT=" & STD_LOGIC'IMAGE(COUT)
                    SEVERITY ERROR;

                CIN <= '1';
                WAIT FOR 10 ns;

                expected := to_unsigned(intA + intB + 1, N + 1);
                ASSERT (unsigned(SUM) = expected(N - 1 DOWNTO 0) AND
                COUT = STD_LOGIC(expected(N)))
                REPORT "Mismatch CIN=0: A=" & INTEGER'IMAGE(intA) &
                    " B=" & INTEGER'IMAGE(intB) &
                    " SUM=" & INTEGER'IMAGE(to_integer(unsigned(SUM))) &
                    " COUT=" & STD_LOGIC'IMAGE(COUT)
                    SEVERITY ERROR;

            END LOOP;
        END LOOP;
        WAIT; -- stop simulation
    END PROCESS;

END ARCHITECTURE sim;
