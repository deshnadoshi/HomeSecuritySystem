library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ssd_unlocker_controller_tb is
end ssd_unlocker_controller_tb;

architecture Behavioral of ssd_unlocker_controller_tb is
    component ssd_unlocker_controller
        Port (
            clk : in std_logic;
            reset : in std_logic;
            keypad_key : in std_logic_vector(3 downto 0);
            setup_guest_key : in std_logic_vector(3 downto 0);
            segment_out : out std_logic_vector(6 downto 0)
        );
    end component;

    -- Declare signals for testbench
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal keypad_key : std_logic_vector(3 downto 0) := (others => '0');
    signal setup_guest_key : std_logic_vector(3 downto 0) := "0000"; -- Initialize to default
    signal segment_out : std_logic_vector(6 downto 0);

begin
    dut: ssd_unlocker_controller
        port map (
            clk => clk,
            reset => reset,
            keypad_key => keypad_key,
            setup_guest_key => setup_guest_key,
            segment_out => segment_out
        );

    -- Clock process
    clk_process: process
    begin
        wait for 4 ns; 
        clk <= '1'; 
        wait for 4 ns; 
        clk <= '0'; 
    end process;

    -- Stimulus process
    stimulus_process: process
    begin
        -- Reset the unit
        reset <= '1';
        wait for 10 ns;
        reset <= '0';

        keypad_key <= "1010"; -- Simulate input for user 1
        wait for 10 ns;
        keypad_key <= "1011"; -- Simulate input for user 2
        wait for 10 ns;
        keypad_key <= "1111"; -- Simulate input for user 3
        wait for 10 ns;

        -- Simulate input for guest
        setup_guest_key <= "0101"; -- Set guest key
        keypad_key <= "0101"; -- Simulate input for guest
        wait for 10 ns;

        -- Simulate invalid input
        keypad_key <= "1001"; -- Simulate invalid input
        wait for 10 ns;

        wait;
    end process;

end Behavioral;
