;------------------------------------
; Mech Brat servo offset finder.
; 
; This version is written for the Atom Pro
; and uses HSERVO.  Also this version is
; table driven such that to change for a different
; program you just need to change the text and servo numbers...
;									
;------------------------------------
;			  How to use			
;									
; Press A to decrease the servo 	
;  offset by 5us					
;									
; Press C to increase the servo	
;  offset by 5us					
;									
; Press B to change which servo is 
;  being manipulated, and to send	
;  data back to the terminal		
;
;
; The servos are changed in this order:	
; Right Hip -> Right Knee -> Right	  ---+
;		^					  Ankle	     |
;		|							     |
;		|								 V
;		Send <-Turret <- Left <- Left <- Left
;		Data	        Ankle	Knee 	Hip	
;------------------------------------------



enablehservo


;System variables
; Note; these dfines are only used in the table below, could simply code into table.
righthip		con p10 
rightknee		con p8 
rightankle		con p7 
lefthip			con p6 
leftknee		con p5 
leftankle		con p4 

Turret			con p11


NUMSERVOS		con	7
aServoOffsets		var	sword(NUMSERVOS)				
ServoTable		bytetable RightHip,rightknee, rightankle,lefthip, leftknee, leftankle, Turret
 				

TextTbl			bytetable 	"righthip_start   con ", 0,| 
							"rightknee_start  con ", 0,| 
							"rightankle_start con ", 0,| 
							"lefthip_start    con ", 0,|  
							"leftknee_start   con ", 0,| 
							"leftankle_start  con ", 0,| 
							"turret_start     con ", 0,|
							0


i				var byte		; temp counter
CurrentServo	var byte		; Which servo is current
StrStart		var	byte		; used in our dump function to know which byte we are starting at

;button init
buttonA 		var bit
buttonB 		var bit
buttonC 		var bit

prevA 			var bit
prevB 			var bit
prevC 			var bit


;==============================================================================
; Complete initialization
;==============================================================================
	CurrentServo = 0
	aServoOffsets = rep 0\NUMSERVOS		; Use the rep so if size changes we should properly init

	; try to retrieve the offsets from EEPROM:
	
	; see how well my pointers work
	gosub ReadServoOffsets

	
	input p12
	input p13
	input p14

	sound 9,[50\3800, 50\4200, 40\4100]
 
	gosub MoveAllServos

	gosub ShowWhichServo

;==============================================================================
; Main Loop
;==============================================================================
	
main:
	; First save away the previous state of the buttons
	prevA = buttonA
	prevB = buttonB
 	prevC = buttonC

	; Next get the current state of the buttons
 	buttonA = in12
 	buttonB = in13
 	buttonC = in14

	; If button A is pressed, we decrement the current servos offset
 	if (buttonA = 0) AND (prevA = 1) then
  		sound 9,[50\3800]
  
		if (aServoOffsets(CurrentServo) > -2000) then
			aServoOffsets(CurrentServo) = aServoOffsets(CurrentServo) - 25
			hservo [ServoTable(CurrentServo)\aServoOffsets(CurrentServo)\128]
			hservowait[ServoTable(CurrentServo)]

   		else
    		sound 9,[150\3500]
 		endif 
  
  	; If ButtonB is pressed then we increment to the next button, if at the end
  	; of the list we dump out the current offset values
 	elseif (buttonB = 0) AND (prevB = 1)
  		sound 9,[50\(3600 + (currentServo * 100))]
    
  		currentServo = currentServo + 1
  		if(currentServo = NUMSERVOS) then
   			sound 9,[75\3200, 50\3300]
   			gosub output_data
  		else
	  		gosub ShowWhichServo
  	
  		endif
 

	; If button C is pressed we increment the offset of the current servo
 	elseif (buttonC = 0) AND (prevC = 1)
  		sound 9,[50\4400]
  
		if (aServoOffsets(CurrentServo) < 2000) then
			aServoOffsets(CurrentServo) = aServoOffsets(CurrentServo) + 25
			hservo [ServoTable(CurrentServo)\aServoOffsets(CurrentServo)\128]
			hservowait[ServoTable(CurrentServo)]
		else
    		sound 9,[150\3500]
 		endif 
  
 	endif
 
	goto main


;==============================================================================
; subroutine: MoveServos
; Calls Hservo to move all of the servos to their current zero location
;==============================================================================
 				

MoveAllServos:
	for i = 0 to numservos-1
		hservo [ServoTable(i)\aServoOffsets(i)\0]
	next
return

;==============================================================================
; Subroutine: ShowWhichServo
; Helps to let the user know which servo they are adjusting
; then it puts it to the current position...
;==============================================================================
ShowWhichServo:
	hservo [ServoTable(CurrentServo)\-2000\128]
	hservowait[ServoTable(CurrentServo)]
	hservo [ServoTable(CurrentServo)\2000\128]
	hservowait[ServoTable(CurrentServo)]
	hservo [ServoTable(CurrentServo)\0\128]
	hservowait[ServoTable(CurrentServo)]

	hservo [ServoTable(CurrentServo)\aServoOffsets(CurrentServo)\128]
	hservowait[ServoTable(CurrentServo)]

return


;==============================================================================
; Subroutine: Output_data
; Outputs to the user the current zero point offsets for each of the servos
;==============================================================================
output_data
	serout s_out,i9600,[";[SERVO OFFSETS]",13]

	; loop through the servo offsets printing out the string and offset.	
	StrStart = 0
	for i = 0 to numservos-1
		serout s_out,i9600,[str TextTbl(StrStart)\80\0, sdec aServoOffsets(i),13]
		
		; Now find the beginning of the next string.
		while (TextTbl(StrStart) <> 0)
			StrStart = StrStart + 1
		wend
		StrStart = StrStart + 1	; and then get to the first character of the next string
	next
	
	; And lets output the servo offsets into the EEPROM to retrieve later..
	gosub WriteServoOffsets

		
	buttonB = 1	; make sure the loop is primed... 
	
	; wait until button B is pressed again.
 	do
		prevB = buttonB 
		buttonB = in13
	while (buttonB = 1) or (prevB = 0)
	
	currentServo = 0  
	sound 9,[200\3800]
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
;==============================================================================
; Subroutine: WriteServoOffsets
; Will write out the current servo offsets to the EEPROM on the BAP29  
;
;==============================================================================
WriteServoOffsets:
	; OK First calculate the checksum
	; We will do something simple like add all of the bytes to each other.
	bCSCalc = 0

	for i = 0 to NUMSERVOS-1
		bCSCalc = AServoOffsets(i).lowbyte + AServoOffsets(i).highbyte
	next
	
	; Now write out number of serovs, checksum, followed by offset data
	writedm 0, [NUMSERVOS, bCSCalc, str aServoOffsets\NUMSERVOS*2]
	return
	