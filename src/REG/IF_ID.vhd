library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IF_ID is
    port(
        clk: in std_logic;
        reset: in std_logic;
        IF_flush: in std_logic;
        instruction_in: in std_logic_vector(31 downto 0);
        pc_in: in std_logic_vector(31 downto 0);
        instruction_out: out std_logic_vector(31 downto 0) := (others => '0');
        pc_out: out std_logic_vector(31 downto 0) := (others => '0')
    )
end entity IF_ID;

architecture behaviour of IF_ID is
begin
    process(clk,reset, IF_flush) is
    begin
        if reset = '1' then
            instruction_out <= (others => '0');
            pc_out <= (others => '0');
        elsif rising_edge(clk) then
            instruction_out <= instruction_in;
            pc_out <= pc_in;
        --Complete
        elsif IF_flush = '1' then
            instruction_out <= (others => '0');
            pc_out <= (others => '0');
        end if;
    end process;
end architecture behaviour;