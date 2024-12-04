library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity data_memory is
    port(
        clk  : in  std_logic;
        we   : in  std_logic_vector(7 downto 0);
        re   : in  std_logic;
        addr : in  std_logic_vector(9 downto 0);
        di   : in  std_logic_vector(63 downto 0);
        do   : out std_logic_vector(63 downto 0)
    );
end data_memory;

architecture Behavior of data_memory is
    type ram_type is array (1023 downto 0) of std_logic_vector(63 downto 0);
    signal RAM : ram_type := (
        0 => x"0000000000000000",
        1 => x"0000000000000000",
        2 => x"8877665544332211",
        3 => x"0000000077777777",
        others => (others => '0')
    );

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if re = '1' then
                do <= RAM(to_integer(unsigned(addr)));
            end if;
            for i in 0 to 7 loop
                if we(i) = '1' then
                    RAM(to_integer(unsigned(addr)))((i + 1) * 8 - 1 downto i * 8) <= di((i + 1) * 8 - 1 downto i * 8);
                end if;
            end loop;
        end if;
    end process;
end Behavior;
