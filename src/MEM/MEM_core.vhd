library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MEM_core is
    port (
        clk : in std_logic;
        Address : in std_logic_vector(63 downto 0);
        DataIn : in std_logic_vector(63 downto 0);
        MemRead : in std_logic;
        MemWrite : in std_logic;
        MemSize : in std_logic_vector(1 downto 0);
        Branch : in std_logic;
        Zero : in std_logic;
        DataOut : out std_logic_vector(63 downto 0);
        mem_debug : out std_logic_vector(15 downto 0);
        PCSrc : out std_logic;
        Flush : out std_logic
    );
end entity MEM_core;

architecture Behaviour of MEM_core is
    signal flush_sig : std_logic;
begin
    flush_sig <= Branch and Zero;
    Flush <= flush_sig;
    PCSrc <= Branch and Zero;
    data_memory_inst: entity work.data_memory
     port map(
        clk => clk,
        Address => Address,
        DataIn => DataIn,
        MemRead => MemRead,
        MemWrite => MemWrite,
        MemSize => MemSize,
        Flush => flush_sig,
        DataOut => DataOut,
        mem_debug => mem_debug
    );
end architecture Behaviour;    