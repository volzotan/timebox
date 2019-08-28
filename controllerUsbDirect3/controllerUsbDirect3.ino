#include <Wire.h>
#include <Adafruit_NeoPixel.h>

#include "global.h"
#include "constants.h"

// #define DEBUG
// #define SHUTDOWN_ON_LOW_BATTERY

#ifdef DEBUG
  #define DEBUG_PRINT(x) SerialUSB.print("["); SerialUSB.print(millis()/1000); SerialUSB.print("] "); SerialUSB.println (x)
#else
  #define DEBUG_PRINT(x)
#endif

// ---------------------------

Adafruit_NeoPixel neopixel  = Adafruit_NeoPixel(1, PIN_LED, NEO_GRB + NEO_KHZ800);
int ledColor[]              = {0, 0, 0};
long ledDuration            = -1;
long ledTimer               = -1;
long ledIterations          = -1;
boolean ledOn               = false;

// ---------------------------

char *inputBuffer = (char*) malloc(sizeof(char) * 100);
String serialInputString = "";
char serialCommand = 0;
int serialParam = -1;
int serialParam2 = -1;

// ---------------------------

void setup() {

  SerialUSB.begin(9600);

  DEBUG_PRINT("INIT");

  initPins();
  neopixel.begin();

  #ifdef DEBUG
    // blink YELLOW, 3x, 1s
    ledShow(50, 50, 0);
  #endif

  #ifdef DEBUG
    while (!SerialUSB) {
      ;
    }

    DEBUG_PRINT("DEBUG MODE ON");
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
    #ifdef SHUTDOWN_ON_LOW_BATTERY
      stopAndShutdown();
    #else
      DEBUG_PRINT("stopping aborted (no SHUTDOWN_ON_LOW_BATTERY)");
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
  // switchZeroOn(false);

  while(true) {
    wait(1.0);
  }
}
