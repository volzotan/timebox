#include <JeeLib.h>

#include <Wire.h>
#include <EEPROM.h>
#include <Adafruit_NeoPixel.h>

#include "global.h"
#include "constants.h"

ISR(WDT_vect) {
  Sleepy::watchdogEvent();
}

#define DEBUG

#ifdef DEBUG
  #define DEBUG_PRINT(x) Serial.print("["); Serial.print(millis()/1000); Serial.print("] "); Serial.println (x)
#else
  #define DEBUG_PRINT(x)
#endif

// ---------------------------

struct CommunicationInterface ser0 = {&Serial,  0, "", 0, -1, -1};
struct CommunicationInterface ser1 = {&Serial1, 0, "", 0, -1, -1};

// ---------------------------

int state           = STATE_INIT;
int picturesTaken   = 0;

// ---------------------------

// OPTIONS

int programMode     = MODE_DIRECT;     // zero or optocoupler?

int optInterval     =    -1;         
int optIterations   =    -1;

int directBootWait  = DEFAULT_DIRECT_BOOT_WAIT;
int directUptime    = DEFAULT_DIRECT_UPTIME;
int zeroBootWait    = DEFAULT_ZERO_BOOT_WAIT;
int zeroUptime      = DEFAULT_ZERO_UPTIME;

// ---------------------------

long zeroRealUptimeTimer  = -1;
long zeroShutdownTimer    = -1;

// ---------------------------

Adafruit_NeoPixel neopixel  = Adafruit_NeoPixel(1, PIN_LED, NEO_GRB + NEO_KHZ800);
int ledColor[]              = {0, 0, 0};
long ledDuration            = -1;
long ledTimer               = -1;
long ledIterations          = -1;
boolean ledOn               = false;

// ---------------------------

void setup() {

  Serial.begin(9600);
  Serial1.begin(9600);

  #ifdef DEBUG
    while (!Serial) {
      ;
    }
  #endif
 
  DEBUG_PRINT("INIT");

  ser0.inputBuffer = malloc(sizeof(char) * 100);
  ser1.inputBuffer = malloc(sizeof(char) * 100);
  resetSerial(ser0);
  resetSerial(ser1);

  // init values
  initPins();
  int error = initFromEEPROM();
  if (error > 0) {
    DEBUG_PRINT("eeprom empty. resetting values...");
    eeprom_reset();
    initFromEEPROM();
  }
  #ifdef DEBUG
    initPrint(ser0);
  #endif;

  // neopixel
  neopixel.begin();
  #ifdef DEBUG
    ledBlink(128, 128, 0, 3, 1000);
  #else
    ledBlink(  0, 128, 0, 3, 3000);
  #endif

  // battery life
  if (!checkBattHealth()) {
    // battery is empty, abort right now!
    
    DEBUG_PRINT("stopping!...");
    #ifndef DEBUG
      state = STATE_STOP;
    #else
      Serial.println("stopping aborted (debug mode)");
    #endif
  }

  DEBUG_PRINT(getLiPoVoltage(BATT_DIRECT));

//  selftest(); delay(100); 
//  selftest(); delay(100); 
//  selftest(); delay(100); 
//  selftest(); delay(100); 
//  selftest(); delay(100); 
//  selftest(); delay(100); 
//  selftest(); delay(100); 
//  selftest(); delay(100); 
//  selftest(); delay(100); 

  state = STATE_IDLE;

        digitalWrite(PIN_CAM1, HIGH);
      delay(500); // TODO: Focustime?
      digitalWrite(PIN_CAM2, HIGH);
      delay(500);
      digitalWrite(PIN_CAM1, LOW);
      delay(500); 
      digitalWrite(PIN_CAM2, LOW);
      delay(500);
              digitalWrite(PIN_CAM1, HIGH);
      delay(500); // TODO: Focustime?
      digitalWrite(PIN_CAM2, HIGH);
      delay(500);
      digitalWrite(PIN_CAM1, LOW);
      delay(500); 
      digitalWrite(PIN_CAM2, LOW);
      delay(500);
}

