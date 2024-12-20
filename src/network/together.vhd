library ieee;
use ieee.std_logic_1164.all;

-- LEDs meaning
-- 3: ARP request for my IP received
-- 4: IP packet received
-- 5: DHCP packet received
-- 6: DHCP offer received
-- 7: DHCP request command set
-- 8: DHCP offer release
-- 9: packet_received cleared
-- 10: DHCP acknowledge received
-- 11: ARP request command set
-- 12: release ARP request
-- 13: release general packet

use ieee.numeric_std.all;

-- This module arbitrates requests to send packets and access to the buffer
-- memory

entity tcpip_layer is port (
  clock : in std_logic;
  reset : in std_logic;
  -- Commands: configure IP layer
  user_configure : in std_logic;
  user_write_udp_header : in std_logic;
  user_transmit_frame : in std_logic;
  user_acknowledge : out std_logic;
  user_write_udp_data : in std_logic;
  -- Data from user side
  user_udp_destination_ip : in std_logic_vector( 31 downto 0 );
  user_udp_source_port : in std_logic_vector( 15 downto 0 );
  user_udp_destination_port : in std_logic_vector( 15 downto 0 );
  user_udp_data_length : in unsigned( 15 downto 0 );
  user_udp_data : in std_logic_vector( 31 downto 0 );
  --
  -- Commands/data to/from receive thread
  ---------------------------------------
  packet_received : in std_logic;
  received_acknowledge : out std_logic;
  ---------------------------------
  -- Signals to/from receive buffer
  ---------------------------------
  rec_addrb : out std_logic_vector( 8 downto 0 );
  rec_datab : in std_logic_vector( 31 downto 0 );
  ---------------------------------
  -- Signal to/from transmit buffer
  ---------------------------------
  -- The memory address where data is written
  mem_addr : out std_logic_vector( 8 downto 0 );
  -- The data to be written in memory
  mem_data : out std_logic_vector( 31 downto 0 );
  -- Write enable signal
  mem_we : out std_logic_vector( 0 downto 0 );
  --------------------------------------
  -- Signals to/from the transmit thread
  --------------------------------------
  -- Instruct sender to send the frame
  send_frame : out std_logic;
  -- Number of dibits to be sent
  number_of_dibits : out unsigned( 12 downto 0 );
  -- From sender, acknowledge that packet was sent
  frame_acknowledge : in std_logic;
  ---------------------------------
  -- User interface signals
  ---------------------------------
  LED : out std_logic_vector( 15 downto 0 );
  SW : in std_logic_vector( 15 downto 0 );
  IP_address : out std_logic_vector( 31 downto 0 )
);
end tcpip_layer;

