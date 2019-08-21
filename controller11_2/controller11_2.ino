#include <JeeLib.h>

#include <Wire.h>
#include <EEPROM.h>
#include <Adafruit_NeoPixel.h>

#include "global.h"
#include "constants.h"

ISR(WDT_vect) {
  Sleepy::watchdogEvent();
}

// #define DEBUG

#ifdef DEBUG
  #define DEBUG_PRINT(x) Serial.print("["); Serial.print(millis()/1000); Serial.print("] "); Serial.println (x)
#else
  #define DEBUG_PRINT(x)
#endif

// ---------------------------

struct CommunicationInterface ser0 = {&Serial,  0, "", 0, -1, -1};
struct CommunicationInterface ser1 = {&Serial1, 0, "", 0, -1, -1};

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
 
  DEBUG_PRINT("INIT");

  ser0.inputBuffer = malloc(sizeof(char) * 100);
  ser1.inputBuffer = malloc(sizeof(char) * 100);
  resetSerial(ser0);
  resetSerial(ser1);

  initPins();

  neopixel.begin();
  #ifdef DEBUG
    // blink YELLOW, 3x, 1s
    ledShow(50, 50, 0);
  #endif

  #ifdef DEBUG
    while (!Serial) {
      ;
    }
  #endif

  #ifdef DEBUG
    // blink YELLOW, 3x, 1s
    ledBlink(128, 128, 0, 3, 1000);
  #else
    // blink GREEN, 3x, 3s
    ledBlink(  0, 128, 0, 3, 3000);
  #endif

  // battery life
  if (!checkBattHealth()) {
    // battery is empty, abort right now!
    
    DEBUG_PRINT("stopping!...");
    #ifndef DEBUG
      stopAndShutdown();
    #else
      DEBUG_PRINT("stopping aborted (debug mode)");
    #endif
  }

  DEBUG_PRINT("Battery pin value:");
  DEBUG_PRINT(getLiPoVoltage(BATT_VD_RAW));
  DEBUG_PRINT("Battery voltage:");
  DEBUG_PRINT(getLiPoVoltage(BATT_DIRECT));
  DEBUG_PRINT("Battery percentage:");
  DEBUG_PRINT(getLiPoVoltage(BATT_PERCENTAGE_DIRECT));
}

void loop() {    
  serialEvent();  
  ledLoop();
}

void stopAndShutdown() {
  ledShow(0, 0, 0);
  switchZeroOn(false);

  while(true) {
    wait(1.0);
  }
}
