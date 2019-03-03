#include <JeeLib.h>

#include <Wire.h>
#include <EEPROM.h>
#include <Adafruit_NeoPixel.h>

#define CONTROLLER14

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

void initPrint(CommunicationInterface ser);

// ---------------------------

// OPTIONS

int watchdog_time           = DEFAULT_WATCHDOG_TIME;
int dummy_load_enabled      = DEFAULT_DUMMY_LOAD_ENABLED;

// ---------------------------

long watchdogTimer  = -1;
long zeroShutdownTimer = -1;

// ---------------------------

Adafruit_NeoPixel neopixel  = Adafruit_NeoPixel(1, PIN_LED, NEO_GRB + NEO_KHZ800);
int ledColor[]              = {0, 0, 0};
long ledDuration            = -1;
long ledTimer               = -1;
long ledIterations          = -1;
boolean ledOn               = false;

// ---------------------------

void setup() {

  Serial.begin(115200);
  // Serial1.begin(115200);

  initPins();

  #ifdef DEBUG
    while (!Serial) {;}
  #endif
 
  DEBUG_PRINT("INIT");
  
  ser0.inputBuffer = malloc(sizeof(char) * 100);
  ser1.inputBuffer = malloc(sizeof(char) * 100);
  resetSerial(ser0);
  resetSerial(ser1);

  // init values
  int error = initFromEEPROM();
  if (error > 0) {
    DEBUG_PRINT("eeprom empty. resetting values...");
    eeprom_reset();
    initFromEEPROM();
  }
//  #ifdef DEBUG
//    initPrint(ser0);
//  #endif;

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

  delay(1000);
  Serial.println("starting");
  digitalWrite(PIN_ZERO_EN,    LOW);

}

void loop() {

  //Serial.println(millis());

//  switchZeroOn(true);
//  while(1);
    
  serialEvent();  
  ledLoop();

}
