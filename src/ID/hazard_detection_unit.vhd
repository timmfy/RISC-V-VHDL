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
begin
    ctrl_zero <= '1' when (VecSig = '0' and VecSig_ex = '0' and MemToReg_ex = '1' and (rs1 = rd_ex or rs2 = rd_ex)) or (VecSig = '1' and VecSig_ex = '1' and MemToReg_ex = '1' and (rs1 = rd_ex or rs2 = rd_ex)) else '0';
    PCWrite <= '1' when (VecSig = '0' and VecSig_ex = '0' and MemToReg_ex = '1' and (rs1 = rd_ex or rs2 = rd_ex)) or (VecSig = '1' and VecSig_ex = '1' and MemToReg_ex = '1' and (rs1 = rd_ex or rs2 = rd_ex)) else '0';
    IF_ID_Write <= '1' when (VecSig = '0' and VecSig_ex = '0' and MemToReg_ex = '1' and (rs1 = rd_ex or rs2 = rd_ex)) or (VecSig = '1' and VecSig_ex = '1' and MemToReg_ex = '1' and (rs1 = rd_ex or rs2 = rd_ex)) else '0';
    --ctrl_zero <= '1' MemToReg_ex = '1' and (rs1 = rd_ex or rs2 = rd_ex) else '0';
    --PCWrite <= '1' MemToReg_ex = '1' and (rs1 = rd_ex or rs2 = rd_ex) else '0';
    --IF_ID_Write <= '1' MemToReg_ex = '1' and (rs1 = rd_ex or rs2 = rd_ex) else '0';
end architecture;
