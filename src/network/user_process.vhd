library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;

entity user_process is port (
  clock : in std_logic;
  reset : in std_logic;
  -- Commands to the TCP/IP layer
  user_configure : out std_logic;
  user_write_udp_header : out std_logic;
  user_transmit_frame : out std_logic;
  user_acknowledge : in std_logic;
  user_write_udp_data : out std_logic;
  -- Data from user side
  user_udp_destination_ip : out std_logic_vector( 31 downto 0 );
  user_udp_source_port : out std_logic_vector( 15 downto 0 );
  user_udp_destination_port : out std_logic_vector( 15 downto 0 );
  user_udp_data_length : out unsigned( 15 downto 0 );
  user_udp_data : out std_logic_vector( 31 downto 0 );
  -- Interface signals
  pulse_btnu : in std_logic
);
end user_process;

architecture behavioral of user_process is

  -- Some useful constant
  constant TURTLE_IP : std_logic_vector( 31 downto 0 ) := x"0ac42415"; -- 10.196.36.21
  constant CRIMSON_IP : std_logic_vector( 31 downto 0 ) := x"c0a80002"; -- 192.168.0.2
  constant MIZAR_IP : std_logic_vector( 31 downto 0 ) := x"82c0a528"; -- 130.192.165.40
  constant NAUSICAA_IP : std_logic_vector( 31 downto 0 ) := x"c0a89f7f"; -- 192.168.159.127
  constant BRENTA_IP : std_logic_vector( 31 downto 0 ) := x"c1cdc204"; -- 193.205.194.4
  constant ROSE_IP : std_logic_vector( 31 downto 0 ) := x"0ac425e5"; -- 10.196.37.229
  constant DAENERYS_IP : std_logic_vector( 31 downto 0 ) := x"0ac425F1"; -- 10.196.37.241
  constant PORT_1234 : std_logic_vector( 15 downto 0 ) := x"04d2";

  constant message_size_words : integer := 7;
  constant message_size_bytes : integer := 28;
  type message_type is array( 0 to message_size_words - 1 ) of std_logic_vector( 31 downto 0 );
  constant message_packet : message_type := (
    x"47524545", -- GREE
    x"54494e47", -- TING
    x"53205052", -- S PR
    x"4f464553", -- OFES
    x"534f5220", -- SOR 
    x"46414c4b", -- FALK
    x"454e2e0a"  -- EN.
  );

  -- Packet data payload counter
  constant t_payload_counter_size : integer := 9;
  signal t_payload_counter_count, t_payload_counter_modulo : unsigned( t_payload_counter_size - 1 downto 0 );
  signal t_payload_counter_init, t_payload_counter_enable, t_payload_counter_tc : std_logic;

  type state_type is ( ready, udp_header, udp_data );
  signal state : state_type;

begin

  process ( clock, reset ) begin
    if reset = '0' then
      state <= ready;
    elsif rising_edge( clock ) then
      
      case state is
        
        when ready =>
          if pulse_btnu = '1' then
            state <= udp_header;
          end if;

        when udp_header =>
          if user_acknowledge = '1' then
            state <= udp_data;
          end if;

        when udp_data =>
          if t_payload_counter_tc = '1' then
            state <= ready;
          end if;

      end case;
    end if;
  end process;

  process ( state, t_payload_counter_count ) begin
    -- Default values
    user_configure <= '0';
    user_transmit_frame <= '0';
    user_write_udp_header <= '0';
    user_udp_destination_ip <= DAENERYS_IP;
--    case SW( 15 downto 13 ) is
--      when "000" => user_udp_destination_ip <= TURTLE_IP;
--      when "001" => user_udp_destination_ip <= CRIMSON_IP;
--      when "010" => user_udp_destination_ip <= NAUSICAA_IP;
--      when "011" => user_udp_destination_ip <= ROSE_IP;
--      when "100" => user_udp_destination_ip <= BRENTA_IP;
--      when "111" => user_udp_destination_ip <= MIZAR_IP;
--      when others => user_udp_destination_ip <= TURTLE_IP;
--    end case;
    user_udp_source_port <= PORT_1234;
    user_udp_destination_port <= PORT_1234;
    user_udp_data_length <= to_unsigned( message_size_words * 4, 16 );
    -- By default, leave the counters alone
    t_payload_counter_init <= '0';
    t_payload_counter_enable <= '0';
    t_payload_counter_modulo <= to_unsigned( message_size_words * 4 - 1, t_payload_counter_size );
    -- Default output data
    user_write_udp_data <= '0';
    user_udp_data <= ( others => '0' );

    case state is

      when ready =>
        user_write_udp_header <= '0';

      when udp_header =>
        -- Set the UDP data
        user_write_udp_header <= '1';
        user_udp_destination_ip <= DAENERYS_IP;
--        case SW( 15 downto 13 ) is
--          when "000" => user_udp_destination_ip <= TURTLE_IP;
--          when "001" => user_udp_destination_ip <= CRIMSON_IP;
--          when "010" => user_udp_destination_ip <= NAUSICAA_IP;
--          when "011" => user_udp_destination_ip <= ROSE_IP;
--          when "100" => user_udp_destination_ip <= BRENTA_IP;
--          when "111" => user_udp_destination_ip <= MIZAR_IP;
--          when others => user_udp_destination_ip <= TURTLE_IP;
--        end case;
        user_udp_source_port <= PORT_1234;
        user_udp_destination_port <= PORT_1234;
        user_udp_data_length <= to_unsigned( message_size_words * 4, 16 );
        -- Initialize the counter
        t_payload_counter_init <= '1';
        t_payload_counter_modulo <= to_unsigned( message_size_words - 1, t_payload_counter_size );

      when udp_data =>
        -- Put the data out
        user_write_udp_data <= '1';
        user_udp_data <= message_packet( to_integer( t_payload_counter_count ) );
        -- Enable the counter
        t_payload_counter_enable <= '1';

    end case;

  end process;

  -- Instantiate the payload data counter for the transmit process
  t_payload_counter : entity work.scaled_counter( behavioral ) generic map (
    size => t_payload_counter_size
  ) port map (
    clock => clock,
    reset => reset,
    counter_init => t_payload_counter_init,
    counter_enable => t_payload_counter_enable,
    count => t_payload_counter_count,
    modulo => t_payload_counter_modulo,
    counter_tc => t_payload_counter_tc
  );

end behavioral;
