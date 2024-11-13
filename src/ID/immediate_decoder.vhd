library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity immediate_decoder is
    port (
        instruction : in std_logic_vector(31 downto 0);
        immediate : out std_logic_vector(31 downto 0)
    );
end immediate_decoder;


architecture behavior of immediate_decoder is

    -- Function for U-type immediate
    function U_type_imm(instr : std_logic_vector(31 downto 0)) return std_logic_vector is
    begin
        return instr(31 downto 12) & (11 downto 0 => '0');
    end function;

    -- Function for J-type immediate
    function J_type_imm(instr : std_logic_vector(31 downto 0)) return std_logic_vector is
    begin
        return (31 downto 20 => instr(31)) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0';
    end function;

    -- Function for I-type immediate
    function I_type_imm(instr : std_logic_vector(31 downto 0)) return std_logic_vector is
    begin
        return (31 downto 11 => instr(31)) & instr(30 downto 20);
    end function;

    -- Function for B-type immediate
    function B_type_imm(instr : std_logic_vector(31 downto 0)) return std_logic_vector is
    begin
        return (31 downto 12 => instr(31)) & instr(7) & instr(30 downto 25) &
               instr(11 downto 8) & '0';
    end function;

    -- Function for S-type immediate
    function S_type_imm(instr : std_logic_vector(31 downto 0)) return std_logic_vector is
    begin
        return (31 downto 11 => instr(31)) & instr(30 downto 25) & instr(11 downto 7);
    end function;

begin

    -- Concurrent assignment replacing the process
    immediate <= U_type_imm(instruction) when instruction(6 downto 2) = "01101" or instruction(6 downto 2) = "00101" else -- U-type
                 J_type_imm(instruction) when instruction(6 downto 2) = "11011" else -- J-type
                 I_type_imm(instruction) when instruction(6 downto 2) = "11001" or instruction(6 downto 2) = "00000" or
                                               instruction(6 downto 2) = "00100" or instruction(6 downto 2) = "11100" else -- I-type
                 B_type_imm(instruction) when instruction(6 downto 2) = "11000" else -- B-type
                 S_type_imm(instruction) when instruction(6 downto 2) = "01000" else -- S-type
                 (others => '0'); -- Default case

end architecture;