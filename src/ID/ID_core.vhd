library ieee;
use ieee.std_logic_1164.all;


entity ID_core is
    port (
        instruction : in std_logic_vector(31 downto 0);
        MemToReg_ex : in std_logic;
        rd_ex : in std_logic_vector(4 downto 0);
        imm : out std_logic_vector(63 downto 0);
        funct3 : out std_logic_vector(2 downto 0);
        rd : out std_logic_vector(4 downto 0);
        RegWrite   : out std_logic;                      -- Write to register file
        VecSig     : out std_logic;                      -- Use vector register
        VecSig_ex  : in std_logic;
        MemRead    : out std_logic;                      -- Read from memory
        MemWrite   : out std_logic;                      -- Write to memory
        MemToReg   : out std_logic;                      -- Memory to register
        MemSize    : out std_logic_vector(1 downto 0);  -- Memory size (byte, halfword, word)
        ALUSrc     : out std_logic;                      -- ALU source (register or immediate)
        Branch     : out std_logic;                      -- Branch signal
        ALUOp      : out std_logic_vector(3 downto 0);    -- ALU operation
        rs1        : out std_logic_vector(4 downto 0);
        rs2        : out std_logic_vector(4 downto 0);
        IF_ID_Write : out std_logic;
        PCWrite : out std_logic
    );
end ID_core;

architecture behavior of ID_core is
    signal opcode_sig : std_logic_vector(6 downto 0);
    signal rs1_sig : std_logic_vector(4 downto 0);
    signal rs2_sig : std_logic_vector(4 downto 0);
    signal funct3_sig : std_logic_vector(2 downto 0);
    signal funct7_sig : std_logic_vector(6 downto 0);
    signal imm_32_sig: std_logic_vector(31 downto 0);
    signal scalar_imm : std_logic_vector(63 downto 0);
    signal vector_imm : std_logic_vector(63 downto 0);
    signal VecSig_sig : std_logic;
    signal rd_sig : std_logic_vector(4 downto 0);
    signal ctrl_zero_sig : std_logic;
    signal RegWrite_sig : std_logic;
    signal MemRead_sig : std_logic;
    signal MemWrite_sig : std_logic;
    signal MemToReg_sig : std_logic;
    signal MemSize_sig : std_logic_vector(1 downto 0);
    signal ALUSrc_sig : std_logic;
    signal Branch_sig : std_logic;
    signal ALUOp_sig : std_logic_vector(3 downto 0);
begin
    instruction_decoder : entity work.instruction_decoder(behavior)
    port map(
        instruction => instruction,
        opcode => opcode_sig,
        rs1 => rs1_sig,
        rs2 => rs2_sig,
        rd => rd_sig,
        funct3 => funct3_sig,
        funct7 => funct7_sig,
        imm => imm_32_sig
    );
    hazard_detection_unit : entity work.hazard_detection_unit(behavior)
    port map(
        MemToReg_ex => MemToReg_ex,
        VecSig => VecSig_sig,
        VecSig_ex => VecSig_ex,
        opcode => opcode_sig,
        rd_ex => rd_ex,
        rs1 => rs1_sig,
        rs2 => rs2_sig,
        ctrl_zero => ctrl_zero_sig,
        PCWrite => PCWrite,
        IF_ID_Write => IF_ID_Write
    );
    control_unit : entity work.control_unit(behavior)
    port map(
        opcode => opcode_sig,
        funct3 => funct3_sig,
        funct7 => funct7_sig,
        RegWrite => RegWrite_sig,
        VecSig => VecSig_sig,
        MemRead => MemRead_sig,
        MemWrite => MemWrite_sig,
        MemToReg => MemToReg_sig,
        MemSize => MemSize_sig,
        ALUSrc => ALUSrc_sig,
        Branch => Branch_sig,
        ALUOp => ALUOp_sig
    );
    scalar_imm <= (63 downto 32 => imm_32_sig(31)) & imm_32_sig when ctrl_zero_sig = '0' else (others => '0');
    vector_imm <= imm_32_sig & imm_32_sig when ctrl_zero_sig = '0' else (others => '0');
    imm <= vector_imm when VecSig_sig = '1' else scalar_imm;
    VecSig <= VecSig_sig when ctrl_zero_sig = '0' else VecSig_ex;
    rd <= rd_sig when ctrl_zero_sig = '0' else rd_ex;
    funct3 <= funct3_sig when ctrl_zero_sig = '0' else (others => '0');
    rs1 <= rs1_sig when ctrl_zero_sig = '0' else (others => '0');
    rs2 <= rs2_sig when ctrl_zero_sig = '0' else (others => '0');
    RegWrite <= RegWrite_sig when ctrl_zero_sig = '0' else '0';
    MemRead <= MemRead_sig when ctrl_zero_sig = '0' else '0';
    MemWrite <= MemWrite_sig when ctrl_zero_sig = '0' else '0';
    MemToReg <= MemToReg_sig when ctrl_zero_sig = '0' else '0';
    MemSize <= MemSize_sig when ctrl_zero_sig = '0' else (others => '0');
    ALUSrc <= ALUSrc_sig when ctrl_zero_sig = '0' else '0';
    Branch <= Branch_sig when ctrl_zero_sig = '0' else '0';
    ALUOp <= ALUOp_sig when ctrl_zero_sig = '0' else (others => '0');
end behavior;
