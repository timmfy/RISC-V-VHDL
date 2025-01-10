library ieee;
use ieee.std_logic_1164.all;

entity CRC32_2 is
  port (
    clock, reset : in std_logic;
    crc : out std_logic_vector( 1 downto 0 );
    d : in std_logic_vector( 1 downto 0 );
    calc, init, d_valid : in std_logic
  );
end CRC32_2;

architecture behavioral of CRC32_2 is

  signal icrc_reg : std_logic_vector( 31 downto 0 );
  signal next_crc : std_logic_vector( 31 downto 0 );

begin

  process ( clock, reset ) begin

    if reset = '0' then
      icrc_reg <= ( others => '1' );
    elsif rising_edge( clock ) then
      if init = '1' then
        icrc_reg <= ( others => '1' );
      elsif calc = '1' then
        icrc_reg <= next_crc;
      elsif d_valid = '1' then
        icrc_reg <= icrc_reg( 29 downto 0 ) & "11";
      end if;
    end if;

  end process;

  next_crc( 0 ) <= icrc_reg( 30 ) xor d( 1 );
  next_crc( 1 ) <= icrc_reg( 30 ) xor d( 1 ) xor d( 0 ) xor icrc_reg( 31 );
  next_crc( 2 ) <= icrc_reg( 30 ) xor d( 1 ) xor icrc_reg( 0 ) xor d( 0 ) xor icrc_reg( 31 );
  next_crc( 3 ) <= icrc_reg( 1 ) xor d( 0 ) xor icrc_reg( 31 );
  next_crc( 4 ) <= d( 1 ) xor icrc_reg( 2 ) xor icrc_reg( 30 );
  next_crc( 5 ) <= icrc_reg( 31 ) xor d( 0 ) xor d( 1 ) xor icrc_reg( 30 ) xor icrc_reg( 3 );
  next_crc( 6 ) <= d( 0 ) xor icrc_reg( 4 ) xor icrc_reg( 31 );
  next_crc( 7 ) <= d( 1 ) xor icrc_reg( 5 ) xor icrc_reg( 30 );
  next_crc( 8 ) <= icrc_reg( 6 ) xor icrc_reg( 30 ) xor d( 1 ) xor icrc_reg( 31 ) xor d( 0 );
  next_crc( 9 ) <= d( 0 ) xor icrc_reg( 7 ) xor icrc_reg( 31 );
  next_crc( 10 ) <= d( 1 ) xor icrc_reg( 8 ) xor icrc_reg( 30 );
  next_crc( 11 ) <= icrc_reg( 30 ) xor icrc_reg( 9 ) xor icrc_reg( 31 ) xor d( 0 ) xor d( 1 );
  next_crc( 12 ) <= icrc_reg( 31 ) xor d( 0 ) xor d( 1 ) xor icrc_reg( 10 ) xor icrc_reg( 30 );
  next_crc( 13 ) <= icrc_reg( 31 ) xor d( 0 ) xor icrc_reg( 11 );
  next_crc( 14 ) <= icrc_reg( 12 );
  next_crc( 15 ) <= icrc_reg( 13 );
  next_crc( 16 ) <= d( 1 ) xor icrc_reg( 14 ) xor icrc_reg( 30 );
  next_crc( 17 ) <= icrc_reg( 15 ) xor d( 0 ) xor icrc_reg( 31 );
  next_crc( 18 ) <= icrc_reg( 16 );
  next_crc( 19 ) <= icrc_reg( 17 );
  next_crc( 20 ) <= icrc_reg( 18 );
  next_crc( 21 ) <= icrc_reg( 19 );
  next_crc( 22 ) <= d( 1 ) xor icrc_reg( 20 ) xor icrc_reg( 30 );
  next_crc( 23 ) <= d( 1 ) xor icrc_reg( 21 ) xor icrc_reg( 31 ) xor d( 0 ) xor icrc_reg( 30 );
  next_crc( 24 ) <= icrc_reg( 31 ) xor d( 0 ) xor icrc_reg( 22 );
  next_crc( 25 ) <= icrc_reg( 23 );
  next_crc( 26 ) <= icrc_reg( 24 ) xor d( 1 ) xor icrc_reg( 30 );
  next_crc( 27 ) <= icrc_reg( 25 ) xor d( 0 ) xor icrc_reg( 31 );
  next_crc( 28 ) <= icrc_reg( 26 );
  next_crc( 29 ) <= icrc_reg( 27 );
  next_crc( 30 ) <= icrc_reg( 28 );
  next_crc( 31 ) <= icrc_reg( 29 );

  crc( 0 ) <= not icrc_reg( 31 );
  crc( 1 ) <= not icrc_reg( 30 );

end behavioral;
