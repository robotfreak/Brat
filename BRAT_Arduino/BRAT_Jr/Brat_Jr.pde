#include <PS2X_lib.h>
#include <Servo.h>
#include "MoveData.h"

PS2X ps2x;

Servo Right_hip;
Servo Right_foot;
Servo Left_hip;
Servo Left_foot;

int prevRh = 0;
int prevRf = 0;
int prevLh = 0;
int prevLf = 0;

int error;

int command;
int stepn = 1;

unsigned long tick;

void setup()
{
  Serial.begin(115200);
    error = ps2x.config_gamepad(9,7,8,6, true, true);   //setup pins and settings:  GamePad(clock, command, attention, data, Pressures?, Rumble?) check for error
 
     if(error == 0)
       Serial.println("Found Controller");

  Right_hip.attach(3);
  Right_foot.attach(2);
  Left_hip.attach(12);
  Left_foot.attach(13);
}

void walk(int t)
{
  if(Right_hip.read() == 90 || Left_hip.read() == 90)
    Step_Start();
    if(stepn == 0)
    {
      Step_0(t);
      stepn = 1;
    }
    else if(stepn == 1)
    {
      Step_1(t);
      stepn = 0;
    }
}


void loop()
{
 ps2x.read_gamepad();
 
  if(ps2x.Analog(PSS_LY) < 108 )
  {
    walk(ps2x.Analog(PSS_LY));
  }
    
    delay(100);

}
