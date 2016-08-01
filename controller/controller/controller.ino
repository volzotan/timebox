#include <Wire.h> 
#include <LiquidCrystal_I2C.h>

#define PIN_DISPLAY_EN          9
#define PIN_THERM_EN
#define PIN_CAMERA_EN
#define PIN_POTENTIOMETER       6
#define PIN_PUSHBUTTON          7

// OPTIONS

#define USE_DISPLAY


LiquidCrystal_I2C lcd(0x27,20,4);  // set the LCD address to 0x27 for a 16 chars and 2 line display


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
    lcd.setCursor(0,2);
    lcd.print("bar");
    lcd.setCursor(2,3);
    lcd.print("foobar");
  #endif
}


void loop() {
  Serial.println(digitalRead(PIN_PUSHBUTTON));
//  delay(3000);
//  digitalWrite(9, LOW);
//    delay(3000);
//      digitalWrite(9, HIGH);
//    
}

void initButtons() {
  pinMode(PIN_DISPLAY_EN,     OUTPUT);  
  pinMode(PIN_POTENTIOMETER,  INPUT);  
  pinMode(PIN_PUSHBUTTON,     INPUT);    
}
