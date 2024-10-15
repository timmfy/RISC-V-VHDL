library ieee;
use ieee.std_logic_1164.all;

entity hazard_detection_unit is
    port(
        MemRead_ex : in std_logic;
        opcode : in std_logic_vector(6 downto 0);
        rs1 : in std_logic_vector(4 downto 0);
        rs2 : in std_logic_vector(4 downto 0);
        rd_ex : in std_logic_vector(4 downto 0);
        ctrl_zero : out std_logic;
        PCWrite   : out std_logic;
        IF_ID_Write : out std_logic
    );
end hazard_detection_unit;

architecture behavior of hazard_detection_unit is
    signal ctrl_zero_sig : std_logic := '0';
    signal PCWrite_sig : std_logic := '0';
    signal IF_ID_Write_sig : std_logic := '0';
begin
    process(opcode)
    begin
        if MemRead_ex = '1' then
            if opcode = "0000011" then
            else
                if rd_ex = rs1 or rd_ex = rs2 then
                ctrl_zero_sig <= '1';
                PCWrite_sig <= '1';
                IF_ID_Write_sig <= '1';
                end if;
            end if;
        end if;
    end process;
    ctrl_zero <= ctrl_zero_sig;
    PCWrite <= PCWrite_sig;
    IF_ID_Write <= IF_ID_Write_sig;
end architecture;
