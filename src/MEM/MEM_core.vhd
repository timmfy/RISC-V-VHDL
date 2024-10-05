library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MEM_core is
    port (
        MemWrite : in std_logic;
        MemRead : in std_logic;
        MemSize : in std_logic_vector(1 downto 0);
        Branch : in std_logic;
        MemToReg : inout std_logic;
        RegWrite : inout std_logic;
        next_pc : inout std_logic_vector(31 downto 0);
        zero : in std_logic;
        alu_result : inout std_logic_vector(63 downto 0);
        read_data2 : in std_logic_vector(63 downto 0);
        rd : inout std_logic_vector(4 downto 0);
        PCSrc : out std_logic;
        data_out : out std_logic_vector(63 downto 0)
    );
end MEM_core;

architecture behavior of MEM_core is
begin
    PCSrc <= Branch and zero;
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