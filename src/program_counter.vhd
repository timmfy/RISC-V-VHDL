library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is
	port(
		clk   : in std_logic;
		reset : in std_logic;
		load_en : in std_logic

		pc_in : in std_logic_vector(11 downto 0)
		
		count     : out std_logic_vector(11 downto 0);
	);
end entity program_counter;

architecture behaviour of program_counter is
	signal current_count : std_logic_vector( 11 downto 0 );
begin
	count <= current_count;
	counter: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				current_count <= (others => '0');
			elsif load_en = '1' then
				current_count <= pc_in;
			end if;
		end if;
	end process counter;
end architecture behaviour;