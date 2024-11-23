library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MEM_core is
    port (
        MemWrite : in std_logic;
        MemRead : in std_logic;
        MemSize : in std_logic_vector(1 downto 0);
        Branch : in std_logic;
        zero : in std_logic;
        alu_result : in std_logic_vector(63 downto 0);
        read_data2 : in std_logic_vector(63 downto 0);
        PCSrc : out std_logic;
        flush : out std_logic := '0';
        data_out : out std_logic_vector(63 downto 0)
    );
end MEM_core;

architecture behavior of MEM_core is
begin
    PCSrc <= Branch and zero;

    -- flushing in case if the branch is taken (rn only for beq)
    flush <= Branch and zero;

    data_memory_inst: entity work.data_memory
     port map(
        Address => alu_result,
        DataIn => read_data2,
        MemRead => MemRead,
        MemWrite => MemWrite,
        MemSize => MemSize,
        DataOut => data_out
    );
end architecture;