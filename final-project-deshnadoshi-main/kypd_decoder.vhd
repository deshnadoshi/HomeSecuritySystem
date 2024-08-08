----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/01/2024 11:36:55 AM
-- Design Name: 
-- Module Name: kypd_decoder - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity kypd_decoder is
    Port (
		  clk : in  STD_LOGIC;
		  reset : in std_logic;
          row : in  STD_LOGIC_VECTOR (3 downto 0);
		  col : out  STD_LOGIC_VECTOR (3 downto 0);
          decodeout : out  STD_LOGIC_VECTOR (3 downto 0));
end kypd_decoder;

architecture Behavioral of kypd_decoder is

signal counter :STD_LOGIC_VECTOR(19 downto 0);
begin
	process(clk)
		begin 
		if clk'event and clk = '1' then
		
		  if (reset = '1') then 
		      decodeout <= "0000"; 
		  end if; 
			-- 1ms
			if counter = "00011000011010100000" then 
				--C1
				col<= "0111";
				counter <= counter+1;
			-- check row pins
			elsif counter = "00011000011010101000" then	
				--R1
				if row = "0111" then
					decodeout <= "0001";	--1
				--R2
				elsif row = "1011" then
					decodeout <= "0100"; --4
				--R3
				elsif row = "1101" then
					decodeout <= "0111"; --7
				--R4
				elsif row = "1110" then
					decodeout <= "0000"; --0
				end if;
				counter <= counter+1;
			-- 2ms
			elsif counter = "00110000110101000000" then	
				--C2
				col<= "1011";
				counter <= counter+1;
			-- check row pins
			elsif counter = "00110000110101001000" then	
				--R1
				if row = "0111" then		
					decodeout <= "0010"; --2
				--R2
				elsif row = "1011" then
					decodeout <= "0101"; --5
				--R3
				elsif row = "1101" then
					decodeout <= "1000"; --8
				--R4
				elsif row = "1110" then
					decodeout <= "1111"; --F
				end if;
				counter <= counter+1;	
			--3ms
			elsif counter = "01001001001111100000" then 
				--C3
				col<= "1101";
				counter <= counter+1;
			-- check row pins
			elsif counter = "01001001001111101000" then 
				--R1
				if row = "0111" then
					decodeout <= "0011"; --3	
				--R2
				elsif row = "1011" then
					decodeout <= "0110"; --6
				--R3
				elsif row = "1101" then
					decodeout <= "1001"; --9
				--R4
				elsif row = "1110" then
					decodeout <= "1110"; --E
				end if;
				counter <= counter+1;
			--4ms
			elsif counter = "01100001101010000000" then 			
				--C4
				col<= "1110";
				counter <= counter+1;
			-- check row pins
			elsif counter = "01100001101010001000" then 
				--R1
				if row = "0111" then
					decodeout <= "1010"; --A
				--R2
				elsif row = "1011" then
					decodeout <= "1011"; --B
				--R3
				elsif row = "1101" then
					decodeout <= "1100"; --C
				--R4
				elsif row = "1110" then
					decodeout <= "1101"; --D
				end if;
				counter <= "00000000000000000000";	
			else
				counter <= counter+1;	
			end if;
		end if;
	end process;
		
		
						 
end Behavioral;
