
// --------------------------------   MISC   -------------------------------- //

void selftest() {
  Serial.print(F("BATT: "));
  Serial.print(getLiPoVoltage(BATT_DIRECT));
  Serial.print(F("v "));

  Serial.print(F("BUTTON: "));
  Serial.print(buttonPressed(BTN_UP));
  Serial.print(buttonPressed(BTN_DOWN));
  Serial.print(buttonPressed(BTN_LEFT));
  Serial.print(buttonPressed(BTN_RIGHT));
  Serial.print(buttonPressed(BTN_CENTER));
  Serial.print(F(" "));
  
  Serial.println();
}

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

void initButtons() {

  pinMode(PIN_CELL_1,          INPUT);
  pinMode(PIN_CELL_2,          INPUT);
  pinMode(PIN_BATT_DIRECT,     INPUT);

  pinMode(PIN_CAMERA_EN,       OUTPUT);
  pinMode(PIN_ZERO_EN,         OUTPUT);
  pinMode(PIN_DISPLAY_EN,      OUTPUT);
  pinMode(PIN_DISPLAY_RST,     OUTPUT);

  pinMode(PIN_PUSHBUTTON_UP,   INPUT);
  pinMode(PIN_PUSHBUTTON_DOWN, INPUT);
  pinMode(PIN_PUSHBUTTON_LEFT, INPUT);
  pinMode(PIN_PUSHBUTTON_RIGHT,INPUT);
  pinMode(PIN_PUSHBUTTON_CENTER,INPUT);

  pinMode(PIN_CAMERA_FOCUS,    OUTPUT);
  pinMode(PIN_CAMERA_SHUTTER,  OUTPUT);

  digitalWrite(PIN_CAMERA_EN,  LOW);
  digitalWrite(PIN_DISPLAY_EN, HIGH);

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

void wait(float seconds) {
  for (int i = 0; i < (int) seconds; ++i) {
    Sleepy::loseSomeTime(1000);
  }

  Sleepy::loseSomeTime((int) ((seconds - ((int) seconds)) * 1000));
}

// -------------------------------- DISPLAY -------------------------------- //

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

// -------------------------------- BATTERY -------------------------------- //

boolean checkBattHealth() {
  float c0 = 0;
  float c1 = 0;
  float c2 = 0;

  if (BALANCER_NOT_CONNECTED) {
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
  } else {
    float c1 = getLiPoVoltage(BATT_CELL_1);
    float c2 = getLiPoVoltage(BATT_CELL_2);
    
    if (c1 < 1.0 || c2 < 1.0) {
      Serial.println("Batt Health Balancer: not connected");
      delay(100);
      return true;
    }

    if (c1 < LIPO_CELL_MIN || c2 < LIPO_CELL_MIN) {
      Serial.print(F("LiPo voltage below threshold! [c1:"));
      Serial.print(c1);
      Serial.print(" | c2:");
      Serial.print(c2);
      Serial.println("]");
      delay(100);
      return false;
    }  
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
    case BATT_DIRECT: // whole battery
      return voltageDivider((float) analogRead(PIN_BATT_DIRECT));
      break;

    case BATT_ALL:
      return abs(voltageDivider((float) analogRead(PIN_CELL_2)));
      break;

    case BATT_CELL_1: // cell 1
      return abs(voltageDivider((float) analogRead(PIN_CELL_1)));
      break;

    case BATT_CELL_2: // cell 2
      return abs(voltageDivider((float) analogRead(PIN_CELL_2)) - voltageDivider((float) analogRead(PIN_CELL_1)));
      break;

    case BATT_PERCENTAGE: // percentage loaded
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
