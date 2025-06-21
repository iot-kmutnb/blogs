-- File: tm1637_driver_demo.vhd
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tm1637_driver_demo IS
    PORT (
        CLK    : IN STD_LOGIC;
        RST_N  : IN STD_LOGIC;
        TM_CLK : INOUT STD_LOGIC;
        TM_DIO : INOUT STD_LOGIC
    );
END tm1637_driver_demo;

ARCHITECTURE behavioral OF tm1637_driver_demo IS

    -- TM1637 driver interface
    SIGNAL start : STD_LOGIC := '0';
    SIGNAL stop  : STD_LOGIC := '1';
    SIGNAL done  : STD_LOGIC;
    SIGNAL ack   : STD_LOGIC;
    SIGNAL dc    : STD_LOGIC_VECTOR(7 DOWNTO 0); -- DATA / CMD byte

    -- FSM
    TYPE state_type IS (
       ST_INIT, ST_LOAD, ST_SEND, ST_WAIT_START, ST_WAIT_DONE, ST_DELAY
    );

    SIGNAL state : state_type := ST_INIT;
    SIGNAL index : INTEGER RANGE 0 TO 6 := 0;

    CONSTANT DELAY_CNT_MAX : INTEGER := 5_000_000 - 1;
    SIGNAL delay_cnt : INTEGER RANGE 0 TO DELAY_CNT_MAX := 0;

    -- Counter for display
    SIGNAL count  : INTEGER RANGE 0 TO 9999 := 0;
    SIGNAL digit0 : INTEGER RANGE 0 TO 9 := 0; -- Units
    SIGNAL digit1 : INTEGER RANGE 0 TO 9 := 0; -- Tens
    SIGNAL digit2 : INTEGER RANGE 0 TO 9 := 0; -- Hundreds
    SIGNAL digit3 : INTEGER RANGE 0 TO 9 := 0; -- Thousands

    -- TM1637 data sequence (7 commands total)
    TYPE data_array IS ARRAY (0 TO 6) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL data_seq : data_array;

    -- 7-segment encoding function
    FUNCTION to_7seg(val : INTEGER) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        CASE val IS
            WHEN 0 => RETURN "00111111";
            WHEN 1 => RETURN "00000110";
            WHEN 2 => RETURN "01011011";
            WHEN 3 => RETURN "01001111";
            WHEN 4 => RETURN "01100110";
            WHEN 5 => RETURN "01101101";
            WHEN 6 => RETURN "01111101";
            WHEN 7 => RETURN "00000111";
            WHEN 8 => RETURN "01111111";
            WHEN 9 => RETURN "01101111";
            WHEN OTHERS => RETURN "00000000";
        END CASE;
    END FUNCTION;

BEGIN
    -- TM1637 Driver Instance
    driver_inst : ENTITY work.tm1637_driver
        PORT MAP(
            CLK    => CLK,
            RST_N  => RST_N,
            START  => start,
            STOP   => stop,
            DC     => dc,
            TM_CLK => TM_CLK,
            TM_DIO => TM_DIO,
            DONE   => done,
            ACK => ack
        );

    -- FSM Process
    PROCESS (CLK, RST_N)
    BEGIN
        IF RST_N = '0' THEN
            state <= ST_INIT;
            start <= '0';
            stop  <= '1';
            index <= 0;
            delay_cnt <= 0;
            count <= 0;

        ELSIF rising_edge(CLK) THEN
            CASE state IS

                WHEN ST_INIT =>
                    start <= '0';
                    stop  <= '1';
                    index <= 0;
                    state <= ST_LOAD;

                WHEN ST_LOAD =>
                    -- Split count into BCD digits
                    digit0 <= count MOD 10;
                    digit1 <= (count / 10) MOD 10;
                    digit2 <= (count / 100) MOD 10;
                    digit3 <= (count / 1000) MOD 10;

                    -- Prepare TM1637 command/data sequence
                    data_seq(0) <= x"40"; -- CMD1: normal write
                    data_seq(1) <= x"C0"; -- CMD2: start address
                    data_seq(2) <= to_7seg(digit3); -- leftmost digit
                    data_seq(3) <= to_7seg(digit2);
                    data_seq(4) <= to_7seg(digit1);
                    data_seq(5) <= to_7seg(digit0); -- rightmost digit        
                    data_seq(6) <= x"8F"; -- CMD3: display ON (max. brightness)

                    state <= ST_SEND;

                WHEN ST_SEND =>
                    dc <= data_seq(index);
                    start <= '1';

                    -- Only stop for command or last byte
                    IF index = 0 OR index = 5 OR index = 6 THEN
                        stop <= '1';
                    ELSE
                        stop <= '0';
                    END IF;

                    state <= ST_WAIT_START;

                WHEN ST_WAIT_START =>
                    IF done = '0' THEN
                        start <= '0';
                        state <= ST_WAIT_DONE;
                    END IF;

                WHEN ST_WAIT_DONE =>
                    IF done = '1' THEN
                        IF index = 6 THEN
                            state <= ST_DELAY;
                            delay_cnt <= DELAY_CNT_MAX;
                        ELSE
                            index <= index + 1;
                            state <= ST_SEND;
                        END IF;
                    END IF;

                WHEN ST_DELAY =>
                    IF delay_cnt = 0 THEN
                        IF count = 9999 THEN
                            count <= 0;
                        ELSE
                            count <= count + 1;
                        END IF;
                        state <= ST_INIT;
                    ELSE
                        delay_cnt <= delay_cnt - 1;
                    END IF;

                WHEN OTHERS =>
                    state <= ST_INIT;

            END CASE;
        END IF;
    END PROCESS;

END behavioral;

