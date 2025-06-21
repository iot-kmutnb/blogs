-- File: leds_demo.vhd
-- Date: 2025-06-19

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY leds_demo IS
    GENERIC (
        CLK_HZ : POSITIVE := 27_000_000;
        BW : POSITIVE := 8
    );
    PORT (
        RST_N  : IN STD_LOGIC; -- asynchrouns active-high reset
        CLK    : IN STD_LOGIC; -- system clock
        LEDS   : OUT STD_LOGIC_VECTOR(BW - 1 DOWNTO 0) -- 8-bit LED output
    );
END leds_demo;

ARCHITECTURE rtl OF leds_demo IS
    CONSTANT CNT_MAX : INTEGER := CLK_HZ/20 - 1;
    SIGNAL counter : INTEGER RANGE 0 TO CNT_MAX := 0;
    SIGNAL tick    : STD_LOGIC := '0';
    SIGNAL led_r   : UNSIGNED(BW - 1 DOWNTO 0) := to_unsigned(1, BW);
    SIGNAL dir     : STD_LOGIC := '1';
BEGIN

    -- Clock Divider: generate slow pulse (tick)
    PROCESS (RST_N, CLK)
    BEGIN
        IF RST_N = '0' THEN
            counter <= 0;
            tick <= '0';
        ELSIF rising_edge(CLK) THEN
            IF counter = CNT_MAX THEN
                counter <= 0;
                tick <= '1';
            ELSE
                counter <= counter + 1;
                tick <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- LED Shift Register: chaser effect
    PROCESS (RST_N, CLK)
    BEGIN
        IF rst_n = '0' THEN
            led_r <= to_unsigned(1, BW);
            dir   <= '1';
        ELSIF rising_edge(CLK) THEN
            IF tick = '1' THEN
                IF dir = '1' AND led_r(BW - 1) = '1' THEN
                    dir <= '0';
                ELSIF dir = '0' AND led_r(0) = '1' THEN
                    dir <= '1';
                ELSE
                    IF dir = '1' THEN
                        led_r <= led_r(BW - 2 DOWNTO 0) & led_r(BW - 1);
                    ELSE
                        led_r <= led_r(0) & led_r(BW - 1 DOWNTO 1);
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    LEDS <= STD_LOGIC_VECTOR(NOT led_r); -- active-low LEDs

END rtl;


