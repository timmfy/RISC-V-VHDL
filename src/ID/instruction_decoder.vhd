library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_decoder is
	port (
		instruction : in std_logic_vector(31 downto 0);
		opcode : out std_logic_vector(6 downto 0);
		rs1 : out std_logic_vector(4 downto 0);
		rs2 : out std_logic_vector(4 downto 0);
		rd : out std_logic_vector(4 downto 0);
		funct3 : out std_logic_vector(2 downto 0);
		funct7 : out std_logic_vector(6 downto 0);
		imm : out std_logic_vector(31 downto 0)
	);
end instruction_decoder;

architecture behavior of instruction_decoder is
	signal immediate: std_logic_vector(31 downto 0);
	signal instruction_sig: std_logic_vector(31 downto 0);
begin
		instruction_sig <= instruction;
		rs1 <= instruction(19 downto 15);
		rs2 <= instruction(24 downto 20);
		rd  <= instruction(11 downto 7);
		funct3 <= instruction(14 downto 12);
		funct7 <= instruction(31 downto 25);
		opcode <= instruction_sig(6 downto 0);
		immediate_decoder: entity work.immediate_decoder(behavior)
			port map(
				instruction => instruction_sig,
				immediate => immediate
			);
		imm <= immediate;
end behavior;