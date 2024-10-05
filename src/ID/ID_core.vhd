library ieee;
use ieee.std_logic_1164.all;


entity ID_core is
    port (
        pc : in std_logic_vector(31 downto 0);
        instruction : in std_logic_vector(31 downto 0);
        reg_write : in std_logic;
        write_reg : in std_logic_vector(4 downto 0);
        write_data : in std_logic_vector(63 downto 0);
        read_data1 : in std_logic_vector(63 downto 0);
        read_data2 : in std_logic_vector(63 downto 0);
        imm : out std_logic_vector(63 downto 0);
        func3 : out std_logic_vector(2 downto 0);
        rd : out std_logic_vector(4 downto 0);
        RegWrite   : out std_logic;                      -- Write to register file
        MemRead    : out std_logic;                      -- Read from memory
        MemWrite   : out std_logic;                      -- Write to memory
        MemToReg   : out std_logic;                      -- Memory to register
        MemSize    : out std_logic_vector(1 downto 0);  -- Memory size (byte, halfword, word)
        ALUSrc     : out std_logic;                      -- ALU source (register or immediate)
        Branch     : out std_logic;                      -- Branch signal
        ALUOp      : out std_logic_vector(3 downto 0)    -- ALU operation
    );
end ID_core;

architecture behavior of ID_core is
    signal opcode : std_logic_vector(6 downto 0);
    signal rs1 : std_logic_vector(4 downto 0);
    signal rs2 : std_logic_vector(4 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal funct7 : std_logic_vector(6 downto 0);
    signal imm_32: std_logic_vector(31 downto 0);
begin
    instruction_decoder : entity work.instruction_decoder
    port map(
        instruction => instruction,
        opcode => opcode,
        rs1 => rs1,
        rs2 => rs2,
        rd => rd,
        funct3 => funct3,
        funct7 => funct7,
        imm => imm_32
    );
    control_unit : entity work.control_unit
    port map(
        opcode => opcode,
        funct3 => funct3,
        funct7 => funct7,
        RegWrite => RegWrite,
        MemRead => MemRead,
        MemWrite => MemWrite,
        MemToReg => MemToReg,
        MemSize => MemSize,
        ALUSrc => ALUSrc,
        Branch => Branch,
        ALUOp => ALUOp
    );
    register_file : entity work.register_file
    port map(
        reg_write => reg_write,
        write_reg => write_reg,
        write_data => write_data,
        read_reg1 => rs1,
        read_reg2 => rs2,
        read_data1 => read_data1,
        read_data2 => read_data2
    );
    imm <= (63 downto 32 => imm_32(31)) & imm_32;
end behavior;