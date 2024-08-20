library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is 
    port(
        clk: in std_logic;
        reset: in std_logic;
        opcode: in std_logic_vector(6 downto 0);
        branch: out std_logic;
        mem_read: out std_logic;
        mem_write: out std_logic;
        mem_to_reg: out std_logic;
        alu_op: out std_logic_vector(2 downto 0);
        alu_src: out std_logic;
        reg_write: out std_logic
    );
end entity control_unit;
--Complete the architecture