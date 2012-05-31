;Program written for Bot Board II, Basic Atom Pro 28, Basic Micro Studio v1.0.0.4
;Written by Nathan Scherdin, modified by Jim and James Frye





;System variables 
righthip	con p10 
rightknee	con p8 
rightankle	con p7 
lefthip		con p6 
leftknee	con p5 
leftankle	con p4 

NUMSERVOS		con 6
aServoOffsets	var	sword(NUMSERVOS)				
ServoTable		bytetable RightHip,rightknee, rightankle,lefthip, leftknee, leftankle

;[PS2 Controller]
PS2DAT 		con P12		;PS2 Controller DAT (Brown)
PS2CMD 		con P13		;PS2 controller CMD (Orange)
PS2SEL 		con P14		;PS2 Controller SEL (Blue)
PS2CLK 		con P15		;PS2 Controller CLK (White)
PadMode 	con $79

TRUE con 1
FALSE con 0

BUTTON_DOWN con 0
BUTTON_UP 	con 1

TravelDeadZone	con 4	;The deadzone for the analog input from the remote

;calibrate steps per degree. 
stepsperdegree fcon 166.6 

;You must calibrate the servos to "zero". Each robot will be different! 
;When homed in and servos are at 0 degrees the robot should be standing 
;straight with the AtomPro chip pointing backward. If you know the number 
;of degrees the servo is off, you can calculate the value. 166.6 steps
;per degree. The values for our test robot were found by running the 
;program bratosf.bas written by James Frye. 





;Interrupt init 
ENABLEHSERVO 

command 	var byte 
bat			var word

IdleBot 	var word
WalkSpeed	var float
WalkAngle	var float

TravLength	var byte
TravLength = 6
LastStep	var byte
LastStep = 0
AnkleAdj	var byte
AnkleAdj = 0

BotActive var bit
BotActive = FALSE

;[Ps2 Controller]
DualShock 	var Byte(7)
LastButton 	var Byte(2)
DS2Mode 	var Byte
PS2Index	var byte
BodyYShift	var sbyte
PS2IN		var float

;PS2 controller
high PS2CLK
LastButton(0) = 255
LastButton(1) = 255


;==============================================================================
; Complete initialization
;==============================================================================
	aServoOffsets = rep 0\NUMSERVOS		; Use the rep so if size changes we should properly init

	; try to retrieve the offsets from EEPROM:
	
	; see how well my pointers work
	gosub ReadServoOffsets


;Init positions 
;Note, movement subroutine arguments are Rightankle,Rightknee,Righthip,Leftankle,Leftknee,Lefthip,speed 
gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0] 


;low 1 
;low 2 
pause 1000 

;---------------------------------------;
;--------Command Quick Reference--------;
;---------------------------------------;
;- Command 0 = Home Position           -;
;- Command 1 = Walk Forward            -;
;- Command 2 = Walk Backward           -;
;- Command 4 = Kick (Left)             -;
;- Command 5 = Kick (Right)            -;
;- Command 6 = Headbutt                -;
;- Command 7 = Get up from Front       -;
;- Command 8 = Get up from Back        -;
;- Command 9 = Rest Position           -;
;- Command 11= Turn Left               -;
;- Command 12= Turn Right              -;
;- Command 13= Slight Turn Left        -;
;- Command 14= Slight Turn Right       -;
;---------------------------------------;
 
         sound 9,[50\4000,40\3500,40\3200,50\3900]


main


gosub PS2INPUT

if(IdleBot = 1000)then
  command = 9
  gosub move
elseif(IdleBot = 50)
  AnkleAdj = 0
else
  IdleBot = IdleBot + 1
  pause 15
endif



adin 16, bat  
  
if (bat < 270) then ;the battery is getting low  
  sound 9,[50\5000,25\4400,50\5000]  
else
  pause 50
endif


goto main 

