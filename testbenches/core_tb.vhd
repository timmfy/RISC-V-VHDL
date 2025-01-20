library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;

entity core_tb is
end core_tb;

architecture behavioral of core_tb is

  signal clk : std_logic;
  signal reset : std_logic;
  -- signal ETH_CRSDV : std_logic;
  -- signal ETH_RXERR : std_logic;
  -- signal ETH_RXD : std_logic_vector( 1 downto 0 );
  -- signal ETH_REFCLK : std_logic;
  -- signal ETH_TXEN : std_logic;
  -- signal ETH_TXD : std_logic_vector( 1 downto 0 );
  -- signal LED : std_logic_vector( 15 downto 0 );
  -- signal SW : std_logic_vector( 15 downto 0 );
  -- signal CA, CB, CC, CD, CE, CF, CG, DP : std_logic;
  -- signal AN : std_logic_vector( 7 downto 0 );
  -- signal BTNC : std_logic;
  -- signal BTND : std_logic;
  -- signal BTNU : std_logic;
  --signal test_out : std_logic_vector( 15 downto 0 );
begin

  dut : entity work.core( behavior ) port map (
    clk => clk,
    reset => reset
    --test_out => test_out
  );

  process begin
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
  end process;


end behavioral;
