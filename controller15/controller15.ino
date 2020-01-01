#include <Wire.h>
#include <Adafruit_NeoPixel.h>
#include "Adafruit_MCP9808.h"

#include "global.h"
#include "constants.h"

#define SHUTDOWN_ON_LOW_BATTERY 0

#define ONESHOT_MODE
// #define DEBUG

#ifdef ONESHOT_MODE
    #define HOST_DEFAULT_POWERED_ON 0
#else 
    #define HOST_DEFAULT_POWERED_ON 1
#endif

#ifdef DEBUG
  #define DEBUG_PRINT(x) SerialUSB.print("["); SerialUSB.print(millis()/1000); SerialUSB.print("] "); SerialUSB.println (x)
#else
  #define DEBUG_PRINT(x)
#endif

// ---------------------------

#ifdef ONESHOT_MODE
    // Hardware is in master mode (for oneshot pi controller)
    int state                       = STATE_IDLE;
#else
    // Hardware is in slave mode (for zerobox pi controller)
    int state                       = STATE_LOOP; 
#endif

long trigger_done               = 0;

long currentTrigger             = -1;
long nextTrigger                = -1;
long postTriggerWaitDelayed     = -1;

#define TRIGGER_INTERVAL        120 *1000 // take picture every X seconds [ms]
#define TRIGGER_MAX_ACTIVE      90  *1000 // zero & cam max time on [ms]
// #define TRIGGER_CAM_DELAY       5   *1000 // turn camera on X seconds after zero [ms]
// #define TRIGGER_WAIT_DELAYED    1   *1000 // wait for X seconds after zero requests shutdown [ms]
#define TRIGGER_COUNT           2000      // max number of triggers

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
    #ifdef SHUTDOWN_ON_LOW_BATTERY == 1
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

    #ifdef ONESHOT_MODE
        nextTrigger = millis() + 3000;
    #endif

}

void loop() { 
  serialEvent();  
  ledLoop();

  switch(state) {

    // do nothing and wait for incoming serial commands
    case STATE_LOOP: {
        break;
    }

    // do nothing and check if it's time to fire a trigger event
    case STATE_IDLE: {

        // all trigger done?
        if (trigger_done >= TRIGGER_COUNT) {
            DEBUG_PRINT("done [IDLE -> LOOP]");
            state = STATE_LOOP;
        }   

        // time for new trigger event?
        if (millis() >= nextTrigger) {
            currentTrigger = nextTrigger; 
            nextTrigger += TRIGGER_INTERVAL; 
            DEBUG_PRINT("start [IDLE -> TRIGGER_START]");
            state = STATE_TRIGGER_START;
        }

        break;
    }

    // start the camera, the pi and the USB connections
    case STATE_TRIGGER_START: {

        switchCameraOn(true);
        delay(1000);
        switchZeroOn(true);
        delay(500);
        switchUsbDeviceOn(0, true);
        delay(100);
        switchUsbDeviceOn(1, true);

        trigger_done += 1;
        DEBUG_PRINT("trigger active [TRIGGER_START -> TRIGGER_WAIT]");
        state = STATE_TRIGGER_WAIT;

        break;
    }

    // pi is currently running and should be shutdown at the latest 
    // after TRIGGER_MAX_ACTIVE. May ask for shutdown before that,
    // if so: waiting for X to pass
    case STATE_TRIGGER_WAIT: {

        if (millis() >= currentTrigger + TRIGGER_MAX_ACTIVE) {

            switchEverytingOff();
            postTriggerWaitDelayed = -1;
            DEBUG_PRINT("trigger max active done [TRIGGER_WAIT -> IDLE]");
            state = STATE_IDLE;
        } else if (postTriggerWaitDelayed > 0 && 
            millis() >= postTriggerWaitDelayed) {

            switchEverytingOff();
            postTriggerWaitDelayed = -1;
            DEBUG_PRINT("trigger done by request [TRIGGER_WAIT -> IDLE]");
            state = STATE_IDLE;
        }

        break;
    }

    default: {
        DEBUG_PRINT("ERROR! illegal state!");
    }
  }
}

void stopAndShutdown() {
  ledShow(0, 0, 0);
  // switchZeroOn(false);

  while(true) {
    wait(1.0);
  }
}
