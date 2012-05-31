;Program written for Bot Board II, Basic Atom Pro 28, IDE Ver. 8.0.1.7
;Written by Nathan Scherdin, modified by Jim and James Frye
;System variables 
righthip	con p10 
rightknee	con p8 
rightankle	con p7 
lefthip		con p6 
leftknee	con p5 
leftankle	con p4 
head		con p11

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

pause 1000
hservo[head\0\0,righthip\0\0,rightknee\0\0,rightankle\0\0,lefthip\0\0,leftknee\0\0,leftankle\0\0]
pause 50
gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0] 
;low 1 
;low 2 
pause 500 

command var byte 
pos var sbyte
scancount var nib
ir var word
bat var word
detpos var sbyte
xx var nib
shortenir var nib

side1 var sbyte
side2 var sbyte
stepvar var sbyte

far con 120
middle con 250
close con 400

filter var byte
irtemp var word(10)

;main 
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
;- Command 10= Small Step              -;
;- Command 11= Turn Left               -;
;- Command 13= Coarse Correct Left     -;
;- Command 14= Coarse Correct Right    -;
;- Command 15= Fine Correct Left       -;
;- Command 16= Fine Correct Right      -;
;---------------------------------------;
 
         sound 9,[50\4400] 
         pause 50 
         sound 9,[50\3960] 
         pause 50 
         sound 9,[50\3400] 
 
;command = 8
;gosub move
;pause 2500

;side1 = -110
;side2 = 110
stepvar = 1
scandir var bit
pos = 0
scandir = 1	;1 = cw 0 = ccw
scancount = 0
shortenir = 0

main

;adin 16, bat

;if (bat < 270) then;the battery is getting low
; sound 9,[50\5000,25\4400,50\5000]
;endif

if(pos = 110) then
  scandir = 0
  scancount = scancount + 1
  elseif(pos = -110)
    scandir = 1
    scancount = scancount + 1
endif

if (scandir = 1) then
  pos = pos + 1 max 110
  elseif(scandir = 0)
    pos = pos - 1 min -110
endif

if(scancount > 5) then
  scancount = 0
  gosub nothinghere
endif

hservo[head\ (pos * 100) \ 255]

gosub readir

if(detpos > 0) then
  scandir = 0
  elseif(detpos < 0)
    scandir = 1
endif

if (ir < middle) and (ir > far) then 
  if(detpos < 20) and (detpos > -20) then
    command = 1
    gosub move
    command = 0
    gosub move
    elseif(detpos > 20)
      command = 16
      gosub move
      elseif(detpos < -20) 
        command = 15
        gosub move
  endif
endif

if (ir < close) and (ir > middle) then 
  if(detpos < 20) and (detpos > -20) then
    command = 10
    gosub move
    command = 0
    gosub move
    elseif(detpos > 20)
      command = 16
      gosub move
      elseif(detpos < -20)
        command = 15
        gosub move
  endif
endif

if (ir > close) then
  sound 9,[100\3750, 50\3950, 100\3800]
  gosub somethinghere
endif

  ;sound 9,[10\(ir * 10)]

  pause 10


