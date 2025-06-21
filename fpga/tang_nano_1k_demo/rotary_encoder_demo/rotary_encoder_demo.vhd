-- File: rotary_encoder_demo.vhd

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY rotary_encoder_demo IS
    GENERIC (
        CLK_HZ      : INTEGER := 27_000_000;
        SAMPLE_RATE : INTEGER := 1000;
        BW          : INTEGER := 8
    );
    PORT (
        CLK   : IN STD_LOGIC;
        RST_N : IN STD_LOGIC;
        SW_A  : IN STD_LOGIC; -- S1
        SW_B  : IN STD_LOGIC; -- S2
        BTN   : IN STD_LOGIC; -- KEY
        Q     : OUT STD_LOGIC_VECTOR(BW - 1 DOWNTO 0)
    );
END rotary_encoder_demo;

ARCHITECTURE behavioral OF rotary_encoder_demo IS
    CONSTANT CNT_MAX : NATURAL := (CLK_HZ/SAMPLE_RATE) - 1;
    SIGNAL capture   : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '1');
    SIGNAL update    : STD_LOGIC := '0';
    SIGNAL change    : STD_LOGIC := '0';
    SIGNAL inc, dec  : STD_LOGIC := '0';

    CONSTANT INIT_VALUE : INTEGER RANGE 0 TO 2**BW - 1 := 1;
    SIGNAL shift_reg : unsigned(BW - 1 DOWNTO 0) := to_unsigned(INIT_VALUE, BW);

BEGIN
    -- This process implements switch debouncing logic.
    sw_capture_proc : PROCESS (RST_N, CLK)
        VARIABLE wait_cnt : NATURAL RANGE 0 TO CNT_MAX := 0;
    BEGIN
        IF RST_N = '0' THEN
            wait_cnt := 0;
            capture <= (OTHERS => '1');
            update  <= '0';
        ELSIF rising_edge(CLK) THEN
            IF wait_cnt = CNT_MAX THEN
                wait_cnt := 0;
                update  <= '1';
                capture <= capture(1 DOWNTO 0) & (SW_A & SW_B);
            ELSE
                wait_cnt := wait_cnt + 1;
                update <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- Detect the falling edge on the captured SW_A signal
    change <= capture(3) AND (NOT capture(1));

    -- Check the logic level of the captured SW_B signal.
    inc <= change AND (NOT capture(0)); -- Enable counter increment
    dec <= change AND capture(0);       -- Enable counter decrement

    count_proc : PROCESS (RST_N, CLK)
    BEGIN
        IF RST_N = '0' THEN
            shift_reg <= to_unsigned(INIT_VALUE, BW);
        ELSIF rising_edge(CLK) THEN
            IF BTN = '0' THEN
                shift_reg <= to_unsigned(INIT_VALUE, BW);
            ELSIF update = '1' THEN -- Update count value.
                IF inc = '1' THEN -- shift left;
                    shift_reg <= shift_reg(BW-2 downto 0) & '1';
                ELSIF dec = '1' THEN -- shift right;
                    if shift_reg /= to_unsigned(1,BW) then
                      shift_reg <= '0' & shift_reg(BW-1 downto 1);
                    end if;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Outputs counter value
    Q <= not STD_LOGIC_VECTOR(shift_reg);

END behavioral;

