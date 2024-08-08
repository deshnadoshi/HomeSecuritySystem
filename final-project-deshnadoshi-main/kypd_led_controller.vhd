----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/01/2024 01:08:07 PM
-- Design Name: 
-- Module Name: kypd_led_controller - Behavioral
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

entity kypd_led_controller is
  Port (
    clk : in std_logic; 
    reset : in std_logic; 
    locked : out std_logic; 
    updated_passkey : in std_logic_vector(3 downto 0); 
    decode_in : in std_logic_vector(3 downto 0)
   );
end kypd_led_controller;

architecture Behavioral of kypd_led_controller is

begin


    process(clk)
    begin 
        if (rising_edge(clk)) then 
            if (reset = '1') then 
                locked <= '1'; -- it is locked, turn the led on 
            else 
        
                if (unsigned(decode_in) = unsigned(updated_passkey)) then 
                    locked <= '0'; -- led turned off, locked is false
                elsif ((unsigned(decode_in) = "1010") OR (unsigned(decode_in) = "1011") OR (unsigned(decode_in) = "1111")) then 
                    -- for the "residents" of the home, they have their own default keys  
                    -- A, C, F are all valid lock openers.               
                    locked <= '0'; 
                else 
                    locked <= '1'; -- is turned on, locked is true
               end if; 
           
           end if; 
        end if; 
    
    end process; 

end Behavioral;