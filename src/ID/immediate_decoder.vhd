library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity immediate_decoder is
    port (
        instruction : in std_logic_vector(31 downto 0);
        immediate : out std_logic_vector(64 downto 0)
    );
end immediate_decoder;
