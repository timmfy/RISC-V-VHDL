library ieee;
use ieee.std_logic_1164.all;

entity istruction_fetch is
    port(
        clk    : in std_logic;
		reset  : in std_logic;

        -- PC Input
        pc_in   : in std_logic_vector(11 downto 0);
        pc_load : in std_logic;

        -- Pc Output
        curr_pc : out std_logic_vector(11 downto 0);
        next_pc : out std_logic_vector(11 downto 0);

        -- Istruction Memory output
        istruction : out std_logic_vector(31 downto 0);
    );
end entity istruction_fetch;

architecture behaviour of istruction_fetch is
    signal pc  : std_logic_vector(11 downto 0);
    signal add : unsigned(2 downto 0) := "100";
begin
    program_counter: entity work.program_counter
        port map(
           clk => clk,
           reset => reset,
           load_en => pc_load,
           pc_in => pc_in,
           cout => pc
        )

    curr_pc <= pc;
    next_pc <= '0'& unsigned(pc) + add;

    instruction_memory: entity work.instruction_memory
        port map(
            clk => clk,
            address => pc(11 downto 2),
            istruction => istruction
        )
end architecture behaviour;