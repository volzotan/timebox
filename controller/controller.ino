#include <JeeLib.h>
#include <Wire.h> 
#include <LiquidCrystal_I2C.h>
#include "constants.h"

ISR(WDT_vect) { Sleepy::watchdogEvent(); }
LiquidCrystal_I2C lcd(0x27,16,2);  

int state = STATE_MENU;
int menu_selected = false;

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
    //lcd.backlight();
    lcd.setCursor(3,0);
    lcd.print("Hello, world!");
    lcd.setCursor(2,1);
    lcd.print("foo");
  #endif
}


void loop() {
  //Serial.println(digitalRead(PIN_PUSHBUTTON));

  #ifdef USE_PHOTOCELL
    digitalWrite(PIN_PHOTOCELL_EN, HIGH);
    delay(100);
    analogRead(PIN_PHOTOCELL);
    delay(10);
    Serial.println(analogRead(PIN_PHOTOCELL));
    delay(10);
    digitalWrite(PIN_PHOTOCELL_EN, LOW);
  #endif

  wait(2);
}

void initButtons() {
  pinMode(PIN_DISPLAY_EN,     OUTPUT);  
  pinMode(PIN_PHOTOCELL_EN,   OUTPUT);  
  
  pinMode(PIN_PHOTOCELL,      INPUT);  
  pinMode(PIN_POTENTIOMETER,  INPUT);  
  pinMode(PIN_PUSHBUTTON,     INPUT);    
}

void takePicture() {
  digitalWrite(PIN_CAMERA_HIGHSIDE, HIGH);
  
  wait(PRE_TRIGGER_WAIT);
  
  digitalWrite(PIN_CAMERA_SHUTTER, HIGH);
  delay(100);
  digitalWrite(PIN_CAMERA_SHUTTER, LOW);

  wait(POST_TRIGGER_WAIT);

  digitalWrite(PIN_CAMERA_HIGHSIDE, LOW);
}

void wait(byte seconds) {
    for (byte i = 0; i < seconds; ++i) {
      Sleepy::loseSomeTime(1000);
  }
}
