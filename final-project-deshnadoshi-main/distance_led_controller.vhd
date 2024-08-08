----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/01/2024 01:48:15 PM
-- Design Name: 
-- Module Name: distance_led_controller - Behavioral
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

entity distance_led_controller is
  Port ( 
    clk : in std_logic; 
    distance_maxsonar_pmod : in std_logic_vector(7 downto 0); 
    within_ten_in : out std_logic    
  );
end distance_led_controller;

architecture Behavioral of distance_led_controller is

begin

    process(clk) 
    begin 
        if (rising_edge(clk)) then 
            if (unsigned(distance_maxsonar_pmod) <= "00001010") then 
                within_ten_in <= '1'; 
            else 
                within_ten_in <= '0'; 
            end if; 
        end if; 
    end process; 


end Behavioral;