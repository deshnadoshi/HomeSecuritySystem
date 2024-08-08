----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/02/2024 10:26:55 AM
-- Design Name: 
-- Module Name: ssd_unlocker_controller - Behavioral
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

entity ssd_unlocker_controller is
  Port ( 
    clk : in std_logic;
    reset : in std_logic; 
    keypad_key : in std_logic_vector(3 downto 0); 
    setup_guest_key : in std_logic_vector(3 downto 0); -- this is the key that was set by the user 
    segment_out : out std_logic_vector(6 downto 0)
  
  );
end ssd_unlocker_controller;

architecture Behavioral of ssd_unlocker_controller is

begin

   
    process(clk)
    begin 
    
        
        if (rising_edge(clk)) then 
        segment_out <= "0000001"; 
        
            if (reset = '1') then 
                segment_out <= "0000001"; 
            else
                case keypad_key is 
                    when "1010" => 
                        -- A is for user 1
                        segment_out <= "1110111"; 
                    when "1011" => 
                        -- B is for user 2
                        segment_out <= "0011111"; 
                    when "1111" =>
                        -- F is for user 3
                        segment_out <= "1000111"; 
                    when others =>
                        if (unsigned(keypad_key) = unsigned(setup_guest_key)) then 
                            -- output 6 for guest
                            segment_out <= "1011111";
                        else
                            -- output 1 for intruder
                            segment_out <= "0110000"; 
                        end if; 
                    
                end case;
            end if; 

        end if;  
    end process; 


end Behavioral;
