library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vector_register_file is
    port(
        clk : in std_logic;
        reg_write: in std_logic;
        write_reg: in std_logic_vector(4 downto 0);
        write_data: in std_logic_vector(63 downto 0);
        read_reg1: in std_logic_vector(4 downto 0);
        read_reg2: in std_logic_vector(4 downto 0);
        read_data1: out std_logic_vector(63 downto 0);
        read_data2: out std_logic_vector(63 downto 0);
        debug: out std_logic_vector(15 downto 0)
    );
end entity vector_register_file;


architecture behavior of vector_register_file is
    type reg_array is array (0 to 31) of std_logic_vector(63 downto 0);
    signal registers : reg_array := (
        0 => x"0000000000000000", -- x0
        1 => x"0202020202020202", -- x1
        2 => x"0303030303030303", -- x2
        others => (others => '0')
    );
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reg_write = '1' then
                registers(to_integer(unsigned(write_reg))) <= write_data;
            end if;
        end if;
    end process;
    read_data1 <= write_data when write_reg = read_reg1 and reg_write = '1' else registers(to_integer(unsigned(read_reg1)));
    read_data2 <= write_data when write_reg = read_reg2 and reg_write = '1' else registers(to_integer(unsigned(read_reg2)));
    debug <= registers(7)(15 downto 0);
end architecture;