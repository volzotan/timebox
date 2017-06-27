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

struct CommunicationInterface ser0 = {&Serial, 0, "",0, -1};
struct CommunicationInterface ser1 = {&Serial1, 0, "",0, -1};

// ---------------------------

int state           = STATE_INIT;
int picturesTaken   = 0;

// ---------------------------

// OPTIONS

bool directMode     = false;         // zero or optocoupler?

int optInterval     =       2;       // CHANGE
int optIterations   =    1000;

long directBootWait = DEFAULT_DIRECT_BOOT_WAIT;
long directUptime   = DEFAULT_DIRECT_UPTIME;
long zeroBootWait   = DEFAULT_ZERO_BOOT_WAIT;
long zeroUptime     = DEFAULT_ZERO_UPTIME;

// ---------------------------

long zeroRealUptimeTimer  = -1;
long zeroShutdownTimer    = -1;

// ---------------------------

Adafruit_NeoPixel neopixel = Adafruit_NeoPixel(1, PIN_LED, NEO_GRB + NEO_KHZ800);

// ---------------------------

void setup() {

  Serial.begin(9600);
  Serial1.begin(9600);
 
  Serial.println("% INIT"); delay(200);

  ser0.inputBuffer = malloc(sizeof(char) * 100);
  ser1.inputBuffer = malloc(sizeof(char) * 100);

  initPins();
  initFromEEPROM();

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

  selftest(); delay(100);
  selftest(); delay(100);
 
}

void loop() {
    
  serialEvent();

  switch (state) {

    case STATE_INIT:

      // programming mode or continue and disable USB?
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
      state = STATE_ZERO_START;
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

        delay(100);
      }
    
      #ifdef DEBUG
        Serial.println("start sleeping");
        delay(100);
      #endif

      if (directMode) {
        wait((optInterval * 60) - directBootWait - directUptime);
        state = STATE_DIRECT_ON;
      } else {
        if (zeroRealUptimeTimer > 0) {
          wait((optInterval * 60) - zeroRealUptimeTimer);
        } else {
          wait((optInterval * 60) - zeroBootWait - zeroUptime);
        }
        state = STATE_ZERO_START;
      }
    break;  

    // ------------ DIRECT ------------

    case STATE_DIRECT_ON:
      switchCameraOn(true);
      wait(directBootWait);
      state = STATE_DIRECT_SHUTTER;
      break;
      
      
    case STATE_DIRECT_SHUTTER:
      digitalWrite(PIN_CAM1, HIGH);
      delay(100); // TODO: Focustime?
      digitalWrite(PIN_CAM2, HIGH);
      delay(100);
      wait(directUptime);
      state = STATE_DIRECT_OFF;
      break;
      

    case STATE_DIRECT_OFF:
      switchCameraOn(false);
      picturesTaken++;
      state = STATE_SLEEP;
      break;

    // ------------ ZERO ------------

    case STATE_ZERO_START:
      Serial.println("start zero"); delay(200);

      // start zero time measurement for correct interval times
      // start shutdown timer
      zeroRealUptimeTimer = millis();
      zeroShutdownTimer = millis() + (zeroBootWait + zeroUptime) * 1000;
      switchZeroOn(true);

      // wait zeroBootWait
      //setStateJump(STATE_ZERO_BOOTED, zeroBootWait);
      //state = STATE_IDLE;

      wait(zeroBootWait);
      state = STATE_ZERO_BOOTED;
    break;    

    case STATE_ZERO_BOOTED:
      switchCameraOn(true);
      state = STATE_ZERO_RUNNING;
    break;    

    case STATE_ZERO_RUNNING:
      // Timer hit? sleep some time? respond to some serial commands?
      if (millis() > zeroShutdownTimer) {
        state = STATE_ZERO_STOP;
      }
      break;

    case STATE_ZERO_STOP:
      switchZeroOn(false);
      zeroShutdownTimer = -1;
      zeroRealUptimeTimer = zeroRealUptimeTimer - millis();   
      
      switchCameraOn(false);
      
      picturesTaken++;

      Serial.println("stop zero"); delay(200);
    
      state = STATE_SLEEP;
    break;    

    // STOP

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
