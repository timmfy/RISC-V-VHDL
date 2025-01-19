library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity data_memory is
  port (
    clka  : in std_logic;
    wea   : in std_logic_vector(7 downto 0);
    rea   : in std_logic;
    addra : in std_logic_vector(9 downto 0);
    dia   : in std_logic_vector(63 downto 0);
    doa   : out std_logic_vector(63 downto 0);
    clkb  : in std_logic;
    --web   : in  std_logic_vector(7 downto 0);
    --reb   : in  std_logic;
    addrb : in std_logic_vector(9 downto 0);
    --dib   : in  std_logic_vector(63 downto 0);
    dob : out std_logic_vector(63 downto 0)
  );
end data_memory;

architecture Behavior of data_memory is
  type ram_type is array (1023 downto 0) of std_logic_vector(63 downto 0);
  signal RAM : ram_type := (
  0 => x"0000000000000000",
  1 => x"0000000000000000",
  2 => x"8877665544332211",
  3 => x"0000000077777777",
  4 => x"1111111111111111",
  5 => x"2222222222222222",
  6 => x"3333333333333333",
  7 => x"4444444444444444",
  others => (others => '0')
  );

begin
  process (clka)
  begin
    if rising_edge(clka) then
      for i in 0 to 7 loop
        if wea(i) = '1' then
          RAM(to_integer(unsigned(addra)))((i + 1) * 8 - 1 downto i * 8) <= dia((i + 1) * 8 - 1 downto i * 8);
        end if;
      end loop;
    end if;
  end process;
  doa <= RAM(to_integer(unsigned(addra)));

  process (clkb)
  begin
    if rising_edge(clkb) then
      dob <= RAM(to_integer(unsigned(addrb)));
    end if;
  end process;
end Behavior;
