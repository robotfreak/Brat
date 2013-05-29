#include <Arduino.h>

#define Xbee Serial

#define XBEE_REQ_DATA 0x01
#define XBEE_READY 0x02
#define XBEE_NREADY 0x03
#define XBEE_DATA 0x04
#define XBEE_PING 0x05

byte RSSI;  //Signal Strength
word Length;  //Packet Length
byte Opt;  //Packet Options
byte APIdent;  //Packet AP Identifier
word Source;  //Address of connected robot
byte connectionStatus = 0;
byte Status;  //Modem status
byte Chksum;  //Packet Chksum
byte packetData[100];  //The latest packet data from robot

word LSY;
word LSX;
word LSP;
word RSY;
word RSX;
word RSP;
word LS;
word MS;
word RS;
byte Key;

void SendPacket(byte type, byte* data, word length, word dest = 0x0002)
{
  byte packet[10 + length];
  packet[0] = 0x7E;  //Start Delimiter
  packet[1] = (length + 6) >> 8;  //Length MSB
  packet[2] = (length + 6);  //Length LSB
  packet[3] = 0x01;  //API Id
  packet[4] = 0x01;  //Frame ID
  packet[5] = dest >> 8;  //Destination Address MSB
  packet[6] = dest;  //Destination Address LSB
  packet[7] = 0x00;  //Options
  packet[8] = type;
  for(int i = 0; i < length ; i++)
    packet[i + 9] = data[i];
  
  byte Checksum = 0xFF;
  
  for(int i = 3; i < 9 + length; i++)
    Checksum -= packet[i];
  
  packet[9 + length] = Checksum;
  
  Xbee.write(packet, 10 + length); 
}

void SendCommand(byte command, word dest = 0x0000)
{
  byte packet[10] = {0x7E, 0x00, 0x06, 0x01, 0x01, (dest >> 8), dest, 0x00, command, 0xFD - (dest >> 8) - (dest & 0x0F) - command};
  Xbee.write(packet, 10);
}

void ReadInPacket()
{
  Xbee.read();
  Length = Xbee.read() << 8;
  Length |= Xbee.read();
  APIdent = Xbee.read();
  switch(APIdent)
  {
    case 0x81: //Recieve
    {
      Source = Xbee.read() << 8;
      Source |= Xbee.read();
      RSSI = Xbee.read();
      Opt = Xbee.read();
      int i;
      int x;
      if(Xbee.peek() == XBEE_PING)
      {
        for(x = Length; x > 0; x--)
          Xbee.read();
      }
      else
      {
        for(i = 0, x = Length; x > 0; x--, i++)
          packetData[i] = Xbee.read();
        connectionStatus |= 8;
      }
      Chksum = Xbee.read();
      break;
    }
    case 0x8A: //Modem Status
    {
      Status = Xbee.read();
      Chksum = Xbee.read();
      break;
    }
    case 0x89: //Ack
    {
      Xbee.read();
      if(Xbee.read())
        connectionStatus = 0;
      else
        connectionStatus |= 1;
      Chksum = Xbee.read();
    }
  }
}

void maintainConnection()
{
  switch(connectionStatus & 7)
  {
    case 0:
      SendCommand(XBEE_PING, 0x0000);
      break;
    case 1: //Connected. Just wait for ready from TX
      break;
    case 3: //Connected, TX Ready
      SendCommand(XBEE_READY, 0x0000);
      connectionStatus |= 4;
      break;
    case 7:
    

  }
  else if(isConnected && !imReady)
  {
    SendCommand(XBEE_READY, 0x0000);
    imReady = true;
  }
  else if(isConnected && imReady && isReady)
  {
    //Check for packets
    if(Xbee.available())
    {
      if(Xbee.peek() == 0x7E)
        ReadInPacket();
      else
        while(Xbee.available())
          Xbee.read();
    }
    //Process new data
    if(newData)
    {
      switch(packetData[0])
      {
        case XBEE_READY:
          isReady = true;
          break;
        case XBEE_NREADY:
          isReady = false;
          break;
        case XBEE_DATA:
          LSY = (packetData[1] << 2) | (packetData[2] >> 6);
          LSX = ((packetData[2] & 0x3F) << 4) | (packetData[3] >> 4);
          LSP = ((packetData[3] & 0x0F) << 6) | (packetData[4] >> 2);
          RSY = ((packetData[4] & 0x03) << 8) | (packetData[5]);
          RSX = (packetData[6] << 2) | (packetData[7] >> 6);
          RSP = ((packetData[7] & 0x3F) << 4) | (packetData[8] >> 4);
          LS  = ((packetData[8] & 0x0F) << 6) | (packetData[9] >> 2);
          MS  = ((packetData[9] & 0x03) << 8) | (packetData[10]);
          RS  = (packetData[11] << 2) | (packetData[12] >> 6);
          Key = packetData[13];
          newValues = true;
          break;
        case XBEE_REQ_DATA:
          //TODO
          break;
      }
      newData = false;
    }
  }
}
