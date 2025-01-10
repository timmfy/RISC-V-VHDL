library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.ALL;

entity modulo_counter is
  generic (
    -- size in bit of the counter
    size : integer := 4;
    -- Determines when the terminal count is asserted
    modulo : integer := 15;
    -- initial counter value
    init_value : integer := 0
  );
  port (
    clock: in std_logic;
    reset : in std_logic;
    counter_init : in std_logic;
    counter_enable : in std_logic;
    count : out unsigned( size - 1 downto 0 );
    counter_tc : out std_logic
  );
end modulo_counter;

architecture behavioral of modulo_counter is

  -- Counter register
  signal counter_reg : unsigned( size - 1 downto 0 );
  
begin

  process ( clock, reset ) begin
    if reset = '0' then
      -- Reset to initial value
      counter_reg <= to_unsigned( init_value, size );
    elsif rising_edge( clock ) then
      if counter_init = '1' then
        counter_reg <= to_unsigned( init_value, size );
      elsif counter_enable = '1' then
        counter_reg <= counter_reg + 1;
      end if;
    end if;
  end process;

  -- Compute the terminal count and the output
  counter_tc <= '1' when counter_reg = to_unsigned( modulo, size ) else '0';
  count <= counter_reg;

end behavioral;
