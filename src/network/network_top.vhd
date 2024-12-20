library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;

entity network_top is port (
  sys_clock : in std_logic;
  reset : in std_logic;
  -- ethernet side connections
  ETH_CRSDV : in std_logic;
  ETH_RXERR : in std_logic;
  ETH_RXD : in std_logic_vector( 1 downto 0 );
  ETH_REFCLK : out std_logic;
  ETH_TXEN : out std_logic;
  ETH_TXD : out std_logic_vector( 1 downto 0 );
  -- to display
  LED : out std_logic_vector( 15 downto 0 );
  -- to control display
  SW : in std_logic_vector( 15 downto 0 );
  -- to seven segment displays
  CA, CB, CC, CD, CE, CF, CG, DP : out std_logic;
  AN : out std_logic_vector( 7 downto 0 );
  -- to start transmission, ARP message
  BTNC : in std_logic;
  -- to start transmission, UDP message
  BTND : in std_logic;
  -- to restart reception
  BTNU : in std_logic
);
end network_top;

architecture behavioral of network_top is

  --
  -- Component declarations
  -------------------------
  
  component rmii_clock_generator port (
    -- Clock in ports
    system_clock : in std_logic;
    -- Clock out ports
    eth_clock : out std_logic
  );
  end component;
  ATTRIBUTE SYN_BLACK_BOX : BOOLEAN;
  ATTRIBUTE SYN_BLACK_BOX OF rmii_clock_generator : COMPONENT IS TRUE;
  ATTRIBUTE BLACK_BOX_PAD_PIN : STRING;
  ATTRIBUTE BLACK_BOX_PAD_PIN OF rmii_clock_generator : COMPONENT IS "system_clock,eth_clock";
  
  COMPONENT receive_buffer PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    clkb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
  END COMPONENT;

  COMPONENT send_buffer PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    clkb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
  );
  END COMPONENT;

  --
  -- Signal declarations
  ----------------------
  
  -- Clock for the ethernet PHY interface
  signal eth_clock : std_logic;

  -- Receive buffer interface signals
  signal rec_we : std_logic_vector( 0 downto 0 );
  signal rec_addr : std_logic_vector( 12 downto 0 );
  signal rec_data : std_logic_vector( 1 downto 0 );
  signal rec_datab : std_logic_vector( 31 downto 0 );  
  signal rec_datab_scramble : std_logic_vector( 31 downto 0 );  
  signal rec_addrb : std_logic_vector( 8 downto 0 );  
  -- Send buffer interface signals
  signal snd_we : std_logic_vector( 0 downto 0 );
  signal snd_addr : std_logic_vector( 8 downto 0 );
  signal snd_data : std_logic_vector( 31 downto 0 );
  signal mem_we : std_logic_vector( 0 downto 0 );
  signal mem_addr : std_logic_vector( 8 downto 0 );
  signal mem_data : std_logic_vector( 31 downto 0 );
  signal trmt_addr : std_logic_vector( 12 downto 0 );
  signal trmt_data : std_logic_vector( 1 downto 0 );
  -- Data to be written in send buffer from high level protocol
--  signal user_data : std_logic_vector( 31 downto 0 );

  -- Debounced signals
  signal pulse_btnc : std_logic;
  signal pulse_btnu : std_logic;
  signal pulse_btnd : std_logic;

  -- The digits for the seven segment display go here
  signal digit0, digit1, digit2, digit3, digit4, digit5, digit6, digit7 : std_logic_vector( 3 downto 0 );
  signal IP_address : std_logic_vector( 31 downto 0 );

  -- Signals for receiving thread
  signal packet_received : std_logic;
  signal received_acknowledge : std_logic;

  -- Signals between TCP/IP layer and sending process
  signal send_frame : std_logic;
  signal frame_acknowledge : std_logic;
  signal number_of_dibits : unsigned( 12 downto 0 );
  signal number_of_dibits_offset : unsigned( 12 downto 0 );
