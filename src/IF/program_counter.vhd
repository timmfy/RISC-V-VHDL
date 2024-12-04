library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is
	port(
		clk   : in std_logic;
		reset : in std_logic;
		pc_src : in std_logic;
		PCWrite : in std_logic;
		branch_target : in std_logic_vector(63 downto 0);
		pc : out std_logic_vector(63 downto 0)
	);
end entity program_counter;

architecture behavior of program_counter is
	signal pc_next : std_logic_vector(63 downto 0) := (others => '0');
	signal here : std_logic := '0';
begin
	process(clk, reset)
	begin
		if reset = '1' then
			pc_next <= (others => '0');
		elsif rising_edge(clk) then
			if pc_next > x"00000000000000ff" then
				pc_next <= x"0000000000000020";
			elsif PCWrite = '1' then
				pc_next <= pc_next;
			elsif pc_src = '1' then
				pc_next <= branch_target;
				here <= '1';
			else
				pc_next <= std_logic_vector(unsigned(pc_next) + 4);
			end if;
		end if;
	end process;
	pc <= pc_next;
end architecture behavior;
