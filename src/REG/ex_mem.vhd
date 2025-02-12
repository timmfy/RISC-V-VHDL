library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EX_MEM is
    port (
        clk : in std_logic;
        --reset : in std_logic;
        MemWrite_in : in std_logic;
        MemRead_in : in std_logic;
        MemSize_in : in std_logic_vector(1 downto 0);
        Branch_in : in std_logic;
        EX_flush : in std_logic;
        MemToReg_in : in std_logic;
        RegWrite_in : in std_logic;
        VecSig_in : in std_logic;
        next_pc_in : in std_logic_vector(63 downto 0);
        zero_in : in std_logic;
        alu_result_in : in std_logic_vector(63 downto 0);
        read_data2_in : in std_logic_vector(63 downto 0);
        rd_in : in std_logic_vector(4 downto 0);
        MemWrite_out : out std_logic;
        MemRead_out : out std_logic;
        MemSize_out : out std_logic_vector(1 downto 0);
        Branch_out : out std_logic;
        MemToReg_out : out std_logic;
        RegWrite_out : out std_logic;
        VecSig_out : out std_logic;
        next_pc_out : out std_logic_vector(63 downto 0);
        zero_out : out std_logic;
        alu_result_out : out std_logic_vector(63 downto 0);
        read_data2_out : out std_logic_vector(63 downto 0);
        rd_out : out std_logic_vector(4 downto 0)
    );
end entity EX_MEM;

architecture behavior of EX_MEM is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if EX_flush = '1' then
                Branch_out <= '0';
                MemToReg_out <= '0';
                MemWrite_out <= '0';
                MemRead_out <= '0';
                VecSig_out <= '0';
                RegWrite_out <= '0';
                MemSize_out <= (others => '0');
                next_pc_out <= (others => '0');
                zero_out <= '0';
                alu_result_out <= (others => '0');
                read_data2_out <= (others => '0');
                rd_out <= (others => '0');
            else
                Branch_out <= Branch_in;
                MemToReg_out <= MemToReg_in;
                MemWrite_out <= MemWrite_in;
                MemRead_out <= MemRead_in;
                RegWrite_out <= RegWrite_in;
                VecSig_out <= VecSig_in;
                MemSize_out <= MemSize_in;
                next_pc_out <= next_pc_in;
                zero_out <= zero_in;
                alu_result_out <= alu_result_in;
                read_data2_out <= read_data2_in;
                rd_out <= rd_in;
            end if;
        end if;
    end process;
end architecture;