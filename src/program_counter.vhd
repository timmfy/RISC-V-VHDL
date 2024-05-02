library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is
	port(
		clk   : in std_logic;
		reset : in std_logic;
		increment : in std_logic
		
		count     : out std_logic_vector( 12 - 1 downto 0 ); --The last two significanto bit equal to 0
	);
end entity program_counter;

architecture behaviour of program_counter is
	signal current_count : std_logic_vector( 12 - 1 downto 0 ); --The last two significanto bit equal to 0
begin
	count <= current_count;
	counter: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				current_count <= (others => '0');
			elsif increment = '1' then
				current_count <= std_logic_vector(unsigned(current_count) + 1);
			end if;
		end if;
	end process counter;
end architecture behaviour;