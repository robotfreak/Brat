#include <Servo.h>
#include <EEPROM.h>
#include <PS2X_lib.h>
#include "Servo_Driver.h"
#include "Move_Data.h"

#define A digitalRead(7)
#define B digitalRead(8)
#define C digitalRead(9)

//#define DEBUG

//Non group move servos
#define Servo_Pan_pin 13

Servo Pan;


//Servo Pin numbers
//Only servos that will be part
//of a group move are defined here
const byte Pins[NUMSERVOS] = {
  12,   //Left Hip pin
  11,   //Left Knee pin
  10,   //Left Ankle pin
  4,    //Right Hip pin
  3,    //Right Knee pin
  2     //Right Ankle pin
};

#define Speakerpin 5

#define LED_pin 13

//PS2 pins
#define DAT 6
#define ATT 8
#define CMD 7
#define CLK 9

//PS2 joystick Deadzone
#define Deadzone 5

PS2X ps2x;

void setup()
{
#ifdef DEBUG
  Serial.begin(115200);
#endif
  for(int i = 0; i < NUMSERVOS; i++)
  {
    Servos[i].pin = Pins[i];
    Servos[i].pos = 1500;
    Servos[i].delta = 0;
    Servos[i].target = 0;
    Servos[i].servo.attach(Servos[i].pin);
    Servos[i].Offset = (char)EEPROM.read(i);
    Servos[i].servo.writeMicroseconds(1500 + Servos[i].Offset);
  }
  Pan.attach(Servo_Pan_pin);
  
  
  pinMode(7, INPUT);
  pinMode(8, INPUT);
  pinMode(9, INPUT);
  if(!A)
    Config_Offsets();
  int error = ps2x.config_gamepad(CLK,CMD,ATT,DAT, true, true); //Configure PS2 Controller
  
#ifdef DEBUG
  if(error == 0)
    Serial.println("Found Controller, configured successful");
  else if(error == 1)
    Serial.println("No controller found");
  else if(error == 2)
    Serial.println("Controller found but not accepting commands.");
  else if(error == 3)
    Serial.println("Controller refusing to enter Pressures mode, may not support it. ");
#endif

  Init_Timer2(); //Set Timer2 to overflow every 16ms
  EnableTimer(); //Begin processing Interupts
}

void Config_Offsets()
{
  pinMode(LED_pin, OUTPUT);
  digitalWrite(LED_pin, HIGH);
  delay(2000);
  
  for(int s = 0; s < NUMSERVOS; s++)
  {
    Servos[s].servo.writeMicroseconds(1600);
    delay(100);
    Servos[s].servo.writeMicroseconds(1500);
    while(A)
    {
      if(!B && Servos[s].Offset > -100)
      {
        Servos[s].Offset -= 1;
        delay(10);
      } 
      else if(!C && Servos[s].Offset < 100)
      {
        Servos[s].Offset += 1;
        delay(10);
      }
      Servos[s].servo.writeMicroseconds(1500 + Servos[s].Offset);
    }
    EEPROM.write(s, Servos[s].Offset);
    delay(500);
  }
  digitalWrite(LED_pin, LOW);
}

void loop()
{
  ps2x.read_gamepad();  //Update the PS2 Controller
  
  int LSY = 128 - ps2x.Analog(PSS_LY);
  int LSX = ps2x.Analog(PSS_LX) - 128;
  int RSX = ps2x.Analog(PSS_RX);

  boolean Active = SeqHandler();  //Store the servo status and process any Active Sequences
  
  if((LSY > Deadzone || LSY < -Deadzone) && !Active)
    Walk((LSY > 0)? 20:-20, 1000 - abs(LSY)/128.0*1000 + 250); 
  else if((LSX > Deadzone || LSX < -Deadzone) && !Active)
    Turn((LSX > 0)? 30:-30, 250);
  else if(!Active)
    Pan.write(RSX/255.0*180);
  else if(ps2x.ButtonPressed(PSB_GREEN) && !Active)
    Head_Thrust();
  else if(ps2x.ButtonPressed(PSB_L1) && !Active)
    Kick_Left();
  else if(ps2x.ButtonPressed(PSB_R1) && !Active)
    Kick_Right();
  else if(ps2x.ButtonPressed(PSB_PAD_UP) && !Active)
    Get_Up_From_Front();
  else if(ps2x.ButtonPressed(PSB_PAD_DOWN) && !Active)
    Get_Up_From_Back();
  else if(ps2x.ButtonPressed(PSB_PAD_RIGHT) && !Active)
    Roll_Right();
  else if(ps2x.ButtonPressed(PSB_PAD_LEFT) && !Active)
    Roll_Left();
  
  delay(50);
}

