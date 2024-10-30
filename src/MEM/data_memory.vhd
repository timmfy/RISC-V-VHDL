library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_memory is
    port (
        Address : in std_logic_vector(63 downto 0);
        DataIn : in std_logic_vector(63 downto 0);
        MemRead : in std_logic;
        MemWrite : in std_logic;
        MemSize : in std_logic_vector(1 downto 0);
        DataOut : out std_logic_vector(63 downto 0)
    );
end data_memory;

architecture behavioral of data_memory is
    type memory_array is array (0 to 512) of std_logic_vector(63 downto 0);
    --Test memory
    signal memory : memory_array := (
        0 => x"0000000000000000",
        1 => x"0000000000000000",
        2 => x"8877665544332211",
        others => (others => '0'));
    signal im_here : std_logic := '0';
begin
    process(Address, DataIn, MemRead, MemWrite, MemSize) is
    begin
        case MemSize is
            when "00" =>
                case Address(2 downto 0) is
                    when "000" =>
                        if MemWrite = '1' then
                            memory(to_integer(unsigned(Address(63 downto 3))))(7 downto 0) <= DataIn(7 downto 0);
                        end if;
                        if MemRead = '1' then
                            DataOut <= (63 downto 8 => '0') & memory(to_integer(unsigned(Address(63 downto 3))))(7 downto 0);
                        end if;
                    when "001" =>
                        if MemWrite = '1' then
                            memory(to_integer(unsigned(Address(63 downto 3))))(15 downto 8) <= DataIn(7 downto 0);
                        end if;
                        if MemRead = '1' then
                            DataOut <= (63 downto 8 => '0') & memory(to_integer(unsigned(Address(63 downto 3))))(15 downto 8);
                        end if;
                    when "010" =>
                        if MemWrite = '1' then
                            memory(to_integer(unsigned(Address(63 downto 3))))(23 downto 16) <= DataIn(7 downto 0);
                        end if;
                        if MemRead = '1' then
                            DataOut <= (63 downto 8 => '0') & memory(to_integer(unsigned(Address(63 downto 3))))(23 downto 16);
                        end if;
                    when "011" =>
                        if MemWrite = '1' then
                            memory(to_integer(unsigned(Address(63 downto 3))))(31 downto 24) <= DataIn(7 downto 0);
                        end if;
                        if MemRead = '1' then
                            DataOut <= (63 downto 8 => '0') & memory(to_integer(unsigned(Address(63 downto 3))))(31 downto 24);
                        end if;
                    when "100" =>
                        if MemWrite = '1' then
                            memory(to_integer(unsigned(Address(63 downto 3))))(39 downto 32) <= DataIn(7 downto 0);
                        end if;
                        if MemRead = '1' then
                            DataOut <= (63 downto 8 => '0') & memory(to_integer(unsigned(Address(63 downto 3))))(39 downto 32);
                        end if;
                    when "101" =>
                        if MemWrite = '1' then
                            memory(to_integer(unsigned(Address(63 downto 3))))(47 downto 40) <= DataIn(7 downto 0);
                        end if;
                        if MemRead = '1' then
                            DataOut <= (63 downto 8 => '0') & memory(to_integer(unsigned(Address(63 downto 3))))(47 downto 40);
                        end if;
                    when "110" =>
                        if MemWrite = '1' then
                            memory(to_integer(unsigned(Address(63 downto 3))))(55 downto 48) <= DataIn(7 downto 0);
                        end if;
                        if MemRead = '1' then
                            DataOut <= (63 downto 8 => '0') & memory(to_integer(unsigned(Address(63 downto 3))))(55 downto 48);
                        end if;
                    when "111" =>
                        if MemWrite = '1' then
                            memory(to_integer(unsigned(Address(63 downto 3))))(63 downto 56) <= DataIn(7 downto 0);
                        end if;
                        if MemRead = '1' then
                            DataOut <= (63 downto 8 => '0') & memory(to_integer(unsigned(Address(63 downto 3))))(63 downto 56);
                        end if;
                    when others =>
                        DataOut <= (others => '0');
                end case;
            when "01" =>
                case Address(2 downto 1) is
                    when "00" =>
                        if MemWrite = '1' then
                            memory(to_integer(unsigned(Address(63 downto 3))))(15 downto 0) <= DataIn(15 downto 0);
                        end if;
                        if MemRead = '1' then
                            DataOut <= (63 downto 16 => '0') & memory(to_integer(unsigned(Address(63 downto 3))))(15 downto 0);
                        end if;
                    when "01" =>
                        if MemWrite = '1' then
                            memory(to_integer(unsigned(Address(63 downto 3))))(31 downto 16) <= DataIn(15 downto 0);
                        end if;
                        if MemRead = '1' then
                            DataOut <= (63 downto 16 => '0') & memory(to_integer(unsigned(Address(63 downto 3))))(31 downto 16);
                        end if;
                    when "10" =>
                        if MemWrite = '1' then
                            memory(to_integer(unsigned(Address(63 downto 3))))(47 downto 32) <= DataIn(15 downto 0);
                        end if;
                        if MemRead = '1' then
                            DataOut <= (63 downto 16 => '0') & memory(to_integer(unsigned(Address(63 downto 3))))(47 downto 32);
                        end if;
                    when "11" =>
                        if MemWrite = '1' then
                            memory(to_integer(unsigned(Address(63 downto 3))))(63 downto 48) <= DataIn(15 downto 0);
                        end if;
                        if MemRead = '1' then
                            DataOut <= (63 downto 16 => '0') & memory(to_integer(unsigned(Address(63 downto 3))))(63 downto 48);
                        end if;
                    when others =>
                        DataOut <= (others => '0');
                end case;
            when "10" =>
                im_here <= '1';
                case Address(2) is
                    when '0' =>
                        if MemWrite = '1' then
                            memory(to_integer(unsigned(Address(63 downto 3))))(31 downto 0) <= DataIn(31 downto 0);
                        end if;
                        if MemRead = '1' then
                            DataOut <= (63 downto 32 => '0') & memory(to_integer(unsigned(Address(63 downto 3))))(31 downto 0);
                        end if;
                    when '1' =>
                        if MemWrite = '1' then
                            memory(to_integer(unsigned(Address(63 downto 3))))(63 downto 32) <= DataIn(31 downto 0);
                        end if;
                        if MemRead = '1' then
                            DataOut <= (63 downto 32 => '0') & memory(to_integer(unsigned(Address(63 downto 3))))(63 downto 32);
                        end if;
                    when others =>
                        DataOut <= (others => '0');
                end case;
            when "11" =>
                if MemWrite = '1' then
                    memory(to_integer(unsigned(Address(63 downto 3)))) <= DataIn;
                end if;
                if MemRead = '1' then
                    DataOut <= memory(to_integer(unsigned(Address(63 downto 3))));
                end if;
            when others =>
                DataOut <= (others => '0');
        end case;
    end process;
end behavioral;
