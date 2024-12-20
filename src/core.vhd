library ieee;
use ieee.std_logic_1164.all;

entity core is
    port (
        clk : in std_logic;
        reset : in std_logic;
        -- ethernet side connections
        ETH_CRSDV : in std_logic;
        ETH_RXERR : in std_logic;
        ETH_RXD : in std_logic_vector( 1 downto 0 );
        ETH_REFCLK : out std_logic;
        ETH_TXEN : out std_logic;
        ETH_TXD : out std_logic_vector( 1 downto 0 );
        -- to display
        LED : out std_logic_vector( 15 downto 0 );
        -- to control display
        SW : in std_logic_vector( 15 downto 0 );
        -- to seven segment displays
        CA, CB, CC, CD, CE, CF, CG, DP : out std_logic;
        AN : out std_logic_vector( 7 downto 0 );
        -- to start transmission, ARP message
        BTNC : in std_logic;
        -- to start transmission, UDP message
        BTND : in std_logic;
        -- to restart reception
        BTNU : in std_logic;

        --to debug
        test_out : out std_logic_vector(15 downto 0)
    );
end entity core;

architecture behavior of core is
    -- IF stage
    signal instruction_if : std_logic_vector(31 downto 0);
    signal pc_if : std_logic_vector(63 downto 0);
    -- ID stage
    signal instruction_id : std_logic_vector(31 downto 0);
    signal pc_id : std_logic_vector(63 downto 0);
    signal read_data1_id : std_logic_vector(63 downto 0);
    signal read_data2_id : std_logic_vector(63 downto 0);
    signal imm_id : std_logic_vector(63 downto 0);
    signal funct3_id : std_logic_vector(2 downto 0);
    signal rd_id : std_logic_vector(4 downto 0);
    signal ALUOp_id : std_logic_vector(3 downto 0);
    signal ALUSrc_id : std_logic;
    signal RegWrite_id : std_logic;
    signal MemRead_id : std_logic;
    signal MemWrite_id : std_logic;
    signal MemToReg_id : std_logic;
    signal PCWrite : std_logic;
    signal IF_ID_Write : std_logic;
    signal MemSize_id : std_logic_vector(1 downto 0);
    signal Branch_id : std_logic;
    signal rs1_id : std_logic_vector(4 downto 0);
    signal rs2_id : std_logic_vector(4 downto 0);
    -- EX stage
    signal ALUOp_ex : std_logic_vector(3 downto 0);
    signal ALUSrc_ex : std_logic;
    signal RegWrite_ex : std_logic;
    signal MemRead_ex : std_logic;
    signal MemWrite_ex : std_logic;
    signal MemToReg_ex : std_logic;
    signal MemSize_ex : std_logic_vector(1 downto 0);
    signal Branch_ex : std_logic;
    signal pc_ex : std_logic_vector(63 downto 0);
    signal read_data1_ex : std_logic_vector(63 downto 0);
    signal read_data2_in_ex : std_logic_vector(63 downto 0);
    signal read_data2_out_ex : std_logic_vector(63 downto 0);
    signal imm_ex : std_logic_vector(63 downto 0);
    signal funct3_ex : std_logic_vector(2 downto 0);
    signal rd_ex : std_logic_vector(4 downto 0);
    signal result_ex : std_logic_vector(63 downto 0);
    signal zero_ex : std_logic;
    signal next_pc_ex : std_logic_vector(63 downto 0);
    signal rs1_ex : std_logic_vector(4 downto 0);
    signal rs2_ex : std_logic_vector(4 downto 0);
    -- MEM stage
    signal MemWrite_mem : std_logic;
    signal MemRead_mem : std_logic;
    signal MemSize_mem : std_logic_vector(1 downto 0);
    signal Branch_mem : std_logic;
    signal flush_mem : std_logic;
    signal MemToReg_mem : std_logic;
    signal RegWrite_mem : std_logic;
    signal PCSrc_mem : std_logic;
    signal next_pc_mem : std_logic_vector(63 downto 0);
    signal zero_mem : std_logic;
    signal alu_result_mem : std_logic_vector(63 downto 0);
    signal read_data2_mem : std_logic_vector(63 downto 0);
    signal rd_mem : std_logic_vector(4 downto 0);
    signal data_out_mem : std_logic_vector(63 downto 0);
    -- WB stage
    signal MemToReg_wb : std_logic;
    signal RegWrite_wb : std_logic;
    signal flush_wb : std_logic;
    signal data_out_wb : std_logic_vector(63 downto 0);
    signal write_reg_wb : std_logic_vector(4 downto 0);
    signal alu_result_wb : std_logic_vector(63 downto 0);
    signal write_data_wb : std_logic_vector(63 downto 0);
    signal mem_debug : std_logic_vector(15 downto 0);
