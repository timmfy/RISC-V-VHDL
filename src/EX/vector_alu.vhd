library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity vector_alu is
    port (
        a : in std_logic_vector(63 downto 0);
        b : in std_logic_vector(63 downto 0);
        ALUOp : in std_logic_vector(3 downto 0);
        result : out std_logic_vector(63 downto 0)
        --zero : out std_logic
    );
end vector_alu;

architecture behavioral of vector_alu is
    signal alu_results : std_logic_vector(63 downto 0);
begin
    process(a, b, ALUOp)
    begin
        case ALUOp is
            when "0000" => -- Addition              
                alu_results <=  std_logic_vector(unsigned(a(63 downto 56)) + unsigned(b(63 downto 56))) &
                                std_logic_vector(unsigned(a(55 downto 48)) + unsigned(b(55 downto 48))) &
                                std_logic_vector(unsigned(a(47 downto 40)) + unsigned(b(47 downto 40))) &
                                std_logic_vector(unsigned(a(39 downto 32)) + unsigned(b(39 downto 32))) &
                                std_logic_vector(unsigned(a(31 downto 24)) + unsigned(b(31 downto 24))) &
                                std_logic_vector(unsigned(a(23 downto 16)) + unsigned(b(23 downto 16))) &
                                std_logic_vector(unsigned(a(15 downto 8)) + unsigned(b(15 downto 8))) &
                                std_logic_vector(unsigned(a(7 downto 0)) + unsigned(b(7 downto 0)));
            when "0001" => -- Subtraction
                alu_results <=  std_logic_vector(unsigned(a(63 downto 56)) - unsigned(b(63 downto 56))) &
                                std_logic_vector(unsigned(a(55 downto 48)) - unsigned(b(55 downto 48))) &
                                std_logic_vector(unsigned(a(47 downto 40)) - unsigned(b(47 downto 40))) &
                                std_logic_vector(unsigned(a(39 downto 32)) - unsigned(b(39 downto 32))) &
                                std_logic_vector(unsigned(a(31 downto 24)) - unsigned(b(31 downto 24))) &
                                std_logic_vector(unsigned(a(23 downto 16)) - unsigned(b(23 downto 16))) &
                                std_logic_vector(unsigned(a(15 downto 8)) - unsigned(b(15 downto 8))) &
                                std_logic_vector(unsigned(a(7 downto 0)) - unsigned(b(7 downto 0)));
            when "0010" => -- AND
                alu_results <=  std_logic_vector(unsigned(a(63 downto 56)) and unsigned(b(63 downto 56))) &
                                std_logic_vector(unsigned(a(55 downto 48)) and unsigned(b(55 downto 48))) &
                                std_logic_vector(unsigned(a(47 downto 40)) and unsigned(b(47 downto 40))) &
                                std_logic_vector(unsigned(a(39 downto 32)) and unsigned(b(39 downto 32))) &
                                std_logic_vector(unsigned(a(31 downto 24)) and unsigned(b(31 downto 24))) &
                                std_logic_vector(unsigned(a(23 downto 16)) and unsigned(b(23 downto 16))) &
                                std_logic_vector(unsigned(a(15 downto 8)) and unsigned(b(15 downto 8))) &
                                std_logic_vector(unsigned(a(7 downto 0)) and unsigned(b(7 downto 0)));
            when "0011" => -- OR
                alu_results <=  std_logic_vector(unsigned(a(63 downto 56)) or unsigned(b(63 downto 56))) &
                                std_logic_vector(unsigned(a(55 downto 48)) or unsigned(b(55 downto 48))) &
                                std_logic_vector(unsigned(a(47 downto 40)) or unsigned(b(47 downto 40))) &
                                std_logic_vector(unsigned(a(39 downto 32)) or unsigned(b(39 downto 32))) &
                                std_logic_vector(unsigned(a(31 downto 24)) or unsigned(b(31 downto 24))) &
                                std_logic_vector(unsigned(a(23 downto 16)) or unsigned(b(23 downto 16))) &
                                std_logic_vector(unsigned(a(15 downto 8)) or unsigned(b(15 downto 8))) &
                                std_logic_vector(unsigned(a(7 downto 0)) or unsigned(b(7 downto 0)));
            when "0100" => -- XOR
                alu_results <=  std_logic_vector(unsigned(a(63 downto 56)) xor unsigned(b(63 downto 56))) &
                                std_logic_vector(unsigned(a(55 downto 48)) xor unsigned(b(55 downto 48))) &
                                std_logic_vector(unsigned(a(47 downto 40)) xor unsigned(b(47 downto 40))) &
                                std_logic_vector(unsigned(a(39 downto 32)) xor unsigned(b(39 downto 32))) &
                                std_logic_vector(unsigned(a(31 downto 24)) xor unsigned(b(31 downto 24))) &
                                std_logic_vector(unsigned(a(23 downto 16)) xor unsigned(b(23 downto 16))) &
                                std_logic_vector(unsigned(a(15 downto 8)) xor unsigned(b(15 downto 8))) &
                                std_logic_vector(unsigned(a(7 downto 0)) xor unsigned(b(7 downto 0)));
            when "0101" => -- Shift left logical
                alu_results <=  std_logic_vector(shift_left(unsigned(a(63 downto 56)), to_integer(unsigned(b(63 downto 56))))) &
                                std_logic_vector(shift_left(unsigned(a(55 downto 48)), to_integer(unsigned(b(55 downto 48))))) &
                                std_logic_vector(shift_left(unsigned(a(47 downto 40)), to_integer(unsigned(b(47 downto 40))))) &
                                std_logic_vector(shift_left(unsigned(a(39 downto 32)), to_integer(unsigned(b(39 downto 32))))) &
                                std_logic_vector(shift_left(unsigned(a(31 downto 24)), to_integer(unsigned(b(31 downto 24))))) &
                                std_logic_vector(shift_left(unsigned(a(23 downto 16)), to_integer(unsigned(b(23 downto 16))))) &
                                std_logic_vector(shift_left(unsigned(a(15 downto 8)), to_integer(unsigned(b(15 downto 8))))) &
                                std_logic_vector(shift_left(unsigned(a(7 downto 0)), to_integer(unsigned(b(7 downto 0)))));
            when "0110" => -- Shift right logical
                alu_results <=  std_logic_vector(shift_right(unsigned(a(63 downto 56)), to_integer(unsigned(b(63 downto 56))))) &
                                std_logic_vector(shift_right(unsigned(a(55 downto 48)), to_integer(unsigned(b(55 downto 48))))) &
                                std_logic_vector(shift_right(unsigned(a(47 downto 40)), to_integer(unsigned(b(47 downto 40))))) &
                                std_logic_vector(shift_right(unsigned(a(39 downto 32)), to_integer(unsigned(b(39 downto 32))))) &
                                std_logic_vector(shift_right(unsigned(a(31 downto 24)), to_integer(unsigned(b(31 downto 24))))) &
                                std_logic_vector(shift_right(unsigned(a(23 downto 16)), to_integer(unsigned(b(23 downto 16))))) &
                                std_logic_vector(shift_right(unsigned(a(15 downto 8)), to_integer(unsigned(b(15 downto 8))))) &
                                std_logic_vector(shift_right(unsigned(a(7 downto 0)), to_integer(unsigned(b(7 downto 0)))));
            when "0111" => -- Shift right arithmetic
                alu_results <=  std_logic_vector(shift_right(signed(a(63 downto 56)), to_integer(unsigned(b(63 downto 56))))) &
                                std_logic_vector(shift_right(signed(a(55 downto 48)), to_integer(unsigned(b(55 downto 48))))) &
                                std_logic_vector(shift_right(signed(a(47 downto 40)), to_integer(unsigned(b(47 downto 40))))) &
                                std_logic_vector(shift_right(signed(a(39 downto 32)), to_integer(unsigned(b(39 downto 32))))) &
                                std_logic_vector(shift_right(signed(a(31 downto 24)), to_integer(unsigned(b(31 downto 24))))) &
                                std_logic_vector(shift_right(signed(a(23 downto 16)), to_integer(unsigned(b(23 downto 16))))) &
                                std_logic_vector(shift_right(signed(a(15 downto 8)), to_integer(unsigned(b(15 downto 8))))) &
                                std_logic_vector(shift_right(signed(a(7 downto 0)), to_integer(unsigned(b(7 downto 0)))));
            when others =>
                alu_results <= (others => '0');
        end case;
    end process;

    result <= alu_results;
    --zero <= '1' when alu_results = x"0000000000000000" else '0';
end behavioral;