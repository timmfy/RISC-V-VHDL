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

architecture behavioral of alu is
begin
    with alu_op select
    result <= std_logic_vector(unsigned(a) + unsigned(b)) when "0000",
              std_logic_vector(unsigned(a) - unsigned(b)) when "0001",
              a and b when "0010",
              a or b when "0011",
              a xor b when "0100",
              a sll to_integer(unsigned(b)) when "0101",
              a srl to_integer(unsigned(b)) when "0110",
              a sra to_integer(unsigned(b)) when "0111",
              std_logic_vector(unsigned(a) * unsigned(b)) when "1000",
              std_logic_vector(unsigned(a) / unsigned(b)) when "1009",
              std_logic_vector(unsigned(a) mod unsigned(b)) when "1010",
              std_logic_vector(unsigned(a) rem unsigned(b)) when "1011",
              std_logic_vector(unsigned(a) + 1) when "1100",
              (others => '0') when others;
    zero <= '1' when result = (others => '0') else '0';
end behavioral;
