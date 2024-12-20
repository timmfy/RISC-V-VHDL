library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;

entity dibit_sender is
  port (
    clock50, reset : in std_logic;
    -- Send command from upper layer
    send_frame : in std_logic;
    number_of_dibits : in unsigned( 12 downto 0 );
    -- Send acknowledge to upper layer
    frame_acknowledge : out std_logic;
    -- Ethernet side connections
    ETH_TXEN : out std_logic;
    ETH_TXD : out std_logic_vector( 1 downto 0 );
    -- Memory interface signals
    read_address : out std_logic_vector( 12 downto 0 );
    read_data : in std_logic_vector( 1 downto 0 )
  );
end dibit_sender;

architecture behavioral of dibit_sender is

  -- Define a state machine to write the data
  type state_type is ( ready, preamble, sfd, send_data, send_last, send_fcs, interframe, ack );
  signal state : state_type;

  -- Preamble counter
  signal preamble_counter : unsigned( 4 downto 0 );
  signal preamble_counter_init, preamble_counter_enable, preamble_counter_tc : std_logic;
  -- Address counter
  signal address_counter : unsigned( 12 downto 0 );
  signal address_counter_init, address_counter_enable, address_counter_tc : std_logic;
  -- CRC counter
  signal crc_counter : unsigned( 3 downto 0 );
  signal crc_counter_init, crc_counter_enable, crc_counter_tc : std_logic;
  -- IFG counter
  signal ifg_counter : unsigned( 5 downto 0 );
  signal ifg_counter_init, ifg_counter_enable, ifg_counter_tc : std_logic;

  -- CRC computation
  signal crc_init, crc_valid, crc_compute : std_logic;
  signal crc_dibit : std_logic_vector( 1 downto 0 );

begin

  -- Route the counter to the address of the memory
  read_address <= std_logic_vector( address_counter );

  -- State machine sequential process
  process ( clock50, reset ) begin
    if reset = '0' then
      state <= ready;
      frame_acknowledge <= '0';
    elsif rising_edge( clock50 ) then
      case state is
        -- Wait for the send signal
        when ready => if send_frame = '1' then state <= preamble; end if;
        -- Check the end of the preamble
        when preamble => if preamble_counter_tc = '1' then state <= sfd; end if;
        when sfd => state <= send_data;
        -- Check the end of the packet
        when send_data => if address_counter_tc = '1' then state <= send_last; end if;
        -- Send the last dibit (memory has a one-cycle latency)
        when send_last => state <= send_fcs;
        -- Send the bits from the CRC
        when send_fcs => if crc_counter_tc = '1' then state <= interframe; frame_acknowledge <= '1'; end if;
        -- Wait for the interframe gap to expire (96 bits, 48 dibits, 12 bytes)
        when interframe => if ifg_counter_tc = '1' then state <= ack; end if;
        -- Wait for send_frame to go back down to 0
        when ack => if send_frame = '0' then state <= ready; frame_acknowledge <= '0'; end if;
      end case;
    end if;
  end process;

  process ( state, read_data, crc_dibit ) begin
    -- By default, counters don't do anything
    preamble_counter_init <= '0';
    preamble_counter_enable <= '0';
    address_counter_init <= '0';
    address_counter_enable <= '0';
    crc_counter_init <= '0';
    crc_counter_enable <= '0';
    ifg_counter_init <= '0';
    ifg_counter_enable <= '0';
    -- Defaults for CRC computation
    crc_init <= '0';
    crc_compute <= '0';
    crc_valid <= '0';
    -- By default we don't send anything on the PHY
    ETH_TXEN <= '0';
    ETH_TXD <= "00";

    case state is

      when ready =>
        -- Initialize the counters
        preamble_counter_init <= '1';
        crc_counter_init <= '1';
        ifg_counter_init <= '1';
        -- Initialize the address counter, also automatically update the length
        -- of the packet to be sent inside the counter
        address_counter_init <= '1';

      when preamble =>
        -- Send the preamble bits
        ETH_TXEN <= '1';
        ETH_TXD <= "01";
        -- Activate the preamble counter
        preamble_counter_enable <= '1';

      when sfd =>
        -- Send the SFD
        ETH_TXEN <= '1';
        ETH_TXD <= "11";
        -- Memory has a one-cycle latency, so we start reading the first dibit
        -- now. Hence, we must also enable the address counter
        address_counter_enable <= '1';

      when send_data =>
        -- Send the data from memory
        ETH_TXEN <= '1';
        ETH_TXD <= read_data;
        -- Activate the address counter
        address_counter_enable <= '1';
        -- Include these bits in CRC computation
        crc_compute <= '1';

      when send_last =>
        -- Send the last dibit
        ETH_TXEN <= '1';
        ETH_TXD <= read_data;
        -- Include these bits in CRC computation
        crc_compute <= '1';

      when send_fcs =>
        -- Send the bits from the CRC
        ETH_TXEN <= '1';
        ETH_TXD( 0 ) <= crc_dibit( 0 );
        ETH_TXD( 1 ) <= crc_dibit( 1 );
        crc_valid <= '1';
        -- Activate the CRC counter
        crc_counter_enable <= '1';

      when interframe =>
        -- Activate the interframe counter
        ifg_counter_enable <= '1';
        -- We are not transmitting at this point, so all other signals are at
        -- the default values

      when others =>
        ETH_TXEN <= '0';

    end case;

  end process;

  -- Instantiate the CRC computation block
  compute_CRC : entity work.CRC32_2( behavioral ) port map (
    clock => clock50,
    reset => reset,
    crc => crc_dibit,
    d => read_data,
    calc => crc_compute,
    init => crc_init,
    d_valid => crc_valid
  );

  -- Instantiate the preamble counter
  PR_counter : entity work.modulo_counter( behavioral ) generic map (
    size => 5,
    modulo => 30
  ) port map (
    clock => clock50,
    reset => reset,
    counter_init => preamble_counter_init,
    counter_enable => preamble_counter_enable,
    count => preamble_counter,
    counter_tc => preamble_counter_tc
  );
  -- Instantiate the address counter
  AD_counter : entity work.scaled_counter( behavioral ) generic map (
    size => 13,
    init_value => 8
  ) port map (
    clock => clock50,
    reset => reset,
    counter_init => address_counter_init,
    counter_enable => address_counter_enable,
    count => address_counter,
    modulo => number_of_dibits,
    counter_tc => address_counter_tc
  );
  -- Instantiate the CRC counter
  CRC_cntr : entity work.modulo_counter( behavioral ) generic map (
    size => 4,
    modulo => 15
  ) port map (
    clock => clock50,
    reset => reset,
    counter_init => crc_counter_init,
    counter_enable => crc_counter_enable,
    count => crc_counter,
    counter_tc => crc_counter_tc
  );
  -- Instantiate the interframe gap counter
  IFG_cntr : entity work.modulo_counter( behavioral ) generic map (
    size => 6,
    modulo => 48
  ) port map (
    clock => clock50,
    reset => reset,
    counter_init => ifg_counter_init,
    counter_enable => ifg_counter_enable,
    count => ifg_counter,
    counter_tc => ifg_counter_tc
  );

end behavioral;
