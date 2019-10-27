#include <Wire.h>
#include <Adafruit_NeoPixel.h>
#include "Adafruit_MCP9808.h"

#include "global.h"
#include "constants.h"

// #define DEBUG
// #define SHUTDOWN_ON_LOW_BATTERY
#define HOST_DEFAULT_POWERED_ON 1

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

Adafruit_MCP9808 tempsensor = Adafruit_MCP9808();

// ---------------------------

void setup() {

  SerialUSB.begin(9600);
  resetSerial();

  DEBUG_PRINT("INIT");

  initPins();

  neopixel.begin();

  #ifdef DEBUG
    // blink YELLOW, 3x, 1s
    ledShow(50, 50, 0);
  #endif

  #ifdef DEBUG
    while (!SerialUSB) {;}

    DEBUG_PRINT("DEBUG MODE ON");
  #endif

  // set the resolution mode of reading
  // Mode  Resolution  SampleTime
  //  0    0.5°C       30 ms
  //  1    0.25°C      65 ms
  //  2    0.125°C     130 ms
  //  3    0.0625°C    250 ms

  if (!tempsensor.begin(0x18)) {
    DEBUG_PRINT("temperature sensor not found");
  }
  tempsensor.setResolution(1); 

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

  #ifdef DEBUG
    DEBUG_PRINT("Battery pin value:");
    analogRead(PIN_BATT_DIRECT);
    delay(100);
    DEBUG_PRINT(analogRead(PIN_BATT_DIRECT));
    DEBUG_PRINT("Battery voltage:");
    DEBUG_PRINT(getBatteryVoltage());
    DEBUG_PRINT("Battery percentage:");
    DEBUG_PRINT(getBatteryPercentage());
  #endif

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
