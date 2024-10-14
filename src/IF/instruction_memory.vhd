library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_memory is
 port (
    address : in std_logic_vector(11 downto 2);
    instruction : out std_logic_vector(31 downto 0)
 );
end instruction_memory;

architecture behavior of instruction_memory is
    type memory is array(0 to 15) of std_logic_vector(31 downto 0);
    signal instructions : memory := (
        --Test instructions
        x"01010093", --addi x1, x2, 16
        x"01010113", --addi x2, x2, 16
        x"01008413", --addi x8 x1 16
        x"01040593", --addi x11, x8, 16
        x"00710313", --addi x6 x2 8 --the output should be x"0000000000000018" in the register x6
        x"40518233", --sub x4 x3 x5
        x"00A483B3", --add x7 x9 x10
        others => (others => '0')
    );
begin
    instruction <= instructions(to_integer(unsigned(address)));
end architecture;