---------------------------------
-- Tate Finley and Lewis Bates
-- ECE 3140
-- Tate's email: tafinley43@tntech.edu
-- Lewis's email: lfbates42@tntech.edu
-- pong1: move paddle with rotary encoder 
--	(pong implementation)
---------------------------------

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
	Clocking : IN STD_LOGIC;  -- Clock
	DT :  INOUT   STD_LOGIC; -- ARDUINO_IO6
	CLK :  INOUT   STD_LOGIC; --ARDUINO_IO7
	disp_ena :  IN   STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
	reset	 :  IN STD_LOGIC;	-- KEY0 to reset the ball position
	row      :  IN   INTEGER;    --row pixel coordinate
   column   :  IN   INTEGER;    --column pixel coordinate
	miscount	:  buffer 	INTEGER := 0; -- keeps track of the miscount
	volleycount :  buffer	INTEGER := 0; -- keeps track of the volleycount
	collisioncount : buffer INTEGER := 0; -- keeps track of the collisions
   red      :  out  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
   green    :  out  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
  	blue     :  out  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to DAC
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS

signal CLK_i : std_logic; --initial state of clock input
signal counter_u : integer := 210; --paddle position top
signal green_int, red_int, blue_int : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); -- the values for the color signals
signal red_b, green_b, blue_b : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); -- background
signal red_d, green_d, blue_d : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); -- display
signal red_p, green_p, blue_p : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); -- ball
signal bounceC, bounceR, countReset : std_logic;
signal count : integer := 0; -- The speed of the paddle

--variable min_col, min_row : integer := 0;
--variable max_col, max_row : integer;
--variable counter : integer := 0;

