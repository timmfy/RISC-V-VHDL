library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_memory is
    port (
        clk : in std_logic;
        Address : in std_logic_vector(7 downto 0);
        DataIn : in std_logic_vector(63 downto 0);
        MemRead : in std_logic;
        MemWrite : in std_logic;
        MemSize : in std_logic_vector(1 downto 0);
        Flush : in std_logic;
        DataOut : out std_logic_vector(63 downto 0);
        mem_debug : out std_logic_vector(15 downto 0)
    );
end data_memory;

architecture Behavioral of data_memory is
    --256 x 64-bit memory
    type memory_array is array(0 to 255) of std_logic_vector(63 downto 0);
    signal memory : memory_array := (
        0 => x"0000000000000000",
        1 => x"0000000000000000",
        2 => x"8877665544332211",
        others => (others => '0'));
    signal index : integer;
begin
    index <= to_integer(unsigned(Address(7 downto 3)));
    process(clk)
    begin
        if rising_edge(clk) then
            -- Memory Read Logic
            if MemRead = '1' and Flush = '0' then
                case MemSize is
                    when "00" => -- Byte access
                        case Address(2 downto 0) is
                            when "000" => DataOut <= (63 downto 8 => '0') & memory(index)(7 downto 0);
                            when "001" => DataOut <= (63 downto 8 => '0') & memory(index)(15 downto 8);
                            when "010" => DataOut <= (63 downto 8 => '0') & memory(index)(23 downto 16);
                            when "011" => DataOut <= (63 downto 8 => '0') & memory(index)(31 downto 24);
                            when "100" => DataOut <= (63 downto 8 => '0') & memory(index)(39 downto 32);
                            when "101" => DataOut <= (63 downto 8 => '0') & memory(index)(47 downto 40);
                            when "110" => DataOut <= (63 downto 8 => '0') & memory(index)(55 downto 48);
                            when others => DataOut <= (63 downto 8 => '0') & memory(index)(63 downto 56);
                        end case;
                    when "01" => -- Halfword access
                        case Address(2 downto 1) is
                            when "00" => DataOut <= (63 downto 16 => '0') & memory(index)(15 downto 0);
                            when "01" => DataOut <= (63 downto 16 => '0') & memory(index)(31 downto 16);
                            when "10" => DataOut <= (63 downto 16 => '0') & memory(index)(47 downto 32);
                            when others => DataOut <= (63 downto 16 => '0') & memory(index)(63 downto 48);
                        end case;
                    when "10" => -- Word access
                        if Address(2) = '0' then
                            DataOut <= (63 downto 32 => '0') & memory(index)(31 downto 0);
                        else
                            DataOut <= (63 downto 32 => '0') & memory(index)(63 downto 32);
                        end if;
                    when others => -- Doubleword access
                        DataOut <= memory(index);
                end case;
            else
                DataOut <= (others => '0');
            end if;

            -- Memory Write Logic
            if MemWrite = '1' and Flush = '0' then
                case MemSize is
                    when "00" => -- Byte write
                        case Address(2 downto 0) is 
                            when "000" => memory(index)(7 downto 0) <= DataIn(7 downto 0);
                            when "001" => memory(index)(15 downto 8) <= DataIn(7 downto 0);
                            when "010" => memory(index)(23 downto 16) <= DataIn(7 downto 0);
                            when "011" => memory(index)(31 downto 24) <= DataIn(7 downto 0);
                            when "100" => memory(index)(39 downto 32) <= DataIn(7 downto 0);
                            when "101" => memory(index)(47 downto 40) <= DataIn(7 downto 0);
                            when "110" => memory(index)(55 downto 48) <= DataIn(7 downto 0);
                            when others => memory(index)(63 downto 56) <= DataIn(7 downto 0);
                        end case;
                    when "01" => -- Halfword write
                        case Address(2 downto 1) is
                            when "00" => memory(index)(15 downto 0) <= DataIn(15 downto 0);
                            when "01" => memory(index)(31 downto 16) <= DataIn(15 downto 0);
                            when "10" => memory(index)(47 downto 32) <= DataIn(15 downto 0);
                            when others => memory(index)(63 downto 48) <= DataIn(15 downto 0);
                        end case;
                    when "10" => -- Word write
                        case Address(2) is
                            when '0' => memory(index)(31 downto 0) <= DataIn(31 downto 0);
                            when others => memory(index)(63 downto 32) <= DataIn(31 downto 0);
                        end case;
                    when others => -- Doubleword write
                        memory(index) <= DataIn;
                end case;
            end if;
        end if;
    end process;
    mem_debug <= memory(4)(15 downto 0);
end Behavioral;