--  -- Destination MAC address
--  signal destination_mac : std_logic_vector( 47 downto 0 );
--  -- Source MAC address
--  signal source_mac : std_logic_vector( 47 downto 0 );
--  -- Destination IP address
--  signal destination_ip : std_logic_vector( 31 downto 0 );
--  -- Source IP address
--  signal source_ip : std_logic_vector( 31 downto 0 );
--  -- Length of the data (data only, header length to be computed when
--  -- necessary)
--  signal packet_length : unsigned( 15 downto 0 );
--  -- Destination port
--  signal destination_port : std_logic_vector( 15 downto 0 );
--  -- Source port
--  signal source_port : std_logic_vector( 15 downto 0 );

  -- Signals between user process and TCP/IP layer
  signal user_configure : std_logic;
  signal user_write_udp_header : std_logic;
  signal user_transmit_frame : std_logic;
  signal user_acknowledge : std_logic;
  signal user_write_udp_data : std_logic;
  signal user_udp_destination_ip : std_logic_vector( 31 downto 0 );
  signal user_udp_source_port : std_logic_vector( 15 downto 0 );
  signal user_udp_destination_port : std_logic_vector( 15 downto 0 );
  signal user_udp_data_length : unsigned( 15 downto 0 );
  signal user_udp_data : std_logic_vector( 31 downto 0 );
 