architecture behavioral of tcpip_layer is

  -- Constant declarations
  ------------------------

  -- Ethernet constants
  -- This devices's MAC address
  -- constant MAC_address : std_logic_vector( 47 downto 0 ) := x"001020000001";
  constant MAC_address : std_logic_vector( 47 downto 0 ) := x"000874e1166f";
  constant BRDCST_MAC  : std_logic_vector( 47 downto 0 ) := x"ffffffffffff";
  -- Ethernet type: ARP: 0x0806
  constant ETH_TYPE_ARP : std_logic_vector( 15 downto 0 ) := x"0806";
  -- Ethernet type: IP: 0x0800
  constant ETH_TYPE_IP  : std_logic_vector( 15 downto 0 ) := x"0800";

  -- ARP constants
  -- Hardware Type: 0x0001 (Ethernet)
  constant ARP_HW_TYPE : std_logic_vector( 15 downto 0 ) := x"0001";
  -- Protocol type: 0x0800 (IPv4)
  constant ARP_PROT    : std_logic_vector( 15 downto 0 ) := x"0800";
  -- Length: 0x0604 (6 hw address, 4 protocol address)
  constant ARP_LEN     : std_logic_vector( 15 downto 0 ) := x"0604";
  -- Opcode: request 0x0001, reply 0x0002
  constant ARP_REQ     : std_logic_vector( 15 downto 0 ) := x"0001";
  constant ARP_REP     : std_logic_vector( 15 downto 0 ) := x"0002";
  -- Padding stuff
  constant ARP_PADDING : std_logic_vector( 15 downto 0 ) := x"0000";

  -- IP and UDP constants
  -- IP version, header length and DSCP+ECN: 0x4500
  constant IP_VER      : std_logic_vector( 15 downto 0 ) := x"4500";
  -- IP flags + offset (assuming no fragmentation): 0x4000, or 0x0000
  constant IP_OFFSET   : std_logic_vector( 15 downto 0 ) := x"0000";
  -- IP TTL + Protocol: 0x8011
  constant IP_TTL_PROT : std_logic_vector( 15 downto 0 ) := x"8011";
  -- IP base checksum (IP_VER + IP_TTL_PROT): 0xC511
  constant IP_BASE_CHK : std_logic_vector( 15 downto 0 ) := x"c511";
  -- UDP checksum: 0x0000 (not used)
  constant UDP_CHECKSUM : std_logic_vector( 15 downto 0 ) := x"0000";
  constant IP_PROT_UDP : std_logic_vector( 7 downto 0 ) := x"11";
  -- DHCP constants
  constant UDP_PORT_DHCP_CLIENT : std_logic_vector( 15 downto 0 ) := x"0044";
  constant UDP_PORT_DHCP_SERVER : std_logic_vector( 15 downto 0 ) := x"0043";
  constant DHCP_XID : std_logic_vector( 31 downto 0 ) := x"00000004";
  constant DHCP_OPTION_SUBNETMASK : std_logic_vector( 7 downto 0 ) := x"01"; -- 1, Subnet mask
  constant DHCP_OPTION_ROUTER : std_logic_vector( 7 downto 0 ) := x"03"; -- 3, Router
  constant DHCP_OPTION_DNS : std_logic_vector( 7 downto 0 ) := x"06"; -- 6, Domain name server
  constant DHCP_OPTION_HOSTNAME : std_logic_vector( 7 downto 0 ) := x"0c"; -- 12, Host name
  constant DHCP_OPTION_IMTU : std_logic_vector( 7 downto 0 ) := x"1a"; -- 26, Interface MTU
  constant DHCP_OPTION_REQUESTED_IP : std_logic_vector( 7 downto 0 ) := x"32"; -- 50, Requested IP address
  constant DHCP_OPTION_IP_LEASE_TIME : std_logic_vector( 7 downto 0 ) := x"33"; -- 51, IP address lease time
  constant DHCP_OPTION_MSG_TYPE : std_logic_vector( 7 downto 0 ) := x"35"; -- 53, DHCP message type
  constant DHCP_OPTION_SERVER_ID : std_logic_vector( 7 downto 0 ) := x"36"; -- 54, Server identifier
  constant DHCP_OPTION_PARAMETER_LIST : std_logic_vector( 7 downto 0 ) := x"37"; -- 55, Parameter request list
  constant DHCP_OPTION_END : std_logic_vector( 7 downto 0 ) := x"ff"; -- 255, End
  constant DHCP_MSG_TYPE_DISCOVER : std_logic_vector( 7 downto 0 ) := x"01";
  constant DHCP_MSG_TYPE_OFFER : std_logic_vector( 7 downto 0 ) := x"02";
  constant DHCP_MSG_TYPE_REQUEST : std_logic_vector( 7 downto 0 ) := x"03";
  constant DHCP_MSG_TYPE_ACK : std_logic_vector( 7 downto 0 ) := x"05";

  -- Fixed packet declarations
  constant dhcp_discover_size : integer := 76;
  type dhcp_discover_type is array( 0 to dhcp_discover_size - 1 ) of std_logic_vector( 31 downto 0 );
  constant dhcp_discover_packet : dhcp_discover_type := (
    -- Operation (0x01 request), HW Type (0x01 Ethernet), HW Address Length (0x06), Hops (0x00)
    x"01010600",
    -- Transaction identification number (0x00000000 or whatever)
    DHCP_XID,
    -- Seconds from request (0x0000), Flags (0x8000, broadcast reply, or 0x0000 unicast reply)
    x"00000000",
    -- Client IP address (0x00000000)
    x"00000000",
    -- Your IP address (0x00000000)
    x"00000000",
    -- Server IP address (0x00000000)
    x"00000000",
    -- Gateway IP address (0x00000000)
    x"00000000",
    -- MAC address (HW address) (16 bytes)
    MAC_address( 47 downto 16 ),
    std_logic_vector'(MAC_address( 15 downto 0 ) & x"0000"),
    x"00000000", x"00000000",
    -- Server name (64 bytes)
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    -- File name (128 bytes )
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    -- Magic cookie (0x63825363)
    x"63825363",
    -- Options.
    -- Message Type (0x35), length 1, 1 (discover)
    -- Host name (0x0c), length 0x07, "nexys40"
    std_logic_vector'(DHCP_OPTION_MSG_TYPE & x"01" & DHCP_MSG_TYPE_DISCOVER & DHCP_OPTION_HOSTNAME),
    x"076e6578",
    x"79733430",
    -- Parameter request list (0x37), length 2
    -- * subnetmask (0x01)
    -- * router (0x03)
    std_logic_vector'(DHCP_OPTION_PARAMETER_LIST & x"02" & DHCP_OPTION_SUBNETMASK & DHCP_OPTION_ROUTER),
    -- End (0xff) + padding
    std_logic_vector'(DHCP_OPTION_END & x"000000"),
    -- More padding to make the message size the minimum
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000"
  );
  -- DHCP request packet payload
  constant dhcp_request_size : integer := 64;
  type dhcp_request_type is array( 0 to dhcp_request_size - 1 ) of std_logic_vector( 31 downto 0 );
  constant dhcp_request_packet : dhcp_request_type := (
    -- Operation (0x01 request), HW Type (0x01 Ethernet), HW Address Length (0x06), Hops (0x00)
    x"01010600",
    -- Transaction identification number (0x00000000 or whatever)
    DHCP_XID,
    -- Seconds from request (0x0000), Flags (0x8000, broadcast reply, or 0x0000 unicast reply)
    x"00000000",
    -- Client IP address (0x00000000)
    x"00000000",
    -- Your IP address (0x00000000)
    x"00000000",
    -- Server IP address (0x00000000)
    x"00000000",
    -- Gateway IP address (0x00000000)
    x"00000000",
    -- MAC address (HW address) (16 bytes)
    MAC_address( 47 downto 16 ),
    std_logic_vector'(MAC_address( 15 downto 0 ) & x"0000"),
    x"00000000", x"00000000",
    -- Server name (64 bytes)
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    -- File name (128 bytes )
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    x"00000000", x"00000000", x"00000000", x"00000000",
    -- Magic cookie (0x63825363)
    x"63825363",
    -- Options.
    -- Message Type (0x35), length 1, 3 (request)
    -- Host name (0x0c), length 0x07, "nexys40"
    std_logic_vector'(DHCP_OPTION_MSG_TYPE & x"01" & DHCP_MSG_TYPE_REQUEST & DHCP_OPTION_HOSTNAME),
    x"076e6578",
    x"79733430",
    -- Parameter request list (0x37), length 2
    -- * subnetmask (0x01)
    -- * router (0x03)
    std_logic_vector'(DHCP_OPTION_PARAMETER_LIST & x"02" & DHCP_OPTION_SUBNETMASK & DHCP_OPTION_ROUTER)
--    -- Server identifier option + request ip address (address 75)
--    DHCP_OPTION_SERVER_ID & x"04" & x"0000",
--    x"0000" & DHCP_OPTION_REQUESTED_IP & x"04",
--    x"00000000",
--    -- End (0xff) + padding
--    DHCP_OPTION_END & x"000000",
--    -- More padding to make the message size the minimum
--    x"00000000", x"00000000", x"00000000", x"00000000",
--    x"00000000", x"00000000", x"00000000", x"00000000",
--    x"00000000", x"00000000", x"00000000"
  );

  -- Internal signals
  -------------------
  -- Commands to the transmit process subroutines
  signal t_write_arp_request : std_logic;
  signal t_write_arp_reply : std_logic;
  signal t_write_udp_datagram : std_logic;
  signal t_write_eth_frame : std_logic;
  -- Data for the transmit process subroutines
  signal t_eth_destination_mac : std_logic_vector( 47 downto 0 );
  signal t_eth_source_mac : std_logic_vector( 47 downto 0 );
  signal t_arp_destination_mac : std_logic_vector( 47 downto 0 );
  signal t_arp_source_mac : std_logic_vector( 47 downto 0 );
  signal t_arp_destination_ip : std_logic_vector( 31 downto 0 );
  signal t_arp_source_ip : std_logic_vector( 31 downto 0 );
  signal t_data_length : unsigned( 15 downto 0 );
  signal t_ip_identification : unsigned( 15 downto 0 );
  signal t_ip_source_ip : std_logic_vector( 31 downto 0 );
  signal t_ip_destination_ip : std_logic_vector( 31 downto 0 );
  signal t_udp_source_port : std_logic_vector( 15 downto 0 );
  signal t_udp_destination_port : std_logic_vector( 15 downto 0 );
  -- The total length, in bytes, of the data to be sent stored in memory
  signal t_total_length : unsigned( 10 downto 0 );
  -- The length value for the IP header
  signal t_ip_length : unsigned( 15 downto 0 );
  -- The length value for the UDP header
  signal t_udp_length : unsigned( 15 downto 0 );
  -- Temporary checksum values (one bit larger than checksum value, to hold the
  -- carry out)
  signal t_ip_checksum1 : unsigned( 16 downto 0 );
  signal t_ip_checksum2 : unsigned( 16 downto 0 );
  -- Transmit memory interface signals
  signal t_mem_data : std_logic_vector( 31 downto 0 );
  signal t_mem_we : std_logic_vector( 0 downto 0 );

  --------------------------
  -- IP layer parameters
  --------------------------
  signal my_ip_address : std_logic_vector( 31 downto 0 );
  signal router_ip_address : std_logic_vector( 31 downto 0 );
  signal router_mac_address : std_logic_vector( 47 downto 0 );
  signal gateway_ip_address : std_logic_vector( 31 downto 0 );
  signal gateway_mac_address : std_logic_vector( 47 downto 0 );

  ----------------------------
  -- Receive process signals
  ----------------------------
  -- Internal commands
  signal send_arp_request_message : std_logic;
  signal set_send_arp_request_message : std_logic;
  signal clear_send_arp_request_message : std_logic;
  signal send_arp_reply_message : std_logic;
  signal set_send_arp_reply_message : std_logic;
  signal clear_send_arp_reply_message : std_logic;
  signal arp_reply_destination_mac : std_logic_vector( 47 downto 0 );
  signal arp_reply_destination_ip : std_logic_vector( 31 downto 0 );
  signal arp_request_destination_mac : std_logic_vector( 47 downto 0 );
  signal arp_request_destination_ip : std_logic_vector( 31 downto 0 );
  signal send_dhcp_discover_message : std_logic;
  signal set_send_dhcp_discover_message : std_logic;
  signal clear_send_dhcp_discover_message : std_logic;
  signal send_dhcp_request_message : std_logic;
  signal set_send_dhcp_request_message : std_logic;
  signal clear_send_dhcp_request_message : std_logic;
  -- Data collected from receive buffer
  signal r_eth_destination_mac : std_logic_vector( 47 downto 0 );
  signal r_eth_source_mac : std_logic_vector( 47 downto 0 );
  signal r_eth_ethernet_type : std_logic_vector( 15 downto 0 );
  signal r_arp_opcode : std_logic_vector( 15 downto 0 );
  signal r_arp_source_mac : std_logic_vector( 47 downto 0 );
  signal r_arp_source_ip : std_logic_vector( 31 downto 0 );
  signal r_arp_destination_mac : std_logic_vector( 47 downto 0 );
  signal r_arp_destination_ip : std_logic_vector( 31 downto 0 );
  signal r_ip_length : std_logic_vector( 15 downto 0 );
  signal r_ip_identification : std_logic_vector( 15 downto 0 );
  signal r_ip_protocol : std_logic_vector( 7 downto 0 );
  signal r_ip_source_ip : std_logic_vector( 31 downto 0 );
  signal r_ip_destination_ip : std_logic_vector( 31 downto 0 );
  signal r_udp_source_port : std_logic_vector( 15 downto 0 );
  signal r_udp_destination_port : std_logic_vector( 15 downto 0 );
  signal r_udp_length : std_logic_vector( 15 downto 0 );
  signal r_dhcp_msg_type : std_logic_vector( 7 downto 0 );
  signal r_dhcp_server_id : std_logic_vector( 31 downto 0 );
  signal r_dhcp_subnetmask : std_logic_vector( 31 downto 0 );
  signal r_dhcp_router_ip : std_logic_vector( 31 downto 0 );
  signal r_dhcp_router_mac : std_logic_vector( 47 downto 0 );
  signal r_dhcp_option_length : unsigned( 7 downto 0 );
  -- Receive buffer data scanner signals
  signal scanner_addr : unsigned( 8 downto 0 );
  signal scanner_set_addr : unsigned( 8 downto 0 );
  signal scanner_byte : unsigned( 1 downto 0 );
  signal scanner_byte_data : std_logic_vector( 7 downto 0 );
  signal scanner_count_init, scanner_count_enable, scanner_count_set, scanner_byte_enable : std_logic;

  signal iLED : std_logic_vector( 15 downto 0 );

  -- Counters
  -----------
  -- Transmit buffer address counter
  constant t_addr_counter_size : integer := 9;
  signal t_addr_counter_count : unsigned( t_addr_counter_size - 1 downto 0 );
  signal t_addr_counter_init, t_addr_counter_enable, t_addr_counter_tc : std_logic;
  -- Packet data payload counter
  constant t_payload_counter_size : integer := 9;
  signal t_payload_counter_count, t_payload_counter_modulo : unsigned( t_payload_counter_size - 1 downto 0 );
  signal t_payload_counter_init, t_payload_counter_enable, t_payload_counter_tc : std_logic;

  -- State machines
  -----------------
  -- Transmit process state machine
  type tstate_type is ( ready,
    arp_request0, arp_request1, arp_request2, 
    arp_reply0, arp_reply1, arp_reply2,
    udp_header0, udp_header1, udp_data0,
    dhcp_discover0, dhcp_discover1, dhcp_discover2, 
    dhcp_request0, dhcp_request1, dhcp_request2, dhcp_request3, dhcp_request4, dhcp_request5, dhcp_request6, dhcp_request7,
    raweth0, raweth1, raweth2, raweth3,
    arpreq0, arpreq1, arpreq2, arpreq3, arpreq4, arpreq5, arpreq6,
    udp0, udp1, udp2, udp3, udp4, udp5, udp6,
    send, waitack );
  signal tstate, t_return_state : tstate_type;
  -- Receive process state machine
  type rstate_type is ( ready,
    eth0, eth1, eth2, eth3, eth4, eth5, eth6, eth7, eth8, eth9, eth10, eth11,
    arp_reply0, arp_reply1,
    dhcp0, dhcp1, dhcp2, dhcp3,
    dhcp_msg_type0, dhcp_msg_type1,
    dhcp_server_id0, dhcp_server_id1, dhcp_server_id2, dhcp_server_id3, dhcp_server_id4,
    dhcp_router0, dhcp_router1, dhcp_router2, dhcp_router3, dhcp_router4,
    dhcp_subnetmask0, dhcp_subnetmask1, dhcp_subnetmask2, dhcp_subnetmask3, dhcp_subnetmask4,
    dhcp_end, dhcp_option_skip0, dhcp_option_skip1,
    release_frame, release_offer, release_ack, release1 );
  signal rstate : rstate_type;

