#include "Arduino.h"

#define period 10 //time between each servo adjustment in Microseconds

extern Servo ServoTable[7];
extern int Offsets[7];

float RHP = 90;
float RKP = 90;
float RAP = 90;
float LHP = 90;
float LKP = 90;
float LAP = 90;

boolean stepN;

void GroupMove(int p1, int p2, int p3, int p4, int p5, int p6, int Speed)
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
    LHP = LHP + RHS;
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

void Walk()
{
  if(stepN)
  {
    GroupMove(70, 70, 75, 70, 70, 50, 250);
    GroupMove(110, 110, 75, 110, 110, 50, 500);
    GroupMove(110, 110, 90, 110, 110, 90, 250);
    stepN = !stepN;
  }
  else
  {
    GroupMove(110, 110, 130, 110, 110, 105, 250);
    GroupMove(70, 70, 130, 70, 70, 105, 500);
    GroupMove(70, 70, 90, 70, 70, 90, 250);
    stepN = !stepN;
  }
}

void Turn_Left()
{
  Serial.println("Left");
  GroupMove(90, 90, 90, 90, 90, 90, 500);
  GroupMove(90, 90, 75, 90, 90, 55, 450);
  GroupMove(90, 90, 75, 90, 90, 75, 50);
  GroupMove(55, 55, 75, 55, 55, 75, 500);
  GroupMove(55, 55, 90, 55, 55, 90, 250);
  GroupMove(90, 90, 90, 90, 90, 90, 500);
  GroupMove(90, 90, 75, 90, 90, 55, 450);
  GroupMove(90, 90, 75, 90, 90, 75, 50);
  GroupMove(55, 55, 75, 55, 55, 75, 500);
  GroupMove(55, 55, 90, 55, 55, 90, 250);
  GroupMove(90, 90, 90, 90, 90, 90, 500);
}

void Turn_Right()
{
  Serial.println("Right");
  GroupMove(90, 90, 90, 90, 90, 90, 500);
  GroupMove(90, 90, 125, 90, 90, 105, 450);
  GroupMove(90, 90, 105, 90, 90, 105, 50);
  GroupMove(125, 125, 105, 125, 125, 105, 500);
  GroupMove(125, 125, 90, 125, 125, 90, 250);
  GroupMove(90, 90, 90, 90, 90, 90, 500);
  GroupMove(90, 90, 125, 90, 90, 105, 450);
  GroupMove(90, 90, 105, 90, 90, 105, 50);
  GroupMove(125, 125, 105, 125, 125, 105, 500);
  GroupMove(125, 125, 90, 125, 125, 90, 250);
  GroupMove(90, 90, 90, 90, 90, 90, 500);
}
