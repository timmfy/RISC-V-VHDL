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
            read_data1 : in std_logic_vector(63 downto 0);
            read_data2 : in std_logic_vector(63 downto 0);
            imm : out std_logic_vector(63 downto 0);
            func3 : out std_logic_vector(2 downto 0);
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
    signal func3 : std_logic_vector(2 downto 0);
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
    uut: ID_core port map (
        pc => pc,
        instruction => instruction,
        reg_write => reg_write,
        write_reg => write_reg,
        write_data => write_data,
        read_data1 => read_data1,
        read_data2 => read_data2,
        imm => imm,
        func3 => func3,
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
        -- Initialize inputs
        reg_write <= '1';
        write_reg <= "00001";
        write_data <= x"0000000000000001";
        read_data1 <= x"0000000000000002";
        read_data2 <= x"0000000000000003";
        instruction <= x"00000000"; -- Example instruction
        pc <= x"00000000"; -- Example PC

        -- Wait for a clock cycle
        wait for 10 ns;

        -- Add more test cases as needed
        -- Example: Change instruction and check outputs
        instruction <= x"00000001"; -- Change instruction
        wait for 10 ns;

        -- End simulation
        wait;
    end process;

end architecture behavior;
