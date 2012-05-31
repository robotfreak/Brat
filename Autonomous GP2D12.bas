;Program written for Bot Board II, Basic Atom Pro 28, IDE Ver. 8.0.1.7
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


TRUE con 1
FALSE con 0


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

command var byte 
xx var byte
ir var word
bat var word
detect var bit
behaviour var byte
filter var byte
temp var word(10)


;---------------------------------------;
;--------Command Quick Reference--------;
;---------------------------------------;
;- Command 1 = Walk Forward            -;
;- Command 2 = Walk Backward           -;
;- Command 3 = Long Stride Forward     -;
;- Command 4 = Long Stride Backward    -;
;- Command 5 = Kick                    -;
;- Command 6 = Headbutt                -;
;- Command 7 = Get up from Front       -;
;- Command 8 = Get up from Back        -;
;- Command 9 = Rest Position           -;
;- Command 0 = Home Position           -;
;- Command 11= Turn Left               -;
;---------------------------------------;
 
         sound 9,[50\4400] 
         pause 50 
         sound 9,[50\3960] 
         pause 50 
         sound 9,[50\3400] 

behaviour = 0
command = 8
gosub move
pause 2500
detect = 0

main

if (behaviour = 16) then 
  behaviour = 0           
endif
behaviour = (behaviour +1)	;let's use this to trigger behaviour at times.
gosub readir
adin 16, bat

if (bat < 270) then;battery is getting low
 sound 9,[50\5000,25\4400,50\5000]
endif

if (ir > 250) then
  detect = true
endif
sound 9,[100\(ir * 10)] 	;beep in between steps, higher pitch for closer obstacles.

if detect then 
  low 14		;turn the yellow LED on
  command=2		;back up one step
  gosub move
  command=11	;turn left two steps
  for xx=1 to 2
  gosub move
  next
  detect = false
  input 14		;turn the yellow LED off
else   
  low 12		;turn the red LED on
  command=1
  gosub move 
  input 12		;turn the red LED off
endif

if (behaviour = 5) then 
  low 13		;turn the green LED on
  command = 9
  gosub move
  pause 2000
  sound 9,[150\4400] 	;little whistle while you rest
  pause 50 
  sound 9,[50\4400] 
  pause 50 
  sound 9,[150\3960] 
  pause 50 
  sound 9,[50\3960] 
  pause 50 
  sound 9,[250\3400] 
  pause 2000
  input 13		;turn the green LED off
endif

goto main 

