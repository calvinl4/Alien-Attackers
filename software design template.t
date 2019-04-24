%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Programmer  : Calvin Lin
% Teacher     : Mr. Chow
% Course      : ICS3U1
%
% Program Name: ICS 3U1 Final project. Alien Attackers
% Description : Parody of the game Space Invaders or Galaga. Instructions of how to play are in the "how to play" section.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% HEADS UP DISPLAY (HUD) %%%%%%%%%%
setscreen ("graphics:600;500") %Feel free to chnage screen dimension!



%%%%%%%%%% VARIABLES & CONSTANTS %%%%%%%%%%

var Aliens : array 1 .. 5 of array 1 .. 11 of int % actual coordinates of all aliens
for i : 1 .. 5
    for k : 1 .. 11
	Aliens (i) (k) := 45 * k + 20
    end for
end for

var Dead_or_Alive : array 1 .. 5 of array 1 .. 11 of string %dead or alive value for aliens. if is a, means it is alive and will draw
for i : 1 .. 5
    for k : 1 .. 11
	Dead_or_Alive (i) (k) := "a"
    end for
end for


var AliensY, Aliens_Past_Y : int := 0 % variables modified in order for the Aliens to move
var AliensX, Aliens_Past_X : int := -50 %
var Cover : array 1 .. 4 of int

for i : 1 .. 4
    Cover (i) := i * 100 + 50  % cover
end for

var User_SpaceshipX : int := 300 % determines location of spaceship
var User_SpaceshipY : int := 80

var Spaceship_Alive : int := 1 % checks if spaceship is alive
var Bullet_Live : int := 1 % determines if the bullet can destroy an alien
var Max_Bullet, Number_Of_Bullet : int := 1 % sees if the spaceship is able to move or not
var Bullet_Speed : int := 5
var Spaceship_Speed : int := 5
var Bullet_Counter : string := "" % counter for the menu thingy

var Total_Score : int := 0 % score

var User_Input : array char of boolean % keypress of user

var gamescreen : int := 0 % var for checking if it is game screen
%title screen stuff
var titlescreen : int := 1 % checks which panel of the game we are in. is currently in titlescreen
var on_title_box : int := 0 % variable to see if mouse is on a title screen button orn ot

%upgrade screen stuff
var box_or_not : int := 0 % if your mouse is currently over the box, variable will see
var upgradescreen : int := 0 % makes it so that it is currently in upgradescreen
var Number_of_Lives : int := 3  % number of lives the spaceship has
var current_selection : int := 0 % sees which is the current selection in the upgrade screen. when it exits, it will upgrade it.

var Timer : int := 0 % timer, it determines when the aliens move... etc

var Alien_Bullet_Hitbox : int := 5 % determines which row of alien the bullet will kill
var Alien_Bullet_Live : int := 1
var Alien_Bullet_Speed : int := 0 % higher the value, the faster the bullets will travel
var Alien_Number_of_Bullets : int := 1 % higher the value, the more bullets there will be on screen at a time
var Which_Alien : int
var Alien_Speed : int := 5 % higher the value faster the alien moves

var Aliens_Left_Or_Right : int := 1 %determines whether the alien will move left or right. 1 = right, 0 = left
var Number_Aliens_Left : int := 1 % sees how many aliens there are left
var Counter_Number_Aliens : int := 0 % utilized so that it will add 1 during each for loop instance. Number_Aliens_Left will then equal this

% Pictures and sprites of aliens, spaceship, and text
var Worst_Alien := Pic.FileNew ("bad_alien.jpg")
var Bad_Alien := Pic.FileNew ("less_bad_alien.jpg")
var Spaceship := Pic.FileNew ("spaceship.jpg")
var Spaceship_Bullet := Pic.FileNew ("spaceship bullet.jpg")
var Heart := Pic.FileNew ("heart.jpg")
var Green_X := Pic.FileNew ("green_x.bmp")
var Red_X := Pic.FileNew ("red_x.bmp")

%var Number_Bullet_Sprite := Pic.FileNew("bullet_sprite")
var Text_1, Text_2, Text_3 : int
Text_1 := Font.New ("Agency FB:30:bold")
Text_2 := Font.New ("Agency FB:18:bold")
Text_3 := Font.New ("Agency FB:18")

