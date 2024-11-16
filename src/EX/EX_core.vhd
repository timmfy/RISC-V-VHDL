library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity EX_core is
    port (
        ALUOp      : in std_logic_vector(3 downto 0);    -- ALU operation
        ALUSrc     : in std_logic;                      -- ALU source (register or immediate)
        RegWrite_mem : in std_logic;                    -- Instruction in the MEM stage writes to a register
        RegWrite_wb : in std_logic;                     -- Instruction in the WB stage writes to a register
        write_reg_wb : in std_logic_vector(4 downto 0); -- Register to write to in the WB stage
        rd_mem : in std_logic_vector(4 downto 0);       -- Register to write to in the MEM stage
        read_data1 : in std_logic_vector(63 downto 0);
        read_data2_in : in std_logic_vector(63 downto 0);
        read_data2_out : out std_logic_vector(63 downto 0);
        rs1 : in std_logic_vector(4 downto 0);
        rs2 : in std_logic_vector(4 downto 0);
        imm : in std_logic_vector(63 downto 0);
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
    signal read_data1_sig : std_logic_vector(63 downto 0);
    signal read_data2_sig : std_logic_vector(63 downto 0);
begin
    next_pc <= std_logic_vector(unsigned(pc) + shift_left(unsigned(imm), 1));

    read_data1_sig <= alu_result_mem when RegWrite_mem = '1' and (rs1 = rd_mem) else
                      data_out_wb   when RegWrite_wb = '1' and (rs1 = write_reg_wb) else
                      read_data1;

    read_data2_sig <= alu_result_mem when RegWrite_mem = '1' and (rs2 = rd_mem) else
                      data_out_wb   when RegWrite_wb = '1' and (rs2 = write_reg_wb) else
                      read_data2_in;

    a <= read_data1_sig;

    b <= imm when ALUSrc = '1' else
         read_data2_sig;

    alu : entity work.alu
        port map (
            a       => a,
            b       => b,
            ALUOp   => ALUOp,
            result  => result,
            zero    => zero
        );

    read_data2_out <= read_data2_sig;
end architecture;