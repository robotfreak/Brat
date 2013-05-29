#include <Servo.h>
#include <EEPROM.h>
#include <SoftwareSerial.h>
#include "Servo_Driver.h"
#include "Move_Data.h"
#include "DIY.h"

#define A digitalRead(7)
#define B digitalRead(8)
#define C digitalRead(9)

#define Deadzone 50

//Servo Pin numbers
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

void setup()
{
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
  
  pinMode(7, INPUT);
  pinMode(8, INPUT);
  pinMode(9, INPUT);
  if(!A)
    Config_Offsets();
  
  Xbee.begin(38400);

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
  imReady = !SeqHandler();  //Store the servo status and process any Active Sequences
  maintainConnection();
  
  if(isConnected && isReady && imReady)
  {
    SendCommand(XBEE_REQ_DATA);
  }
  if(newValues && imReady)
  {
    if((LSY > 512 + Deadzone || LSY < 512 - Deadzone))
      Walk((LSY > 512)? 20:-20, 1000 - abs(LSY - 512)/512.0*250);
    else if((LSX > 512 + Deadzone || LSX < 512 - Deadzone))
      Turn((LSX > 512)? 30:-30, 250);
    else if(Key == 'A')
      Head_Thrust();
    else if(Key == '1')
      Kick_Left();
    else if(Key == '3')
      Kick_Right();
    else if(Key == '2')
      Get_Up_From_Front();
    else if(Key == '8')
      Get_Up_From_Back();
    else if(Key == '4')
      Roll_Right();
    else if(Key == '6')
      Roll_Left();
   
    newValues = false;
  }
  delay(50);
}

