library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.ALL;

entity dibit_receiver is
  port (
    clock50, reset : in std_logic;
    -- Read acknowledge from upper layer
    acknowledge : in std_logic;
    -- Data ready signal
    packet_ready : out std_logic;
    -- Ethernet side connections
    ETH_CRSDV : in std_logic;
    ETH_RXERR : in std_logic;
    ETH_RXD : in std_logic_vector( 1 downto 0 );
    write_enable : out std_logic_vector( 0 downto 0 );
    write_address : out std_logic_vector( 12 downto 0 );
    write_data : out std_logic_vector( 1 downto 0 )
  );
end dibit_receiver;

architecture behavioral of dibit_receiver is

  -- Define a state machine to read the data
  type state_type is ( ready, preamble, read, waitack0, done );
  signal state, nstate : state_type;
  signal ipacket_ready, npacket_ready : std_logic;

  -- Address counter
  signal address_counter : unsigned( 12 downto 0 );
  signal address_counter_init, address_counter_enable, address_counter_tc : std_logic;
  
begin

  -- Instantiate the address counter
  AD_counter : entity work.modulo_counter( behavioral ) generic map (
    size => 13,
    modulo => 8191,
    init_value => 8
  ) port map (
    clock => clock50,
    reset => reset,
    counter_init => address_counter_init,
    counter_enable => address_counter_enable,
    count => address_counter,
    counter_tc => address_counter_tc
  );

  -- Connect the outputs
  packet_ready <= ipacket_ready;

  -- State machine sequential process
  process ( clock50, reset ) begin
    if reset = '0' then
      state <= ready;
      ipacket_ready <= '0';
    elsif rising_edge( clock50 ) then
      state <= nstate;
      ipacket_ready <= npacket_ready;
    end if;
  end process;

  -- next state and output process
  process ( state, ETH_CRSDV, ETH_RXD, address_counter, acknowledge, ipacket_ready ) begin
    -- By default the state remains the same
    nstate <= state;
    npacket_ready <= ipacket_ready;

    -- By default we don't write in the memory
    write_enable <= "0";
    -- By default, and this likely won't change, we write the values from
    -- the Ethernet PHY into the address pointed to by our counter
    write_data <= ETH_RXD;
    write_address <= std_logic_vector( address_counter );

    -- Defaults for the counter
    address_counter_init <= '0';
    address_counter_enable <= '0';

    case state is

      -- Wait for Data Valid to be asserted
      when ready =>
        -- Reset the address counter
        address_counter_init <= '1';
        -- wait for DV to go up
        if ETH_CRSDV = '1' then
          nstate <= preamble;
        end if;

      -- Wait for preamble bits
      when preamble =>
        -- First check if data is still valid
        if ETH_CRSDV = '1' then
          -- It is valid, check the value
          if ETH_RXD = "00" then
            -- Skip initial 00 values
            nstate <= preamble;
          elsif ETH_RXD = "01" then
            -- This is the preamble, keep reading, don't save the data
            nstate <= preamble;
          elsif ETH_RXD = "10" then
            -- This is a false carrier detect, abort reading, go back to ready
            nstate <= ready;
          elsif ETH_RXD = "11" then
            -- We have found the Start Frame Delimiter, go to reading
            nstate <= read;
          end if;
        else
          -- Lost carrier, abort and go back to ready state
          nstate <= ready;
        end if;

      when read =>
        -- Keep reading values and write them into the memory as long as DV
        -- is valid
        write_enable <= "1";
        -- Enable the address counter, so that we will write to a new
        -- location next time around
        address_counter_enable <= '1';
        -- Check the valid signal
        if ETH_CRSDV = '0' then
          -- Packet has ended, go to the idle state
          nstate <= waitack0;
        end if;

      when waitack0 =>
        -- Wait for the acknowledge to be deasserted, before we assert
        -- packet_ready
        if acknowledge = '0' then
          nstate <= done;
          npacket_ready <= '1';
        end if;

      when done =>
        -- Wait for ack to be asserted
        if acknowledge = '1' then
          nstate <= ready;
          npacket_ready <= '0';
        end if;

    end case;

  end process;

end behavioral;
