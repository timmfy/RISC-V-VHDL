library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity EX_core is
    port (
        ALUOp      : in std_logic_vector(3 downto 0);    -- ALU operation
        ALUSrc     : in std_logic;                      -- ALU source (register or immediate)
        RegWrite_mem : in std_logic;
        RegWrite_wb : in std_logic;
        write_reg_wb : in std_logic_vector(4 downto 0);
        rd_ex : in std_logic_vector(4 downto 0);
        read_data1 : in std_logic_vector(63 downto 0);
        read_data2 : in std_logic_vector(63 downto 0);
        rs1 : in std_logic_vector(4 downto 0);
        rs2 : in std_logic_vector(4 downto 0);
        imm : in std_logic_vector(63 downto 0);
        rd : in std_logic_vector(4 downto 0);
        pc : in std_logic_vector(63 downto 0);
        alu_result_mem : in std_logic_vector(63 downto 0);
        data_out_wb : in std_logic_vector(63 downto 0);
        result : out std_logic_vector(63 downto 0);
        zero : out std_logic;
        next_pc : out std_logic_vector(63 downto 0)
    );
end EX_core;

architecture behavior of EX_core is
    signal a : std_logic_vector(63 downto 0);
    signal b : std_logic_vector(63 downto 0);
begin
    next_pc <= std_logic_vector(unsigned(pc) + shift_left(unsigned(imm), 2));
    if RegWrite_mem = '1' or RegWrite_wb = '1'then
        if rs1 = rd_ex then
            a <= alu_result_mem;
        elsif rs1 = write_data_wb then
            a <= data_out_wb;
        elsif rs2 = rd_ex then
            b <= alu_result_mem;
        elsif rs2 = write_data_wb then
            b <= data_out_wb;    
        end if;
    else
        a <= read_data1:
        b <= imm when ALUSrc = '1' else read_data2;
    end if;
    alu : entity work.alu
    port map(
        a => read_data1,
        b => b,
        ALUOp => ALUOp,
        ALUSrc => ALUSrc,
        result => result,
        zero => zero
    );
end architecture;