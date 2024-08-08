----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/01/2024 02:52:04 PM
-- Design Name: 
-- Module Name: maxsonar_kypd_top_level - Behavioral
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

entity maxsonar_kypd_ssd_vga_top_level is
  Port ( 
    clk : in std_logic; 

    vga_hs, vga_vs : out std_logic;
    vga_r, vga_b : out std_logic_vector(4 downto 0);
    vga_g : out std_logic_vector(5 downto 0); 
    
    JA: inout std_logic_vector(7 downto 0); 
    led : out std_logic; 
    analog, rx, tx : out std_logic; 
    pwm : in std_logic; 
    rst : in std_logic; -- button 0 to reset
    sw : in std_logic_vector(3 downto 0); 
    passkey_btn : in std_logic; -- button 1 to load passkey
    panic_leds : out std_logic_vector(2 downto 0); -- to light up when panic button is pressed
    panic_btn : in std_logic; -- panic button 3 to be pressed
    seg : out std_logic_vector(6 downto 0);
    an : out std_logic; 
    segment_btn : in std_logic 
    

  );
end maxsonar_kypd_ssd_vga_top_level;

architecture Behavioral of maxsonar_kypd_ssd_vga_top_level is

    component kypd_decoder is
        Port (
            clk : in  STD_LOGIC;
            reset : in std_logic; 
            row : in  STD_LOGIC_VECTOR (3 downto 0);
            col : out  STD_LOGIC_VECTOR (3 downto 0);
            decodeout : inout  STD_LOGIC_VECTOR (3 downto 0));
    end component;

    component kypd_led_controller is 
        port (
            clk : in std_logic; 
            reset : in std_logic; 
            locked : out std_logic; 
            updated_passkey : in std_logic_vector(3 downto 0); 
            decode_in : in std_logic_vector(3 downto 0)
        ); 
    end component; 

    component pmod_maxsonar is
    port (
        clk       : IN   STD_LOGIC;                     --system clock
        reset_n   : IN   STD_LOGIC;                     --asynchronous active-HIGH reset (modified to follow the rest of the code)
        sensor_pw : IN   STD_LOGIC;                     --pulse width (PW) input from ultrasonic range finder
        distance  : OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) --binary distance output (inches)
    ); 
    end component; 
    
    component distance_led_controller is 
    port (
        clk : in std_logic; 
        distance_maxsonar_pmod : in std_logic_vector(7 downto 0); 
        within_ten_in : out std_logic    
    ); 
    end component;  
    
    component kypd_maxsonar_interface is 
    port (
        clk : in std_logic; 
        reset :  in std_logic; 
        kypd_locked : in std_logic;
        maxsonar_light : in std_logic; 
        panic_override : in std_logic;
        precedence_led : out std_logic
    ); 
    end component; 
    
    component load_passkey is 
    port (
        clk : in std_logic;
        reset : in std_logic;
        switches : in std_logic_vector(3 downto 0); -- setting the value to what is meant to be entered
        confirm_selection : in std_logic; -- button press to load value
        valid_key_value : out std_logic_vector(3 downto 0)
    ); 
    end component; 
    
    component debounce is 
    port (
        clk : in std_logic; 
        btn : in std_logic; 
        dbnc : out std_logic
    ); 
    end component; 
    
    component panic_button_led_controller is 
    port (
        clk : in std_logic;
        reset : in std_logic;
        panic_button_clicked : in std_logic; 
        panic_override_mx_kypd : out std_logic;
        kypd_decode_in : in std_logic_vector(3 downto 0); 
        panic_lights : out std_logic_vector(2 downto 0)
    ); 
    end component; 
    
    component ssd_unlocker_controller is 
    port (
        clk : in std_logic;
        reset : in std_logic; 
        keypad_key : in std_logic_vector(3 downto 0); 
        setup_guest_key : in std_logic_vector(3 downto 0); -- this is the key that was set by the user 
        segment_out : out std_logic_vector(6 downto 0)
      
    ); 
    end component; 
    
    component clock_div is 
        port (
            clk : in std_logic; 
            clk_enable : out std_logic
        ); 
    end component; 
    
    component panic_picture is 
        port ( 
            clka : IN STD_LOGIC;
            addra : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        
        );
    end component; 
    
    component pixel_pusher is 
        port ( 
            clk, en : in std_logic;
            panic_button_press : in std_logic; 
            show_image : out std_logic;
            vs, vid : in std_logic;
            pixel : in std_logic_vector(7 downto 0);
            hcount : in std_logic_vector(9 downto 0);
            R, B : out std_logic_vector(4 downto 0);
            G : out std_logic_vector(5 downto 0); 
            addr : out std_logic_vector(17 downto 0)
            
        ); 
    end component; 
    
    component vga_ctrl is 
        port ( 
            clk, en : in std_logic;
            reset : in std_logic;
            hcount, vcount : out std_logic_vector(9 downto 0); 
            vid, hs, vs : out std_logic
        ); 
    end component; 
    
    -- PICTURES
    component pierre_picture IS
      PORT (
        clka : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
    END component;  
    
    component charles_picture IS
      PORT (
        clka : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
    END component;
  
    component nick_picture IS
      PORT (
        clka : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
    end component;
    
component pixel_pusher_ssd_charles is
  Port ( 
    clk, en : in std_logic;
--  panic_button_press : in std_logic; 
    show_image : out std_logic;
    decode_in : in std_logic_vector(3 downto 0); 
    vs, vid : in std_logic;
    pixel : in std_logic_vector(7 downto 0);
    hcount : in std_logic_vector(9 downto 0);
    R, B : out std_logic_vector(4 downto 0);
    G : out std_logic_vector(5 downto 0); 
    addr : out std_logic_vector(17 downto 0)
  
  );
  end component; 
  
component pixel_pusher_ssd_nick is
  Port ( 
    clk, en : in std_logic;
--  panic_button_press : in std_logic; 
            show_image : out std_logic;
    decode_in : in std_logic_vector(3 downto 0); 
    vs, vid : in std_logic;
    pixel : in std_logic_vector(7 downto 0);
    hcount : in std_logic_vector(9 downto 0);
    R, B : out std_logic_vector(4 downto 0);
    G : out std_logic_vector(5 downto 0); 
    addr : out std_logic_vector(17 downto 0)
  
  );
end component;

component pixel_pusher_ssd_pierre is
  Port ( 
    clk, en : in std_logic;
--  panic_button_press : in std_logic; 
            show_image : out std_logic;
    decode_in : in std_logic_vector(3 downto 0); 
    vs, vid : in std_logic;
    pixel : in std_logic_vector(7 downto 0);
    hcount : in std_logic_vector(9 downto 0);
    R, B : out std_logic_vector(4 downto 0);
    G : out std_logic_vector(5 downto 0); 
    addr : out std_logic_vector(17 downto 0)
  
  );
end component;

-- picture's vga controls
component vga_ctrl_ssd_charles is
  Port ( 
  clk, en : in std_logic;
  reset : in std_logic; 
  hcount, vcount : out std_logic_vector(9 downto 0); 
  vid, hs, vs : out std_logic
  );
end component;

component vga_ctrl_ssd_nick is
  Port ( 
  clk, en : in std_logic;
  reset : in std_logic; 
  hcount, vcount : out std_logic_vector(9 downto 0); 
  vid, hs, vs : out std_logic
  );
end component;

component vga_ctrl_ssd_pierre is
  Port ( 
  clk, en : in std_logic;
  reset : in std_logic; 
  hcount, vcount : out std_logic_vector(9 downto 0); 
  vid, hs, vs : out std_logic
  );
end component;


    signal decode: STD_LOGIC_VECTOR (3 downto 0);
    signal top_distance : std_logic_vector(7 downto 0);  
    signal kypd_lock : std_logic; 
    signal maxsonar_lock : std_logic; 
    signal new_passkey : std_logic_vector(3 downto 0); 
    signal dbnc_passkey_btn : std_logic; 
    signal dbnc_reset_btn : std_logic; 
    signal dbnc_panic_btn : std_logic; 
    signal panic_led_controller_override : std_logic;
    signal dbnc_ssd_btn : std_logic; 
    
    signal decode_four_out_map : std_logic_vector(15 downto 0); 
    
    -- panic signals 
    signal signal_clk_en : std_logic;  
    signal signal_hcount_pnc, signal_vcount_pnc : std_logic_vector(9 downto 0);
    signal signal_vid_pnc, signal_vs_pnc, signal_hs_pnc : std_logic;
    signal signal_pixel_pnc : std_logic_vector(7 downto 0);
    signal signal_addr_pnc : std_logic_vector(17 downto 0);
    signal vga_r_pnc, vga_b_pnc : std_logic_vector(4 downto 0); 
    signal vga_g_pnc : std_logic_vector(5 downto 0); 

--    -- Pierre signals
    signal signal_hcount_p, signal_vcount_p : std_logic_vector(9 downto 0);
    signal signal_vid_p, signal_vs_p, signal_hs_p : std_logic;
    signal signal_pixel_p : std_logic_vector(7 downto 0);
    signal signal_addr_p : std_logic_vector(17 downto 0);
    signal vga_r_p, vga_b_p : std_logic_vector(4 downto 0); 
    signal vga_g_p : std_logic_vector(5 downto 0); 
    
--    -- Charles signals
    signal signal_hcount_c, signal_vcount_c : std_logic_vector(9 downto 0);
    signal signal_vid_c, signal_vs_c, signal_hs_c : std_logic;
    signal signal_pixel_c : std_logic_vector(7 downto 0);
    signal signal_addr_c : std_logic_vector(17 downto 0);
    signal vga_r_c, vga_b_c : std_logic_vector(4 downto 0); 
    signal vga_g_c : std_logic_vector(5 downto 0); 

--    -- Nick Signals 

    signal signal_hcount_n, signal_vcount_n : std_logic_vector(9 downto 0);
    signal signal_vid_n, signal_vs_n, signal_hs_n : std_logic;
    signal signal_pixel_n : std_logic_vector(7 downto 0);
    signal signal_addr_n : std_logic_vector(17 downto 0);
    signal vga_r_n, vga_b_n : std_logic_vector(4 downto 0); 
    signal vga_g_n : std_logic_vector(5 downto 0); 

signal show_image_pnc : std_logic;
signal show_image_pierre : std_logic;
signal show_image_nick : std_logic;
signal show_image_charles : std_logic;

    

begin


    u1: pmod_maxsonar
    port map (
        clk => clk, 
        reset_n => dbnc_reset_btn,
        sensor_pw => pwm,
        distance => top_distance
        
    ); 
    
    u2: distance_led_controller
    port map (
        clk => clk, 
        distance_maxsonar_pmod => top_distance, 
        within_ten_in => maxsonar_lock
    ); 
    
    rx <= '1'; 

    u3 : kypd_decoder
        port map(
            clk => clk,
            reset => dbnc_reset_btn,
            Row => JA(7 downto 4),
            Col => JA(3 downto 0),
            DecodeOut => Decode
        );
        
     u4 : kypd_led_controller 
     port map (
        clk => clk, 
        reset => dbnc_reset_btn,
        locked => kypd_lock, 
        updated_passkey => new_passkey,
        decode_in => decode
     ); 
     
     u5 : kypd_maxsonar_interface
     port map (
        clk => clk, 
        reset => dbnc_reset_btn,
        kypd_locked => kypd_lock,
        maxsonar_light => maxsonar_lock, 
        panic_override => panic_led_controller_override,
        precedence_led => led
    
     ); 

    u6 : load_passkey
    port map (
        clk => clk,
        reset => dbnc_reset_btn,
        switches => sw, 
        confirm_selection => dbnc_passkey_btn,
        valid_key_value => new_passkey

    ); 
    
    u7 : debounce
    port map (
        clk => clk,
        btn => passkey_btn,
        dbnc => dbnc_passkey_btn
    ); 
    
    u8 : debounce 
    port map (
        clk => clk,
        btn => rst,
        dbnc => dbnc_reset_btn
    ); 
    
    u9 : panic_button_led_controller
    port map (
        clk => clk,
        reset => dbnc_reset_btn,
        panic_button_clicked => dbnc_panic_btn,
        panic_override_mx_kypd => panic_led_controller_override,
        panic_lights => panic_leds, 
        kypd_decode_in => Decode

    ); 

    
    u10 : debounce 
    port map (
        clk => clk,
        btn => panic_btn,
        dbnc => dbnc_panic_btn
    );
    
    u11: ssd_unlocker_controller 
    port map (
        clk => clk,
        reset => dbnc_reset_btn,
        keypad_key => decode, 
        setup_guest_key => new_passkey, -- this is the key that was set by the user 
        segment_out => seg
      
    ); 
    
    u12: debounce 
    port map (
        clk => clk,
        btn => segment_btn,
        dbnc => dbnc_ssd_btn
    ); 
    
    u13 : clock_div 
    port map (
        clk => clk, 
        clk_enable => signal_clk_en
    ); 
    
    u14 : panic_picture 
    port map (
        clka => signal_clk_en,
        addra => signal_addr_pnc,
        douta => signal_pixel_pnc
    
    ); 
    

    u15 : pixel_pusher
    port map (
        clk => clk, 
        en => signal_clk_en, 
        show_image => show_image_pnc,
        panic_button_press => dbnc_panic_btn,
        vs => signal_vs_pnc, 
        vid => signal_vid_pnc,
        pixel => signal_pixel_pnc,
        hcount => signal_hcount_pnc,
        R => vga_r_pnc,
        G => vga_g_pnc,
        B => vga_b_pnc,
        addr => signal_addr_pnc
    
    ); 
    
    u16 : vga_ctrl
    port map (
        clk => clk, 
        reset => dbnc_reset_btn,
        en => signal_clk_en,
        hcount => signal_hcount_pnc,
        vcount => signal_vcount_pnc,
        vid => signal_vid_pnc,
        hs => signal_hs_pnc,
        vs => signal_vs_pnc
    
    ); 
    
   
    -- port mapping the pictures
    
    -- CHARLES
    u17 : charles_picture 
    port map (
        clka => signal_clk_en,
        addra => signal_addr_c,
        douta => signal_pixel_c
    
    ); 
    
    u20 : pixel_pusher_ssd_charles
    port map (
        clk => clk, 
        decode_in => Decode,
        en => signal_clk_en, 
        show_image => show_image_charles,
        vs => signal_vs_c, 
        vid => signal_vid_c,
        pixel => signal_pixel_c,
        hcount => signal_hcount_c,
        R => vga_r_c,
        G => vga_g_c,
        B => vga_b_c,
        addr => signal_addr_c
    
    ); 
    
    u24 : vga_ctrl_ssd_charles
    port map (
        clk => clk, 
        reset => dbnc_reset_btn,
        en => signal_clk_en,
        hcount => signal_hcount_c,
        vcount => signal_vcount_c,
        vid => signal_vid_c,
        hs => signal_hs_c,
        vs => signal_vs_c
    
    );     
-- pierre
    u18 : pierre_picture 
    port map (
        clka => signal_clk_en,
        addra => signal_addr_p,
        douta => signal_pixel_p
   
    ); 
    
    u21 : pixel_pusher_ssd_pierre
    port map (
        clk => clk, 
        decode_in => decode,
        en => signal_clk_en, 
        show_image => show_image_pierre,
        vs => signal_vs_p, 
        vid => signal_vid_p,
        pixel => signal_pixel_p,
        hcount => signal_hcount_p,
        R => vga_r_p,
        G => vga_g_p,
        B => vga_b_p,
        addr => signal_addr_p
    
    );     
    
    u23 : vga_ctrl_ssd_pierre
    port map (
        clk => clk, 
        reset => dbnc_reset_btn,
        en => signal_clk_en,
        hcount => signal_hcount_p,
        vcount => signal_vcount_p,
        vid => signal_vid_p,
        hs => signal_hs_p,
        vs => signal_vs_p
    
    );     
    
    -- nick
    u19 : nick_picture 
    port map (
        clka => signal_clk_en,
        addra => signal_addr_n,
        douta => signal_pixel_n
    ); 
    
    u22 : pixel_pusher_ssd_nick
    port map (
        clk => clk, 
        decode_in => decode,
        en => signal_clk_en, 
        show_image => show_image_nick,
        vs => signal_vs_n, 
        vid => signal_vid_n,
        pixel => signal_pixel_n,
        hcount => signal_hcount_n,
        R => vga_r_n,
        G => vga_g_n,
        B => vga_b_n,
        addr => signal_addr_n
    
    );     
    
    u25 : vga_ctrl_ssd_nick
    port map (
        clk => clk, 
        reset => dbnc_reset_btn,
        en => signal_clk_en,
        hcount => signal_hcount_n,
        vcount => signal_vcount_n,
        vid => signal_vid_n,
        hs => signal_hs_n,
        vs => signal_vs_n
    
    ); 
    
    
    process(clk)
    begin 
    if (rising_edge(clk)) then 
        if (show_image_pnc = '1') then
            vga_r <= vga_r_pnc;
            vga_g <= vga_g_pnc;
            vga_b <= vga_b_pnc;
            vga_hs <= signal_hs_pnc;
            vga_vs <= signal_vs_pnc;
        elsif (show_image_pierre = '1') then
            vga_r <= vga_r_p;
            vga_g <= vga_g_p;
            vga_b <= vga_b_p;
            vga_hs <= signal_hs_p;
            vga_vs <= signal_vs_p;
        elsif (show_image_nick = '1') then
            vga_r <= vga_r_n;
            vga_g <= vga_g_n;
            vga_b <= vga_b_n;
            vga_hs <= signal_hs_n;
            vga_vs <= signal_vs_n;
        elsif (show_image_charles = '1') then
            vga_r <= vga_r_c;
            vga_g <= vga_g_c;
            vga_b <= vga_b_c; 
            vga_hs <= signal_hs_c;
            vga_vs <= signal_vs_c;
        else
            vga_r <= vga_r_c;
            vga_g <= vga_g_c;
            vga_b <= vga_b_c;
            vga_hs <= signal_hs_c;
            vga_vs <= signal_vs_c;
        end if;
    end if; 
    end process;



end Behavioral;