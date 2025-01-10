library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;

-- This block can send over the Ethernet network various kinds of packet. It
-- also function as an interface to the send buffer.
-- the following kinds of packets are recognized:
-- * Raw ethernet packet, data already stored in memory. For this packet, the
--   sender must provide
--   - MAC destination and source
--   - length of the packet
-- * ARP request packet. The sender must provide
--   - source MAC address and source IP address,
--   - destination IP address
-- * ARP reply packet. The sender must provide source MAC and IP address, and
--   destination MAC and IP address 
-- * UPD packet

entity packet_send is port (
  clock : in std_logic;
  reset : in std_logic;
  -- Relevant send data. Assumption is that the IP data is already written at
  -- the relevant address. Other assumption is that the provided information
  -- remains valid while the packet is sent.
  -- Send commands
  send_eth_packet : in std_logic;
  send_arp_request : in std_logic;
  send_arp_reply : in std_logic;
  send_udp_packet : in std_logic;
  write_udp_data : in std_logic;
  write_eth_data : in std_logic;
  -- Data required for sending packets
  -- Destination MAC address
  destination_mac : in std_logic_vector( 47 downto 0 );
  -- Source MAC address
  source_mac : in std_logic_vector( 47 downto 0 );
  -- Destination IP address
  destination_ip : in std_logic_vector( 31 downto 0 );
  -- Source IP address
  source_ip : in std_logic_vector( 31 downto 0 );
  -- Length of the data (data only, header length to be computed when
  -- necessary)
  packet_length : in unsigned( 15 downto 0 );
  -- Destination port
  destination_port : in std_logic_vector( 15 downto 0 );
  -- Source port
  source_port : in std_logic_vector( 15 downto 0 );
  -- Output ports
  -- Signals that the operation has been completed
  done : out std_logic;
  -- The memory address where data is written
  mem_addr : out std_logic_vector( 8 downto 0 );
  -- The data to be written in memory
  mem_data : out std_logic_vector( 31 downto 0 );
  -- Write enable signal
  mem_we : out std_logic_vector( 0 downto 0 );
  -- User data to be written in memory
  user_data_in : in std_logic_vector( 31 downto 0 );
  -- Instruct sender to send the frame
  send_frame : out std_logic;
  -- Number of dibits to be sent
  number_of_dibits : out unsigned( 12 downto 0 );
  -- From sender, acknowledge that packet was sent
  frame_acknowledge : in std_logic
  );
end packet_send;

architecture behavioral of packet_send is

  -- Constant declarations
  ------------------------

  -- Ethernet Type values
  -- ARP: 0x0806
  constant ETH_TYPE_ARP : std_logic_vector( 15 downto 0 ) := x"0806";
  -- IP: 0x0800
  constant ETH_TYPE_IP  : std_logic_vector( 15 downto 0 ) := x"0800";

  -- ARP values. Hardware Type: 0x0001 (Ethernet)
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

  -- IP and UDP values
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

  -- Signal declarations
  ------------------------

  -- The total length, in bytes, of the data to be sent stored in memory
  signal total_length : unsigned( 10 downto 0 );
  -- The length value for the IP header
  signal ip_length : unsigned( 15 downto 0 );
  -- The length value for the UDP header
  signal udp_length : unsigned( 15 downto 0 );
  -- Data for IP header
  signal ip_identification : unsigned( 15 downto 0 );
  -- Memory interface
  signal snd_addr : unsigned( 8 downto 0 );
  signal snd_data : std_logic_vector( 31 downto 0 );
  signal snd_we : std_logic_vector( 0 downto 0 );
  -- Store command values
  signal isend_eth_packet : std_logic;
  signal isend_arp_request : std_logic;
  signal isend_arp_reply : std_logic;
  signal isend_udp_packet : std_logic;

  -- Temporary checksum values
  signal ip_checksum1 : unsigned( 16 downto 0 );
  signal ip_checksum2 : unsigned( 16 downto 0 );

  -- State machine declarations
  type state_type is ( ready, udp_data, eth_data, raweth0, raweth1, raweth2,
  raweth3, arpreq0, arpreq1, arpreq2, arpreq3, arpreq4, arpreq5, arpreq6, udp0,
  udp1, udp2, udp3, udp4, udp5, udp6, send, waitack );
  signal state : state_type;

  -- TODO:
  -- * Compute the checksum (use the unsigned correctly)
  -- * Compute the number of dibits to be sent
  -- Move start of memory in dibit_sender and dibit_receiver to 16
  -- In higher level module, scramble the order of the data to make it readable
  -- Check the handshake with the dibit_sender
  -- Check the handshake with the higher level protocol
  -- Change command to send_packet and packet_type
  -- Add commands to write memory from outside

