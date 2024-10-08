library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IF_core is
    port (
        clk   : in std_logic;
		reset : in std_logic;
		pc_src : in std_logic;
		branch_target : in std_logic_vector(31 downto 0);
        instruction : out std_logic_vector(31 downto 0);
        pc : out std_logic_vector(31 downto 0)
    );
end IF_core;

architecture behavior of IF_core is
    signal pc_sig : std_logic_vector(31 downto 0) := (others => '0');
begin
    program_counter: entity work.program_counter(behaviour)
    port map(
        clk           => clk,
        reset         => reset,
        pc_src        => pc_src,
        branch_target => branch_target,
        pc            => pc_sig
    );
    instruction_memory: entity work.instruction_memory(behaviour)
    port map(
        address      => pc_sig(11 downto 2),
        instruction  => instruction
    );
    pc <= pc_sig;
end architecture behavior;