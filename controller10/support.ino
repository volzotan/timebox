
// --------------------------------   MISC   -------------------------------- //

int buttonPressed(int button) {
  for (int i = 0; i < 3; i++) {
    if (digitalRead(button)) {
      return false;
    }
    delay(10);
  }

  while (!digitalRead(button)) {}
  delay(10);

  return true;
}

void initPins() {

  pinMode(PIN_BATT_DIRECT,     INPUT);

  pinMode(PIN_ZERO_EN,         OUTPUT);
  pinMode(PIN_CAMERA_EN,       OUTPUT);

  pinMode(PIN_BUTTON,          INPUT);

  pinMode(PIN_CAM1,            OUTPUT);
  pinMode(PIN_CAM2,            OUTPUT);
  pinMode(PIN_CAM3,            OUTPUT);
  pinMode(PIN_CAM4,            OUTPUT);
  
  pinMode(PIN_LED,             OUTPUT);

  pinMode(PIN_EXT1,            OUTPUT);
  pinMode(PIN_EXT2,            OUTPUT);
  pinMode(PIN_EXT3,            OUTPUT);

  digitalWrite(PIN_ZERO_EN,    LOW);
  digitalWrite(PIN_CAMERA_EN,  LOW);
  
//  pinMode(PIN_DISPLAY_EN,      OUTPUT);
//  pinMode(PIN_DISPLAY_RST,     OUTPUT);
//  digitalWrite(PIN_DISPLAY_EN, HIGH);
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

int lastIndexOf(const char * s, char target)
{
   int ret = -1;
   int curIdx = 0;
   while(s[curIdx] != '\0')
   {
      if (s[curIdx] == target) ret = curIdx;
      curIdx++;
   }
   return ret;
}

void wait(float seconds) {

  #ifdef DEBUG
    for (int i = 0; i < (int) seconds; ++i) {
      delay(500);
      delay(500);
      Serial.println("sleep");
    }
    return;
  #endif
  
  for (int i = 0; i < (int) seconds; ++i) {
    Sleepy::loseSomeTime(1000);
  }

  Sleepy::loseSomeTime((int) ((seconds - ((int) seconds)) * 1000));
}

// -------------------------------- OPERATIONS -------------------------------- //

void switchZeroOn(boolean switchOn) {
  if (switchOn) {
    digitalWrite(PIN_ZERO_EN, HIGH);
  } else {
    digitalWrite(PIN_ZERO_EN, HIGH);  
  }
}


//void switchDisplayOn(boolean switchOn) {
//  if (switchOn) {
//    digitalWrite(PIN_DISPLAY_EN, HIGH);
//  } else {
//    digitalWrite(PIN_DISPLAY_EN, HIGH);  
//  }
//}


void switchCameraOn(boolean switchOn) {
  if (switchOn) {
    digitalWrite(PIN_CAMERA_EN, HIGH);
  } else {
    digitalWrite(PIN_CAMERA_EN, HIGH);  
  }
}


// -------------------------------- DISPLAY -------------------------------- //

//void initDisplay() {
//  display.begin(SSD1306_SWITCHCAPVCC, 0x3C);
//  display.clearDisplay();
//
//  display.setTextColor(WHITE);
//  display.setTextSize(2);
//
//  display.setCursor(0,0);
//  display.print(F("TIMEBOXGO"));
//
//  display.setTextSize(2);
//  display.setCursor(0,SECONDROW);
//  display.print(F("v: "));
//  display.setCursor(64,SECONDROW);
//  display.print(VERSION);
//
//  display.display();
//}
//
//void displayOn(boolean state) {
//  if (state) {
//    digitalWrite(PIN_DISPLAY_EN, LOW);
//  } else {
//    display.clearDisplay();
//    display.display();
//    digitalWrite(PIN_DISPLAY_EN, HIGH);
//  }
//}

// -------------------------------- BATTERY -------------------------------- //

boolean checkBattHealth() {
  float c0 = 0;
  float c1 = 0;
  float c2 = 0;


    c0 = getLiPoVoltage(BATT_DIRECT);

    if (c0 < 1.0) {
      Serial.println(F("Batt Health: not connected"));
      delay(100);
      // whatever. probably USB powered.
      return true;
    }

    if (c0 > 1.0 && c0 < LIPO_CELL_MIN*2) {
      Serial.print(F("Battery voltage below threshold! ["));
      Serial.print(String(c0));
      Serial.println("]");
      
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

  for (int i=0; i<10; i++) {
    acc += getLiPoVoltageRaw(cell);
    delay(1);  
  }

  return acc/10.0; 
}

float getLiPoVoltageRaw(int cell) {
  switch (cell) {
    case BATT_DIRECT: // whole battery
      return voltageDivider((float) analogRead(PIN_BATT_DIRECT));
      break;

    case BATT_PERCENTAGE_DIRECT: // percentage loaded

      // There is a bug here... (maybe)
    
      if (voltageDivider((float) analogRead(PIN_BATT_DIRECT)) > 1.0) {
        return (getLiPoVoltage(BATT_DIRECT) - LIPO_CELL_MIN * 2) / (((LIPO_CELL_MAX - LIPO_CELL_MIN) * 2) / 100);
      } else {
        return -1;  
      }
      break;

    default:
      return -1;
      break;
  }
}
