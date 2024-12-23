library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity user_process_tb is
end user_process_tb;

architecture behavioral of user_process_tb is

  -- Signals to connect to the UUT
  signal clock : std_logic := '0';
  signal reset : std_logic := '0';
  signal data_to_send : std_logic_vector(31 downto 0) := (others => '0');
  signal load_data : std_logic := '0';
  signal user_configure : std_logic;
  signal user_write_udp_header : std_logic;
  signal user_transmit_frame : std_logic;
  signal user_acknowledge : std_logic := '0';
  signal user_write_udp_data : std_logic;
  signal user_udp_destination_ip : std_logic_vector(31 downto 0);
  signal user_udp_source_port : std_logic_vector(15 downto 0);
  signal user_udp_destination_port : std_logic_vector(15 downto 0);
  signal user_udp_data_length : unsigned(15 downto 0);
  signal user_udp_data : std_logic_vector(31 downto 0);
  signal pulse_btnu : std_logic := '0';

  -- Clock generation
  constant clock_period : time := 10 ns;
  begin
    clock_process : process
    begin
      clock <= '1';
      wait for clock_period / 2;
      clock <= '0';
      wait for clock_period / 2;
    end process;

  -- Instantiate the Unit Under Test (UUT)
  user_process_inst: entity work.user_process
    port map (
      clock => clock,
      reset => reset,
      data_to_send => data_to_send,
      load_data => load_data,
      user_configure => user_configure,
      user_write_udp_header => user_write_udp_header,
      user_transmit_frame => user_transmit_frame,
      user_acknowledge => user_acknowledge,
      user_write_udp_data => user_write_udp_data,
      user_udp_destination_ip => user_udp_destination_ip,
      user_udp_source_port => user_udp_source_port,
      user_udp_destination_port => user_udp_destination_port,
      user_udp_data_length => user_udp_data_length,
      user_udp_data => user_udp_data,
      pulse_btnu => pulse_btnu
    );

  -- Stimulus process
  stimulus: process
  begin
    -- Initialize inputs
    reset <= '1';
    wait for clock_period * 2;
    reset <= '0';
    wait for clock_period * 2;

    -- Test case 1: Change data_to_send and pulse_btnu
    load_data <= '1';
    data_to_send <= x"DEADBEEF";
    wait for clock_period;
    data_to_send <= x"CAFEBABE";
    wait for clock_period;
    data_to_send <= x"11111111";
    wait for clock_period;
    data_to_send <= x"22222222";
    wait for clock_period;
    load_data <= '0';
    wait for clock_period * 3;
    pulse_btnu <= '1';
    wait for clock_period;
    pulse_btnu <= '0';

    -- End simulation
    wait;
  end process;

end behavioral;