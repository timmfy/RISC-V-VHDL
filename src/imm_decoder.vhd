library ieee;
use ieee.std_logic_1164.all;

entity imm_decoder is
	port(
		opcode : in std_logic_vector(4 downto 0);
		immediate   : out std_logic_vector(31 downto 0)
	);
end entity imm_decoder;

architecture behaviour of imm_decoder is
begin
	decode: process(opcode)
	begin
		case opcode is
			when b"01101" | b"00101" => -- U type
				immediate <= opcode(31 downto 12) & (11 downto 0 => '0');
			when b"11011" => -- J type
				immediate <= (31 downto 20 => opcode(31)) & opcode(19 downto 12) & opcode(20) & opcode(30 downto 21) & '0';
			when b"11001" | b"00000" | b"00100"  | b"11100"=> -- I type
				immediate <= (31 downto 11 => opcode(31)) & opcode(30 downto 20);
			when b"11000" => -- B type
				immediate <= (31 downto 12 => opcode(31)) & opcode(7) & opcode(30 downto 25) & opcode(11 downto 8) & '0';
			when b"01000" => -- S type
				immediate <= (31 downto 11 => opcode(31)) & opcode(30 downto 25) & opcode(11 downto 7);
			when others =>
				immediate <= (others => '0');
		end case;
	end process decode;
end architecture behaviour;