#include <Arduino.h>

#define period 10 //time between each servo adjustment in Milliseconds

extern Servo ServoTable[6];
extern int Offsets[6];

float RHP = 90;
float RKP = 90;
float RAP = 90;
float LHP = 90;
float LKP = 90;
float LAP = 90;

boolean stepN;
int last_angle = 90;
int Speed = 400;

//******************************************************************
//GroupMove:
//This function takes six inputs one for each servo in the range
//of 0 to 180. It allows us to move all six servos at the same
//time while making sure that they start and stop at the same
//time.
//******************************************************************
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

//******************************************************************
//Walk:
//This will make the robot take one step forward each time it's
//called.
//******************************************************************
void Walk(byte angle)
{
  if(stepN)
  {
    angle = 90 + angle;
    GroupMove(last_angle, last_angle, 55, last_angle, last_angle, 75, Speed);
    GroupMove(angle, angle, 75, angle, angle, 75, Speed);
    GroupMove(angle, angle, 90, angle, angle, 90, Speed);
    stepN = !stepN;
  }
  else
  {
    angle = 90 - angle;
    GroupMove(last_angle, last_angle, 105, last_angle, last_angle, 125, Speed);
    GroupMove(angle, angle, 105, angle, angle, 105, Speed);
    GroupMove(angle, angle, 90, angle, angle, 90, Speed);
    stepN = !stepN;
  }
  last_angle = angle;
}

void Turn_Left()
{
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

void Get_Up_From_Front()
{
  GroupMove(90, 90, 90, 90, 90, 90, 500);
  GroupMove(60, 0, 90, 120, 170, 90, 500);
  GroupMove(120, 0, 60, 120, 170, 90, 500);
  GroupMove(170, 0, 90, 10, 180, 90, 500);
  GroupMove(90, 90, 90, 90, 90, 90, 1000);
}

void Get_Up_From_Back()
{
  GroupMove(90, 90, 90, 90, 90, 90, 500); 
  GroupMove(90, 180, 90, 90, 0, 90, 500);
  GroupMove(90, 90, 90, 90, 90, 90, 500);
}

void Roll_Left()
{
  GroupMove(90, 90, 90, 90, 90, 90, 500);
  GroupMove(90, 90, 90, 40, 90, 90, 100);
  GroupMove(90, 90, 90, 90, 90, 90, 500); 
}

void Roll_Right()
{
  GroupMove(90, 90, 90, 90, 90, 90, 500);
  GroupMove(140, 90, 90, 90, 90, 90, 100);
  GroupMove(90, 90, 90, 90, 90, 90, 500); 
}
