#include <Wire.h>
#include <Adafruit_INA219.h>
#include <Adafruit_INA260.h>

Adafruit_INA219 ina219 = Adafruit_INA219();
Adafruit_INA260 ina260 = Adafruit_INA260();

float busvoltage = 0;
float shuntvoltage = 0;
float loadvoltage = 0;
float current = 0;
float power = 0;

int counter = 0;

void setup(void) {
    
    Serial.begin(115200);
  
    // Initialize the INA219.
    // By default the initialization will use the largest range (32V, 2A).  However
    // you can call a setCalibration function to change this range (see comments).
    // To use a slightly lower 32V, 1A range (higher precision on amps):
    //ina219.setCalibration_32V_1A();
    // Or to use a lower 16V, 400mA range (higher precision on volts and amps):
    //ina219.setCalibration_16V_400mA();

    // ina219.begin();

    ina260.begin();
    ina260.setAveragingCount(INA260_COUNT_16);
}

void loop() {

    // busvoltage = ina219.getBusVoltage_V();
    // shuntvoltage = ina219.getShuntVoltage_mV();
    // current = ina219.getCurrent_mA();
    // loadvoltage = busvoltage + (shuntvoltage / 1000);

    busvoltage = ina260.readBusVoltage();
    current = ina260.readCurrent();
    power = ina260.readPower();

    Serial.print(counter);
    Serial.print(" ");
    Serial.print(busvoltage); 
    Serial.print(" ");
    Serial.print(current);
    Serial.print(" ");
    Serial.print(power);
  
    Serial.println("");
  
    counter++;

    delay(10);
}
