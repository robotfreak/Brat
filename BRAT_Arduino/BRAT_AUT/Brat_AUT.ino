//Autonomous Brat code designed to avoid obstacles and wander
//by Devon Simmons 03/29/12
//Written for the BotBoarduino
//Robot kit from Lynxmotion
//Right Hip, Knee, Ankle on pins 12, 11, 10
//Left Hip, Knee, Ankle on pins 4, 3, 2
//Onboard buttons are used on pins 7, 8, 9
//Onboard Speaker is used on pin 5
//GP2D12 Sensor on analog pin 3
//Only Core libraries are used

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
#define Irpin A3
#define Speakerpin 5

int Offsets[6] = {0, 0, 0, 0, 0, 0};
Servo ServoTable[6];

//******************************************************************
//Setup:
//This is the main Arduino setup function called on startup
//******************************************************************
void setup()
{
  ServoTable[0].attach(RightHipPin);
  ServoTable[1].attach(RightKneePin);
  ServoTable[2].attach(RightAnklePin);
  ServoTable[3].attach(LeftHipPin);
  ServoTable[4].attach(LeftKneePin);
  ServoTable[5].attach(LeftAnklePin);
  pinMode(7, INPUT);  //Activate the onboard buttons for our use in the program
  pinMode(8, INPUT);  //
  pinMode(9, INPUT);  //
  if(digitalRead(7) == LOW)  //if we hold down the A button enter config mode
    Config_Offsets();
  else                       //Otherwise Load the current offsets
    Load_Offsets();
}

//******************************************************************
//Load_Offsets:
//This function loads the stored offsets from the onboard EEPROM
//into RAM for use by the function.
//******************************************************************
void Load_Offsets()
{
  EEPROM_readAnything(0, Offsets);
}

//******************************************************************
//Config_Offsets:
//If Button A is held down on startup this function will run.
//This function  allows the user to set the offsets of each 
//servo by using the three onboard button.
//Button A cycles to the next servo.
//Button B decreases the servo offset.
//Button C increases the servo offset.
//The Servo offsets are set in this order:
//RightHip > RightKnee > RightAnkle > LeftHip > LeftKnee > LeftAnkle
//******************************************************************
void Config_Offsets()
{
  tone(Speakerpin, 1000, 1000); //let the user know config has started
  delay(2000); //give some time to let go of button A
  
  for(int x = 0; x < 6; x++) //Cycle through all six servos
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
  EEPROM_writeAnything(0, Offsets); //Save the new config to non volatile EEPROM
  for(int x = 0; x < 5; x++) //let the user know they have finished the config
  {
    tone(Speakerpin, 100*x + 500, 100);
    delay(100);
  }
}
  
//******************************************************************
//ir_Sense:
//If there is something in range of the sensor the robot
//will turn to its left
//******************************************************************
void ir_Sense()
{
  if(analogRead(Irpin) > 250)
    Turn_Left();
}

//******************************************************************
//Main loop
//******************************************************************
void loop()
{
  ir_Sense();
  Walk(20);
}
