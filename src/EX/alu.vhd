library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity alu is
    port (
        a : in std_logic_vector(63 downto 0);
        b : in std_logic_vector(63 downto 0);
        ALUOp : in std_logic_vector(3 downto 0);
        result : out std_logic_vector(63 downto 0);
        zero : out std_logic
    );
end alu;

architecture behavioral of alu is
    signal shift_amount : integer;
    signal result_sig : std_logic_vector(63 downto 0);
begin
    shift_amount <= to_integer(unsigned(b(4 downto 0)));
    result_sig <= std_logic_vector(unsigned(a) + unsigned(b)) when ALUOp = "0000" else
                  std_logic_vector(unsigned(a) - unsigned(b)) when ALUOp = "0001" else
                  a and b when ALUOp = "0010" else
                  a or b when ALUOp = "0011" else
                  a xor b when ALUOp = "0100" else
                  std_logic_vector(shift_left(unsigned(a), shift_amount)) when ALUOp = "0101" else
                  std_logic_vector(shift_right(unsigned(a), shift_amount)) when ALUOp = "0110" else
                  std_logic_vector(shift_right(signed(a), shift_amount)) when ALUOp = "0111" else
                  (63 downto 1 => '0') & '1' when (ALUOp = "1000" and signed(a) < signed(b)) or
                                              (ALUOp = "1001" and unsigned(a) < unsigned(b)) else
                  (others => '0') when (ALUOp = "1000" and signed(a) > signed(b)) or (ALUOp = "1000" and signed(a) = signed(b)) or
                                     (ALUOp = "1001" and unsigned(a) > unsigned(b)) or (ALUOp = "1001" and unsigned(a) = unsigned(b)) else
                  (others => 'X');
    
    result <= result_sig;
    zero <= '1' when result_sig = X"0000000000000000" else '0';
end behavioral;
