library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity core_tb is
end core_tb;

architecture behavior of core_tb is
    signal clk : std_logic := '1';
    signal reset : std_logic := '0';
begin
    dut: entity work.core
    port map(
        clk => clk,
        reset => reset
    );
    clk <= not clk after 5 ns;
    stimulus: process
    begin
        wait for 150 ns;
        wait;
    end process;
end behavior;
