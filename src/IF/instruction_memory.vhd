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
        x"00000013", -- nop
        x"40000913", --addi x18, x0, 1024 (status memory address for the network controller)
        x"00100993", --addi x19, x0, 1 (status value for the network controller)
        x"05400293", -- addi x5 x0 84
        x"00829293", -- slli x5 x5 8
        x"04528293", -- addi x5 x5 69
        x"00829293", -- slli x5 x5 8
        x"05328293", -- addi x5 x5 83
        x"00829293", -- slli x5 x5 8
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
        x"02000093", -- addi x1 x0 32
        x"01800113", -- addi x2 x0 24
        x"00800193", -- addi x3 x0 8
        x"02808087", -- vl1re8.v v1 0(x1)
        x"02810107", -- vl1re8.v v2 0(x2)
        x"2EF0B0D7", -- vxor.vi v1 v1 15
        x"0100B0D7", -- vadd.vi v1 v1 16
        x"0100B0D7", -- vadd.vi v1 v1 16
        x"9610B0D7", -- vsll.vi v1 v1 1
        x"2A10B0D7", -- vor.vi v1 v1 1
        x"082080D7", -- vsub.vv v1 v1 v3
        x"02118427", -- vs1r.v v1, 0(x3)
        x"01393023", -- sd x19 0(x18) (start the transmission)
        x"00093023", -- sd x0, 0(x18)
        --x"01010113", --addi x2, x2, 16
        --x"0030B0D7", --vadd.vi v1 v1 3 (attention: imm and v1 are flipped cause in the documentation imm take the place of vs1 instaed of vs2)
        --x"00213157", --vadd.vi v2 v2 2
        --x"002081D7", --vadd.vv v3 v1 v2
        --x"A211B5D7", --vsrl.vi v11 v3 1
        --x"9611B657", --vsll.vi v12 v3 1
        --x"08218257", --vsub.vv v4 v2 v3
        --x"081232D7", --vsub.vi v5 v4 1
        --x"2A520357", --vor.vv v6 v5 v4
        --x"2E6283D7", --vxor.vv v7 v6 v5
        --x"02810407", -- vl1re8.v v8 0(x2)
        --x"02708427", -- vs1r.v v7, 0(x1) (imm and vs1 are flipped as well)
        
        --x"2E848557", -- vxor.vv v10 v8 v9      
        --Test instructions
        -- x"02008093", --addi x1 x1 32
        -- x"01010113", --addi x2, x2, 16
        -- x"00013383", --ld x7 0(x2)
        -- --Load hazard
        -- x"00708023", --sb x7 0(x1)
        -- x"00709023", --sh x7 0(x1)
        -- x"0070B023", --sd x7 0(x1)
        -- x"00108A63", --beq x1 x1 20
        -- x"0070A023", --sw x7 0(x1)
        -- x"01040593", --addi x11, x8, 16
        -- x"40518233", --sub x4 x3 x5
        -- x"00A483B3", --add x7 x9 x10
        -- x"00A483B3", --add x7 x9 x10
        -- x"00A483B3", --add x7 x9 x10
        -- x"00A483B3", --add x7 x9 x10
        -- x"00A483B3", --add x7 x9 x10
        -- x"00009303", --lh x6 0(x1)
        -- x"00009303", --lh x6 0(x1)
        -- x"00009303", --lh x6 0(x1)
        -- x"00009303", --lh x6 0(x1)
        -- x"00009303", --lh x6 0(x1)
        -- x"00009303", --lh x6 0(x1)
        -- x"00009303", --lh x6 0(x1)
        -- x"00009303", --lh x6 0(x1)
        -- x"00009303", --lh x6 0(x1)
        -- x"00009283", --lh x5 0(x1)
        -- x"00061283", --lh x5 0(x12)
        others => x"00000013" --nop
    );
begin
    instruction <= instructions(to_integer(unsigned(address)));
end architecture behavior;
