library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MEM_WB is
    port (
        clk : in std_logic;
        reset : in std_logic;
        RegWrite_in : in std_logic;
        MemToReg_in : in std_logic;
        data_out_in : in std_logic_vector(63 downto 0);
        alu_result_in : in std_logic_vector(63 downto 0);
        rd_in : in std_logic_vector(4 downto 0);
        RegWrite_out : out std_logic;
        MemToReg_out : out std_logic;
        data_out_out : out std_logic_vector(63 downto 0);
        alu_result_out : out std_logic_vector(63 downto 0);
        rd_out : out std_logic_vector(4 downto 0)
    );
end MEM_WB;

architecture behavior of MEM_WB is
    signal RegWrite_reg : std_logic;
    signal MemToReg_reg : std_logic;
    signal data_out_reg : std_logic_vector(63 downto 0);
    signal alu_result_reg : std_logic_vector(63 downto 0);
    signal rd_reg : std_logic_vector(4 downto 0);
begin
    process(clk, reset)
    begin
        if reset = '1' then
            RegWrite_reg <= '0';
            MemToReg_reg <= '0';
            data_out_reg <= (others => '0');
            alu_result_reg <= (others => '0');
            rd_reg <= (others => '0');
        elsif rising_edge(clk) then
            RegWrite_reg <= RegWrite_in;
            MemToReg_reg <= MemToReg_in;
            data_out_reg <= data_out_in;
            alu_result_reg <= alu_result_in;
            rd_reg <= rd_in;
        end if;
    end process;
    RegWrite_out <= RegWrite_reg;
    MemToReg_out <= MemToReg_reg;
    data_out_out <= data_out_reg;
    alu_result_out <= alu_result_reg;
    rd_out <= rd_reg;
end architecture;
