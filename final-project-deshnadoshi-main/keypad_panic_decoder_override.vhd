----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/05/2024 11:11:52 AM
-- Design Name: 
-- Module Name: keypad_panic_decoder_override - Behavioral
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

entity keypad_panic_decoder_override is
  Port ( 
    clk : in std_logic; 
    panic_btn_pressed : in std_logic; 
    rst : in std_logic; 
    kypd_decode_in : in std_logic_vector(3 downto 0); 
    panic_leds_out : out std_logic_vector(3 downto 0) -- leds controller
  );
end keypad_panic_decoder_override;

architecture Behavioral of keypad_panic_decoder_override is

type state_type is (check_digit_1, check_digit_2, check_digit_3, check_digit_4, state_locked, state_unlocked); 
signal state: state_type := state_locked;

constant password_digit_1 : std_logic_vector(3 downto 0) := "0011"; --3 
constant password_digit_2 : std_logic_vector(3 downto 0) := "0110"; --6
constant password_digit_3 : std_logic_vector(3 downto 0) := "0110"; --6
constant password_digit_4 : std_logic_vector(3 downto 0) := "0010"; --2


begin


    process(clk)
    begin 
            if (rising_edge(clk)) then 
            
                if (rst = '1') then 
                    state <= check_digit_1;
                    panic_leds_out <= "000"; 
                elsif (panic_btn_pressed = '0') then
                    case state is 
                        when check_digit_1 => 
                            if (kypd_decode_in = password_digit_1) then
                                panic_leds_out <= "000"; -- still an intruder
                                state <= check_digit_2; 
                            else 
                                panic_leds_out <= "000"; -- still an intruder
                                state <= state_locked;
                            end if; 
                        when check_digit_2 => 
                            if (kypd_decode_in = password_digit_2) then
                                panic_leds_out <= "000"; 
                                state <= check_digit_3; 
                            else 
                                panic_leds_out <= "000"; 
                                state <= state_locked;
                            end if; 
                        when check_digit_3 =>
                            if (kypd_decode_in = password_digit_3) then
                                panic_leds_out <= "000"; 
                                state <= check_digit_4; 
                            else 
                                panic_leds_out <= "000"; 
                                state <= state_locked;
                            end if; 
                        when check_digit_4 => 
                            if (kypd_decode_in = password_digit_4) then
                                panic_leds_out <= "000"; 
                                state <= state_unlocked; 
                            else 
                                panic_leds_out <= "000"; 
                                state <= state_locked;
                            end if; 
                        when state_unlocked =>
                            panic_leds_out <= "111"; -- override for panic button in more subtle way
                            state <= state_unlocked; 
                        when state_locked => 
                            panic_leds_out <= "000"; 
                            state <= check_digit_1; 
                    end case; 
                        
                end if; 
        
        end if; 

    end process; 


end Behavioral;
