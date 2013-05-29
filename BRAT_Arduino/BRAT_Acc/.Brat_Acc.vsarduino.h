#define __AVR_ATmega328P__
#define __cplusplus
#define __builtin_va_list int
#define __attribute__(x)
#define __inline__
#define __asm__(x)
#define ARDUINO 100
extern "C" void __cxa_pure_virtual() {}
#include "C:\Users\Flowstone\Documents\Dropbox\Work\Arduino sketches\arduino-1.0\libraries\EEPROM\EEPROM.h"
#include "C:\Users\Flowstone\Documents\Dropbox\Work\Arduino sketches\arduino-1.0\libraries\Servo\Servo.h"
#include "C:\Users\Flowstone\Documents\Dropbox\Work\Arduino sketches\arduino-1.0\libraries\EEPROM\EEPROM.cpp"
#include "C:\Users\Flowstone\Documents\Dropbox\Work\Arduino sketches\arduino-1.0\libraries\Servo\Servo.cpp"
void setup();
void Load_Offsets();
void Config_Offsets();
int read_Acc();
void loop();

#include "C:\Users\Flowstone\Documents\Dropbox\Work\Arduino sketches\arduino-1.0\hardware\arduino\variants\standard\pins_arduino.h" 
#include "C:\Users\Flowstone\Documents\Dropbox\Work\Arduino sketches\arduino-1.0\hardware\arduino\cores\arduino\Arduino.h"
#include "C:\Users\Flowstone\Documents\Dropbox\Work\Arduino sketches\Brat Stuff\Brat_Acc\Brat_Acc.ino" 
