
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
  analogReference(EXTERNAL);

  // TODO:
  // Another approach is to measure the internal 1.1V reference with respect to AVCC/VCC. Since you already know the internal reference (1.082V), 
  // you just turn the equation around and solve for VCC. Further still you can now use your calculated VCC as a reliable reference for your other 
  // ADC inputs irrespective of battery voltage. For AtMega328, the 1.1V reference can be selected as analog channel 14.

  pinMode(PIN_BATT_DIRECT,     INPUT);

  pinMode(PIN_ZERO_EN,         OUTPUT);
  pinMode(PIN_CAMERA_EN,       OUTPUT);

  pinMode(PIN_BUTTON,          INPUT);

  pinMode(PIN_CAM_FOCUS,       OUTPUT);
  pinMode(PIN_CAM_SHUTTER,     OUTPUT);
  
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
}

void wait(float seconds) {

  #ifndef DEEP_SLEEP
    for (int i = 0; i < (int) seconds; ++i) {
      delay(1000);
      DEBUG_PRINT("> sleep");
    }
    return;
  #endif
  
  for (int i = 0; i < (int) seconds; ++i) {
    Sleepy::loseSomeTime(1000);
  }

  Sleepy::loseSomeTime((int) ((seconds - ((int) seconds)) * 1000));
}

// -------------------------------- OPERATIONS -------------------------------- //

void switchCameraOn(boolean switchOn) {
  if (switchOn) {
    digitalWrite(PIN_CAMERA_EN, HIGH);
  } else {
    digitalWrite(PIN_CAMERA_EN, LOW);  
  }
}

// -------------------------------- BATTERY -------------------------------- //

boolean checkBattHealth() {
  float c0 = 0;
  float c1 = 0;
  float c2 = 0;

    c0 = getLiPoVoltage(BATT_DIRECT);

    if (c0 < 1.0) {
      DEBUG_PRINT("Batt Health: not connected");
      delay(100);
      // whatever. probably USB powered.
      return true;
    }

    if (c0 > 1.0 && c0 < LIPO_CELL_MIN*2) {
      DEBUG_PRINT("Battery voltage below threshold!");
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

    // analog value on pin
    case BATT_VD_RAW:
      return analogRead(PIN_BATT_DIRECT);
      break;

    // voltage for whole battery
    case BATT_DIRECT:
      return voltageDivider((float) analogRead(PIN_BATT_DIRECT));
      break;

    // percentage battery full
    case BATT_PERCENTAGE_DIRECT: 

      // There is a bug here... (maybe)
    
      if (voltageDivider((float) analogRead(PIN_BATT_DIRECT)) > 1.0) {
        return (getLiPoVoltage(BATT_DIRECT) - LIPO_CELL_MIN * 2) / (((LIPO_CELL_MAX - LIPO_CELL_MIN) * 2) / 100.0);
      } else {
        return -1;  
      }
      break;

    default:
      return -1;
      break;
  }
}
