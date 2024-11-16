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
    signal alu_results : std_logic_vector(63 downto 0);
begin
    shift_amount <= to_integer(unsigned(b(4 downto 0)));

    process(a, b, ALUOp)
    begin
        case ALUOp is
            when "0000" => alu_results <= std_logic_vector(unsigned(a) + unsigned(b));
            when "0001" => alu_results <= std_logic_vector(unsigned(a) - unsigned(b));
            when "0010" => alu_results <= a and b;
            when "0011" => alu_results <= a or b;
            when "0100" => alu_results <= a xor b;
            when "0101" => alu_results <= std_logic_vector(shift_left(unsigned(a), shift_amount));
            when "0110" => alu_results <= std_logic_vector(shift_right(unsigned(a), shift_amount));
            when "0111" => alu_results <= std_logic_vector(shift_right(signed(a), shift_amount));
            when "1000" =>
                if signed(a) < signed(b) then
                    alu_results <= (63 downto 1 => '0') & '1';
                else
                    alu_results <= (others => '0');
                end if;
            when "1001" =>
                if unsigned(a) < unsigned(b) then
                    alu_results <= (63 downto 1 => '0') & '1';
                else
                    alu_results <= (others => '0');
                end if;
            when others => alu_results <= (others => '0');
        end case;
    end process;

    result <= alu_results;
    zero <= '1' when alu_results = X"0000000000000000" else '0';
end behavioral;
