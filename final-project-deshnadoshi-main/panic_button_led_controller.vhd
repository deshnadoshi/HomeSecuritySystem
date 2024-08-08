----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/02/2024 06:44:44 AM
-- Design Name: 
-- Module Name: panic_button_led_controller - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity panic_button_led_controller is
  Port ( 
    clk : in std_logic;
    reset : in std_logic;
    panic_button_clicked : in std_logic; 
    panic_override_mx_kypd : out std_logic;
    panic_lights : out std_logic_vector(2 downto 0);
    kypd_decode_in : in std_logic_vector(3 downto 0)
  );
end panic_button_led_controller;

architecture Behavioral of panic_button_led_controller is

signal counter : std_logic_vector(26 downto 0) := (others => '0'); 

type state_type is (check_digit_1, check_digit_2, check_digit_3, check_digit_4, state_locked, state_unlocked); 
signal state: state_type := state_locked;

constant password_digit_1 : std_logic_vector(3 downto 0) := "1010"; -- A
constant password_digit_2 : std_logic_vector(3 downto 0) := "1011"; -- B
constant password_digit_3 : std_logic_vector(3 downto 0) := "1111"; -- F
constant password_digit_4 : std_logic_vector(3 downto 0) := "0010"; -- default guest 



begin

    process(clk)
    begin 
        if (rising_edge(clk)) then 
            if (reset = '1') then 
                counter <= (others => '0'); 
                panic_lights <= "000"; 
                state <= check_digit_1;
                
            elsif (panic_button_clicked = '1') then
                panic_override_mx_kypd <= '1'; 
                
                if (unsigned(counter) < 124999999) then
                    counter <= std_logic_vector(unsigned(counter) + 1);
                else
                    counter <= (others => '0');
                end if;
                                
                if (unsigned(counter) < 62500000) then
                    panic_lights <= "111";
                else
                    panic_lights <= "000";
                end if;

            else
                    case state is 
                        when check_digit_1 => 
                            if (kypd_decode_in = password_digit_1) then
                                panic_lights <= "000"; -- still an intruder
                                state <= check_digit_2; 
                            else 
                                panic_lights <= "000"; -- still an intruder
                                state <= state_locked;
                            end if; 
                        when check_digit_2 => 
                            if (kypd_decode_in = password_digit_2) then
                                panic_lights <= "000"; 
                                state <= check_digit_3; 
                            else 
                                panic_lights <= "111"; 
                                state <= state_locked;
                            end if; 
                        when check_digit_3 =>
                            if (kypd_decode_in = password_digit_3) then
                                panic_lights <= "000"; 
                                state <= check_digit_4; 
                            else 
                                panic_lights <= "111"; 
                                state <= state_locked;
                            end if; 
                        when check_digit_4 => 
                            if (kypd_decode_in = password_digit_4) then
                                panic_lights <= "000"; 
                                state <= state_unlocked; 
                            else 
                                panic_lights <= "111"; 
                                state <= state_locked;
                            end if; 
                        when state_unlocked =>
                            panic_lights <= "111"; -- override for panic button in more subtle way
                            state <= state_unlocked; 
                        when state_locked => 
                            panic_lights <= "000"; 
                            state <= check_digit_1; 
                    end case; 
            end if; 
            
        end if; 
    end process;
    
    

end Behavioral;
