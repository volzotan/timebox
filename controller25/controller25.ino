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

  if (!checkLiPoHealth()) {
    // battery is empty, abort right now!

    Serial.println("stopping!...");
    state = STATE_STOP;
  }

  #ifdef DEBUG
    // do not start right away, go to menu
    state = STATE_MENU_INIT;
  #endif

  for (int i = 0; i < 50; i++) {
    if (buttonXPressed()) {
      state = STATE_MENU_INIT;
      break;
    }
    wait(0.1);
  }

  selftest();
}


void loop() {

//  Serial.print(getLiPoVoltage(0));
//  Serial.print(" ");
//  Serial.print(getLiPoVoltage(1));
//  Serial.print(" ");
//  Serial.println(getLiPoVoltage(2));
//  delay(1000);

  if (state % 10 == 0) {
    if (buttonXPressed()) {
      state += 2;
      arrayPointer = 0;
      oldArrayPointer = 1;
      delay(300);
    }

    if (buttonUpPressed() && state < STATE_MENU_START) {
      state += 11;
      delay(300);
    }

    if (buttonDownPressed() && state > STATE_MENU_DETAILS) {
      state -= 9;
      delay(300);
    }
  }

  switch (state) {

    case STATE_INIT:
      // do nothing. right now all init code is in setup()
      break;

    case STATE_SLEEP:
      #ifdef DEBUG
        Serial.println(F("start sleeping"));
        delay(100);
      #endif

      wait((optInterval * 60) - PRE_TRIGGER_WAIT - POST_TRIGGER_WAIT);

      if (picturesTaken < optIterations) {
        state = STATE_SENSOR_READ;
      }
      break;

    case STATE_SENSOR_READ:
      #ifdef DEBUG
        Serial.println(F("reading sensors..."));
      #endif

      state = STATE_CAMERA_RUNNING;
      break;

    case STATE_CAMERA_RUNNING:
      #ifdef DEBUG
        Serial.println(F("taking picture..."));
      #endif

      if (!checkLiPoHealth()) {
        // battery is empty
        state = STATE_STOP;
      }

      takePicture(true);
      state = STATE_SLEEP;
      break;

    case STATE_STOP:
      wait(60);
      break;

    // ---------------------------------

    case STATE_MENU_INIT:
      wait(0.5);
      displayOn(true);
      delay(100);
      initDisplay();

      wait(1.5);
      Serial.println(F("display initialized"));

      state = STATE_MENU_DETAILS_DRAW;
      break;

    case STATE_MENU_DETAILS_DRAW:
      display.clearDisplay();
      
      display.setCursor(0, 0);
      #if USE_TEMP_SENSOR
        display.print(readTempSensor());
        display.setCursor(5, 0);
        display.print("C");
      #else
        display.print("BATT");
      #endif

      display.setCursor(0, SECONDROW);
      display.print((int) getLiPoVoltage(-1));
      display.setCursor(32, SECONDROW);
      display.print("%");

      display.setTextSize(1);

      display.setCursor(70, 0);
      display.print("B :");
      display.setCursor(90, 0);
      display.print(getLiPoVoltage(0));
      display.setCursor(120, 0);
      display.print("v");

      display.setCursor(70, 11);
      display.print("C1:");
      display.setCursor(90, 11);
      display.print(getLiPoVoltage(1));
      display.setCursor(120, 11);
      display.print("v");

      display.setCursor(70, 23);
      display.print("C2:");
      display.setCursor(90, 23);
      display.print(getLiPoVoltage(2));
      display.setCursor(120, 23);
      display.print("v");
      
      display.setTextSize(2);

      display.display();

      state--;
      break;

    // ---------------------------------

    case STATE_MENU_CAMERA_ON_DRAW:
      display.clearDisplay();
      display.setCursor(0, 0);
      display.print(F("CAMERA ON"));
      display.display();

      state--;
      break;

    case STATE_MENU_CAMERA_ON_SELECTED:
      digitalWrite(PIN_CAMERA_EN, HIGH);

      display.clearDisplay();
      display.setCursor(0, 0);
      display.print(F("CAMERA ON"));
      display.print(".");
      display.display();
      wait(0.5);
      display.print(".");
      display.display();
      wait(0.5);
      display.print(".");
      display.display();
      wait(0.5);

      state = STATE_MENU_CAMERA_ON_DRAW;
      break;

    // ---------------------------------

    case STATE_MENU_CAMERA_OFF_DRAW:
      display.clearDisplay();
      display.setCursor(0, 0);
      display.print("CAMERA OFF");
      display.display();

      state--;
      break;

    case STATE_MENU_CAMERA_OFF_SELECTED:
      digitalWrite(PIN_CAMERA_EN, LOW);

      display.clearDisplay();
      display.setCursor(0, 0);
      display.print("CAMERA OFF ...");
      display.display();
      wait(1.0);

      state = STATE_MENU_CAMERA_OFF_DRAW;
      break;

    // ---------------------------------

    case STATE_MENU_TAKE_PICTURE_DRAW:
      display.clearDisplay();
      display.setCursor(0, 0);
      display.print("RELEASE");
      display.setCursor(0, SECONDROW);
      display.print("SHUTTER");
      display.display();

      state--;
      break;

    case STATE_MENU_TAKE_PICTURE_SELECTED:
      takePicture(false);

      display.clearDisplay();
      display.setCursor(0, 0);
      display.print("WAIT.");
      display.display();
      wait(0.5);
      display.setCursor(0, 0);
      display.print("WAIT..");
      display.display();
      wait(0.5);
      display.setCursor(0, 0);
      display.print("WAIT...");
      display.display();
      wait(0.5);

      state = STATE_MENU_TAKE_PICTURE_DRAW;
      break;

    // ---------------------------------

    case STATE_MENU_INTERVAL_DRAW: // +1
      display.clearDisplay();
      display.setCursor(0, 0);
      display.print("INTERVAL");
      display.setCursor(0, SECONDROW);
      display.print(optInterval);
      display.display();
      state--;
      break;

    case STATE_MENU_INTERVAL_SELECTED: // +2
      if (oldArrayPointer != arrayPointer) {
        display.clearDisplay();

        display.setCursor(0, SECONDROW);
        display.print(valuesInterval[arrayPointer]);

        // total Time
        display.setCursor(0, 0);
        display.print("T:");
        display.setCursor(24, 0);
        display.print(calculateTime(valuesInterval[arrayPointer], optIterations));
        display.display();
        oldArrayPointer = arrayPointer;
      }

      if (buttonUpPressed() && arrayPointer < (sizeof(valuesInterval) / sizeof(valuesInterval[0])) - 1 ) {
        arrayPointer++;
      }

      if (buttonDownPressed() && arrayPointer > 0 ) {
        arrayPointer--;
      }

      if (buttonXPressed()) {
        optInterval = valuesInterval[arrayPointer];
        state = STATE_MENU_INTERVAL_DRAW;
        eeprom_saveto();
      }

      break;

    // ---------------------------------

    case STATE_MENU_ITERATIONS_DRAW: // +1
      display.clearDisplay();
      display.setCursor(0, 0);
      display.print("ITERATIONS");
      display.setCursor(0, SECONDROW);
      display.print(optIterations);
      display.display();
      state--;
      break;

    case STATE_MENU_ITERATIONS_SELECTED: // +2
      if (oldArrayPointer != arrayPointer) {
        display.clearDisplay();

        display.setCursor(0, SECONDROW);
        display.print(valuesIterations[arrayPointer]);

        // total Time
        display.setCursor(0, 0);
        display.print("T:");
        display.setCursor(24, 0);
        display.print(calculateTime(optInterval, valuesIterations[arrayPointer]));
        display.display();
        oldArrayPointer = arrayPointer;
      }

      if (buttonUpPressed() && arrayPointer < (sizeof(valuesIterations) / sizeof(valuesIterations[0])) - 1 ) {
        arrayPointer++;
      }

      if (buttonDownPressed() && arrayPointer > 0 ) {
        arrayPointer--;
      }

      if (buttonXPressed()) {
        optIterations = valuesIterations[arrayPointer];
        state = STATE_MENU_ITERATIONS_DRAW;
        eeprom_saveto();
      }

      break;

    // ---------------------------------

    case STATE_MENU_START_DRAW: // +1
      display.clearDisplay();
      display.setCursor(0, 0);
      display.print("START");

      display.setTextSize(1);
      display.setCursor(80, 0);
      display.print("N:");
      display.setCursor(92, 0);
      display.print(optIterations);

      display.setCursor(80, 9);
      display.print("D:");
      display.setCursor(92, 9);
      display.print(optInterval);
      display.setTextSize(2);
      
      display.setCursor(0, SECONDROW);
      display.print("T:");
      display.setCursor(24, SECONDROW);
      display.print(calculateTime(optInterval, optIterations));

      display.display();

      state--;
      break;

    case STATE_MENU_START_SELECTED:
      digitalWrite(PIN_CAMERA_EN, LOW);
    
      display.clearDisplay();
      display.setCursor(0, 0);
      display.print("STARTING in 10s");
      display.display();
      for (int i = 9; i > -1; i--) {
        wait(1);
        display.clearDisplay();
        display.setTextSize(4);
        display.setCursor(0, 0);
        display.print("0" + String(i));
        display.display();
        //        if (buttonPressed()) {
        //          // abort
        //          state = STATE_MENU_DETAILS;
        //        }
      }

      displayOn(false);

      wait(1);

      picturesTaken = 0;
      state = STATE_SENSOR_READ;
      break;

    // ---------------------------------

    case STATE_MENU_SLEEP_DRAW: // +1
      display.clearDisplay();
      display.setCursor(0, 0);
      display.print("SLEEP");
      display.display();

      state--;
      break;

    
    case STATE_MENU_SLEEP_SELECTED:
      state = STATE_STOP;
      break;

    // ---------------------------------

    default:
      if (state % 10 == 1) {
        state -= 1;
        return;
      }

      if (state % 10 == 2) {
        state -= 2;
        return;
      }

      //Serial.println("ERR: no valid state");
  }

  //wait(1);
}

