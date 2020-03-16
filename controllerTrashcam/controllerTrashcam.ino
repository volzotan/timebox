#include <Wire.h>
#include "Adafruit_MCP9808.h"

#include "global.h"
#include "constants.h"

#define DEBUG

#define SHUTDOWN_ON_LOW_BATTERY
// #define HOST_DEFAULT_POWERED_ON
// #define WAIT_ON_BOOT_FOR_SERIAL
// #define TEMP_SENSOR_AVAILABLE

#define SERIAL Serial1

#ifdef DEBUG
  #define DEBUG_PRINT(x) SerialUSB.print("["); SerialUSB.print(millis()/1000); SerialUSB.print("] "); SerialUSB.println (x)
#else
  #define DEBUG_PRINT(x)
#endif

// ---------------------------

int state                       = STATE_IDLE;
// int state                       = STATE_LOOP;

long trigger_done               = 0;

long currentTrigger             = -1;
long nextTrigger                = -1;
long postTriggerWaitDelayed     = -1;

long trigger_reduced_till       = -1;
long trigger_increased_till     = -1;

#define TRIGGER_INTERVAL        90  *1000       // take picture every X seconds [ms]
#define TRIGGER_INTERVAL_RED    240 *1000
#define TRIGGER_INTERVAL_INC    60  *1000

#define TRIGGER_MAX_ACTIVE      59  *1000       // zero & cam max time on [ms]
// #define TRIGGER_CAM_DELAY       5   *1000    // turn camera on X seconds after zero [ms]
// #define TRIGGER_WAIT_DELAYED    1   *1000    // wait for X seconds after zero requests shutdown [ms]
#define TRIGGER_COUNT           10000           // max number of triggers

// ---------------------------

char *inputBuffer           = (char*) malloc(sizeof(char) * 100);
String serialInputString    = "";
char serialCommand          = 0;
int serialParam             = -1;
int serialParam2            = -1;

// ---------------------------

Adafruit_MCP9808 tempsensor = Adafruit_MCP9808();

// ---------------------------

void setup() {

    SerialUSB.begin(9600);
    SERIAL.begin(9600);

    resetSerial();

    DEBUG_PRINT("INIT");
    DEBUG_PRINT("DEBUG MODE ON");

    initPins();

    #ifdef WAIT_ON_BOOT_FOR_SERIAL
        while (!SerialUSB) {;}
        DEBUG_PRINT("SerialUsb connected");
    #endif

    // set the resolution mode of reading
    // Mode  Resolution  SampleTime
    //  0    0.5°C       30 ms
    //  1    0.25°C      65 ms
    //  2    0.125°C     130 ms
    //  3    0.0625°C    250 ms

    #ifdef TEMP_SENSOR_AVAILABLE
        if (!tempsensor.begin(0x18)) {
            DEBUG_PRINT("temperature sensor not found");
        } else {
            tempsensor.setResolution(1); 
        }
    #endif

    // battery life
    if (!checkBattHealth()) {
        // battery is empty, abort right now!

        DEBUG_PRINT("battery low! stopping...");
        #ifdef SHUTDOWN_ON_LOW_BATTERY 

            stopAndShutdown();

            // #ifndef DEBUG
            //     stopAndShutdown();
            // #else
            //     DEBUG_PRINT("stopping aborted (DEBUG mode on)");
            // #endif

        #else
            DEBUG_PRINT("stopping aborted (no SHUTDOWN_ON_LOW_BATTERY)");
        #endif
    }

    #ifdef DEBUG
    
        for (int i=0; i<50; i++) {
            SerialUSB.print(".");
            delay(100);
        }
        SerialUSB.println();

        DEBUG_PRINT("-----------------");
        DEBUG_PRINT("Battery pin value:");
        analogRead(PIN_BATT_DIRECT);
        delay(100);
        DEBUG_PRINT(analogRead(PIN_BATT_DIRECT));
        DEBUG_PRINT("Battery voltage:");
        DEBUG_PRINT(getBatteryVoltage());
        DEBUG_PRINT("Battery percentage:");
        DEBUG_PRINT(getBatteryPercentage());
        DEBUG_PRINT("Temperature:");
        #ifdef TEMP_SENSOR_AVAILABLE
            // TODO
        #else:
            DEBUG_PRINT("(temp sensor not available)");
        #endif
        DEBUG_PRINT("-----------------");
        DEBUG_PRINT("TRIGGER_INTERVAL:");
        DEBUG_PRINT(TRIGGER_INTERVAL);
        DEBUG_PRINT("TRIGGER_INTERVAL_RED:");
        DEBUG_PRINT(TRIGGER_INTERVAL_RED);
        DEBUG_PRINT("TRIGGER_INTERVAL_INC:");
        DEBUG_PRINT(TRIGGER_INTERVAL_INC);
        DEBUG_PRINT("TRIGGER_MAX_ACTIVE:");
        DEBUG_PRINT(TRIGGER_MAX_ACTIVE);
        DEBUG_PRINT("-----------------");
    #endif

    nextTrigger = millis() + 1000;

}

void loop() { 
    serialEvent();  

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

                stopAndShutdown();
                // state = STATE_LOOP;
            }   

            // time for new trigger event?
            if (millis() >= nextTrigger) {
                currentTrigger = nextTrigger; 

                int interval_length = TRIGGER_INTERVAL;

                if (trigger_reduced_till > 0) {
                    if (millis() < trigger_reduced_till) {
                        interval_length = TRIGGER_INTERVAL_RED;
                        DEBUG_PRINT("interval in reduced trigger state");
                    } else {
                        trigger_reduced_till = -1;
                        DEBUG_PRINT("interval switched from reduced to regular");
                    }
                } else if (trigger_increased_till > 0) {
                    if (millis() < trigger_increased_till) {
                        interval_length = TRIGGER_INTERVAL_INC;
                        DEBUG_PRINT("interval in increased trigger state");
                    } else {
                        trigger_increased_till = -1;
                        DEBUG_PRINT("interval switched from increased to regular");
                    }
                }

                nextTrigger += interval_length; 
                
                DEBUG_PRINT("start [IDLE -> TRIGGER_START]");
                state = STATE_TRIGGER_START;
            }

            break;
        }

        // start the camera, the pi and the USB connections
        case STATE_TRIGGER_START: {

            if (!checkBattHealth()) {
                #ifdef SHUTDOWN_ON_LOW_BATTERY

                    stopAndShutdown();

                    // #ifndef DEBUG
                    //     stopAndShutdown();
                    // #else
                    //     DEBUG_PRINT("stopping aborted (DEBUG mode on)");
                    // #endif
                #else
                    DEBUG_PRINT("stopping aborted (no SHUTDOWN_ON_LOW_BATTERY)");
            #endif
            }

            switchZeroOn(true);

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

                switchZeroOn(false);
                postTriggerWaitDelayed = -1;
                DEBUG_PRINT("trigger max active done [TRIGGER_WAIT -> IDLE]");
                DEBUG_PRINT("uptime [ms]: ");
                DEBUG_PRINT(millis()-currentTrigger);
                state = STATE_IDLE;
            } else if (postTriggerWaitDelayed > 0 && 
                millis() >= postTriggerWaitDelayed) {

                switchZeroOn(false);
                postTriggerWaitDelayed = -1;
                DEBUG_PRINT("trigger done by request [TRIGGER_WAIT -> IDLE]");
                DEBUG_PRINT("uptime [ms]:");
                DEBUG_PRINT(millis()-currentTrigger);
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

    DEBUG_PRINT("STOP AND SHUTDOWN");

    switchZeroOn(false);

    while(true) {
        wait(1.0);
    }
}
