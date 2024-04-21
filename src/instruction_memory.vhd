library ieee;
use ieee.std_logic_1164.all;

entity instruction_memory is
 port (
    clk : in std_logic;
    address : in std_logic_vector(11 downto 2);
    instruction : out std_logic_vector(31 downto 0)
 );
end instruction_memory;

architecture rtl of instruction_memory is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            case address is
                --Example
                when "0000000000" => instruction <= (31 downto 30 => '1', others => '0');
                when others => instruction <= (others => '0');
            end case;
        end if;
    end process;
end architecture;