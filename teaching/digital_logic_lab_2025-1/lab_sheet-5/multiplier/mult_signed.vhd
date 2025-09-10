LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY mult_signed IS
  GENERIC (
    N : INTEGER := 8 -- operand size
  );
  PORT (
    a : IN signed(N - 1 DOWNTO 0);
    b : IN signed(N - 1 DOWNTO 0);
    p : OUT signed(2 * N - 1 DOWNTO 0)
  );
END ENTITY;

-- Inferred multiplier
ARCHITECTURE rtl_infer OF mult_signed IS
BEGIN
  p <= a * b;
END rtl_infer;

-- array multiplier 
ARCHITECTURE rtl_array OF mult_signed IS
BEGIN
  PROCESS (a, b)
    VARIABLE product : signed(2 * N - 1 DOWNTO 0);
    VARIABLE pp : signed(2 * N - 1 DOWNTO 0); -- partial product
  BEGIN
    product := (OTHERS => '0');
    -- Generate partial products
    FOR i IN 0 TO N - 2 LOOP
      IF b(i) = '1' THEN
        pp := resize(a, 2 * N) SLL i; -- shift left by i
        product := product + pp;
      END IF;
    END LOOP;
    -- Handle negative numbers (2's complement)
    IF b(N - 1) = '1' THEN
      product := product - (resize(a, 2 * N) SLL (N - 1));
    END IF;
    p <= product;
  END PROCESS;
END ARCHITECTURE rtl_array;
