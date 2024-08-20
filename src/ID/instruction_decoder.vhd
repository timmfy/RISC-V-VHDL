library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ry_decode is
	port(
		clk    : in std_logic;
		reset  : in std_logic;

		-- Instruction input:
		instruction    : in std_logic_vector(31 downto 0);

		-- Register addresses:
		rs1_addr, rs2_addr, rd_addr : out register_address;
		csr_addr : out csr_address;

		-- Function value
		funct3 : out std_logic_vector(2 downto 0);
        funct7 : out std_logic_vector(6 downto 0);

        -- opcode
        opcode : out std_logic_vector(4 downto 0);

		-- Immediate value for immediate instructions:
		immediate : out std_logic_vector(31 downto 0);
	);

end entity ry_decode;

architecture behaviour of ry_decode is
begin
	rs1_addr <= instruction(19 downto 15);
	rs2_addr <= instruction(24 downto 20);
	rd_addr  <= instruction(11 downto  7);

	funct3 <= instruction(14 downto 12);
    funct3 <= instruction(31 downto 25);

    -- The last two are always 11
    opcode <= instruction(31 downto 2);

	-- Extract the immediate
	immediate_decoder: entity work.imm_decoder
		port map(
			opcode => instruction(31 downto 2),
			immediate => immediate_value
		);

end architecture behaviour;