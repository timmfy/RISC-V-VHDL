library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    port (
        a : in std_logic_vector(63 downto 0);
        b : in std_logic_vector(63 downto 0);
        ALUOp : in std_logic_vector(3 downto 0);
        ALUSrc : in std_logic;
        result : out std_logic_vector(63 downto 0);
        zero : out std_logic
    );
end alu;

architecture behavioral of alu is
    signal shift_amount : integer;
    signal msb : std_logic;
    signal sra_shift : std_logic_vector(63 downto 0);
    signal result_sig : std_logic_vector(63 downto 0);
begin
    msb <= a(63);
    shift_amount <= to_integer(unsigned(b(4 downto 0)));
    process(a, b, ALUOp, ALUSrc) is
    begin
        if ALUOp = "0000" then
            result_sig <= std_logic_vector(unsigned(a) + unsigned(b));
        elsif ALUOp = "0001" then
            result_sig <= std_logic_vector(unsigned(a) - unsigned(b));
        elsif ALUOp = "0010" then
            result_sig <= a and b;
        elsif ALUOp = "0011" then
            result_sig <= a or b;
        elsif ALUOp = "0100" then
            result_sig <= a xor b;
        elsif ALUOp = "0101" then
            result_sig <= std_logic_vector(shift_left(unsigned(a), to_integer(unsigned(b(4 downto 0)))));
        elsif ALUOp = "0110" then
            result_sig <= std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(b(4 downto 0)))));
        elsif ALUOp = "0111" then
            if msb  = '1' then
                sra_shift <= (others => '0');
                sra_shift(63 downto shift_amount) <= (others => '1');
                result_sig <= std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(b(4 downto 0))))) or sra_shift;
            else
                result_sig <= std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(b(4 downto 0)))));
            end if;
        elsif ALUOp = "1000" then
            if signed(a) < signed(b) then
                result_sig <= (others => '0');
                result_sig(0) <= '1';
            else
                result_sig <= (others => '0');
            end if;
        elsif ALUOp = "1001" then
            if unsigned(a) < unsigned(b) then
                result_sig <= (others => '0');
                result_sig(0) <= '1';
            else
                result_sig <= (others => '0');
            end if;
        else
            result_sig <= (others => 'X');
        end if;
    end process;    
    result <= result_sig;
    zero <= '1' when result_sig = X"0000000000000000" else '0';
end behavioral;