begin

  mem_addr <= std_logic_vector( snd_addr );
  mem_data <= snd_data;
  mem_we <= snd_we;
  number_of_dibits <= total_length & "00";

  process ( clock, reset ) begin
    if reset = '0' then
      state <= ready;
      done <= '0';
      ip_identification <= ( others => '1' );
      snd_addr <= ( others => '0' );
      snd_data <= ( others => '0' );
      snd_we <= "0";
      total_length <= ( others => '0' );
      ip_length <= ( others => '0' );
      udp_length <= ( others => '0' );
      ip_checksum1 <= ( others => '0' );
      ip_checksum2 <= ( others => '0' );
      send_frame <= '0';
      isend_eth_packet <= '0';
      isend_arp_request <= '0';
      isend_arp_reply <= '0';
      isend_udp_packet <= '0';
    elsif rising_edge( clock ) then
      -- When in writing mode, automatically increase memory address by one
      -- until we reach the send state
      if state /= ready and state /= send and state /= waitack then
        snd_addr <= snd_addr + 1;
      end if;

      case state is

        when ready =>
          done <= '0';
          -- Wait for a command to be issued
          if send_eth_packet = '1' or send_arp_request = '1' or send_arp_reply = '1' or send_udp_packet = '1' then
            isend_eth_packet <= send_eth_packet;
            isend_arp_request <= send_arp_request;
            isend_arp_reply <= send_arp_reply;
            isend_udp_packet <= send_udp_packet;
            state <= raweth0;
          elsif write_udp_data = '1' then
            -- UDP data starts at address 11
            snd_addr <= to_unsigned( 11 , 9 );
            snd_data <= user_data_in;
            snd_we <= "1";
            state <= udp_data;
          elsif write_eth_data = '1' then
            -- Raw ethernet data starts at address 4
            snd_addr <= to_unsigned( 4 , 9 );
            snd_data <= user_data_in;
            snd_we <= "1";
            state <= eth_data;
          end if;

        -- Keep writing until the request is released
        when udp_data =>
          snd_data <= user_data_in;
          if write_udp_data = '0' then
            snd_we <= "0";
            state <= ready;
          end if;
        when eth_data =>
          snd_data <= user_data_in;
          if write_eth_data = '0' then
            snd_we <= "0";
            state <= ready;
          end if;

        -- Store Ethernet frame header in memory
        when raweth0 =>
          -- Compute packet length for UDP datagrams
          ip_length <= packet_length + 28;
          udp_length <= packet_length + 8;
          ip_identification <= ip_identification + 1;
          -- Write packet data into memory
          snd_addr <= ( others => '0' );
          snd_data <= "0000000000000000" & destination_mac( 47 downto 32 );
          snd_we <= "1";
          -- Start computing the IP checksum
          ip_checksum1 <= unsigned( "0" & source_ip( 31 downto 16 ) ) + unsigned( "0" & source_ip( 15 downto 0 ) );
          ip_checksum2 <= unsigned( "0" & destination_ip( 31 downto 16 ) ) + unsigned( "0" & destination_ip( 15 downto 0 ) );
          state <= raweth1;
        when raweth1 =>
          snd_data <= destination_mac( 31 downto 0 );
          ip_checksum1 <= ( "0" & ip_checksum1( 15 downto 0 ) ) + ( "0" & ip_length ) + ( "0000000000000000" & ip_checksum1( 16 ) );
          ip_checksum2 <= ( "0" & ip_checksum2( 15 downto 0 ) ) + ( "0" & ip_identification ) + ( "0000000000000000" & ip_checksum2( 16 ) );
          state <= raweth2;
        when raweth2 =>
          snd_data <= source_mac( 47 downto 16 );
          ip_checksum1 <= ( "0" & ip_checksum1( 15 downto 0 ) ) + unsigned( "0" & IP_OFFSET ) + ( "0000000000000000" & ip_checksum1( 16 ) );
          ip_checksum2 <= ( "0" & ip_checksum2( 15 downto 0 ) ) + unsigned( "0" & IP_BASE_CHK ) + ( "0000000000000000" & ip_checksum2( 16 ) );
          state <= raweth3;
        when raweth3 =>
          if isend_arp_request = '1' or isend_arp_reply = '1' then
            snd_data <= source_mac( 15 downto 0 ) & ETH_TYPE_ARP;
            -- Compute packet total length in bytes. For ARP it is always 60 bytes
            total_length <= to_unsigned( 60, 11 );
            state <= arpreq0;
          elsif isend_udp_packet = '1' then
            snd_data <= source_mac( 15 downto 0 ) & ETH_TYPE_IP;
            -- Compute packet total length in bytes. For UDP it is the ip_length
            -- plus the ethernet header (14 bytes)
            total_length <= ip_length( 10 downto 0 ) + 14;
            state <= udp0;
          elsif isend_eth_packet = '1' then
            snd_data <= source_mac( 15 downto 0 ) & std_logic_vector( packet_length );
            -- Compute packet total length in bytes. For raw Ethernet we simply
            -- add the ethernet header length (14 bytes)
            total_length <= packet_length( 10 downto 0 ) + 14;
            state <= send;
          end if;
          ip_checksum1 <= ( "0" & ip_checksum1( 15 downto 0 ) ) + ( "0" & ip_checksum2( 15 downto 0 ) ) + ( "0000000000000000" & ip_checksum1( 16 ) ) + ( "0000000000000000" & ip_checksum2( 16 ) );

        -- Store the whole ARP message in memory
        when arpreq0 =>
          snd_data <= ARP_HW_TYPE & ARP_PROT;
          state <= arpreq1;
        when arpreq1 =>
          if isend_arp_request = '1' then  snd_data <= ARP_LEN & ARP_REQ;
          elsif isend_arp_reply = '1' then snd_data <= ARP_LEN & ARP_REP;
          end if;
          state <= arpreq2;
        when arpreq2 =>
          snd_data <= source_mac( 47 downto 16 );
          state <= arpreq3;
        when arpreq3 =>
          snd_data <= source_mac( 15 downto 0 ) & source_ip( 31 downto 16 );
          state <= arpreq4;
        when arpreq4 =>
          if isend_arp_request = '1' then  snd_data <= source_ip( 15 downto 0 ) & ARP_PADDING;
          elsif isend_arp_reply = '1' then snd_data <= source_ip( 15 downto 0 ) & destination_mac( 47 downto 32 );
          end if;
          state <= arpreq5;
        when arpreq5 =>
          if isend_arp_request = '1' then  snd_data <= ARP_PADDING & ARP_PADDING;
          elsif isend_arp_reply = '1' then snd_data <= destination_mac( 31 downto 0 );
          end if;
          state <= arpreq6;
        when arpreq6 =>
          snd_data <= destination_ip( 31 downto 0 );
          -- Should we add code for adding 0 padding? Not necessary, really. It
          -- would be 5 states... Useful if we don't want to send info from
          -- previous packets
          state <= send;

        -- Store the IP and UDP header in memory
        when udp0 =>
          snd_data <= IP_VER & std_logic_vector( ip_length );
          ip_checksum1 <= ( "0" & ip_checksum1( 15 downto 0 ) ) + ( "0000000000000000" & ip_checksum1( 16 ) );
          state <= udp1;
        when udp1 =>
          ip_checksum1 <= not ip_checksum1;
          snd_data <= std_logic_vector( ip_identification ) & IP_OFFSET;
          state <= udp2;
        when udp2 =>
          snd_data <= IP_TTL_PROT & std_logic_vector( ip_checksum1( 15 downto 0 ) );
          state <= udp3;
        when udp3 =>
          snd_data <= source_ip( 31 downto 0 );
          state <= udp4;
        when udp4 =>
          snd_data <= destination_ip( 31 downto 0 );
          state <= udp5;
        when udp5 =>
          snd_data <= source_port & destination_port;
          state <= udp6;
        when udp6 =>
          snd_data <= std_logic_vector( udp_length ) & UDP_CHECKSUM;
          state <= send;

        when send =>
          -- Do not write memory any more
          snd_we <= "0";
          -- Check if the dibit sender is available for sending. If not, stay
          -- in this state until it is
          if frame_acknowledge = '0' then
            -- Yes, we can request the frame to be sent
            send_frame <= '1';
            state <= waitack;
          end if;
        when waitack =>
          -- Wait for the frame to be sent, handle handshake
          if frame_acknowledge = '1' then
            send_frame <= '0';
            done <= '1';
            state <= ready;
          end if;

      end case;

    end if;

  end process;

end architecture;
