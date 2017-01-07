#include <JeeLib.h>

#include <SPI.h>
#include <Wire.h>
#include <EEPROM.h>
#include <Adafruit_SSD1306.h>

#include "constants.h"

ISR(WDT_vect) {
  Sleepy::watchdogEvent();
}

#define DEBUG

Adafruit_SSD1306 display(PIN_DISPLAY_RST);

int state           = STATE_SLEEP;
int picturesTaken   = 0;

int oldArrayPointer = 0;
int arrayPointer    = 0;

// ---------------------------

int optInterval     =       1;
int optIterations   =     100;

const int valuesInterval[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15, 20};
const int valuesIterations[] = {50, 60, 70, 80, 90, 100, 125, 150, 175, 200, 250, 300, 350, 400, 500, 600, 700, 800, 900};

// ---------------------------

void setup() {
  Serial.begin(9600);
  while (!Serial) {
    ;
  }

  Serial.println(F("init"));
  initFromEEPROM();
  initButtons();

  if (!checkBattHealth()) {
    // battery is empty, abort right now!
    
    Serial.println("stopping!...");
    #ifndef DEBUG
      state = STATE_STOP;
    #else
      Serial.println("stopping aborted (debug mode)");
    #endif
  }

  digitalWrite(PIN_DISPLAY_EN, LOW);
  initDisplay();
}

void loop() {
  delay(1000);
  selftest();
}