move:
	if(command = 1) then							; Walk
		if LastStep = 0 then
			gosub movement [  WalkAngle, WalkSpeed, WalkSpeed, -WalkAngle,-WalkSpeed,-WalkSpeed,500.0] 
			gosub movement [ -WalkAngle, WalkSpeed, WalkSpeed,  WalkAngle,-WalkSpeed,-WalkSpeed,500.0]
			LastStep = 1
		elseif LastStep = 1
			gosub movement [ -WalkAngle,-WalkSpeed,-WalkSpeed,  WalkAngle, WalkSpeed, WalkSpeed,500.0] 
			gosub movement [  WalkAngle,-WalkSpeed,-WalkSpeed, -WalkAngle, WalkSpeed, WalkSpeed,500.0] 
			LastStep = 0
		endif
		AnkleAdj = AnkleAdj + 1
		if (AnkleAdj > 6) then
			AnkleAdj = 6
		endif
      elseif(command = 4)							; Kick Left
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, 500.0] 
         gosub movement [-14.0,  0.0,  0.0, 42.0,  0.0,  0.0, 500.0] 
         gosub movement [-23.0,  0.0,  0.0,  0.0,-32.0, 41.0, 500.0] 
         gosub movement [-23.0,  0.0,  0.0,  0.0, 24.0,-20.0, 250.0] 
         gosub movement [-18.0,  0.0,  0.0,  0.0,  0.0,  0.0, 500.0] 
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, 500.0]
      elseif(command = 5)							; Kick Right
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, 500.0] 
         gosub movement [ 42.0,  0.0,  0.0,-14.0,  0.0,  0.0, 500.0] 
         gosub movement [  0.0,-32.0, 41.0,-23.0,  0.0,  0.0, 500.0] 
         gosub movement [  0.0, 24.0,-20.0,-23.0,  0.0,  0.0, 250.0] 
         gosub movement [  0.0,  0.0,  0.0,-18.0,  0.0,  0.0, 500.0] 
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, 500.0] 
      elseif(command = 7)							; Get up from front 
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, 500.0] 
         gosub movement [  0.0, 90.0, 45.0,  0.0, 90.0, 45.0, 500.0] 
         gosub movement [ 40.0, 90.0,-37.0,  0.0, 90.0, 45.0, 500.0] 
         gosub movement [  0.0, 90.0,-65.0,  0.0, 90.0,-65.0, 500.0] 
         pause 300
		 gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,1000.0] 
      elseif(command = 8)							; Get up from back 
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,1000.0] 
         gosub movement [  0.0,-90.0,  5.0,  0.0,-90.0,  5.0,1000.0] 
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,1000.0] 
;         pause 1000 
;         gosub movement [  0.0, 22.0,-80.0,  0.0, 22.0,-80.0,1000.0] 
;         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,1000.0]
       elseif(command = 0)							; Home Position 
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, 500.0] 
;         sound 9,[50\4400] 
;         pause 50 
;         sound 9,[50\4400] 
;         pause 50 
;         sound 9,[50\4400] 
      elseif(command = 6)							; Headbutt 
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, 500.0] 
         gosub movement [  0.0,-50.0,-90.0,  0.0,-50.0,-90.0, 500.0] 
         gosub movement [  0.0, 32.0,-58.0,  0.0, 32.0,-58.0, 400.0] 
         pause 200 
         gosub movement [  0.0,-11.0,  7.0,  0.0,-11.0,  7.0, 500.0] 
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, 500.0] 
;         sound 9,[50\4400] 
;         pause 50 
;         sound 9,[50\3960] 
;         pause 50 
;         sound 9,[50\3960] 
      elseif(command = 11)							; Turn left
         gosub movement [ 20.0,  0.0,  0.0,-14.0,  0.0,  0.0,500.0] 
         gosub movement [ 20.0,-35.0,-35.0,-14.0, 35.0, 35.0,500.0] 
         gosub movement [  0.0,-35.0,-35.0,  0.0, 35.0, 35.0,500.0] 
         gosub movement [  0.0, 35.0, 35.0,  0.0,-35.0,-35.0,500.0] 
         gosub movement [ 20.0, 35.0, 35.0,-14.0,-35.0,-35.0,500.0] 
         gosub movement [ 20.0,  0.0,  0.0,-14.0,-35.0,-35.0,500.0]
         gosub movement [-14.0,  0.0,  0.0, 20.0,-35.0,-35.0,500.0]
         gosub movement [-14.0,  0.0,  0.0, 20.0,  0.0,  0.0,500.0]
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,500.0]
      elseif(command = 12)							; Turn right
         gosub movement [-14.0,  0.0,  0.0, 20.0,  0.0,  0.0,500.0] 
         gosub movement [-14.0, 35.0, 35.0, 20.0,-35.0,-35.0,500.0] 
         gosub movement [  0.0, 35.0, 35.0,  0.0,-35.0,-35.0,500.0] 
         gosub movement [  0.0,-35.0,-35.0,  0.0, 35.0, 35.0,500.0] 
         gosub movement [-14.0,-35.0,-35.0, 20.0, 35.0, 35.0,500.0] 
         gosub movement [-14.0,-35.0,-35.0, 20.0,  0.0,  0.0,500.0]
         gosub movement [ 20.0,-35.0,-35.0,-14.0,  0.0,  0.0,500.0]
         gosub movement [ 20.0,  0.0,  0.0,-14.0,  0.0,  0.0,500.0]
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,500.0]
      elseif(command = 13)							;coarse correct left
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,500.0]
         gosub movement [ 25.0,  0.0,  0.0,-18.0,  0.0,  0.0,500.0]
         pause 100
         gosub movement [  2.0,-20.0,-20.0,-18.0, 20.0, 20.0,500.0]
         gosub movement [  0.0,-20.0,-20.0,  0.0, 20.0, 20.0,500.0]
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,500.0]

      elseif(command = 14)							;coarse correct right
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,500.0]
         gosub movement [-18.0,  0.0,  0.0, 25.0,  0.0,  0.0,500.0]
         pause 100
         gosub movement [-18.0, 20.0, 20.0,  2.0,-20.0,-20.0,500.0]
         gosub movement [  0.0, 20.0, 20.0,  0.0,-20.0,-20.0,500.0]
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,500.0]
      elseif(command = 9)							; Rest Position 
         gosub movement [  0.0, 35.0, 40.0,  0.0, 35.0, 40.0,500.0] 
      endif
   IdleBot = 0
