library ieee;
use ieee.std_logic_1164.all;

entity instruction_memory_tb is
end entity instruction_memory_tb;

architecture behaviour of instruction_memory_tb is
    signal clk : std_logic := '0';
    signal address : std_logic_vector(11 downto 2);
    signal instruction : std_logic_vector(31 downto 0);

    constant clk_period : time := 10 ns;
begin
    dut: entity work.instruction_memory(behaviour)
        port map (
            clk => clk,
            address => address,
            instruction => instruction
        );

    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    stim_proc: process
    begin
        address <= "0000000000";
        wait for clk_period;
        assert instruction = x"11111110" report "Test case 1 failed" severity error;

        address <= "0000000001";
        wait for clk_period;
        assert instruction = x"11111111" report "Test case 2 failed" severity error;

        address <= "0000000010";
        wait for clk_period;
        assert instruction = x"11111100" report "Test case 3 failed" severity error;

        address <= "0000000011";
        wait for clk_period;
        assert instruction = x"11111101" report "Test case 4 failed" severity error;

    end process;
end architecture behaviour;