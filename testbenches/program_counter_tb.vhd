library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter_tb is
end entity program_counter_tb;

architecture behaviour of program_counter_tb is
    -- Signals to connect to the UUT
    signal clk           : std_logic := '0';
    signal reset         : std_logic := '0';
    signal pc_src        : std_logic := '0';
    signal branch_target : std_logic_vector(31 downto 0) := (others => '0');
    signal pc            : std_logic_vector(31 downto 0);

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    dut: entity work.program_counter(behaviour)
        port map (
            clk           => clk,
            reset         => reset,
            pc_src        => pc_src,
            branch_target => branch_target,
            pc            => pc
        );

    -- Clock process definitions
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin		
        -- hold reset state for 20 ns
        reset <= '1';
        wait for 20 ns;	
        reset <= '0';
        wait for 20 ns;

        -- Test case 1: Normal increment (pc_src = '0')
        pc_src <= '0';
        wait for clk_period;
        assert pc = x"00000004" report "Test case 1 failed" severity error;

        wait for clk_period;
        assert pc = x"00000008" report "Test case 1 failed" severity error;

        -- Test case 2: Branch (pc_src = '1')
        pc_src <= '1';
        branch_target <= x"00000010";  -- Target address to branch to
        wait for clk_period;
        assert pc = x"00000010" report "Test case 2 failed" severity error;

        -- Test case 3: Reset operation
        reset <= '1';
        wait for clk_period;
        assert pc = x"00000000" report "Test case 3 failed" severity error;
        reset <= '0';

        -- Test case 4: Normal increment from non-zero value
        pc_src <= '0';
        wait for clk_period;
        assert pc = x"00000004" report "Test case 4 failed" severity error;

        -- Test case 5: Branch to a different target address
        pc_src <= '1';
        branch_target <= x"00000020";  -- Another target address
        wait for clk_period;
        assert pc = x"00000020" report "Test case 5 failed" severity error;

        -- Finish simulation
        wait;
    end process;

end architecture behaviour;