return   

;--------------------------------------------------------------------
;[PS2Input] reads the input data from the PS2 controller and processes the
;data to the parameters.
Ps2Input:
	
  low PS2SEL
  shiftout PS2CMD,PS2CLK,FASTLSBPRE,[$1\8]
  shiftin PS2DAT,PS2CLK,FASTLSBPOST,[DS2Mode\8]
  high PS2SEL
  pause 1

  low PS2SEL
  shiftout PS2CMD,PS2CLK,FASTLSBPRE,[$1\8,$42\8]	
  shiftin PS2DAT,PS2CLK,FASTLSBPOST,[DualShock(0)\8, DualShock(1)\8, DualShock(2)\8, DualShock(3)\8, |
  	DualShock(4)\8, DualShock(5)\8, DualShock(6)\8]
  high PS2SEL
  pause 1	

;serout s_out,i14400,[dec DS2Mode, 13]
DS2Mode = DS2Mode & 0x7F
  if DS2Mode <> PadMode THEN
	low PS2SEL
	shiftout PS2CMD,PS2CLK,FASTLSBPRE,[$1\8,$43\8,$0\8,$1\8,$0\8] ;CONFIG_MODE_ENTER
	high PS2SEL
	pause 1

	low PS2SEL
	shiftout PS2CMD,PS2CLK,FASTLSBPRE,[$01\8,$44\8,$00\8,$01\8,$03\8,$00\8,$00\8,$00\8,$00\8] ;SET_MODE_AND_LOCK
	high PS2SEL
	pause 1

	low PS2SEL
	shiftout PS2CMD,PS2CLK,FASTLSBPRE,[$01\8,$4F\8,$00\8,$FF\8,$FF\8,$03\8,$00\8,$00\8,$00\8] ;SET_DS2_NATIVE_MODE
	high PS2SEL
	pause 1

	low PS2SEL
	shiftout PS2CMD,PS2CLK,FASTLSBPRE,[$01\8,$43\8,$00\8,$00\8,$5A\8,$5A\8,$5A\8,$5A\8,$5A\8] ;CONFIG_MODE_EXIT_DS2_NATIVE
	high PS2SEL
	pause 1

	low PS2SEL
	shiftout PS2CMD,PS2CLK,FASTLSBPRE,[$01\8,$43\8,$00\8,$00\8,$00\8,$00\8,$00\8,$00\8,$00\8] ;CONFIG_MODE_EXIT
	high PS2SEL
	pause 100
		
	sound P9,[100\3000, 100\3500, 100\4000]
	return
  ENDIF

  IF (DualShock(1).bit3 = 0) and LastButton(0).bit3 THEN	;Start Button test
	IF(BotActive) THEN
	  'Turn off
	  Sound P9,[100\4400,80\3800,60\3200]
	  command = 9
	  gosub move
	  BotActive = False
	ELSE
	  'Turn on
	  Sound P9,[60\3200,80\3800,100\4400]
	  command = 0
	  gosub move
	  BotActive = True	
	ENDIF
  ENDIF	

  IF BotActive THEN
	IF (DualShock(1).bit0 = 0) and LastButton(0).bit0 THEN ;Select Button test
		if (TravLength = 8) then
			TravLength = 8
			Sound P9,[80\3800,60\3200]
		else
			TravLength = 6
			Sound P9,[80\3200,60\3800]
		endif
	ENDIF
	
	
	IF (DualShock(1).bit4 = 0) and LastButton(0).bit4 THEN	;Up Button test
		command = 7
		gosub move
	ENDIF
		
	IF (DualShock(1).bit6 = 0) and LastButton(0).bit6 THEN	;Down Button test
		command = 8
		gosub move
	ENDIF

	
	IF (DualShock(2).bit4 = 0) and LastButton(1).bit4 THEN	;Triangle Button test
		command = 6
		gosub move
	ENDIF

