#include <JeeLib.h>
#include <Adafruit_NeoPixel.h>
#include "constants.h"

ISR(WDT_vect) {
  Sleepy::watchdogEvent();
}

// --------- CONFIG ----------

// #define DEBUG
// #define DEEP_SLEEP
// #define PERSISTENT_CAMERA

// ---------------------------

#define DEBUG_PRINT(x) Serial.print("["); Serial.print(millis()/1000); Serial.print("] "); Serial.println (x)

Adafruit_NeoPixel neopixel  = Adafruit_NeoPixel(1, PIN_LED, NEO_GRB + NEO_KHZ800);

int picturesTaken = 0;

// ---------------------------

void setup() {

  Serial.begin(9600);
 
  DEBUG_PRINT("INIT");

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

  #ifdef PERSISTENT_CAMERA
    // blink YELLOW, 3x
    ledShow( 64,  64, 0);
    delay(1000);
    ledShow(  0, 0  , 0);
    delay(500);
    ledShow( 64,  64, 0);
    delay(1000);
    ledShow(  0,   0, 0);
    delay(500);
    ledShow( 64,  64, 0);
    delay(1000);
    ledShow(  0,   0, 0);
  #else
    // blink GREEN, 3x
    ledShow(  0, 128, 0);
    delay(1000);
    ledShow(  0, 0  , 0);
    delay(500);
    ledShow(  0, 128, 0);
    delay(1000);
    ledShow(  0,   0, 0);
    delay(500);
    ledShow(  0, 128, 0);
    delay(1000);
    ledShow(  0,   0, 0);
  #endif

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

  #ifdef PERSISTENT_CAMERA
    DEBUG_PRINT("start persistent camera");
    ledShow(0, 0, 128);
    delay(100);
    switchCameraOn(true);
    delay(900);
    ledShow(0, 0, 0);
    wait(PRE_TRIGGER_WAIT);
  #endif

  DEBUG_PRINT("start loop");
}

void loop() {    

  if (!checkBattHealth()) {    
    DEBUG_PRINT("low batt! stopping!...");
    stopAndShutdown();
  }

  if (picturesTaken > ITERATIONS) {
    DEBUG_PRINT("max iterations reached! stopping!...");
    stopAndShutdown();
  }

  #ifndef PERSISTENT_CAMERA:
    DEBUG_PRINT("pre trigger wait");

    ledShow(0, 0, 128);
    delay(100);
    switchCameraOn(true);
    delay(900);
    ledShow(0, 0, 0);

    wait(PRE_TRIGGER_WAIT); 
  #endif

  DEBUG_PRINT("trigger camera");
  digitalWrite(PIN_CAM_FOCUS, HIGH);
  delay(100);
  
  digitalWrite(PIN_CAM_SHUTTER, HIGH);
  wait(TRIGGER_DURATION);
  
  digitalWrite(PIN_CAM_SHUTTER, LOW);
  digitalWrite(PIN_CAM_FOCUS, LOW);

  #ifndef PERSISTENT_CAMERA:
    DEBUG_PRINT("post trigger wait");
    wait(POST_TRIGGER_WAIT);

    ledShow(0, 0, 128);
    delay(100);
    switchCameraOn(false);
    delay(900);
    ledShow(0, 0, 0);
  #endif

  picturesTaken++;

  DEBUG_PRINT("done. go to sleep");
  delay(100);

  #ifdef PERSISTENT_CAMERA:
    wait(INTERVAL - TRIGGER_DURATION - 0.200);
  #else
    wait(INTERVAL - PRE_TRIGGER_WAIT - TRIGGER_DURATION - POST_TRIGGER_WAIT - 2.200);
  #endif
}

void stopAndShutdown() {

  switchCameraOn(false);

  ledShow(128, 0, 0);
  delay(1000);
  ledShow(0, 0, 0);
  delay(100);

  while(true) {
    wait(1.0);
  }
}
