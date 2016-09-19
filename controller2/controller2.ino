#include <JeeLib.h>

#include <SPI.h>
#include <Wire.h> 
#include <EEPROM.h>
#include <Adafruit_SSD1306.h>

#include "constants.h"

ISR(WDT_vect) { Sleepy::watchdogEvent(); }

#define DEBUG

Adafruit_SSD1306 display(PIN_DISPLAY_RST);

int state = STATE_SLEEP;
int picturesTaken   = 0;

int oldArrayPointer = 0;
int arrayPointer    = 0;
                    
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

    #ifndef DEBUG
      Serial.println("stopping!...");
      state = STATE_STOP;
    #endif
  }

  #ifdef DEBUG
    // do not start right away, go to menu
    state = STATE_MENU_INIT;
  #endif

  for (int i=0; i < 10; i++) {
    if (buttonXPressed()) {
      state = STATE_MENU_INIT;
      break;
    }
    wait(0.1); 
  }

  selftest();
}


void loop() {

  Serial.println(state);

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
      initDisplay();
      
      wait(1.5);
      Serial.println("display initialized");
    
      state = STATE_MENU_DETAILS_DRAW;
    break;

    case STATE_MENU_DETAILS_DRAW:
      display.clearDisplay();

      display.setTextSize(2);
      display.setTextColor(WHITE);

      display.setCursor(0,0);
      #if USE_TEMP_SENSOR
        display.print(readTempSensor());
        display.setCursor(5,0);
        display.print("C");
      #else
        display.print("BATT");
      #endif

      display.setCursor(0,SECONDROW);
//      display.print((int) getLiPoVoltage(-1));
      display.setCursor(40,SECONDROW);
      display.print("%");
      
      display.setCursor(72,0);
      display.print("C1:");
      display.setCursor(80,0);
//      display.print(getLiPoVoltage(1));
      display.setCursor(115,0);
      display.print("v");
      
      display.setCursor(72,SECONDROW);
      display.print("C2:");
      display.setCursor(80,SECONDROW);
//      display.print(getLiPoVoltage(2));
      display.setCursor(115,SECONDROW);
      display.print("v");

      display.display();

      state--;
    break;

    // ---------------------------------

    case STATE_MENU_CAMERA_ON_DRAW:
      display.clearDisplay();
      display.setCursor(0,0);
      display.print("CAMERA ON");
      display.display();

      state--;
    break;

    case STATE_MENU_CAMERA_ON_SELECTED:
      digitalWrite(PIN_CAMERA_EN, HIGH);
    
      display.clearDisplay(); 
      display.setCursor(0,0);
      display.print("CAMERA ON");
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
      display.setCursor(0,0);
      display.print("CAMERA OFF");
      display.display();

      state--;
    break;

    case STATE_MENU_CAMERA_OFF_SELECTED:
      digitalWrite(PIN_CAMERA_EN, LOW);
    
      display.clearDisplay(); 
      display.setCursor(0,0);
      display.print("CAMERA OFF ...");
      display.display();
      wait(1.0);
  
      state = STATE_MENU_CAMERA_OFF_DRAW;
    break;

    // ---------------------------------

    case STATE_MENU_TAKE_PICTURE_DRAW:
      display.clearDisplay();
      display.setCursor(0,0);
      display.print("RELEASE SHUTTER");
      display.display();

      state--;
    break;

    case STATE_MENU_TAKE_PICTURE_SELECTED:
      takePicture(false);
    
      display.clearDisplay(); 
      display.setCursor(0,0);
      display.print("WAIT");
      display.setCursor(13,0);
      display.print(".");
      display.display();
      wait(0.5);
      display.setCursor(14,0);
      display.print(".");
      display.display();
      wait(0.5);
      display.setCursor(15,0);
      display.print(".");
      display.display();
      wait(0.5);
  
      state = STATE_MENU_TAKE_PICTURE_DRAW;
    break;

    // ---------------------------------
       
    case STATE_MENU_INTERVAL_DRAW: // +1
      display.clearDisplay();
      display.setCursor(0,0);
      display.print("INTERVAL");
      display.setCursor(11,0);
      display.print(optInterval);
      display.display();
      state--;
    break;

    case STATE_MENU_INTERVAL_SELECTED: // +2      
      if (oldArrayPointer != arrayPointer) {
        display.clearDisplay();
        
        display.setCursor(0,1);
        display.print(valuesInterval[arrayPointer]);

        // total Time
        display.setCursor(8,1);
        display.print("T:");
        display.setCursor(10,1);
        display.print(calculateTime(valuesInterval[arrayPointer], optIterations));
        display.display();
        oldArrayPointer = arrayPointer;
      }

      if (buttonUpPressed() && arrayPointer < (sizeof(valuesInterval)/sizeof(valuesInterval[0])) ) {
        arrayPointer++;
      }

      if (buttonUpPressed() && arrayPointer > 0 ) {
        arrayPointer--;
      }
    
      if (buttonXPressed()) {
        optInterval = valuesInterval[arrayPointer];
        state = STATE_MENU_INTERVAL;
        eeprom_saveto();
      }
      
    break;

    // ---------------------------------
         
    case STATE_MENU_ITERATIONS_DRAW: // +1
      display.clearDisplay();
      display.setCursor(0,0);
      display.print("ITERATIONS");
      display.setCursor(11,0);
      display.print(optIterations);
      display.display();
      state--;
    break;

//    
//    case STATE_MENU_ITERATIONS_SELECTED: // +2
//      potiSegment = getPotiPosition(sizeof(valuesIterations)/sizeof(valuesIterations[0]));
//      
//      if (potiSegment != oldPotiSegment) {
//        display.clearDisplay();
//        
//        display.setCursor(0,1);
//        display.print(valuesIterations[potiSegment]);
//
//        // total Time
//        display.setCursor(8,1);
//        display.print("T:");
//        display.setCursor(10,1);
//        display.print(calculateTime(optInterval, valuesIterations[potiSegment]));
//        oldPotiSegment = potiSegment;
//      }
//    
//      if (buttonPressed()) {
//        optIterations = valuesIterations[potiSegment];
//        state = STATE_MENU_ITERATIONS;
//        eeprom_saveto();
//      }
//      
//    break;

    // ---------------------------------

    case STATE_MENU_START_DRAW: // +1
      display.clearDisplay();
      display.setCursor(0,0);
      display.print("START");

      display.setCursor(0,1);
      display.print("T:");
      display.setCursor(2,1);
      display.print(calculateTime(optIterations, optInterval));

      display.setCursor(9,0);
      display.print("N:");
      display.setCursor(11,0);
      display.print(optIterations);

      display.setCursor(9,1);
      display.print("D:");
      display.setCursor(11,1);
      display.print(optInterval);
      display.display();
     
      state--;
    break;

    case STATE_MENU_START_SELECTED: 
      display.clearDisplay();
      display.setCursor(0,0);
      display.print("STARTING in 10s");
      display.display();
      for (int i=9; i>-1; i--) {
        wait(1);
        display.setCursor(12,0);
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

  pinMode(PIN_CAMERA_EN,       OUTPUT);
  pinMode(PIN_ZERO_EN,         OUTPUT);
  pinMode(PIN_EXT_EN,          OUTPUT); 
  pinMode(PIN_DISPLAY_EN,      OUTPUT);
  pinMode(PIN_DISPLAY_RST,     OUTPUT);
   
  pinMode(PIN_PUSHBUTTON_UP,   INPUT); 
  pinMode(PIN_PUSHBUTTON_DOWN, INPUT); 
  pinMode(PIN_PUSHBUTTON_X,    INPUT);  

  pinMode(PIN_CAMERA_FOCUS,    OUTPUT);
  pinMode(PIN_CAMERA_SHUTTER,  OUTPUT);

  pinMode(PIN_TEMP,            INPUT);

  digitalWrite(PIN_DISPLAY_EN, LOW);
  digitalWrite(PIN_CAMERA_EN,  LOW);

}

void initDisplay() {
  // initialize with the I2C addr 0x3C (for the 128x32) 
  display.begin(SSD1306_SWITCHCAPVCC, 0x3C);   
  display.clearDisplay();

  display.setTextSize(1);
  display.setTextColor(WHITE);
  display.setCursor(0,0);
  display.println("Hello, world!");
  display.setTextSize(2);
  display.setTextColor(WHITE);
  display.print("0x"); 
  display.println(0xDEADBEEF, HEX);
  display.display();

//      display.setCursor(0,0);
//      display.print("TIMEBOXGO");
//      display.setCursor(0,1);
//      display.print("version: ");
//      display.setCursor(9,1);
//      display.print(VERSION);
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

int buttonUpPressed() {
  for (int i=0; i<3; i++) {
    if (digitalRead(PIN_PUSHBUTTON_UP)) {
      return false;
    }
    delay(10);
  }

  while(!digitalRead(PIN_PUSHBUTTON_UP)) {}
  delay(10);

  return true;
}

int buttonDownPressed() {
  for (int i=0; i<3; i++) {
    if (digitalRead(PIN_PUSHBUTTON_DOWN)) {
      return false;
    }
    delay(10);
  }

  while(!digitalRead(PIN_PUSHBUTTON_DOWN)) {}
  delay(10);

  return true;
}

int buttonXPressed() {
  for (int i=0; i<3; i++) {
    if (digitalRead(PIN_PUSHBUTTON_X)) {
      return false;
    }
    delay(10);
  }

  while(!digitalRead(PIN_PUSHBUTTON_X)) {}
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
  
  Serial.print("LiPo -1:"); Serial.println(getLiPoVoltage(-1));
  Serial.print("LiPo  0:"); Serial.println(getLiPoVoltage(0));
  Serial.print("LiPo  1:"); Serial.println(getLiPoVoltage(1));
  Serial.print("LiPo  2:"); Serial.println(getLiPoVoltage(2));

  Serial.print("Temp:"); Serial.println(readTempSensor());
 
  Serial.print("ButtonUP  :"); Serial.println(buttonUpPressed());
  Serial.print("ButtonDOWN:"); Serial.println(buttonDownPressed());
  Serial.print("ButtonX   :"); Serial.println(buttonXPressed());
}