;	IF (DualShock(2).bit5 = 0) and LastButton(1).bit5 THEN	;Circle Button test
;	ENDIF	
	
	IF (DualShock(2).bit6 = 0) and LastButton(1).bit6 THEN	;Cross Button test
		command = 0
		gosub move
	ENDIF	
	
;IF (DualShock(2).bit7 = 0) and LastButton(1).bit7 THEN	;Square Button test
;ENDIF			
	
	IF (DualShock(2).bit3 = 0) AND (LastButton(1).bit3 = 1) THEN;R1 Button test
		command = 5
		gosub move
	ENDIF

	IF (DualShock(2).bit2 = 0) AND (LastButton(1).bit2 = 1) THEN;L1 Button test
		command = 4
		gosub move
	ENDIF

;	IF (DualShock(2).bit0 = 0) THEN;AND (LastButton(1).bit0 = 1) THEN 	;L2 Button test
;	ENDIF
		
;	IF (DualShock(2).bit3 = 0) THEN;AND (LastButton(1).bit3 = 1) THEN ;R2 Button test
;	ENDIF
		
	
IF (ABS(Dualshock(6)-128) > TravelDeadZone) AND (BotActive = TRUE) THEN
	PS2IN = TOFLOAT (Dualshock(6) - 128)
	if PS2IN > 0.0 then
		WalkSpeed = (PS2IN/(TOFLOAT TravLength))
		WalkAngle = (((PS2IN/10.0) + 4.0) - (TOFLOAT AnkleAdj))
	else;if (Dualshock(6)-128) < 0
		WalkSpeed = (PS2IN/(TOFLOAT TravLength))
		WalkAngle = -(((PS2IN/10.0) - 4.0) + (TOFLOAT AnkleAdj))
	endif
	command = 1
	gosub move

