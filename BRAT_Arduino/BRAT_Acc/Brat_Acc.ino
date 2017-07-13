//Autonomous Brat code designed to keep the brat on its feet!
//Robot Brat kit from Lynxmotion
//Right Hip, Knee, Ankle on pins 3, 2, 1
//Left Hip, Knee, Ankle on pins 12, 11, 10
//Lynxmotion 2D accelerometer X, Y on analog pins 1, 2

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

int Acctemp[10];
int Acc[2];
int Offsets[7] = {0, 0, 0, 0, 0, 0, 0};
Servo ServoTable[7];

void setup()
{
  Serial.begin(115200);
  Serial.println("Brat Accelerometer");
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
  if (digitalRead(7) == LOW) //if we hold down the B button enter config mode
  {
    Load_Offsets();
    Config_Offsets();
  }
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

  for (int x = 0; x < 6; x++)
  {
    while (digitalRead(7))
    {
      if (digitalRead(8) == LOW)
      {
        Offsets[x] = Offsets[x] - 1;
        delay(100);
      }
      else if (digitalRead(9) == LOW)
      {
        Offsets[x] = Offsets[x] + 1;
        delay(100);
      }
      ServoTable[x].write(90 + Offsets[x]);
    }
    delay(500);

  }
  EEPROM_writeAnything(0, Offsets);
  for (int x = 0; x < 5; x++)
  {
    tone(5, 100 * x + 500, 100);
    delay(100);
  }
}

int read_Acc()
{
  for (int i = 0; i < 2; i++)
  {
    int A;
    int B;
    for (int x = 0; x < 10; x++)
    {
      A = analogRead(i + 1);
      B = analogRead(i + 1);
      while (abs(A - B) > 5)
      {
        A = B;
        B = analogRead(i + 1);
      }
      Acctemp[x] = (A + B) / 2;
    }
    Acc[i] = 0;
    for (int x = 0; x < 9; x++)
      Acc[i] = Acc[i] + Acctemp[x];
    Acc[i] = Acc[i] / 10;
    Serial.print(Acc[i]);
    Serial.print(" ");
  }
  Serial.println("");
}

void loop()
{
  read_Acc();
  if (Acc[0] < 350)
  {
    Get_Up_From_Back();
    delay(1000);
  }
  else if (Acc[0] > 550)
  {
    Get_Up_From_Front();
    delay(1000);
  }
  else if (Acc[1] < 350)
  {
    Roll_Right();
    delay(500);
  }
  else if (Acc[1] > 550)
  {
    Roll_Left();
    delay(500);
  }
  //  else if(analogRead(0) > 400)
  //  {
  //    Turn_Right(125);
  //    Turn_Right(125);
  //  }
  //  else
  //    Walk(20);
}
