library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_memory is
 port (
    address : in std_logic_vector(11 downto 2);
    instruction : out std_logic_vector(31 downto 0)
 );
end instruction_memory;

architecture behaviour of instruction_memory is
    type memory is array(0 to 15) of std_logic_vector(31 downto 0);
    signal instructions : memory := (
        --Test instructions
        x"11111110", x"11111111", x"11111100", x"11111101",
        x"11111010", x"11111011", x"11111000", x"11111001",
        x"11110110", x"11110111", x"11110100", x"11110101",
        x"11110010", x"11110011", x"11110000", x"11110001"
    );
begin
    instruction <= instructions(to_integer(unsigned(address)));
end architecture;