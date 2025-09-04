-- solution for Lab Sheet 5: lab 1

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY adder IS
    GENERIC (
        N : INTEGER := 8
    );
    PORT (
        CIN  : IN  STD_LOGIC; -- carry-in
        A, B : IN  STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- operands
        SUM  : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- result
        COUT : OUT STD_LOGIC -- carry-out
    );
END ENTITY adder;

ARCHITECTURE RCA OF adder IS
BEGIN
    PROCESS (A, B, CIN)
        VARIABLE C : STD_LOGIC_VECTOR(0 TO N); -- carry chain
        VARIABLE S : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    BEGIN
        C(0) := CIN;
        FOR i IN 0 TO N - 1 LOOP
            S(i) := A(i) XOR B(i) XOR C(i);
            C(i + 1) := (A(i) AND B(i)) OR (C(i) AND (A(i) XOR B(i)));
        END LOOP;
        SUM <= S;
        COUT <= C(N);
    END PROCESS;
END ARCHITECTURE RCA;

ARCHITECTURE CSA OF adder IS
BEGIN
    PROCESS (A, B, CIN)
        VARIABLE C : STD_LOGIC_VECTOR(0 TO N);
        VARIABLE S : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        VARIABLE sum0, sum1 : STD_LOGIC;
        VARIABLE c0, c1 : STD_LOGIC;
    BEGIN
        C(0) := CIN;
        FOR i IN 0 TO N - 1 LOOP
            -- Precompute both cases
            sum0 := A(i) XOR B(i); -- assuming carry = 0
            c0 := A(i) AND B(i);

            sum1 := NOT(A(i) XOR B(i)); -- assuming carry = 1
            c1 := (A(i) AND B(i)) OR (A(i) XOR B(i));

            -- Select based on actual carry-in
            IF C(i) = '0' THEN
                S(i) := sum0;
                C(i + 1) := c0;
            ELSE
                S(i) := sum1;
                C(i + 1) := c1;
            END IF;
        END LOOP;
        SUM <= S;
        COUT <= C(N);
    END PROCESS;
END ARCHITECTURE CSA;
