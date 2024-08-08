----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/01/2024 02:52:04 PM
-- Design Name: 
-- Module Name: maxsonar_kypd_top_level - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity maxsonar_kypd_top_level is
  Port ( 
    clk : in std_logic; 
    JA: inout std_logic_vector(7 downto 0); 
    led : out std_logic; 
    analog, rx, tx : out std_logic; 
    pwm : in std_logic; 
    reset : in std_logic; -- button 0 to reset
    sw : in std_logic_vector(3 downto 0); 
    passkey_btn : in std_logic; -- button 1 to load passkey
    panic_leds : out std_logic_vector(2 downto 0); -- to light up when panic button is pressed
    panic_btn : in std_logic -- panic button 3 to be pressed
  
  );
end maxsonar_kypd_top_level;

architecture Behavioral of maxsonar_kypd_top_level is

    component kypd_decoder is
        Port (
            clk : in  STD_LOGIC;
            reset : in std_logic; 
            Row : in  STD_LOGIC_VECTOR (3 downto 0);
            Col : out  STD_LOGIC_VECTOR (3 downto 0);
            DecodeOut : out  STD_LOGIC_VECTOR (3 downto 0));
    end component;

    component kypd_led_controller is 
        port (
            clk : in std_logic; 
            locked : out std_logic; 
            updated_passkey : in std_logic_vector(3 downto 0); 
            decode_in : in std_logic_vector(3 downto 0)
        ); 
    end component; 

    component pmod_maxsonar is
    port (
        clk       : IN   STD_LOGIC;                     --system clock
        reset_n   : IN   STD_LOGIC;                     --asynchronous active-HIGH reset (modified to follow the rest of the code)
        sensor_pw : IN   STD_LOGIC;                     --pulse width (PW) input from ultrasonic range finder
        distance  : OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) --binary distance output (inches)
    ); 
    end component; 
    
    component distance_led_controller is 
    port (
        clk : in std_logic; 
        distance_maxsonar_pmod : in std_logic_vector(7 downto 0); 
        within_ten_in : out std_logic    
    ); 
    end component;  
    
    component kypd_maxsonar_interface is 
    port (
        clk : in std_logic; 
        reset : in std_logic; 
        kypd_locked : in std_logic;
        maxsonar_light : in std_logic; 
        panic_override : in std_logic;
        precedence_led : out std_logic
    ); 
    end component; 
    
    component load_passkey is 
    port (
        clk : in std_logic;
        reset : in std_logic;
        switches : in std_logic_vector(3 downto 0); -- setting the value to what is meant to be entered
        confirm_selection : in std_logic; -- button press to load value
        valid_key_value : out std_logic_vector(3 downto 0)
    ); 
    end component; 
    
    component debounce is 
    port (
        clk : in std_logic; 
        btn : in std_logic; 
        dbnc : out std_logic
    ); 
    end component; 
    
    component panic_button_led_controller is 
    port (
        clk : in std_logic;
        reset : in std_logic;
        panic_button_clicked : in std_logic; 
        panic_override_mx_kypd : out std_logic;
        panic_lights : out std_logic_vector(2 downto 0)
    ); 
    end component; 
    
    signal Decode: STD_LOGIC_VECTOR (3 downto 0);
    signal top_distance : std_logic_vector(7 downto 0);  
    signal kypd_lock : std_logic; 
    signal maxsonar_lock : std_logic; 
    signal new_passkey : std_logic_vector(3 downto 0); 
    signal dbnc_passkey_btn : std_logic; 
    signal dbnc_reset_btn : std_logic; 
    signal dbnc_panic_btn : std_logic; 
    signal panic_led_controller_override : std_logic;

begin

    u1: pmod_maxsonar
    port map (
        clk => clk, 
        reset_n => dbnc_reset_btn,
        sensor_pw => pwm,
        distance => top_distance
        
    ); 
    
    u2: distance_led_controller
    port map (
        clk => clk, 
        distance_maxsonar_pmod => top_distance, 
        within_ten_in => maxsonar_lock
    ); 
    
    rx <= '1'; 

    u3 : kypd_decoder
        port map(
            clk => clk,
            reset => dbnc_reset_btn,
            Row => JA(7 downto 4),
            Col => JA(3 downto 0),
            DecodeOut => Decode
        );
        
     u4 : kypd_led_controller 
     port map (
        clk => clk, 
        locked => kypd_lock, 
        updated_passkey => new_passkey,
        decode_in => Decode
     ); 
     
     u5 : kypd_maxsonar_interface
     port map (
        clk => clk, 
        reset => dbnc_reset_btn,
        kypd_locked => kypd_lock,
        maxsonar_light => maxsonar_lock, 
        panic_override => panic_led_controller_override,
        precedence_led => led
    
     ); 

    u6 : load_passkey
    port map (
        clk => clk,
        reset => dbnc_reset_btn,
        switches => sw, 
        confirm_selection => dbnc_passkey_btn,
        valid_key_value => new_passkey

    ); 
    
    u7 : debounce
    port map (
        clk => clk,
        btn => passkey_btn,
        dbnc => dbnc_passkey_btn
    ); 
    
    u8 : debounce 
    port map (
        clk => clk,
        btn => reset,
        dbnc => dbnc_reset_btn
    ); 
    
    u9 : panic_button_led_controller
    port map (
        clk => clk,
        reset => dbnc_reset_btn,
        panic_button_clicked => dbnc_panic_btn,
        panic_override_mx_kypd => panic_led_controller_override,
        panic_lights => panic_leds
    ); 

    
    u10 : debounce 
    port map (
        clk => clk,
        btn => panic_btn,
        dbnc => dbnc_panic_btn
    );

end Behavioral;