void initButtons() {

  pinMode(PIN_CELL_1,          INPUT);
  pinMode(PIN_CELL_2,          INPUT);
  pinMode(PIN_BATT_DIRECT,     INPUT);

  pinMode(PIN_CAMERA_EN,       OUTPUT);
  pinMode(PIN_ZERO_EN,         OUTPUT);
  pinMode(PIN_DISPLAY_RST,     OUTPUT);

  pinMode(PIN_PUSHBUTTON_UP,   INPUT);
  pinMode(PIN_PUSHBUTTON_DOWN, INPUT);
  pinMode(PIN_PUSHBUTTON_X,    INPUT);

  pinMode(PIN_CAMERA_FOCUS,    OUTPUT);
  pinMode(PIN_CAMERA_SHUTTER,  OUTPUT);

  pinMode(PIN_TEMP,            INPUT);

  digitalWrite(PIN_CAMERA_EN,  LOW);

}

void initDisplay() {
  // initialize with the I2C addr 0x3C (for the 128x32)
  display.begin(SSD1306_SWITCHCAPVCC, 0x3C);
  display.clearDisplay();

  display.setTextColor(WHITE);
  display.setTextSize(2);

  display.setCursor(0,0);
  display.print(F("TIMEBOXGO"));

  display.setTextSize(2);
  display.setCursor(0,SECONDROW);
  display.print(F("version: "));
  display.setCursor(64,SECONDROW);
  display.print(VERSION);

  display.display();
}

