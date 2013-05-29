//This File contains all of the Sequences and move Functions.
//WARNING! These Sequences will only work correctly using the default brat configuration.
//Adding any extra top weight will alter the robots balance and have unexpected results.

#include <Arduino.h>


boolean stepN; //Keeps track of which foot it forward
int last_angle = 90; //Holds the last known leg displacement

//Causes the robot to take a step forward for each callback
void Walk(byte angle, int Speed)
{
  if(stepN)
  {
    angle = 90 + angle;
    if(angle == last_angle)
    {
      stepN = !stepN;
      return;
    }
    Command Walk1 = {3,-1,{
    {last_angle, last_angle, 55, last_angle, last_angle, 75, Speed},
    {angle, angle, 75, angle, angle, 75, Speed + 100},
    {angle, angle, 90, angle, angle, 90, Speed }}
    };
    Set_Current_Command(Walk1);
    stepN = !stepN;
  }
  else
  {
    angle = 90 - angle;
    if(angle == last_angle)
    {
      stepN = !stepN;
      return;
    }
    Command Walk2 = {3,-1,{
    {last_angle, last_angle, 105, last_angle, last_angle, 125, Speed},
    {angle, angle, 105, angle, angle, 105, Speed + 100},
    {angle, angle, 90, angle, angle, 90, Speed}}
    };
    Set_Current_Command(Walk2);
    stepN = !stepN;
  }
  last_angle = angle;
}

//Causes the robot to turn left or right based on the angle passed to the function
void Turn(byte angle, int Speed)
{
  angle += 90;
  Command Turn = {9,-1,{
  {90, 90, 55, 90, 90, 75, Speed},
  {90, 90, 75, 90, 90, 75, Speed},
  {angle + (90 - angle)/2, angle + (90 - angle)/2, 75, angle + (90 - angle)/2, angle + (90 - angle)/2, 75, Speed},
  {angle + (90 - angle)/2, angle + (90 - angle)/2, 90, angle + (90 - angle)/2, angle + (90 - angle)/2, 90, Speed},
  {angle + (90 - angle)/2, angle + (90 - angle)/2, 105, angle + (90 - angle)/2, angle + (90 - angle)/2, 125, Speed},
  {angle + (90 - angle)/2, angle + (90 - angle)/2, 105, angle + (90 - angle)/2, angle + (90 - angle)/2, 105, Speed},
  {angle, angle, 105, angle, angle, 105, Speed},
  {angle, angle, 90, angle, angle, 90, Speed},
  {90, 90, 90, 90, 90, 90, Speed}}};
  Set_Current_Command(Turn);
  last_angle = 90;
}

//Fell on your face? This might help
void Get_Up_From_Front()
{
  Command Get_Up_From_Front = {5,-1, {
  {90, 90, 90, 90, 90, 90, 500},
  {60, 0, 90, 120, 170, 90, 500},
  {120, 0, 60, 120, 170, 90, 500},
  {170, 0, 90, 10, 180, 90, 500},
  {90, 90, 90, 90, 90, 90, 1000}}};
  Set_Current_Command(Get_Up_From_Front);
}

//Laying on your back? Try this out
void Get_Up_From_Back()
{
  Command Get_Up_From_Back = {3,-1, {
  {90, 90, 90, 90, 90, 90, 500},
  {80, 180, 90, 100, 0, 90, 500},
  {90, 90, 90, 90, 90, 90, 500}}};
  Set_Current_Command(Get_Up_From_Back);
}

//Oh, you're on your side? I thought about that too
void Roll_Left()
{
  Command Roll_Left = {3,-1, {
  {90, 90, 90, 90, 90, 90, 500},
  {90, 90, 90, 30, 90, 90, 100},
  {90, 90, 90, 90, 90, 90, 500}}};
  Set_Current_Command(Roll_Left);
}

//Other side? You're covered
void Roll_Right()
{
  Command Roll_Right = {3,-1, {
  {90, 90, 90, 90, 90, 90, 500},
  {150, 90, 90, 90, 90, 90, 100},
  {90, 90, 90, 90, 90, 90, 500}}};
  Set_Current_Command(Roll_Right);
}

//Destroy all of your enemies with a mighty left kick
void Kick_Left()
{
  Command Kick_Left = {6,-1, {
  {90, 90, 90, 90, 90, 90, 500},
  {90, 90, 132, 90, 90, 76, 500},
  {50, 145, 70, 90, 90, 70, 500},
  {110, 80, 70, 90, 90, 70, 250},
  {90, 90, 70, 90, 90, 70, 500},
  {90, 90, 90, 90, 90, 90, 500}}};
  last_angle = 90;
  Set_Current_Command(Kick_Left);
}

//Deliver the pain with a monsterous Right Kick
void Kick_Right()
{
  Command Kick_Right = {6,-1, {
  {90, 90, 90, 90, 90, 90, 500},
  {90, 90, 104, 90, 90, 48, 500},
  {90, 90, 110, 130, 25, 110, 500},
  {90, 90, 110, 70, 100, 110, 250},
  {90, 90, 110, 90, 90, 110, 500},
  {90, 90, 90, 90, 90, 90, 500}}};
  last_angle = 90;
  Set_Current_Command(Kick_Right);
}

//Make like a soccer player and head thrust the target
void Head_Thrust()
{
  Command Head_Thrust = {4,-1, {
  {90, 90, 90, 90, 90, 90, 500},
  {155, 135, 90, 25, 45, 90, 500},
  {110, 55, 90, 70, 125, 90, 300},
  {90, 90, 90, 90, 90, 90, 500}}};
  last_angle = 90;
  Set_Current_Command(Head_Thrust);
}


