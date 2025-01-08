---------------------------------
-- Tate Finley and Lewis Bates
-- ECE 3140
-- pong2: two player pong 
--	(pong implementation)
---------------------------------


library   ieee;
use       ieee.std_logic_1164.all;

entity pong2b is
	
	port(
	
		-- Inputs for image generation
		
		pixel_clk_m		:	IN	STD_LOGIC;     -- pixel clock for VGA mode being used 
		reset_n_m		:	IN	STD_LOGIC; --active low asycnchronous reset
		
		-- Outputs for image generation 
		
		h_sync_m		:	OUT	STD_LOGIC;	--horiztonal sync pulse
		v_sync_m		:	OUT	STD_LOGIC;	--vertical sync pulse 
		
		--player 1
		ARDUINO_IO6 : 	INOUT		STD_LOGIC; 
		ARDUINO_IO7 : 	INOUT 	STD_LOGIC;
		
		--player 2
		ARDUINO_IO2 : 	INOUT		STD_LOGIC; 
		ARDUINO_IO3 : 	INOUT 	STD_LOGIC;
		
		--buzzer
		ARDUINO_IO12 : INOUT 		STD_LOGIC;
		
		--reset
		KEY0 			: 	IN 		STD_LOGIC;
		
		--tallies
		HEX0,HEX1,HEX4,HEX5 : OUT STD_LOGIC_VECTOR(7 downto 0);
		
		red_m      :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
		green_m    :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
		blue_m     :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0') --blue magnitude output to DAC
		
	
	);
	
end pong2b;

architecture vga of pong2b is

	component vga_pll_25_175 IS
	PORT
	(
		inclk0		: IN STD_LOGIC  := '0'; --clock of board (50 MHz)
		c0		: OUT STD_LOGIC   --clock for vga display (25.175 MHz)
		--c1		: OUT STD_LOGIC    --clock for buzzer sounds (16.777 MHz)
	);
	END component;
	
	component vga_controller is 
	
		port(
		
			pixel_clk	:	IN	STD_LOGIC;	--pixel clock at frequency of VGA mode being used
			reset_n		:	IN	STD_LOGIC;	--active low asycnchronous reset
			h_sync		:	OUT	STD_LOGIC;	--horiztonal sync pulse
			v_sync		:	OUT	STD_LOGIC;	--vertical sync pulse
			disp_ena	:	OUT	STD_LOGIC;	--display enable ('1' = display time, '0' = blanking time)
			column		:	OUT	INTEGER;	--horizontal pixel coordinate
			row			:	OUT	INTEGER;	--vertical pixel coordinate
			n_blank		:	OUT	STD_LOGIC;	--direct blacking output to DAC
			n_sync		:	OUT	STD_LOGIC   --sync-on-green output to DAC
		
		);
		
	end component;
	
	component hw_image_generator is
	
		port(
			reset_dis : IN STD_LOGIC;
			Clocking : IN STD_LOGIC;
			DT : INOUT   STD_LOGIC;
			CLK :  INOUT  STD_LOGIC;
			DT2 :  INOUT  STD_LOGIC;
			CLK2 : INOUT   STD_LOGIC;
			disp_ena :  IN  STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
			row      :  IN  INTEGER;    --row pixel coordinate
			column   :  IN  INTEGER;    --column pixel coordinate
			countL	 :  buffer  INTEGER;
			countR	 :  buffer  INTEGER;
			volleyCount : buffer INTEGER;
			rowBounce : buffer INTEGER;
			red      :  OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
			green    :  OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
			blue     :  OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0')   --blue magnitude output to DAC
		
		);
		
	end component;
	
	component countToSevenSegment is
	port ( number : IN integer;
			 hex_disp1 : OUT STD_LOGIC_VECTOR(7 downto 0);
			 hex_disp2 : OUT STD_LOGIC_VECTOR(7 downto 0));
	end component;
	
	component dual_boot is 
	port (
			clk_clk       : in std_logic := 'X'; -- clk
			reset_reset_n : in std_logic := 'X'  -- reset_n
		);
	end component dual_boot;
	
	
	signal pll_OUT_to_vga_controller_IN, dispEn : STD_LOGIC;
	--signal buzzingCLK : STD_LOGIC;
	signal rowSignal, colSignal : INTEGER;
	signal reset : std_logic;
	signal player1, player2, hit, hit_tb : integer := 0;
	--signal reset_c : std_logic;
	--constant counter_bit : integer := 18;
	--signal counter : std_logic_vector(17 downto 0);
	--signal reset_counter : std_logic_vector(17 downto 0) := (others => '0');
	
begin
	process(KEY0)
	begin
		if(KEY0 = '0') then
			reset <= '1';
		else 
			reset <= '0';
		end if;
	end process;

	u0 : component dual_boot port map (clk_clk => pixel_clk_m, reset_reset_n => reset_n_m);
-- Just need 3 components for VGA system 
	U1	:	vga_pll_25_175 port map(pixel_clk_m, pll_OUT_to_vga_controller_IN);
	U2	:	vga_controller port map(pll_OUT_to_vga_controller_IN, reset_n_m, h_sync_m, v_sync_m, dispEn, colSignal, rowSignal, open, open);
	U3	:	hw_image_generator port map(reset, pixel_clk_m, ARDUINO_IO6, ARDUINO_IO7, ARDUINO_IO2, ARDUINO_IO3, dispEn, rowSignal, colSignal, player1, player2, hit, hit_tb, red_m, green_m, blue_m);
	U4 :  countToSevenSegment port map(player1, HEX4, HEX5);
	U5 :	countToSevenSegment port map(player2, HEX0, HEX1);
	--U6: ripple_counter generic map (n => counter_bit)
	--		port map (clk => buzzingCLK, clear => reset_c, dout => counter);
	
	process(hit_tb, hit, ARDUINO_IO12, pixel_clk_m)
	variable bounce_tb, bounce : integer := 0;
	begin
		if(rising_edge(pixel_clk_m)) then
			--whenever score changes
			if(hit_tb /= bounce_tb) then
				--set new score
				bounce_tb := hit_tb;
				ARDUINO_IO12 <= not ARDUINO_IO12;
			end if;
			if(hit /= bounce) then
				ARDUINO_IO12 <= not ARDUINO_IO12;
				bounce := hit;
			end if;	
		end if;
	end process;
	

end vga;