var mouse_x, mouse_y, buttondown : int  %makes mouse x and mouse y. variables for the mousewhere code



%%%%%%%%%% FUNCTIONS & PROCEDURES %%%%%%%%%%


procedure Animate_Aliens % erases aliens past location and redraws them in new location
    for i : 1 .. 5
	for k : 1 .. 11
	    if Dead_or_Alive (i) (k) = "a" then
		if i = 2 or i = 3 then
		    Draw.FillBox (Aliens (i) (k) + Aliens_Past_X, 500 - (i * 40) - Aliens_Past_Y - 50, Aliens (i) (k) + Aliens_Past_X + 30, 500 - (i * 40) - Aliens_Past_Y + 30 - 50, black)
		    Pic.Draw (Bad_Alien, Aliens (i) (k) + AliensX, 500 - (i * 40) - AliensY - 50, picMerge)
		else
		    Draw.FillBox (Aliens (i) (k) + Aliens_Past_X, 500 - (i * 40) - Aliens_Past_Y - 50, Aliens (i) (k) + Aliens_Past_X + 30, 500 - (i * 40) - Aliens_Past_Y + 30 - 50, black)
		    Pic.Draw (Worst_Alien, Aliens (i) (k) + AliensX, 500 - (i * 40) - AliensY - 50, picMerge)
		end if
	    end if
	end for
    end for
end Animate_Aliens

%procedure Draw_Bullet_Sprite (Amount: int)
%  for i: 1 .. Amount
%       Pic.Draw(Number_Bullet_Sprite, 500 - i * 30, 10, picMerge)
%    end for
%end Draw_Bullet_Sprite


procedure Draw_Lives (Amount : int)
    for i : 1 .. Amount
	Pic.Draw (Heart, i * 40, 10, picMerge)
    end for
end Draw_Lives

function Score_Increase (Alien_Row : int) : int     % calculates increase in score
    var Increase_In_Score : int := 0
    Increase_In_Score -= (Alien_Row - 6) * 100     % sees which row the alien is in, then adds score by 100 * which row
    result Increase_In_Score
end Score_Increase

procedure Delayed_Text_Drawing (actual_text : string, x, y, font, delay_speed : int) % acquires the text and animates it, aalso acquires delay
    for i : 2 .. length (actual_text)
	Font.Draw (actual_text (1 .. i), x, y, font, white)
	delay (delay_speed)
    end for
end Delayed_Text_Drawing

function Which_Alien_Has_What_Speed (Which_Alien : int) : int %function that changes how fast the bullet moves according to which alien is shooting it (row)
    var Delay_of_Bullet_Travel : int := 0
    Delay_of_Bullet_Travel += Which_Alien
    result Delay_of_Bullet_Travel
end Which_Alien_Has_What_Speed

procedure Triple_Red_X  % draws 3 red x's in the position of the green x's during the upgrade screen. time saving procedure
    Pic.Draw (Red_X, 175, 243, picMerge)

    Pic.Draw (Red_X, 175, 193, picMerge)

    Pic.Draw (Red_X, 175, 143, picMerge)
end Triple_Red_X

procedure Write_Instructions % writes instructions
    Delayed_Text_Drawing ("Welcome to Alien Attackers. The threat of Aliens is imminent.", 40, 450, Text_3, 5)
    Delayed_Text_Drawing ("As our most prestigious fleet commander, it is your job to defend us.", 40, 410, Text_3, 5)
    Delayed_Text_Drawing ("Move your spaceship with the arrow keys.", 40, 370, Text_3, 5)
    Delayed_Text_Drawing ("Press Control to shoot your space lasers.", 40, 330, Text_3, 5)
    Delayed_Text_Drawing ("After each wave of Aliens, you have time to upgrade your ship.", 40, 290, Text_3, 5)
    Delayed_Text_Drawing ("However the aliens, with new fighting knowledge, get stronger each wave.", 40, 250, Text_3, 5)

    Delayed_Text_Drawing ("I'm ready to fight", 225, 100, Text_2, 20)
    Draw.Box (215, 88, 362, 128, white) % outline