void loop() {

//  switchZeroOn(true);
//  while(1);
    
  serialEvent();  
  ledLoop();
 
  switch (state) {

    case STATE_INIT:

      // programming mode or continue and disable USB?
      for(int i=0; i<10; i++) {
        if (digitalRead(PIN_BUTTON) == 1) {
          state = STATE_IDLE;
          
          DEBUG_PRINT("--> idle");

          ledShow(0, 0, 100);

          return;  
        } else {
          delay(100);  
        }
      }
      
      DEBUG_PRINT("start");

      if (programMode == MODE_DIRECT) {
        state = STATE_DIRECT_ON;
      } else if (programMode == MODE_ZERO) {
        state = STATE_ZERO_START;
      }
    break;  
    

    case STATE_IDLE:
      DEBUG_PRINT("idle");
      #ifdef DEBUG
        delay(1000);
      #endif
    break;  
    
    
    case STATE_SLEEP:

      if (!checkBattHealth()) {
        // battery is empty, abort right now!
        
        DEBUG_PRINT("stopping!...");
        #ifndef DEBUG
          state = STATE_STOP;
        #endif
        
        DEBUG_PRINT("stopping aborted (debug mode)");

        delay(100);
      }
    
      DEBUG_PRINT("start sleeping");

      if (programMode == MODE_DIRECT) {
        wait(optInterval - directBootWait - directUptime);
        state = STATE_DIRECT_ON;
      } else if (programMode == MODE_ZERO) {
        if (zeroRealUptimeTimer > 0) {
          wait(optInterval - zeroRealUptimeTimer);
        } else {
          wait(optInterval - zeroBootWait - zeroUptime);
        }
        state = STATE_ZERO_START;
      }
    break;  

    // ------------ DIRECT ------------

    case STATE_DIRECT_ON:
      DEBUG_PRINT("direct camera on");
      switchCameraOn(true);
      wait(directBootWait);
      state = STATE_DIRECT_SHUTTER;
      break;
      
      
    case STATE_DIRECT_SHUTTER:
      DEBUG_PRINT("direct release shutter");
      digitalWrite(PIN_CAM1, HIGH);
      delay(100); // TODO: Focustime?
      digitalWrite(PIN_CAM2, HIGH);
      delay(100);
      digitalWrite(PIN_CAM1, LOW);
      delay(100); 
      digitalWrite(PIN_CAM2, LOW);
      delay(100);
      wait(directUptime);
      state = STATE_DIRECT_OFF;
      break;
      

    case STATE_DIRECT_OFF:
      DEBUG_PRINT("direct camera off");
      switchCameraOn(false);
      picturesTaken++;
      state = STATE_SLEEP;
      break;

    // ------------ ZERO ------------

    case STATE_ZERO_START:
      DEBUG_PRINT("zero start");

      // start zero time measurement for correct interval times
      // start shutdown timer
      zeroRealUptimeTimer = millis();
      zeroShutdownTimer = millis() + (zeroBootWait + zeroUptime) * 1000L;
      switchZeroOn(true);
      
      wait(zeroBootWait);
      state = STATE_ZERO_BOOTED;
    break;    

    case STATE_ZERO_BOOTED:
      DEBUG_PRINT("zero booted");
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
      DEBUG_PRINT("zero stop");
      switchZeroOn(false);
      zeroShutdownTimer = -1;
      zeroRealUptimeTimer = zeroRealUptimeTimer - millis();   
      
      switchCameraOn(false);
      picturesTaken++;
    
      state = STATE_SLEEP;
    break;    

    // STOP

    case STATE_STOP:
      DEBUG_PRINT("stop");
      #ifdef DEBUG
        delay(1000);
      #endif
      
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
  neopixel.setPixelColor(0, neopixel.Color(0,100,0));
  neopixel.show();

  // button state

  // zero uart
  // Serial1.println("FOO");
    
}
