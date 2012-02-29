//arduino solar panel code
#include <EEPROM.h>

// Date and time functions using a DS1307 RTC connected via I2C and Wire lib

#include <Wire.h>
#include "RTClib.h"
#include <SD.h>

const int chipSelect = 8;
const int LOCATION_FILE_NUMBER_LSB = 0x00;
const int LOCATION_FILE_NUMBER_MSB = 0x01;

RTC_DS1307 RTC;
File dataFile;

void setup () {
 // initialize serial communications:
 Serial.begin(9600);

 // set up pins A2 and A3 as the power and ground for the real time clock:
 pinMode(A2, OUTPUT);
 pinMode(A3, OUTPUT);
 // A2 is the ground, A3 is the power:
 digitalWrite(A2, LOW);
 digitalWrite(A3, HIGH);

 Serial.print("Initializing SD card...");
 // make sure that the default chip select pin is set to
 // output, even if you don't use it:
 pinMode(10, OUTPUT);

 // see if the card is present and can be initialized:
 if (!SD.begin(chipSelect)) {
   Serial.println("Card failed, or not present");
   // don't do anything more:
   return;
 }
 Serial.println("card initialized.");



 // start the wire and RTC libraries:
 Wire.begin();
 RTC.begin();

 if (! RTC.isrunning()) {
   Serial.println("RTC is NOT running!");
   // following line sets the RTC to the date & time this sketch was compiled
   RTC.adjust(DateTime(__DATE__, __TIME__));
 }

 Serial.println("RTC is set");

 newlog();

}

void loop () {


 // if the file is available, write to it:
 if (dataFile) {
   DateTime now = RTC.now();

   dataFile.print(now.month(), DEC);
   dataFile.print('/');
   dataFile.print(now.day(), DEC);
   dataFile.print('/');
   dataFile.print(now.year(), DEC);
   dataFile.print(',');
   dataFile.print(now.hour(), DEC);
   dataFile.print(':');
   dataFile.print(now.minute(), DEC);
   dataFile.print(':');
   dataFile.print(now.second(), DEC);
   dataFile.print(",");
   // calculate the voltage on A1:
   float voltage = 5 * analogRead(A0) / 1024.0;
   dataFile.print(voltage);
   dataFile.println();

   dataFile.flush();
 }
 // delay for a minute:
 delay(60000);
 // delay for three seconds:
 //delay(3000);
}

void newlog(void)
{
 uint8_t msb, lsb;
 uint16_t new_file_number;

 //Combine two 8-bit EEPROM spots into one 16-bit number
 lsb = EEPROM.read(LOCATION_FILE_NUMBER_LSB);
 msb = EEPROM.read(LOCATION_FILE_NUMBER_MSB);
 new_file_number = msb;
 new_file_number = new_file_number << 8;
 new_file_number |= lsb;

 //If both EEPROM spots are 255 (0xFF), that means they are un-initialized (first time OpenLog has been turned on)
 //Let's init them both to 0
 if((lsb == 255) && (msb == 255))
 {
   new_file_number = 0; //By default, unit will start at file number zero
   EEPROM.write(LOCATION_FILE_NUMBER_LSB, 0x00);
   EEPROM.write(LOCATION_FILE_NUMBER_MSB, 0x00);
 }

 //The above code looks like it will forever loop if we ever create 65535 logs
 //Let's quit if we ever get to 65534
 //65534 logs is quite possible if you have a system with lots of power on/off cycles
 if(new_file_number == 65534)
 {
   //Gracefully drop out to command prompt with some error
   PgmPrint("!Too many logs:1!");
   return; //Bail!
 }

 //If we made it this far, everything looks good - let's start testing to see if our file number is the next available

 //Search for next available log spot
 char fileName[] = "LOG00000.TXT";
 while(1)
 {
   new_file_number++;
   if(new_file_number > 65533) //There is a max of 65534 logs
   {
     PgmPrint("!Too many logs:2!");
     return;
   }

   sprintf(fileName, "LOG%05d.TXT", new_file_number); //Splice the new file number into this file name

   //Try to open file, if fail (file doesn't exist), then break
   if (!SD.exists(fileName)) break;
 }
Serial.print(fileName);

 //Record new_file number to EEPROM
 lsb = (uint8_t)(new_file_number & 0x00FF);
 msb = (uint8_t)((new_file_number & 0xFF00) >> 8);

 EEPROM.write(LOCATION_FILE_NUMBER_LSB, lsb); // LSB

 if (EEPROM.read(LOCATION_FILE_NUMBER_MSB) != msb)
   EEPROM.write(LOCATION_FILE_NUMBER_MSB, msb); // MSB


  // open the file. note that only one file can be open at a time,
 // so you have to close this one before opening another.
 dataFile = SD.open(fileName, FILE_WRITE);
}



