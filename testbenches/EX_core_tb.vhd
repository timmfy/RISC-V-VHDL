library ieee;
use ieee.std_logic_1164.all;

entity EX_core_tb is
end EX_core_tb;

architecture behavior of EX_core_tb is
    signal ALUOp : std_logic_vector(3 downto 0);
    signal ALUSrc : std_logic;
    signal read_data1 : std_logic_vector(63 downto 0);
    signal read_data2 : std_logic_vector(63 downto 0);
    signal imm : std_logic_vector(63 downto 0);
    signal rd : std_logic_vector(4 downto 0);
    signal pc : std_logic_vector(63 downto 0);
    signal result : std_logic_vector(63 downto 0);
    signal zero : std_logic;
    signal next_pc : std_logic_vector(63 downto 0);
begin
    dut: entity work.EX_core
    port map(
        ALUOp => ALUOp,
        ALUSrc => ALUSrc,
        read_data1 => read_data1,
        read_data2 => read_data2,
        imm => imm,
        rd => rd,
        pc => pc,
        result => result,
        zero => zero,
        next_pc => next_pc
    );

    stimulus: process
    begin
        --Test case 1
        --Sum of two numbers 1 and 2
        ALUOp <= "0000";
        ALUSrc <= '0';
        read_data1 <= x"0000000000000001";
        read_data2 <= x"0000000000000002";
        imm <= x"0000000000000000";
        rd <= "00001";
        pc <= x"0000000000000000";
        wait for 10 ns;
        assert result = x"0000000000000003" report "Test case 1 failed" severity error;

        --Test case 2
        --Subtraction of two numbers 2 and 1
        ALUOp <= "0001";
        ALUSrc <= '0';
        read_data1 <= x"0000000000000002";
        read_data2 <= x"0000000000000001";
        imm <= x"0000000000000000";
        rd <= "00001";
        pc <= x"0000000000000000";
        wait for 10 ns;
        assert result = x"0000000000000001" report "Test case 2 failed" severity error;

        --Test case 3
        --Subtraction of two numbers 1 and 2
        ALUOp <= "0001";
        ALUSrc <= '0';
        read_data1 <= x"0000000000000001";
        read_data2 <= x"0000000000000002";
        imm <= x"0000000000000000";
        rd <= "00001";
        pc <= x"0000000000000000";
        wait for 10 ns;
        assert result = x"ffffffffffffffff" report "Test case 3 failed" severity error;

        --Test case 4
        --AND of two numbers 1 and 2
        ALUOp <= "0010";
        ALUSrc <= '0';
        read_data1 <= x"0000000000000001";
        read_data2 <= x"0000000000000002";
        imm <= x"0000000000000000";
        rd <= "00001";
        pc <= x"0000000000000000";
        wait for 10 ns;
        assert result = x"0000000000000000" report "Test case 4 failed" severity error;

        --Test case 5
        --OR of two numbers 1 and 2
        ALUOp <= "0011";
        ALUSrc <= '0';
        read_data1 <= x"0000000000000001";
        read_data2 <= x"0000000000000002";
        imm <= x"0000000000000000";
        rd <= "00001";
        pc <= x"0000000000000000";
        wait for 10 ns;
        assert result = x"0000000000000003" report "Test case 5 failed" severity error;

        --Test case 6
        --XOR of two numbers 1 and 2
        ALUOp <= "0100";
        ALUSrc <= '0';
        read_data1 <= x"0000000000000001";
        read_data2 <= x"0000000000000002";
        imm <= x"0000000000000000";
        rd <= "00001";
        pc <= x"0000000000000000";
        wait for 10 ns;
        assert result = x"0000000000000003" report "Test case 6 failed" severity error;

        --Test case 7
        --Shift left of 1 by 2
        ALUOp <= "0101";
        ALUSrc <= '0';
        read_data1 <= x"0000000000000001";
        read_data2 <= x"0000000000000002";
        imm <= x"0000000000000000";
        rd <= "00001";
        pc <= x"0000000000000000";
        wait for 10 ns;
        assert result = x"0000000000000004" report "Test case 7 failed" severity error;

        --Test case 8
        --Shift right of 4 by 2
        ALUOp <= "0110";
        ALUSrc <= '0';
        read_data1 <= x"0000000000000004";
        read_data2 <= x"0000000000000002";
        imm <= x"0000000000000000";
        rd <= "00001";
        pc <= x"0000000000000000";
        wait for 10 ns;
        assert result = x"0000000000000001" report "Test case 8 failed" severity error;

        --Test case 9
        --Shift right arithmetic of -4 by 2
        ALUOp <= "0111";
        ALUSrc <= '0';
        read_data1 <= x"fffffffffffffffc";
        read_data2 <= x"0000000000000002";
        imm <= x"0000000000000000";
        rd <= "00001";
        pc <= x"0000000000000000";
        wait for 10 ns;
        assert result = x"ffffffffffffffff" report "Test case 9 failed" severity error;

        --Test case 10
        --Less than of -1 and 2
        ALUOp <= "1000";
        ALUSrc <= '0';
        read_data1 <= x"ffffffffffffffff";
        read_data2 <= x"0000000000000002";
        imm <= x"0000000000000000";
        rd <= "00001";
        pc <= x"0000000000000000";
        wait for 10 ns;
        assert result = x"0000000000000001" report "Test case 10 failed" severity error;

        --Test case 11
        --Less than of 2 and 1
        ALUOp <= "1001";
        ALUSrc <= '0';
        read_data1 <= x"0000000000000002";
        read_data2 <= x"0000000000000001";
        imm <= x"0000000000000000";
        rd <= "00001";
        pc <= x"0000000000000000";
        wait for 10 ns;
        assert result = x"0000000000000000" report "Test case 11 failed" severity error;

        --Test case 12
        --Branching
        ALUOp <= "0000";
        ALUSrc <= '1';
        read_data1 <= x"0000000000000001";
        read_data2 <= x"0000000000000002";
        imm <= x"0000000000000008";
        rd <= "00001";
        pc <= x"0000000000000000";
        wait for 10 ns;
        assert next_pc = x"0000000000000020" report "Test case 12 failed" severity error;
        wait;
    end process;
end architecture;