library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    port (
        a : in std_logic_vector(31 downto 0);
        b : in std_logic_vector(31 downto 0);
        alu_op : in std_logic_vector(3 downto 0);
        result : out std_logic_vector(31 downto 0);
        zero : out std_logic
    );
end alu;
