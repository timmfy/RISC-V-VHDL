library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MEM_core is
    port (
        clk : in std_logic;
        Address_ex : in std_logic_vector(12 downto 0);
        Address_mem : in std_logic_vector(2 downto 0);
        DataIn : in std_logic_vector(63 downto 0);
        MemRead : in std_logic;
        MemWrite : in std_logic;
        MemSize_ex : in std_logic_vector(1 downto 0);
        MemSize_mem : in std_logic_vector(1 downto 0);
        Branch : in std_logic;
        Zero : in std_logic;
        mem_debug : out std_logic_vector(15 downto 0);
        DataOut : out std_logic_vector(63 downto 0);
        PCSrc : out std_logic;
        Flush : out std_logic
    );
end entity MEM_core;

architecture Behaviour of MEM_core is

    signal we : std_logic_vector(7 downto 0) := (others => '0');
    signal addr : std_logic_vector(9 downto 0);
    signal di : std_logic_vector(63 downto 0);
    signal do : std_logic_vector(63 downto 0);
    signal flush_sig : std_logic;

    function get_we(
        mem_size : std_logic_vector(1 downto 0); --Memsize from the EX stage
        addr_gw : std_logic_vector(12 downto 0); 
        mem_write : std_logic
    ) return std_logic_vector is
    begin
        if mem_write = '0' then
            return "00000000";
        end if;
        if mem_size = "00" then
            case addr_gw(2 downto 0) is
                when "000" => return "00000001";
                when "001" => return "00000010";
                when "010" => return "00000100";
                when "011" => return "00001000";
                when "100" => return "00010000";
                when "101" => return "00100000";
                when "110" => return "01000000";
                when others => return "10000000";
            end case;
        elsif mem_size = "01" then
            case addr_gw(2 downto 1) is
                when "00" => return "00000011";
                when "01" => return "00001100";
                when "10" => return "00110000";
                when others => return "11000000";
            end case;
        elsif mem_size = "10" then
            if addr_gw(2) = '0' then
                return "00001111";
            else
                return "11110000";
            end if;
        else
            return ("11111111");
        end if;
    end function;

