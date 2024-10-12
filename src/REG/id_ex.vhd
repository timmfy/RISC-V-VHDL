library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ID_EX is
    port(
        clk: in std_logic;
        reset: in std_logic;
        ALUOp_in      : in std_logic_vector(3 downto 0);    -- ALU operation
        ALUSrc_in     : in std_logic;                      -- ALU source (register or immediate)
        RegWrite_in   : in std_logic;                      -- Write to register file
        MemRead_in    : in std_logic;                      -- Read from memory
        MemWrite_in   : in std_logic;                      -- Write to memory
        MemToReg_in   : in std_logic;                      -- Memory to register
        MemSize_in    : in std_logic_vector(1 downto 0);  -- Memory size (byte, halfword, word)
        Branch_in     : in std_logic;                      -- Branch signal
        read_data1_in : in std_logic_vector(63 downto 0);
        read_data2_in : in std_logic_vector(63 downto 0);
        imm_in        : in std_logic_vector(63 downto 0);
        rd_in         : in std_logic_vector(4 downto 0);
        pc_in         : in std_logic_vector(63 downto 0);
        funct3_in     : in std_logic_vector(2 downto 0);
        rs1_in        : in std_logic_vector(4 downto 0);
        rs2_in        : in std_logic_vector(4 downto 0);
        ALUOp_out         : out std_logic_vector(3 downto 0);    -- ALU operation
        ALUSrc_out        : out std_logic;                      -- ALU source (register or immediate)
        RegWrite_out      : out std_logic;                      -- Write to register file
        MemRead_out       : out std_logic;                      -- Read from memory
        MemWrite_out      : out std_logic;                      -- Write to memory
        MemToReg_out      : out std_logic;                      -- Memory to register
        MemSize_out       : out std_logic_vector(1 downto 0);  -- Memory size (byte, halfword, word)
        Branch_out        : out std_logic;                      -- Branch signal
        read_data1_out    : out std_logic_vector(63 downto 0);
        read_data2_out    : out std_logic_vector(63 downto 0);
        imm_out           : out std_logic_vector(63 downto 0);
        rd_out            : out std_logic_vector(4 downto 0);
        pc_out            : out std_logic_vector(63 downto 0);
        funct3_out        : out std_logic_vector(2 downto 0);
        rs1_out            : out std_logic_vector(4 downto 0);
        rs2_out            : out std_logic_vector(4 downto 0)
    );
end entity ID_EX;

architecture behavior of ID_EX is
    signal ALUOp_reg     : std_logic_vector(3 downto 0);    -- ALU operation
    signal ALUSrc_reg    : std_logic;                      -- ALU source (register or immediate)
    signal RegWrite_reg  : std_logic;                      -- Write to register file
    signal MemRead_reg   : std_logic;                      -- Read from memory
    signal MemWrite_reg  : std_logic;                      -- Write to memory
    signal MemToReg_reg  : std_logic;                      -- Memory to register
    signal MemSize_reg   : std_logic_vector(1 downto 0);  -- Memory size (byte, halfword, word)
    signal Branch_reg    : std_logic;                      -- Branch signal
    signal read_data1_reg: std_logic_vector(63 downto 0);
    signal read_data2_reg: std_logic_vector(63 downto 0);
    signal imm_reg      : std_logic_vector(63 downto 0);
    signal rd_reg       : std_logic_vector(4 downto 0);
    signal pc_reg       : std_logic_vector(63 downto 0);
    signal funct3_reg    : std_logic_vector(2 downto 0);
    signal rs1_reg       : std_logic_vector(4 downto 0);
    signal rs2_reg       : std_logic_vector(4 downto 0);
begin
    process(clk, reset)
    begin
        if reset = '1' then
            ALUOp_reg <= (others => '0');
            ALUSrc_reg <= '0';
            RegWrite_reg <= '0';
            MemRead_reg <= '0';
            MemWrite_reg <= '0';
            MemToReg_reg <= '0';
            MemSize_reg <= (others => '0');
            Branch_reg <= '0';
            read_data1_reg <= (others => '0');
            read_data2_reg <= (others => '0');
            imm_reg <= (others => '0');
            rd_reg <= (others => '0');
            pc_reg <= (others => '0');
            funct3_reg <= (others => '0');
            rs1_reg <= (others => '0');
            rs2_reg <= (others => '0');
        elsif rising_edge(clk) then
            ALUOp_reg <= ALUOp_in;
            ALUSrc_reg <= ALUSrc_in;
            RegWrite_reg <= RegWrite_in;
            MemRead_reg <= MemRead_in;
            MemWrite_reg <= MemWrite_in;
            MemToReg_reg <= MemToReg_in;
            MemSize_reg <= MemSize_in;
            Branch_reg <= Branch_in;
            read_data1_reg <= read_data1_in;
            read_data2_reg <= read_data2_in;
            imm_reg <= imm_in;
            rd_reg <= rd_in;
            pc_reg <= pc_in;
            funct3_reg <= funct3_in;
            rs1_reg <= rs1_in;
            rs1_reg <= rs2_in;
        end if;
    end process;
    ALUOp_out <= ALUOp_reg;
    ALUSrc_out <= ALUSrc_reg;
    RegWrite_out <= RegWrite_reg;
    MemRead_out <= MemRead_reg;
    MemWrite_out <= MemWrite_reg;
    MemToReg_out <= MemToReg_reg;
    MemSize_out <= MemSize_reg;
    Branch_out <= Branch_reg;
    read_data1_out <= read_data1_reg;
    read_data2_out <= read_data2_reg;
    imm_out <= imm_reg;
    rd_out <= rd_reg;
    pc_out <= pc_reg;
    funct3_out <= funct3_reg;
    rs1_out <= rs1_reg;
    rs1_out <= rs2_reg;
end architecture;