BEGIN
  
  -- Display for the screen
  PROCESS(disp_ena, row, column, counter_u, countReset)
	variable counter_l : integer := 270; --paddle position bottom
	variable min_col, min_row : integer := 0;
	variable max_col, max_row : integer;
	variable counter : integer := 0;
	variable curveL, curveR, i, j : integer := 1; -- used for the English spin variables
	variable color, digit0, digit1, digit2 : integer := 0;


  BEGIN
 	max_col := min_col + 32;
  	max_row := min_row + 32;
	counter_l := counter_u + 60; --paddle width
	--pong display
	
		-- create the reset feature for the ball
		
	
		-- The clock cycle to  set up the bouncing for the columns & rows
		if(rising_edge(Clocking)) then
			if(counter > 600000) then -- 600000
				counter := 0; -- ball counter
	
				-- resets the game when the KEY0 is pressed
				if(reset = '1' and countReset = '0') then
					bounceC <= '1';
					miscount <= 0;
					volleycount <= 0;
					min_row := 224;
					min_col := 304;
					curveR := 1;
					curveL := 1;
					collisioncount <= 0;
		

				-- resets the ball position & the miscount
				elsif (reset = '1') then
					bounceC <= '1';
					miscount <= 0;
					volleycount <= 0;
					min_row := 224;
					min_col := 304;
					curveR := 1;
					curveL := 1;	
					collisioncount <= 0;					

				else
						-- checks the bounces on the columns	
						if(bounceC = '1') then
							min_col := min_col - i; -- min_col goes left
							-- max cap for the curve
							if (i > 5) then
								i := 5;
							end if ;
							-- parameters for count
							-- determines the curvature of the ball
							if (i > curveL) then
								i := curveL;
							elsif (i <= curveL) then
								i := i + 1;
								else
								i := i;	
							end if ;
						else
							min_col := min_col + i; -- min_col goes right
							-- max cap for the curve
							if (i > 5) then
								i := 5;
							end if ;
							-- parameters for count
							-- determines the curvature of the ball
							if (i > curveL) then
								i := curveL;
							elsif (i <= curveL) then
								i := i + 1;
							else
								i := i;	
							end if ;
						end if;
						if(bounceR = '1') then
							min_row := min_row - j; -- min_row goes left
							-- max cap for the curve
							if (j > 5) then
								j := 5;
							end if ;
							-- parameters for count
							-- determines the curvature of the ball
							if (j > curveR) then
								j := curveR;
							elsif (j <= curveR) then
								j := j + 1;
							else
								j := j;	
							end if ;
						else
							min_row := min_row + j; -- min_row goes right
							-- max cap for the curve
							if (j > 5) then
								j := 5;
							end if ;
							-- parameters for count
							-- determines the curvature of the ball
							if (j > curveR) then
								j := curveR;
							elsif (j <= curveR) then
								j := j + 1;
							else
								j := j;	
							end if ;
						end if;
						
						-- boundary for the borders
						if(max_row > 470) then
							bounceR <= '1';
							collisioncount <= collisioncount + 1;
							-- increment the collision count
						elsif(min_row < 10) then
							bounceR <= '0';
							collisioncount <= collisioncount + 1;
							-- increment the collision count
						end if;

						
						-- boundary for the paddle
						if(max_col > 620 and  max_row > counter_u and min_row < counter_l) then
							-- debouncing and determining the angle of the ball
							if (bounceC = '0') then
								-- volley count
								
								-- top part of the paddle
								if ((max_row > counter_u) and (min_row < counter_u)) then
									curveL := curveL + 1;
									curveR := 1;
								
								-- bottom part of the paddle 
								elsif ((min_row < counter_l) and (max_row > counter_l)) then
									curveR := curveR + 1;
									curveL := 1;
								
								else
									
									curveR := 1;
									curveL := 1;

								end if ;
							end if ;	

							bounceC <= '1';
							collisioncount <= collisioncount + 1;							
							-- increment the collision count

						elsif (max_col > 640 ) then
							bounceC <= '1';
							collisioncount <= collisioncount + 1;
							-- increment the collision count
							miscount <= miscount + 1;						
							min_row := 224;
							min_col := 304;	
							curveR := 1;
							curveL := 1;
							
						-- left wall	
						elsif(min_col < 10 ) then
							if (bounceC = '1') then
								volleycount <= volleycount + 1;						
							end if ;
							bounceC <= '0';
							collisioncount <= collisioncount + 1;							
							-- increment the collision count

						end if;
						
						-- ends the game & Locks the ball,
						-- when the miscount gets to 11
						if (miscount >= 11) then
							miscount <= miscount;
							volleycount <= volleycount;
							min_row := 224;
							min_col := 304;
							curveR := 1;
							curveL := 1;
						end if;	


				end if;	
			else
				counter := counter + 1;
			end if;
		end if;
		
		--display color
		color := miscount mod 8;

		-- generates the colors used in the display
		case(color) is
			when 0 =>
				green_d <= (others => '1');
				red_d <= (others => '1');
				blue_d <= (others => '1');
			when 1 =>
				green_d <= (others => '1');
				red_d <= (others => '1');
				blue_d <= (others => '0');
			when 2 =>
				green_d <= (others => '1');
				red_d <= (others => '0');
				blue_d <= (others => '1');
			when 3 =>
				green_d <= (others => '0');
				red_d <= (others => '1');
				blue_d <= (others => '1');
			when 4 =>
				green_d <= "1000";
				red_d <= (others => '1');
				blue_d <= "1000";
			when 5 =>
				green_d <= (others => '1');
				red_d <= "1000";
				blue_d <= "1000";
			when 6 =>
				green_d <= "1000";
				red_d <= "1000";
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

		-- change the background color 
		if(volleycount > 20) then
			green_b <= (others => '0');
			red_b <= "1000";
			blue_b <= (others => '0');
		elsif(volleycount > 10) then
			green_b <= (others => '0');
			red_b <= (others => '0');
			blue_b <= "1000";
		else
			green_b <= (others => '0');
			red_b <= (others => '0');
			blue_b <= (others => '0');
		end if;

		-- make volleycount into 3 digits
		digit2 := volleycount/100;
		digit1 := (volleycount mod 100 ) / 10;
		digit0 := volleycount mod 10;

	IF(disp_ena = '1') THEN        --display time
	 
		-- 10 is the top boundary and 470 is the lower boundary
		if(row < 10 or row > 470) then
			green_int <= green_d;
			red_int <= red_d;
			blue_int <= blue_d;

			-- the middle border
		elsif(column < 330 and column > 310) then
			if(row > 30 and row < 65) then
			 	green_int <= green_d;
				red_int <= red_d;
				blue_int <= blue_d;
			elsif(row > 85 and row < 120) then
				green_int <= green_d;
				red_int <= red_d;
				blue_int <= blue_d;
			elsif(row > 140 and row < 175) then
				green_int <= green_d;
				red_int <= red_d;
				blue_int <= blue_d;
			elsif(row > 195 and row < 230) then
				green_int <= green_d;
				red_int <= red_d;
				blue_int <= blue_d;
			elsif(row > 250 and row < 285) then
				green_int <= green_d;
				red_int <= red_d;
				blue_int <= blue_d;
			elsif(row > 305 and row < 340) then
				green_int <= green_d;
				red_int <= red_d;
				blue_int <= blue_d;
			elsif(row > 360 and row < 395) then
				green_int <= green_d;
				red_int <= red_d;
				blue_int <= blue_d;
			elsif(row > 415 and row < 450) then
				green_int <= green_d;
				red_int <= red_d;
				blue_int <= blue_d;
			else
				green_int <= green_b;
				red_int <= red_b;
				blue_int <= blue_b;
			end if;

			-- The Left Wall
		elsif(column < 10) then
			--edit these columns using the rotary encoder.
			
			green_int <= green_d;
			red_int <= red_d;
			blue_int <= blue_d;
			

			-- The right paddle
		elsif(column > 620) then
			--edit these columns using the rotary encoder.
			if(row > counter_u and row < counter_l) then
				green_int <= (others => '1');
				red_int <= (others => '1');
				blue_int <= (others => '1');
			else
				green_int <= green_b;
				red_int <= red_b;
				blue_int <= blue_b;
			end if;
		
		-- displays the miscount on the screen	
		elsif (column > 360 and column < 440) then
			if (row > 32 and row < 72) then

				-- displays the miscount onto the screen, to the right of the middle border
				case(miscount) is
					when 0 =>
						if((row > 32 and row < 40) or (row > 63 and row < 72)) then
							if(column > 375 and column < 392) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 64) then
							if((column > 367 and column < 376) or (column > 391 and column < 400)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 1 =>
						if((row > 32 and row < 40) or (row > 47 and row < 64)) then
							if(column > 375 and column < 384) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 367 and column < 384) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 63 and row < 72) then
							if(column > 367 and column < 392) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 2 =>
						if(row > 32 and row < 40) then
							if(column > 375 and column < 392) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if((column > 367 and column < 376) or (column > 391 and column < 400)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 47 and row < 56) then
							if(column > 383 and column < 400) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 55 and row < 64) then
							if(column > 375 and column < 384) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 63 and row < 72) then
							if(column > 367 and column < 400) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 3 =>
						if((row > 32 and row < 40) or (row > 63 and row < 72)) then
							if(column > 367 and column < 392) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif((row > 39 and row < 48) or (row > 55 and row < 64)) then
							if(column > 391 and column < 400) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 47 and row < 56) then
							if(column > 375 and column < 392) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 4 =>
						if(row > 32 and row < 48) then
							if((column > 367 and column < 376) or (column > 383 and column < 392)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 47 and row < 56) then
							if(column > 367 and column < 400) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 55 and row < 72) then
							if(column > 383 and column < 392) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 5 =>
						if(row > 32 and row < 40) then
							if(column > 375 and column < 400) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 367 and column < 376) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif((row > 47 and row < 56) or (row > 63 and row < 72)) then
							if(column > 367 and column < 392) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 55 and row < 64) then
							if(column > 391 and column < 400) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 6 =>
						if(row > 32 and row < 40) then
							if(column > 375 and column < 400) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 367 and column < 376) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif((row > 47 and row < 56) or (row > 63 and row < 72)) then
							if(column > 367 and column < 392) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 55 and row < 64) then
							if((column > 367 and column < 376) or (column > 391 and column < 400)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 7 => 
						if(row > 32 and row < 40) then
							if(column > 367 and column < 400) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 391 and column < 400) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 47 and row < 56) then
							if(column > 383 and column < 392) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 55 and row < 72) then
							if(column > 375 and column < 384) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 8 =>
						if((row > 32 and row < 40) or (row > 47 and row < 56) or (row > 63 and row < 72)) then
							if(column > 375 and column < 392) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif((row > 39 and row < 48) or (row > 55 and row < 64)) then
							if((column > 367 and column < 376) or (column > 391 and column < 400)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 9 =>
						if((row > 32 and row < 40) or (row > 47 and row < 56)) then
							if(column > 375 and column < 400) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if((column > 367 and column < 376) or (column > 391 and column < 400)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 55 and row < 72) then
							if(column > 391 and column < 400) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 10 =>
						if(row > 32 and row < 40) then
							if(column > 375 and column < 384) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							elsif(column > 415 and column < 432) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 367 and column < 384) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							elsif((column > 407 and column < 416) or (column > 431 and column < 440)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 47 and row < 64) then
							if(column > 375 and column < 384) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							elsif((column > 407 and column < 416) or (column > 431 and column < 440)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 63 and row < 72) then
							if(column > 367 and column < 392) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							elsif(column > 415 and column < 432) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 11 =>
						if((row > 32 and row < 40) or (row > 47 and row < 64)) then
							if(column > 375 and column < 384) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							elsif(column > 415 and column < 424) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 367 and column < 384) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							elsif(column > 407 and column < 424) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 63 and row < 72) then
							if(column > 367 and column < 392) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							elsif(column > 407 and column < 432) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when others =>
						green_int <= green_b;
						red_int <= red_b;
						blue_int <= blue_b;
				end case;
				
			else
				green_int <= green_b;
				red_int <= red_b;
				blue_int <= blue_b;

			end if ;
			
		-- display the volleycount on the screen for digit0, the LSB		
		elsif (column > 240 and column < 280) then
			if (row > 32 and row < 72) then

				--360 to 400 and 400 to 440
				case(digit0) is
					when 0 =>
						if((row > 32 and row < 40) or (row > 63 and row < 72)) then
							if(column > 255 and column < 272) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 64) then
							if((column > 247 and column < 256) or (column > 271 and column < 280)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 1 =>
						if((row > 32 and row < 40) or (row > 47 and row < 64)) then
							if(column > 255 and column < 264) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 247 and column < 264) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 63 and row < 72) then
							if(column > 247 and column < 272) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 2 =>
						if(row > 32 and row < 40) then
							if(column > 255 and column < 272) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if((column > 247 and column < 256) or (column > 271 and column < 280)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 47 and row < 56) then
							if(column > 263 and column < 280) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 55 and row < 64) then
							if(column > 255 and column < 264) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 63 and row < 72) then
							if(column > 247 and column < 280) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 3 =>
						if((row > 32 and row < 40) or (row > 63 and row < 72)) then
							if(column > 247 and column < 272) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif((row > 39 and row < 48) or (row > 55 and row < 64)) then
							if(column > 271 and column < 280) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 47 and row < 56) then
							if(column > 255 and column < 272) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 4 =>
						if(row > 32 and row < 48) then
							if((column > 247 and column < 256) or (column > 263 and column < 272)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 47 and row < 56) then
							if(column > 247 and column < 280) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 55 and row < 72) then
							if(column > 263 and column < 272) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 5 =>
						if(row > 32 and row < 40) then
							if(column > 255 and column < 280) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 247 and column < 256) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif((row > 47 and row < 56) or (row > 63 and row < 72)) then
							if(column > 247 and column < 272) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 55 and row < 64) then
							if(column > 271 and column < 280) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 6 =>
						if(row > 32 and row < 40) then
							if(column > 255 and column < 280) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 247 and column < 256) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif((row > 47 and row < 56) or (row > 63 and row < 72)) then
							if(column > 247 and column < 272) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 55 and row < 64) then
							if((column > 247 and column < 256) or (column > 271 and column < 280)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 7 => 
						if(row > 32 and row < 40) then
							if(column > 247 and column < 280) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 271 and column < 280) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 47 and row < 56) then
							if(column > 263 and column < 272) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 55 and row < 72) then
							if(column > 255 and column < 264) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 8 =>
						if((row > 32 and row < 40) or (row > 47 and row < 56) or (row > 63 and row < 72)) then
							if(column > 255 and column < 272) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif((row > 39 and row < 48) or (row > 55 and row < 64)) then
							if((column > 247 and column < 256) or (column > 271 and column < 280)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 9 =>
						if((row > 32 and row < 40) or (row > 47 and row < 56)) then
							if(column > 255 and column < 280) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if((column > 247 and column < 256) or (column > 271 and column < 280)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 55 and row < 72) then
							if(column > 271 and column < 280) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;

					when others =>
						green_int <= green_b;
						red_int <= red_b;
						blue_int <= blue_b;

				end case;

			else
				green_int <= green_b;
				red_int <= red_b;
				blue_int <= blue_b;
			
			end if;

		-- display the volleycount on the screen for digit1, the 2nd bit			
		elsif (column > 200 and column < 240) then
			if (row > 32 and row < 72) then
				-- subtract 40 on all of the columns to make the second digit
				case(digit1) is
					when 0 =>
						if((row > 32 and row < 40) or (row > 63 and row < 72)) then
							if(column > 215 and column < 232) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 64) then
							if((column > 207 and column < 216) or (column > 231 and column < 240)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 1 =>
						if((row > 32 and row < 40) or (row > 47 and row < 64)) then
							if(column > 215 and column < 224) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 207 and column < 224) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 63 and row < 72) then
							if(column > 207 and column < 232) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 2 =>
						if(row > 32 and row < 40) then
							if(column > 215 and column < 232) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if((column > 207 and column < 216) or (column > 231 and column < 240)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 47 and row < 56) then
							if(column > 223 and column < 240) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 55 and row < 64) then
							if(column > 215 and column < 224) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 63 and row < 72) then
							if(column > 207 and column < 240) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 3 =>
						if((row > 32 and row < 40) or (row > 63 and row < 72)) then
							if(column > 207 and column < 232) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif((row > 39 and row < 48) or (row > 55 and row < 64)) then
							if(column > 231 and column < 240) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 47 and row < 56) then
							if(column > 215 and column < 232) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 4 =>
						if(row > 32 and row < 48) then
							if((column > 207 and column < 216) or (column > 223 and column < 232)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 47 and row < 56) then
							if(column > 207 and column < 240) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 55 and row < 72) then
							if(column > 223 and column < 232) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 5 =>
						if(row > 32 and row < 40) then
							if(column > 215 and column < 240) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 207 and column < 216) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif((row > 47 and row < 56) or (row > 63 and row < 72)) then
							if(column > 207 and column < 232) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 55 and row < 64) then
							if(column > 231 and column < 240) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 6 =>
						if(row > 32 and row < 40) then
							if(column > 215 and column < 240) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 207 and column < 216) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif((row > 47 and row < 56) or (row > 63 and row < 72)) then
							if(column > 207 and column < 232) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 55 and row < 64) then
							if((column > 207 and column < 216) or (column > 231 and column < 240)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 7 => 
						if(row > 32 and row < 40) then
							if(column > 207 and column < 240) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 231 and column < 240) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 47 and row < 56) then
							if(column > 223 and column < 232) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 55 and row < 72) then
							if(column > 215 and column < 224) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 8 =>
						if((row > 32 and row < 40) or (row > 47 and row < 56) or (row > 63 and row < 72)) then
							if(column > 215 and column < 232) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif((row > 39 and row < 48) or (row > 55 and row < 64)) then
							if((column > 207 and column < 216) or (column > 231 and column < 240)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 9 =>
						if((row > 32 and row < 40) or (row > 47 and row < 56)) then
							if(column > 215 and column < 240) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if((column > 207 and column < 216) or (column > 231 and column < 240)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 55 and row < 72) then
							if(column > 231 and column < 240) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
				

					when others =>
						green_int <= green_b;
						red_int <= red_b;
						blue_int <= blue_b;

				end case;

			else
				green_int <= green_b;
				red_int <= red_b;
				blue_int <= blue_b;

			end if;


		-- display the volleycount on the screen for digit2, the MSB	
		elsif (column > 160 and column < 200) then
			if (row > 32 and row < 72) then			
				-- subtract 80 on all of the columns to make the second digit
				case(digit2) is
					when 0 =>
						if((row > 32 and row < 40) or (row > 63 and row < 72)) then
							if(column > 175 and column < 192) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 64) then
							if((column > 167 and column < 176) or (column > 191 and column < 200)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 1 =>
						if((row > 32 and row < 40) or (row > 47 and row < 64)) then
							if(column > 175 and column < 184) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 167 and column < 184) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 63 and row < 72) then
							if(column > 167 and column < 192) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 2 =>
						if(row > 32 and row < 40) then
							if(column > 175 and column < 192) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if((column > 167 and column < 176) or (column > 191 and column < 200)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 47 and row < 56) then
							if(column > 183 and column < 200) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 55 and row < 64) then
							if(column > 175 and column < 184) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 63 and row < 72) then
							if(column > 167 and column < 200) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 3 =>
						if((row > 32 and row < 40) or (row > 63 and row < 72)) then
							if(column > 167 and column < 192) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif((row > 39 and row < 48) or (row > 55 and row < 64)) then
							if(column > 191 and column < 200) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 47 and row < 56) then
							if(column > 175 and column < 192) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 4 =>
						if(row > 32 and row < 48) then
							if((column > 167 and column < 176) or (column > 183 and column < 192)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 47 and row < 56) then
							if(column > 167 and column < 200) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 55 and row < 72) then
							if(column > 183 and column < 192) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 5 =>
						if(row > 32 and row < 40) then
							if(column > 175 and column < 200) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 167 and column < 176) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif((row > 47 and row < 56) or (row > 63 and row < 72)) then
							if(column > 167 and column < 192) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 55 and row < 64) then
							if(column > 191 and column < 200) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 6 =>
						if(row > 32 and row < 40) then
							if(column > 175 and column < 200) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 167 and column < 176) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif((row > 47 and row < 56) or (row > 63 and row < 72)) then
							if(column > 167 and column < 192) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 55 and row < 64) then
							if((column > 167 and column < 176) or (column > 191 and column < 200)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 7 => 
						if(row > 32 and row < 40) then
							if(column > 167 and column < 200) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if(column > 191 and column < 200) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 47 and row < 56) then
							if(column > 183 and column < 192) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 55 and row < 72) then
							if(column > 175 and column < 184) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 8 =>
						if((row > 32 and row < 40) or (row > 47 and row < 56) or (row > 63 and row < 72)) then
							if(column > 175 and column < 192) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif((row > 39 and row < 48) or (row > 55 and row < 64)) then
							if((column > 167 and column < 176) or (column > 191 and column < 200)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
					when 9 =>
						if((row > 32 and row < 40) or (row > 47 and row < 56)) then
							if(column > 175 and column < 200) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 39 and row < 48) then
							if((column > 167 and column < 176) or (column > 191 and column < 200)) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						elsif(row > 55 and row < 72) then
							if(column > 191 and column < 200) then
								green_int <= green_d;
								red_int <= red_d;
								blue_int <= blue_d;
							else
								green_int <= green_b;
								red_int <= red_b;
								blue_int <= blue_b;
							end if;
						else
							green_int <= green_b;
							red_int <= red_b;
							blue_int <= blue_b;
						end if;
				


					when others =>
						green_int <= green_b;
						red_int <= red_b;
						blue_int <= blue_b;

				end case;

			else
				green_int <= green_b;
				red_int <= red_b;
				blue_int <= blue_b;

			end if ;
				
			
		else 
			green_int <= green_b;
			red_int <= red_b;
			blue_int <= blue_b;
		end if;
			
		--affecting the paddle	
		-- less than 10 is the left paddle and greater than 620 is the right paddle
		-- elsif(column < 10 or column > 620) then
		-- 	--edit these columns using the rotary encoder.
		-- 	if(row > counter_u and row < counter_l) then
		-- 		green_int <= (others => '1');
		-- 		 red_int <= (others => '1');
		-- 		blue_int <= (others => '1');
		-- 	else
		-- 		green_int <= (others => '0');
		-- 		 red_int <= (others => '0');
		-- 		blue_int <= (others => '0');
		-- 	end if;
		-- else 
		-- 	green_int <= (others => '0');
		-- 	 red_int <= (others => '0');
		-- 	blue_int <= (others => '0');
		-- end if;
		

		-- Sets up the display for the mask
		if(row > min_row and row < max_row) then
			if(column > min_col and column < max_col) then
				red <= (others => '1');
				green <= (others => '1');
				blue <= (others => '1');
			else
				red <= red_int;
				green <= green_int;
				blue <= blue_int;
			end if;
		else
				red <= red_int;
				green <= green_int;
				blue <= blue_int;
		end if;

    ELSE                           --blanking time
      green <= (others => '0');
		red <= (others => '0');
		blue <= (others => '0');
    END IF;
  END PROCESS;
  
  -- the rotary encoder process
  process(Clocking, CLK, DT, miscount, reset)
  
  begin	
	if (rising_edge(Clocking)) then
		--debouncing if condition


		if (miscount >= 11) then

			if (reset = '0') then
				countReset <= '1';
				counter_u <= 210;
			else 
				countReset <= '0';
			end if;
		end if;

		if(count > 999) then 
			count <= 0;

						
			--could add boundry check up here instead to reduce description
			--check state and direction of rotary encoder/paddle
			if(CLK /= CLK_i) then
				--left = up
				if(DT /= CLK) then
					if(counter_u > 410) then
						counter_u <= 411; -- boundary checks for the bottom
					else
						counter_u <= counter_u + 10; 
					end if;
				--right = down
				else
					if(counter_u < 10) then
						counter_u <= 9; -- boundary checks for the top
					else
						counter_u <= counter_u - 10; 
					end if;
				end if;
			else
				if(counter_u > 410) then
						counter_u <= 411; -- boundary checks for the bottom
				elsif(counter_u < 10) then
						counter_u <= 9; -- boundary checks for the top
				else
					counter_u <= counter_u; -- makes sure counter_u is updated
				end if;
			end if;
			CLK_i <= CLK;
		else
			count <= count + 1; -- updates the count 
		end if;
	end if;
  end process;
  
END behavior;
