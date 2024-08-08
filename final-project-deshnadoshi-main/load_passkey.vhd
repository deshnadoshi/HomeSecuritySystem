----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/01/2024 08:45:43 PM
-- Design Name: 
-- Module Name: load_passkey - Behavioral
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

entity load_passkey is
  Port ( 
    clk : in std_logic;
    reset : in std_logic;
    switches : in std_logic_vector(3 downto 0); -- setting the value to what is meant to be entered
    confirm_selection : in std_logic; -- button press to load value
    valid_key_value : out std_logic_vector(3 downto 0)
  );
end load_passkey;

architecture Behavioral of load_passkey is

begin

    process(clk)
    begin 
        if (rising_edge(clk)) then 
            if (reset = '1') then 
                valid_key_value <= "1111"; 
            elsif (confirm_selection = '1') then 
                valid_key_value <= switches; 
            end if; 
        
        end if; 
    end process; 

end Behavioral;
