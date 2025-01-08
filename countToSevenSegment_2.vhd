---------------------------------
-- Tate Finley and Lewis Bates
-- ECE 3140
-- Tate's email: tafinley43@tntech.edu
-- Lewis's email: lfbates42@tntech.edu
-- countToSevenSegment_2: increment seven segment display
-- according to passed in number
---------------------------------

library   ieee;
use       ieee.std_logic_1164.all;

entity countToSevenSegment_2 is
	port ( number : IN integer;
			 hex_disp1 : OUT STD_LOGIC_VECTOR(7 downto 0);
			 hex_disp2 : OUT STD_LOGIC_VECTOR(7 downto 0);
			 hex_disp3 : OUT STD_LOGIC_VECTOR(7 downto 0)
			 );
end countToSevenSegment_2;

architecture behavioral of countToSevenSegment_2 is
signal digit2, digit1, digit0 : integer;
begin
	digit2 <= number/100;
	digit1 <= (number mod 100 ) / 10;
	digit0 <= number mod 10;
	
	process(digit0)
	begin
		case(digit0) is
			when 0 => hex_disp1 <= "11000000";
			when 1 => hex_disp1 <= "11111001";
			when 2 => hex_disp1 <= "10100100";
			when 3 => hex_disp1 <= "10110000";
			when 4 => hex_disp1 <= "10011001";
			when 5 => hex_disp1 <= "10010010";
			when 6 => hex_disp1 <= "10000010";
			when 7 => hex_disp1 <= "11111000";
			when 8 => hex_disp1 <= "10000000";
			when 9 => hex_disp1 <= "10011000";
			when others => hex_disp1 <= "11111111";
		end case;
	end process;
	
	process(digit1)
	begin
		case(digit1) is
			when 0 => hex_disp2 <= "11000000";
			when 1 => hex_disp2 <= "11111001";
			when 2 => hex_disp2 <= "10100100";
			when 3 => hex_disp2 <= "10110000";
			when 4 => hex_disp2 <= "10011001";
			when 5 => hex_disp2 <= "10010010";
			when 6 => hex_disp2 <= "10000010";
			when 7 => hex_disp2 <= "11111000";
			when 8 => hex_disp2 <= "10000000";
			when 9 => hex_disp2 <= "10011000";
			when others => hex_disp2 <= "11111111";
		end case;
	end process;
	
	process(digit2)
	begin
		case(digit2) is
			when 0 => hex_disp3 <= "11000000";
			when 1 => hex_disp3 <= "11111001";
			when 2 => hex_disp3 <= "10100100";
			when 3 => hex_disp3 <= "10110000";
			when 4 => hex_disp3 <= "10011001";
			when 5 => hex_disp3 <= "10010010";
			when 6 => hex_disp3 <= "10000010";
			when 7 => hex_disp3 <= "11111000";
			when 8 => hex_disp3 <= "10000000";
			when 9 => hex_disp3 <= "10011000";
			when others => hex_disp3 <= "11111111";
		end case;
	end process;
	
end behavioral;