----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/05/2024 02:09:12 PM
-- Design Name: 
-- Module Name: kypd_decoder_tb - Behavioral
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

entity kypd_decoder_tb is
--  Port ( );
end kypd_decoder_tb;

architecture Behavioral of kypd_decoder_tb is

component kypd_decoder is
    Port (
		  clk : in  STD_LOGIC;
		  reset : in std_logic;
          row : in  STD_LOGIC_VECTOR (3 downto 0);
		  col : inout  STD_LOGIC_VECTOR (3 downto 0);
          decodeout : out  STD_LOGIC_VECTOR (3 downto 0));
end component;

    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal row : std_logic_vector(3 downto 0) := (others => '0');
    signal col : std_logic_vector(3 downto 0);
    signal decodeout : std_logic_vector(3 downto 0);

begin
    clk_process : process
    begin 
        wait for 4 ns; 
        clk <= '1'; 
        
        wait for 4 ns; 
        clk <= '0';
    end process clk_process; 

    stimulus_process : process
    begin
        -- Reset impulse
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 40 ms;
    end process stimulus_process;
    
    key_press_process : process
    begin 
        wait for 4 ms; 
        row <= "0111"; 
        
        wait for 4 ms; 
        row <= "1011"; 
        
        wait for 2 ms; 
        row <= "1110"; 
    end process; 
     
    

    dut : kypd_decoder
        port map (
            clk => clk,
            reset => reset,
            row => row,
            col => col,
            decodeout => decodeout
        );
end Behavioral;
