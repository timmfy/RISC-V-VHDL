library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is 
    port(
        opcode     : in  std_logic_vector(6 downto 0);  -- The opcode from the instruction
        funct3     : in  std_logic_vector(2 downto 0);  -- For R-type and B-type instructions
        funct7     : in  std_logic_vector(6 downto 0);  -- For R-type instructions
        RegWrite   : out std_logic;                      -- Write to register file
        MemRead    : out std_logic;                      -- Read from memory
        MemWrite   : out std_logic;                      -- Write to memory
        MemToReg   : out std_logic;                      -- Memory to register
        ALUSrc     : out std_logic;                      -- ALU source (register or immediate)
        Branch     : out std_logic;                      -- Branch signal
        ALUOp      : out std_logic_vector(1 downto 0)    -- ALU operation selector
    );
end control_unit;

architecture behavior of control_unit is
    -- Define opcode types for better readability
    constant R_TYPE    : std_logic_vector(6 downto 0) := "0110011";  -- R-type
    constant I_TYPE    : std_logic_vector(6 downto 0) := "0010011";  -- I-type (ADDI, etc.)
    constant LOAD_TYPE : std_logic_vector(6 downto 0) := "0000011";  -- I-type (LW)
    constant STORE_TYPE: std_logic_vector(6 downto 0) := "0100011";  -- S-type (SW)
    constant BRANCH_TYPE: std_logic_vector(6 downto 0) := "1100011"; -- B-type (BEQ)
    
begin
    -- Process the opcode to generate control signals
    process(opcode, funct3, funct7)
    begin
        -- Default values for control signals
        RegWrite <= '0';
        MemRead <= '0';
        MemWrite <= '0';
        MemToReg <= '0';
        ALUSrc <= '0';
        Branch <= '0';
        ALUOp <= "00";  -- Default ALU operation (e.g., ADD)

        case opcode is
            -- R-type instructions (ADD, SUB, AND, OR)
            when R_TYPE =>
                RegWrite <= '1';  -- Enable writing to register file
                ALUSrc <= '0';    -- ALU source comes from register
                MemToReg <= '0';  -- Write ALU result to register
                MemRead <= '0';   -- No memory read
                MemWrite <= '0';  -- No memory write
                Branch <= '0';    -- No branch

                -- Determine the specific ALU operation based on funct3 and funct7
                case funct3 is
                    when "000" =>  -- ADD/SUB
                        if funct7 = "0000000" then
                            ALUOp <= "10";  -- ADD
                        elsif funct7 = "0100000" then
                            ALUOp <= "11";  -- SUB
                        end if;
                    when "111" =>  -- AND
                        ALUOp <= "00";  -- AND operation
                    when "110" =>  -- OR
                        ALUOp <= "01";  -- OR operation
                    when others =>
                        ALUOp <= "00";  -- Default to AND
                end case;

            -- I-type instructions (ADDI, LW)
            when I_TYPE =>
                RegWrite <= '1';  -- Enable writing to register file
                ALUSrc <= '1';    -- ALU source is immediate
                MemToReg <= '0';  -- Write ALU result to register
                MemRead <= '0';   -- No memory read
                MemWrite <= '0';  -- No memory write
                Branch <= '0';    -- No branch
                ALUOp <= "10";    -- ADD (for ADDI)

            when LOAD_TYPE =>  -- Load Word (LW)
                RegWrite <= '1';  -- Write to register file
                MemRead <= '1';   -- Enable memory read
                MemWrite <= '0';  -- No memory write
                MemToReg <= '1';  -- Write memory data to register
                ALUSrc <= '1';    -- ALU source is immediate (memory address)
                Branch <= '0';    -- No branch
                ALUOp <= "10";    -- ADD (address calculation)

            -- S-type instructions (SW)
            when STORE_TYPE =>
                RegWrite <= '0';  -- No register file write
                MemRead <= '0';   -- No memory read
                MemWrite <= '1';  -- Enable memory write
                ALUSrc <= '1';    -- ALU source is immediate (memory address)
                Branch <= '0';    -- No branch
                ALUOp <= "10";    -- ADD (address calculation)

            -- B-type instructions (BEQ)
            when BRANCH_TYPE =>
                RegWrite <= '0';  -- No register file write
                MemRead <= '0';   -- No memory read
                MemWrite <= '0';  -- No memory write
                Branch <= '1';    -- Enable branching
                ALUSrc <= '0';    -- ALU source is register
                ALUOp <= "11";    -- SUB (for BEQ)

            when others =>
                -- Default values for unrecognized opcodes
                RegWrite <= '0';
                MemRead <= '0';
                MemWrite <= '0';
                MemToReg <= '0';
                ALUSrc <= '0';
                Branch <= '0';
                ALUOp <= "00";    -- Default to ADD
        end case;
    end process;
end architecture;