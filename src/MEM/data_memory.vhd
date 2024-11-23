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

-- architecture Behavioral of data_memory is
--     --128 x 64-bit memory
--     type memory_array is array(0 to 127) of std_logic_vector(63 downto 0);
--     signal memory : memory_array := (
--         0 => x"0000000000000000",
--         1 => x"0000000000000000",
--         2 => x"8877665544332211",
--         others => (others => '0'));
--     signal index : integer;

--     -- Define functions for byte and halfword selection
--     function select_byte(data_word : std_logic_vector(63 downto 0); addr : std_logic_vector(2 downto 0)) return std_logic_vector is
--         variable byte_data : std_logic_vector(7 downto 0);
--     begin
--         case addr is
--             when "000" => byte_data := data_word(7 downto 0);
--             when "001" => byte_data := data_word(15 downto 8);
--             when "010" => byte_data := data_word(23 downto 16);
--             when "011" => byte_data := data_word(31 downto 24);
--             when "100" => byte_data := data_word(39 downto 32);
--             when "101" => byte_data := data_word(47 downto 40);
--             when "110" => byte_data := data_word(55 downto 48);
--             when others => byte_data := data_word(63 downto 56);
--         end case;
--         return byte_data;
--     end function;

--     function select_halfword(data_word : std_logic_vector(63 downto 0); addr : std_logic_vector(2 downto 1)) return std_logic_vector is
--         variable halfword_data : std_logic_vector(15 downto 0);
--     begin
--         case addr is
--             when "00" => halfword_data := data_word(15 downto 0);
--             when "01" => halfword_data := data_word(31 downto 16);
--             when "10" => halfword_data := data_word(47 downto 32);
--             when others => halfword_data := data_word(63 downto 48);
--         end case;
--         return halfword_data;
--     end function;

--     function select_word(data_word : std_logic_vector(63 downto 0); addr : std_logic) return std_logic_vector is
--         variable word_data : std_logic_vector(31 downto 0);
--     begin
--         case addr is
--             when '0' => word_data := data_word(31 downto 0);
--             when others => word_data := data_word(63 downto 32);
--         end case;
--         return word_data;
--     end function;

-- begin
--     index <= to_integer(unsigned(Address(6 downto 3)));
--     process(clk)
--     begin
--         if rising_edge(clk) then
--             -- Memory Read Logic
--             if MemRead = '1' and Flush = '0' then
--                 case MemSize is
--                     when "00" => -- Byte access
--                         DataOut <= (63 downto 8 => '0') & select_byte(memory(index), Address(2 downto 0));
--                     when "01" => -- Halfword access
--                         DataOut <= (63 downto 16 => '0') & select_halfword(memory(index), Address(2 downto 1));
--                     when "10" => -- Word access
--                         DataOut <= (63 downto 32 => '0') & select_word(memory(index), Address(2));
--                     when others => -- Doubleword access
--                         DataOut <= memory(index);
--                 end case;
--             else
--                 DataOut <= (others => '0');
--             end if;

--             -- Memory Write Logic
--             if MemWrite = '1' and Flush = '0' then
--                 case MemSize is
--                     when "00" => -- Byte write
--                         case Address(2 downto 0) is 
--                             when "000" => memory(index)(7 downto 0) <= DataIn(7 downto 0);
--                             when "001" => memory(index)(15 downto 8) <= DataIn(7 downto 0);
--                             when "010" => memory(index)(23 downto 16) <= DataIn(7 downto 0);
--                             when "011" => memory(index)(31 downto 24) <= DataIn(7 downto 0);
--                             when "100" => memory(index)(39 downto 32) <= DataIn(7 downto 0);
--                             when "101" => memory(index)(47 downto 40) <= DataIn(7 downto 0);
--                             when "110" => memory(index)(55 downto 48) <= DataIn(7 downto 0);
--                             when others => memory(index)(63 downto 56) <= DataIn(7 downto 0);
--                         end case;
--                     when "01" => -- Halfword write
--                         case Address(2 downto 1) is
--                             when "00" => memory(index)(15 downto 0) <= DataIn(15 downto 0);
--                             when "01" => memory(index)(31 downto 16) <= DataIn(15 downto 0);
--                             when "10" => memory(index)(47 downto 32) <= DataIn(15 downto 0);
--                             when others => memory(index)(63 downto 48) <= DataIn(15 downto 0);
--                         end case;
--                     when "10" => -- Word write
--                         case Address(2) is
--                             when '0' => memory(index)(31 downto 0) <= DataIn(31 downto 0);
--                             when others => memory(index)(63 downto 32) <= DataIn(31 downto 0);
--                         end case;
--                     when others => -- Doubleword write
--                         memory(index) <= DataIn;
--                 end case;
--             end if;
--         end if;
--     end process;
--     mem_debug <= memory(4)(15 downto 0);
-- end Behavioral;

