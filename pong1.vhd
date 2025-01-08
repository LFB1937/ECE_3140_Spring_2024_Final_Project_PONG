---------------------------------
-- Tate Finley and Lewis Bates
-- ECE 3140
-- Tate's email: tafinley43@tntech.edu
-- Lewis's email: lfbates42@tntech.edu
-- pong1: move paddle with rotary encoder 
--	(pong implementation)
---------------------------------


library   ieee;
use       ieee.std_logic_1164.all;

entity pong1 is
	
	port(
	
		-- Inputs for image generation
		
		pixel_clk_m		:	IN	STD_LOGIC;     -- pixel clock for VGA mode being used 
		reset_n_m		:	IN	STD_LOGIC; --active low asycnchronous reset
		
		-- Outputs for image generation 
		
		h_sync_m		:	OUT	STD_LOGIC;	--horiztonal sync pulse
		v_sync_m		:	OUT	STD_LOGIC;	--vertical sync pulse 
		
		ARDUINO_IO6 : 	INOUT	STD_LOGIC; 
		ARDUINO_IO7 : 	INOUT 	STD_LOGIC;

		KEY0	:	IN	STD_LOGIC;

		HEX0	:	OUT STD_LOGIC_VECTOR(7 downto 0);
		HEX1	:	OUT STD_LOGIC_VECTOR(7 downto 0);
		HEX2	:	OUT STD_LOGIC_VECTOR(7 downto 0);

		HEX4	:	OUT STD_LOGIC_VECTOR(7 downto 0);
		HEX5	:	OUT STD_LOGIC_VECTOR(7 downto 0);
		
		red_m      :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
		green_m    :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
		blue_m     :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0') --blue magnitude output to DAC
		
	
	);
	
end pong1;

architecture vga of pong1 is

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
	
	component hw_image_generator is
	
		port(
			Clocking : IN STD_LOGIC;
			CLK :  INOUT  STD_LOGIC;
			DT : INOUT   STD_LOGIC;
			disp_ena :  IN  STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
			reset	 :  IN STD_LOGIC;
			row      :  IN  INTEGER;    --row pixel coordinate
			column   :  IN  INTEGER;    --column pixel coordinate
			miscount	:  buffer 	INTEGER := 0; -- keeps track of the miscount
			volleycount :  buffer	INTEGER := 0; -- keeps track of the volleycount
			red      :  OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
			green    :  OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
			blue     :  OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0')   --blue magnitude output to DAC
		
		);
		
	end component;

	component countToSevenSegment is
		port ( number : IN integer;
				 hex_disp1 : OUT STD_LOGIC_VECTOR(7 downto 0);
				 hex_disp2 : OUT STD_LOGIC_VECTOR(7 downto 0)
				 );
	end component;
	
	component countToSevenSegment_2 is
	port ( number : IN integer;
			 hex_disp1 : OUT STD_LOGIC_VECTOR(7 downto 0);
			 hex_disp2 : OUT STD_LOGIC_VECTOR(7 downto 0);
			 hex_disp3 : OUT STD_LOGIC_VECTOR(7 downto 0)
			 );
	end component;
	
	component dual_boot is
		port (
			clk_clk       : in std_logic := 'X'; -- clk
			reset_reset_n : in std_logic := 'X'  -- reset_n
		);
	end component dual_boot;
	
	signal pll_OUT_to_vga_controller_IN, dispEn, reset : STD_LOGIC;
	signal rowSignal, colSignal : INTEGER;
	signal mis_count, volley_count : INTEGER := 0;
	
begin

	process(KEY0)
	begin
		-- Resets the KEY0 input
		if KEY0 = '0' then
			reset <= '1';
		else 
			reset <= '0';
		end if ;
	end process;

		u0 : component dual_boot
		port map (
			clk_clk       => pixel_clk_m,       --   clk.clk
			reset_reset_n => reset_n_m  -- reset.reset_n
		);
	
-- Just need 3 components for VGA system 
	U1	:	vga_pll_25_175 port map(pixel_clk_m, pll_OUT_to_vga_controller_IN);
	U2	:	vga_controller port map(pll_OUT_to_vga_controller_IN, reset_n_m, h_sync_m, v_sync_m, dispEn, colSignal, rowSignal, open, open);
	U3	:	hw_image_generator port map(pixel_clk_m, ARDUINO_IO6, ARDUINO_IO7, dispEn, reset, rowSignal, colSignal, mis_count, volley_count, red_m, green_m, blue_m);
	
	U4	: countToSevenSegment port map(mis_count, HEX4, HEX5);
	U5	: countToSevenSegment_2 port map(volley_count, HEX0, HEX1, HEX2);

end vga;