end Write_Instructions
process fire (Position : int)     % different process in order to have the firing function happen simultaneous with movement. includes hitboxes
    Total_Score -= 50
    var bulletY : int := User_SpaceshipY + 40
    loop
	delay (5)
	Bullet_Live := 1     % makes the bullet active and able to kill things and move
	%Draw.Line (Position, bulletY, Position, bulletY - 20, black)
	Draw.FillBox (Position - 7, bulletY - 15, Position + 7, bulletY, black)
	bulletY += 1
	%Draw.Line (Position, bulletY, Position, bulletY - 20, white)
	Pic.Draw (Spaceship_Bullet, Position - 5, bulletY - 15, picMerge) % draws bullet
	for decreasing i : 5 .. 1
	    for k : 1 .. 11
		if Position >= Aliens (i) (k) + AliensX and Position <= Aliens (i) (k) + AliensX + 30 then     % checks if bullet location is in Alien X
		    if bulletY = 500 - (i * 40) - AliensY - 50 then     % checks if bullet location is in any of aliens Y or out of screen
			if Dead_or_Alive (i) (k) = "a" then
			    Dead_or_Alive (i) (k) := ""
			    Draw.FillBox (Aliens (i) (k) + AliensX - 10, 500 - (i * 40) - AliensY - 20 - 30, Aliens (i) (k) + AliensX + 45, 500 - (i * 40) - AliensY + 40 - 50, black)
			    % erases alien
			    Total_Score += Score_Increase (i)
			    Bullet_Live := 0     % deactivates bullet
			    exit
			end if
		    end if
		end if
	    end for
	    exit when bulletY >= 500 or Bullet_Live = 0     % if bullet is not active exits or out of screen
	end for
	exit when bulletY >= 500 or Bullet_Live = 0
    end loop
    %Draw.Line (Position, bulletY, Position, bulletY - 20, black)
    Draw.FillBox (Position - 7, bulletY - 15, Position + 7, bulletY, black)        % erases the leftover white line when the bullet stops
    if Number_Of_Bullet < Max_Bullet then     % when the bullet hits something , adds a bullet to the spaceship
	Number_Of_Bullet += 1
    end if
end fire

process alienfire (Alien_Position, Alien_Y, i : int)
    var Alien_bulletY := Alien_Y
    loop
	delay (Which_Alien_Has_What_Speed (i) - Alien_Bullet_Speed + 5)
	Draw.Line (Alien_Position, Alien_bulletY, Alien_Position, Alien_bulletY + 10, black)
	Alien_bulletY -= 1
	Draw.Line (Alien_Position, Alien_bulletY, Alien_Position, Alien_bulletY + 10, white)
	if Alien_Position <= User_SpaceshipX + 15 and Alien_Position >= User_SpaceshipX - 15 and Alien_bulletY >= User_SpaceshipY and Alien_bulletY <= User_SpaceshipY + 30 then
	    Draw.FillBox (User_SpaceshipX - 15, User_SpaceshipY, User_SpaceshipX + 17, User_SpaceshipY + 30, black)
	    Spaceship_Alive := 0 % value is now 0, not alive spaceship
	    Draw.FillBox (Number_of_Lives * 40, 10, Number_of_Lives * 40 + 30, 10 + 30, black)
	    Number_of_Lives -= 1 % loses 1 life
	end if
	exit when Spaceship_Alive = 0 or Alien_bulletY = 0
    end loop
    Draw.Line (Alien_Position, Alien_bulletY, Alien_Position, Alien_bulletY + 10, black)
    if Spaceship_Alive not= 1 then
	delay (1000)
	Spaceship_Alive := 1
    end if
end alienfire


%%%%%%%%%% MAIN CODE %%%%%%%%%%



