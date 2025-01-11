library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity EX_core is
    port (
        ALUOp      : in std_logic_vector(3 downto 0);    -- ALU operation
        ALUSrc     : in std_logic;                      -- ALU source (register or immediate)
        VecSig     : in std_logic;
        VecSig_mem : in std_logic;                      -- Vector instruction in the MEM stage
        VecSig_wb  : in std_logic;                      -- Vector instruction in the WB stage
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
    signal enable_scalar : std_logic;
    signal enable_vector : std_logic;
    signal read_data2_sig : std_logic_vector(63 downto 0);
    signal scalar_result : std_logic_vector(63 downto 0);
    signal vector_result : std_logic_vector(63 downto 0);
    signal scalar_zero : std_logic;
    signal vector_zero : std_logic;
    signal forward_from_mem : std_logic;
    signal forward_from_wb : std_logic;
begin

    next_pc <= std_logic_vector(unsigned(pc) + shift_left(unsigned(imm), 1));

    forward_from_mem <= '1' when (
        ((VecSig = '0' and VecSig_mem = '0') or (VecSig = '1' and VecSig_mem = '1')) 
        and RegWrite_mem = '1'
    ) else '0';

    forward_from_wb <= '1' when (
        ((VecSig = '0' and VecSig_wb = '0') or (VecSig = '1' and VecSig_wb = '1'))
        and RegWrite_wb = '1'
    ) else '0';

    a <= alu_result_mem when (forward_from_mem = '1' and rs1 = rd_mem) else
            data_out_wb when (forward_from_wb = '1' and rs1 = write_reg_wb) else 
            read_data1;

    read_data2_sig <= alu_result_mem when (forward_from_mem = '1' and rs2 = rd_mem) else
                        data_out_wb when (forward_from_wb = '1' and rs2 = write_reg_wb) else
                        read_data2_in;

    b <= imm when ALUSrc = '1' else read_data2_sig;

    alu: entity work.alu
        port map (
            a       => a,
            b       => b,
            ALUOp   => ALUOp,
            result  => scalar_result,
            zero    => scalar_zero
        );
    vector_alu: entity work.vector_alu
        port map (
            a       => a,
            b       => b,
            ALUOp   => ALUOp,
            result  => vector_result,
            zero    => vector_zero
        );
    -- Use single multiplexer for result selection
    result <= vector_result when VecSig = '1' else scalar_result;
    zero <= vector_zero when VecSig = '1' else scalar_zero;
    read_data2_out <= read_data2_sig;
end architecture;
