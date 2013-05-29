//Autonomous Brat code designed to avoid obstacles, wander, and keep it on its feet
//by Devon Simmons 03/29/12
//Written for the BotBoarduino
//Robot kit from Lynxmotion
//Right Hip, Knee, Ankle on pins 12, 11, 10
//Left Hip, Knee, Ankle on pins 4, 3, 2
//Onboard buttons are used on pins 7, 8, 9
//Onboard Speaker is used on pin 5
//GP2D12 Sensor on analog pin 3
//Accelerometer X on analog pin 1
//Accelerometer Y on analog pin 2
//Only Core libraries are used

#include <EEPROM.h>
#include "WriteReadAnything.h"
#include <Servo.h>
#include "Move_Data.h"
 
//Here are our pin numbers
#define RightHipPin 12
#define RightKneePin 11
#define RightAnklePin 10
#define LeftHipPin 4
#define LeftKneePin 3
#define LeftAnklePin 2
#define Speakerpin 5
#define Irpin A3
#define AccX A1
#define AccY A2

//Main program variables
int Acctemp[10];
int Acc[2];
int Offsets[6] = {0, 0, 0, 0, 0, 0};
Servo ServoTable[6];

//******************************************************************
//Setup:
//This is the main Arduino setup function called on startup
//******************************************************************
void setup()
{
//  Serial.begin(115000);
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

int read_Acc()
{
  for(int i = 0; i < 2; i++)
  {
    int A;
    int B;
    for(int x = 0; x < 10; x++)  
    {
      A = analogRead(i? AccY : AccX);
      B = analogRead(i? AccY : AccX);
      while(abs(A - B) > 5)
      {
        A = B;
        B = analogRead(i? AccY : AccX);
      }
      Acctemp[x] = (A + B) / 2;
    }
    Acc[i] = 0;
    for(int x = 0; x < 9; x++)
      Acc[i] = Acc[i] + Acctemp[x];
    Acc[i] = Acc[i] / 10; 
  }
//  Serial.print(Acc[0]);
//  Serial.print(" ");
//  Serial.println(Acc[1]);
}
  
//******************************************************************
//ir_Sense:
//If there is something in range of the sensor the robot
//will turn to its left
//******************************************************************
boolean ir_Sense()
{
  if(analogRead(Irpin) > 250)
  {
    Turn_Left();
    return 1;
  }
  else
    return 0;
}

//******************************************************************
//Main loop
//******************************************************************
void loop()
{
  read_Acc();
  if(Acc[1] < 350)
  {
//    Serial.println("GU_Back");
    Get_Up_From_Back();
    delay(1000);
  }
  else if(Acc[1] > 550)
  {
//    Serial.println("GU_Front");
    Get_Up_From_Front();
    delay(1000);
  }
  else if(Acc[0] < 350)
  {
//    Serial.println("Roll_Right");
    Roll_Right();
    delay(500);
    return;
  }
  else if(Acc[0] > 550)
  {
//    Serial.println("Roll_Left");
    Roll_Left();
    delay(500);
    return;
  }
  if(ir_Sense())
    return;
  else
    Walk(20);
}
