library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ID_core_tb is
end entity ID_core_tb;

architecture behavior of ID_core_tb is
    -- Component declaration for the Unit Under Test (UUT)
    component ID_core
        port (
            pc : in std_logic_vector(31 downto 0);
            instruction : in std_logic_vector(31 downto 0);
            reg_write : in std_logic;
            write_reg : in std_logic_vector(4 downto 0);
            write_data : in std_logic_vector(63 downto 0);
            read_data1 : out std_logic_vector(63 downto 0);
            read_data2 : out std_logic_vector(63 downto 0);
            imm : out std_logic_vector(63 downto 0);
            funct3 : out std_logic_vector(2 downto 0);
            rd : out std_logic_vector(4 downto 0);
            RegWrite : out std_logic;
            MemRead : out std_logic;
            MemWrite : out std_logic;
            MemToReg : out std_logic;
            MemSize : out std_logic_vector(1 downto 0);
            ALUSrc : out std_logic;
            Branch : out std_logic;
            ALUOp : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Inputs
    signal pc : std_logic_vector(31 downto 0) := (others => '0');
    signal instruction : std_logic_vector(31 downto 0) := (others => '0');
    signal reg_write : std_logic := '0';
    signal write_reg : std_logic_vector(4 downto 0) := (others => '0');
    signal write_data : std_logic_vector(63 downto 0) := (others => '0');
    signal read_data1 : std_logic_vector(63 downto 0) := (others => '0');
    signal read_data2 : std_logic_vector(63 downto 0) := (others => '0');

    -- Outputs
    signal imm : std_logic_vector(63 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal rd : std_logic_vector(4 downto 0);
    signal RegWrite : std_logic;
    signal MemRead : std_logic;
    signal MemWrite : std_logic;
    signal MemToReg : std_logic;
    signal MemSize : std_logic_vector(1 downto 0);
    signal ALUSrc : std_logic;
    signal Branch : std_logic;
    signal ALUOp : std_logic_vector(3 downto 0);

begin
    -- Instantiate the Unit Under Test (UUT)
    dut: entity work.ID_core(behavior) port map (
        pc => pc,
        instruction => instruction,
        reg_write => reg_write,
        write_reg => write_reg,
        write_data => write_data,
        read_data1 => read_data1,
        read_data2 => read_data2,
        imm => imm,
        funct3 => funct3,
        rd => rd,
        RegWrite => RegWrite,
        MemRead => MemRead,
        MemWrite => MemWrite,
        MemToReg => MemToReg,
        MemSize => MemSize,
        ALUSrc => ALUSrc,
        Branch => Branch,
        ALUOp => ALUOp
    );

    -- Stimulus process
    stim_proc: process
    begin
        -- Test case 1: ADDI x1, x2, 16 (I-Type)
        pc <= x"00000000";
        instruction <= x"01010093";
        wait for 10 ns;
        -- Test case 2: SUB x3, x4, x5 (R-Type)
        instruction <= x"405201b3";
        wait for 10 ns;
        -- Test case 3: SW x6, 8(x7) (S-Type)
        instruction <= x"0063a023";
        wait for 10 ns;
        -- Test case 4: BEQ x1, x2, -4 (B-Type)
        instruction <= x"fe208ee3";
        wait for 10 ns;
        -- Test case 5: LUI x10, 0x12345 (U-Type)
        instruction <= x"12345537";
        wait for 10 ns;
        -- Test case 6: JAL x1, 2048 (J-Type)
        instruction <= x"008000ef";
        wait for 10 ns;
        --Simulate the write back
        reg_write <= '1';
        write_reg <= "00001";
        write_data <= x"0000000000000001";
        wait for 10 ns;
        -- ADDI x1, x1, 16 while reg_write is enabled
        -- Should write 2 to register 1 and add 16 to it
        -- So that the read_data1 should be 2
        instruction <= x"01008093";
        write_reg <= "00001";
        write_data <= x"0000000000000010";
        wait for 10 ns;
        wait;
    end process;

end architecture behavior;
