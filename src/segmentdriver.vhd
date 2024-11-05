library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.std_logic_unsigned.all;


entity seven_segment_driver is
    generic (
      size : integer := 20 --! size of the counter 2^20 max
    );
    Port (
      clock  : in std_logic; --! Clock
      reset  : in std_logic; --! Reset
      digit0 : in std_logic_vector( 3 downto 0 ); --! digit to the left
      digit1 : in std_logic_vector( 3 downto 0 ); --! digit number 2 from left
      digit2 : in std_logic_vector( 3 downto 0 ); --! digit number 3 from left
      digit3 : in std_logic_vector( 3 downto 0 ); --! digit number 4 from left
      digit4 : in std_logic_vector( 3 downto 0 ); --! digit number 5 from left
      digit5 : in std_logic_vector( 3 downto 0 ); --! digit number 6 from left
      digit6 : in std_logic_vector( 3 downto 0 ); --! digit number 7 from left
      digit7 : in std_logic_vector( 3 downto 0 ); --! digit number 8 from left
      CA     : out std_logic_vector(7 downto 0); --! Cathodes
      AN     : out std_logic_vector(7 downto 0 ) --! Anodes
    );
end entity seven_segment_driver;

architecture Behavioral of seven_segment_driver is

        -- We will use a counter to derive the frequency for the displays
        -- Clock is 100 MHz, we use 3 bits to address the display, so we count every
        -- size - 3 bits. To get ~100 Hz per digit, we need 20 bits, so that we divide
        -- by 2^20.
        signal flick_counter : unsigned( size - 1 downto 0 ); --! counter to switch between display
        -- The digit is temporarily stored here
        signal digit : std_logic_vector(7 downto 0 ); --! digit to be displayed
        -- Collect the values of the cathodes here
        signal cathodes : std_logic_vector( 7 downto 0 ); --! cathodes to light on the leds
      
    begin
      
        -- Divide the clock
        divide_clock :  process ( clock, reset ) begin
          if reset = '1' then
            flick_counter <= ( others => '0' );
          elsif rising_edge( clock ) then
            flick_counter <= flick_counter + 1;
          end if;
        end process;
      
        -- Select the anode
        with flick_counter( size - 1 downto size - 3) select
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
        with flick_counter( size - 1 downto size - 3) select
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
      
    CA <= cathodes;
      end behavioral;
      