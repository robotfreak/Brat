//This file handles the Timer interupt and positioning the servos.

#include <Arduino.h>
#define NUMSERVOS 6
#define period 16

boolean Moving = false; //Servo status flag
long ticks; //Number of updates in a move

const long TscaleFactor = 100;   //Fixed point Scale Factor for Time Variable
const long DscaleFactor = 1000;  //Fixed point Scale Factor for displacement

//Define a structure to hold all data for each servo
struct ServoItem
{
  Servo servo;
  int pos;
  int delta;
  int target;
  byte pin;
  char Offset;
} Servos[NUMSERVOS];

//Define a structure to store multistep sequences.
struct Command 
{
  int Steps;
  int StepCount; //must be set to -1
  int Seq[10][NUMSERVOS + 1];
} Current_Command;

//Timer 2 Initialization
void Init_Timer2()
{
  #if defined(__AVR_ATmega168__) || defined(__AVR_ATmega328P__) || defined(__AVR_ATmega1280__)
    TCCR2A = (1 << WGM21);              // CTC
    TCCR2B = (1 << CS22) | (1 << CS21) | (1 << CS20); // set to clock /1024
    OCR2A = 249;                        // overflow every 16ms
#else
    // Use normal mode
    TCCR2 = (1 << WGM21);               // CTC
    TCCR2 |= (1 << CS22) | (1 << CS21) | (1 << CS20); // set prescaler to 125kHz
    OCR2 = 249;                         // so overflow every 16ms
#endif
    TCNT2 = 0;
}

//Enables Timer 2 Interupts
void EnableTimer()
{
#if defined(__AVR_ATmega168__) || defined(__AVR_ATmega328P__) || defined(__AVR_ATmega1280__)
    TIMSK2 |= 1 << OCIE2A;
#else
    TIMSK |= 1 << OCIE2;
#endif
}

//Timer 2 Overflow ISR
#if defined(__AVR_ATmega168__) || defined(__AVR_ATmega328P__) || defined(__AVR_ATmega1280__)
ISR(TIMER2_COMPA_vect)
#else
ISR(TIMER2_COMP_vect)
#endif
{
  if(!Moving)
    return;
    
  if(ticks > 0)
  {
    for(int i = 0; i < NUMSERVOS; i++)
    {
      Servos[i].pos += Servos[i].delta;
      Servos[i].servo.writeMicroseconds(Servos[i].pos);
    }
    ticks -= TscaleFactor;
  }
  else
  {
    for(int i = 0; i < NUMSERVOS; i++)
    {
      Servos[i].pos = Servos[i].target;
      Servos[i].delta = 0;
      Servos[i].target = 0;
      Servos[i].servo.writeMicroseconds(Servos[i].pos);
    }
    Moving = false;
  }
}

//Preps the servos to begin a Group Move
void Start_GM(int pos[NUMSERVOS + 1])
{
  ticks = (pos[NUMSERVOS] * TscaleFactor) / period ;
  for(int i = 0; i < NUMSERVOS; i++)
  {
    Servos[i].target = map(pos[i], 0, 180, 500, 2500) + Servos[i].Offset;
    Servos[i].delta = (((Servos[i].target - Servos[i].pos) * DscaleFactor) / ticks) / (DscaleFactor / TscaleFactor);
  }
}

//Simply puts a move into action
void Commit_GM()
{
  Moving = true;
}

//Processes pending Sequence Moves.
boolean SeqHandler()
{
  if(Moving)
    return true;
  if(Current_Command.Steps == 0)
    return false;
    
  Current_Command.StepCount++;
  if(Current_Command.StepCount < Current_Command.Steps)
  {
    Start_GM(Current_Command.Seq[Current_Command.StepCount]);
    Commit_GM();
    return true;
  }
  else
  {
    Current_Command.Steps = 0;
    return false;
  }
}

//Sets the Current Command
void Set_Current_Command(Command new_Command)
{
  Current_Command = new_Command;
}


