library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ID_EX is
    port(
        clk: in std_logic;
        --reset: in std_logic;
        ALUOp_in      : in std_logic_vector(3 downto 0);    -- ALU operation
        ALUSrc_in     : in std_logic;                      -- ALU source (register or immediate)
        RegWrite_in   : in std_logic;                      -- Write to register file
        VecSig_in     : in std_logic;
        MemRead_in    : in std_logic;                      -- Read from memory
        MemWrite_in   : in std_logic;                      -- Write to memory
        MemToReg_in   : in std_logic;                      -- Memory to register
        MemSize_in    : in std_logic_vector(1 downto 0);  -- Memory size (byte, halfword, word)
        Branch_in     : in std_logic;                      -- Branch signal
        ID_flush      : in std_logic;                   -- Flush signal 
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
        VecSig_out        : out std_logic;
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
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if ID_flush = '0' then
                ALUOp_out <= ALUOp_in;
                ALUSrc_out <= ALUSrc_in;
                VecSig_out <= VecSig_in;
                RegWrite_out <= RegWrite_in;
                MemRead_out <= MemRead_in;
                MemWrite_out <= MemWrite_in;
                MemToReg_out <= MemToReg_in;
                MemSize_out <= MemSize_in;
                Branch_out <= Branch_in;
                read_data1_out <= read_data1_in;
                read_data2_out <= read_data2_in;
                imm_out <= imm_in;
                rd_out <= rd_in;
                pc_out <= pc_in;
                funct3_out <= funct3_in;
                rs1_out <= rs1_in;
                rs2_out <= rs2_in;
            else
                ALUOp_out <= (others => '0');
                ALUSrc_out <= '0';
                VecSig_out <= '0';
                RegWrite_out <= '0';
                MemRead_out <= '0';
                MemWrite_out <= '0';
                MemToReg_out <= '0';
                MemSize_out <= (others => '0');
                Branch_out <= '0';
                read_data1_out <= (others => '0');
                read_data2_out <= (others => '0');
                imm_out <= (others => '0');
                rd_out <= (others => '0');
                pc_out <= (others => '0');
                funct3_out <= (others => '0');
                rs1_out <= (others => '0');
                rs2_out <= (others => '0');
            end if;
        end if;
    end process;
end architecture;