begin

  mem_addr <= std_logic_vector( t_addr_counter_count );
  mem_data <= t_mem_data;
  mem_we <= t_mem_we;
  number_of_dibits <= t_total_length & "00";
  LED <= iLED;
  process ( SW, my_ip_address, r_dhcp_router_ip, r_dhcp_server_id, r_dhcp_subnetmask, r_dhcp_router_mac ) begin
    IP_address <= x"00000000";
    case SW( 2 downto 0 ) is
      when "000" => IP_address <= my_ip_address;
      when "001" => IP_address <= r_dhcp_server_id;
      when "010" => IP_address <= r_dhcp_subnetmask;
      when "011" => IP_address <= r_dhcp_router_ip;
      when "100" => IP_address <= r_dhcp_router_mac( 31 downto 0 );
      when "101" => IP_address <= r_dhcp_router_mac( 47 downto 16 );
      when others => IP_address <= my_ip_address;
    end case;
  end process;

  -- Transmit process, handles writing header data and send handshake
  process ( clock, reset ) begin
    if reset = '0' then
      tstate <= ready;
      t_write_arp_request <= '0';
      t_write_arp_reply <= '0';
      t_write_udp_datagram <= '0';
      t_write_eth_frame <= '0';
      t_eth_destination_mac <= ( others => '0' );
      t_eth_source_mac <= ( others => '0' );
      t_data_length <= ( others => '0' );
      t_arp_destination_mac <= ( others => '0' );
      t_arp_source_mac <= ( others => '0' );
      t_arp_destination_ip <= ( others => '0' );
      t_arp_source_ip <= ( others => '0' );
      t_ip_identification <= ( others => '1' );
      t_ip_source_ip <= ( others => '0' );
      t_ip_destination_ip <= ( others => '0' );
      t_udp_source_port <= ( others => '0' );
      t_udp_destination_port <= ( others => '0' );
      t_total_length <= ( others => '0' );
      t_ip_length <= ( others => '0' );
      t_udp_length <= ( others => '0' );
      t_ip_checksum1 <= ( others => '0' );
      t_ip_checksum2 <= ( others => '0' );
      send_frame <= '0';
    elsif rising_edge( clock ) then

      case tstate is

        when ready =>
          t_write_arp_request <= '0';
          t_write_arp_reply <= '0';
          t_write_udp_datagram <= '0';
          t_write_eth_frame <= '0';
          iLED( 0 ) <= '0';
          iLED( 1 ) <= '0';
          iLED( 2 ) <= '0';
