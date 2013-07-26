/* Shy Light Master 006
 by Michael B. LeBlanc
 NSCAD University
 March 11, 2011
 
 This version reverses the action of the servo.
 
 */

#include <x10.h>
#include <x10constants.h>

boolean switchPress = LOW; // initialize switch state

#define zcPin 2
#define dataPin 3
#define switchPin 4  // pin used to receive footswitch presses
#define commandPin 5 // pin used to send commands to servo slave unit
#define lightsensorPin 0

// set up a new x10 instance:
x10 myHouse =  x10(zcPin, dataPin);

void setup() {
  Serial.begin(9600);

  pinMode(zcPin,INPUT);
  pinMode(dataPin,OUTPUT);
  pinMode(commandPin, OUTPUT);
  pinMode(lightsensorPin, INPUT);

  myHouse.write(B, UNIT_1, 1); // initialize for unit 1, A block
  // send a "Lights OFF" command 3 times:
  myHouse.write(B, OFF,3);
  Serial.println("SETUP COMPLETE");
}

void basket() {
  myHouse.write(B, OFF, 3);
  Serial.println("Lights on:");
  myHouse.write(B, ON, 3);
  openBasket();
  timeOut();
  closeBasket();
  lightDim();
}

void openBasket() {
  Serial.println("Lights down slowly:");
  pulseServo();
  for (int i=1; i<=18; i++) 
  {
    myHouse.write(B, BRIGHT, 1);
    myHouse.write(B, BRIGHT, 1);
    delay(17);
  }
}

void timeOut() { 
  Serial.println("timeout starting");

  // wait 20 seconds or for switch to close
  // after 20 secs, automatically close the basket
  long currTime = millis();
  long delayTime = currTime + 20000;
  do { 
    // 20 second loop
    currTime = millis();
    switchPress = digitalRead(switchPin);
  } 
  while (switchPress == LOW && delayTime > currTime); // escape if switch closed
}

void closeBasket() 
{
  Serial.println("Lights up slowly:");
  pulseServo();
  for (int i=17; i>=0; i--) 
  {
    myHouse.write(B, DIM, 1);
    myHouse.write(B, DIM, 1);
    delay(17);
  }
}

void lightDim() {
  Serial.println("Lights off:");
  myHouse.write(B, DIM, 20);
}

void pulseServo(){
  digitalWrite(commandPin,HIGH); // send pulse to Servo Module
  delay(100);
  digitalWrite(commandPin,LOW);
}

// IT ALL HAPPENS HERE **************************************
void loop() {
  switchPress = digitalRead(switchPin);
  int light = analogRead(lightsensorPin);

  if (light > 700){
    Serial.print(light);
    Serial.println(": turning light off now.");
    myHouse.write(B, OFF, 3);    
  }
  // Wait for someone to press the footswitch
  if (switchPress == HIGH) {
    basket();
  }
}

