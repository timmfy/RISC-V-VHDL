library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity EX_core is
    port (
        ALUOp      : in std_logic_vector(3 downto 0);    -- ALU operation
        ALUSrc     : in std_logic;                      -- ALU source (register or immediate)
        RegWrite_mem : in std_logic;                    -- Instruction in the MEM stage writes to a register
        RegWrite_wb : in std_logic;                     -- Instruction in the WB stage writes to a register
        write_reg_wb : in std_logic_vector(4 downto 0);
        rd_mem : in std_logic_vector(4 downto 0);
        read_data1 : in std_logic_vector(63 downto 0);
        read_data2_in : in std_logic_vector(63 downto 0);
        read_data2_out : out std_logic_vector(63 downto 0);
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
    signal read_data2_sig : std_logic_vector(63 downto 0);
begin
    process(write_reg_wb, ALUOp, ALUSrc, RegWrite_wb, RegWrite_mem, imm, alu_result_mem, data_out_wb, rs1, rs2, read_data1, read_data2_in, pc, rd, rd_mem)
    begin
        next_pc <= std_logic_vector(unsigned(pc) + shift_left(unsigned(imm), 2));
        if RegWrite_mem = '1' or RegWrite_wb = '1' then
            if rs1 = rd_mem then
                a <= alu_result_mem;
            elsif rs1 = write_reg_wb then
                a <= data_out_wb;
            else
                a <= read_data1;
            end if;

            if rs2 = rd_mem then
                read_data2_sig <= alu_result_mem;
            elsif rs2 = write_reg_wb then
                read_data2_sig <= data_out_wb;
            else
                read_data2_sig <= read_data2_in; 
            end if;
        else
            a <= read_data1;
            read_data2_sig <= read_data2_in;
        end if;

        if ALUsrc = '1' then
            b <= imm;
        else
            b <= read_data2_sig;
        end if;
    end process;
    alu : entity work.alu
    port map(
        a => a,
        b => b,
        ALUOp => ALUOp,
        ALUSrc => ALUSrc,
        result => result,
        zero => zero
    );
    read_data2_out <= read_data2_sig;
end architecture;