library ieee;
use ieee.std_logic_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use ieee.numeric_std.all;

entity sSegDriver is
  port (
    clock : in std_logic;
    digit0 : in std_logic_vector( 3 downto 0 );
    digit1 : in std_logic_vector( 3 downto 0 );
    digit2 : in std_logic_vector( 3 downto 0 );
    digit3 : in std_logic_vector( 3 downto 0 );
    digit4 : in std_logic_vector( 3 downto 0 );
    digit5 : in std_logic_vector( 3 downto 0 );
    digit6 : in std_logic_vector( 3 downto 0 );
    digit7 : in std_logic_vector( 3 downto 0 );
    CA, CB, CC, CD, CE, CF, CG, DP : out std_logic;
    AN : out std_logic_vector( 7 downto 0 )
  );
end sSegDriver;

architecture behavioral of sSegDriver is

  -- We will use a 20 bit counter to derive the frequency for the displays
  signal flick_counter : unsigned( 19 downto 0 );
  -- The digit is stored here
  signal digit : std_logic_vector( 3 downto 0 );
  -- Collect the values of the cathodes here
  signal cathodes : std_logic_vector( 7 downto 0 );

begin

  -- Divide the clock
  process( clock ) begin
    if rising_edge( clock ) then
      flick_counter <= flick_counter + 1;
    end if;
  end process;

  -- Select the anode
  with flick_counter( 19 downto 17 ) select
    AN <=
      "11111110" when "000",
      "11111101" when "001",
      "11111011" when "010",
      "11110111" when "011",
      "11101111" when "100",
      "11011111" when "101",
      "10111111" when "110",
      "01111111" when others;

  -- Select the digit
  with flick_counter( 19 downto 17 ) select
    digit <=
      digit0 when "000",
      digit1 when "001",
      digit2 when "010",
      digit3 when "011",
      digit4 when "100",
      digit5 when "101",
      digit6 when "110",
      digit7 when others;

  -- Decode the digit
  with digit select
    cathodes <=
      -- DP, CG, CF, CE, CD, CC, CB, CA
      "11000000" when "0000",
      "11111001" when "0001",
      "10100100" when "0010",
      "10110000" when "0011",
      "10011001" when "0100",
      "10010010" when "0101",
      "10000010" when "0110",
      "11111000" when "0111",
      "10000000" when "1000",
      "10010000" when "1001",
      "10001000" when "1010",
      "10000011" when "1011",
      "11000110" when "1100",
      "10100001" when "1101",
      "10000110" when "1110",
      "10001110" when others;

  DP <= cathodes( 7 );
  CG <= cathodes( 6 );
  CF <= cathodes( 5 );
  CE <= cathodes( 4 );
  CD <= cathodes( 3 );
  CC <= cathodes( 2 );
  CB <= cathodes( 1 );
  CA <= cathodes( 0 );

end behavioral;