move:
      if(command = 1) then							; Walk Forward
         gosub movement [  7.0,-20.0,-20.0, -7.0, 20.0, 20.0, 500.0] 
         gosub movement [ -7.0,-20.0,-20.0,  7.0, 20.0, 20.0, 500.0]
         gosub movement [ -7.0, 20.0, 20.0,  7.0,-20.0,-20.0, 500.0] 
         gosub movement [  7.0, 20.0, 20.0, -7.0,-20.0,-20.0, 500.0] 
      elseif(command = 2)							; Walk Backwards
         gosub movement [ -7.0,-20.0,-20.0,  7.0, 20.0, 20.0, 500.0] 
         gosub movement [  7.0,-20.0,-20.0, -7.0, 20.0, 20.0, 500.0] 
         gosub movement [  7.0, 20.0, 20.0, -7.0,-20.0,-20.0, 500.0] 
         gosub movement [ -7.0, 20.0, 20.0,  7.0,-20.0,-20.0, 500.0] 
      elseif(command = 3)							; Long Stride Forward
         gosub movement [ 12.0,-45.0,-45.0,-12.0, 45.0, 45.0, 750.0] 
         gosub movement [-12.0,-45.0,-45.0, 12.0, 45.0, 45.0, 750.0] 
         gosub movement [-12.0, 45.0, 45.0, 12.0,-45.0,-45.0, 750.0] 
         gosub movement [ 12.0, 45.0, 45.0,-12.0,-45.0,-45.0, 750.0]
      elseif(command = 4)							; Long Stride Backward
         gosub movement [-12.0,-45.0,-45.0, 12.0, 45.0, 45.0, 750.0] 
         gosub movement [ 12.0,-45.0,-45.0,-12.0, 45.0, 45.0, 750.0] 
         gosub movement [ 12.0, 45.0, 45.0,-12.0,-45.0,-45.0, 750.0] 
         gosub movement [-12.0, 45.0, 45.0, 12.0,-45.0,-45.0, 750.0] 
      elseif(command = 5)							; Kick 
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, 500.0] 
         gosub movement [ 42.0,  0.0,  0.0,-14.0,  0.0,  0.0, 500.0] 
         gosub movement [  0.0,-32.0, 41.0,-23.0,  0.0,  0.0, 500.0] 
         gosub movement [  0.0, 24.0,-20.0,-23.0,  0.0,  0.0, 250.0] 
         gosub movement [  0.0,  0.0,  0.0,-18.0,  0.0,  0.0, 500.0] 
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, 500.0] 
         sound 9,[50\3960] 
         pause 50 
         sound 9,[50\4400] 
         pause 50 
         sound 9,[50\3960] 
      elseif(command = 7)							; Get up from front 
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, 500.0] 
         gosub movement [  0.0, 90.0, 45.0,  0.0, 90.0, 45.0, 500.0] 
         gosub movement [ 40.0, 90.0,-37.0,  0.0, 90.0, 45.0, 500.0] 
         gosub movement [  0.0, 90.0,-65.0,  0.0, 90.0,-65.0, 500.0] 
         pause 500 									; Then Bow
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, 750.0] 
         sound 9,[50\4400] 
         pause 50 
         sound 9,[50\4400] 
         pause 50 
         sound 9,[50\3960] 
      elseif(command = 8)							; Get up from back 
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,1000.0] 
         gosub movement [  0.0,-90.0,  5.0,  0.0,-90.0,  5.0,1000.0] 
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,1000.0] 
         pause 1000
         ;gosub movement [  0.0, 22.0,-80.0,  0.0, 22.0,-80.0,1000.0] 
         ;gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,1000.0]  
         sound 9,[50\3960] 
         pause 50 
         sound 9,[50\3960] 
         pause 50 
         sound 9,[50\4400] 

       elseif(command = 0)							; Home Position 
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, 500.0] 
         sound 9,[50\4400] 
         pause 50 
         sound 9,[50\4400] 
         pause 50 
         sound 9,[50\4400] 
      elseif(command = 6)							; Headbutt 
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, 500.0] 
         gosub movement [  0.0,-50.0,-90.0,  0.0,-50.0,-90.0, 500.0] 
         gosub movement [  0.0, 32.0,-58.0,  0.0, 32.0,-58.0, 400.0] 
         pause 200 
         ;gosub movement [  0.0,-11.0,  7.0,  0.0,-11.0,  7.0, 500.0] 
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, 500.0] 
         sound 9,[50\4400] 
         pause 50 
         sound 9,[50\3960] 
         pause 50 
         sound 9,[50\3960] 
      elseif(command = 11)							; Turn 
         gosub movement [  0.0,-35.0,-40.0,  0.0, 35.0, 37.0,500.0] 
         gosub movement [  0.0, 35.0, 37.0,  0.0,-35.0,-40.0,500.0] 
         gosub movement [-14.0, 35.0, 37.0, 20.0,-35.0,-40.0,500.0] 
         gosub movement [-14.0, 35.0, 37.0, 20.0, 35.0, 37.0,500.0] 
         gosub movement [ 20.0, 35.0, 37.0,-14.0, 35.0, 37.0,500.0] 
         gosub movement [ 20.0,-35.0,-40.0,-14.0, 35.0, 37.0,500.0] 

         ;gosub movement [  0.0,-35.0,-70.0,  0.0, 35.0,  7.0,500.0] 
         ;gosub movement [  0.0, 35.0,  7.0,  0.0,-35.0,-70.0,500.0] 
         ;gosub movement [-14.0, 35.0,  7.0, 20.0,-35.0,-70.0,500.0] 
         ;gosub movement [-14.0, 35.0,  7.0, 20.0, 35.0,  7.0,500.0] 
         ;gosub movement [ 20.0, 35.0,  7.0,-14.0, 35.0,  7.0,500.0] 
         ;gosub movement [ 20.0,-35.0,-70.0,-14.0, 35.0,  7.0,500.0] 



      elseif(command = 9)							; Rest Position 
         gosub movement [  0.0, 45.0, 45.0,  0.0, 45.0, 45.0, 500.0] 
      endif 
return   

    
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

; variables passed to gethservo
idle var byte		
finished var byte
junk var word


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
      rhspeed=0.0; 
      rkspeed=0.0; 
      raspeed=0.0; 
   endif 
   hservo [lefthip\TOINT (-lefthippos*stepsperdegree) + aServoOffsets(3)\TOINT lhspeed, | 
         righthip\TOINT (righthippos*stepsperdegree) + aServoOffsets(0)\TOINT rhspeed, | 
         leftknee\TOINT (-leftkneepos*stepsperdegree) + aServoOffsets(4)\TOINT lkspeed, | 
         rightknee\TOINT (rightkneepos*stepsperdegree) + aServoOffsets(1)\TOINT rkspeed, | 
         leftankle\TOINT (-leftanklepos*stepsperdegree) + aServoOffsets(5)\TOINT laspeed, | 
         rightankle\TOINT (rightanklepos*stepsperdegree) + aServoOffsets(2)\TOINT raspeed]
   ;hservowait [lefthip,righthip,leftknee,rightknee,leftankle,rightankle]

	; Simple loop to check the status of all of servos.  This loop will
	; terminate when all of the servos say that they are idle.  I.E.
	; they reached their new destination.   
	do 
		finished = hservoidle(lefthip) and hservoidle(righthip) and hservoidle(leftknee) and hservoidle(rightknee) 	and hservoidle (leftankle) and hservoidle(rightankle)
		
		; ??? - we say not to edit, yet???
		;add sensor handling code here
		;adin 0,ir
		;if (ir > 210) then 
		;  detect = true
		;endif	
		
	while (NOT finished)
	   
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
   
readir

 for filter = 0 to 9
   adin 19, temp(filter)
 next 
 ir = 0 
 for filter = 0 to 9
 ir = ir + temp(filter)
 next 
 ir = ir / 10
 ;sound 9,[10\4000]
 ;serout s_out,i38400,[dec ir ,13]
return


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
