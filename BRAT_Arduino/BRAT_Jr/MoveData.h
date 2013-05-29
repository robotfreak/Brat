#include "WProgram.h"

extern Servo Right_hip;
extern Servo Right_foot;
extern Servo Left_hip;
extern Servo Left_foot;

extern unsigned long tick;
extern int command;




void Move(int Rh, int Rf, int Lh, int Lf, int time)
{
  while(Rh != Right_hip.read() || Rf != Right_foot.read() || Lh != Left_hip.read() || Lf != Left_foot.read())
  {
    
    if((millis() - tick) >= time)
      {
        tick = millis();
        if(Rh > Right_hip.read())
          Right_hip.write(Right_hip.read() + 1);
          
        else if (Rh < Right_hip.read())
          Right_hip.write(Right_hip.read() - 1);
          
        if(Lh > Left_hip.read())
          Left_hip.write(Left_hip.read() + 1);
          
        else if (Lh < Left_hip.read())
          Left_hip.write(Left_hip.read() - 1);
          
        if(Rf > Right_foot.read())
          Right_foot.write(Right_foot.read() + 1);
          
        else if (Rf < Right_foot.read())
          Right_foot.write(Right_foot.read() - 1);\
          
        if(Lf > Left_foot.read())
          Left_foot.write(Left_foot.read() + 1);
          
        else if (Lf < Left_foot.read())
          Left_foot.write(Left_foot.read() - 1);
          
          
      }
  }
}

void Step_Start()
{
  Move(90, 70, 90, 70, 10);
  delay(50);
  Move(45, 70, 45, 70, 10);
  delay(50);
}

void Step_0(int x)
{
  Move(45, 110, 45, 110, x + 5);
  delay(50);
  Move(135, 110, 135, 110, x);
  delay(50);
}

void Step_1(int x)
{
  Move(135, 70, 135, 70, x + 5);
  delay(50);
  Move(45, 70, 45, 70, x);
  delay(50);
}

void Turn_Right()
{
  Move(90, 90, 90, 90, 10);
  delay(100);
  Move(90, 110, 90, 110, 10);
  delay(50);
  Move(110, 110, 90, 110, 10);
  delay(50);
  Move(110, 70, 90, 70, 10);
  delay(50);
  Move(90, 70, 110, 70, 10);
  delay(50);
  Move(90, 110, 110, 110, 10);
  delay(50);
  Move(110, 110, 90, 110, 10);
  delay(50);
  Move(110, 70, 90, 70, 10);
  delay(50);
  Move(90, 90, 90, 90, 10);  
}

void Turn_Left()
{
  Move(90, 90, 90, 90, 10);
  delay(100);
  Move(90, 70, 90, 70, 10);  //lean on left foot
  delay(50);
  Move(90, 70, 70, 70, 10); //turn on left hip
  delay(50);
  Move(90, 110, 70, 110, 10); //lean on right foot
  delay(50);
  Move(70, 110, 90, 110, 10);
  delay(50);
  Move(70, 70, 90, 70, 10);
  delay(50);
  Move(90, 70, 70, 70, 10);
  delay(50);
  Move(90, 110, 70, 110, 10);
  delay(50);
  Move(90, 90, 90, 90, 10);  
}
