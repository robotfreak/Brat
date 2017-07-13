//Autonomous Brat code designed to avoid obstacles and wander
//by Devon Simmons
//Robot kit from Lynxmotion
//Right Hip, Knee, Ankle on pins 4, 3, 2
//Left Hip, Knee, Ankle on pins 11, 12, 13
//Pan Servo on pin 10
//GP2D12 Sensor on analog pin 0

#include <EEPROM.h>
#include "WriteReadAnything.h"
#include <Servo.h>
#include "Move_Data.h"
 
#define RightHipPin 12
#define RightKneePin 11
#define RightAnklePin 10
#define LeftHipPin 4
#define LeftKneePin 3
#define LeftAnklePin 2
#define SensorServoPin 13



int Offsets[7] = {0, 0, 0, 0, 0, 0, 0};

Servo ServoTable[7];

void setup()
{
  Serial.begin(115200);
  ServoTable[0].attach(RightHipPin);
  ServoTable[1].attach(RightKneePin);
  ServoTable[2].attach(RightAnklePin);
  ServoTable[3].attach(LeftHipPin);
  ServoTable[4].attach(LeftKneePin);
  ServoTable[5].attach(LeftAnklePin);
  ServoTable[6].attach(SensorServoPin);
  pinMode(7, INPUT);  //Activate the onboard buttons for our use in the program
  pinMode(8, INPUT);  //
  pinMode(9, INPUT);  //
  if(digitalRead(7) == LOW)  //if we hold down the A button enter config mode
    Config_Offsets();
  else                       //Otherwise Load the current offsets
    Load_Offsets();
}

void Load_Offsets()
{
  EEPROM_readAnything(0, Offsets);
}

void Config_Offsets()
{
  tone(5, 1000, 1000); 
  delay(2000);
  
  for(int x = 0; x < 6; x++)
  {
    while(digitalRead(7))
    {
      if(digitalRead(8) == LOW)
        {
          Offsets[x] = Offsets[x] - 1;
          delay(100);
        }
      else if(digitalRead(9) == LOW)
      {
        Offsets[x] = Offsets[x] + 1;
        delay(100);
      }
      ServoTable[x].write(90 + Offsets[x]); 
    }
    delay(500);
    
  }
  EEPROM_writeAnything(0, Offsets);
  for(int x = 0; x < 5; x++)
  {
    tone(5, 100*x + 500, 100);
    delay(100);
  }
}
  
//******************************************************************
//ir_Sense:
//moves the sensor servo 180 degrees and reads the sensor 
//each degree of movement. If something is detected then the angle
//of the servo is read and the robot turns left or right
//******************************************************************
void ir_Sense()
{
  if(stepN)
  {
    for(int x = 0; x < 180; x++)
    {
      ServoTable[6].write(x);
      delay(5);
      if(analogRead(0) > 250)
        goto Detection;
    }
  }
  else
  {
    for(int x = 180; x > 0; x--)
    {
      ServoTable[6].write(x);
      delay(5);
      if(analogRead(0) > 250)
        goto Detection;
    }
  }
  return;
  Detection:
  Serial.println(ServoTable[6].read());
  if(ServoTable[6].read() > 90)
    Turn_Left();
  else
    Turn_Right();
}

void loop()
{
  ir_Sense();
  Walk();
}
