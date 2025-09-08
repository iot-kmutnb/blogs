-- Testbench for fifo_sc (single-clock FIFO)
-- ghdl -a .\ram_dp_sc.vhd .\fifo_sc.vhd .\tb_fifo_sc.vhd 
-- ghdl -e tb_fifo_sc
-- ghdl -r tb_fifo_sc --vcd=wave.vcd --stop-time=1us

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY tb_fifo_sc IS
END ENTITY;

ARCHITECTURE sim OF tb_fifo_sc IS
    -- Testbench generics
    CONSTANT DATA_WIDTH : NATURAL := 8;
    CONSTANT ADDR_WIDTH : NATURAL := 4; -- FIFO depth = 16 (small for sim)

    -- DUT ports
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL rst_n : STD_LOGIC := '0';
    SIGNAL wr_en : STD_LOGIC := '0';
    SIGNAL rd_en : STD_LOGIC := '0';
    SIGNAL din   : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dout  : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL full  : STD_LOGIC;
    SIGNAL empty : STD_LOGIC;

    SIGNAL write_data : unsigned(DATA_WIDTH - 1 DOWNTO 0) := x"A0";
BEGIN
    -- DUT instantiation
    uut : ENTITY work.fifo_sc(rtl)
        GENERIC MAP(
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
        PORT MAP(
            clk => clk,
            rst_n => rst_n,
            wr_en => wr_en,
            rd_en => rd_en,
            din => din,
            dout => dout,
            full => full,
            empty => empty
        );

    -- Clock generation (10 ns period)
    clk <= NOT clk AFTER 5 ns;

    -- Stimulus process
    stim_proc : PROCESS
        VARIABLE seed1 : POSITIVE := 1234;
        VARIABLE seed2 : POSITIVE := 5678;
        VARIABLE rand_value : real;
    BEGIN
        -- Initial reset
        rst_n <= '0';
        WAIT FOR 20 ns;
        rst_n <= '1';
        WAIT FOR 20 ns;

        WAIT UNTIL rising_edge(clk);
        -- 1. Fill the FIFO until full
        REPORT "Start writing into FIFO...";
        WHILE full = '0' LOOP
            wr_en <= '1';
            write_data <= write_data + 1;
            din <= STD_LOGIC_VECTOR(write_data);
            WAIT UNTIL rising_edge(clk);
        END LOOP;
        wr_en <= '0';
        WAIT UNTIL rising_edge(clk);
        REPORT "FIFO is FULL";

        WAIT FOR 20 ns;
        WAIT UNTIL rising_edge(clk);

        -- 2. Read out until empty
        REPORT "Start reading from FIFO...";
        WHILE empty = '0' LOOP
            uniform(seed1, seed2, rand_value);
            IF rand_value > 0.1 THEN
                rd_en <= '1';
            ELSE
                rd_en <= '0';
            END IF;
            WAIT UNTIL rising_edge(clk);
        END LOOP;
        rd_en <= '0';
        WAIT UNTIL rising_edge(clk);
        REPORT "FIFO is EMPTY";
        WAIT;
    END PROCESS;

END ARCHITECTURE;