#include <JeeLib.h>
#include <Wire.h> 
#include <LiquidCrystal_I2C.h>
#include "constants.h"

ISR(WDT_vect) { Sleepy::watchdogEvent(); }
LiquidCrystal_I2C lcd(0x27,16,2);  

#define DEBUG

int state = STATE_MENU_DETAILS;

int oldPotiSegment  = 0;
int potiSegment     = oldPotiSegment;
                    
// ---------------------------

int optInterval     =       1;
int optIterations   =     100;

const int valuesInterval[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
const int valuesIterations[] = {50, 60, 70, 80, 90, 100, 125, 150, 175, 200, 250, 300, 350, 400, 500, 600, 700, 800, 900};

// ---------------------------

void setup() {
  
  Serial.begin(9600);
  while (!Serial) {
    ; 
  }
  
  Serial.println("init");
  initButtons();
  
  #ifdef USE_DISPLAY
    digitalWrite(PIN_DISPLAY_EN, LOW);
    delay(100);
    lcd.init();                      // initialize the lcd 
    lcd.backlight();
    lcd.setCursor(0,0);
    lcd.print("TIMEBOXGO");
    lcd.setCursor(0,1);
    lcd.print("version: ");
    lcd.setCursor(9,1);
    lcd.print(VERSION);
    
    wait(1);
    Serial.println("display initialized");
  #endif
}


void loop() {

//  while (true) {
//    Serial.println("low");
//    digitalWrite(PIN_CAMERA_EN, LOW);
//    digitalWrite(PIN_SENSORS_EN, LOW);
//    delay(1000);
//    Serial.println("high");
//    digitalWrite(PIN_CAMERA_EN, HIGH);
//    digitalWrite(PIN_SENSORS_EN, HIGH);  
//    delay(1000);
//  }

//  #ifdef DEBUG 
//    //Serial.println(state);
//    Serial.print(state);
//    Serial.print(" ");
//    Serial.print(getPotiPosition(7));
//    Serial.print(" ");
//    Serial.print(getLiPoVoltage(1));
//    Serial.print(" ");
//    Serial.print(getLiPoVoltage(2));
//    Serial.print(" ");
//    Serial.println(getLiPoVoltage(0));
//    delay(50);
//  #endif

  if (state % 10 == 0) {
    potiSegment = getPotiPosition(7);
    if (potiSegment != oldPotiSegment) {
      state = potiSegment * 10 + 1;
    }

    if (buttonPressed()) {
      state = potiSegment * 10 + 2;
      delay(300);
    }

    oldPotiSegment = potiSegment;
  }

  switch(state) {

    case STATE_SLEEP:
      
    break;

    case STATE_SENSOR_READ:
    break;

    case STATE_CAMERA_RUNNING:
      
    break;

    // ---------------------------------

    case STATE_MENU_DETAILS_DRAW:
      lcd.clear();
      lcd.setCursor(9,0);
      lcd.print("C1:");
      lcd.setCursor(12,0);
      lcd.print(getLiPoVoltage(1));
      lcd.setCursor(15,0);
      lcd.print("v");
      lcd.setCursor(9,1);
      lcd.print("C2:");
      lcd.setCursor(12,1);
      lcd.print(getLiPoVoltage(2));
      lcd.setCursor(15,1);
      lcd.print("v");

      state--;
    break;

    // ---------------------------------

    case STATE_MENU_CAMERA_ON_DRAW:
      lcd.clear();
      lcd.setCursor(0,0);
      lcd.print("CAMERA ON");

      state--;
    break;

    case STATE_MENU_CAMERA_ON_SELECTED:
      digitalWrite(PIN_CAMERA_EN, HIGH);
    
      lcd.clear(); 
      lcd.setCursor(0,0);
      lcd.print("CAMERA ON");
      lcd.setCursor(10,0);
      lcd.print(".");
      wait(0.5);
      lcd.setCursor(11,0);
      lcd.print(".");
      wait(0.5);
      lcd.setCursor(12,0);
      lcd.print(".");
      wait(0.5);
  
      state = STATE_MENU_CAMERA_ON_DRAW;
    break;

    // ---------------------------------

    case STATE_MENU_CAMERA_OFF_DRAW:
      lcd.clear();
      lcd.setCursor(0,0);
      lcd.print("CAMERA OFF");

      state--;
    break;

    case STATE_MENU_CAMERA_OFF_SELECTED:
      digitalWrite(PIN_CAMERA_EN, LOW);
    
      lcd.clear(); 
      lcd.setCursor(0,0);
      lcd.print("CAMERA OFF ...");
      wait(1.0);
  
      state = STATE_MENU_CAMERA_OFF_DRAW;
    break;

    // ---------------------------------

    case STATE_MENU_TAKE_PICTURE_DRAW:
      lcd.clear();
      lcd.setCursor(0,0);
      lcd.print("TAKE PICTURE");

      state--;
    break;

    case STATE_MENU_TAKE_PICTURE_SELECTED:
      digitalWrite(PIN_CAMERA_SHUTTER, HIGH);
    
      lcd.clear(); 
      lcd.setCursor(0,0);
      lcd.print("TAKE PICTURE");
      lcd.setCursor(13,0);
      lcd.print(".");
      wait(0.5);
      lcd.setCursor(14,0);
      lcd.print(".");
      wait(0.5);
      lcd.setCursor(15,0);
      lcd.print(".");
      wait(0.5);
  
      state = STATE_MENU_TAKE_PICTURE_DRAW;
    break;

    // ---------------------------------
       
    case STATE_MENU_INTERVAL_DRAW: // +1
      lcd.clear();
      lcd.setCursor(0,0);
      lcd.print("INTERVAL");
      lcd.setCursor(10,0);
      lcd.print(optInterval);
      state--;
    break;

    case STATE_MENU_INTERVAL_SELECTED: // +2
      potiSegment = getPotiPosition(sizeof(valuesInterval)/sizeof(valuesInterval[0]));
      
      if (potiSegment != oldPotiSegment) {
        lcd.clear();
        
        lcd.setCursor(0,1);
        lcd.print(valuesInterval[potiSegment]);

        // total Time
        lcd.setCursor(8,1);
        lcd.print("T:");
        lcd.setCursor(10,1);
        lcd.print(calculateTime(valuesInterval[potiSegment], optIterations));
        oldPotiSegment = potiSegment;
      }
    
      if (buttonPressed()) {
        // TODO: saveValue...
        optInterval = valuesInterval[potiSegment];
        state = STATE_MENU_INTERVAL;
      }
      
    break;

    // ---------------------------------
         
    case STATE_MENU_ITERATIONS_DRAW: // +1
      lcd.clear();
      lcd.setCursor(0,0);
      lcd.print("ITERATIONS");
      lcd.setCursor(11,0);
      lcd.print(optIterations);
      state--;
    break;

    
    case STATE_MENU_ITERATIONS_SELECTED: // +2
      potiSegment = getPotiPosition(sizeof(valuesIterations)/sizeof(valuesIterations[0]));
      
      if (potiSegment != oldPotiSegment) {
        lcd.clear();
        
        lcd.setCursor(0,1);
        lcd.print(valuesIterations[potiSegment]);

        // total Time
        lcd.setCursor(8,1);
        lcd.print("T:");
        lcd.setCursor(10,1);
        lcd.print(calculateTime(optInterval, valuesIterations[potiSegment]));
        oldPotiSegment = potiSegment;
      }
    
      if (buttonPressed()) {
        // TODO: saveValue...
        optIterations = valuesIterations[potiSegment];
        state = STATE_MENU_ITERATIONS;
      }
      
    break;

    // ---------------------------------

    case STATE_MENU_START_DRAW: // +1
      lcd.clear();
      lcd.setCursor(0,0);
      lcd.print("START");

      lcd.setCursor(8,0);
      lcd.print("N:");
      lcd.setCursor(10,0);
      lcd.print(optIterations);

      lcd.setCursor(0,1);
      lcd.print("D:");
      lcd.setCursor(4,1);
      lcd.print(optInterval);

      lcd.setCursor(8,1);
      lcd.print("T:");
      lcd.setCursor(10,1);
      lcd.print("foo");
     
      state--;
    break;
    
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
  pinMode(PIN_CELL_1,         INPUT);  
  pinMode(PIN_CELL_2,         INPUT);  

  pinMode(PIN_DISPLAY_EN,     OUTPUT);
  pinMode(PIN_CAMERA_EN,      OUTPUT);
  pinMode(PIN_SENSORS_EN,     OUTPUT);
  pinMode(PIN_PHOTOCELL,      INPUT);  
  pinMode(PIN_POTENTIOMETER,  INPUT);  
  pinMode(PIN_PUSHBUTTON,     INPUT);  

  pinMode(PIN_CAMERA_FOCUS,   OUTPUT);
  pinMode(PIN_CAMERA_SHUTTER, OUTPUT);
}

void takePicture() {
  digitalWrite(PIN_CAMERA_EN, HIGH);
  
  wait(PRE_TRIGGER_WAIT);
  
  digitalWrite(PIN_CAMERA_SHUTTER, HIGH);
  delay(100);
  digitalWrite(PIN_CAMERA_SHUTTER, LOW);

  wait(POST_TRIGGER_WAIT);

  digitalWrite(PIN_CAMERA_EN, LOW);
}

String calculateTime(int iterations, int interval) {
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

int getPotiPosition(int numberOfSegments) {
  int segmentSize = 1024 / numberOfSegments;
  
  return analogRead(PIN_POTENTIOMETER) / segmentSize;
}

float getLiPoVoltage(byte cell) {
  switch (cell) {
    case 0:
      return ((float) analogRead(PIN_CELL_2) / 1024) * 10.0;
    break;

    case 1:
      return ((float) analogRead(PIN_CELL_1) / 1024) * 10.0;
    break;

    case 2:
      return (((float) analogRead(PIN_CELL_2) / 1024) * 10.0) - ((float) analogRead(PIN_CELL_1) / 1024) * 10.0;
    break;

    default:
      return -1;
    break;
  }
}

boolean buttonPressed() {
  for (int i=0; i<3; i++) {
    if (!digitalRead(PIN_PUSHBUTTON)) {
      return false;
    }
    delay(10);
  }

  while(digitalRead(PIN_PUSHBUTTON)) {}
  delay(10);

  return true;
}

void wait(float seconds) {
  for (int i = 0; i < (int) seconds; ++i) {
      Sleepy::loseSomeTime(1000);
  }
  
  Sleepy::loseSomeTime((int) ((seconds - ((int) seconds)) * 1000));
}
