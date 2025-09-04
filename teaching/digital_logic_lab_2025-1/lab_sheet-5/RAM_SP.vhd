-- single-port synchronous RAM
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY RAM_SP IS
    GENERIC (
        DATA_WIDTH : INTEGER := 8;
        ADDR_WIDTH : INTEGER := 8
    );
    PORT (
        CLK  : IN STD_LOGIC; -- system clock
        WE   : IN STD_LOGIC; -- write enable
        ADDR : IN UNSIGNED(ADDR_WIDTH - 1 DOWNTO 0);
        DIN  : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        DOUT : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)
    );
END ENTITY RAM_SP;

ARCHITECTURE rtl OF RAM_SP IS
    TYPE ram_t IS ARRAY (0 TO 2 ** ADDR_WIDTH - 1) 
         OF STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

    FUNCTION init_ram
        RETURN ram_t IS
        VARIABLE tmp : ram_t := (OTHERS => (OTHERS => '0'));
    BEGIN
        FOR addr_pos IN 0 TO 2 ** ADDR_WIDTH - 1 LOOP
            -- Initialize each address with the address itself
            tmp(addr_pos) := STD_LOGIC_VECTOR(to_unsigned(addr_pos, DATA_WIDTH));
        END LOOP;
        RETURN tmp;
    END init_ram;

    --signal ram : ram_t := init_ram;
    SIGNAL ram : ram_t;
    SIGNAL addr_reg : NATURAL RANGE 0 TO 2 ** ADDR_WIDTH - 1 := 0;

BEGIN
    PROCESS (CLK)
    BEGIN
        IF rising_edge(CLK) THEN
            IF WE = '1' THEN
                ram(to_integer(ADDR)) <= DIN; -- synchronous write operation
            END IF;
            addr_reg <= to_integer(ADDR);
        END IF;
    END PROCESS;
    DOUT <= ram(addr_reg); -- synchronous read operation

END ARCHITECTURE;