begin
    -- Forwarding data for the WB/ID stage
    write_data_wb <= data_out_wb when MemToReg_wb = '1' else alu_result_wb;
    
    -- Network module
    network_inst: entity work.network_top
    port map(
        sys_clock => clk,
        reset => reset,
        ETH_CRSDV => ETH_CRSDV,
        ETH_RXERR => ETH_RXERR,
        ETH_RXD => ETH_RXD,
        ETH_REFCLK => ETH_REFCLK,
        ETH_TXEN => ETH_TXEN,
        ETH_TXD => ETH_TXD,
        LED => LED,
        SW => SW,
        CA => CA,
        CB => CB,
        CC => CC,
        CD => CD,
        CE => CE,
        CF => CF,
        CG => CG,
        DP => DP,
        AN => AN,
        BTNC => BTNC,
        BTND => BTND,
        BTNU => BTNU
    );
    -- IF stage
    IF_stage: entity work.IF_core
    port map(
        clk => clk,
        reset => reset,
        pc_src => PCSrc_mem,
        PCWrite => PCWrite,
        branch_target => next_pc_mem,
        instruction => instruction_if,
        pc => pc_if
    );

    -- IF/ID pipeline register
    IF_ID_inst: entity work.IF_ID
     port map(
        clk => clk,
        --reset => reset,
        IF_ID_Write => IF_ID_Write,
        IF_flush => flush_mem,
        instruction_in => instruction_if,
        pc_in => pc_if,
        instruction_out => instruction_id,
        pc_out => pc_id
    );

    -- ID stage
    ID_core_inst: entity work.ID_core
     port map(
        instruction => instruction_id,
        imm => imm_id,
        funct3 => funct3_id,
        rd => rd_id,
        RegWrite => RegWrite_id,
        MemRead => MemRead_id,
        MemWrite => MemWrite_id,
        MemToReg => MemToReg_id,
        MemSize => MemSize_id,
        ALUSrc => ALUSrc_id,
        Branch => Branch_id,
        ALUOp => ALUOp_id,
        PCWrite => PCWrite,
        IF_ID_Write => IF_ID_Write,
        MemToReg_ex => MemToReg_ex,
        rd_ex => rd_ex,
        rs1 => rs1_id,
        rs2 => rs2_id
    );

    --register file
    register_file_inst: entity work.register_file
    port map(
        clk => clk,
        reg_write => RegWrite_wb,
        write_reg => write_reg_wb,
        write_data => write_data_wb,
        read_reg1 => rs1_id,
        read_reg2 => rs2_id,
        read_data1 => read_data1_id,
        read_data2 => read_data2_id,
        debug => test_out
    );

    -- ID/EX pipeline register
    ID_EX_inst: entity work.ID_EX
     port map(
        clk => clk,
        --reset => reset,
        ALUOp_in => ALUOp_id,
        ALUSrc_in => ALUSrc_id,
        RegWrite_in => RegWrite_id,
        MemRead_in => MemRead_id,
        MemWrite_in => MemWrite_id,
        MemToReg_in => MemToReg_id,
        MemSize_in => MemSize_id,
        Branch_in => Branch_id,
        ID_flush => flush_mem,
        read_data1_in => read_data1_id,
        read_data2_in => read_data2_id,
        imm_in => imm_id,
        rd_in => rd_id,
        pc_in => pc_id,
        funct3_in => funct3_id,
        rs1_in => rs1_id,
        rs2_in => rs2_id,
        ALUOp_out => ALUOp_ex,
        ALUSrc_out => ALUSrc_ex,
        RegWrite_out => RegWrite_ex,
        MemRead_out => MemRead_ex,
        MemWrite_out => MemWrite_ex,
        MemToReg_out => MemToReg_ex,
        MemSize_out => MemSize_ex,
        Branch_out => Branch_ex,
        read_data1_out => read_data1_ex,
        read_data2_out => read_data2_in_ex,
        imm_out => imm_ex,
        rd_out => rd_ex,
        pc_out => pc_ex,
        funct3_out => funct3_ex,
        rs1_out => rs1_ex,
        rs2_out => rs2_ex
    );

    -- EX stage
    EX_core_inst: entity work.EX_core
     port map(
        ALUOp => ALUOp_ex,
        ALUSrc => ALUSrc_ex,
        RegWrite_mem => RegWrite_mem,
        RegWrite_wb => RegWrite_wb,
        write_reg_wb => write_reg_wb,
        rd_mem => rd_mem,
        read_data1 => read_data1_ex,
        read_data2_in => read_data2_in_ex,
        read_data2_out => read_data2_out_ex,
        rs1 => rs1_ex,
        rs2 => rs2_ex,
        imm => imm_ex,
        pc => pc_ex,
        alu_result_mem => alu_result_mem,
        data_out_wb => write_data_wb,
        result => result_ex,
        zero => zero_ex,
        next_pc => next_pc_ex
    );

    -- EX/MEM pipeline register
    EX_MEM_inst: entity work.EX_MEM
     port map(
        clk => clk,
        --reset => reset,
        --MemWrite_in => MemWrite_ex,
        --MemRead_in => MemRead_ex,
        MemSize_in => MemSize_ex,
        Branch_in => Branch_ex,
        EX_flush => flush_mem,
        MemToReg_in => MemToReg_ex,
        RegWrite_in => RegWrite_ex,
        next_pc_in => next_pc_ex,
        zero_in => zero_ex,
        alu_result_in => result_ex,
        --read_data2_in => read_data2_out_ex,
        rd_in => rd_ex,
        --MemWrite_out => MemWrite_mem,
        --MemRead_out => MemRead_mem,
        MemSize_out => MemSize_mem,
        Branch_out => Branch_mem,
        MemToReg_out => MemToReg_mem,
        RegWrite_out => RegWrite_mem,
        next_pc_out => next_pc_mem,
        zero_out => zero_mem,
        alu_result_out => alu_result_mem,
        --read_data2_out => read_data2_mem,
        rd_out => rd_mem
    );

    -- MEM stage
    MEM_core_inst: entity work.MEM_core
     port map(
        clk => clk,
        Address_ex => result_ex(12 downto 0),
        Address_mem => alu_result_mem(2 downto 0),
        DataIn => read_data2_out_ex,
        MemRead => MemRead_ex,
        MemWrite => MemWrite_ex,
        MemSize_ex => MemSize_ex,
        MemSize_mem => MemSize_mem,
        Branch => Branch_mem,
        Zero => zero_mem,
        DataOut => data_out_mem,
        mem_debug => mem_debug,
        PCSrc => PCSrc_mem,
        Flush => flush_mem
    );

    --MEM/WB pipeline register
    MEM_WB_inst: entity work.MEM_WB
     port map(
        clk => clk,
        --reset => reset,
        MemToReg_in => MemToReg_mem,
        RegWrite_in => RegWrite_mem,
        data_out_in => data_out_mem,
        rd_in => rd_mem,
        flush_in => flush_mem,
        alu_result_in => alu_result_mem,
        MemToReg_out => MemToReg_wb,
        RegWrite_out => RegWrite_wb,
        data_out_out => data_out_wb,
        rd_out => write_reg_wb,
        flush_out => flush_wb,
        alu_result_out => alu_result_wb
    );
    --test_out <= mem_debug;
end architecture behavior;
