library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity EX_core is
    port (
        ALUOp      : in std_logic_vector(3 downto 0);    -- ALU operation
        ALUSrc     : in std_logic;                      -- ALU source (register or immediate)
        read_data1 : in std_logic_vector(63 downto 0);
        read_data2 : in std_logic_vector(63 downto 0);
        imm : in std_logic_vector(63 downto 0);
        rd : in std_logic_vector(4 downto 0);
        pc : in std_logic_vector(63 downto 0);
        result : out std_logic_vector(63 downto 0);
        zero : out std_logic;
        next_pc : out std_logic_vector(63 downto 0)
    );
end EX_core;

architecture behavior of EX_core is
    signal b : std_logic_vector(63 downto 0);
begin
    next_pc <= std_logic_vector(unsigned(pc) + shift_left(unsigned(imm), 2));
    b <= imm when ALUSrc = '1' else read_data2;
    alu : entity work.alu
    port map(
        a => read_data1,
        b => b,
        ALUOp => ALUOp,
        ALUSrc => ALUSrc,
        result => result,
        zero => zero
    );
end architecture;