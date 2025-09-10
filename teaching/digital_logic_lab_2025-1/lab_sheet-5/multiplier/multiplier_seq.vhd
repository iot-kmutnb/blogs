LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY multiplier IS
    PORT (
        CLK   : IN STD_LOGIC; -- system clock
        RST_N : IN STD_LOGIC; -- async active-low reset
        SW    : IN  STD_LOGIC_VECTOR(9 DOWNTO 0); -- multiplier input
        HEX0  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- 7-seg outputs
        HEX1  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        HEX2  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        HEX3  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rtl OF multiplier IS
    SIGNAL a_reg, b_reg : signed(4 DOWNTO 0);
    SIGNAL p, p_reg : signed(9 DOWNTO 0);
    SIGNAL start : STD_LOGIC;
    SIGNAL ready : STD_LOGIC;

    -- BCD digits
    SIGNAL bcd1 : unsigned(3 DOWNTO 0);
    SIGNAL bcd2 : unsigned(3 DOWNTO 0);
    SIGNAL bcd3 : unsigned(3 DOWNTO 0);
    SIGNAL sign_flag : STD_LOGIC;

    -- 7-segment decode
    FUNCTION bcd2seg7(d : unsigned(3 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
        VARIABLE seg : STD_LOGIC_VECTOR(7 DOWNTO 0);
    BEGIN
        CASE d IS
            WHEN "0000" => seg := "11000000"; -- 0
            WHEN "0001" => seg := "11111001"; -- 1
            WHEN "0010" => seg := "10100100"; -- 2
            WHEN "0011" => seg := "10110000"; -- 3
            WHEN "0100" => seg := "10011001"; -- 4
            WHEN "0101" => seg := "10010010"; -- 5
            WHEN "0110" => seg := "10000010"; -- 6
            WHEN "0111" => seg := "11111000"; -- 7
            WHEN "1000" => seg := "10000000"; -- 8
            WHEN "1001" => seg := "10010000"; -- 9
            WHEN OTHERS => seg := "11111111"; -- blank
        END CASE;
        RETURN seg;
    END FUNCTION;

    CONSTANT SEG_MINUS : STD_LOGIC_VECTOR(7 DOWNTO 0) := "10111111";
    CONSTANT SEG_BLANK : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11111111";

BEGIN
    --------------------------------------------------------------------
    -- Register inputs and generate start pulse
    --------------------------------------------------------------------
    PROCESS (clk, rst_n)
    BEGIN
        IF rst_n = '0' THEN
            a_reg <= (OTHERS => '0');
            b_reg <= (OTHERS => '0');
            start <= '0';
        ELSIF rising_edge(clk) THEN
            a_reg <= signed(SW(4 DOWNTO 0));
            b_reg <= signed(SW(9 DOWNTO 5));
            start <= '1'; -- start multiplication every cycle new input
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- Instantiate multi-cycle signed multiplier
    --------------------------------------------------------------------
    mult_inst : ENTITY work.mult_signed(rtl_mult_seq)
        GENERIC MAP(N => 5)
        PORT MAP(
            clk => clk,
            rst_n => rst_n,
            start => start,
            a => a_reg,
            b => b_reg,
            p => p,
            ready => ready
        );

    --------------------------------------------------------------------
    -- Capture result when done
    --------------------------------------------------------------------
    PROCESS (clk, rst_n)
    BEGIN
        IF rst_n = '0' THEN
            p_reg <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF ready = '1' THEN
                p_reg <= p;
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- Convert p_reg to BCD
    --------------------------------------------------------------------
    PROCESS (p_reg)
        VARIABLE temp : unsigned(9 DOWNTO 0);
    BEGIN
        IF p_reg < 0 THEN
            sign_flag <= '1';
            temp := unsigned(-p_reg);
        ELSE
            sign_flag <= '0';
            temp := unsigned(p_reg);
        END IF;

        bcd3 <= resize((temp / 100) MOD 10, 4);
        bcd2 <= resize((temp / 10) MOD 10, 4);
        bcd1 <= resize(temp MOD 10, 4);
    END PROCESS;

    --------------------------------------------------------------------
    -- Drive 7-segment displays
    --------------------------------------------------------------------
    HEX0 <= bcd2seg7(bcd1);
    HEX1 <= bcd2seg7(bcd2);
    HEX2 <= bcd2seg7(bcd3);
    HEX3 <= SEG_MINUS WHEN sign_flag = '1' ELSE SEG_BLANK;

END ARCHITECTURE;
