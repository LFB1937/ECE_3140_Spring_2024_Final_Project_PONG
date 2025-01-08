---------------------------------
-- Tate Finley and Lewis Bates
-- ECE 3140
-- pong2: two player pong 
--	(pong implementation)
---------------------------------


library   ieee;
use       ieee.std_logic_1164.all;

entity pong2a is
	
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
		
		--accelerometer
		G_SENSOR_CS_N : OUT	STD_LOGIC;
		G_SENSOR_SCLK : OUT	STD_LOGIC;
		G_SENSOR_SDI  : INOUT	STD_LOGIC;
		G_SENSOR_SDO  : INOUT	STD_LOGIC;
		
		--reset
		KEY0 			: 	IN 		STD_LOGIC;
		
		--tallies
		HEX0,HEX1,HEX4,HEX5 : OUT STD_LOGIC_VECTOR(7 downto 0);
		
		red_m      :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
		green_m    :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
		blue_m     :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0') --blue magnitude output to DAC
		
	
	);
	
end pong2a;

architecture vga of pong2a is

	component vga_pll_25_175 is 
	
		port(
		
			inclk0		:	IN  STD_LOGIC := '0';  -- Input clock that gets divided (50 MHz for max10)
			c0			:	OUT STD_LOGIC          -- Output clock for vga timing (25.175 MHz)
		
		);
		
	end component;
	
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
	
	component ADXL345_controller is
	port (
		reset_n     : IN STD_LOGIC;
		clk         : IN STD_LOGIC;
		data_valid  : OUT STD_LOGIC;
		data_x      : OUT STD_LOGIC_VECTOR(15 downto 0);
		data_y      : OUT STD_LOGIC_VECTOR(15 downto 0);
		data_z      : OUT STD_LOGIC_VECTOR(15 downto 0);
		SPI_SDI     : OUT STD_LOGIC;
		SPI_SDO     : IN STD_LOGIC;
		SPI_CSN     : OUT STD_LOGIC;
		SPI_CLK     : OUT STD_LOGIC
	);
	end component; 
	
	component hw_image_generator is
	
		port(
			reset_dis : IN STD_LOGIC;
			Clocking : IN STD_LOGIC;
			DT : INOUT    STD_LOGIC;
			CLK :  INOUT  STD_LOGIC;
			tilt : IN     STD_LOGIC;
			stay : IN     STD_LOGIC;
			disp_ena :  IN  STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
			row      :  IN  INTEGER;    --row pixel coordinate
			column   :  IN  INTEGER;    --column pixel coordinate
			countL	 :  buffer  INTEGER;
			countR	 :  buffer  INTEGER;
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
	signal rowSignal, colSignal : INTEGER;
	signal reset : std_logic;
	signal player1, player2 : integer := 0;
	signal data_x, data_y, data_z : std_logic_vector(15 downto 0);
	signal tilt, stay : std_logic;
	
	
begin
	process(KEY0)
	begin
		if(KEY0 = '0') then
			reset <= '1';
		else 
			reset <= '0';
		end if;
	end process;

	u0 : dual_boot port map (clk_clk  => pixel_clk_m, reset_reset_n => reset_n_m);
-- Just need 3 components for VGA system 
	U1	:	vga_pll_25_175 port map(pixel_clk_m, pll_OUT_to_vga_controller_IN);
	U2	:	vga_controller port map(pll_OUT_to_vga_controller_IN, reset_n_m, h_sync_m, v_sync_m, dispEn, colSignal, rowSignal, open, open);
	U3 :  ADXL345_controller port map('1', pixel_clk_m, open, data_x, data_y, data_z, G_SENSOR_SDI, G_SENSOR_SDO, G_SENSOR_CS_N, G_SENSOR_SCLK);
	
	process(data_x)
	begin
		if(data_x(11) = '1') then
			--down
			tilt <= '0';
			if(data_x(7) = '1' and data_x(6) = '1') then
				stay <= '1';
			else
				stay <= '0';
			end if;
		else
			--up
			tilt <= '1';
			if(data_x(7) = '0' and data_x(6) = '0') then
				stay <= '1';
			else
				stay <= '0';
			end if;
		end if;
	end process;
	
	U4	:	hw_image_generator port map(reset, pixel_clk_m, ARDUINO_IO6, ARDUINO_IO7, tilt, stay, dispEn, rowSignal, colSignal, player1, player2, red_m, green_m, blue_m);
	U5 :  countToSevenSegment port map(player1, HEX4, HEX5);
	U6 :	countToSevenSegment port map(player2, HEX0, HEX1);

end vga;