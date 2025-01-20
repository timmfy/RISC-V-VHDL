library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity alu is
    port (
        a : in std_logic_vector(63 downto 0);
        b : in std_logic_vector(63 downto 0);
        ALUOp : in std_logic_vector(3 downto 0);
        result : out std_logic_vector(63 downto 0)
        --zero : out std_logic
    );
end alu;

architecture behavioral of alu is
    signal shift_amount : integer;
    signal alu_results : std_logic_vector(63 downto 0);
begin
    process(a, b, ALUOp)
    begin
        shift_amount <= to_integer(unsigned(b(4 downto 0)));
        case ALUOp is
            when "0000" => -- Addition
                alu_results <= std_logic_vector(unsigned(a) + unsigned(b));
            when "0001" => -- Subtraction
                alu_results <= std_logic_vector(unsigned(a) - unsigned(b));
            when "0010" => -- AND
                alu_results <= a and b;
            when "0011" => -- OR
                alu_results <= a or b;
            when "0100" => -- XOR
                alu_results <= a xor b;
            when "0101" => -- Shift left logical
                alu_results <= std_logic_vector(shift_left(unsigned(a), shift_amount));
            when "0110" => -- Shift right logical
                alu_results <= std_logic_vector(shift_right(unsigned(a), shift_amount));
            when "0111" => -- Shift right arithmetic
                alu_results <= std_logic_vector(shift_right(signed(a), shift_amount));
            when "1000" => -- Set less than
                if signed(a) < signed(b) then
                    alu_results <= (63 downto 1 => '0') & '1';
                else
                    alu_results <= (others => '0');
                end if;
            when "1001" => -- Set less than unsigned
                if unsigned(a) < unsigned(b) then
                    alu_results <= (63 downto 1 => '0') & '1';
                else
                    alu_results <= (others => '0');
                end if;
            when others =>
                alu_results <= (others => '0');
        end case;
    end process;

    result <= alu_results;
    --zero <= '1' when alu_results = x"0000000000000000" else '0';
end behavioral;
-- (63 downto 1 => '0') & '1' when ALUOp = "1000" and signed(a) < signed(b) else
-- (others => '0') when ALUOp = "1000" and signed(a) >= signed(b) else
-- (63 downto 1 => '0') & '1' when ALUOp = "1001" and unsigned(a) < unsigned(b) else
-- (others => '0') when ALUOp = "1001" and unsigned(a) >= unsigned(b) else
-- (others => '0');