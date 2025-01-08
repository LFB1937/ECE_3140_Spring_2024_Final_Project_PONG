--------------------------------------------------------------------------------
--
--   FileName:         hw_image_generator.vhd
--   Dependencies:     none
--   Design Software:  Quartus II 64-bit Version 12.1 Build 177 SJ Full Version
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
--   Version 1.0 05/10/2013 Scott Larson
--     Initial Public Release
--    
--------------------------------------------------------------------------------
--
-- Altered 10/13/19 - Tyler McCormick 
-- Test pattern is now 8 equally spaced 
-- different color vertical bars, from black (left) to white (right)


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY hw_image_generator IS
--  GENERIC(
--    
-- row : INTEGER := 15;
-- col : INTEGER := 5;
--	col_a : INTEGER := 80;
--	col_b : INTEGER := 160;
--	col_c : INTEGER := 240;
--	col_d : INTEGER := 320;
--	col_e : INTEGER := 400;
--	col_f : INTEGER := 480;
--	col_g : INTEGER := 560;
--	col_h : INTEGER := 640
--
--	);  
  PORT(
	 reset_dis : IN STD_LOGIC;
	 Clocking : IN STD_LOGIC;  -- Clock
	 DT :  INOUT   STD_LOGIC; -- ARDUINO_IO6
	 CLK :  INOUT   STD_LOGIC; --ARDUINO_IO7
	 DT2 : INOUT	STD_LOGIC;	--ARDUINO_IO0
	 CLK2 : INOUT	STD_LOGIC;  --ARDUINO_IO1
	 disp_ena :  IN   STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
    row      :  IN   INTEGER;    --row pixel coordinate
    column   :  IN   INTEGER;    --column pixel coordinate
	 countL	 :  buffer  INTEGER;
	 countR	 :  buffer  INTEGER;
    red      :  out  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
    green    :  out  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
    blue     :  out  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to DAC
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS

signal CLK_i, CLK_i2 : std_logic; --initial state of clock input
signal counter_u, counter_u2 : integer := 210; --paddle position top
signal paddleL, paddleR : std_logic; 
signal bounceC, bounceR : STD_LOGIC;
signal red_m, green_m, blue_m : STD_LOGIC_VECTOR(3 downto 0);
signal count_r : std_logic := '0'; --reset program

BEGIN
  
  --visual display
  PROCESS(Clocking, count_r, disp_ena, row, column, counter_u, counter_u2, green_m, red_m, blue_m)
  variable counter_l : integer := 270; --left paddle position bottom
  variable counter_l2 : integer := 270; -- right paddle position bottom
  variable min_col, min_row : integer := 0;
  variable max_col, max_row : integer;
  variable counter : integer := 0;
  BEGIN
	counter_l := counter_u + 60; --left paddle width
	counter_l2 := counter_u2 + 60; --right paddle width
	max_col := min_col + 32;
	max_row := min_row + 32;
	if(rising_edge(Clocking)) then
		if(counter > 299999) then
			counter := 0;
			if(reset_dis = '1' and count_r = '0') then
				min_col := 304;
				min_row := 224;
				countL <= 0;
				countR <= 0;
			elsif(reset_dis = '1') then
				min_col := 304;
				min_row := 224;
				countL <= 0;
				countR <= 0;
			else
				if(bounceC = '1') then
					min_col := min_col - 1;
				else
					min_col := min_col + 1;
				end if;
				if(bounceR = '1') then
					min_row := min_row - 1;
				else
					min_row := min_row + 1;
				end if;
				
				--check top and bottom walls
				if(max_row > 470) then
					bounceR <= '1';
				elsif(min_row < 10) then
					bounceR <= '0';
				end if;
				
				
				--check if out of bounds or hits paddle
				
				if(max_col > 630 and max_row > counter_u2 and min_row < counter_l2) then
					bounceC <= '1';
				elsif(min_col < 10 and max_row > counter_u and min_row < counter_l) then
					bounceC <= '0';
				elsif(max_col > 640) then
					bounceC <= '1';
					min_col := 304;
					min_row := 224;
					countL <= countL + 1;
				elsif(min_col < 0) then
					bounceC <= '0';
					min_col := 304;
					min_row := 224;
					countR <= countR + 1;
				end if;
				
				if(countL >= 11 or countR >= 11) then
					countL <= countL;
					countR <= countR;
					min_col := 304;
					min_row := 224;
				end if;
			end if;
			
		else
			counter := counter + 1;
		end if;
	end if;
	
	--pong display
    IF(disp_ena = '1') THEN        --display time
		--< 10 = top, > 470 = bottom boundry
		if(row < 10 or row > 470) then
			green_m <= (others => '1');
			red_m <= (others => '1');
			blue_m <= (others => '1');
		-- the middle markation
		elsif(column < 330 and column > 310) then
			if(row > 30 and row < 65) then
				green_m <= (others => '1');
				red_m <= (others => '1');
				blue_m <= (others => '1');
			elsif(row > 85 and row < 120) then
				green_m <= (others => '1');
				red_m <= (others => '1');
				blue_m <= (others => '1');
			elsif(row > 140 and row < 175) then
				green_m <= (others => '1');
				red_m <= (others => '1');
				blue_m <= (others => '1');
			elsif(row > 195 and row < 230) then
				green_m <= (others => '1');
				red_m <= (others => '1');
				blue_m <= (others => '1');
			elsif(row > 250 and row < 285) then
				green_m <= (others => '1');
				red_m <= (others => '1');
				blue_m <= (others => '1');
			elsif(row > 305 and row < 340) then
				green_m <= (others => '1');
				red_m <= (others => '1');
				blue_m <= (others => '1');
			elsif(row > 360 and row < 395) then
				green_m <= (others => '1');
				red_m <= (others => '1');
				blue_m <= (others => '1');
			elsif(row > 415 and row < 450) then
				green_m <= (others => '1');
				red_m <= (others => '1');
				blue_m <= (others => '1');
			else
				green_m <= (others => '0');
				red_m <= (others => '0');
				blue_m <= (others => '0');
			end if;
		--affecting left paddle
		elsif(column < 10) then
			--edit these columns using the rotary encoder.
			if(row > counter_u and row < counter_l) then
				green_m <= (others => '1');
				red_m <= (others => '1');
				blue_m <= (others => '1');
			else
				green_m <= (others => '0');
				red_m <= (others => '0');
				blue_m <= (others => '0');
			end if;
		--affecting right paddle
		elsif(column > 630) then
			--edit these columns using the rotary encoder.
			if(row > counter_u2 and row < counter_l2) then
				green_m <= (others => '1');
				red_m <= (others => '1');
				blue_m <= (others => '1');
			else
				green_m <= (others => '0');
				red_m <= (others => '0');
				blue_m <= (others => '0');
			end if;
		else 
			green_m <= (others => '0');
			red_m <= (others => '0');
			blue_m <= (others => '0');
		end if;
		
		if(row > min_row and row < max_row) then
			if(column > min_col and column < max_col) then
				green <= (others => '1');
				red <= (others => '1');
				blue <= (others => '1');
			else
				green <= green_m;
				red <= red_m;
				blue <= blue_m;
			end if;
		else
			green <= green_m;
			red <= red_m;
			blue <= blue_m;
		end if;
		
    ELSE                           --blanking time
      green <= (others => '0');
		red <= (others => '0');
		blue <= (others => '0');
    END IF;
  END PROCESS;
  
  --movement for rotary encoder
  process(Clocking, CLK, DT, CLK2, DT2, countL, countR, reset_dis)
  Variable count: integer := 0;
  variable count2 : integer := 0;
  begin	
	if (rising_edge(Clocking)) then
		--debouncing if condition
		--left paddle
		if(countL >= 11 or countR >= 11) then
			if(reset_dis = '0') then
				counter_u <= 210;
				counter_u2 <= 210;
				count_r <= '1';
			else
				count_r <= '0';
			end if;
		end if;
		
		if(count > 999) then 
			count := 0;
			--check end state is achieved can exclude if not specified
			
			--could add boundry check up here instead to reduce description
			--check state and direction of rotary encoder/paddle
			if(CLK /= CLK_i) then
				--left = up
				if(DT /= CLK) then
					if(counter_u > 410) then
						counter_u <= 411;
					else
						counter_u <= counter_u + 8; 
					end if;
				--right = down
				else
					if(counter_u < 10) then
						counter_u <= 9;
					else
						counter_u <= counter_u - 8; 
					end if;
				end if;
			else
				if(counter_u > 410) then
						counter_u <= 411;
				elsif(counter_u < 10) then
						counter_u <= 9;
				else
					counter_u <= counter_u;
				end if;
			end if;
			CLK_i <= CLK;
		else
			count := count + 1;
		end if;
		--right paddle
		if(count2 > 999) then 
			count2 := 0;
			--could add boundry check up here instead to reduce description
			--check state and direction of rotary encoder/paddle
			if(CLK2 /= CLK_i2) then
				--left = up
				if(DT2 /= CLK2) then
					if(counter_u2 > 410) then
						counter_u2 <= 411;
					else
						counter_u2 <= counter_u2 + 8; 
					end if;
				--right = down
				else
					if(counter_u2 < 10) then
						counter_u2 <= 9;
					else
						counter_u2 <= counter_u2 - 8; 
					end if;
				end if;
			else
				if(counter_u2 > 410) then
						counter_u2 <= 411;
				elsif(counter_u2 < 10) then
						counter_u2 <= 9;
				else
					counter_u2 <= counter_u2;
				end if;
			end if;
			CLK_i2 <= CLK2;
		else
			count2 := count2 + 1;
		end if;
	end if;
  end process;
  

END behavior;
