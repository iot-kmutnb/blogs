-- File: ws2812b_driver.vhd
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ws2812b_driver IS
    GENERIC (
        CLK_HZ : INTEGER := 50_000_000 -- Input clock frequency
    );
    PORT (
        CLK : IN STD_LOGIC; -- Clock input
        RST_N : IN STD_LOGIC; -- Async reset active low
        WR : IN STD_LOGIC; -- Write strobe input
        DATA : IN STD_LOGIC_VECTOR(23 DOWNTO 0); -- 24-bit GRB color data
        BUSY : OUT STD_LOGIC; -- High when sending data
        DOUT : OUT STD_LOGIC -- Serial data output to WS2812
    );
END ws2812b_driver;

ARCHITECTURE Behavioral OF ws2812b_driver IS

    -- Timing constants
    CONSTANT CLK_TICK_US : INTEGER := CLK_HZ / INTEGER(1e6);
    CONSTANT T0H : INTEGER := (CLK_TICK_US * 400/1000); -- '0' bit high time (0.40us)
    CONSTANT T0L : INTEGER := (CLK_TICK_US * 850/1000); -- '0' bit low time  (0.85us)
    CONSTANT T1H : INTEGER := (CLK_TICK_US * 800/1000); -- '1' bit high time (0.80us)
    CONSTANT T1L : INTEGER := (CLK_TICK_US * 450/1000); -- '1' bit low time (0.45us)

    -- FSM states
    TYPE state_type IS (IDLE, LOAD, SEND_BIT_H, SEND_BIT_L);
    SIGNAL state : state_type := IDLE;

    -- Internal signals
    SIGNAL data_reg : STD_LOGIC_VECTOR(23 DOWNTO 0) := (OTHERS => '0');
    SIGNAL bit_index : INTEGER RANGE 0 TO 23 := 23;
    SIGNAL clk_counter : INTEGER;
    SIGNAL busy_reg : STD_LOGIC := '0';
    SIGNAL dout_reg : STD_LOGIC := '0';

    SIGNAL cnt_t_high : INTEGER := 0;
    SIGNAL cnt_t_low : INTEGER := 0;

BEGIN

    -- output signal assignments
    BUSY <= busy_reg;
    DOUT <= dout_reg;

    PROCESS (CLK, RST_N)
    BEGIN
        IF RST_N = '0' THEN
            state <= IDLE;
            busy_reg <= '0';
            dout_reg <= '0';
            clk_counter <= 0;
            bit_index <= 23;
            data_reg <= (OTHERS => '0');
            cnt_t_high <= 0;
            cnt_t_low <= 0;

        ELSIF rising_edge(CLK) THEN

            CASE state IS
                WHEN IDLE =>
                    busy_reg <= '0';
                    dout_reg <= '0';
                    clk_counter <= 0;
                    bit_index <= 23;
                    IF WR = '1' THEN
                        data_reg <= DATA;
                        busy_reg <= '1';
                        state <= LOAD;
                    END IF;

                WHEN LOAD =>
                    IF data_reg(23) = '1' THEN -- MSB timing
                        cnt_t_high <= T1H;
                        cnt_t_low <= T1L;
                    ELSE
                        cnt_t_high <= T0H;
                        cnt_t_low <= T0L;
                    END IF;
                    clk_counter <= 0;
                    dout_reg <= '1';
                    state <= SEND_BIT_H;

                WHEN SEND_BIT_H =>
                    clk_counter <= clk_counter + 1;
                    IF clk_counter = cnt_t_high THEN
                        dout_reg <= '0';
                        clk_counter <= 0;
                        state <= SEND_BIT_L;
                    END IF;

                WHEN SEND_BIT_L =>
                    clk_counter <= clk_counter + 1;
                    IF clk_counter = cnt_t_low THEN
                        IF bit_index = 0 THEN -- LSB sent
                            dout_reg <= '0';
                            clk_counter <= 0;
                            busy_reg <= '0';
                            state <= IDLE;
                        ELSE
                            -- Shift data left by 1 (MSB first)
                            data_reg <= data_reg(22 DOWNTO 0) & '0';
                            bit_index <= bit_index - 1;
                            -- Setup timings for next bit
                            IF data_reg(22) = '1' THEN
                                cnt_t_high <= T1H;
                                cnt_t_low <= T1L;
                            ELSE
                                cnt_t_high <= T0H;
                                cnt_t_low <= T0L;
                            END IF;
                            clk_counter <= 0;
                            dout_reg <= '1';
                            state <= SEND_BIT_H;
                        END IF;
                    END IF;

                WHEN OTHERS =>
                    state <= IDLE;

            END CASE;
        END IF;
    END PROCESS;

END behavioral;