void takePicture(boolean turnCameraOn) {
  // TODO: if datalogger is enabled: log battery voltage
  //loggerWrite();

  if (turnCameraOn) {
    digitalWrite(PIN_CAMERA_EN, HIGH);
    wait(PRE_TRIGGER_WAIT);
  }

  pinMode(PIN_CAMERA_FOCUS, OUTPUT);
  digitalWrite(PIN_CAMERA_FOCUS, HIGH);
  delay(100);
  
  pinMode(PIN_CAMERA_SHUTTER, OUTPUT);
  digitalWrite(PIN_CAMERA_SHUTTER, HIGH);
  delay(100);
  
  digitalWrite(PIN_CAMERA_SHUTTER, LOW);
  digitalWrite(PIN_CAMERA_FOCUS, LOW);

  if (turnCameraOn) {
    wait(POST_TRIGGER_WAIT);
    digitalWrite(PIN_CAMERA_EN, LOW);
  }

  picturesTaken++;

  // TODO: if datalogger is enabled: log battery voltage again for comparison
}

String calculateTime(int interval, int iterations) {
  String hours = String((iterations * interval) / 60);
  if (hours.length() < 2) {
    hours = "0" + hours;
  }

  String minutes = String((iterations * interval) % 60);
  if (minutes.length() < 2) {
    minutes = "0" + minutes;
  }

  return hours + "h" + minutes + "m";
}

