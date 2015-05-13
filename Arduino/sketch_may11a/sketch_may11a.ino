//#include <SoftwareSerial.h>

//#define rxPin 10
//#define txPin 11
//SoftwareSerial mySerial =  SoftwareSerial(rxPin, txPin);
/* Made By: Logan Crawfis

FSR to light LED --------------------------

*/ 
int sensorPin = A0; // select the input pin for the potentiometer 
int ledPin = 13; // select the pin for the LED
int sensorValue = 0; // variable to store the value coming from the sensor

void setup() { // declare the ledPin as an OUTPUT: 

pinMode(ledPin, OUTPUT);
Serial.begin(115200);
//pinMode(rxPin, INPUT);
//  pinMode(txPin, OUTPUT);
// mySerial.begin(115200);

}

void loop() { // read the value from the sensor: 
	sensorValue = analogRead(sensorPin);

        Serial.println(sensorValue);
//        mySerial.write("Hello");
        
        delay(10);
        
	if(sensorValue > 200){ 
	//if the value is greater than 1000 it will light the led 
	digitalWrite(ledPin, HIGH);//change the greater than to a less than for it to turn off when you push 
	} 
	else {
        digitalWrite(ledPin, LOW);
      } 
}