--          if send_dhcp_discover_message = '1' then
          if user_configure = '1' then
            -- We must initiate a DHCP discovery
            tstate <= dhcp_discover0;
          elsif send_dhcp_request_message = '1' then
            tstate <= dhcp_request0;
          elsif send_arp_request_message = '1' then
            tstate <= arp_request0;
          elsif send_arp_reply_message = '1' then
            tstate <= arp_reply0;
          elsif user_write_udp_header = '1' then
            iLED( 0 ) <= '1';
            tstate <= udp_header0;
          elsif user_write_udp_data = '1' then
            tstate <= udp_data0;
          elsif user_transmit_frame = '1' then
            t_return_state <= ready;
            tstate <= send;
          end if;

        when arp_request0 =>
          -- Set up the necessary data for ARP message creation
          t_eth_destination_mac <= BRDCST_MAC;
          t_eth_source_mac <= MAC_address;
          t_arp_destination_mac <= x"000000000000";
          t_arp_destination_ip <= arp_request_destination_ip;
          t_arp_source_mac <= MAC_address;
          t_arp_source_ip <= my_ip_address;
          -- Set up the return state
          t_return_state <= arp_request1;
          -- Jump to write header subroutine
          t_write_arp_request <= '1';
          tstate <= raweth0;
        when arp_request1 =>
          -- Send the packet
          t_return_state <= arp_request2;
          tstate <= send;
        when arp_request2 => tstate <= ready;

        when arp_reply0 =>
          -- Set up the necessary data for ARP message creation
          t_eth_destination_mac <= arp_reply_destination_mac;
          t_eth_source_mac <= MAC_address;
          t_arp_destination_mac <= arp_reply_destination_mac;
          t_arp_destination_ip <= arp_reply_destination_ip;
          t_arp_source_mac <= MAC_address;
          t_arp_source_ip <= my_ip_address;
          -- Set up the return state
          t_return_state <= arp_reply1;
          -- Jump to write header subroutine
          t_write_arp_reply <= '1';
          tstate <= raweth0;
        when arp_reply1 =>
          -- Send the packet
          t_return_state <= arp_reply2;
          tstate <= send;
        when arp_reply2 => tstate <= ready;

        -- Write a UDP header with the given data
        when udp_header0 =>
          -- Send to the gateway MAC address
          t_eth_destination_mac <= r_dhcp_router_mac;
          -- Use Turtle destination mac instead
          -- t_eth_destination_mac <= x"0014222ec8b4";
          t_eth_source_mac <= MAC_address;
          t_data_length <= user_udp_data_length;
          t_ip_identification <= t_ip_identification + 1;
          t_ip_source_ip <= my_ip_address;
          t_ip_destination_ip <= user_udp_destination_ip;
          t_udp_source_port <= user_udp_source_port;
          t_udp_destination_port <= user_udp_destination_port;
          -- Set up the return state
          t_return_state <= udp_header1;
          -- Jump to write header subroutine
          t_write_udp_datagram <= '1';
          tstate <= raweth0;
        when udp_header1 =>
          -- Go to writing the data
          tstate <= udp_data0;

        when udp_data0 =>
          -- There is data on the input, which we must write in the memory. Stay
          -- here as long as user_write_udp_data is active. Then, send the packet
          t_return_state <= ready;
          if user_write_udp_data = '0' then
            tstate <= send;
          end if;

        -- Send a DHCP discover UDP message
        when dhcp_discover0 =>
          -- Set up all the necessary data for UDP header creation
          t_eth_destination_mac <= x"ffffffffffff";
          t_eth_source_mac <= MAC_address;
          t_data_length <= to_unsigned( dhcp_discover_size * 4, 16 );
          t_ip_identification <= t_ip_identification + 1;
          t_ip_source_ip <= x"00000000";
          t_ip_destination_ip <= x"ffffffff";
          t_udp_source_port <= x"0044";
          t_udp_destination_port <= x"0043";
          -- Set up the return state
          t_return_state <= dhcp_discover1;
          -- Jump to write header subroutine
          t_write_udp_datagram <= '1';
          tstate <= raweth0;
        when dhcp_discover1 =>
          -- In this state we enable the payload counter and write the UDP data
          -- in memory. Wait for the process to finish, and then send the packet
          if t_payload_counter_tc = '1' then
            -- At this point we can send the Ethernet frame
            t_return_state <= dhcp_discover2;
            tstate <= send;
          end if;
        when dhcp_discover2 => tstate <= ready;

        -- Send a DHCP request UDP message
        when dhcp_request0 =>
          -- Set up all the necessary data for UDP header creation
          t_eth_destination_mac <= x"ffffffffffff";
          t_eth_source_mac <= MAC_address;
          -- TODO: adjust the size of the data
          t_data_length <= to_unsigned( ( dhcp_request_size + 12 ) * 4, 16 );
          t_ip_source_ip <= x"00000000";
          t_ip_destination_ip <= x"ffffffff";
          t_udp_source_port <= x"0044";
          t_udp_destination_port <= x"0043";
          -- Set up the return state
          t_return_state <= dhcp_request1;
          -- Jump to write header subroutine
          t_write_udp_datagram <= '1';
          tstate <= raweth0;
        when dhcp_request1 =>
          -- In this state we enable the payload counter and write the UDP data
          -- in memory. Wait for the process to finish, and then proceed to
          -- completing the packet
          if t_payload_counter_tc = '1' then
            tstate <= dhcp_request2;
          end if;
        when dhcp_request2 => tstate <= dhcp_request3;
        when dhcp_request3 => tstate <= dhcp_request4;
        when dhcp_request4 => tstate <= dhcp_request5;
        when dhcp_request5 => tstate <= dhcp_request6;
        when dhcp_request6 =>
          -- Here we pad the packet with zeros, so wait for the counter to
          -- finish. Once done, we can send the frame
          if t_payload_counter_tc = '1' then
            t_return_state <= dhcp_request7;
            tstate <= send;
          end if;
        when dhcp_request7 => tstate <= ready;

        -- Subroutine to write header data
        when raweth0 =>
          -- Compute packet length for IP and UDP datagrams
          t_ip_length <= t_data_length + 28;
          t_udp_length <= t_data_length + 8;
          -- Start computing the IP checksum
          t_ip_checksum1 <= unsigned( '0' & t_ip_source_ip( 31 downto 16 ) ) + unsigned( '0' & t_ip_source_ip( 15 downto 0 ) );
          t_ip_checksum2 <= unsigned( '0' & t_ip_destination_ip( 31 downto 16 )) + unsigned( '0' & t_ip_destination_ip( 15 downto 0 ) );
          tstate <= raweth1;
        when raweth1 =>
          t_ip_checksum1 <= ( "0" & t_ip_checksum1( 15 downto 0 ) ) + ( "0" & t_ip_length ) + ( "0000000000000000" & t_ip_checksum1( 16 ) );
          t_ip_checksum2 <= ( "0" & t_ip_checksum2( 15 downto 0 ) ) + ( "0" & t_ip_identification ) + ( "0000000000000000" & t_ip_checksum2( 16 ) );
          tstate <= raweth2;
        when raweth2 =>
          t_ip_checksum1 <= ( "0" & t_ip_checksum1( 15 downto 0 ) ) + unsigned( '0' & IP_OFFSET ) + ( "0000000000000000" & t_ip_checksum1( 16 ) );
          t_ip_checksum2 <= ( "0" & t_ip_checksum2( 15 downto 0 ) ) + unsigned( '0' & IP_BASE_CHK ) + ( "0000000000000000" & t_ip_checksum2( 16 ) );
          tstate <= raweth3;
        when raweth3 =>
          t_ip_checksum1 <= ( "0" & t_ip_checksum1( 15 downto 0 ) ) + ( "0" & t_ip_checksum2( 15 downto 0 ) ) + ( "0000000000000000" & t_ip_checksum1( 16 ) ) + ( "0000000000000000" & t_ip_checksum2( 16 ) );
          if t_write_arp_request = '1' or t_write_arp_reply = '1' then
            -- Compute packet total length in bytes. For ARP it is always 60 bytes
            t_total_length <= to_unsigned( 60, 11 );
            tstate <= arpreq0;
          elsif t_write_udp_datagram = '1' then
            -- Compute packet total length in bytes. For UDP it is the ip_length
            -- plus the ethernet header (14 bytes)
            t_total_length <= t_ip_length( 10 downto 0 ) + 14;
            tstate <= udp0;
          elsif t_write_eth_frame = '1' then
            -- Compute packet total length in bytes. For raw Ethernet we simply
            -- add the ethernet header length (14 bytes)
            t_total_length <= t_data_length( 10 downto 0 ) + 14;
            tstate <= t_return_state;
          end if;

        -- Store the whole ARP message in memory
        when arpreq0 => tstate <= arpreq1;
        when arpreq1 => tstate <= arpreq2;
        when arpreq2 => tstate <= arpreq3;
        when arpreq3 => tstate <= arpreq4;
        when arpreq4 => tstate <= arpreq5;
        when arpreq5 => tstate <= arpreq6;
        when arpreq6 => tstate <= t_return_state;
          -- Should we add code for adding 0 padding? Not necessary, really. It
          -- would be 5 states... Useful if we don't want to send info from
          -- previous packets

        -- Store the IP and UDP header in memory
        when udp0 =>
          t_ip_checksum1 <= ( "0" & t_ip_checksum1( 15 downto 0 ) ) + ( "0000000000000000" & t_ip_checksum1( 16 ) );
          tstate <= udp1;
        when udp1 =>
          t_ip_checksum1 <= not t_ip_checksum1;
          tstate <= udp2;
        when udp2 => tstate <= udp3;
        when udp3 => tstate <= udp4;
        when udp4 => tstate <= udp5;
        when udp5 => tstate <= udp6;
        when udp6 => tstate <= t_return_state;

        -- Instruct the packet sender to send the frame
        when send =>
          -- Check if the dibit sender is available for sending. If not, stay
          -- in this state until it is
          if frame_acknowledge = '0' then
            -- Yes, we can request the frame to be sent
            send_frame <= '1';
            tstate <= waitack;
          end if;
        when waitack =>
          -- Wait for the frame to be sent, handle handshake
          if frame_acknowledge = '1' then
            send_frame <= '0';
            tstate <= t_return_state;
          end if;

      end case;

    end if;

  end process;

  -- Compute the state machine output values
  process ( tstate, user_udp_data, user_write_udp_data, t_payload_counter_count,
    r_dhcp_server_id, my_ip_address, t_eth_destination_mac, t_eth_source_mac,
    t_write_arp_request, t_write_arp_reply, t_write_udp_datagram,
    t_write_eth_frame, t_data_length, t_arp_source_mac, t_arp_source_ip,
    t_arp_destination_mac, t_arp_destination_ip, t_ip_length,
    t_ip_identification, t_ip_checksum1, t_ip_source_ip, t_ip_destination_ip,
    t_udp_source_port, t_udp_destination_port, t_udp_length )
  begin
    -- By default transmit memory data is zero
    t_mem_data <= ( others => '0' );
    -- By default we do not write the memory
    t_mem_we <= "0";
    -- Acknowledge signal to user process
    user_acknowledge <= '0';

    -- By default we leave the memory address and payload counter alone
    t_addr_counter_init <= '0';
    t_addr_counter_enable <= '0';
    t_payload_counter_init <= '0';
    t_payload_counter_enable <= '0';
    t_payload_counter_modulo <= ( others => '0' );

    clear_send_arp_request_message <= '0';
    clear_send_arp_reply_message <= '0';
    clear_send_dhcp_discover_message <= '0';
    clear_send_dhcp_request_message <= '0';

    case tstate is

      when ready =>
        -- Initialize the address counter to 0
        t_addr_counter_init <= '1';

      when arp_request2 => clear_send_arp_request_message <= '1';

      when arp_reply2 => clear_send_arp_reply_message <= '1';

      when udp_header1 => user_acknowledge <= '1';

      when udp_data0 =>
        if user_write_udp_data = '1' then
          t_mem_we <= "1";
          t_addr_counter_enable <= '1';
          t_mem_data <= user_udp_data;
        end if;

      when dhcp_discover0 =>
        -- Initialize the counter that will scan the data words in the packet data
        t_payload_counter_init <= '1';
        t_payload_counter_modulo <= to_unsigned( dhcp_discover_size - 1, t_payload_counter_size );
      when dhcp_discover1 =>
        -- When we get here, the UDP header has been written, and the memory
        -- address pointer points to the first word of the payload. We therefore
        -- write the data found in the constant packet and enable the counters
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        t_payload_counter_enable <= '1';
        t_mem_data <= dhcp_discover_packet( to_integer( t_payload_counter_count ) );
      when dhcp_discover2 => clear_send_dhcp_discover_message <= '1';

      when dhcp_request0 =>
        -- Initialize the counter that will scan the data words in the packet data
        t_payload_counter_init <= '1';
        t_payload_counter_modulo <= to_unsigned( dhcp_request_size - 1, t_payload_counter_size );
      when dhcp_request1 =>
        -- When we get here, the UDP header has been written, and the memory
        -- address pointer points to the first word of the payload. We therefore
        -- write the data found in the constant packet and enable the counters
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        t_payload_counter_enable <= '1';
        t_mem_data <= dhcp_request_packet( to_integer( t_payload_counter_count ) );
      when dhcp_request2 =>
        -- Write additional options
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        t_mem_data <= DHCP_OPTION_SERVER_ID & x"04" & r_dhcp_server_id( 31 downto 16 );
        -- We will also need the counter again to write more zeros at the end
        t_payload_counter_init <= '1';
        t_payload_counter_modulo <= to_unsigned( 15, t_payload_counter_size );
      when dhcp_request3 =>
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        t_payload_counter_enable <= '1';
        t_mem_data <= r_dhcp_server_id( 15 downto 0 ) & DHCP_OPTION_REQUESTED_IP & x"04";
      when dhcp_request4 =>
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        t_payload_counter_enable <= '1';
        t_mem_data <= my_ip_address;
      when dhcp_request5 =>
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        t_payload_counter_enable <= '1';
        t_mem_data <= DHCP_OPTION_END & x"000000";
      when dhcp_request6 =>
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        t_payload_counter_enable <= '1';
        t_mem_data <= x"00000000";
      when dhcp_request7 => clear_send_dhcp_request_message <= '1';

      -- Write packet data header into memory (subroutines)
      when raweth0 =>
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        t_mem_data <= "0000000000000000" & t_eth_destination_mac( 47 downto 32 );
      when raweth1 =>
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        t_mem_data <= t_eth_destination_mac( 31 downto 0 );
      when raweth2 =>
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        t_mem_data <= t_eth_source_mac( 47 downto 16 );
      when raweth3 =>
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        if t_write_arp_request = '1' or t_write_arp_reply = '1' then
          t_mem_data <= t_eth_source_mac( 15 downto 0 ) & ETH_TYPE_ARP;
        elsif t_write_udp_datagram = '1' then
          t_mem_data <= t_eth_source_mac( 15 downto 0 ) & ETH_TYPE_IP;
        elsif t_write_eth_frame = '1' then
          t_mem_data <= t_eth_source_mac( 15 downto 0 ) & std_logic_vector( t_data_length );
        end if;

      when arpreq0 =>
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        t_mem_data <= ARP_HW_TYPE & ARP_PROT;
      when arpreq1 =>
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        if t_write_arp_request = '1' then  t_mem_data <= ARP_LEN & ARP_REQ;
        elsif t_write_arp_reply = '1' then t_mem_data <= ARP_LEN & ARP_REP;
        end if;
      when arpreq2 =>
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        t_mem_data <= t_arp_source_mac( 47 downto 16 );
      when arpreq3 =>
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        t_mem_data <= t_arp_source_mac( 15 downto 0 ) & t_arp_source_ip( 31 downto 16 );
      when arpreq4 =>
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        if t_write_arp_request = '1' then  t_mem_data <= t_arp_source_ip( 15 downto 0 ) & ARP_PADDING;
        elsif t_write_arp_reply = '1' then t_mem_data <= t_arp_source_ip( 15 downto 0 ) & t_arp_destination_mac( 47 downto 32 );
        end if;
      when arpreq5 =>
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        if t_write_arp_request = '1' then  t_mem_data <= ARP_PADDING & ARP_PADDING;
        elsif t_write_arp_reply = '1' then t_mem_data <= t_arp_destination_mac( 31 downto 0 );
        end if;
      when arpreq6 =>
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        t_mem_data <= t_arp_destination_ip( 31 downto 0 );

      when udp0 =>
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        t_mem_data <= IP_VER & std_logic_vector( t_ip_length );
      when udp1 =>
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        t_mem_data <= std_logic_vector( t_ip_identification ) & IP_OFFSET;
      when udp2 =>
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        t_mem_data <= IP_TTL_PROT & std_logic_vector( t_ip_checksum1( 15 downto 0 ) );
      when udp3 =>
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        t_mem_data <= t_ip_source_ip( 31 downto 0 );
      when udp4 =>
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        t_mem_data <= t_ip_destination_ip( 31 downto 0 );
      when udp5 =>
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        t_mem_data <= t_udp_source_port & t_udp_destination_port;
      when udp6 =>
        t_mem_we <= "1";
        t_addr_counter_enable <= '1';
        t_mem_data <= std_logic_vector( t_udp_length ) & UDP_CHECKSUM;

      when others =>
        -- do nothing here
        t_mem_we <= "0";

    end case;

  end process;

  -- Receive process
  process ( clock, reset ) begin
    if reset = '0' then
      rstate <= ready;
      received_acknowledge <= '0';
      set_send_arp_request_message <= '0';
      set_send_arp_reply_message <= '0';
      set_send_dhcp_discover_message <= '0';
      set_send_dhcp_request_message <= '0';
      r_eth_destination_mac <= x"000000000000";
      r_eth_source_mac <= x"000000000000";
      r_eth_ethernet_type <= x"0000";
      r_arp_opcode <= x"0000";
      r_arp_source_mac <= x"000000000000";
      r_arp_source_ip <= x"00000000";
      r_arp_destination_mac <= x"000000000000";
      r_arp_destination_ip <= x"00000000";
      r_ip_length <= x"0000";
      r_ip_identification <= x"0000";
      r_ip_protocol <= x"00";
      r_ip_source_ip <= x"00000000";
      r_ip_destination_ip <= x"00000000";
      r_udp_source_port <= x"0000";
      r_udp_destination_port <= x"0000";
      r_udp_length <= x"0000";
      r_dhcp_msg_type <= x"00";
      r_dhcp_server_id <= x"00000000";
      r_dhcp_subnetmask <= x"00000000";
      r_dhcp_router_ip <= x"00000000";
      r_dhcp_router_mac <= ( others => '0' );
      r_dhcp_option_length <= x"00";
      arp_request_destination_mac <= ( others => '0' );
      arp_request_destination_ip <= ( others => '0' );
      arp_reply_destination_mac <= ( others => '0' );
      arp_reply_destination_ip <= ( others => '0' );
      my_ip_address <= x"a9fe0001";
      router_ip_address <= x"00000000";
      router_mac_address <= x"000000000000";
      gateway_ip_address <= x"00000000";
      gateway_mac_address <= x"000000000000";
      iLED( 15 downto 3 ) <= "0000000000000";
    elsif rising_edge( clock ) then

      case rstate is

        when ready =>
          -- Wait for a packet to be received
          if packet_received = '1' then rstate <= eth0; end if;

        when eth0 =>
          -- One state delay, to let the scanner be enabled
          rstate <= eth1;

        when eth1 =>
          -- Reading data at address 0
          r_eth_destination_mac( 47 downto 32 ) <= rec_datab( 15 downto 0 );
          rstate <= eth2;

        when eth2 =>
          -- Reading data at address 1
          r_eth_destination_mac( 31 downto 0 ) <= rec_datab;
          rstate <= eth3;

        when eth3 =>
          -- Reading data at address 2
          r_eth_source_mac( 47 downto 16 ) <= rec_datab;
          rstate <= eth4;

        when eth4 =>
          -- Reading data at address 3
          r_eth_source_mac( 15 downto 0 ) <= rec_datab( 31 downto 16 );
          r_eth_ethernet_type <= rec_datab( 15 downto 0 );
          rstate <= eth5;

        when eth5 =>
          -- Reading data at address 4
          r_ip_length <= rec_datab( 15 downto 0 );
          rstate <= eth6;

        when eth6 =>
          -- Reading data at address 5
          r_ip_identification <= rec_datab( 31 downto 16 );
          r_arp_opcode <= rec_datab( 15 downto 0 );
          rstate <= eth7;

        when eth7 =>
          -- Reading data at address 6
          r_ip_protocol <= rec_datab( 23 downto 16 );
          r_arp_source_mac( 47 downto 16 ) <= rec_datab;
          rstate <= eth8;

        when eth8 =>
          -- Reading data at address 7
          r_ip_source_ip <= rec_datab;
          r_arp_source_mac( 15 downto 0 ) <= rec_datab( 31 downto 16 );
          r_arp_source_ip( 31 downto 16 ) <= rec_datab( 15 downto 0 );
          rstate <= eth9;

        when eth9 =>
          -- Reading data at address 8
          r_ip_destination_ip <= rec_datab;
          r_arp_source_ip( 15 downto 0 ) <= rec_datab( 31 downto 16 );
          r_arp_destination_mac( 47 downto 32 ) <= rec_datab( 15 downto 0 );
          rstate <= eth10;

        when eth10 =>
          -- Reading data at address 9
          r_udp_source_port <= rec_datab( 31 downto 16 );
          r_udp_destination_port <= rec_datab( 15 downto 0 );
          r_arp_destination_mac( 31 downto 0 ) <= rec_datab;
          rstate <= eth11;

        when eth11 =>
          -- Reading data at address 10
          r_udp_length <= rec_datab( 31 downto 16 );
          r_arp_destination_ip <= rec_datab;
          -- At this point check what we have to deal with. If we don't find
          -- anything interesting, by default we will release the frame
          rstate <= release_frame;
          -- Check the destination MAC address
          if r_eth_destination_mac = x"ffffffffffff" or r_eth_destination_mac = MAC_address then
            -- It is for us. Check the type of packet
            if r_eth_ethernet_type = ETH_TYPE_ARP then
              -- It is either an ARP request or an ARP reply
              if r_arp_opcode = ARP_REQ then
                -- Check if the request matches our IP address (we must look
                -- directly at the data bus, since we are reading the ip address
                -- during this clock cycle)
                if rec_datab = my_ip_address then
                  iLED( 3 ) <= '1';
                  -- We must send an ARP reply. Check if there is no pending arp
                  -- reply requests
                  if send_arp_reply_message = '0' then
                    rstate <= arp_reply0;
                  -- TODO: else what do we do? We must wait here to send the ARP reply!!
                  end if;
                end if; -- Otherwise it is not for us, ignore
              elsif r_arp_opcode = ARP_REP then
                -- Check if the reply is for the router IP address
                if r_arp_source_ip = r_dhcp_router_ip then
                  r_dhcp_router_mac <= r_arp_source_mac;
                end if; -- TODO: any other ARP request we want to do?
              end if;
            elsif r_eth_ethernet_type = ETH_TYPE_IP then
              -- It is an IP packet. Check if it is a UDP or TCP packet
              iLED( 4 ) <= '1';
              if r_ip_protocol = IP_PROT_UDP then
                -- Check the port to understand which service
                if r_udp_destination_port = UDP_PORT_DHCP_CLIENT then
                  -- It is a DHCP packet. Need to figure if it is offer or ack
                  iLED( 5 ) <= '1';
                  rstate <= dhcp0;
                end if; -- Otherwise other port, don't know what to do
              end if; -- Otherwise, we don't know how to handle the protocol
            end if; -- Otherwise, other Ethernet type, don't know
          end if; -- Not for us, simply ignore

        when arp_reply0 =>
          -- release the frame
          received_acknowledge <= '1';
          -- Set a request to send an arp reply, and provide the necessary data
          set_send_arp_reply_message <= '1';
          arp_reply_destination_mac <= r_arp_source_mac;
          arp_reply_destination_ip <= r_arp_source_ip;
          rstate <= arp_reply1;
        when arp_reply1 =>
          set_send_arp_reply_message <= '0';
          -- wait for packet_received to go down before deasserting acknowledge
          -- and go back to ready state
          if packet_received = '0' then
            received_acknowledge <= '0';
            rstate <= ready;
          end if;

        when dhcp0 =>
          rstate <= dhcp1;
          -- Reading at address 11
          if rec_datab( 31 downto 24 ) /= x"02" then
            -- This is not a DHCP reply, then ignore
            rstate <= release_frame;
          end if;

        when dhcp1 =>
          rstate <= dhcp2;
          -- Reading at address 12
          if rec_datab /= DHCP_XID then
            -- Not our transaction id, so not for us. Ignore
            rstate <= release_frame;
          end if;

        when dhcp2 =>
          -- Reading at address 15. Grab our IP address (yiaddr)
          my_ip_address <= rec_datab;
          rstate <= dhcp3;

        when dhcp3 =>
          -- Reading options at address 71
          if scanner_byte_data = DHCP_OPTION_MSG_TYPE then
            rstate <= dhcp_msg_type0;
          elsif scanner_byte_data = DHCP_OPTION_SERVER_ID then
            rstate <= dhcp_server_id0;
          elsif scanner_byte_data = DHCP_OPTION_SUBNETMASK then
            rstate <= dhcp_subnetmask0;
          elsif scanner_byte_data = DHCP_OPTION_ROUTER then
            rstate <= dhcp_router0;
          elsif scanner_byte_data = DHCP_OPTION_END then
            rstate <= dhcp_end;
          else
            rstate <= dhcp_option_skip0;
          end if;

        when dhcp_msg_type0 =>
          -- Length should be 1, just skip it
          rstate <= dhcp_msg_type1;
        when dhcp_msg_type1 =>
          if scanner_byte_data = DHCP_MSG_TYPE_OFFER then
            r_dhcp_msg_type <= DHCP_MSG_TYPE_OFFER;
            -- good, it's an offer, return to reading the options
            iLED( 6 ) <= '1';
            rstate <= dhcp3;
          elsif scanner_byte_data = DHCP_MSG_TYPE_ACK then
            -- Excellent, this solves the problem
            iLED( 10 ) <= '1';
            r_dhcp_msg_type <= DHCP_MSG_TYPE_ACK;
            rstate <= dhcp_end;
          else
            -- Don't know what to do with this message, release the frame
            rstate <= release_frame;
          end if;

        when dhcp_server_id0 => rstate <= dhcp_server_id1;
        when dhcp_server_id1 => r_dhcp_server_id( 31 downto 24 ) <= scanner_byte_data; rstate <= dhcp_server_id2;
        when dhcp_server_id2 => r_dhcp_server_id( 23 downto 16 ) <= scanner_byte_data; rstate <= dhcp_server_id3;
        when dhcp_server_id3 => r_dhcp_server_id( 15 downto 8 ) <= scanner_byte_data; rstate <= dhcp_server_id4;
        when dhcp_server_id4 => r_dhcp_server_id( 7 downto 0 ) <= scanner_byte_data; rstate <= dhcp3;

        when dhcp_router0 => rstate <= dhcp_router1;
        when dhcp_router1 => r_dhcp_router_ip( 31 downto 24 ) <= scanner_byte_data; rstate <= dhcp_router2;
        when dhcp_router2 => r_dhcp_router_ip( 23 downto 16 ) <= scanner_byte_data; rstate <= dhcp_router3;
        when dhcp_router3 => r_dhcp_router_ip( 15 downto 8 ) <= scanner_byte_data; rstate <= dhcp_router4;
        when dhcp_router4 => r_dhcp_router_ip( 7 downto 0 ) <= scanner_byte_data; rstate <= dhcp3;

        when dhcp_subnetmask0 => rstate <= dhcp_subnetmask1;
        when dhcp_subnetmask1 => r_dhcp_subnetmask( 31 downto 24 ) <= scanner_byte_data; rstate <= dhcp_subnetmask2;
        when dhcp_subnetmask2 => r_dhcp_subnetmask( 23 downto 16 ) <= scanner_byte_data; rstate <= dhcp_subnetmask3;
        when dhcp_subnetmask3 => r_dhcp_subnetmask( 15 downto 8 ) <= scanner_byte_data; rstate <= dhcp_subnetmask4;
        when dhcp_subnetmask4 => r_dhcp_subnetmask( 7 downto 0 ) <= scanner_byte_data; rstate <= dhcp3;

        when dhcp_option_skip0 =>
          -- Read the length
          r_dhcp_option_length <= unsigned( scanner_byte_data );
          rstate <= dhcp_option_skip1;
        when dhcp_option_skip1 =>
          r_dhcp_option_length <= r_dhcp_option_length - 1;
          if r_dhcp_option_length = 1 then
            rstate <= dhcp3;
          end if;

        when dhcp_end =>
          -- Time to handle the DHCP message
          if r_dhcp_msg_type = DHCP_MSG_TYPE_OFFER then
            -- Set a request to send a DHCP request message, and provide the
            -- necessary data
            if send_dhcp_request_message = '0' then
              set_send_dhcp_request_message <= '1';
              iLED( 7 ) <= '1';
              rstate <= release_offer;
            end if;
          elsif r_dhcp_msg_type = DHCP_MSG_TYPE_ACK then
            -- We need to send an ARP request for the MAC address of the router
            if send_arp_request_message = '0' then
              set_send_arp_request_message <= '1';
              arp_request_destination_ip <= r_dhcp_router_ip;
              iLED( 11 ) <= '1';
              rstate <= release_ack;
            end if;
          end if;

        when release_frame =>
          iLED( 13 ) <= '1';
          received_acknowledge <= '1';
          rstate <= release1;
        when release_offer =>
          -- Clear the commands
          set_send_dhcp_request_message <= '0';
          iLED( 8 ) <= '1';
          -- release the frame
          received_acknowledge <= '1';
          rstate <= release1;
        when release_ack =>
          set_send_arp_request_message <= '0';
          iLED( 12 ) <= '1';
          received_acknowledge <= '1';
          rstate <= release1;

        when release1 =>
          -- wait for packet_received to go down before deasserting acknowledge
          -- and go back to ready state
          if packet_received = '0' then
            iLED( 9 ) <= '1';
            received_acknowledge <= '0';
            rstate <= ready;
          end if;

      end case;
    end if;
  end process;

  process ( rstate ) begin
    -- Set the output values for each state. First set the defaults
    scanner_count_init <= '0';
    scanner_count_enable <= '0';
    scanner_count_set <= '0';
    scanner_set_addr <= "000000000";
    scanner_byte_enable <= '0';

    case rstate is
      when ready => scanner_count_init <= '1';
      when eth0 => scanner_count_enable <= '1'; -- count = 0, not reading
      when eth1 => scanner_count_enable <= '1'; -- count = 1, reading 0
      when eth2 => scanner_count_enable <= '1'; -- count = 2, reading 1
      when eth3 => scanner_count_enable <= '1'; -- count = 3, reading 2
      when eth4 => scanner_count_enable <= '1'; -- count = 4, reading 3
      when eth5 => scanner_count_enable <= '1'; -- count = 5, reading 4
      when eth6 => scanner_count_enable <= '1'; -- count = 6, reading 5
      when eth7 => scanner_count_enable <= '1'; -- count = 7, reading 6
      when eth8 => scanner_count_enable <= '1'; -- count = 8, reading 7
      when eth9 => scanner_count_enable <= '1'; -- count = 9, reading 8
      when eth10 => scanner_count_enable <= '1'; -- count = 10, reading 9
      when eth11 => scanner_count_enable <= '1'; -- count = 11, reading 10
      when dhcp0 => scanner_count_set <= '1'; scanner_set_addr <= "000001111"; -- count = 12, reading 11
      when dhcp1 => scanner_count_set <= '1'; scanner_set_addr <= "001000111"; -- count = 15, reading 12
      when dhcp2 => -- count = 71, byte = 0, reading 15
      when dhcp3 => scanner_count_enable <= '1'; scanner_byte_enable <= '1'; -- count = 71, byte = 0, reading 71
      when dhcp_msg_type0 => scanner_count_enable <= '1'; scanner_byte_enable <= '1';
      when dhcp_msg_type1 => scanner_count_enable <= '1'; scanner_byte_enable <= '1';
      when dhcp_server_id0 => scanner_count_enable <= '1'; scanner_byte_enable <= '1';
      when dhcp_server_id1 => scanner_count_enable <= '1'; scanner_byte_enable <= '1';
      when dhcp_server_id2 => scanner_count_enable <= '1'; scanner_byte_enable <= '1';
      when dhcp_server_id3 => scanner_count_enable <= '1'; scanner_byte_enable <= '1';
      when dhcp_server_id4 => scanner_count_enable <= '1'; scanner_byte_enable <= '1';
      when dhcp_router0 => scanner_count_enable <= '1'; scanner_byte_enable <= '1';
      when dhcp_router1 => scanner_count_enable <= '1'; scanner_byte_enable <= '1';
      when dhcp_router2 => scanner_count_enable <= '1'; scanner_byte_enable <= '1';
      when dhcp_router3 => scanner_count_enable <= '1'; scanner_byte_enable <= '1';
      when dhcp_router4 => scanner_count_enable <= '1'; scanner_byte_enable <= '1';
      when dhcp_subnetmask0 => scanner_count_enable <= '1'; scanner_byte_enable <= '1';
      when dhcp_subnetmask1 => scanner_count_enable <= '1'; scanner_byte_enable <= '1';
      when dhcp_subnetmask2 => scanner_count_enable <= '1'; scanner_byte_enable <= '1';
      when dhcp_subnetmask3 => scanner_count_enable <= '1'; scanner_byte_enable <= '1';
      when dhcp_subnetmask4 => scanner_count_enable <= '1'; scanner_byte_enable <= '1';
      when dhcp_option_skip0 => scanner_count_enable <= '1'; scanner_byte_enable <= '1';
      when dhcp_option_skip1 => scanner_count_enable <= '1'; scanner_byte_enable <= '1';
      when others =>
        -- do nothing, use the defaults
    end case;
  end process;

  -- Scanner process
  rec_addrb <= std_logic_vector( scanner_addr );
  process ( clock, reset ) begin
    if reset = '0' then
      scanner_addr <= "000000000";
      scanner_byte <= "00";
    elsif rising_edge( clock ) then
      if scanner_count_init = '1' then
        -- Initialize the scanner to zero
        scanner_addr <= "000000000";
        scanner_byte <= "00";
      elsif scanner_count_set = '1' then
        -- Initialize the scanner to a given address
        scanner_addr <= scanner_set_addr;
        scanner_byte <= "00";
      elsif scanner_count_enable = '1' then
        -- Increment the scanner by word or by byte
        if scanner_byte_enable = '1' then
          -- Increment by byte.
          if scanner_byte = "10" then
            scanner_addr <= scanner_addr + 1;
          end if;
          scanner_byte <= scanner_byte + 1;
        else
          -- Increment by word
          scanner_byte <= "00";
          scanner_addr <= scanner_addr + 1;
        end if;
      end if;
    end if;
  end process;
  process ( scanner_byte, rec_datab ) begin
    case scanner_byte is
      when "00" => scanner_byte_data <= rec_datab( 31 downto 24 );
      when "01" => scanner_byte_data <= rec_datab( 23 downto 16 );
      when "10" => scanner_byte_data <= rec_datab( 15 downto 8 );
      when "11" => scanner_byte_data <= rec_datab( 7 downto 0 );
      when others => scanner_byte_data <= rec_datab( 31 downto 24 );
    end case;
  end process;

  -- Instantiate the send request buffers
  process ( clock, reset ) begin
    if reset = '0' then
      send_arp_request_message <= '0';
    elsif rising_edge( clock ) then
      if clear_send_arp_request_message = '1' then
        send_arp_request_message <= '0';
      elsif set_send_arp_request_message = '1' then
        send_arp_request_message <= '1';
      end if;
    end if;
  end process;
  process ( clock, reset ) begin
    if reset = '0' then
      send_arp_reply_message <= '0';
    elsif rising_edge( clock ) then
      if clear_send_arp_reply_message = '1' then
        send_arp_reply_message <= '0';
      elsif set_send_arp_reply_message = '1' then
        send_arp_reply_message <= '1';
      end if;
    end if;
  end process;
  process ( clock, reset ) begin
    if reset = '0' then
      send_dhcp_discover_message <= '0';
    elsif rising_edge( clock ) then
      if clear_send_dhcp_discover_message = '1' then
        send_dhcp_discover_message <= '0';
      elsif set_send_dhcp_discover_message = '1' then
        send_dhcp_discover_message <= '1';
      end if;
    end if;
  end process;
  process ( clock, reset ) begin
    if reset = '0' then
      send_dhcp_request_message <= '0';
    elsif rising_edge( clock ) then
      if clear_send_dhcp_request_message = '1' then
        send_dhcp_request_message <= '0';
      elsif set_send_dhcp_request_message = '1' then
        send_dhcp_request_message <= '1';
      end if;
    end if;
  end process;

  -- Instantiate the address counter for the transmit process
  t_addr_counter : entity work.up_counter( behavioral ) generic map (
    size => t_addr_counter_size
  ) port map (
    clock => clock,
    reset => reset,
    counter_init => t_addr_counter_init,
    counter_enable => t_addr_counter_enable,
    count => t_addr_counter_count,
    counter_tc => t_addr_counter_tc
  );
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

end architecture;
