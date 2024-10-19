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
        -- ALUOp = 1001 -> SLTU
    );
end control_unit;

architecture behavior of control_unit is
    -- Define opcode types for better readability
    constant R_TYPE    : std_logic_vector(6 downto 0) := "0110011";  -- R-type
    constant I_TYPE    : std_logic_vector(6 downto 0) := "0010011";  -- I-type with immediate (ADDI, etc.)
    constant LOAD_TYPE : std_logic_vector(6 downto 0) := "0000011";  -- I-type (LW)
    constant STORE_TYPE: std_logic_vector(6 downto 0) := "0100011";  -- S-type (SW)
    constant BRANCH_TYPE: std_logic_vector(6 downto 0) := "1100011"; -- B-type (BEQ)
    constant JALR_TYPE : std_logic_vector(6 downto 0) := "1100111";  -- I-type (JALR)
    constant JAL_TYPE  : std_logic_vector(6 downto 0) := "1101111";  -- J-type (JAL)
    constant LUI_TYPE  : std_logic_vector(6 downto 0) := "0110111";  -- U-type (LUI)
    constant AUIPC_TYPE: std_logic_vector(6 downto 0) := "0010111";  -- U-type (AUIPC)

    
begin
    process(opcode, funct3, funct7, ctrl_zero) is
    begin
        if ctrl_zero = '1' then
            RegWrite <= '0';  -- Enable writing to register file
            ALUSrc <= '0';    -- ALU source comes from register
            MemToReg <= '0';  -- Write ALU result to register
            MemRead <= '0';   -- No memory read
            MemWrite <= '0';  -- No memory write
            MemSize <= "00";  -- Doubleword
            Branch <= '0';    -- No branch
        else
            case opcode is
            -- R-type instructions (ADD, SUB, AND, OR, SLL, SRL, SLT, SLTU)
            when R_TYPE =>
                RegWrite <= '1';  -- Enable writing to register file
                ALUSrc <= '0';    -- ALU source comes from register
                MemToReg <= '0';  -- Write ALU result to register
                MemRead <= '0';   -- No memory read
                MemWrite <= '0';  -- No memory write
                MemSize <= "11";  -- Doubleword
                Branch <= '0';    -- No branch

                -- Determine the specific ALU operation based on funct3 and funct7
                case funct7 is
                    when "0000000" =>
                        case funct3 is
                            when "000" =>
                                ALUOp <= "0000";  -- ADD
                            when "001" =>
                                ALUOp <= "0101";  -- SLL
                            when "010" =>
                                ALUOp <= "1000"; -- SLT
                            when "011" =>
                                ALUOp <= "1001"; --SLTU
                            when "100" =>
                                ALUOp <= "0100"; -- XOR
                            when "101" =>
                                ALUOp <= "0110"; -- SRL
                            when "110" =>
                                ALUOp <= "0011"; -- OR
                            when "111" =>
                                ALUOp <= "0010"; -- AND
                            when others =>
                                ALUOp <= "0000"; -- Default to ADD
                        end case;

                    when "0100000" =>
                        case funct3 is
                            when "000" =>
                                ALUOp <= "0001";  -- SUB
                            when "101" =>
                                ALUOp <= "0111";  -- SRA
                            when others =>
                                ALUOp <= "0001";  -- Default to SUB
                        end case;

                    when others =>
                        ALUOp <= "0000";  -- Default to ADD
                end case;

            -- I-type instructions (ADDI, LW)
            when I_TYPE =>
                RegWrite <= '1';  -- Enable writing to register file
                ALUSrc <= '1';    -- ALU source is immediate
                MemToReg <= '0';  -- Write ALU result to register
                MemRead <= '0';   -- No memory read
                MemWrite <= '0';  -- No memory write
                Branch <= '0';    -- No branch

                --determine the specific ALU operation based on funct3
                case funct3 is
                    when "000" =>
                        ALUOp <= "0000"; --ADDI
                    when "001" =>
                        ALUOp <= "0101"; --SLLI
                    when "010" =>
                        ALUOp <= "1000"; --SLTI
                    when "011" =>
                        ALUOp <= "1001"; --SLTIU
                    when "100" =>
                        ALUOp <= "0100"; --XORI
                    when "101" =>
                        ALUOp <= "0110"; --SRLI
                    when "110" =>
                        ALUOp <= "0011"; --ORI
                    when "111" =>
                        ALUOp <= "0010"; --ANDI
                    when others =>
                        ALUOp <= "0000"; -- Default to ADDI
                end case;

            when LOAD_TYPE =>  -- Load Word (LW)
                RegWrite <= '1';  -- Write to register file
                MemRead <= '1';   -- Enable memory read
                MemWrite <= '0';  -- No memory write
                MemToReg <= '1';  -- Write memory data to register
                ALUSrc <= '1';    -- ALU source is immediate (memory address)
                Branch <= '0';    -- No branch
                ALUOp <= "0000"; --ADD
                case funct3 is 
                    when "000" =>
                        MemSize <= "00";  -- Byte (lb)
                    when "001" =>
                        MemSize <= "01";  -- Halfword (lh)
                    when "010" =>
                        MemSize <= "10";  -- Word (lw)
                    when others =>
                        MemSize <= "11";  -- Doubleword (ld)
                end case;

            -- S-type instructions (SW)
            when STORE_TYPE =>
                RegWrite <= '0';  -- No register file write
                MemRead <= '0';   -- No memory read
                MemWrite <= '1';  -- Enable memory write
                MemToReg <= '0';
                ALUSrc <= '1';    -- ALU source is immediate (memory address)
                Branch <= '0';    -- No branch
                ALUOp <= "0000"; --ADD
                case funct3 is
                    when "000" =>
                        MemSize <= "00";  -- Byte (sb)
                    when "001" =>
                        MemSize <= "01";  -- Halfword (sh)
                    when "010" =>
                        MemSize <= "10";  -- Word (sw)
                    when others =>
                        MemSize <= "11";  -- Doubleword (sd)
                end case;
                
            -- B-type instructions (BEQ)
            when BRANCH_TYPE =>
                RegWrite <= '0';  -- No register file write
                MemRead <= '0';   -- No memory read
                MemWrite <= '0';  -- No memory write
                MemSize <= "11";  -- Doubleword
                MemToReg <= '0';
                Branch <= '1';    -- Enable branching
                ALUSrc <= '0';    -- ALU source is register
                ALUOp <= "0000"; --ADD
            when JALR_TYPE =>
                RegWrite <= '1';  -- Write to register file
                MemRead <= '0';   -- No memory read
                MemWrite <= '0';  -- No memory write
                MemToReg <= '0';  -- Write ALU result to register
                MemSize <= "11";  -- Doubleword
                ALUSrc <= '1';    -- ALU source is immediate
                Branch <= '0';    -- No branch
                ALUOp <= "0000"; --ADD
            when JAL_TYPE =>
                RegWrite <= '1';  -- Write to register file
                MemRead <= '0';   -- No memory read
                MemWrite <= '0';  -- No memory write
                MemSize <= "11";  -- Doubleword
                MemToReg <= '0';  -- Write ALU result to register
                ALUSrc <= '1';    -- ALU source is immediate
                Branch <= '0';    -- No branch
                ALUOp <= "0000"; --Default
            when LUI_TYPE =>
                RegWrite <= '1';  -- Write to register file
                MemRead <= '0';   -- No memory read
                MemWrite <= '0';  -- No memory write
                MemSize <= "11";  -- Doubleword
                MemToReg <= '0';  -- Write ALU result to register
                ALUSrc <= '1';    -- ALU source is immediate
                Branch <= '0';    -- No branch
                ALUOp <= "0000"; --Default
            when AUIPC_TYPE =>
                RegWrite <= '1';  -- Write to register file
                MemRead <= '0';   -- No memory read
                MemWrite <= '0';  -- No memory write
                MemSize <= "11";  -- Doubleword
                MemToReg <= '0';  -- Write ALU result to register
                ALUSrc <= '1';    -- ALU source is immediate
                Branch <= '0';    -- No branch
                ALUOp <= "0000"; --Default
            when others =>
                -- Default values for unrecognized opcodes
                RegWrite <= '0';
                MemRead <= '0';
                MemWrite <= '0';
                MemSize <= "11";  -- Doubleword
                MemToReg <= '0';
                ALUSrc <= '0';
                Branch <= '0';
                ALUOp <= "0000";
            end case;
        end if;
    end process;
end architecture;
