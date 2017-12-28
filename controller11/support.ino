
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
  
  pinMode(PIN_LED,             OUTPUT);

  pinMode(PIN_EXT1,            OUTPUT);
  pinMode(PIN_EXT2,            OUTPUT);
  pinMode(PIN_EXT3,            OUTPUT);

  digitalWrite(PIN_ZERO_EN,    LOW);
  digitalWrite(PIN_CAMERA_EN,  LOW);
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

void ledShow(int r, int g, int b) {
  neopixel.setPixelColor(0, neopixel.Color(r,g,b));
  neopixel.show(); 

  ledIterations = -1;
  ledTimer = -1;

  if (r + g + b > 0) {
    ledOn = true;
  } else {
    ledOn = false;
  }
}

void ledBlink(int r, int g, int b, int iterations, int duration) {
  ledShow(r, g, b);
  ledOn = true;
  
  ledColor[0] = r; ledColor[1] = g; ledColor[2] = b;
  ledIterations = iterations;
  ledTimer = millis() + duration;
}

void ledLoop() {
  if ((ledTimer > 0) && (millis() > ledTimer)) {
    
    if (ledIterations > 0) {
      ledTimer = millis() + ledDuration; 
    } else {
      ledTimer = -1;
      return;
    }
    
    if (ledOn) {
      neopixel.setPixelColor(0, neopixel.Color(0, 0, 0));
      ledOn = false;
      ledIterations -= 1;    
    } else {
      neopixel.setPixelColor(0, neopixel.Color(ledColor[0], ledColor[1], ledColor[2]));
      ledOn = true;
    }

    neopixel.show(); 
  }
}

void wait(float seconds) {

  #ifdef DEBUG
    for (int i = 0; i < (int) seconds; ++i) {
      delay(1000);
      Serial.println("> sleep");
    }
    return;
  #endif
  
  for (int i = 0; i < (int) seconds; ++i) {
    Sleepy::loseSomeTime(1000);
  }

  Sleepy::loseSomeTime((int) ((seconds - ((int) seconds)) * 1000));
}

// -------------------------------- MISC -------------------------------- //

// -------------------------------- OPERATIONS -------------------------------- //

void switchZeroOn(boolean switchOn) {
  if (switchOn) {
    digitalWrite(PIN_ZERO_EN, HIGH);
  } else {
    digitalWrite(PIN_ZERO_EN, LOW);  
  }
}

void switchCameraOn(boolean switchOn) {
  if (switchOn) {
    digitalWrite(PIN_CAMERA_EN, HIGH);
  } else {
    digitalWrite(PIN_CAMERA_EN, HIGH);  
  }
}

// -------------------------------- BATTERY -------------------------------- //

boolean checkBattHealth() {
  float c0 = 0;
  float c1 = 0;
  float c2 = 0;

    c0 = getLiPoVoltage(BATT_DIRECT);

    if (c0 < 1.0) {
      DEBUG_PRINT(F("Batt Health: not connected"));
      delay(100);
      // whatever. probably USB powered.
      return true;
    }

    if (c0 > 1.0 && c0 < LIPO_CELL_MIN*2) {
      DEBUG_PRINT(F("Battery voltage below threshold!"));
      DEBUG_PRINT(String(c0));
      
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

  for (int i=0; i<1; i++) {
    acc += getLiPoVoltageRaw(cell);
    //delay(1);  
  }

  return acc/1.0; 
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
