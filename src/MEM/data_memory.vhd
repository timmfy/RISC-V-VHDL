library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_memory is
    port (
        Address : in std_logic_vector(63 downto 0);
        DataIn : in std_logic_vector(63 downto 0);
        MemRead : in std_logic;
        MemWrite : in std_logic;
        MemSize : in std_logic_vector(1 downto 0);
        DataOut : out std_logic_vector(63 downto 0);
        mem_debug : out std_logic_vector(15 downto 0)
    );
end data_memory;

architecture behavioral of data_memory is
    type memory_array is array (0 to 512) of std_logic_vector(63 downto 0);
    signal memory : memory_array := (
        0 => x"0000000000000000",
        1 => x"0000000000000000",
        2 => x"8877665544332211",
        others => (others => '0'));
    signal index : integer;
    
begin
    index <= to_integer(unsigned(Address(8 downto 3)));
    -- Memory Read Logic
    DataOut <=
        (63 downto 8 => '0') & memory(index)(7 downto 0) when MemRead = '1' and MemSize = "00" and Address(2 downto 0) = "000" else
        (63 downto 8 => '0') & memory(index)(15 downto 8) when MemRead = '1' and MemSize = "00" and Address(2 downto 0) = "001" else
        (63 downto 8 => '0') & memory(index)(23 downto 16) when MemRead = '1' and MemSize = "00" and Address(2 downto 0) = "010" else
        (63 downto 8 => '0') & memory(index)(31 downto 24) when MemRead = '1' and MemSize = "00" and Address(2 downto 0) = "011" else
        (63 downto 8 => '0') & memory(index)(39 downto 32) when MemRead = '1' and MemSize = "00" and Address(2 downto 0) = "100" else
        (63 downto 8 => '0') & memory(index)(47 downto 40) when MemRead = '1' and MemSize = "00" and Address(2 downto 0) = "101" else
        (63 downto 8 => '0') & memory(index)(55 downto 48) when MemRead = '1' and MemSize = "00" and Address(2 downto 0) = "110" else
        (63 downto 8 => '0') & memory(index)(63 downto 56) when MemRead = '1' and MemSize = "00" and Address(2 downto 0) = "111" else
        (63 downto 16 => '0') & memory(index)(15 downto 0) when MemRead = '1' and MemSize = "01" and Address(2 downto 1) = "00" else
        (63 downto 16 => '0') & memory(index)(31 downto 16) when MemRead = '1' and MemSize = "01" and Address(2 downto 1) = "01" else
        (63 downto 16 => '0') & memory(index)(47 downto 32) when MemRead = '1' and MemSize = "01" and Address(2 downto 1) = "10" else
        (63 downto 16 => '0') & memory(index)(63 downto 48) when MemRead = '1' and MemSize = "01" and Address(2 downto 1) = "11" else
        (63 downto 32 => '0') & memory(index)(31 downto 0) when MemRead = '1' and MemSize = "10" and Address(2) = '0' else
        (63 downto 32 => '0') & memory(index)(63 downto 32) when MemRead = '1' and MemSize = "10" and Address(2) = '1' else
        memory(index) when MemRead = '1' and MemSize = "11" else
        (others => '0');

    -- Memory Write Logic
    memory(index) <=
    memory(index) when MemWrite = '0' else
        DataIn when MemSize = "11" else
        memory(index)(63 downto 8) & DataIn(7 downto 0) when MemSize = "00" and Address(2 downto 0) = "000" else
        memory(index)(63 downto 16) & DataIn(7 downto 0) & memory(index)(7 downto 0) when MemSize = "00" and Address(2 downto 0) = "001" else
        memory(index)(63 downto 24) & DataIn(7 downto 0) & memory(index)(15 downto 0) when MemSize = "00" and Address(2 downto 0) = "010" else
        memory(index)(63 downto 32) & DataIn(7 downto 0) & memory(index)(23 downto 0) when MemSize = "00" and Address(2 downto 0) = "011" else
        memory(index)(63 downto 40) & DataIn(7 downto 0) & memory(index)(31 downto 0) when MemSize = "00" and Address(2 downto 0) = "100" else
        memory(index)(63 downto 48) & DataIn(7 downto 0) & memory(index)(39 downto 0) when MemSize = "00" and Address(2 downto 0) = "101" else
        memory(index)(63 downto 56) & DataIn(7 downto 0) & memory(index)(47 downto 0) when MemSize = "00" and Address(2 downto 0) = "110" else
        DataIn when MemSize = "11" else
        -- Halfword write logic
        memory(index)(63 downto 16) & DataIn(15 downto 0) when MemSize = "01" and Address(2 downto 1) = "00" else
        memory(index)(63 downto 32) & DataIn(15 downto 0) & memory(index)(15 downto 0) when MemSize = "01" and Address(2 downto 1) = "01" else
        memory(index)(63 downto 48) & DataIn(15 downto 0) & memory(index)(31 downto 0) when MemSize = "01" and Address(2 downto 1) = "10" else
        DataIn(15 downto 0) & memory(index)(47 downto 0) when MemSize = "01" and Address(2 downto 1) = "11" else
        -- Word write logic
        memory(index)(63 downto 32) & DataIn(31 downto 0) when MemSize = "10" and Address(2) = '0' else
        DataIn(31 downto 0) & memory(index)(31 downto 0) when MemSize = "10" and Address(2) = '1';

    mem_debug <= memory(4)(15 downto 0);
end behavioral;