----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/01/2024 03:05:07 PM
-- Design Name: 
-- Module Name: kypd_maxsonar_interface - Behavioral
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

entity kypd_maxsonar_interface is
  Port ( 
    clk : in std_logic; 
    reset : in std_logic; 
    kypd_locked : in std_logic;
    maxsonar_light : in std_logic; 
    panic_override : in std_logic;
    precedence_led : out std_logic
  
  );
end kypd_maxsonar_interface;

architecture Behavioral of kypd_maxsonar_interface is

begin

    process(clk)
    begin 
        if (rising_edge(clk)) then 
        -- when we're within 10 inches and when the keypad is locked
--            if (panic_override = '0') then 
                if (reset = '1') then 
                    precedence_led <= maxsonar_light; 
                else 
                    if (kypd_locked = '1' AND maxsonar_light = '1') then 
                        precedence_led <= maxsonar_light; 
                    elsif (maxsonar_light = '1' AND kypd_locked = '0') then 
                        precedence_led <= '0'; 
                    elsif (maxsonar_light = '0') then 
                        precedence_led <= maxsonar_light;                 
                    end if; 
                end if; 
--              end if; 
            
        end if; 
    end process; 


end Behavioral;