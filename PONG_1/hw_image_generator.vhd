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
   red      :  out  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
   green    :  out  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
   blue     :  out  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to DAC
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS

signal CLK_i : std_logic; --initial state of clock input
signal counter_u : integer := 210; --paddle position top
signal green_int, red_int, blue_int : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); -- the values for the color signals
signal bounceC, bounceR, countReset : std_logic;

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

  BEGIN
 	max_col := min_col + 32;
  	max_row := min_row + 32;
	counter_l := counter_u + 60; --paddle width
	--pong display
	
		-- create the reset feature for the ball
		
	
		-- The clock cycle to  set up the bouncing for the columns & rows
		if(rising_edge(Clocking)) then
			if(counter > 600000) then -- 600000
				counter := 0;
				
				if(reset = '1' and countReset = '0') then
					bounceC <= '1';
					miscount <= 0;
					volleycount <= 0;
					min_row := 224;
					min_col := 304;		

				-- resets the ball position & the miscount
				elsif (reset = '1') then
					bounceC <= '1';
					miscount <= 0;
					volleycount <= 0;
					min_row := 224;
					min_col := 304;	
				else
						
						if(bounceC = '1') then
							min_col := min_col - 1; -- min_col goes left
						else
							min_col := min_col + 1; -- min_col goes right
						end if;
						if(bounceR = '1') then
							min_row := min_row - 1; -- min_row goes left
						else
							min_row := min_row + 1; -- min_row goes right
						end if;
						
						-- boundary for the borders
						if(max_row > 470) then
							bounceR <= '1';
						elsif(min_row < 10) then
							bounceR <= '0';
						end if;
						
						-- boundary for the paddle
						if(max_col > 620 and  max_row > counter_u and min_row < counter_l) then
							bounceC <= '1';

						elsif (max_col > 640 ) then
							-- if (bounceC = '0') then
								miscount <= miscount + 1;						
							-- end if ;
							--bounceC <= '1';
							--reset <= '1';
							min_row := 224;
							min_col := 304;	
							
						-- left wall	
						elsif(min_col < 10 ) then
							if (bounceC = '1') then
								volleycount <= volleycount + 1;						
							end if ;
							bounceC <= '0';

						end if;
						
						if (miscount >= 11) then
							miscount <= miscount;
							volleycount <= volleycount;
							min_row := 224;
							min_col := 304;
						end if;	
				end if;	
			else
				counter := counter + 1;
			end if;
		end if;
	
	IF(disp_ena = '1') THEN        --display time
	 
	-- 10 is the top boundary and 470 is the lower boundary
		if(row < 10 or row > 470) then
			green_int <= (others => '1');
			red_int <= (others => '1');
			blue_int <= (others => '1');

		-- the middle border
		elsif(column < 330 and column > 310) then
			if(row > 30 and row < 65) then
				green_int <= (others => '1');
				red_int <= (others => '1');
				blue_int <= (others => '1');
			elsif(row > 85 and row < 120) then
				green_int <= (others => '1');
				red_int <= (others => '1');
				blue_int <= (others => '1');
			elsif(row > 140 and row < 175) then
				green_int <= (others => '1');
				red_int <= (others => '1');
				blue_int <= (others => '1');
			elsif(row > 195 and row < 230) then
				green_int <= (others => '1');
				red_int <= (others => '1');
				blue_int <= (others => '1');
			elsif(row > 250 and row < 285) then
				green_int <= (others => '1');
				red_int <= (others => '1');
				blue_int <= (others => '1');
			elsif(row > 305 and row < 340) then
				green_int <= (others => '1');
				red_int <= (others => '1');
				blue_int <= (others => '1');
			elsif(row > 360 and row < 395) then
				green_int <= (others => '1');
				red_int <= (others => '1');
				blue_int <= (others => '1');
			elsif(row > 415 and row < 450) then
				green_int <= (others => '1');
				red_int <= (others => '1');
				blue_int <= (others => '1');
			else
				green_int <= (others => '0');
				red_int <= (others => '0');
				blue_int <= (others => '0');
			end if;

		-- The Left Wall
		elsif(column < 10) then
			--edit these columns using the rotary encoder.
			
				green_int <= (others => '1');
				red_int <= (others => '1');
				blue_int <= (others => '1');
			

		-- The right paddle
		elsif(column > 620) then
			--edit these columns using the rotary encoder.
			if(row > counter_u and row < counter_l) then
				green_int <= (others => '1');
				red_int <= (others => '1');
				blue_int <= (others => '1');
			else
				green_int <= (others => '0');
				red_int <= (others => '0');
				blue_int <= (others => '0');
			end if;
		else 
			green_int <= (others => '0');
			red_int <= (others => '0');
			blue_int <= (others => '0');
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
  Variable count: integer := 0;
  
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
			count := 0;

						
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
			count := count + 1; -- updates the count 
		end if;
	end if;
  end process;
  
END behavior;
