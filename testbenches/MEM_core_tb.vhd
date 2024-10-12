library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MEM_core_tb is
end MEM_core_tb;

architecture behavior of MEM_core_tb is
    signal MemWrite : std_logic;
    signal MemRead : std_logic;
    signal MemSize : std_logic_vector(1 downto 0);
    signal Branch : std_logic;
    signal zero : std_logic;
    signal alu_result : std_logic_vector(63 downto 0);
    signal read_data2 : std_logic_vector(63 downto 0);
    signal PCSrc : std_logic;
    signal data_out : std_logic_vector(63 downto 0);
begin
    dut: entity work.MEM_core
    port map(
        MemWrite => MemWrite,
        MemRead => MemRead,
        MemSize => MemSize,
        Branch => Branch,
        zero => zero,
        alu_result => alu_result,
        read_data2 => read_data2,
        PCSrc => PCSrc,
        data_out => data_out
    );

    stimulus: process
    begin
        --Test case 1
        --Write byte to the address 0x
        MemWrite <= '1';
        MemRead <= '0';
        MemSize <= "00";
        Branch <= '0';
        zero <= '0';
        alu_result <= x"0000000000000008";
        read_data2 <= x"0000000000000010";
        wait for 10 ns;

        --Test case 2
        --Read byte from the address 0x
        MemWrite <= '0';
        MemRead <= '1';
        MemSize <= "00";
        Branch <= '0';
        zero <= '0';
        alu_result <= x"0000000000000008";
        read_data2 <= x"0000000000000000";
        wait for 10 ns;

        MemWrite <= '1';
        MemRead <= '0';
        MemSize <= "00";
        Branch <= '0';
        zero <= '0';
        alu_result <= x"0000000000000010";
        read_data2 <= x"0000000000000001";
        wait for 10 ns;
        
        --Test case 3
        --Write halfword to the address 0x
        MemWrite <= '1';
        MemRead <= '0';
        MemSize <= "01";
        Branch <= '0';
        zero <= '0';
        alu_result <= x"0000000000000008";
        read_data2 <= x"0000000000000110";
        wait for 10 ns;

        --Test case 4
        --Read halfword from the address 0x
        MemWrite <= '0';
        MemRead <= '1';
        MemSize <= "01";
        Branch <= '0';
        zero <= '0';
        alu_result <= x"0000000000000008";
        read_data2 <= x"0000000000000000";
        wait for 10 ns;

        --Test case 5
        --Write word to the address 0x
        MemWrite <= '1';
        MemRead <= '0';
        MemSize <= "10";
        Branch <= '0';
        zero <= '0';
        alu_result <= x"0000000000000008";
        read_data2 <= x"0000000001011010";
        wait for 10 ns;

        --Test case 6
        --Read word from the address 0x
        MemWrite <= '0';
        MemRead <= '1';
        MemSize <= "10";
        Branch <= '0';
        zero <= '0';
        alu_result <= x"0000000000000008";
        read_data2 <= x"0000000000000000";
        wait for 10 ns;

        --Test case 7
        --Write doubleword to the address 0x
        MemWrite <= '1';
        MemRead <= '0';
        MemSize <= "11";
        Branch <= '0';
        zero <= '0';
        alu_result <= x"0000000000000008";
        read_data2 <= x"1000001000000000";
        wait for 10 ns;

        --Test case 8
        --Read doubleword from the address 0x
        MemWrite <= '0';
        MemRead <= '1';
        MemSize <= "11";
        Branch <= '0';
        zero <= '0';
        alu_result <= x"0000000000000008";
        read_data2 <= x"0000000000000000";
        wait for 10 ns;

        --Test case 9
        --Branch is true
        MemWrite <= '0';
        MemRead <= '0';
        MemSize <= "00";
        Branch <= '1';
        zero <= '1';
        alu_result <= x"0000000000000008";
        read_data2 <= x"0000000000000000";
        wait for 10 ns;
    end process;
end architecture;