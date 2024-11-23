library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MEM_WB is
    port (
        clk : in std_logic;
        --reset : in std_logic;
        RegWrite_in : in std_logic;
        MemToReg_in : in std_logic;
        flush_in : in std_logic;
        data_out_in : in std_logic_vector(63 downto 0);
        alu_result_in : in std_logic_vector(63 downto 0);
        rd_in : in std_logic_vector(4 downto 0);
        RegWrite_out : out std_logic;
        MemToReg_out : out std_logic;
        flush_out : out std_logic;
        data_out_out : out std_logic_vector(63 downto 0);
        alu_result_out : out std_logic_vector(63 downto 0);
        rd_out : out std_logic_vector(4 downto 0)
    );
end MEM_WB;

architecture behavior of MEM_WB is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            RegWrite_out <= RegWrite_in;
            MemToReg_out <= MemToReg_in;
            data_out_out <= data_out_in;
            alu_result_out <= alu_result_in;
            rd_out <= rd_in;
            flush_out <= flush_in;
        end if;
    end process;
end architecture;
