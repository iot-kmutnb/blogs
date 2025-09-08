-- Single-clock FIFO (Altera-like behavior, show-ahead)
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fifo_sc IS
    GENERIC (
        DATA_WIDTH : NATURAL := 8;
        ADDR_WIDTH : NATURAL := 10 -- FIFO depth = 2^ADDR_WIDTH
    );
    PORT (
        clk   : IN STD_LOGIC;
        rst_n : IN STD_LOGIC;
        wr_en : IN STD_LOGIC;
        rd_en : IN STD_LOGIC;
        din   : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        dout  : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        full  : OUT STD_LOGIC;
        empty : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE rtl OF fifo_sc IS
    CONSTANT MEM_DEPTH : NATURAL := 2 ** ADDR_WIDTH;

    SIGNAL wr_ptr, rd_ptr : NATURAL RANGE 0 TO MEM_DEPTH - 1 := 0;
    SIGNAL fifo_count : NATURAL RANGE 0 TO MEM_DEPTH := 0;

    SIGNAL ram_in   : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL ram_out  : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL dout_reg : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ram_we   : STD_LOGIC;
    SIGNAL is_full, is_empty : STD_LOGIC;

BEGIN
    ram_in <= din;
    ram_we <= (wr_en AND NOT is_full);

    -- dual-port RAM
    u_ram : ENTITY work.ram_dp_sc
        GENERIC MAP(
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
        PORT MAP(
            clk => clk,
            raddr => rd_ptr,
            waddr => wr_ptr,
            data => ram_in,
            we => ram_we,
            q => ram_out
        );

    fifo_wr_proc : PROCESS (clk, rst_n)
    BEGIN
        IF rst_n = '0' THEN
            wr_ptr <= 0;
        ELSIF rising_edge(clk) THEN
            IF (wr_en = '1' AND is_full = '0') THEN
                IF wr_ptr = MEM_DEPTH - 1 THEN
                    wr_ptr <= 0;
                ELSE
                    wr_ptr <= wr_ptr + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    fifo_rd_proc : PROCESS (clk, rst_n)
    BEGIN
        IF rst_n = '0' THEN
            rd_ptr <= 0;
            dout_reg <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            -- Update read pointer when valid read
            IF (rd_en = '1' AND is_empty = '0') THEN
                IF rd_ptr = MEM_DEPTH - 1 THEN
                    rd_ptr <= 0;
                ELSE
                    rd_ptr <= rd_ptr + 1;
                END IF;
            END IF;
            -- Output logic
            IF (rd_en = '1' AND is_empty = '0') THEN
                -- Normal read
                dout_reg <= ram_out;
            END IF;
        END IF;
    END PROCESS;

    fifo_cnt_proc : PROCESS (clk, rst_n)
        VARIABLE wr_rd_en : STD_LOGIC_VECTOR(1 DOWNTO 0);
    BEGIN
        IF rst_n = '0' THEN
            fifo_count <= 0;
        ELSIF rising_edge(clk) THEN
            wr_rd_en := wr_en & rd_en;
            CASE wr_rd_en IS
                WHEN "10" => -- write only
                    IF is_full = '0' THEN
                        fifo_count <= fifo_count + 1;
                    END IF;
                WHEN "01" => -- read only
                    IF is_empty = '0' THEN
                        fifo_count <= fifo_count - 1;
                    END IF;
                WHEN OTHERS =>
                    NULL; -- write+read (no net change) or idle
            END CASE;
        END IF;
    END PROCESS;

    -- Status signals
    is_full <= '1' WHEN fifo_count = MEM_DEPTH ELSE
        '0';
    is_empty <= '1' WHEN fifo_count = 0 ELSE
        '0';

    full <= is_full;
    empty <= is_empty;
    dout <= dout_reg;
END ARCHITECTURE;

