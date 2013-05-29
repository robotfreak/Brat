//Autonomous Brat code designed Seek out water bottles and knock them over
//Robot kit from Lynxmotion
//Right Hip, Knee, Ankle on pins 4, 3, 2
//Left Hip, Knee, Ankle on pins 11, 12, 13
//Pan Servo on pin 10
//GP2D12 Sensor on analog pin 0

#include <EEPROM.h>
#include "WriteReadAnything.h"
#include <Servo.h>
#include "Move_Data.h"
 
#define RightHipPin 4
#define RightKneePin 3
#define RightAnklePin 2
#define LeftHipPin 11
#define LeftKneePin 12
#define LeftAnklePin 13
#define SensorServoPin 10

#define Far 150

#define Middle 300
#define Close 400
int irtemp[10];
byte detpos;
int ir;
boolean dirflag = false;
byte pos = 90;
boolean scandir = 0;
byte scancount = 0;



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
  
void nothing_Here()
{
  Serial.println("nothing Here");
  Turn_Right(130);
  Turn_Right(130);
}

int read_Ir()
{
  int A = analogRead(0);
  delay(1); 
  int B = analogRead(0);
  int number = 0;
  for(int x = 0; x < 10; x++)  
  {
    A = analogRead(0);
    B = analogRead(0);
    while(abs(A - B) > 5)
    {
      A = B;
      B = analogRead(0);
    }
    irtemp[x] = (A + B) / 2;
  }
  ir = 0;
  for(int x = 0; x < 9; x++)
    ir = ir + irtemp[x];
  ir = ir / 10; 
  
  if(ir > Far)
    detpos = pos;
}

void Scan()
{
  if(pos >= 180)
    {
      scandir = 0;
      scancount = scancount++;
    }
    else if(pos <= 0)
    {
      scandir = 1;
      scancount = scancount++;
    }
    
    
    if(scandir == 1)
      pos = pos++;
    else
      pos = pos--;
    
    ServoTable[6].write(pos);
}


void somethingHere()
{
  while(scancount < 6)
  {
    
    Scan();
    read_Ir();
    
    if(detpos > 110 && ir > 375)
    {  
      Turn_Right(detpos);
      scandir = 1;
    }
    else if(detpos < 70 && ir > 375)
    {
      Turn_Left(detpos);
      scandir = 0;
    }
    else if(detpos >= 80 && detpos <= 100 && ir > 375 && ir < 425)
    {
      Walk(5);
      Walk(5);
      Head_Thrust();
      scancount = 0;
      return;
    }
    else if(detpos < 80 && detpos >= 70 && ir > 375)
    {
      Walk(5);
      Walk(5);
      Kick_Left();
      scancount = 0;
      return;
    }
    else if(detpos > 100 && detpos <= 110 && ir > 375)
    {
      Walk(5);
      Walk(5);
      Kick_Right();
      scancount = 0; 
      return;
    }
    
    detpos = 90;
    
    delay(10);
    
  }
  scancount = 0;
}


void loop()
{
  Scan();
  read_Ir();
  
  
    
  if(scancount > 5)
  {
    scancount = 0;
    nothing_Here();
  }
  
  ServoTable[6].write(pos);
  
  read_Ir();
  
  if(detpos > 95)
    scandir = 1;
  else if(detpos < 85)
    scandir = 0;
    
  if(ir < Close && ir > Far)
  {
    scancount = 0;
    if(detpos < 105 && detpos > 75)
    {
      if(ir > Middle)
      {  
        Walk(5);
      }
      else
      {
        Walk(10);
      }
    }
    else if(detpos > 105)
    {
      Turn_Right(detpos);
      scandir = 1;
    }
    else if(detpos < 75)
    {
      Turn_Left(detpos);
      scandir = 0;
    }
  }
  
  
  if(ir > Close)
  {
    scancount = 0;
    somethingHere();
  }
   
  detpos = 90;
  
  delay(3);
    
  
}
