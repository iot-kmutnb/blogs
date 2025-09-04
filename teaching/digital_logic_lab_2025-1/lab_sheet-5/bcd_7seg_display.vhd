
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY bcd_7seg_display IS
    PORT (
        data : IN STD_LOGIC_VECTOR(11 DOWNTO 0); -- 12-bit binary input
        seg1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- left-most digit
        seg2 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        seg3 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        seg4 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) -- right-most digit
    );
END ENTITY bcd_7seg_display;

ARCHITECTURE rtl OF bcd_7seg_display IS

    -- BCD digits
    SIGNAL d0, d1, d2, d3 : STD_LOGIC_VECTOR(3 DOWNTO 0);

    -- 7-segment decoder function
    FUNCTION bcd_to_7seg(bcd : INTEGER) RETURN STD_LOGIC_VECTOR IS
        VARIABLE seg : STD_LOGIC_VECTOR(7 DOWNTO 0);
    BEGIN
        CASE bcd IS
            WHEN 0 => RETURN "11000000"; -- 0
            WHEN 1 => RETURN "11111001"; -- 1
            WHEN 2 => RETURN "10100100"; -- 2
            WHEN 3 => RETURN "10110000"; -- 3
            WHEN 4 => RETURN "10011001"; -- 4
            WHEN 5 => RETURN "10010010"; -- 5
            WHEN 6 => RETURN "10000010"; -- 6
            WHEN 7 => RETURN "11111000"; -- 7
            WHEN 8 => RETURN "10000000"; -- 8
            WHEN 9 => RETURN "10010000"; -- 9
            WHEN 10 => RETURN "10001000"; -- A
            WHEN 11 => RETURN "10000011"; -- b
            WHEN 12 => RETURN "11000110"; -- C
            WHEN 13 => RETURN "10100001"; -- d
            WHEN 14 => RETURN "10000110"; -- E
            WHEN 15 => RETURN "10001110"; -- F
            WHEN OTHERS => RETURN "11111111"; -- blank/off 
        END CASE;
        RETURN seg;
    END FUNCTION;

    -- Temporary BCD array
    TYPE bcd_array_t IS ARRAY(3 DOWNTO 0) OF STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL bcd_digits : bcd_array_t;
    SIGNAL value, dec0, dec1, dec2, dec3 : INTEGER;

BEGIN

    value <= to_integer(unsigned(data));
    dec0 <= value MOD 10;
    dec1 <= (value / 10) MOD 10;
    dec2 <= (value / 100) MOD 10;
    dec3 <= (value / 1000) MOD 10;

    seg1 <= bcd_to_7seg(dec3);
    seg2 <= bcd_to_7seg(dec2);
    seg3 <= bcd_to_7seg(dec1);
    seg4 <= bcd_to_7seg(dec0);

END ARCHITECTURE rtl;
