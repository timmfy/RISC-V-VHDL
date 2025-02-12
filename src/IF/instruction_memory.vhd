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
        x"00000013", --nop (executed at reset - start of the program)
        x"02000093", -- addi x1 x0 32
        x"01800113", -- addi x2 x0 24
        x"03800193", -- addi x3 x0 56
        x"04000213", -- addi x4 x0 64
        x"05400293", -- addi x5 x0 84
        x"00829293", -- slli x5 x5 8
        x"04528293", -- addi x5 x5 69
        x"00829293", -- slli x5 x5 8
        x"05328293", -- addi x5 x5 83
        x"00829293", -- slli x5 x5 8

        --Test the branch instruction
        x"00108563", -- beq x1 x1 10
        x"00013483", -- ld x9 0(x2)
        x"00a28313", -- addi x6 x5 10
        x"00a28313", -- addi x6 x5 10
        x"00a48313", -- addi x10 x5 18
        --Should jump here
        x"05428293", -- addi x5 x5 84
        x"00829293", -- slli x5 x5 8
        x"00829293", -- slli x5 x5 8
        x"00829293", -- slli x5 x5 8
        x"00829293", -- slli x5 x5 8
        x"02000313", -- addi x6 x0 32
        x"00831313", -- slli x6 x6 8
        x"04d30313", -- addi x6 x6 77
        x"00831313", -- slli x6 x6 8
        x"04530313", -- addi x6 x6 69
        x"00831313", -- slli x6 x6 8
        x"05330313", -- addi x6 x6 83
        x"0062e2b3", -- xor x5 x5 x6
        x"0051b023", -- sd x5 0(x3)
        x"02810107", -- vl1re8.v v2 0(x2)
        x"02808087", -- vl1re8.v v1 0(x1)
        x"2EF0B0D7", -- vxor.vi v1 v1 15
        x"0100B0D7", -- vadd.vi v1 v1 16
        x"0100B0D7", -- vadd.vi v1 v1 16
        x"9610B0D7", -- vsll.vi v1 v1 1
        x"2A10B0D7", -- vor.vi v1 v1 1
        x"082080D7", -- vsub.vv v1 v1 v3
        x"02120427", -- vs1r.v v1 0(x4)
        others => x"00000013" --nop
    );
begin
    instruction <= instructions(to_integer(unsigned(address)));
end architecture behavior;
