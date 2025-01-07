library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;

entity controller is port (
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
    SW : inout std_logic_vector( 15 downto 0 );
    -- to seven segment displays
    CA, CB, CC, CD, CE, CF, CG, DP : out std_logic;
    AN : out std_logic_vector( 7 downto 0 );
    -- to start transmission, ARP message
    BTNC : in std_logic;
    -- to start transmission, UDP message
    BTND : in std_logic;
    -- to restart reception
    BTNU : in std_logic;

    --to retrieve data from memory
    mem_addr : out std_logic_vector( 9 downto 0 );
    mem_data : inout std_logic_vector( 31 downto 0 )
);
end entity controller;

architecture behavioral of controller is 
signal data_sent: std_logic := '0';
signal button_pressed: std_logic := '0';
signal load_enable: std_logic := '0';
constant message_size_words : integer := 4;
signal load_counter : integer range 0 to message_size_words := 0;
type state_type is (idle, loading, send);
signal state: state_type := idle;
type message_type is array( 0 to message_size_words - 1 ) of std_logic_vector( 31 downto 0 );
signal message_packet : message_type := (
    x"47524545", -- GREE
    x"54494e47", -- TING
    x"53205052", -- S PR
    x"4f464553" -- OFES
  );
  --signal user_data : std_logic_vector( 31 downto 0 ) := ( others => '0' );
  type addresses is array ( 0 to 5 ) of std_logic_vector( 9 downto 0 );
  signal addr : addresses := (
        "0000000010",
        "0000000011",
        "0000000100",
        "0000000101",
        "0000000110",
        "0000000111"
    );
begin
    network_top_inst: entity work.network_top
        port map (
            sys_clock => sys_clock,
            reset => reset,
            load_enable => load_enable,
            user_data => mem_data,
            ETH_CRSDV => ETH_CRSDV,
            ETH_RXERR => ETH_RXERR,
            ETH_RXD => ETH_RXD,
            ETH_REFCLK => ETH_REFCLK,
            ETH_TXEN => ETH_TXEN,
            ETH_TXD => ETH_TXD,
            LED => LED,
            SW => SW,
            CA => CA,
            CB => CB,
            CC => CC,
            CD => CD,
            CE => CE,
            CF => CF,
            CG => CG,
            DP => DP,
            AN => AN,
            BTNC => BTNC,
            BTND => BTND,
            BTNU => button_pressed
        );
    process(sys_clock, reset)
    begin
        if rising_edge ( sys_clock ) then
           case state is
            when idle =>
                button_pressed <= '0';
                if SW(15) = '1' and data_sent = '0' then
                    --Start loading the message packet from the memory
                    mem_addr <= addr(0);
                    load_counter <= 1;
                    state <= loading;
                elsif SW(15) = '0' and data_sent = '1' then
                    data_sent <= '0';  
                end if;
            when loading =>
                if load_counter < message_size_words then
                    load_enable <= '1';
                    --user_data <= message_packet(load_counter);
                    --This is probably wrong because the mem data is delayed by one clock cycle
                    mem_addr <= addr(load_counter);
                    --user_data <= mem_data(31 downto 0);
                    load_counter <= load_counter + 1;
                elsif load_counter = message_size_words then
                    state <= send;
                end if;
            when send =>
                load_enable <= '0';
                button_pressed <= '1';
                load_counter <= 0;
                data_sent <= '1';
                state <= idle;
           end case;
        end if;
    end process;
end architecture behavioral;