ELSEIF (ABS(Dualshock(5)-128) > (TravelDeadZone*4)) AND (BotActive = TRUE)
	PS2IN = TOFLOAT (Dualshock(5) - 128)
	if (PS2IN > (TOFLOAT TravelDeadZone)) AND (PS2IN < 70.0) then
		command = 14
	elseif (PS2IN >= 70.0)
		command = 12
	elseif (PS2IN < (TOFLOAT -TravelDeadZone)) AND (PS2IN > -70.0)
		command = 13
	else
		command = 11
	endif
	gosub move
ENDIF
	
	
	
  ENDIF
  
  LastButton(0) = DualShock(1)
  LastButton(1) = DualShock(2)
return	
;--------------------------------------------------------------------
    
;Should never need to edit anything below this line.  Add user subroutines above this and below main. 
lefthippos var float 
leftkneepos var float 
leftanklepos var float 
righthippos var float 
rightkneepos var float 
rightanklepos var float 
last_lefthippos var float 
last_leftkneepos var float 
last_leftanklepos var float 
last_righthippos var float 
last_rightkneepos var float 
last_rightanklepos var float 
lhspeed var float 
lkspeed var float 
laspeed var float 
rhspeed var float 
rkspeed var float 
raspeed var float 
speed var float 
longestmove var float 
;movement [lefthippos,leftkneepos,leftanklepos,righthippos,rightkneepos,rightanklepos,speed] 
movement [rightanklepos,rightkneepos,righthippos,leftanklepos,leftkneepos,lefthippos,speed] 
   if(speed<>0.0)then 
      gosub getlongest[lefthippos-last_lefthippos, | 
                   leftkneepos-last_leftkneepos, | 
                   leftanklepos-last_leftanklepos, | 
                   righthippos-last_righthippos, | 
                   rightkneepos-last_rightkneepos, | 
                   rightanklepos-last_rightanklepos],longestmove
      speed = ((longestmove*stepsperdegree)/(speed/20.0)) 
      gosub getspeed[lefthippos,last_lefthippos,longestmove,speed],lhspeed 
      gosub getspeed[leftkneepos,last_leftkneepos,longestmove,speed],lkspeed 
      gosub getspeed[leftanklepos,last_leftanklepos,longestmove,speed],laspeed 
      gosub getspeed[righthippos,last_righthippos,longestmove,speed],rhspeed 
      gosub getspeed[rightkneepos,last_rightkneepos,longestmove,speed],rkspeed 
      gosub getspeed[rightanklepos,last_rightanklepos,longestmove,speed],raspeed
   else 
      lhspeed=0.0; 
      lkspeed=0.0; 
      laspeed=0.0; 
      rhspeed=0.0; aServoOffsets(
      rkspeed=0.0; 
      raspeed=0.0; 
   endif 
   hservo [lefthip\TOINT (-lefthippos*stepsperdegree) + aServoOffsets(3)\TOINT lhspeed, | 
         righthip\TOINT (righthippos*stepsperdegree) + aServoOffsets(0)\TOINT rhspeed, | 
         leftknee\TOINT (-leftkneepos*stepsperdegree) + aServoOffsets(4)\TOINT lkspeed, | 
         rightknee\TOINT (rightkneepos*stepsperdegree) + aServoOffsets(1)\TOINT rkspeed, | 
         leftankle\TOINT (-leftanklepos*stepsperdegree) + aServoOffsets(5)\TOINT laspeed, | 
         rightankle\TOINT (rightanklepos*stepsperdegree) + aServoOffsets(2)\TOINT raspeed]
   hservowait [lefthip,righthip,leftknee,rightknee,leftankle,rightankle]

   
;idle var byte
;finished var byte
;junk var word
;sensorloop
;	finished = true
;	gethservo lefthip,junk,idle
;	if(NOT idle)then
;		finished=false
;	endif	
;	gethservo righthip,junk,idle
;	if(NOT idle)then
;		finished=false
;	endif	
;	gethservo leftknee,junk,idle
;	if(NOT idle)then
;		finished=false
;	endif	
;	gethservo rightknee,junk,idle
;	if(NOT idle)then
;		finished=false
;	endif	
;	gethservo leftankle,junk,idle
;	if(NOT idle)then
;		finished=false
;	endif	
;	gethservo rightankle,junk,idle
;	if(NOT idle)then
;		finished=false
;	endif
	;add sensor handling code here
	
	
	
;	if(NOT finished)then sensorloop
	   
   last_lefthippos = lefthippos 
   last_leftkneepos = leftkneepos 
   last_leftanklepos = leftanklepos 
   last_righthippos = righthippos 
   last_rightkneepos = rightkneepos 
   last_rightanklepos = rightanklepos

   return 

one var float 
two var float 
three var float 
four var float 
five var float 
six var float 
getlongest[one,two,three,four,five,six]
   if(one<0.0)then 
      one=-1.0*one 
   endif 
   if(two<0.0)then 
      two=-1.0*two 
   endif 
   if(three<0.0)then 
      three=-1.0*three 
   endif 
   if(four<0.0)then 
      four=-1.0*four 
   endif 
   if(five<0.0)then 
      five=-1.0*five 
   endif 
   if(six<0.0)then 
      six=-1.0*six 
   endif 
   if(one<two)then 
      one=two 
   endif 
   if(one<three)then 
      one=three 
   endif 
   if(one<four)then 
      one=four 
   endif 
   if(one<five)then 
      one=five 
   endif 
   if(one<six)then 
      one=six 
   endif 
   return one 
    
newpos var float 
oldpos var float 
longest var float 
maxval var float 
getspeed[newpos,oldpos,longest,maxval] 
   if(newpos>oldpos)then 
      return ((newpos-oldpos)/longest)*maxval 
   endif 
   return ((oldpos-newpos)/longest)*maxval 


;==============================================================================
; Subroutine: ReadServoOffsets
; Will read in the zero points that wer last saved for the different servos
; that are part of this robot.  
;
;==============================================================================
pT			var		pointer		; try using a pointer variable
cSOffsets	var		byte		; number of
bCSIn		var		byte
bCSCalc		var		byte		; calculated checksum
b			var		byte		; 
i			var		byte

ReadServoOffsets:
	readdm 0, [cSOffsets, bCSIn]
	;serout s_out, i9600, ["RSO: cnt:", dec cSOffsets, " CS in:", hex bcsIn];

	if (cSOffsets > 0) and (cSOffsets <= NUMSERVOS) then 		; offset data is bad so go to error location

		; OK now lets read in the array of data
		readdm 2, [str aServoOffsets\csOffsets*2]
		
		;... calculate checksum...
		bCSCalc = 0
	
		for i = 0 to NUMSERVOS-1
			bCSCalc = AServoOffsets(i).lowbyte + AServoOffsets(i).highbyte
;			serout s_out, i9600, [" ", sdec aServoOffsets(i),":", hex aServoOffsets(i)]
		next
		
;		serout s_out, i9600, [ " CS Calc:", hex bCSCalc]
	
		if bCSCalc <> bCSIn then 
			aServoOffsets = rep 0\NUMSERVOS
		endif
	endif
;	serout s_out, i9600, [13]
	return
