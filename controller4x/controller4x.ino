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

void setup() {
  Serial.begin(9600);
  while (!Serial) {
    ;
  }

  Serial.println(F("init"));
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

  initDisplay();
}

void loop() {
  delay(1000);
  selftest();
}

