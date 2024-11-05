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
    type memory is array(0 to 255) of std_logic_vector(31 downto 0);
    signal instructions : memory := (
        --Test instructions
        x"02008093", --addi x1 x1 32
        x"01010113", --addi x2, x2, 16
        x"00013383", --ld x7 0(x2)
        --Load hazard
        x"00708023", --sb x7 0(x1)
        x"00709023", --sh x7 0(x1)
        --x"00108A63", --beq x1 x1 20
        x"0070A023", --sw x7 0(x1)
        x"0070B023", --sd x7 0(x1)
        x"01040593", --addi x11, x8, 16
        x"40518233", --sub x4 x3 x5
        x"00A483B3", --add x7 x9 x10
        x"00A483B3", --add x7 x9 x10
        x"00A483B3", --add x7 x9 x10
        x"00A483B3", --add x7 x9 x10
        x"00A483B3", --add x7 x9 x10
        x"00A483B3", --add x7 x9 x10
        x"00A483B3", --add x7 x9 x10
        x"00A483B3", --add x7 x9 x10
        x"00A483B3", --add x7 x9 x10
        others => (others => '0')
    );
begin
    instruction <= instructions(to_integer(unsigned(address)));
end architecture;
