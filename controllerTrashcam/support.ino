
// --------------------------------   MISC   -------------------------------- //

int buttonPressed(int button) {
    for (int i = 0; i < 10; i++) {
        if (!digitalRead(button)) {
            return false;
        }
        delay(10);
    }

    while (digitalRead(button)) {}
    delay(10);

    return true;
}

void initPins() {
    // analogReference(AR_DEFAULT); // SAMD21 internal reference 3.3v

    // TODO:
    // Another approach is to measure the internal 1.1V reference with respect to AVCC/VCC. Since you already know the internal reference (1.082V), 
    // you just turn the equation around and solve for VCC. Further still you can now use your calculated VCC as a reliable reference for your other 
    // ADC inputs irrespective of battery voltage. For AtMega328, the 1.1V reference can be selected as analog channel 14.

    pinMode(PIN_BATT_DIRECT,     INPUT);
    pinMode(PIN_BUTTON,          INPUT);  
    pinMode(PIN_ZERO_FAULT,      INPUT);  

    pinMode(PIN_ZERO_EN,         OUTPUT);
    pinMode(PIN_PIXEL,           OUTPUT);
    pinMode(PIN_SERVO,           OUTPUT);

    #ifdef HOST_DEFAULT_POWERED_ON
        digitalWrite(PIN_ZERO_EN, HIGH);
    #else
        digitalWrite(PIN_ZERO_EN, LOW);
    #endif
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

int lastIndexOf(const char * s, char target) {
    int ret = -1;
    int curIdx = 0;
    while(s[curIdx] != '\0') {
        if (s[curIdx] == target) ret = curIdx;
        curIdx++;
    }
    return ret;
}

long getMillis() {
    return rtc.getY2kEpoch() * 1000L;
}

void wait() {

    #ifdef DEEP_SLEEP

        int s = rtc.getSeconds() + 1;
        s = s % 60;
        rtc.setAlarmSeconds(s);

        rtc.attachInterrupt(alarmFired);
        rtc.enableAlarm(rtc.MATCH_SS);
        delay(10);
        rtc.standbyMode();

        rtc.disableAlarm();
        DEBUG_PRINT("> wakeup");

    #else 

        delay(1000);
        DEBUG_PRINT("> sleep");
        
        alarmFired();

    #endif
}

void switchZeroOn(boolean switchOn) {
    if (switchOn) {
        digitalWrite(PIN_ZERO_EN, HIGH);
    } else {
        digitalWrite(PIN_ZERO_EN, LOW);  
    }
}

void led(int r, int g, int b) {
    pixels.setPixelColor(0, pixels.Color(r, g, b));
    pixels.show();
}

// -------------------------------- BATTERY -------------------------------- //

boolean checkBattHealth() {

    float c0 = getBatteryVoltage();

    if (c0 < 2.0) {
        DEBUG_PRINT("Batt Health: not connected");
        delay(100);
        // whatever. probably USB powered.
        return true;
    }

    if (c0 > 2.0 && c0 < LIPO_CELL_MIN * LIPO_CELL_NUM) {
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

float getBatteryPercentage() {
    // discard first measurement
    analogRead(PIN_BATT_DIRECT);

    float voltage = voltageDivider((float) analogRead(PIN_BATT_DIRECT));

    if (voltage > 1.0) {
        return (voltage - LIPO_CELL_MIN * LIPO_CELL_NUM) / (((LIPO_CELL_MAX - LIPO_CELL_MIN) * LIPO_CELL_NUM) / 100.0);
    } else {
        return -1;  
    }
}

float getBatteryVoltage() {
    // discard first measurement
    analogRead(PIN_BATT_DIRECT);

    return voltageDivider((float) analogRead(PIN_BATT_DIRECT));
}