detpos = 0

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
         pause 500 
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
         ;sound 9,[50\4400] 
         ;pause 50 
         ;sound 9,[50\4400] 
         ;pause 50 
         ;sound 9,[50\4400] 
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
         
      elseif(command = 13)							;coarse correct left
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,500.0]
         gosub movement [ 35.0,  0.0,  0.0,-18.0,  0.0,  0.0,500.0]
         pause 100
         gosub movement [  2.0,-20.0,-20.0,-18.0, 20.0, 20.0,500.0]
         gosub movement [  0.0,-20.0,-20.0,  0.0, 20.0, 20.0,500.0]
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,500.0]

      elseif(command = 14)							;coarse correct right
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,500.0]
         gosub movement [-18.0,  0.0,  0.0, 35.0,  0.0,  0.0,500.0]
         pause 100
         gosub movement [-18.0, 20.0, 20.0,  2.0,-20.0,-20.0,500.0]
         gosub movement [  0.0, 20.0, 20.0,  0.0,-20.0,-20.0,500.0]
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,500.0]

      elseif(command = 15)							;fine correct left
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,500.0]
         gosub movement [-15.0,  0.0,  0.0, 35.0,  0.0,  0.0,500.0]
         gosub movement [-15.0,  0.0,  0.0, 26.0, 25.0, 25.0,500.0]
         gosub movement [  0.0,  0.0,  0.0,  0.0, 25.0, 25.0,500.0]
         gosub movement [ 40.0,  0.0,  0.0,-15.0, 25.0, 25.0,500.0]
         pause 100
         gosub movement [ 26.0,-25.0,-25.0,-15.0, 25.0, 25.0,500.0]
         gosub movement [  0.0,-25.0,-25.0,  0.0, 25.0, 25.0,500.0]
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,500.0]

      elseif(command = 16)							;fine correct right 
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,500.0]
         gosub movement [ 35.0,  0.0,  0.0,-15.0,  0.0,  0.0,500.0]
         gosub movement [ 26.0, 25.0, 25.0,-15.0,  0.0,  0.0,500.0]
         gosub movement [  0.0, 25.0, 25.0,  0.0,  0.0,  0.0,500.0]
         gosub movement [-15.0, 25.0, 25.0, 40.0,  0.0,  0.0,500.0]
         pause 100
         gosub movement [-15.0, 25.0, 25.0, 26.0,-25.0,-25.0,500.0]
         gosub movement [  0.0, 25.0, 25.0,  0.0,-25.0,-25.0,500.0]
         gosub movement [  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,500.0]       

      elseif(command = 9)							; Rest Position 
        gosub movement [  0.0, 45.0, 45.0,  0.0, 45.0, 45.0, 500.0] 

      elseif(command = 10)							; Walk Forward
        gosub movement [  7.0,-10.0,-10.0, -7.0, 10.0, 10.0, 500.0] 
        gosub movement [ -7.0,-10.0,-10.0,  7.0, 10.0, 10.0, 500.0]
        gosub movement [ -7.0, 10.0, 10.0,  7.0,-10.0,-10.0, 500.0] 
        gosub movement [  7.0, 10.0, 10.0, -7.0,-10.0,-10.0, 500.0] 

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
   adin 19, irtemp(filter)
 next 
 ir = 0 
 for filter = 0 to 9
 ir = ir + irtemp(filter)
 next 
 ir = ir / 10
 ;sound 9,[10\4000]
 ;serout s_out,i38400,[dec ir ,13]
 if (shortenir = 0) then
   if (ir > far) then
     detpos = pos
   endif
   elseif (shortenir = 1)
     if (ir > 375) then
       detpos = pos
     endif
 endif

return



nothinghere

command = 14
for xx = 1 to 3
  gosub move
next
command = 0
gosub move


return




somethinghere

if(pos = 75) then
  scandir = 0
  scancount = scancount + 1
  elseif(pos = -75)
    scandir = 1
    scancount = scancount + 1
endif

if (scandir = 1) then
  pos = pos + 1 max 75
  elseif(scandir = 0)
    pos = pos - 1 min -75
endif

if(scancount > 6) then
  scancount = 0
  sound 9,[75\3750, 50\4100, 75\3500]
  return
endif

hservo[head\ (pos * 100) \ 255]

gosub readir

if(detpos > 25) and (ir > 375) then ;25 instead of 0 to move the 'center point'
  scandir = 0
  elseif(detpos < 25) and (ir > 375)
    scandir = 1
endif

;serout s_out,i38400,["ir = ", dec ir, "   pos = ", sdec pos, "   scandir = ", dec scandir, "  detpos = ", sdec detpos, 13]

if (detpos > 35) and (ir > 375) then
  command = 16
  gosub move
  elseif (detpos < 15) and (ir > 375) 
    command = 15
    gosub move
    elseif (detpos >= 15) and (detpos <= 35) and (ir > 375) and (ir < 425)
      command = 5
      gosub move
      elseif (detpos >= 15) and (detpos <= 35) and (ir > 425)
        command = 10
        gosub move
        command = 5
        gosub move
endif



detpos = 25

pause 10

goto somethinghere

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
