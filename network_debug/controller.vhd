library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;

entity controller is port (
    sys_clock : in std_logic;
    reset : in std_logic;
    SW : inout std_logic_vector( 15 downto 0 )
);
end entity controller;

architecture behavioral of controller is 
    signal data_to_send_user : std_logic_vector(31 downto 0) := (others => '0');
    signal load_data_user : std_logic := '0';
    signal button_pressed : std_logic := '0';
    constant message_size_words : integer := 4;
    type data_array_type is array(0 to message_size_words - 1) of std_logic_vector(31 downto 0);
    signal data_array : data_array_type := (
        x"504F5243", -- 
        x"4F204449", -- 
        x"4F212121", -- 
        x"20202020"  -- 
    );
    signal data_index : integer range 0 to message_size_words := 0;
    type controller_state_type is (idle, loading_data, sending_data);
    signal controller_state : controller_state_type := idle;
    signal data_sent : std_logic := '0';
begin
    process(sys_clock, reset)
    begin
        if reset = '1' then
            data_to_send_user <= (others => '0');
            load_data_user <= '0';
            button_pressed <= '0';
        elsif rising_edge(sys_clock) then
            case controller_state is
                when idle =>
                    button_pressed <= '0';
                    if SW(15) = '1' then
                        if data_sent = '0' then
                            controller_state <= loading_data;
                        end if;
                    end if;
                when loading_data =>
                    if data_index < message_size_words then
                        data_to_send_user <= data_array(data_index);
                        load_data_user <= '1';
                        data_index <= data_index + 1;
                    elsif data_index = message_size_words then
                        controller_state <= sending_data;
                        load_data_user <= '0';
                    end if;
                when sending_data =>
                        button_pressed <= '1';
                        data_sent <= '1';
                        controller_state <= idle;
                        data_index <= 0;
            end case;
        end if;
    end process;
end architecture behavioral;