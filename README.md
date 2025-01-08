# ECE_3140_Spring_2024_Final_Project_PONG
This is the repository for the final project that Tate Finley and I did for Dr. JW Bruce's ECE 3140 class.

The target hardware that we used for this project was the DE-10 Lite from TerASIC Inc.
The board can be found at the following link:
https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=218&No=1021&PartNo=1#contents

The HTML file "project_pong.rst" contains all of the design requirements and specifications that we were asked to meet and, if possible, exceed.



-- Implementation for Pong1

	- has a paddle on the right side that is operated by the rotary encoder.
		- counterclockwise turns make the paddle turn down, clockwise turns make the paddle turn up.
	
	- KEY0 resets the ball position, 7 segment displays, volley count, and the miscount.

	- HEX0 - HEX2  display the volley count, while HEX5 & HEX4 display the miscount.

	- locks the paddle, and the position of the ball in the center of the board when the miscount 
		reaches 11, thsi is to signify that the game is over.


-- Implementation for Pong1A

	- has a paddle on the right side that is operated by the ADXL345_controller acclerometer.
	
	- KEY0 resets the ball position, 7 segment displays, volley count, and the miscount.

	- HEX0 - HEX2  display the volley count, while HEX5 & HEX4 display the miscount.

	- locks the paddle, and the position of the ball in the center of the board when the miscount 
		reaches 11, thsi is to signify that the game is over.


-- Implementation for Pong1B

	- has a paddle on the right side that is operated by the rotary encoder.
		- counterclockwise turns make the paddle turn down, clockwise turns make the paddle turn up.
	
	- KEY0 resets the ball position, 7 segment displays, volley count, and the miscount.

	- HEX0 - HEX2  display the volley count, while HEX5 & HEX4 display the miscount.

	- locks the paddle, and the position of the ball in the center of the board when the miscount 
		reaches 11, thsi is to signify that the game is over.

	- Puts English Spin on the ball when the ball hits the paddle from the very top or the very bottom,
		and does not put spin on the ball if it hits the center of the paddle.

	- alternates colors for the border, middle border, and numbers display upon every set in the game.
	
	- changes the background display when the score is greater than 10 points, and when the score is greater than 20 points.
	
	- the buzzer ticks everytime it hits the border or paddle.

	- displays the volley count on the left of the border and the miscount on the right of the border.


-- Implementation for Pong2

	- has two paddles one on the right side, and one on the left side. Both are operated by a single rotary encoder.
		- counterclockwise turns make the paddle turn down, clockwise turns make the paddle turn up.
	
	- KEY0 resets the ball position, 7 segment displays, right score count, and the left score count.

	- HEX0 & HEX1 display the right score count, while HEX5 & HEX4 display the left score count.

	- locks the paddle, and the position of the ball in the center of the board when either score count 
		reaches 11, thsi is to signify that the game is over.


-- Implementation for Pong2A

	- has two paddles one on the right side, and one on the left side. 
		- The left is operated by a single rotary encoder.
		- the right paddle is operated by the acclerometer.
		- counterclockwise turns of the rotary encoder make the paddle turn down, clockwise turns make the paddle turn up.
		- right tilts of the board make it go up, and left tilts make it go down.
	
	- KEY0 resets the ball position, 7 segment displays, right score count, and the left score count.

	- HEX0 & HEX1 display the right score count, while HEX5 & HEX4 display the left score count.

	- locks the paddle, and the position of the ball in the center of the board when either score count 
		reaches 11, thsi is to signify that the game is over.

-- Implementation for Pong2B

	- has two paddles one on the right side, and one on the left side. Both are operated by a single rotary encoder.
		- counterclockwise turns make the paddle turn down, clockwise turns make the paddle turn up.
	
	- KEY0 resets the ball position, 7 segment displays, right score count, and the left score count.

	- HEX0 & HEX1 display the right score count, while HEX5 & HEX4 display the left score count.

	- locks the paddle, and the position of the ball in the center of the board when either score count 
		reaches 11, thsi is to signify that the game is over.

	- Puts English Spin on the ball when the ball hits the paddle from the very top or the very bottom,
		and does not put spin on the ball if it hits the center of the paddle.

	- alternates colors for the border, middle border, and numbers display upon every set in the game.
	
	- changes the background display when that player is winning.
	
	- the buzzer ticks everytime it hits the border or paddle.

	- displays the player 1 on the left of the border and the player 2 on the right of the border.

	- the paddles are color coded, left is red and right is blue.

	- the ball changes colors, shrinks, and speeds up for long volley counts.

