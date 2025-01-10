library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.ALL;

entity up_counter is
  generic (
    -- size in bit of the counter
    size : integer := 4
  );
  port (
    clock: in std_logic;
    reset : in std_logic;
    counter_init : in std_logic;
    counter_enable : in std_logic;
    count : out unsigned( size - 1 downto 0 );
    counter_tc : out std_logic
  );
end up_counter;

architecture behavioral of up_counter is

  -- Counter register
  signal counter_reg : unsigned( size - 1 downto 0 );
  
begin

  process ( clock, reset ) begin
    if reset = '0' then
      -- Reset to initial 0 value
      counter_reg <= ( others => '0' );
    elsif rising_edge( clock ) then
      if counter_init = '1' then
        counter_reg <= ( others => '0' );
      elsif counter_enable = '1' then
        counter_reg <= counter_reg + 1;
      end if;
    end if;
  end process;

  -- Compute the terminal count
  counter_tc <= '1' when counter_reg = to_unsigned( 0, size ) else '0';
  count <= counter_reg;

end behavioral;
