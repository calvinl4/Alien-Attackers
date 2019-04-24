%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Programmer  : Calvin Lin
% Teacher     : Mr. Chow
% Course      : ICS3U1
%
% Program Name:
% Description :
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

%spaceship tings
var User_SpaceshipX : int := 300 % determines location of spaceship
var User_SpaceshipY : int := 80
var Spaceship_Alive : int := 1 % checks if spaceship is alive
var Bullet_Live : int := 1 % determines if the bullet can destroy an alien
var Max_Bullet, Number_Of_Bullet : int := 1 % sees if the spaceship is able to move or not
var Bullet_Speed : int := 5

% upgrade selection screen stuff
var box_or_not : int := 0 % if your mouse is currently over the box, variable will see
var titlescreen : int := 1 % checks which panel of the game we are in. is currently in titlescreen
var upgradescreen : int := 0 % makes it so that it is currently in upgradescreen
var current_selection : int := 0 % sees which is the current selection in the upgrade screen. when it exits, it will upgrade it.
var three_two_one : string := ""

var Total_Score : int := 0 % score
var User_Input : array char of boolean % keypress of user

var Number_of_Lives : int := 3  % number of lives the spaceship has

var Timer : int := 0 % timer, it determines when the aliens move... etc

var Alien_Bullet_Hitbox : int := 5 % determines which row of alien the bullet will kill
var Alien_Bullet_Live : int := 1
var Alien_Bullet_Speed : int := 0 % higher the value, the faster the bullets will travel
var Alien_Number_of_Bullets : int := 1 % higher the value, the more bullets there will be on screen at a time
var Which_Alien : int

var Aliens_Left_Or_Right : int := 1 %determines whether the alien will move left or right. 1 = right, 0 = left
var Number_Aliens_Left : int := 0 % sees how many aliens there are left %%%% temporarily set to 0 for testing purposes
var Counter_Number_Aliens : int := 0 % utilized so that it will add 1 during each for loop instance. Number_Aliens_Left will then equal this

% Pictures and sprites of aliens, spaceship
var Worst_Alien := Pic.FileNew ("bad_alien.jpg")
var Bad_Alien := Pic.FileNew ("less_bad_alien.jpg")
var Spaceship := Pic.FileNew ("spaceship.jpg")
var Spaceship_Bullet := Pic.FileNew ("spaceship bullet.jpg")
var Heart := Pic.FileNew ("heart.jpg")
var Green_X := Pic.FileNew ("green_x.bmp")
var Red_X := Pic.FileNew ("red_x.bmp")
% fonts
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

procedure Draw_Lives (Amount : int)
    for i : 1 .. Amount
	Pic.Draw (Heart, i * 40, 10, picMerge) % Draws the hearts according to how many hearts there are supposed to be. in the corner.
    end for
end Draw_Lives

function Score_Increase (Alien_Row : int) : int     % calculates increase in score
    var Increase_In_Score : int := 0 % creates new variable and sets value to zero
    Increase_In_Score -= (Alien_Row - 6) * 100     % sees which row the alien is in, then adds score by 100 * which row
    result Increase_In_Score
end Score_Increase

procedure Triple_Red_X  % draws 3 red x's in the position of the green x's during the upgrade screen. time saving procedure
    Pic.Draw (Red_X, 175, 243, picMerge)

    Pic.Draw (Red_X, 175, 193, picMerge)

    Pic.Draw (Red_X, 175, 143, picMerge)
end Triple_Red_X


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
			    Draw.FillBox (Aliens (i) (k) + AliensX - 10, 500 - (i * 40) - AliensY - 20 - 50, Aliens (i) (k) + AliensX + 45, 500 - (i * 40) - AliensY + 40 - 50, black)
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

