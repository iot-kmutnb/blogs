-- Simple Dual-Port RAM with different read/write addresses but single read/write clock
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY ram_dp_sc IS
    GENERIC (
        DATA_WIDTH : NATURAL := 8;
        ADDR_WIDTH : NATURAL := 6
    );
    PORT (
        clk   : IN STD_LOGIC;
        raddr : IN NATURAL RANGE 0 TO 2**ADDR_WIDTH - 1;
        waddr : IN NATURAL RANGE 0 TO 2**ADDR_WIDTH - 1;
        data  : IN STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0);
        we    : IN STD_LOGIC := '0';
        q     : OUT STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0)
    );

END ENTITY;

ARCHITECTURE rtl OF ram_dp_sc IS
    -- Build a 2-D array type for the RAM
    SUBTYPE word_t IS STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0);
    TYPE memory_t IS ARRAY(2**ADDR_WIDTH - 1 DOWNTO 0) OF word_t;
    -- Declare the RAM signal. 
    SIGNAL ram : memory_t;

BEGIN
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (we = '1') THEN -- write new data
                ram(waddr) <= data;
            END IF;
            q <= ram(raddr);
        END IF;
    END PROCESS;
END rtl;