begin
    flush_sig <= Branch and Zero;
    Flush <= flush_sig;
    PCSrc <= Branch and Zero;

    --Preparing the data
    addr <= Address_ex(12 downto 3);
    we <= get_we(MemSize_ex, Address_ex, MemWrite) when flush_sig = '0' else (others => '0');
    -- with MemSize select
    --     UPPER <= 7 when "00",
    --     15 when "01",
    --     31 when "10",
    --     63 when others;
    --Memory Write Logic
    di <=   --Bytes write
            (63 downto 8 => '0') & DataIn(7 downto 0) when MemSize_ex = "00" and Address_ex(2 downto 0) = "000" and MemWrite = '1' else
            (63 downto 16 => '0') & DataIn(15 downto 8) & (7 downto 0 => '0') when MemSize_ex = "000" and Address_ex(2 downto 0) = "001" and MemWrite = '1' else
            (63 downto 24 => '0') & DataIn(23 downto 16) & (15 downto 0 => '0') when MemSize_ex = "000" and Address_ex(2 downto 0) = "010" and MemWrite = '1' else
            (63 downto 32 => '0') & DataIn(31 downto 24) & (23 downto 0 => '0') when MemSize_ex = "000" and Address_ex(2 downto 0) = "011" and MemWrite = '1' else
            (63 downto 40 => '0') & DataIn(39 downto 32) & (31 downto 0 => '0') when MemSize_ex = "000" and Address_ex(2 downto 0) = "100" and MemWrite = '1' else
            (63 downto 48 => '0') & DataIn(47 downto 40) & (39 downto 0 => '0') when MemSize_ex = "000" and Address_ex(2 downto 0) = "101" and MemWrite = '1' else
            (63 downto 56 => '0') & DataIn(55 downto 48) & (47 downto 0 => '0') when MemSize_ex = "000" and Address_ex(2 downto 0) = "110" and MemWrite = '1' else
            DataIn(63 downto 56) & (55 downto 0 => '0') when MemSize_ex = "000" and Address_ex(2 downto 0) = "111" and MemWrite = '1' else
            --Halfword write
            (63 downto 16 => '0') & DataIn(15 downto 0) when MemSize_ex = "01" and Address_ex(2 downto 1) = "00" and MemWrite = '1' else
            (63 downto 32 => '0') & DataIn(31 downto 16) & (15 downto 0 => '0') when MemSize_ex = "01" and Address_ex(2 downto 1) = "01" and MemWrite = '1' else
            (63 downto 48 => '0') & DataIn(47 downto 32) & (31 downto 0 => '0') when MemSize_ex = "01" and Address_ex(2 downto 1) = "10" and MemWrite = '1' else
            DataIn(63 downto 48) & (47 downto 0 => '0') when MemSize_ex = "01" and Address_ex(2 downto 1) = "11" and MemWrite = '1' else
            --Word write
            (63 downto 32 => '0') & DataIn(31 downto 0) when MemSize_ex = "10" and Address_ex(2) = '0' and MemWrite = '1' else
            DataIn(63 downto 32) & (31 downto 0 => '0') when MemSize_ex = "10" and Address_ex(2) = '1' and MemWrite = '1' else
            --Doubleword write
            DataIn when MemSize_ex = "11" and MemWrite = '1' and flush_sig = '0' else
          (others => '0');
     
    DataOut <=  --Bytes Read
                (63 downto 8 => '0') & do(7 downto 0) when MemSize_mem = "00" and Address_mem(2 downto 0) = "000" else
                (63 downto 8 => '0') & do(15 downto 8) when MemSize_mem ="00" and Address_mem(2 downto 0) = "001" else
                (63 downto 8 => '0') & do(23 downto 16) when MemSize_mem = "00" and Address_mem(2 downto 0) = "010" else
                (63 downto 8 => '0') & do(31 downto 24) when MemSize_mem = "00" and Address_mem(2 downto 0) = "011" else
                (63 downto 8 => '0') & do(39 downto 32) when MemSize_mem = "00" and Address_mem(2 downto 0) = "100" else
                (63 downto 8 => '0') & do(47 downto 40) when MemSize_mem = "00" and Address_mem(2 downto 0) = "101" else
                (63 downto 8 => '0') & do(55 downto 48) when MemSize_mem = "00" and Address_mem(2 downto 0) = "110" else
                (63 downto 8 => '0') & do(63 downto 56) when MemSize_mem = "00" and Address_mem(2 downto 0) = "111" else
                --Halfword Read
                (63 downto 16 => '0') & do(15 downto 0) when MemSize_mem = "01" and Address_mem(2 downto 1) = "00" else
                (63 downto 16 => '0') & do(31 downto 16) when MemSize_mem = "01" and Address_mem(2 downto 1) = "01" else
                (63 downto 16 => '0') & do(47 downto 32) when MemSize_mem = "01" and Address_mem(2 downto 1) = "10" else
                (63 downto 16 => '0') & do(63 downto 48) when MemSize_mem = "01" and Address_mem(2 downto 1) = "11" else
                --Word Read
                (63 downto 32 => '0') & do(31 downto 0) when MemSize_mem = "10" and Address_mem(2) = '0' else
                (63 downto 32 => '0') & do(63 downto 32) when MemSize_mem = "10" and Address_mem(2) = '1' else
                --Doubleword Read
                do when MemSize_mem = "11" else
                (others => '0');
    
    data_memory_inst: entity work.data_memory
     port map(
        clk => clk,
        re => MemRead,
        we => we,
        addr => addr,
        di => di,
        do => do
    );
    mem_debug <= do(15 downto 0);
end architecture Behaviour;