#include <JeeLib.h>

#include <Wire.h>
#include <EEPROM.h>
#include <Adafruit_NeoPixel.h>

#include "global.h"
#include "constants.h"

ISR(WDT_vect) {
  Sleepy::watchdogEvent();
}

//#define DEBUG

// ---------------------------

struct CommunicationInterface ser0 = {&Serial, 0, "",0, 0};
struct CommunicationInterface ser1 = {&Serial1, 0, "",0, 0};

// ---------------------------

int state           = STATE_INIT;
int picturesTaken   = 0;

// ---------------------------

int optInterval     =       2;        // CHANGE
int optIterations   =    1000;
int zero_uptime     =      80;

// ---------------------------

Adafruit_NeoPixel neopixel = Adafruit_NeoPixel(1, PIN_LED, NEO_GRB + NEO_KHZ800);

// ---------------------------

void setup() {

  Serial.begin(9600);
  Serial1.begin(9600);
  //Serial1.begin(115200);
 
  Serial.println("% INIT"); delay(200);

  ser0.inputBuffer = malloc(sizeof(char) * 100);
  ser1.inputBuffer = malloc(sizeof(char) * 100);

  initPins();

  neopixel.begin();
  neopixel.setPixelColor(0, neopixel.Color(5,5,0));
  neopixel.show();
  
  while (!Serial) {
    ;
  }

  if (!checkBattHealth()) {
    // battery is empty, abort right now!
    
    Serial.println("stopping!...");
    #ifndef DEBUG
      state = STATE_STOP;
    #else
      Serial.println("stopping aborted (debug mode)");
    #endif
  }

//  delay(100);
//  Serial.println("start");
//  digitalWrite(PIN_ZERO_EN, HIGH);
//  delay(500);

  selftest();
  delay(100);
  selftest();
  delay(100);
//  selftest();
//  delay(100);
//  selftest();
//  delay(100);
//  selftest();
//  delay(100);
//  selftest();
//  delay(100);
//  selftest();
//  delay(100);
//  selftest();
//  delay(100);
//  selftest();
//  delay(100);
//  selftest();
//  delay(100);
//  selftest();
//  delay(100);
//  selftest();
//  delay(100);
//  selftest();
//  delay(100);
//  selftest();
//  delay(100);
//  selftest();
//  delay(100);
//  selftest();
//  delay(100);
//  selftest();
//  delay(100);
//  selftest();
//  delay(100);
//  selftest();
//  delay(100);

}

void loop() {
    
  serialEvent();

  return;

  switch (state) {

    case STATE_INIT:
      for(int i=0; i<300; i++) {
        if (digitalRead(PIN_BUTTON) == 0) {
          state = STATE_IDLE;
          Serial.println("idle"); delay(200);
          return;  
        } else {
          delay(10);  
        }
      }

      Serial.println("start"); delay(200);
      state = STATE_ZERO;
    break;  

    case STATE_IDLE:
      delay(1000);
      Serial.println("idle");
    break;  
    
    case STATE_SLEEP:

      if (!checkBattHealth()) {
        // battery is empty, abort right now!
        
        Serial.println("stopping!...");
        #ifndef DEBUG
          state = STATE_STOP;
        #else
          Serial.println("stopping aborted (debug mode)");
        #endif

        delay(200);
      }
    
      #ifdef DEBUG
        Serial.println("start sleeping");
        delay(200);
      #endif

      wait((optInterval * 60) - zero_uptime);
      state = STATE_ZERO;
    break;  

    case STATE_ZERO:
      Serial.println("start zero"); delay(200);
      
      switchZeroOn(true);
      
      wait(10);
      
      switchCameraOn(true);
      
      wait(zero_uptime-10);
      
      switchZeroOn(false);
      switchCameraOn(false);
      
      picturesTaken++;

      Serial.println("stop zero"); delay(200);

      state = STATE_SLEEP;
    break;    

    case STATE_STOP:
      wait(60);
    break;
  }
}

void selftest() {
  // assume all pins are initialized

  Serial.println("--- SELFTEST ---");
  
  // battery 
  Serial.print("BATT: ");
  Serial.print(analogRead(PIN_BATT_DIRECT));
  Serial.print(" | ");
  Serial.print(getLiPoVoltage(BATT_DIRECT));
  Serial.print("v | ");
  Serial.print(getLiPoVoltage(BATT_PERCENTAGE_DIRECT));
  Serial.println("%");
  
  // NeoPixel
  neopixel.setPixelColor(0, neopixel.Color(0,5,0));
  neopixel.show();

  // button state

  // zero uart
  Serial1.println("FOO");
    
}
