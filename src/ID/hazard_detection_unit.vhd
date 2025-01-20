library ieee;
use ieee.std_logic_1164.all;

entity hazard_detection_unit is
    port(
        MemToReg_ex : in std_logic;
        VecSig : in std_logic;
        VecSig_ex : in std_logic;
        rs1 : in std_logic_vector(4 downto 0);
        rs2 : in std_logic_vector(4 downto 0);
        rd_ex : in std_logic_vector(4 downto 0);
        ctrl_zero : out std_logic;
        PCWrite   : out std_logic;
        IF_ID_Write : out std_logic
    );
end hazard_detection_unit;

architecture behavior of hazard_detection_unit is
    signal load_use_hazard : std_logic;
begin
    load_use_hazard <= '1' when
        ((VecSig = '0' and VecSig_ex = '0') or (VecSig = '1' and VecSig_ex = '1')) 
        and ((rs1 = rd_ex) or (rs2 = rd_ex)) 
        and MemToReg_ex = '1'
    else '0';
    ctrl_zero <= load_use_hazard;
    PCWrite <= load_use_hazard;
    IF_ID_Write <= load_use_hazard;
end architecture;
