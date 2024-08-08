----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/05/2024 12:46:11 PM
-- Design Name: 
-- Module Name: mksv_top_level_tb - Behavioral
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

entity mksv_top_level_tb is
--  Port ( );
end mksv_top_level_tb;

architecture Behavioral of mksv_top_level_tb is

component maxsonar_kypd_ssd_vga_top_level is
  Port ( 
    clk : in std_logic; 
    vga_hs, vga_vs : out std_logic;
    vga_r, vga_b : out std_logic_vector(4 downto 0);
    vga_g : out std_logic_vector(5 downto 0); 
    JA: inout std_logic_vector(7 downto 0); 
    led : out std_logic; 
    analog, rx, tx : out std_logic; 
    pwm : in std_logic; 
    rst : in std_logic; 
    sw : in std_logic_vector(3 downto 0); 
    passkey_btn : in std_logic; 
    panic_leds : out std_logic_vector(2 downto 0); 
    panic_btn : in std_logic; 
    seg : out std_logic_vector(6 downto 0);
    an : out std_logic; 
    segment_btn : in std_logic 
  );
end component;


    -- Signals for inputs
    signal clk : std_logic := '0';
    signal pwm : std_logic := '0';
    signal rst : std_logic := '0';
    signal sw : std_logic_vector(3 downto 0) := "0000";
    signal passkey_btn : std_logic := '0';
    signal panic_btn : std_logic := '0';
    signal segment_btn : std_logic := '0';
    
    -- Signals for outputs
    signal vga_hs, vga_vs : std_logic;
    signal vga_r, vga_b : std_logic_vector(4 downto 0);
    signal vga_g : std_logic_vector(5 downto 0);
    signal JA: std_logic_vector(7 downto 0);
    signal led : std_logic;
    signal analog, rx, tx : std_logic;
    signal panic_leds : std_logic_vector(2 downto 0);
    signal seg : std_logic_vector(6 downto 0);
    signal an : std_logic;

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
    
        -- Reset impulse to clear all the values
--        rst <= '1';
        rst <= '1';
        wait for 20 ms;
        rst <= '0';
        wait for 100 ms;
    
--        rst <= '0';
--        wait for 10 ns; 
        
        -- Sending 10 inch pulses for MAXSONAR
        pwm <= '1'; -- 1 in
        wait for 148 us;
        pwm <= '1'; -- 2 in
        wait for 148 us;
        pwm <= '1'; -- 3 in
        wait for 148 us;
        pwm <= '1'; -- 4 in
        wait for 148 us;
        pwm <= '1'; -- 5 in
        wait for 148 us;
        pwm <= '1'; -- 6 in
        wait for 148 us;
        pwm <= '1'; -- 7 in
        wait for 148 us;
        pwm <= '1'; -- 8 in
        wait for 148 us;
        pwm <= '1'; -- 9 in
        
        -- Output: led0 should turn on. 
        
        -- Sending a built-in key to turn led0 off
        wait for 20 ms; 
        JA(7 downto 4) <= "0111"; 
        
        wait for 10 ms; 
        JA(7 downto 4) <= "1011"; 
        
        wait for 10 ms; 
        JA(7 downto 4) <= "1110"; 
        -- Output: led0 should turn off. 
        -- End the PWM pulses for MAXSONAR
        wait for 100 ms;
        pwm <= '0';
        
    end process stimulus_process; 
        
    rst_process : process
    begin
        -- Reset impulse
    end process rst_process;
            
    dut: maxsonar_kypd_ssd_vga_top_level
        port map (
            clk => clk,
            pwm => pwm,
            rst => rst,
            sw => sw,
            passkey_btn => passkey_btn,
            panic_btn => panic_btn,
            segment_btn => segment_btn,
            vga_hs => vga_hs,
            vga_vs => vga_vs,
            vga_r => vga_r,
            vga_b => vga_b,
            vga_g => vga_g,
            JA => JA,
            led => led,
            analog => analog,
            rx => rx,
            tx => tx,
            panic_leds => panic_leds,
            seg => seg,
            an => an
        );
end Behavioral;
