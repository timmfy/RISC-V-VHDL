library ieee;
use ieee.std_logic_1164.all;

entity hazard_detection_unit is
    port(
        MemToReg_ex : in std_logic;
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
    process(MemToReg_ex)
    begin
        if MemToReg_ex = '1' then
            ctrl_zero_sig <= '1';
            PCWrite_sig <= '1';
            IF_ID_Write_sig <= '1';
        else
            ctrl_zero_sig <= '0';
            PCWrite_sig <= '0';
            IF_ID_Write_sig <= '0';
        end if;
    end process;
    ctrl_zero <= ctrl_zero_sig;
    PCWrite <= PCWrite_sig;
    IF_ID_Write <= IF_ID_Write_sig;
end architecture;
