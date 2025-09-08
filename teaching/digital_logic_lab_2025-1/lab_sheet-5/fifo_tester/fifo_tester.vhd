LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fifo_tester IS
    PORT (
        RST_N : IN STD_LOGIC; -- active-low reset
        CLK   : IN STD_LOGIC; -- 50 MHz clock
        TEST  : IN STD_LOGIC; -- test button
        PUT   : IN STD_LOGIC; -- FIFO put operation
        GET   : IN STD_LOGIC; -- FIFO get operation
        FULL  : OUT STD_LOGIC; -- FIFO full flag -> LED
        EMPTY : OUT STD_LOGIC; -- FIFO empty flag -> LED
        HEX3  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- output data high digit
        HEX2  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- output data low digit
        HEX1  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- input data high digit
        HEX0  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) -- input data low digit
    );
END ENTITY;

ARCHITECTURE rtl OF fifo_tester IS

    -- FIFO signals
    SIGNAL wr_en : STD_LOGIC := '0';
    SIGNAL rd_en : STD_LOGIC := '0';
    SIGNAL din   : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dout  : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL is_full  : STD_LOGIC;
    SIGNAL is_empty : STD_LOGIC;

    -- 8-bit counter for test data
    CONSTANT COUNT_INIT : unsigned(7 DOWNTO 0) := x"A0";
    SIGNAL counter : unsigned(7 DOWNTO 0) := COUNT_INIT;

    -- Timer for 100 ms interval
    CONSTANT TICKS_100MS : INTEGER := 10000000; -- 50 MHz * 0.1 s
    SIGNAL tick_cnt : INTEGER RANGE 0 TO TICKS_100MS := 0;
    SIGNAL tick_100ms : STD_LOGIC := '0';

    -- BCD display signals
    SIGNAL digit3 : unsigned(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL digit2 : unsigned(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL digit1 : unsigned(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL digit0 : unsigned(3 DOWNTO 0) := (OTHERS => '0');

    -- Debounced TEST button
    SIGNAL test_db : STD_LOGIC;
    SIGNAL test_edge : STD_LOGIC;

    -- Function: 4-bit hex (0–F) to 7-segment code (active low)
    FUNCTION bin2seg7(d : unsigned(3 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
        VARIABLE seg : STD_LOGIC_VECTOR(6 DOWNTO 0);
    BEGIN
        CASE d IS
            WHEN "0000" => seg := "1000000"; -- 0
            WHEN "0001" => seg := "1111001"; -- 1
            WHEN "0010" => seg := "0100100"; -- 2
            WHEN "0011" => seg := "0110000"; -- 3
            WHEN "0100" => seg := "0011001"; -- 4
            WHEN "0101" => seg := "0010010"; -- 5
            WHEN "0110" => seg := "0000010"; -- 6
            WHEN "0111" => seg := "1111000"; -- 7
            WHEN "1000" => seg := "0000000"; -- 8
            WHEN "1001" => seg := "0010000"; -- 9
            WHEN "1010" => seg := "0001000"; -- A
            WHEN "1011" => seg := "0000011"; -- b
            WHEN "1100" => seg := "1000110"; -- C
            WHEN "1101" => seg := "0100001"; -- d
            WHEN "1110" => seg := "0000110"; -- E
            WHEN "1111" => seg := "0001110"; -- F
            WHEN OTHERS => seg := "1111111"; -- blank
        END CASE;
        RETURN seg;
    END FUNCTION;
BEGIN

    -- FIFO instantiation
    u_fifo : ENTITY work.fifo_sc
        GENERIC MAP(
            DATA_WIDTH => 8,
            ADDR_WIDTH => 4 -- depth = 16
        )
        PORT MAP(
            clk => CLK,
            rst_n => RST_N,
            wr_en => wr_en,
            rd_en => rd_en,
            din => din,
            dout => dout,
            full => is_full,
            empty => is_empty
        );

    -- Debounce TEST button
    u_test : ENTITY work.btn_debounce
        GENERIC MAP(WIDTH => 16)
        PORT MAP(
            clk => CLK,
            rst_n => RST_N,
            btn_in => TEST,
            btn_out => test_db,
            btn_edge => test_edge
        );

    -- 100 ms tick generator
    PROCESS (CLK, RST_N)
    BEGIN
        IF RST_N = '0' THEN
            tick_cnt <= 0;
            tick_100ms <= '0';
        ELSIF rising_edge(CLK) THEN
            IF tick_cnt = TICKS_100MS - 1 THEN
                tick_cnt <= 0;
                tick_100ms <= '1';
            ELSE
                tick_cnt <= tick_cnt + 1;
                tick_100ms <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- Control logic for push/pop every 100 ms
    PROCESS (CLK, RST_N)
    BEGIN
        IF RST_N = '0' THEN
            wr_en <= '0';
            rd_en <= '0';
            counter <= COUNT_INIT;
        ELSIF rising_edge(CLK) THEN
            wr_en <= '0';
            rd_en <= '0';

            IF tick_100ms = '1' THEN
                -- put if TEST held and PUT = 1
                IF test_db = '0' AND PUT = '1' AND is_full = '0' THEN
                    din <= STD_LOGIC_VECTOR(counter);
                    wr_en <= '1';
                    counter <= counter + 1;
                END IF;

                -- Pop if TEST held and GET = 1
                IF test_db = '0' AND GET = '1' AND is_empty = '0' THEN
                    rd_en <= '1';
                END IF;
            END IF;
        END IF;
    END PROCESS;

    PROCESS (dout)
        VARIABLE val : INTEGER;
    BEGIN
        val := to_integer(unsigned(dout));
        digit3 <= to_unsigned(val / 16, 4);
        digit2 <= to_unsigned(val MOD 16, 4);
    END PROCESS;

    PROCESS (din)
        VARIABLE val : INTEGER;
    BEGIN
        val := to_integer(unsigned(din));
        digit1 <= to_unsigned(val / 16, 4);
        digit0 <= to_unsigned(val MOD 16, 4);
    END PROCESS;

    -- 7-seg display outputs
    HEX3 <= bin2seg7(digit3);
    HEX2 <= bin2seg7(digit2);

    -- 7-seg display inputs
    HEX1 <= bin2seg7(digit1);
    HEX0 <= bin2seg7(digit0);

    FULL <= is_full;
    EMPTY <= is_empty;

END ARCHITECTURE;

