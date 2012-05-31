#include <Arduino.h>

#define period 10 //time between each servo adjustment in Microseconds

extern Servo ServoTable[6];
extern int Offsets[6];

float RHP = 90;
float RKP = 90;
float RAP = 90;
float LHP = 90;
float LKP = 90;
float LAP = 90;

float Range = 1;
boolean stepN;
int last_angle = 90;
int Speed = 300;

void GroupMove(byte p1, byte p2, byte p3, byte p4, byte p5, byte p6, int Speed)
{
  float ticks = Speed / period;
  float RHS = (p1 - RHP) / ticks;
  float RKS = (p2 - RKP) / ticks;
  float RAS = (p3 - RAP) / ticks;
  float LHS = (p4 - LHP) / ticks;
  float LKS = (p5 - LKP) / ticks;
  float LAS = (p6 - LAP) / ticks;
  for(int x = 0; x < ticks; x++)
  {
    RHP = RHP + RHS;
    RKP = RKP + RKS;
    RAP = RAP + RAS;
    LHP = LHP + LHS;
    LKP = LKP + LKS;
    LAP = LAP + LAS;
    ServoTable[0].write(RHP + Offsets[0]);
    ServoTable[1].write(RKP + Offsets[1]);
    ServoTable[2].write(RAP + Offsets[2]);
    ServoTable[3].write(LHP + Offsets[3]);
    ServoTable[4].write(LKP + Offsets[4]);
    ServoTable[5].write(LAP + Offsets[5]);
    delay(period);
  }
}

void Walk(byte angle)
{
  angle = angle*Range;
  if(stepN)
  {
    angle = 90 + angle;
    GroupMove(last_angle, last_angle, 75, last_angle, last_angle, 55, Speed);
    GroupMove(angle, angle, 75, angle, angle, 55, Speed);
    GroupMove(angle, angle, 90, angle, angle, 90, Speed);
    stepN = !stepN;
  }
  else
  {
    angle = 90 - angle;
    GroupMove(last_angle, last_angle, 120, last_angle, last_angle, 105, Speed);
    GroupMove(angle, angle, 125, angle, angle, 105, Speed);
    GroupMove(angle, angle, 90, angle, angle, 90, Speed);
    stepN = !stepN;
  }
  last_angle = angle;
}

void Turn_Right(byte angle)
{
  Serial.println("Turn_Right");
  if(angle > 125)
    angle = 125;
  else if(angle < 110)
    angle = 110;
  GroupMove(90, 90, 90, 90, 90, 90, Speed);
  GroupMove(90, 90, 75, 90, 90, 55, Speed);
  GroupMove(90, 90, 75, 90, 90, 75, Speed);
  GroupMove(angle + (90 - angle)/2, angle + (90 - angle)/2, 75, angle + (90 - angle)/2, angle + (90 - angle)/2, 75, Speed);
  GroupMove(angle + (90 - angle)/2, angle + (90 - angle)/2, 90, angle + (90 - angle)/2, angle + (90 - angle)/2, 90, Speed);
  GroupMove(angle + (90 - angle)/2, angle + (90 - angle)/2, 125, angle + (90 - angle)/2, angle + (90 - angle)/2, 105, Speed);
  GroupMove(angle + (90 - angle)/2, angle + (90 - angle)/2, 105, angle + (90 - angle)/2, angle + (90 - angle)/2, 105, Speed);
  GroupMove(angle, angle, 105, angle, angle, 105, Speed);
  GroupMove(angle, angle, 90, angle, angle, 90, Speed);
  GroupMove(90, 90, 90, 90, 90, 90, Speed);
  last_angle = 90;
}

void Turn_Left(byte angle)
{ 
  Serial.println("Turn_Left");
  if(angle < 55)
    angle = 55;
  else if(angle > 70)
    angle = 70;
  GroupMove(90, 90, 90, 90, 90, 90, Speed);
  GroupMove(90, 90, 125, 90, 90, 105, Speed);
  GroupMove(90, 90, 105, 90, 90, 105, Speed);
  GroupMove(angle + (90 - angle)/2, angle + (90 - angle)/2, 105, angle + (90 - angle)/2, angle + (90 - angle)/2, 105, Speed);
  GroupMove(angle + (90 - angle)/2, angle + (90 - angle)/2, 90, angle + (90 - angle)/2, angle + (90 - angle)/2, 90, Speed);
  GroupMove(angle + (90 - angle)/2, angle + (90 - angle)/2, 75, angle + (90 - angle)/2, angle + (90 - angle)/2, 55, Speed);
  GroupMove(angle + (90 - angle)/2, angle + (90 - angle)/2, 75, angle + (90 - angle)/2, angle + (90 - angle)/2, 75, Speed);
  GroupMove(angle, angle, 75, angle, angle, 75, Speed);
  GroupMove(angle, angle, 90, angle, angle, 90, Speed);
  GroupMove(90, 90, 90, 90, 90, 90, Speed);
  last_angle = 90;
}

void Kick_Right()
{
  GroupMove(90, 90, 90, 90, 90, 90, 500); 
  GroupMove(90, 90, 48, 90, 90, 104, 500);
  GroupMove(130, 35, 110, 90, 90, 110, 500);
  GroupMove(70, 100, 110, 90, 90, 110, 250);
  GroupMove(90, 90, 110, 90, 90, 110, 500);
  GroupMove(90, 90, 90, 90, 90, 90, 500);
  last_angle = 90;
}

void Kick_Left()
{
  GroupMove(90, 90, 90, 90, 90, 90, 500);
  GroupMove(90, 90, 76, 90, 90, 132, 500);
  GroupMove(90, 90, 70, 50, 145, 70, 500);
  GroupMove(90, 90, 70, 110, 80, 70, 250);
  GroupMove(90, 90, 70, 90, 90, 70, 500);
  GroupMove(90, 90, 90, 90, 90, 90, 500);
  last_angle = 90;
}

void Head_Thrust()
{
  GroupMove(90, 90, 90, 90, 90, 90, 500);
  GroupMove(25, 45, 90, 155, 135, 90, 500);
  GroupMove(70, 125, 90, 110, 65, 90, 300);
  delay(100);
  GroupMove(90, 90, 90, 90, 90, 90, 500);
  last_angle = 90;
}

void Get_Up_From_Front()
{
  GroupMove(90, 90, 90, 90, 90, 90, 500);
  GroupMove(120, 180, 90, 60, 10, 90, 500);
  GroupMove(60, 180, 120, 60, 10, 90, 500);
  GroupMove(10, 180, 90, 170, 0, 90, 500);
  GroupMove(90, 90, 90, 90, 90, 90, 500);
}

void Get_Up_From_Back()
{
  GroupMove(90, 90, 90, 90, 90, 90, 500); 
  GroupMove(90, 0, 90, 90, 180, 90, 500);
  GroupMove(90, 90, 90, 90, 90, 90, 500);
}

void Roll_Left()
{
  GroupMove(90, 90, 90, 90, 90, 90, 500);
  GroupMove(90, 90, 90, 140, 90, 90, 100);
  GroupMove(90, 90, 90, 90, 90, 90, 500); 
}

void Roll_Right()
{
  GroupMove(90, 90, 90, 90, 90, 90, 500);
  GroupMove(40, 90, 90, 90, 90, 90, 100);
  GroupMove(90, 90, 90, 90, 90, 90, 500); 
}
