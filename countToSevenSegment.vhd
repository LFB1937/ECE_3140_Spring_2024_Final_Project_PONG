----------------------------------------------------
-- Tate Finley and Lewis Bates
-- ECE 3140
-- countToSevenSegment: increment seven segment display
-- according to passed in number
---------------------------------------------------

library   ieee;
use       ieee.std_logic_1164.all;

entity countToSevenSegment is
	port ( number : IN integer;
			 hex_disp1 : OUT STD_LOGIC_VECTOR(7 downto 0);
			 hex_disp2 : OUT STD_LOGIC_VECTOR(7 downto 0));
end countToSevenSegment;

architecture behavioral of countToSevenSegment is
signal digit1, digit0 : integer;
begin
	digit1 <= number/10; -- second digit
	digit0 <= number mod 10; --first digit
	
	process(digit0)
	begin
		--display number
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
		--display number
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
	
end behavioral;