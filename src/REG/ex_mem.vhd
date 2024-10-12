library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EX_MEM is
    port (
        clk : in std_logic;
        reset : in std_logic;
        MemWrite_in : in std_logic;
        MemRead_in : in std_logic;
        MemSize_in : in std_logic_vector(1 downto 0);
        Branch_in : in std_logic;
        MemToReg_in : in std_logic;
        RegWrite_in : in std_logic;
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
        next_pc_out : out std_logic_vector(63 downto 0);
        zero_out : out std_logic;
        alu_result_out : out std_logic_vector(63 downto 0);
        read_data2_out : out std_logic_vector(63 downto 0);
        rd_out : out std_logic_vector(4 downto 0)
    );
end entity EX_MEM;

architecture behavior of EX_MEM is
    signal MemWrite_reg : std_logic;
    signal MemRead_reg : std_logic;
    signal MemSize_reg : std_logic_vector(1 downto 0);
    signal Branch_reg : std_logic;
    signal MemToReg_reg : std_logic;
    signal RegWrite_reg : std_logic;
    signal next_pc_reg : std_logic_vector(63 downto 0);
    signal zero_reg : std_logic;
    signal alu_result_reg : std_logic_vector(63 downto 0);
    signal read_data2_reg : std_logic_vector(63 downto 0);
    signal rd_reg : std_logic_vector(4 downto 0);
begin
    process(clk, reset)
    begin
        if reset = '1' then
            MemWrite_reg <= '0';
            MemRead_reg <= '0';
            MemSize_reg <= (others => '0');
            Branch_reg <= '0';
            MemToReg_reg <= '0';
            RegWrite_reg <= '0';
            next_pc_reg <= (others => '0');
            zero_reg <= '0';
            alu_result_reg <= (others => '0');
            read_data2_reg <= (others => '0');
            rd_reg <= (others => '0');
        elsif rising_edge(clk) then
            MemWrite_reg <= MemWrite_in;
            MemRead_reg <= MemRead_in;
            MemSize_reg <= MemSize_in;
            Branch_reg <= Branch_in;
            MemToReg_reg <= MemToReg_in;
            RegWrite_reg <= RegWrite_in;
            next_pc_reg <= next_pc_in;
            zero_reg <= zero_in;
            alu_result_reg <= alu_result_in;
            read_data2_reg <= read_data2_in;
            rd_reg <= rd_in;
        end if;
    end process;
    MemWrite_out <= MemWrite_reg;
    MemRead_out <= MemRead_reg;
    MemSize_out <= MemSize_reg;
    Branch_out <= Branch_reg;
    MemToReg_out <= MemToReg_reg;
    RegWrite_out <= RegWrite_reg;
    next_pc_out <= next_pc_reg;
    zero_out <= zero_reg;
    alu_result_out <= alu_result_reg;
    read_data2_out <= read_data2_reg;
    rd_out <= rd_reg;
end architecture;