library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is 
    port(
        ctrl_zero  : in std_logic;
        opcode     : in  std_logic_vector(6 downto 0);  -- The opcode from the instruction
        funct3     : in  std_logic_vector(2 downto 0);  -- For R-type and B-type instructions
        funct7     : in  std_logic_vector(6 downto 0);  -- For R-type instructions
        RegWrite   : out std_logic;                      -- Write to register file
        VecSig     : out std_logic;                      -- Use vector register
        MemRead    : out std_logic;                      -- Read from memory
        MemWrite   : out std_logic;                      -- Write to memory
        MemToReg   : out std_logic;                      -- Memory to register
        MemSize    : out std_logic_vector(1 downto 0);  -- Memory size (byte, halfword, word)
        ALUSrc     : out std_logic;                      -- ALU source (register or immediate)
        Branch     : out std_logic;                      -- Branch signal
        ALUOp      : out std_logic_vector(3 downto 0)    -- ALU operation
        -- ALUOp = 0000 -> ADD
        -- ALUOp = 0001 -> SUB
        -- ALUOp = 0010 -> AND
        -- ALUOp = 0011 -> OR
        -- ALUOp = 0100 -> XOR
        -- ALUOp = 0101 -> SLL
        -- ALUOp = 0110 -> SRL
        -- ALUOp = 0111 -> SRA
        -- ALUOp = 1000 -> SLT
        -- ALUOp = 1009 -> SLTU
    );
end control_unit;

architecture behavior of control_unit is
    -- Define opcode types for better readability
    constant R_TYPE     : std_logic_vector(6 downto 0) := "0110011";  -- R-type
    constant I_TYPE     : std_logic_vector(6 downto 0) := "0010011";  -- I-type
    constant LOAD_TYPE  : std_logic_vector(6 downto 0) := "0000011";  -- Load
    constant STORE_TYPE : std_logic_vector(6 downto 0) := "0100011";  -- Store
    constant BRANCH_TYPE: std_logic_vector(6 downto 0) := "1100011";  -- Branch
    constant JALR_TYPE  : std_logic_vector(6 downto 0) := "1100111";  -- JALR
    constant JAL_TYPE   : std_logic_vector(6 downto 0) := "1101111";  -- JAL
    constant LUI_TYPE   : std_logic_vector(6 downto 0) := "0110111";  -- LUI
    constant AUIPC_TYPE : std_logic_vector(6 downto 0) := "0010111";  -- AUIPC
    constant V_TYPE     : std_logic_vector(6 downto 0) := "1010111";  -- Vector operation

begin
    -- Control signals assignment without process
    RegWrite <= '0' when ctrl_zero = '1' else
                '1' when opcode = R_TYPE or opcode = I_TYPE or opcode = LOAD_TYPE or opcode = JALR_TYPE or opcode = JAL_TYPE or opcode = LUI_TYPE or opcode = AUIPC_TYPE or opcode = V_TYPE else
                '0';

    VecSig <= '1' when opcode = V_TYPE and ctrl_zero = '0' else '0';

    MemRead <= '1' when opcode = LOAD_TYPE and ctrl_zero = '0' else '0';

    MemWrite <= '1' when opcode = STORE_TYPE and ctrl_zero = '0' else '0';

    MemToReg <= '1' when opcode = LOAD_TYPE and ctrl_zero = '0' else '0';

    ALUSrc <= '1' when ((opcode = I_TYPE or opcode = LOAD_TYPE or opcode = STORE_TYPE or opcode = JALR_TYPE or opcode = LUI_TYPE or opcode = AUIPC_TYPE) or (opcode = V_TYPE and funct3 = "011")) and ctrl_zero = '0' else '0';

    Branch <= '1' when opcode = BRANCH_TYPE and ctrl_zero = '0' else '0';

    MemSize <= 
        "00" when (opcode = LOAD_TYPE or opcode = STORE_TYPE) and funct3 = "000" and ctrl_zero = '0' else  -- Byte
        "01" when (opcode = LOAD_TYPE or opcode = STORE_TYPE) and funct3 = "001" and ctrl_zero = '0' else  -- Halfword
        "10" when (opcode = LOAD_TYPE or opcode = STORE_TYPE) and funct3 = "010" and ctrl_zero = '0' else  -- Word
        "11";  -- Default to Doubleword

    -- ALU operation assignment
    ALUOp <=
        -- R-type instructions
        "0000" when opcode = R_TYPE and funct7 = "0000000" and funct3 = "000" and ctrl_zero = '0' else  -- ADD
        "0101" when opcode = R_TYPE and funct7 = "0000000" and funct3 = "001" and ctrl_zero = '0' else  -- SLL
        "1000" when opcode = R_TYPE and funct7 = "0000000" and funct3 = "010" and ctrl_zero = '0' else  -- SLT
        "1001" when opcode = R_TYPE and funct7 = "0000000" and funct3 = "011" and ctrl_zero = '0' else  -- SLTU
        "0100" when opcode = R_TYPE and funct7 = "0000000" and funct3 = "100" and ctrl_zero = '0' else  -- XOR
        "0110" when opcode = R_TYPE and funct7 = "0000000" and funct3 = "101" and ctrl_zero = '0' else  -- SRL
        "0011" when opcode = R_TYPE and funct7 = "0000000" and funct3 = "110" and ctrl_zero = '0' else  -- OR
        "0010" when opcode = R_TYPE and funct7 = "0000000" and funct3 = "111" and ctrl_zero = '0' else  -- AND
        "0001" when opcode = R_TYPE and funct7 = "0100000" and funct3 = "000" and ctrl_zero = '0' else  -- SUB
        "0111" when opcode = R_TYPE and funct7 = "0100000" and funct3 = "101" and ctrl_zero = '0' else  -- SRA

        -- V-type Instructions
        "0000" when opcode = V_TYPE and funct7 = "0000000" and funct3 = "011" else -- ADDI

        -- I-type instructions
        "0000" when opcode = I_TYPE and funct3 = "000" and ctrl_zero = '0' else  -- ADDI
        "0101" when opcode = I_TYPE and funct3 = "001" and ctrl_zero = '0' else  -- SLLI
        "1000" when opcode = I_TYPE and funct3 = "010" and ctrl_zero = '0' else  -- SLTI
        "1001" when opcode = I_TYPE and funct3 = "011" and ctrl_zero = '0' else  -- SLTIU
        "0100" when opcode = I_TYPE and funct3 = "100" and ctrl_zero = '0' else  -- XORI
        "0110" when opcode = I_TYPE and funct3 = "101" and ctrl_zero = '0' and funct7 = "0000000" else  -- SRLI
        "0111" when opcode = I_TYPE and funct3 = "101" and ctrl_zero = '0' and funct7 = "0100000" else  -- SRAI
        "0011" when opcode = I_TYPE and funct3 = "110" and ctrl_zero = '0' else  -- ORI
        "0010" when opcode = I_TYPE and funct3 = "111" and ctrl_zero = '0' else  -- ANDI

        -- Load and Store instructions
        "0000" when (opcode = LOAD_TYPE or opcode = STORE_TYPE) and ctrl_zero = '0' else  -- ADD

        -- Branch instruction
        "0001" when opcode = BRANCH_TYPE and ctrl_zero = '0' else  -- SUB (for comparison)

        -- JALR, JAL, LUI, AUIPC instructions
        "0000" when (opcode = JALR_TYPE or opcode = JAL_TYPE or opcode = LUI_TYPE or opcode = AUIPC_TYPE) and ctrl_zero = '0' else  -- Default ADD

        -- Default case
        "0000";

end architecture;
