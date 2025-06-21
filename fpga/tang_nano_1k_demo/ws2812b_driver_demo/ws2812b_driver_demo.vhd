LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ws2812b_driver_demo IS
    PORT (
        CLK   : IN STD_LOGIC;
        RST_N : IN STD_LOGIC;
        DOUT  : OUT STD_LOGIC
    );
END ws2812b_driver_demo;

ARCHITECTURE rtl OF ws2812b_driver_demo IS

    COMPONENT ws2812b_driver
        GENERIC (
            CLK_HZ : INTEGER
        );
        PORT (
            CLK : IN STD_LOGIC;
            RST_N : IN STD_LOGIC;
            WR : IN STD_LOGIC;
            DATA : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            BUSY : OUT STD_LOGIC;
            DOUT : OUT STD_LOGIC
        );
    END COMPONENT;

    --------------------------------------------------------------------
    -- Color ROM (8 test colors: GRB format)
    --------------------------------------------------------------------
    TYPE rom_type IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR(23 DOWNTO 0);
    CONSTANT color_rom : rom_type := (
        x"00FF00",
        x"FF0000",
        x"0000FF",
        x"FFFF00",
        x"00FFFF",
        x"FF00FF",
        x"FFFFFF",
        x"000000"
    );
    -- FSM states
    TYPE state_type IS (IDLE, WRITE_DATA, WAIT_BUSY);
    SIGNAL state : state_type := IDLE;

    SIGNAL rom_index : INTEGER RANGE 0 TO 7 := 0;
    SIGNAL wr_strobe : STD_LOGIC := '0';
    SIGNAL busy : STD_LOGIC;
    SIGNAL delay_cnt : INTEGER := 0;
    SIGNAL data : STD_LOGIC_VECTOR(23 DOWNTO 0);

    CONSTANT CLK_HZ : INTEGER := 27e6;
    CONSTANT DELAY_MAX : INTEGER := CLK_HZ/2;

BEGIN

    data <= color_rom(rom_index);

    --------------------------------------------------------------------
    -- DUT: WS2812B Driver Instance
    --------------------------------------------------------------------
    inst_driver : ws2812b_driver
    GENERIC MAP(
        CLK_HZ => CLK_HZ
    )
    PORT MAP(
        CLK => CLK,
        RST_N => RST_N,
        WR => wr_strobe,
        DATA => data,
        BUSY => busy,
        DOUT => DOUT
    );

    --------------------------------------------------------------------
    -- FSM Controller to loop through color_rom
    --------------------------------------------------------------------
    PROCESS (CLK, RST_N)
    BEGIN
        IF RST_N = '0' THEN
            wr_strobe <= '0';
            rom_index <= 0;
            state <= IDLE;
            delay_cnt <= 0;

        ELSIF rising_edge(CLK) THEN
            CASE state IS
                WHEN IDLE => -- Idle: wait until not busy
                    IF busy = '0' THEN
                        wr_strobe <= '1';
                        state <= WRITE_DATA;
                    END IF;

                WHEN WRITE_DATA => -- Issue write strobe
                    IF busy = '1' THEN
                        wr_strobe <= '0';
                        state <= WAIT_BUSY;
                    END IF;

                WHEN WAIT_BUSY => -- Wait for delay before next color
                    IF busy = '0' THEN
                        IF delay_cnt < DELAY_MAX THEN
                            delay_cnt <= delay_cnt + 1;
                        ELSE
                            delay_cnt <= 0;
                            rom_index <= (rom_index + 1) MOD 8;
                            state <= IDLE;
                        END IF;
                    END IF;

                WHEN OTHERS =>
                    state <= IDLE;
            END CASE;
        END IF;
    END PROCESS;

END rtl;

