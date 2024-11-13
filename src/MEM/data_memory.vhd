library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_memory is
    port (
        clk : in std_logic;
        Address : in std_logic_vector(63 downto 0);
        DataIn : in std_logic_vector(63 downto 0);
        MemRead : in std_logic;
        MemWrite : in std_logic;
        MemSize : in std_logic_vector(1 downto 0);
        FlushMem : in std_logic;
        DataOut : out std_logic_vector(63 downto 0);
        mem_debug : out std_logic_vector(15 downto 0)
    );
end data_memory;

architecture Behavioral of data_memory is
    --512 x 64-bit memory
    type memory_array is array(0 to 4095) of std_logic_vector(7 downto 0);
    signal memory : memory_array := (
        0 to 15 => x"00",
        16 => x"11",
        17 => x"22",
        18 => x"33",
        19 => x"44",
        20 => x"55",
        21 => x"66",
        22 => x"77",
        23 => x"88",
        others => (others => '0'));
    signal index : integer;
begin
    index <= to_integer(unsigned(Address(8 downto 3))) * 8;
    process(clk)
    begin
        if rising_edge(clk) then
            -- Memory Read Logic
            if MemRead = '1' and FlushMem = '0' then
                case MemSize is
                    when "00" => -- Byte access
                        case Address(2 downto 0) is
                            when "000" => DataOut <= (63 downto 8 => '0') & memory(index);
                            when "001" => DataOut <= (63 downto 8 => '0') & memory(index + 1);
                            when "010" => DataOut <= (63 downto 8 => '0') & memory(index + 2);
                            when "011" => DataOut <= (63 downto 8 => '0') & memory(index + 3);
                            when "100" => DataOut <= (63 downto 8 => '0') & memory(index + 4);
                            when "101" => DataOut <= (63 downto 8 => '0') & memory(index + 5);
                            when "110" => DataOut <= (63 downto 8 => '0') & memory(index + 6);
                            when "111" => DataOut <= (63 downto 8 => '0') & memory(index + 7);
                            when others => DataOut <= (others => '0');
                        end case;
                    when "01" => -- Halfword access
                        case Address(2 downto 1) is
                            when "00" => DataOut <= (63 downto 16 => '0') & memory(index + 1) & memory(index);
                            when "01" => DataOut <= (63 downto 16 => '0') & memory(index + 3) & memory(index + 2);
                            when "10" => DataOut <= (63 downto 16 => '0') & memory(index + 5) & memory(index + 4);
                            when "11" => DataOut <= (63 downto 16 => '0') & memory(index + 7) & memory(index + 6);
                            when others => DataOut <= (others => '0');
                        end case;
                    when "10" => -- Word access
                        if Address(2) = '0' then
                            DataOut <= (63 downto 32 => '0') & memory(index + 3) & memory(index + 2) & memory(index + 1) & memory(index);
                        else
                            DataOut <= (63 downto 32 => '0') & memory(index + 7) & memory(index + 6) & memory(index + 5) & memory(index + 4);
                        end if;
                    when "11" => -- Doubleword access
                        DataOut <= memory(index + 7) & memory(index + 6) & memory(index + 5) & memory(index + 4) & memory(index + 3) & memory(index + 2) & memory(index + 1) & memory(index);
                    when others =>
                        DataOut <= (others => '0');
                end case;
            else
                DataOut <= (others => '0');
            end if;

            -- Memory Write Logic
            if MemWrite = '1' and FlushMem = '0' then
                case MemSize is
                    when "00" => -- Byte write
                        case Address(2 downto 0) is
                            when "000" =>
                                memory(index) <= DataIn(7 downto 0);
                            when "001" =>
                                memory(index + 1) <= DataIn(7 downto 0);
                            when "010" =>
                                memory(index + 2) <= DataIn(7 downto 0);
                            when "011" =>
                                memory(index + 3) <= DataIn(7 downto 0);
                            when "100" =>
                                memory(index + 4) <= DataIn(7 downto 0);
                            when "101" =>
                                memory(index + 5) <= DataIn(7 downto 0);
                            when "110" =>
                                memory(index + 6) <= DataIn(7 downto 0);
                            when others =>
                                memory(index + 7) <= DataIn(7 downto 0);
                        end case;
                    when "01" => -- Halfword write
                        case Address(2 downto 1) is
                            when "00" =>
                                memory(index) <= DataIn(7 downto 0);
                                memory(index + 1) <= DataIn(15 downto 8);
                            when "01" =>
                                memory(index + 2) <= DataIn(7 downto 0);
                                memory(index + 3) <= DataIn(15 downto 8);
                            when "10" =>
                                memory(index + 4) <= DataIn(7 downto 0);
                                memory(index + 5) <= DataIn(15 downto 8);
                            when others =>
                                memory(index + 6) <= DataIn(7 downto 0);
                                memory(index + 7) <= DataIn(15 downto 8);
                        end case;
                    when "10" => -- Word write
                        if Address(2) = '0' then
                            memory(index) <= DataIn(7 downto 0);
                            memory(index + 1) <= DataIn(15 downto 8);
                            memory(index + 2) <= DataIn(23 downto 16);
                            memory(index + 3) <= DataIn(31 downto 24);
                        else
                            memory(index + 4) <= DataIn(7 downto 0);
                            memory(index + 5) <= DataIn(15 downto 8);
                            memory(index + 6) <= DataIn(23 downto 16);
                            memory(index + 7) <= DataIn(31 downto 24);
                        end if;
                    when "11" => -- Doubleword write
                        memory(index) <= DataIn(7 downto 0);
                        memory(index + 1) <= DataIn(15 downto 8);
                        memory(index + 2) <= DataIn(23 downto 16);
                        memory(index + 3) <= DataIn(31 downto 24);
                        memory(index + 4) <= DataIn(39 downto 32);
                        memory(index + 5) <= DataIn(47 downto 40);
                        memory(index + 6) <= DataIn(55 downto 48);
                        memory(index + 7) <= DataIn(63 downto 56);
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;
    mem_debug <= memory(17) & memory(16);
end Behavioral;