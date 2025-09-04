LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY lfsr_demo IS
    GENERIC (
        N_BITS  : INTEGER := 4;
        CLK_DIV : INTEGER := 50000
    );
    PORT (
        RST_N : IN STD_LOGIC; -- async. active-low reset
        CLK   : IN STD_LOGIC; -- system clock
        BTN   : IN STD_LOGIC; -- load seed into LFSR
        SW    : IN STD_LOGIC_VECTOR(N_BITS - 1 DOWNTO 0); -- seed value
        FB    : OUT STD_LOGIC; -- feedback bit
        PULSE : OUT STD_LOGIC -- single-cycle pulse
    );
END ENTITY lfsr_demo;

ARCHITECTURE rtl OF lfsr_demo IS
    -- Clock divider signals
    SIGNAL clk_div_cnt : unsigned(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL lfsr_ce     : STD_LOGIC := '0';
    SIGNAL lfsr_load   : STD_LOGIC := '0';
    SIGNAL lfsr_q      : STD_LOGIC_VECTOR(N_BITS - 1 DOWNTO 0);
    SIGNAL lfsr_seed   : STD_LOGIC_VECTOR(N_BITS - 1 DOWNTO 0) := (OTHERS => '1');
    SIGNAL btn_sync    : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '1');

BEGIN

    PROCESS (CLK, RST_N)
    BEGIN
        IF RST_N = '0' THEN
            clk_div_cnt <= (OTHERS => '0');
            lfsr_ce   <= '0';
            lfsr_load <= '0';
            btn_sync  <= (OTHERS => '1');

        ELSIF rising_edge(CLK) THEN
            lfsr_ce   <= '0';
            lfsr_load <= '0';
            btn_sync  <= btn_sync(0) & BTN;
            IF btn_sync = "01" THEN
                lfsr_ce   <= '1';
                lfsr_load <= '1';
                lfsr_seed <= SW;
                clk_div_cnt <= (OTHERS => '0');
            ELSIF clk_div_cnt = CLK_DIV - 1 THEN
                clk_div_cnt <= (OTHERS => '0');
                lfsr_ce <= '1';
            ELSE
                clk_div_cnt <= clk_div_cnt + 1;
            END IF;
        END IF;
    END PROCESS;

    ----------------------------------------------------------------
    -- Instantiate the N-bit LFSR
    ----------------------------------------------------------------
    lfsr_inst : ENTITY work.LFSR
        GENERIC MAP(N_BITS => N_BITS)
        PORT MAP(
            RST_N => RST_N,
            CLK => CLK,
            LOAD => lfsr_load,
            SEED => lfsr_seed,
            CE => lfsr_ce,
            Q => lfsr_q,
            FB => FB
        );

    PULSE <= '1' WHEN lfsr_seed = lfsr_q ELSE
        '0';

END ARCHITECTURE rtl;