if Number_Aliens_Left = 0 then              % when all the aliens die, triggers below
    upgradescreen := 1                 % makes it so that it is now the upgradescreen
    Draw.FillBox (0, 0, 600, 500, black)
    Draw.FillBox (0, 0, 100, 500, blue)

    Delayed_Text_Drawing ("Congratulations.", 200, 400, Text_1, 5) %
    Delayed_Text_Drawing ("You have defeated this wave. Aliens will come stronger.", 150, 350, Text_3, 5) %
    Delayed_Text_Drawing ("Use your time wisely. Which ship part shall you upgrade?", 150, 310, Text_3, 5) %
    Delayed_Text_Drawing ("Faster Bullets", 245, 250, Text_3, 5) %
    Draw.Box (235, 240, 352, 276, white) % the box around each text
    Delayed_Text_Drawing ("More Bullets", 250, 200, Text_3, 5) %
    Draw.Box (240, 190, 350, 226, white)
    Delayed_Text_Drawing ("Faster Spaceship", 238, 150, Text_3, 5) %
    Draw.Box (230, 140, 372, 178, white)
    Delayed_Text_Drawing ("I'm Ready to Fight", 425, 100, Text_3, 5) % creates text and box
    Draw.Box (417, 90, 565, 128, white)
    Triple_Red_X % draws 3 red x's so that the user knows what to upgrade
    Pic.Draw (Spaceship, 280, 50, picMerge) % part of decorating the background

    loop % double loop is here only to ensure that the user MUST select an upgrade
	loop % makes the boxes light up when the mouse is hovered over it
	    Mouse.Where (mouse_x, mouse_y, buttondown) % finds where the mouse is currently at and the mouseclicks
	    if mouse_x <= 352 and mouse_x >= 235 and mouse_y >= 240 and mouse_y <= 276 then % if mouse moves to this region of space. ditto to rest
		box_or_not := 1 % when the mouse is over this region of space, this variable is set to 1. respective to all other sections
		if buttondown = 1 then % only if the button presses down
		    current_selection := 1 % makes the current upgrade faster bullets. only triggers once you leave selection screen
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
		Delayed_Text_Drawing ("Faster Bullets", 245, 250, Text_3, 0) %
		if mouse_x >= 352 or mouse_x <= 235 or mouse_y <= 240 or mouse_y >= 276 then
		    Draw.FillBox (235, 240, 352, 276, black)
		    Delayed_Text_Drawing ("Faster Bullets", 245, 250, Text_3, 0)                 %
		    Draw.Box (235, 240, 352, 276, white)
		    box_or_not := 0
		end if
	    elsif box_or_not = 2 then
		Draw.FillBox (240, 190, 350, 226, grey)
		Delayed_Text_Drawing ("More Bullets", 250, 200, Text_3, 0)     %
		if mouse_x <= 240 or mouse_x >= 350 or mouse_y <= 190 or mouse_y >= 226 then
		    Draw.FillBox (240, 190, 350, 226, black)
		    Delayed_Text_Drawing ("More Bullets", 250, 200, Text_3, 0) %
		    Draw.Box (240, 190, 350, 226, white)
		    box_or_not := 0
		end if
	    elsif box_or_not = 3 then
		Draw.FillBox (230, 140, 372, 178, grey)
		Delayed_Text_Drawing ("Faster Spaceship", 238, 150, Text_3, 0) %
		if mouse_x <= 230 or mouse_x >= 372 or mouse_y <= 140 or mouse_y >= 178 then
		    Draw.FillBox (230, 140, 372, 178, black)
		    Delayed_Text_Drawing ("Faster Spaceship", 238, 150, Text_3, 0) %
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

	    exit when upgradescreen = 0             % exits if it is no longer the upgrade screen
	end loop
	if current_selection = 1 then
	    exit
	elsif current_selection = 2 then
	    exit
	elsif current_selection = 3 then
	    exit
	else
	    Delayed_Text_Drawing ("You must repair and upgrade!", 350, 50, Text_3, 10)
	    upgradescreen := 1 % makes it the upgrade screen again because it goes back there as they didn't pick upgrade
	end if
    end loop % safety for if the user does not select an upgrade. will keep looping if he doesn't pick an upgrade
    Alien_Bullet_Speed += 1 % makes the bullets of the aliens slightly faster
    Number_Aliens_Left := 1                 % makes it not equal 0 so no infinite loop


    Draw.FillBox (0, 0, 600, 500, black)
    Delayed_Text_Drawing ("Aliens are Approaching...", 150, 250, Text_1, 0)
    delay (1000)
end if
