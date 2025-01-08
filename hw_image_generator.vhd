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
	 volleyCount : buffer INTEGER;
	 rowBounce : buffer INTEGER;
    red      :  out  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
    green    :  out  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
    blue     :  out  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to DAC
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS

signal CLK_i, CLK_i2 : std_logic; --initial state of clock input
signal counter_u, counter_u2 : integer := 210; --paddle position top
signal paddleL, paddleR : std_logic; 
signal bounceC, bounceR : STD_LOGIC;
signal red_m, green_m, blue_m : STD_LOGIC_VECTOR(3 downto 0); -- buffer
signal red_b, green_b, blue_b : STD_LOGIC_VECTOR(3 downto 0); -- background
signal red_d, green_d, blue_d : STD_LOGIC_VECTOR(3 downto 0); -- display
signal red_p, green_p, blue_p : STD_LOGIC_VECTOR(3 downto 0); -- ball
signal count_r : std_logic := '0'; --reset program

BEGIN
  
  --visual display
  PROCESS(Clocking, count_r, disp_ena, row, column, counter_u, counter_u2, green_m, red_m, blue_m, countR, countL, volleyCount, green_d, red_d, blue_d, green_b, blue_b, red_b)
  variable counter_l : integer := 270; --left paddle position bottom
  variable counter_l2 : integer := 270; -- right paddle position bottom
  variable min_col, min_row : integer := 0;
  variable max_col, max_row : integer;
  variable counter : integer := 0;
  variable totalCount, color : integer := 0;
  variable count_max : integer := 599999;
  variable curveL, curveR, i, j : integer := 5;
  BEGIN
	counter_l := counter_u + 60; --left paddle width
	counter_l2 := counter_u2 + 60; --right paddle width
	totalCount := countR + countL;
	--ball color
	if(volleyCount > 20) then
		green_p <= (others => '0');
		red_p <= (others => '1');
		blue_p <= (others => '0');
		count_max := 599999;
		max_col := min_col + 17;
		max_row := min_row + 17;
	elsif(volleyCount > 10) then
		green_p <= "1000";
		red_p <= (others => '1');
		blue_p <= (others => '0');
		count_max := 699999;
		max_col := min_col + 22;
		max_row := min_row + 22;
	elsif(volleyCount > 5) then
		green_p <= (others => '1');
		red_p <= (others => '1');
		blue_p <= (others => '0');
		count_max := 799999;
		max_col := min_col + 27;
		max_row := min_row + 27;
	else
		green_p <= (others => '1');
		red_p <= (others => '1');
		blue_p <= (others => '1');	
		count_max := 999999;
		max_col := min_col + 32;
		max_row := min_row + 32;
	end if;
	
	if(rising_edge(Clocking)) then
		if(counter > count_max) then
			counter := 0;
			if(reset_dis = '1' and count_r = '0') then
				min_col := 304;
				min_row := 224;
				volleyCount <= 0;
				rowBounce <= 0;
				countL <= 0;
				countR <= 0;
				curveR := 5;
				curveL := 5;
			elsif(reset_dis = '1') then
				min_col := 304;
				min_row := 224;
				countL <= 0;
				countR <= 0;
				volleyCount <= 0;
				rowBounce <= 0;
				curveR := 5;
				curveL := 5;
			else
				--change check counters here
				if(bounceC = '1') then
					min_col := min_col - i;
					--max cap for curve
					if (i < 1) then
						i := 1;
					elsif(i < curveL) then
						i := curveL;
					elsif(i >= curveL) then
						i := i - 1;
					else
						i := i;
					end if;
				else
					min_col := min_col + i;
					--max cap for curve
					if (i < 1) then
						i := 1;
					elsif(i < curveL) then
						i := curveL;
					elsif(i >= curveL) then
						i := i - 1;
					else
						i := i;
					end if;
				end if;
				if(bounceR = '1') then
					min_row := min_row - j;
					if (j < 1) then
						j := 1;
					elsif(j < curveR) then
						j := curveR;
					elsif(j >= curveR) then
						j := j - 1;
					else
						j := j;
					end if;
				else
					min_row := min_row + j;
					if (j < 1) then
						j := 1;
					elsif(j < curveR) then
						j := curveR;
					elsif(j >= curveR) then
						j := j - 1;
					else
						j := j;
					end if;
				end if;
				
				--check top and bottom walls
				if(max_row > 470) then
					if(bounceR = '0') then
						rowBounce <= rowBounce + 1;
					end if;
					bounceR <= '1';
				elsif(min_row < 10) then
					if(bounceR = '1') then
						rowBounce <= rowBounce + 1;
					end if;
					bounceR <= '0';	
				end if;
				
				
				--check if out of bounds or hits paddle
				
				--change min_col or min_row count for angle
				if(max_col > 620 and max_row > counter_u2 and min_row < counter_l2) then
					--debouncing + determine angle
					if(bounceC = '0')then
						volleyCount <= volleyCount + 1;
						if((max_row > counter_u2) and (min_row < counter_u2)) then
							if(curveL > 1) then
								curveL := curveL - 1;
							else
								curveL := 1;
							end if;
							curveR := 5;
						elsif((min_row < counter_l2) and (max_row > counter_l2)) then
							if(curveR > 1) then
								curveR := curveR - 1;
							else
								curveR := 1;
							end if;
							curveL := 5;
						else
							curveR := 5;
							curveL := 5;
						end if;
					end if;
					bounceC <= '1';
				elsif(min_col < 20 and max_row > counter_u and min_row < counter_l) then
					--debouncing + determine angle
					if(bounceC = '1')then
						volleyCount <= volleyCount + 1;
						if((max_row > counter_u) and (min_row < counter_u)) then
							if(curveL > 1) then
								curveL := curveL - 1;
							else
								curveL := 1;
							end if;
							curveR := 5;
						elsif((min_row < counter_l) and (max_row > counter_l)) then
							if(curveR > 1) then
								curveR := curveR - 1;
							else
								curveR := 1;
							end if;
							curveL := 5;
						else
							curveR := 5;
							curveL := 5;
						end if;
					end if;
					bounceC <= '0';
				elsif(max_col > 640) then
					bounceC <= '1';
					min_col := 304;
					min_row := 224;
					countL <= countL + 1;
					volleyCount <= 0;
					curveR := 5;
					curveL := 5;
				elsif(min_col < 0) then
					bounceC <= '0';
					min_col := 304;
					min_row := 224;
					volleyCount <= 0;
					countR <= countR + 1;
					curveR := 5;
					curveL := 5;
				end if;
				
				if(countL >= 11 or countR >= 11) then
					countL <= countL;
					countR <= countR;
					volleyCount <= 0;
					rowBounce <= 0;
					min_col := 304;
					min_row := 224;
					curveR := 5;
					curveL := 5;
				end if;
			end if;
			
		else
			counter := counter + 1;
		end if;
	end if;
	--display color
	color := totalCount mod 8;
	
	case(color) is
		when 0 =>
			green_d <= (others => '1');
			red_d <= (others => '1');
			blue_d <= (others => '1');
		when 1 =>
			green_d <= "1000";
			red_d <= (others => '1');
			blue_d <= (others => '0');
		when 2 =>
			green_d <= (others => '1');
			red_d <= "1000";
			blue_d <= (others => '0');
		when 3 =>
			green_d <= (others => '0');
			red_d <= "1000";
			blue_d <= (others => '1');
		when 4 =>
			green_d <= (others => '0');
			red_d <= (others => '1');
			blue_d <= "1000";
		when 5 =>
			green_d <= (others => '1');
			red_d <= (others => '0');
			blue_d <= "1000";
		when 6 =>
			green_d <= "1000";
			red_d <= (others => '0');
			blue_d <= (others => '1');
		when 7 =>
			green_d <= "1000";
			red_d <= "1000";
			blue_d <= "1000";
		when others =>
			green_d <= (others => '1');
			red_d <= (others => '1');
			blue_d <= (others => '1');
	end case;
	
	if(countL > countR) then
		green_b <= (others => '0');
		red_b <= "1000";
		blue_b <= (others => '0');
	elsif(countR > countL) then
		green_b <= (others => '0');
		red_b <= (others => '0');
		blue_b <= "1000";
	else
		green_b <= (others => '0');
		red_b <= (others => '0');
		blue_b <= (others => '0');
	end if;
	--pong display
	--check count for color for display signals
    IF(disp_ena = '1') THEN        --display time
		--< 10 = top, > 470 = bottom boundry
		if(row < 10 or row > 470) then
			green_m <= green_d;
			red_m <= red_d;
			blue_m <= blue_d;
		-- the middle markation
		elsif(column < 330 and column > 310) then
			if(row > 30 and row < 65) then
				green_m <= green_d;
				red_m <= red_d;
				blue_m <= blue_d;
			elsif(row > 85 and row < 120) then
				green_m <= green_d;
				red_m <= red_d;
				blue_m <= blue_d;
			elsif(row > 140 and row < 175) then
				green_m <= green_d;
				red_m <= red_d;
				blue_m <= blue_d;
			elsif(row > 195 and row < 230) then
				green_m <= green_d;
				red_m <= red_d;
				blue_m <= blue_d;
			elsif(row > 250 and row < 285) then
				green_m <= green_d;
				red_m <= red_d;
				blue_m <= blue_d;
			elsif(row > 305 and row < 340) then
				green_m <= green_d;
				red_m <= red_d;
				blue_m <= blue_d;
			elsif(row > 360 and row < 395) then
				green_m <= green_d;
				red_m <= red_d;
				blue_m <= blue_d;
			elsif(row > 415 and row < 450) then
				green_m <= green_d;
				red_m <= red_d;
				blue_m <= blue_d;
			else
				green_m <= green_b;
				red_m <= red_b;
				blue_m <= blue_b;
			end if;
		--affecting left paddle
		elsif(column < 20) then
			--edit these columns using the rotary encoder.
			if(row > counter_u and row < counter_l) then
				--color paddle
				green_m <= (others => '0');
				red_m <= (others => '1');
				blue_m <= (others => '0');
			else
				--color background
				green_m <= green_b;
				red_m <= red_b;
				blue_m <= blue_b;
			end if;
		--affecting right paddle
		elsif(column > 620) then
			--edit these columns using the rotary encoder.
			if(row > counter_u2 and row < counter_l2) then
				--can color paddle here
				green_m <= (others => '0');
				red_m <= (others => '0');
				blue_m <= (others => '1');
			else
				--color background
				green_m <= green_b;
				red_m <= red_b;
				blue_m <= blue_b;
			end if;
		-- or check row first then these columns
		elsif(column < 280 and column > 200) then --tens digit left side
			if(row > 32 and row < 72) then
				--scoreboard logic player 1
				case(countL) is
					when 0 =>
						if((row > 32 and row < 40) or (row > 63 and row < 72)) then
							if(column > 255 and column < 272) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 39 and row < 64) then
							if((column > 247 and column < 256) or (column > 271 and column < 280)) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						else
							green_m <= green_b;
							red_m <= red_b;
							blue_m <= blue_b;
						end if;
					when 1 =>
						if((row > 32 and row < 40) or (row > 47 and row < 64)) then
							if(column > 255 and column < 264) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 247 and column < 264) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 63 and row < 72) then
							if(column > 247 and column < 272) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						else
							green_m <= green_b;
							red_m <= red_b;
							blue_m <= blue_b;
						end if;
					when 2 =>
						if(row > 32 and row < 40) then
							if(column > 255 and column < 272) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if((column > 247 and column < 256) or (column > 271 and column < 280)) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 47 and row < 56) then
							if(column > 263 and column < 280) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 55 and row < 64) then
							if(column > 255 and column < 264) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 63 and row < 72) then
							if(column > 247 and column < 280) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						else
							green_m <= green_b;
							red_m <= red_b;
							blue_m <= blue_b;
						end if;
					when 3 =>
						if((row > 32 and row < 40) or (row > 63 and row < 72)) then
							if(column > 247 and column < 272) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif((row > 39 and row < 48) or (row > 55 and row < 64)) then
							if(column > 271 and column < 280) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 47 and row < 56) then
							if(column > 255 and column < 272) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						else
							green_m <= green_b;
							red_m <= red_b;
							blue_m <= blue_b;
						end if;
					when 4 =>
						if(row > 32 and row < 48) then
							if((column > 247 and column < 256) or (column > 263 and column < 272)) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 47 and row < 56) then
							if(column > 247 and column < 280) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 55 and row < 72) then
							if(column > 263 and column < 272) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						else
							green_m <= green_b;
							red_m <= red_b;
							blue_m <= blue_b;
						end if;
					when 5 =>
						if(row > 32 and row < 40) then
							if(column > 255 and column < 280) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 247 and column < 256) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif((row > 47 and row < 56) or (row > 63 and row < 72)) then
							if(column > 247 and column < 272) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 55 and row < 64) then
							if(column > 271 and column < 280) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						else
							green_m <= green_b;
							red_m <= red_b;
							blue_m <= blue_b;
						end if;
					when 6 =>
						if(row > 32 and row < 40) then
							if(column > 255 and column < 280) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 247 and column < 256) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif((row > 47 and row < 56) or (row > 63 and row < 72)) then
							if(column > 247 and column < 272) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 55 and row < 64) then
							if((column > 247 and column < 256) or (column > 271 and column < 280)) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						else
							green_m <= green_b;
							red_m <= red_b;
							blue_m <= blue_b;
						end if;
					when 7 => 
						if(row > 32 and row < 40) then
							if(column > 247 and column < 280) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 271 and column < 280) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 47 and row < 56) then
							if(column > 263 and column < 272) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 55 and row < 72) then
							if(column > 255 and column < 264) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						else
							green_m <= green_b;
							red_m <= red_b;
							blue_m <= blue_b;
						end if;
					when 8 =>
						if((row > 32 and row < 40) or (row > 47 and row < 56) or (row > 63 and row < 72)) then
							if(column > 255 and column < 272) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif((row > 39 and row < 48) or (row > 55 and row < 64)) then
							if((column > 247 and column < 256) or (column > 271 and column < 280)) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						else
							green_m <= green_b;
							red_m <= red_b;
							blue_m <= blue_b;
						end if;
					when 9 =>
						if((row > 32 and row < 40) or (row > 47 and row < 56)) then
							if(column > 255 and column < 280) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if((column > 247 and column < 256) or (column > 271 and column < 280)) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 55 and row < 72) then
							if(column > 271 and column < 280) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						else
							green_m <= green_b;
							red_m <= red_b;
							blue_m <= blue_b;
						end if;
					when 10 =>
						if(row > 32 and row < 40) then
							if(column > 215 and column < 224) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							elsif(column > 255 and column < 272) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 207 and column < 224) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							elsif((column > 247 and column < 256) or (column > 271 and column < 280)) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 47 and row < 64) then
							if(column > 215 and column < 224) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							elsif((column > 247 and column < 256) or (column > 271 and column < 280)) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 63 and row < 72) then
							if(column > 207 and column < 232) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							elsif(column > 255 and column < 272) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						else
							green_m <= green_b;
							red_m <= red_b;
							blue_m <= blue_b;
						end if;
					when 11 =>
						if((row > 32 and row < 40) or (row > 47 and row < 64)) then
							if(column > 215 and column < 224) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							elsif(column > 255 and column < 264) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 207 and column < 224) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							elsif(column > 247 and column < 264) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 63 and row < 72) then
							if(column > 207 and column < 232) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							elsif(column > 247 and column < 272) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						else
							green_m <= green_b;
							red_m <= red_b;
							blue_m <= blue_b;
						end if;
					when others =>
						green_m <= green_b;
						red_m <= red_b;
						blue_m <= blue_b;
				end case;
			else
				green_m <= green_b;
				red_m <= red_b;
				blue_m <= blue_b;
			end if;
		elsif(column > 360 and column < 440) then --ones digit right side
			if(row > 32 and row < 72) then
				case(countR) is
					when 0 =>
						if((row > 32 and row < 40) or (row > 63 and row < 72)) then
							if(column > 375 and column < 392) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 39 and row < 64) then
							if((column > 367 and column < 376) or (column > 391 and column < 400)) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						else
							green_m <= green_b;
							red_m <= red_b;
							blue_m <= blue_b;
						end if;
					when 1 =>
						if((row > 32 and row < 40) or (row > 47 and row < 64)) then
							if(column > 375 and column < 384) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 367 and column < 384) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 63 and row < 72) then
							if(column > 367 and column < 392) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						else
							green_m <= green_b;
							red_m <= red_b;
							blue_m <= blue_b;
						end if;
					when 2 =>
						if(row > 32 and row < 40) then
							if(column > 375 and column < 392) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if((column > 367 and column < 376) or (column > 391 and column < 400)) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 47 and row < 56) then
							if(column > 383 and column < 400) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 55 and row < 64) then
							if(column > 375 and column < 384) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 63 and row < 72) then
							if(column > 367 and column < 400) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						else
							green_m <= green_b;
							red_m <= red_b;
							blue_m <= blue_b;
						end if;
					when 3 =>
						if((row > 32 and row < 40) or (row > 63 and row < 72)) then
							if(column > 367 and column < 392) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif((row > 39 and row < 48) or (row > 55 and row < 64)) then
							if(column > 391 and column < 400) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 47 and row < 56) then
							if(column > 375 and column < 392) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						else
							green_m <= green_b;
							red_m <= red_b;
							blue_m <= blue_b;
						end if;
					when 4 =>
						if(row > 32 and row < 48) then
							if((column > 367 and column < 376) or (column > 383 and column < 392)) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 47 and row < 56) then
							if(column > 367 and column < 400) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 55 and row < 72) then
							if(column > 383 and column < 392) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						else
							green_m <= green_b;
							red_m <= red_b;
							blue_m <= blue_b;
						end if;
					when 5 =>
						if(row > 32 and row < 40) then
							if(column > 375 and column < 400) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 367 and column < 376) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif((row > 47 and row < 56) or (row > 63 and row < 72)) then
							if(column > 367 and column < 392) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 55 and row < 64) then
							if(column > 391 and column < 400) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						else
							green_m <= green_b;
							red_m <= red_b;
							blue_m <= blue_b;
						end if;
					when 6 =>
						if(row > 32 and row < 40) then
							if(column > 375 and column < 400) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 367 and column < 376) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif((row > 47 and row < 56) or (row > 63 and row < 72)) then
							if(column > 367 and column < 392) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 55 and row < 64) then
							if((column > 367 and column < 376) or (column > 391 and column < 400)) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						else
							green_m <= green_b;
							red_m <= red_b;
							blue_m <= blue_b;
						end if;
					when 7 => 
						if(row > 32 and row < 40) then
							if(column > 367 and column < 400) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 391 and column < 400) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 47 and row < 56) then
							if(column > 383 and column < 392) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 55 and row < 72) then
							if(column > 375 and column < 384) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						else
							green_m <= green_b;
							red_m <= red_b;
							blue_m <= blue_b;
						end if;
					when 8 =>
						if((row > 32 and row < 40) or (row > 47 and row < 56) or (row > 63 and row < 72)) then
							if(column > 375 and column < 392) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif((row > 39 and row < 48) or (row > 55 and row < 64)) then
							if((column > 367 and column < 376) or (column > 391 and column < 400)) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						else
							green_m <= green_b;
							red_m <= red_b;
							blue_m <= blue_b;
						end if;
					when 9 =>
						if((row > 32 and row < 40) or (row > 47 and row < 56)) then
							if(column > 375 and column < 400) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if((column > 367 and column < 376) or (column > 391 and column < 400)) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 55 and row < 72) then
							if(column > 391 and column < 400) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						else
							green_m <= green_b;
							red_m <= red_b;
							blue_m <= blue_b;
						end if;
					when 10 =>
						if(row > 32 and row < 40) then
							if(column > 375 and column < 384) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							elsif(column > 415 and column < 432) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 367 and column < 384) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							elsif((column > 407 and column < 416) or (column > 431 and column < 440)) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 47 and row < 64) then
							if(column > 375 and column < 384) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							elsif((column > 407 and column < 416) or (column > 431 and column < 440)) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 63 and row < 72) then
							if(column > 367 and column < 392) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							elsif(column > 415 and column < 432) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						else
							green_m <= green_b;
							red_m <= red_b;
							blue_m <= blue_b;
						end if;
					when 11 =>
						if((row > 32 and row < 40) or (row > 47 and row < 64)) then
							if(column > 375 and column < 384) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							elsif(column > 415 and column < 424) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 367 and column < 384) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							elsif(column > 407 and column < 424) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						elsif(row > 63 and row < 72) then
							if(column > 367 and column < 392) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							elsif(column > 407 and column < 432) then
								green_m <= green_d;
								red_m <= red_d;
								blue_m <= blue_d;
							else
								green_m <= green_b;
								red_m <= red_b;
								blue_m <= blue_b;
							end if;
						else
							green_m <= green_b;
							red_m <= red_b;
							blue_m <= blue_b;
						end if;
					when others =>
						green_m <= green_b;
						red_m <= red_b;
						blue_m <= blue_b;
				end case;
			else
				green_m <= green_b;
				red_m <= red_b;
				blue_m <= blue_b;
			end if;
		else 
			green_m <= green_b;
			red_m <= red_b;
			blue_m <= blue_b;
		end if;
		
		if(row > min_row and row < max_row) then
			if(column > min_col and column < max_col) then
				--can color ball here
				green <= green_p;
				red <= red_p;
				blue <= blue_p;
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
