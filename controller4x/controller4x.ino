#include <JeeLib.h>

#include <SPI.h>
#include <Wire.h>
#include <EEPROM.h>
#include <Adafruit_SSD1306.h>

#include "constants.h"

ISR(WDT_vect) {
  Sleepy::watchdogEvent();
}

//#define DEBUG

int state           = STATE_INIT;
int picturesTaken   = 0;

// ---------------------------

int optInterval     =       2;        // CHANGE
int optIterations   =    1000;
int zero_uptime     =      80;

// ---------------------------

void setup() {
  Serial.begin(9600);
  Serial1.begin(115200);

//  #ifdef DEBUG
//    while (!Serial) {
//       ;
//    }
//  #endif

  Serial.println("init"); delay(200);
  
  initPins();

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
}

void loop() {
  //serialEvent();

  switch (state) {

    case STATE_INIT:
      for(int i=0; i<300; i++) {
        if (digitalRead(PIN_PUSHBUTTON_CENTER) == 0) {
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
      digitalWrite(PIN_ZERO_EN, HIGH);
      wait(10);
      digitalWrite(PIN_CAMERA_EN, HIGH);
      wait(zero_uptime-10);
      digitalWrite(PIN_ZERO_EN, LOW);
      digitalWrite(PIN_CAMERA_EN, LOW);
      
      picturesTaken++;

      Serial.println("stop zero"); delay(200);

      state = STATE_SLEEP;
    break;    

    case STATE_STOP:
      wait(60);
    break;
  }
}

