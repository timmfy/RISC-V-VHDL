library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_memory is
    port (
        address : in std_logic_vector(31 downto 0);
        data_in : in std_logic_vector(31 downto 0);
        mem_read : in std_logic;
        mem_write : in std_logic;
        data_out : out std_logic_vector(31 downto 0)
    );
end data_memory;