loop
    % title screen
    if titlescreen = 1 then
	Draw.FillBox (0, 0, 600, 500, black)
	Draw.FillBox (450, 0, 600, 500, blue)

	Delayed_Text_Drawing ("ALIEN ATTACKERS", 110, 400, Text_1, 100)
	Delayed_Text_Drawing ("Play Game ", 50, 250, Text_2, 5)
	Draw.Box (40, 238, 140, 278, white)
	Delayed_Text_Drawing ("How To Play ", 50, 200, Text_2, 5)
	Draw.Box (40, 188, 155, 228, white)
	Delayed_Text_Drawing ("Quit Game", 50, 150, Text_2, 5)
	Draw.Box (40, 138, 140, 178, white)




	for i : 1 .. 3
	    Pic.Draw (Spaceship, 115 + 50 * i, 325, picMerge)
	end for
	titlescreen := 0
    end if

    Mouse.Where (mouse_x, mouse_y, buttondown)

    if mouse_x <= 140 and mouse_x >= 40 and mouse_y <= 278 and mouse_y >= 238 then     % if the mouse lands on the play game button then triggers
	on_title_box := 1
	Draw.FillBox (40, 238, 140, 278, grey)     % makes the hovery effect
	Delayed_Text_Drawing ("Play Game ", 50, 250, Text_2, 0)     % refreshes so it doesn't dissapear
	Draw.Box (40, 238, 140, 278, white)     % makes it look good
	if buttondown = 1 then     % starts game when button is pressed
	    gamescreen := 1
	    Draw.FillBox (0, 0, 600, 500, black)
	    loop
		Timer += Alien_Speed % will eventually increase to make the aliens shoot faster
		Input.KeyDown (User_Input)

		%Firing procedure
		if User_Input (KEY_CTRL) and Number_Of_Bullet > 0 and Spaceship_Alive = 1 then
		    fork fire (User_SpaceshipX)
		    Number_Of_Bullet -= 1
		end if

		% Movement of Spaceship
		if User_Input (KEY_LEFT_ARROW) and Spaceship_Alive = 1 then

		    Draw.FillBox (User_SpaceshipX - 15, User_SpaceshipY, User_SpaceshipX + 17, User_SpaceshipY + 30, black)
		    User_SpaceshipX -= Spaceship_Speed % makes it go left
		    Pic.Draw (Spaceship, User_SpaceshipX - 15, User_SpaceshipY, picMerge)     % draws spaceship

		end if
		if User_Input (KEY_RIGHT_ARROW) and Spaceship_Alive = 1 then

		    Draw.FillBox (User_SpaceshipX - 15, User_SpaceshipY, User_SpaceshipX + 17, User_SpaceshipY + 30, black)
		    User_SpaceshipX += Spaceship_Speed
		    Pic.Draw (Spaceship, User_SpaceshipX - 15, User_SpaceshipY, picMerge)     % draws spaceship

		end if

		% Movement of Aliens
		if Timer mod 1000 = 0 then
		    Aliens_Past_Y := AliensY
		    Aliens_Past_X := AliensX
		    AliensY += 10
		    if Aliens_Left_Or_Right = 1 then
			Aliens_Left_Or_Right := 0
		    else
			Aliens_Left_Or_Right := 1
		    end if
		elsif Aliens_Left_Or_Right = 1 and Timer mod 100 = 0 then
		    Aliens_Past_Y := AliensY
		    Aliens_Past_X := AliensX
		    AliensX += 10
		elsif Aliens_Left_Or_Right = 0 and Timer mod 100 = 0 then
		    Aliens_Past_Y := AliensY
		    Aliens_Past_X := AliensX
		    AliensX -= 10
		end if

		delay (40)
		% Animation of the Aliens Moving. Erasing
		Animate_Aliens

		% Aliens firing
		if Timer mod 100 = 0 and Spaceship_Alive = 1 then
		    randint (Which_Alien, 1, 11)
		    for decreasing i : 5 .. 1
			if Dead_or_Alive (i) (Which_Alien) = "a" then
			    fork alienfire (Which_Alien * 45 + AliensX + 35, 500 - (i * 40) - AliensY - 60, i)
			    exit
			end if
		    end for
		end if

		for i : 1 .. 5     % checks which aliens are alive
		    for k : 1 .. 11
			if Dead_or_Alive (i) (k) = "a" then
			    Counter_Number_Aliens += 1
			end if
		    end for
		    Number_Aliens_Left := Counter_Number_Aliens
		end for
		Counter_Number_Aliens := 0

		% Scoreboard, Lives, Level... Etc
		Delayed_Text_Drawing ("SCORE:", 10, 470, Text_2, 0) % score
		Delayed_Text_Drawing (intstr (Total_Score), 70, 470, Text_2, 0)
		Draw.FillBox (70, 470, 150, 500, black)
		Delayed_Text_Drawing (intstr (Total_Score), 70, 470, Text_2, 0)

		Delayed_Text_Drawing ("Spaceship Ammo :", 350, 15, Text_2, 0)
		Bullet_Counter := intstr (Number_Of_Bullet)
		Delayed_Text_Drawing (Bullet_Counter + " Rocket", 500, 15, Text_2, 0)
		Draw.FillBox (500, 14, 600, 40, black)
		Delayed_Text_Drawing (Bullet_Counter + " Rocket", 500, 15, Text_2, 0)



		%Draw.Dot (User_SpaceshipX, 50, white)
		if Spaceship_Alive = 1 then     % makes it so that it stuff below only triggers once the spaceship is alive
		    Pic.Draw (Spaceship, User_SpaceshipX - 15, User_SpaceshipY, picMerge)     % redraws spaceship from animation
		    Draw_Lives (Number_of_Lives)     %redraws lives from the erasing inside alienfire
		end if
		if Number_of_Lives = 0 then     % game over screen which triggers after game ends
		    Draw.FillBox (0, 0, 600, 500, black)
		    Delayed_Text_Drawing ("GAME OVER", 175, 300, Text_1, 100)
		    Delayed_Text_Drawing ("Your Score:", 100, 200, Text_1, 100)
		    Delayed_Text_Drawing (intstr (Total_Score), 275, 200, Text_1, 100)
		    loop

		    end loop
		end if

		%%% UPGRADE SCREEN%%%

		if Number_Aliens_Left = 0 then          % when all the aliens die, triggers below
		    upgradescreen := 1     % makes it so that it is now the upgradescreen
		    Draw.FillBox (0, 0, 600, 500, black)
		    Draw.FillBox (0, 0, 100, 500, blue)

		    Delayed_Text_Drawing ("Congratulations.", 200, 400, Text_1, 5)     %
		    Delayed_Text_Drawing ("You have defeated this wave. Aliens will come stronger.", 150, 350, Text_3, 5)     %
		    Delayed_Text_Drawing ("Use your time wisely. Which ship part shall you upgrade?", 150, 310, Text_3, 5)     %
		    Delayed_Text_Drawing ("Faster Bullets", 245, 250, Text_3, 5)     %
		    Delayed_Text_Drawing ("*some may be defective", 370, 200, Text_3, 5)
		    Delayed_Text_Drawing ("(bullets from space)", 385, 165, Text_3, 5)                                                     %
		    %                     %

		    Draw.Box (235, 240, 352, 276, white)     % the box around each text
		    Delayed_Text_Drawing ("More Bullets", 250, 200, Text_3, 5)     %
		    Draw.Box (240, 190, 350, 226, white)
		    Delayed_Text_Drawing ("Faster Spaceship", 238, 150, Text_3, 5)     %
		    Draw.Box (230, 140, 372, 178, white)
		    Delayed_Text_Drawing ("I'm Ready to Fight", 425, 100, Text_3, 50)     % creates text and box
		    Draw.Box (417, 90, 565, 128, white)
		    Triple_Red_X     % draws 3 red x's so that the user knows what to upgrade
		    Pic.Draw (Spaceship, 280, 50, picMerge)     % part of decorating the background

		    loop     % double loop is here only to ensure that the user MUST select an upgrade
			loop     % makes the boxes light up when the mouse is hovered over it
			    Mouse.Where (mouse_x, mouse_y, buttondown)     % finds where the mouse is currently at and the mouseclicks
			    if mouse_x <= 352 and mouse_x >= 235 and mouse_y >= 240 and mouse_y <= 276 then     % if mouse moves to this region of space. ditto to rest
				box_or_not := 1     % when the mouse is over this region of space, this variable is set to 1. respective to all other sections
				if buttondown = 1 then     % only if the button presses down
				    current_selection := 1     % makes the current upgrade faster bullets. only triggers once you leave selection screen
				    Triple_Red_X
				    Pic.Draw (Green_X, 175, 243, picMerge)
				end if
			    elsif mouse_x >= 240 and mouse_x <= 350 and mouse_y >= 190 and mouse_y <= 226 then
				box_or_not := 2
				if buttondown = 1 then
				    current_selection := 2
				    Triple_Red_X
				    Pic.Draw (Green_X, 175, 193, picMerge)
				end if
			    elsif mouse_x >= 230 and mouse_x <= 372 and mouse_y >= 140 and mouse_y <= 178 then
				box_or_not := 3
				if buttondown = 1 then
				    current_selection := 3
				    Triple_Red_X
				    Pic.Draw (Green_X, 175, 143, picMerge)

				end if
			    elsif mouse_x >= 417 and mouse_x <= 565 and mouse_y >= 90 and mouse_y <= 128 then
				box_or_not := 4
				if buttondown = 1 then
				    upgradescreen := 0
				end if
			    end if
			    if box_or_not = 1 then
				Draw.FillBox (235, 240, 352, 276, grey)
				Delayed_Text_Drawing ("Faster Bullets", 245, 250, Text_3, 0)     %
				if mouse_x >= 352 or mouse_x <= 235 or mouse_y <= 240 or mouse_y >= 276 then
				    Draw.FillBox (235, 240, 352, 276, black)
				    Delayed_Text_Drawing ("Faster Bullets", 245, 250, Text_3, 0)     %
				    Draw.Box (235, 240, 352, 276, white)
				    box_or_not := 0
				end if
			    elsif box_or_not = 2 then
				Draw.FillBox (240, 190, 350, 226, grey)
				Delayed_Text_Drawing ("More Bullets", 250, 200, Text_3, 0)     %
				if mouse_x <= 240 or mouse_x >= 350 or mouse_y <= 190 or mouse_y >= 226 then
				    Draw.FillBox (240, 190, 350, 226, black)
				    Delayed_Text_Drawing ("More Bullets", 250, 200, Text_3, 0)     %
				    Draw.Box (240, 190, 350, 226, white)

				    box_or_not := 0
				end if
			    elsif box_or_not = 3 then
				Draw.FillBox (230, 140, 372, 178, grey)
				Delayed_Text_Drawing ("Faster Spaceship", 238, 150, Text_3, 0)     %
				if mouse_x <= 230 or mouse_x >= 372 or mouse_y <= 140 or mouse_y >= 178 then
				    Draw.FillBox (230, 140, 372, 178, black)
				    Delayed_Text_Drawing ("Faster Spaceship", 238, 150, Text_3, 0)     %
				    Draw.Box (230, 140, 372, 178, white)
				    box_or_not := 0
				end if
			    elsif box_or_not = 4 then
				Draw.FillBox (417, 90, 565, 128, grey)
				Delayed_Text_Drawing ("I'm Ready to Fight", 425, 100, Text_3, 0)
				if mouse_x <= 417 or mouse_x >= 565 or mouse_y >= 128 or mouse_y <= 90 then
				    Draw.FillBox (417, 90, 565, 128, black)
				    Delayed_Text_Drawing ("I'm Ready to Fight", 425, 100, Text_3, 0)
				    Draw.Box (417, 90, 565, 128, white)
				    box_or_not := 0
				end if
			    end if

			    Delayed_Text_Drawing ("Faster Bullets", 245, 250, Text_3, 0)     %
			    Draw.Box (235, 240, 352, 276, white)
			    Delayed_Text_Drawing ("More Bullets", 250, 200, Text_3, 0)     %

			    Draw.Box (240, 190, 350, 226, white)
			    Delayed_Text_Drawing ("Faster Spaceship", 238, 150, Text_3, 0)     %
			    Draw.Box (230, 140, 372, 178, white)
			    Delayed_Text_Drawing ("I'm Ready to Fight", 425, 100, Text_3, 0)     % creates text and box to help refresh the boxes while it turns grey
			    Draw.Box (417, 90, 565, 128, white)

			    exit when upgradescreen = 0     % exits if it is no longer the upgrade screen
			end loop
			if current_selection = 1 then
			    Bullet_Speed += 3
			    exit
			elsif current_selection = 2 then
			    Number_Of_Bullet += 1
			    Max_Bullet += 1
			    exit
			elsif current_selection = 3 then
			    Spaceship_Speed += 2

			    exit
			else
			    Delayed_Text_Drawing ("You must repair and upgrade!", 350, 50, Text_3, 10)
			    upgradescreen := 1     % makes it the upgrade screen again because it goes back there as they didn't pick upgrade
			end if
		    end loop     % safety for if the user does not select an upgrade. will keep looping if he doesn't pick an upgrade
		    Alien_Bullet_Speed += 1     % makes the bullets of the aliens slightly faster
		    Number_Aliens_Left := 1     % makes it not equal 0 so no infinite loop
		    Number_of_Lives := 3 % refreshes lives
		    AliensY := 0
		    Aliens_Past_Y := 0 % sets aliens positions back to normal
		    AliensX := -50
		    Aliens_Past_X := -50
		    Timer := 0
		    for i : 1 .. 5    % refreshes alive aliens
			for k : 1 .. 11
			    Dead_or_Alive (i) (k) := "a"
			end for
		    end for
		    for i : 1 .. 5 % refreshes aliens positions
			for k : 1 .. 11
			    Aliens (i) (k) := 45 * k + 20
			end for
		    end for
		    Number_Aliens_Left := Counter_Number_Aliens
		    Draw.FillBox (0, 0, 600, 500, black)
		    Delayed_Text_Drawing ("Aliens are Approaching...", 150, 250, Text_1, 0)
		    delay (1000)

		end if


	    end loop
	end if

    elsif mouse_x <= 155 and mouse_x >= 40 and mouse_y >= 188 and mouse_y <= 228 then     % when you click on the how to play button, will put you in this loop
	on_title_box := 2     % since mouse is now touching a title screen box, will make it so that it equals 2.
	if buttondown = 1 then
	    Draw.FillBox (0, 0, 600, 500, black)

	    Write_Instructions
	    loop
		Mouse.Where (mouse_x, mouse_y, buttondown)
		if mouse_x >= 215 and mouse_x <= 362 and mouse_y >= 88 and mouse_y <= 128 then
		    if buttondown = 1 then
			titlescreen := 1
			Draw.FillBox (0, 0, 600, 500, black)
			on_title_box := 0
			exit
		    end if
		end if
	    end loop
	end if
    end if
    if on_title_box = 1 then                 % variable so that it can make the background thingy thingy
	Draw.FillBox (40, 238, 140, 278, grey)
	Delayed_Text_Drawing ("Play Game ", 50, 250, Text_2, 0)
	Draw.Box (40, 238, 140, 278, white)

	if mouse_x <= 40 or mouse_x >= 140 or mouse_y <= 238 or mouse_y >= 278 then
	    Draw.FillBox (40, 238, 140, 278, black)

	    Delayed_Text_Drawing ("Play Game ", 50, 250, Text_2, 0)
	    Draw.Box (40, 238, 140, 278, white)
	    on_title_box := 0
	end if
    end if
    if on_title_box = 2 then             % variable so that it can make the background thingy thingy
	Draw.FillBox (40, 188, 155, 228, grey)
	Delayed_Text_Drawing ("How To Play ", 50, 200, Text_2, 0)
	Draw.Box (40, 188, 155, 228, white)

	if mouse_x >= 155 or mouse_x <= 40 or mouse_y <= 188 or mouse_y >= 228 then
	    Draw.FillBox (40, 188, 155, 228, black)

	    Delayed_Text_Drawing ("How To Play ", 50, 200, Text_2, 0)
	    Draw.Box (40, 188, 155, 228, white)
	    on_title_box := 0
	end if
    end if


    % makes it so that it doesn't do it when it's on the title screen
    % this section refreshes the boxes so that after your mouse moves out of the title box, it will make it black and take off the grey.
    % makes the background of box from grey to black
    if gamescreen not= 1 then
	Delayed_Text_Drawing ("Play Game ", 50, 250, Text_2, 0)     % rewrites text
	Draw.Box (40, 238, 140, 278, white)     % outline
	Delayed_Text_Drawing ("How To Play ", 50, 200, Text_2, 0)
	Draw.Box (40, 188, 155, 228, white)
	Delayed_Text_Drawing ("Quit Game", 50, 150, Text_2, 0)
	Draw.Box (40, 138, 140, 178, white)     % ditto
	Delayed_Text_Drawing ("A Loyal Commander Does Not Fear Anything", 40, 108, Text_2, 0)
	Draw.Line (40, 138, 140, 178, white)
	Draw.Line (140, 138, 40, 178, white)

    end if
end loop

