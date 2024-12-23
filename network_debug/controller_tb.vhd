library ieee;
use ieee.std_logic_1164.all;

entity controller_tb is
end controller_tb;

architecture behavior of controller_tb is
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal SW : std_logic_vector(15 downto 0) := (others => '0');

begin
    controller_inst : entity work.controller
    port map (
        sys_clock => clk,
        reset => reset,
        SW => SW
    );

    clk_process : process
    begin
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
    end process;

    stim_process : process
    begin
        reset <= '1';
        wait for 30 ns;
        reset <= '0';
        wait for 30 ns;
        SW <= "1000000000000000";
        wait for 150 ns;
        SW <= "0000000000000000";
        wait;
    end process;
end behavior;