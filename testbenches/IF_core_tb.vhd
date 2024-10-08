library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IF_core_tb is
end entity IF_core_tb;

architecture behavior of IF_core_tb is
    -- Component declaration for the Unit Under Test (UUT)
    component IF_core
        port (
            clk            : in std_logic;
            reset          : in std_logic;
            pc_src         : in std_logic;
            branch_target  : in std_logic_vector(31 downto 0);
            instruction    : out std_logic_vector(31 downto 0);
            pc             : out std_logic_vector(31 downto 0)
        );
    end component;

    -- Inputs
    signal clk             : std_logic := '0';
    signal reset           : std_logic := '0';
    signal pc_src          : std_logic := '0';
    signal branch_target   : std_logic_vector(31 downto 0) := (others => '0');

    -- Outputs
    signal instruction     : std_logic_vector(31 downto 0);
    signal pc              : std_logic_vector(31 downto 0);

    -- Clock period definition
    constant clk_period    : time := 10 ns;

begin
    -- Instantiate the Unit Under Test (UUT)
    dut: entity work.IF_core(behavior) port map (
        clk            => clk,
        reset          => reset,
        pc_src         => pc_src,
        branch_target  => branch_target,
        instruction    => instruction,
        pc             => pc
    );

    -- Clock process definitions
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Hold reset state for 100 ns
        reset <= '1';
        wait for 10 ns;
        reset <= '0';
        -- Test normal operation (pc_src = '0')
        pc_src <= '0';
        wait for clk_period;
        assert instruction = x"11111111" report "Instruction mismatch" severity error;
        wait for clk_period;
        assert instruction = x"11111100" report "Instruction mismatch" severity error;
        wait for clk_period*1;
        report "Normal operation test passed" severity note;
        -- Test branch (pc_src = '1')
        branch_target <= x"00000020";  -- Example branch target
        pc_src <= '1';
        wait for clk_period;
        assert instruction = x"11110110" report "Instruction mismatch" severity error;
        pc_src <= '0';  -- Return to normal operation
        wait for clk_period*1;
        wait;
    end process;

end architecture behavior;
