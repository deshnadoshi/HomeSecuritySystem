library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity load_passkey_tb is
end load_passkey_tb;

architecture Behavioral of load_passkey_tb is
    component load_passkey
        Port (
            clk : in std_logic;
            reset : in std_logic;
            switches : in std_logic_vector(3 downto 0);
            confirm_selection : in std_logic;
            valid_key_value : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Declare signals for testbench
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal switches : std_logic_vector(3 downto 0) := (others => '0');
    signal confirm_selection : std_logic := '0';
    signal valid_key_value : std_logic_vector(3 downto 0);

begin
    -- Instantiate the unit under test
    UUT: load_passkey
        port map (
            clk => clk,
            reset => reset,
            switches => switches,
            confirm_selection => confirm_selection,
            valid_key_value => valid_key_value
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
--        reset <= '1';
--        wait for 10 ns;
--        reset <= '0';

        -- Load new passkey value
        switches <= "1010"; -- Sample passkey value
        confirm_selection <= '1';
        wait for 10 ns;
        confirm_selection <= '0';
        wait for 10 ns; 
        
        reset <= '0'; 

        wait;
    end process;

end Behavioral;