boolean checkLiPoHealth() {
  float c0 = getLiPoVoltage(0);
  float c1 = getLiPoVoltage(1);
  float c2 = getLiPoVoltage(2);

  if (c0 < 1.0 && (c1 < 1.0 || c2 < 1.0)) {
    Serial.println("LiPo not connected");
    delay(100);
    // whatever. probably USB powered.
    return true;
  }

  if (c0 > 1.0 && c0 < LIPO_CELL_MIN*2) {
    Serial.println("LiPo voltage below threshold! [c0:" + String(c0) + "]");
    delay(100);
    return false;
  }

  if (c1 > 1.0 && (c1 < LIPO_CELL_MIN ||  c2 < LIPO_CELL_MIN)) {
    Serial.println("LiPo voltage below threshold! [c1:" + String(c1) + " | c2:" + String(c2) + "]");
    delay(100);
    return false;
  }

  return true;
}

float voltageDivider(float input) {
  return ((input / 1024) * VDBASEVOLTAGE) / ( (float) VDRESISTOR2 / (VDRESISTOR1 + VDRESISTOR2) );
}

float getLiPoVoltage(int cell) {
  float acc = 0;

  for (int i=0; i<3; i++) {
    acc += getLiPoVoltageRaw(cell);
    delay(1);  
  }

  return acc/3.0; 
}

float getLiPoVoltageRaw(int cell) {
  switch (cell) {
    case 0: // whole battery
      return voltageDivider((float) analogRead(PIN_BATT_DIRECT));
      break;

    case 1: // cell 1
      return abs(voltageDivider((float) analogRead(PIN_CELL_1)));
      break;

    case 2: // cell 2
      return abs(voltageDivider((float) analogRead(PIN_CELL_2)) - voltageDivider((float) analogRead(PIN_CELL_1)));
      break;

    case -1: // percentage loaded
      if (voltageDivider((float) analogRead(PIN_CELL_1)) > 1.0) {
        return (getLiPoVoltage(1) + getLiPoVoltage(2) - LIPO_CELL_MIN * 2) / (((LIPO_CELL_MAX - LIPO_CELL_MIN) * 2) / 100);
      } else if (voltageDivider((float) analogRead(PIN_BATT_DIRECT)) > 1.0) {
        return (getLiPoVoltage(0) - LIPO_CELL_MIN * 2) / (((LIPO_CELL_MAX - LIPO_CELL_MIN) * 2) / 100);
      } else {
        return -1;  
      }
      break;

    default:
      return -1;
      break;
  }
}

void displayOn(boolean state) {
//  if (state) {
//    digitalWrite(PIN_DISPLAY_EN, HIGH);
//  } else {
//    display.clearDisplay();
//    display.display();
//    digitalWrite(PIN_DISPLAY_EN, LOW);
//  }
}

int buttonUpPressed() {
  for (int i = 0; i < 3; i++) {
    if (digitalRead(PIN_PUSHBUTTON_UP)) {
      return false;
    }
    delay(10);
  }

  while (!digitalRead(PIN_PUSHBUTTON_UP)) {}
  delay(10);

  return true;
}

int buttonDownPressed() {
  for (int i = 0; i < 3; i++) {
    if (digitalRead(PIN_PUSHBUTTON_DOWN)) {
      return false;
    }
    delay(10);
  }

  while (!digitalRead(PIN_PUSHBUTTON_DOWN)) {}
  delay(10);

  return true;
}

int buttonXPressed() {
  for (int i = 0; i < 3; i++) {
    if (digitalRead(PIN_PUSHBUTTON_X)) {
      return false;
    }
    delay(10);
  }

  while (!digitalRead(PIN_PUSHBUTTON_X)) {}
  delay(10);

  return true;
}

void wait(float seconds) {
  for (int i = 0; i < (int) seconds; ++i) {
    Sleepy::loseSomeTime(1000);
  }

  Sleepy::loseSomeTime((int) ((seconds - ((int) seconds)) * 1000));
}

float readTempSensor() {
  return -23;
}

void selftest() {

  Serial.print(F("LiPo -1:")); Serial.println(getLiPoVoltage(-1));
  Serial.print(F("LiPo  0:")); Serial.println(getLiPoVoltage(0));
  Serial.print(F("LiPo  1:")); Serial.println(getLiPoVoltage(1));
  Serial.print(F("LiPo  2:")); Serial.println(getLiPoVoltage(2));

  Serial.print(F("Temp:")); Serial.println(readTempSensor());

  Serial.print(F("ButtonUP  :")); Serial.println(buttonUpPressed());
  Serial.print(F("ButtonDOWN:")); Serial.println(buttonDownPressed());
  Serial.print(F("ButtonX   :")); Serial.println(buttonXPressed());
}
