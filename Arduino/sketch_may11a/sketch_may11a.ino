//#include <SoftwareSerial.h>

//#define rxPin 10
//#define txPin 11
//SoftwareSerial mySerial =  SoftwareSerial(rxPin, txPin);
/* Made By: Logan Crawfis

FSR to light LED --------------------------

*/ 
int sensorPinUpLeft = A0; // select the input pin for the potentiometer 
int sensorPinDownLeft = A1;
int sensorPinUpRight = A2;
int sensorPinDownRight = A3;
int ledPin = 13; // select the pin for the LED
int sensorValue0 = 0;
int sensorValue1 = 0;
int sensorValue2 = 0;
int sensorValue3 = 0;

void setup() { // declare the ledPin as an OUTPUT: 

pinMode(ledPin, OUTPUT);
Serial.begin(115200);
//pinMode(rxPin, INPUT);
//  pinMode(txPin, OUTPUT);
// mySerial.begin(115200);

}

void loop() { // read the value from the sensor: 
	sensorValue0 = analogRead(sensorPinUpLeft);
	sensorValue1 = analogRead(sensorPinDownLeft);
	sensorValue2 = analogRead(sensorPinUpRight);
	sensorValue3 = analogRead(sensorPinDownRight);

	float SumValue = (sensorValue0 + sensorValue1 + sensorValue2 + sensorValue3);
    float AvgValue = SumValue/4;
//    Serial.print(sensorValue0);
//    Serial.print("/");
//    Serial.print(sensorValue1);
//    Serial.print("/");
//    Serial.print(sensorValue2);
//    Serial.print("/");
//    Serial.print(sensorValue3);
//    Serial.println("");
      Serial.println(AvgValue);

//        mySerial.write("Hello");
        
    delay(150);
        
	if(AvgValue > 200){ 
	//if the value is greater than 1000 it will light the led 
	digitalWrite(ledPin, HIGH);//change the greater than to a less than for it to turn off when you push 
	} 
	else {
        digitalWrite(ledPin, LOW);
      } 
}
