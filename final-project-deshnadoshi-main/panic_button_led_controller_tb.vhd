library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity panic_button_led_controller_tb is
end panic_button_led_controller_tb;

architecture Behavioral of panic_button_led_controller_tb is

    component panic_button_led_controller
        Port (
            clk : in std_logic;
            reset : in std_logic;
            panic_button_clicked : in std_logic;
            panic_override_mx_kypd : out std_logic;
            panic_lights : out std_logic_vector(2 downto 0);
            kypd_decode_in : in std_logic_vector(3 downto 0)
        );
    end component;

    -- Declare signals for testbench
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal panic_button_clicked : std_logic := '0';
    signal panic_override_mx_kypd : std_logic;
    signal panic_lights : std_logic_vector(2 downto 0);
    signal kypd_decode_in : std_logic_vector(3 downto 0);

begin
    -- Instantiate the unit under test
    UUT: panic_button_led_controller
        port map (
            clk => clk,
            reset => reset,
            panic_button_clicked => panic_button_clicked,
            panic_override_mx_kypd => panic_override_mx_kypd,
            panic_lights => panic_lights,
            kypd_decode_in => kypd_decode_in
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

        panic_button_clicked <= '0';
        wait for 10 ns; 
        -- Simulate entering incorrect password
        kypd_decode_in <= "0000";
        wait for 10 ns;
        kypd_decode_in <= "0001";
        wait for 10 ns;
        kypd_decode_in <= "0010";
        wait for 10 ns;
        kypd_decode_in <= "0011";
        wait for 10 ns;

        -- Simulate entering correct password
        kypd_decode_in <= "1010"; -- A
        wait for 10 ns;
        kypd_decode_in <= "1011"; -- B
        wait for 10 ns;
        kypd_decode_in <= "1111"; -- F
        wait for 10 ns;
        kypd_decode_in <= "0010"; -- default guest
        wait for 10 ns;

        -- Simulate panic button click
        panic_button_clicked <= '1';
        wait for 100 ns;
        panic_button_clicked <= '0';

        wait;
    end process;

end Behavioral;
