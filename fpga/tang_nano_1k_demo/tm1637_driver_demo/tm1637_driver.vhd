-- File: tm1637_driver.vhd
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tm1637_driver IS
    PORT (
        CLK    : IN STD_LOGIC;
        RST_N  : IN STD_LOGIC;
        START  : IN STD_LOGIC; -- start write operation
        STOP   : IN STD_LOGIC;
        DC     : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- data or cmd byte
        TM_CLK : INOUT STD_LOGIC;
        TM_DIO : INOUT STD_LOGIC;
        DONE   : OUT STD_LOGIC;
        ACK    : OUT STD_LOGIC -- ACK or NACK status
    );
END tm1637_driver;

ARCHITECTURE behavioral OF tm1637_driver IS

    TYPE state_type IS (
        ST_IDLE,
        ST_START,
        ST_SHIFT_CLK_L,
        ST_SHIFT_CLK_H,
        ST_ACK,
        ST_READ_ACK,
        ST_STOP,
        ST_DONE
    );

    SIGNAL state      : state_type := ST_IDLE;
    SIGNAL next_state : state_type := ST_IDLE;

    SIGNAL bit_cnt    : INTEGER RANGE 0 TO 7 := 0;
    SIGNAL shift_reg  : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

    -- Output control signals
    SIGNAL tm_clk_oe  : STD_LOGIC := '0'; -- 1 = drive, 0 = high-Z
    SIGNAL tm_dio_oe  : STD_LOGIC := '0'; -- 1 = drive, 0 = high-Z

    -- Clock divider: adjust for target frequency
    --CONSTANT CLK_DIV : INTEGER := 125;
    CONSTANT CLK_DIV   : INTEGER := 1000;
    --CONSTANT CLK_DIV : INTEGER := 5000;
    SIGNAL clk_count   : INTEGER RANGE 0 TO CLK_DIV - 1 := 0;
    SIGNAL clk_en      : STD_LOGIC := '0';

    -- ACK read
    SIGNAL ack_bit     : STD_LOGIC := '1';
    SIGNAL stop_bit    : STD_LOGIC := '1';

BEGIN
    -- Assign outputs
    TM_CLK <= '0' WHEN tm_clk_oe = '1' ELSE 'Z';
    TM_DIO <= '0' WHEN tm_dio_oe = '1' ELSE 'Z';
    ACK <= ack_bit;

    -- Clock Divider: Generate clk_en pulse
    clk_div_proc : PROCESS (RST_N, CLK)
    BEGIN
        IF RST_N = '0' THEN
            clk_count <= 0;
            clk_en <= '0';
        ELSIF rising_edge(CLK) THEN
            IF clk_count = CLK_DIV - 1 THEN
                clk_count <= 0;
                clk_en <= '1';
            ELSE
                clk_count <= clk_count + 1;
                clk_en <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- FSM Process
    fsm_proc : PROCESS (RST_N, CLK)
    BEGIN
        IF RST_N = '0' THEN
            state     <= ST_IDLE;
            tm_clk_oe <= '0';
            tm_dio_oe <= '0';
            bit_cnt   <= 0;
            ack_bit   <= '1';
            stop_bit  <= '1';
            DONE      <= '1';

        ELSIF rising_edge(CLK) THEN
            IF clk_en = '1' THEN
                CASE state IS
                    WHEN ST_IDLE =>
                        DONE <= '1';
                        tm_clk_oe <= '0'; -- CLK 'H'
                        tm_dio_oe <= '0'; -- DIO 'H'
                        IF START = '1' THEN
                            state <= ST_START;
                        END IF;

                    WHEN ST_START =>
                        DONE <= '0';
                        stop_bit <= STOP;
                        shift_reg <= DC;
                        tm_dio_oe <= '1'; -- DIO '0'
                        bit_cnt <= 0;
                        state <= ST_SHIFT_CLK_L;

                    WHEN ST_SHIFT_CLK_L =>
                        tm_clk_oe <= '1'; -- CLK '0'
                        state <= ST_SHIFT_CLK_H;
                        tm_dio_oe <= NOT shift_reg(0); -- LSB first
                        shift_reg <= '0' & shift_reg(7 DOWNTO 1);

                    WHEN ST_SHIFT_CLK_H =>
                        tm_clk_oe <= '0'; -- CLK 'H'
                        IF bit_cnt = 7 THEN
                            state <= ST_ACK;
                        ELSE
                            bit_cnt <= bit_cnt + 1;
                            state <= ST_SHIFT_CLK_L;
                        END IF;

                    WHEN ST_ACK =>
                        tm_clk_oe <= '1'; -- CLK '0'
                        tm_dio_oe <= '0'; -- release line
                        DONE <= '1';
                        state <= ST_READ_ACK;

                    WHEN ST_READ_ACK =>
                        ack_bit <= TM_DIO; -- read ACK
                        tm_dio_oe <= '1'; -- DIO '0'
                        tm_clk_oe <= '0'; -- CLK 'H'
                        state <= ST_DONE;

                    WHEN ST_DONE =>
                        tm_dio_oe <= '1'; -- DIO '0'
                        tm_clk_oe <= '1'; -- CLK '0'
                        state <= ST_STOP;

                    WHEN ST_STOP =>
                        IF stop_bit = '0' THEN
                            tm_clk_oe <= '1'; -- CLK '0'
                            state <= ST_START;
                        ELSE
                            tm_clk_oe <= '0'; -- CLK 'H'
                            state <= ST_IDLE;
                        END IF;

                    WHEN OTHERS =>
                        state <= ST_IDLE;

                END CASE;
            END IF;
        END IF;
    END PROCESS;

END behavioral;

