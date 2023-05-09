#include <SPI.h>
#include <SD.h>
#include <SoftwareSerial.h>


SoftwareSerial gps(2, 3); // RX, TX

File myFile;

const int chipSelect = 10;
bool isVerbose = true;
const int nChars = 500;
char gps_string[nChars];


int tempPin1 = 0;
int tempPin2 = 6;
int presPin = 5;
int humPin = 7;
    int xPin = 4;
    int yPin = 3;
    int zPin = 2;
    int uvPin=1;


void clear_gps_string() {
  for (int i = 0; i < nChars ; i++) {
    gps_string[i] = '\0';
  }
  

}

void read_gps() {

  char t;

  // If we arrive in the middle of a gps_available
  // wait for that to go away:
  while (gps.available()) {
    t = gps.read(); // do nothing
    delay(1);
    
  }
  // ok, now wait until the gps is available again:
  while (!gps.available()) {
    delay(1); // do nothing
  }

  // now read in the GPS data:
  int iChar = 0;
  while (gps.available()) {
    gps_string[iChar] = gps.read();
    iChar++;
    delay(1);
  }
}


void setup()
{
  // Open serial communications and wait for port to open:
  Serial.begin(9600);
  gps.begin(9600);
  while (!gps) {
    delay(2); // wait
  }

  gps.listen();
  if (isVerbose) Serial.println("GPS is initialized!");  
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }


  Serial.print("Initializing SD card...");
  
  if (!SD.begin()) {
    Serial.println("initialization failed!");
    return;
  }
  Serial.println("initialization done.");

  // open the file. note that only one file can be open at a time,
  // so you have to close this one before opening another.
  myFile = SD.open("all.txt", FILE_WRITE);
  delay(10);

  // if the file opened okay, write to it:
  if (myFile) {
    Serial.println("Writing to data file...");
    myFile.println("testing header");
   
  } else {
    // if the file didn't open, print an error:
    Serial.println("error opening data file");
  }



  delay(100);
  
}

void loop()
{
    double temp1 = analogRead(tempPin1);
    double temp2 = analogRead(tempPin2);
    double pressure = analogRead(presPin);
    double humidity = analogRead(humPin);

    double xAccelorometer = analogRead(xPin);
    double yAccelorometer = analogRead(yPin);
    double zAcceloromter = analogRead(zPin);
  

    unsigned long time = millis();

    myFile.print("DATA: ,");
    myFile.print(temp1);
    myFile.print(",");


    myFile.print(" ");
    myFile.print(temp2);
    myFile.print(",");

    myFile.print(" ");
    myFile.print(pressure);
    myFile.print(",");
    
    myFile.print(" ");
    myFile.print(humidity);
    myFile.print(",");

    myFile.print(" ");
    myFile.print(xAccelorometer);
    myFile.print(",");

    myFile.print(" ");
    myFile.print(yAccelorometer);
    myFile.print(",");

    myFile.print(" ");
    myFile.print(zAcceloromter);
    myFile.print(",");

    myFile.println(time);

   //delay(200);

   myFile.println("@,");
   
   clear_gps_string(); 
   read_gps();
   if (isVerbose) myFile.println(gps_string);
   
   delay(200);
    
   myFile.println("@");
   myFile.flush();

    delay(20);
 
}