begin

  --
  -- Component instantiation
  --
  rmii_clock : rmii_clock_generator port map ( 
    -- Clock in ports
    system_clock => sys_clock,
    -- Clock out ports  
    eth_clock => eth_clock              
  );

  -- Propagate the clock to the PHY ethernet module
  ETH_REFCLK <= eth_clock;
  
  REC_buffer : receive_buffer port map (
    clka => eth_clock,
    wea => rec_we,
    addra => rec_addr,
    dina => rec_data,
    clkb => sys_clock,
    addrb => rec_addrb,
    doutb => rec_datab
  );
  digit6 <= IP_address( 3 downto 0 );
  digit7 <= IP_address( 7 downto 4 );
  digit4 <= IP_address( 11 downto 8 );
  digit5 <= IP_address( 15 downto 12 );
  digit2 <= IP_address( 19 downto 16 );
  digit3 <= IP_address( 23 downto 20 );
  digit0 <= IP_address( 27 downto 24 );
  digit1 <= IP_address( 31 downto 28 );
  -- Descramble the data from the receiver memory
  rec_datab_scramble <= rec_datab( 7 downto 0 ) & rec_datab( 15 downto 8 ) & rec_datab( 23 downto 16 ) & rec_datab( 31 downto 24 );

  SND_buffer : send_buffer port map (
    clka => sys_clock,
    wea => snd_we,
    addra => snd_addr,
    dina => snd_data,
    clkb => eth_clock,
    addrb => trmt_addr,
    doutb => trmt_data
  );

  -- Instantiate the dibit receiver
  DB_rec : entity work.dibit_receiver( behavioral ) port map (
    clock50 => eth_clock,
    reset => reset,
    acknowledge => received_acknowledge,
    packet_ready => packet_received,
    ETH_CRSDV => ETH_CRSDV,
    ETH_RXERR => ETH_RXERR,
    ETH_RXD => ETH_RXD,
    write_enable => rec_we,
    write_address => rec_addr,
    write_data => rec_data
  );

  -- Instantiate the dibit sender
  DB_send : entity work.dibit_sender( behavioral ) port map (
    clock50 => eth_clock,
    reset => reset,
    send_frame => send_frame,
    number_of_dibits => number_of_dibits_offset,
    frame_acknowledge => frame_acknowledge,
    ETH_TXEN => ETH_TXEN,
    ETH_TXD => ETH_TXD,
    read_address => trmt_addr,
    read_data => trmt_data
  );

  -- Instantiate the IP layer
  -- The number of dibits is offset by 8, since we leave the first 16 bits empty
  -- to better align the data, but we need to put the value - 1 to correctly
  -- stop the sending
  number_of_dibits_offset <= number_of_dibits + 7;
  snd_addr <= mem_addr;
  snd_we <= mem_we;
  -- Scramble the data so that the reader can read it
  snd_data( 31 downto 24 ) <= mem_data(  7 downto  0 );
  snd_data( 23 downto 16 ) <= mem_data( 15 downto  8 );
  snd_data( 15 downto  8 ) <= mem_data( 23 downto 16 );
  snd_data(  7 downto  0 ) <= mem_data( 31 downto 24 );

  IP_layer : entity work.tcpip_layer( behavioral ) port map (
    clock => sys_clock,
    reset => reset,
    user_configure => pulse_btnc,
    user_write_udp_header => user_write_udp_header,
    user_transmit_frame => user_transmit_frame,
    user_acknowledge => user_acknowledge,
    user_write_udp_data => user_write_udp_data,
    user_udp_destination_ip => user_udp_destination_ip,
    user_udp_source_port => user_udp_source_port,
    user_udp_destination_port => user_udp_destination_port,
    user_udp_data_length => user_udp_data_length,
    user_udp_data => user_udp_data,
    packet_received => packet_received,
    received_acknowledge => received_acknowledge,
    rec_addrb => rec_addrb,
    rec_datab => rec_datab_scramble,
    mem_addr => mem_addr,
    mem_data => mem_data,
    mem_we => mem_we,
    send_frame => send_frame,
    number_of_dibits => number_of_dibits,
    frame_acknowledge => frame_acknowledge,
    LED => LED,
    SW => SW,
    IP_address => IP_address
  );

  -- Instantiate the user process
  USER : entity work.user_process( behavioral ) port map (
    clock => sys_clock,
    reset => reset,
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

  -- Instantiate the driver of the seven segment display
  -- We put digit1-digit0 on the left (i.e., at digit7-digit6), and so on
  SSDriver : entity work.sSegDriver( behavioral ) port map (
    -- clock is at 100 MHz
    clock => sys_clock,
    digit0 => digit6,
    digit1 => digit7,
    digit2 => digit4,
    digit3 => digit5,
    digit4 => digit2,
    digit5 => digit3,
    digit6 => digit0,
    digit7 => digit1,
    CA => CA,
    CB => CB,
    CC => CC,
    CD => CD,
    CE => CE,
    CF => CF,
    CG => CG,
    DP => DP,
    AN => AN
  );

  -- Just turn off the LEDs, since we aren't using them
  -- LED <= ( others => '0' );

  -- Instantiate the debouncer for the central button
  btnc_debouncer : entity work.debouncer( behavioral ) generic map (
    counter_size => 12
  ) port map (
    clock => sys_clock,
    reset => reset,
    bouncy => BTNC,
    pulse => pulse_btnc
  );
  -- Instantiate the debouncer for the up button
  btnu_debouncer : entity work.debouncer( behavioral ) generic map (
    counter_size => 12
  ) port map (
    clock => sys_clock,
    reset => reset,
    bouncy => BTNU,
    pulse => pulse_btnu
  );
  -- Instantiate the debouncer for the down button
  btnd_debouncer : entity work.debouncer( behavioral ) port map (
    clock => sys_clock,
    reset => reset,
    bouncy => BTND,
    pulse => pulse_btnd
  );

end behavioral;

--  -- Signals for packet
--  constant packet_size : integer := 15;
--  --  To go up instead of down!
--  type packet_type is array( 0 to packet_size - 1 ) of std_logic_vector( 31 downto 0 );
--  constant arp_request_packet : packet_type := (
--    "11111111111111111111111111111111", -- Dest MAC address: broadcast
--    "11111111111111110000000000010000", -- Source MAC address: 0x00-10-20-00-00-01
--    "00100000000000000000000000000001",
--    -- Ethernet type: 0x0806, ARP
--    -- Hardware type: 0x0001, Ethernet
--    "00001000000001100000000000000001",
--    -- Protocol type: 0x0800, IPv4 
--    -- HW Address length, 0x06
--    -- Protocol address length, 0x04
--    "00001000000000000000011000000100",
--    -- Opcode: 0x0001, request
--    "00000000000000010000000000010000", -- Source MAC address: 0x00-10-20-00-00-01
--    "00100000000000000000000000000001",
--    "11000000101010000000000000000111", -- Source IP address: 0xC0 A8 00 07 (192.168.0.7)
--    "00000000000000000000000000000000", -- Dest MAC address: 0x00-00-00-00-00-00
--    "00000000000000001100000010101000", -- Dest IP address: 0xC0 A8 00 01 (192.168.0.1)
--    "00000000000000010000000000000000", -- + 18 bytes of padding (2 here)
--    "00000000000000000000000000000000",
--    "00000000000000000000000000000000",
--    "00000000000000000000000000000000",
--    "00000000000000000000000000000000"
--  );
--    -- Destination MAC address: 0x00095B53FA4C
--    -- "00000000000010010101101101010011",
--    -- "1111101001001100
--  constant udp_hello_packet : packet_type := (
--    -- Destination MAC address: 0x000874E1166E
--    "00000000000010000111010011100001",
--    "00010110011011100000000000010000", -- Source MAC address: 0x00-10-20-00-00-01
--    "00100000000000000000000000000001",
--    -- 0x08 (Ethernet type: 0x0800, IPv4), 0x45 (IPv4, Len = 5), 0x00 (DSCP+ECN)
--    "00001000000000000100010100000000",
--    -- 0x00 (Length, high byte) -- 0x2E (Length, low byte) -- 0x00 (Identification, high byte) -- 0x00 (Identification, low byte)
--    "00000000001011100000000000000000",
--    -- 0x00 (Offset) -- 0x00 (Offset) -- 0x40 (TTL) -- 0x11 (Protocol = UDP)
--    "00000000000000000100000000010001",
--    -- IP header checksum (0xF965) -- Source IP address: 0xC0 A8 00 07 (192.168.0.7)
--    "11111001011001011100000010101000",
--    "00000000000001111100000010101000",
--    -- Destination IP address: 0xC0 A8 00 07 (192.168.0.2) -- 0x04 (Source port: 1234 = 0x04D2) -- 0xD2
--    "00000000000000100000010011010010",
--    -- 0x04 (Destination port: 1234 = 0x04D2) -- 0xD2 -- 0x00 (Length, UDP header + data = 26 = 0x001A)
--    "00000100110100100000000000011010",
--    -- 0x0000 (Checksum, leave 0)
--    -- 0x48 65 6C 6C 6F 2C 20 57 6F 72 6C 64 21 2E 2E 2E 2E 0A (Hello world!...)
--    "00000000000000000100100001100101",
--    "01101100011011000110111100101100",
--    "00100000010101110110111101110010",
--    "01101100011001000010000100101110",
--    "00101110001011100010111000001010"
--  );
--
--
--  type state_type is ( wr_start, wr_arp_request, wr_idle, wr_request );
--  signal state : state_type;
--  -- ARP request packet counter
--  signal arp_request_counter : unsigned( 8 downto 0 );
--  signal arp_request_counter_init, arp_request_counter_enable, arp_request_counter_tc : std_logic;
--
--  -- Process to write the memory
--  process ( sys_clock, reset ) begin
--    if reset = '0' then
--      state <= wr_start;
--    elsif rising_edge( sys_clock ) then
--      case state is
--        when wr_start => state <= wr_arp_request;
--        -- Check if we need to continue sending
--        when wr_arp_request => if arp_request_counter_tc = '1' then state <= wr_idle; end if;
--        when wr_idle => if pulse_btnc = '1' then state <= wr_request; end if;
--        when wr_request => if frame_acknowledge = '1' then state <= wr_idle; end if;
--      end case;
--    end if;
--  end process;
--
--  process ( state, arp_request_counter, arp_request_counter_tc ) begin
--    -- Default counter signals
--    arp_request_counter_init <= '0';
--    arp_request_counter_enable <= '0';
--    -- Default memory signals
--    snd_we <= "0";
--    snd_addr <= std_logic_vector( arp_request_counter );
--    -- snd_data <= arp_request_packet( to_integer( arp_request_counter ) );
--    -- If I want to switch the order of the 32 bits use the following
--    -- snd_data( 31 downto 24 ) <= arp_request_packet( to_integer( arp_request_counter ) )(  7 downto  0 );
--    -- snd_data( 23 downto 16 ) <= arp_request_packet( to_integer( arp_request_counter ) )( 15 downto  8 );
--    -- snd_data( 15 downto  8 ) <= arp_request_packet( to_integer( arp_request_counter ) )( 23 downto 16 );
--    -- snd_data(  7 downto  0 ) <= arp_request_packet( to_integer( arp_request_counter ) )( 31 downto 24 );
--    snd_data( 31 downto 24 ) <= udp_hello_packet( to_integer( arp_request_counter ) )(  7 downto  0 );
--    snd_data( 23 downto 16 ) <= udp_hello_packet( to_integer( arp_request_counter ) )( 15 downto  8 );
--    snd_data( 15 downto  8 ) <= udp_hello_packet( to_integer( arp_request_counter ) )( 23 downto 16 );
--    snd_data(  7 downto  0 ) <= udp_hello_packet( to_integer( arp_request_counter ) )( 31 downto 24 );
--    -- Default handshake signals
--    send_frame <= '0';
--    case state is
--      when wr_start => arp_request_counter_init <= '1';
--      when wr_arp_request =>
--        snd_we <= "1";
--        if arp_request_counter_tc = '0' then
--          arp_request_counter_enable <= '1';
--        else
--          arp_request_counter_enable <= '0';
--        end if;
--      when wr_idle => snd_we <= "0";
--      when wr_request => send_frame <= '1';
--    end case;
--  end process;
--
--  -- Instantiate the arp packet counter
--  ARP_cntr : entity work.modulo_counter( behavioral ) generic map (
--    size => 9,
--    modulo => 14
--  ) port map (
--    clock => sys_clock,
--    reset => reset,
--    counter_init => arp_request_counter_init,
--    counter_enable => arp_request_counter_enable,
--    count => arp_request_counter,
--    counter_tc => arp_request_counter_tc
--  );
