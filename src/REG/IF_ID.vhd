library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IF_ID is
    port(
        clk: in std_logic;
        reset: in std_logic;
        IF_ID_Write : in std_logic;
        IF_flush : in std_logic;
        instruction_in: in std_logic_vector(31 downto 0);
        pc_in: in std_logic_vector(63 downto 0);
        instruction_out: out std_logic_vector(31 downto 0) := (others => '0');
        pc_out: out std_logic_vector(63 downto 0) := (others => '0')
    );
end entity IF_ID;

architecture behavior of IF_ID is
    signal pc_reg : std_logic_vector(63 downto 0);
    signal instruction_reg : std_logic_vector(31 downto 0);
begin
    process(clk,reset) is
    begin
        if reset = '1' then
            instruction_reg <= (others => '0');
            pc_reg <= (others => '0');
        elsif rising_edge(clk) then
            if IF_ID_Write = '1' then
                instruction_reg <= instruction_reg;
                pc_reg <= pc_reg;
            else
                instruction_reg <= instruction_in;
                pc_reg <= pc_in;
            end if;
        end if;
    end process;
    pc_out <= pc_reg;
    instruction_out <= x"00000013" when IF_flush = '1' else instruction_reg;
end architecture behavior;
