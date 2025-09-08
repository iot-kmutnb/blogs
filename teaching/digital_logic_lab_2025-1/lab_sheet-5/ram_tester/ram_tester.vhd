LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ram_tester IS
    GENERIC (
        DATA_WIDTH : INTEGER := 8;
        ADDR_WIDTH : INTEGER := 16
    );
    PORT (
        RST_N     : IN STD_LOGIC; -- active-low reset
        CLK       : IN STD_LOGIC; -- system clock
        START     : IN STD_LOGIC; -- start pulse
        SW        : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0); -- SEED
        LED_DONE  : OUT STD_LOGIC;
        LED_ERROR : OUT STD_LOGIC
    );
END ENTITY ram_tester;

ARCHITECTURE rtl OF ram_tester IS

    CONSTANT MAX_ADDR : INTEGER := 2 ** ADDR_WIDTH - 1;
    -- RAM
    SIGNAL ram_din  : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL ram_dout : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL ram_addr : unsigned(ADDR_WIDTH - 1 DOWNTO 0);
    SIGNAL ram_we   : STD_LOGIC;

    -- LFSR
    SIGNAL lfsr_q    : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL lfsr_q_d  : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL lfsr_ce   : STD_LOGIC := '0';
    SIGNAL lfsr_load : STD_LOGIC := '0';

    -- FSM
    TYPE state_t IS (ST_IDLE, ST_WR, ST_WR_NEXT, ST_RD_SETUP, 
                ST_RD_WAIT, ST_CHECK, ST_DONE);
    SIGNAL st : state_t;

    SIGNAL error_s : STD_LOGIC := '0';
    SIGNAL start_sync : STD_LOGIC_VECTOR(1 DOWNTO 0) := "11";

BEGIN

    --------------------------------------------------------------------
    -- RAM instance
    --------------------------------------------------------------------
    ram_inst : ENTITY work.RAM_SP
        GENERIC MAP(
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
        PORT MAP(
            CLK => CLK,
            WE => ram_we,
            ADDR => ram_addr,
            DIN => ram_din,
            DOUT => ram_dout
        );

    --------------------------------------------------------------------
    -- LFSR instance
    --------------------------------------------------------------------
    lfsr_inst : ENTITY work.LFSR
        GENERIC MAP(
            N_BITS => DATA_WIDTH
        )
        PORT MAP(
            CLK => CLK,
            RST_N => RST_N,
            CE => lfsr_ce,
            LOAD => lfsr_load,
            SEED => SW,
            Q => lfsr_q,
            FB => OPEN
        );

    ram_din <= lfsr_q WHEN st = ST_WR OR st = ST_WR_NEXT ELSE
        (OTHERS => '0');

    --------------------------------------------------------------------
    -- FSM
    --------------------------------------------------------------------
    PROCESS (CLK, RST_N)
    BEGIN
        IF RST_N = '0' THEN
            st <= ST_IDLE;
            ram_addr <= (OTHERS => '0');
            ram_we <= '0';
            lfsr_ce <= '0';
            lfsr_load <= '0';
            lfsr_q_d <= (OTHERS => '0');
            error_s <= '0';
            start_sync <= "11";

        ELSIF rising_edge(CLK) THEN
            -- defaults
            ram_we <= '0';
            lfsr_ce <= '0';
            lfsr_load <= '0';

            -- sync START input
            start_sync <= start_sync(0) & START;

            CASE st IS
                WHEN ST_IDLE =>
                    ram_addr <= (OTHERS => '0');
                    error_s <= '0';
                    IF start_sync = "01" THEN
                        lfsr_load <= '1'; -- load seed into LFSR
                        lfsr_ce <= '1';
                        st <= ST_WR;
                    END IF;

                    -- Write phase
                WHEN ST_WR =>
                    ram_we <= '1';
                    lfsr_ce <= '0';
                    st <= ST_WR_NEXT;

                WHEN ST_WR_NEXT =>
                    IF ram_addr = MAX_ADDR THEN
                        ram_addr <= (OTHERS => '0');
                        lfsr_load <= '1';
                        lfsr_ce <= '1';
                        ram_we <= '0';
                        st <= ST_RD_SETUP;
                    ELSE
                        lfsr_ce <= '1';
                        ram_addr <= ram_addr + 1;
                        st <= ST_WR;
                    END IF;

                    -- Read/compare phase
                WHEN ST_RD_SETUP =>
                    lfsr_load <= '0';
                    lfsr_ce <= '0';
                    st <= ST_RD_WAIT;

                WHEN ST_RD_WAIT =>
                    lfsr_q_d <= lfsr_q;
                    st <= ST_CHECK;
                    lfsr_ce <= '1';

                WHEN ST_CHECK =>
                    lfsr_ce <= '0';
                    IF ram_dout /= lfsr_q_d THEN
                        error_s <= '1';
                    END IF;
                    IF ram_addr = MAX_ADDR THEN
                        st <= ST_DONE;
                    ELSE
                        ram_addr <= ram_addr + 1;
                        st <= ST_RD_WAIT;
                    END IF;

                    ----------------------------------------------------------------
                WHEN ST_DONE =>
                    lfsr_ce <= '0';
                    -- stay here until reset
                    st <= ST_DONE;

            END CASE;
        END IF;
    END PROCESS;

    LED_DONE <= '1' WHEN st = ST_DONE ELSE
        '0';
    LED_ERROR <= error_s;

END ARCHITECTURE;
