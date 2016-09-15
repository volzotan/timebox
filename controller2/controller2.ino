#include <JeeLib.h>

#include <SPI.h>
#include <Wire.h> 
#include <EEPROM.h>

#include "constants.h"

ISR(WDT_vect) { Sleepy::watchdogEvent(); }

#define DEBUG

int state = STATE_SLEEP;
int picturesTaken   = 0;
                    
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
  initFromEEPROM();
  initButtons();

  if (!checkLiPoHealth()) {
    // battery is empty, abort right now!
    state = STATE_STOP;
  }
  
  #ifdef DEBUG
    // do not start right away, go to menu
    state = STATE_MENU_INIT;
  #endif

  for (int i=0; i < 10; i++) {
    if (buttonPressed()) {
      state = STATE_MENU_INIT;
      break;
    }
    wait(0.1); 
  }

  selftest();
}


void loop() {

  if (state % 10 == 0) {
    potiSegment = getPotiPosition(7);
    if (potiSegment != oldPotiSegment) {
      state = (potiSegment+1) * 10 + 1;
    }

    if (buttonPressed()) {
      state = (potiSegment+1) * 10 + 2;
      delay(300);
    }

    oldPotiSegment = potiSegment;
  }

  switch(state) {

    case STATE_SLEEP:
      #ifdef DEBUG
        Serial.println("start sleeping");
        delay(100);
      #endif
      
      wait((optInterval * 60) - PRE_TRIGGER_WAIT - POST_TRIGGER_WAIT);

      if (picturesTaken < optIterations) {
        state = STATE_SENSOR_READ;
      }
    break;

    case STATE_SENSOR_READ:
      #ifdef DEBUG
        Serial.println("reading sensors...");
      #endif
      
      state = STATE_CAMERA_RUNNING;
    break;

    case STATE_CAMERA_RUNNING:
      #ifdef DEBUG
        Serial.println("taking picture...");
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
      lcd.init();
      lcd.backlight();
      lcd.setCursor(0,0);
      lcd.print("TIMEBOXGO");
      lcd.setCursor(0,1);
      lcd.print("version: ");
      lcd.setCursor(9,1);
      lcd.print(VERSION);
      
      wait(1.5);
      Serial.println("display initialized");
    
      state = STATE_MENU_DETAILS_DRAW;
    break;

    case STATE_MENU_DETAILS_DRAW:
      lcd.clear();

      lcd.setCursor(0,0);
      #if USE_TEMP_SENSOR
        lcd.print(readTempSensor());
        lcd.setCursor(5,0);
        lcd.print("C");
      #else
        lcd.print("BATTERY");
      #endif

      lcd.setCursor(0,1);
      lcd.print((int) getLiPoVoltage(-1));
      lcd.setCursor(3,1);
      lcd.print("%");
      
      lcd.setCursor(8,0);
      lcd.print("C1:");
      lcd.setCursor(11,0);
      lcd.print(getLiPoVoltage(1));
      lcd.setCursor(15,0);
      lcd.print("v");
      
      lcd.setCursor(8,1);
      lcd.print("C2:");
      lcd.setCursor(11,1);
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
      lcd.print("RELEASE SHUTTER");

      state--;
    break;

    case STATE_MENU_TAKE_PICTURE_SELECTED:
      takePicture(false);
    
      lcd.clear(); 
      lcd.setCursor(0,0);
      lcd.print("WAIT");
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
      lcd.setCursor(11,0);
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
        optInterval = valuesInterval[potiSegment];
        state = STATE_MENU_INTERVAL;
        eeprom_saveto();
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
        optIterations = valuesIterations[potiSegment];
        state = STATE_MENU_ITERATIONS;
        eeprom_saveto();
      }
      
    break;

    // ---------------------------------

    case STATE_MENU_START_DRAW: // +1
      lcd.clear();
      lcd.setCursor(0,0);
      lcd.print("START");

      lcd.setCursor(0,1);
      lcd.print("T:");
      lcd.setCursor(2,1);
      lcd.print(calculateTime(optIterations, optInterval));

      lcd.setCursor(9,0);
      lcd.print("N:");
      lcd.setCursor(11,0);
      lcd.print(optIterations);

      lcd.setCursor(9,1);
      lcd.print("D:");
      lcd.setCursor(11,1);
      lcd.print(optInterval);
     
      state--;
    break;

    case STATE_MENU_START_SELECTED: 
      lcd.clear();
      lcd.setCursor(0,0);
      lcd.print("STARTING in 10s");
      for (int i=9; i>-1; i--) {
        wait(1);
        lcd.setCursor(12,0);
        lcd.print("0" + String(i));
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
  // CELL3, CELL4

  pinMode(PIN_DISPLAY_EN,      OUTPUT);
  pinMode(PIN_DISPLAY_RST,     OUTPUT);
  pinMode(PIN_ZERO_EN,         OUTPUT);
  pinMode(PIN_SENSORS_EN,      OUTPUT); 
  pinMode(PIN_EXT_EN,          OUTPUT); 
   
  pinMode(PIN_PUSHBUTTON_UP,   INPUT); 
  pinMode(PIN_PUSHBUTTON_DOWN, INPUT); 
  pinMode(PIN_PUSHBUTTON_X,    INPUT);  

  pinMode(PIN_CAMERA_FOCUS,    OUTPUT);
  pinMode(PIN_CAMERA_SHUTTER,  OUTPUT);

  pinMode(PIN_TEMP,            INPUT);

  digitalWrite(PIN_DISPLAY_EN, LOW);
  digitalWrite(PIN_CAMERA_EN,  LOW);
  digitalWrite(PIN_SENSORS_EN, LOW);

}

void takePicture(boolean turnCameraOn) {
  // TODO: if datalogger is enabled: log battery voltage
  //loggerWrite();

  if (turnCameraOn) {
    digitalWrite(PIN_CAMERA_EN, HIGH);
    wait(PRE_TRIGGER_WAIT);
  }
  
  digitalWrite(PIN_CAMERA_FOCUS, HIGH);
  delay(100);
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
  int segmentSize = 1030 / numberOfSegments;

  return analogRead(PIN_POTENTIOMETER) / segmentSize;
}

boolean checkLiPoHealth() {
  float c1 = getLiPoVoltage(1);
  float c2 = getLiPoVoltage(2);
  
  if (c1 < LIPO_CELL_MIN ||  c2 < LIPO_CELL_MIN) {
    if (c1 == 0) {
      Serial.println("LiPo not connected");
    } else {
      Serial.println("LiPo voltage below threshold! [c1:" + String(c1) + " | c2:" + String(c2) + "]");
    }
    
    delay(100);
    return false;
  }

  return true;
}

float getLiPoVoltage(int cell) {
  switch (cell) {
    case 0: // whole battery
      return ((float) analogRead(PIN_CELL_2) / 1024) * 10.0;
    break;

    case 1: // cell 1
      return ((float) analogRead(PIN_CELL_1) / 1024) * 10.0;
    break;

    case 2: // cell 2
      return (((float) analogRead(PIN_CELL_2) / 1024) * 10.0) - ((float) analogRead(PIN_CELL_1) / 1024) * 10.0;
    break;

    case -1: // percentage loaded 
      return ((getLiPoVoltage(1) + getLiPoVoltage(2)) - LIPO_CELL_MIN*2) / (((LIPO_CELL_MAX-LIPO_CELL_MIN) * 2) / 100);
    break;
    
    default:
      return -1;
    break;
  }
}

void displayOn(boolean state) {
  if (state) {
    digitalWrite(PIN_DISPLAY_EN, HIGH);
  } else {
    digitalWrite(PIN_DISPLAY_EN, LOW);  
  }
}

int buttonPressed() {
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

float readTempSensor() {
  sensorsOn(true);

  sensor.begin();
  sensor.set_address(0);
  sensor.set_resolution(3);

  delay(100);
  float t = sensor.read();  
  
  sensorsOn(false);
 
  return t;
}

void selftest() {
  
  Serial.print("LiPo -1:"); Serial.println(getLiPoVoltage(-1));
  Serial.print("LiPo  0:"); Serial.println(getLiPoVoltage(0));
  Serial.print("LiPo  1:"); Serial.println(getLiPoVoltage(1));
  Serial.print("LiPo  2:"); Serial.println(getLiPoVoltage(2));

  Serial.print("Temp:"); Serial.println(readTempSensor());
  
  Serial.print("Poti (10 Seg.):"); Serial.println(getPotiPosition(10));
  Serial.print("Button:"); Serial.println(buttonPressed());
}
