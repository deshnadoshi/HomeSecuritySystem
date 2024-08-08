--------------------------------------------------------------------------------
--
--   FileName:         pmod_ultrasonic_range_finder.vhd
--   Dependencies:     none
--   Design Software:  Quartus Prime Version 17.0.0 Build 595 SJ Lite Edition
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 10/30/2019 Scott Larson
--     Initial Public Release
--   Version 1.1 01/30/2023 Scott Larson
--     Eliminated some synthesis warnings, no functional difference from v1.0
--    
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY pmod_maxsonar IS
  PORT(
    clk       : IN   STD_LOGIC;                     --system clock
    reset_n   : IN   STD_LOGIC;                     --asynchronous active-HIGH reset (modified to follow the rest of the code)
    sensor_pw : IN   STD_LOGIC;                     --pulse width (PW) input from ultrasonic range finder
    distance  : OUT  STD_LOGIC_VECTOR(7 DOWNTO 0)); --binary distance output (inches)
END pmod_maxsonar;

ARCHITECTURE behavior OF pmod_maxsonar IS
  SIGNAL sensor_pw_prev : STD_LOGIC;  --previous value of the sensor's pulse width signal
BEGIN

  PROCESS(clk,reset_n)
    --VARIABLE sub_inch_counter : INTEGER RANGE 0 TO 147*clk_freq := 0; --counts until time equivalent to 1 inch is reached (147us)
    VARIABLE inch_counter     : INTEGER RANGE 0 TO 255 := 0;
    VARIABLE sub_inch_counter : INTEGER RANGE 0 TO 147*125 := 0; --counts until time equivalent to 6 inch is reached (882us)
          --counts number of inches that have been reached
  BEGIN
    IF(reset_n = '1') THEN                          --asynchronous reset
      sub_inch_counter := 0;                          --clear sub-inch counter
      inch_counter := 0;                              --clear inch counter
      distance <= (OTHERS => '0');                    --clear distance output register
    ELSIF(clk'EVENT AND clk = '1') THEN             --rising system clock edge  
      sensor_pw_prev <= sensor_pw;                    --store previous value of pulse width input
      IF(sensor_pw = '1') THEN                        --pulse width input is high
        IF(sub_inch_counter < 147*125) THEN        --time is less than 147us -- adjusted to match 6 in = 882us
          sub_inch_counter := sub_inch_counter + 1;       --increment sub-inch counter
        ELSE                                            --time is equal to 147us
          sub_inch_counter := 0;                          --clear sub-inch counter
          inch_counter := inch_counter + 1;               --increment inch counter
        END IF;
      END IF;
      IF(sensor_pw_prev = '1' AND sensor_pw = '0') THEN  --falling edge of pulse width signal
        --convert the integer inch counter into a binary number for output
        distance <= std_logic_vector(to_unsigned(inch_counter,distance'LENGTH));
      
        --clear counters
        sub_inch_counter := 0;
        inch_counter := 0;
      END IF;
    END IF;
  END PROCESS;
END behavior;