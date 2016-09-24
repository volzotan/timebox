#include <Wire.h>
#include <Adafruit_INA219.h>

Adafruit_INA219 ina219;

int counter = 0;

void setup(void) 
{
  while (!Serial);     // will pause Zero, Leonardo, etc until serial console opens

  uint32_t currentFrequency;
    
  Serial.begin(9600);
  
  // Initialize the INA219.
  // By default the initialization will use the largest range (32V, 2A).  However
  // you can call a setCalibration function to change this range (see comments).
  ina219.begin();
  // To use a slightly lower 32V, 1A range (higher precision on amps):
  //ina219.setCalibration_32V_1A();
  // Or to use a lower 16V, 400mA range (higher precision on volts and amps):
  //ina219.setCalibration_16V_400mA();
}

void loop(void) {
  counter++;
  
  float shuntvoltage = 0;
  float busvoltage = 0;
  float current_mA = 0;
  float loadvoltage = 0;

  shuntvoltage = ina219.getShuntVoltage_mV();
  busvoltage = ina219.getBusVoltage_V();
  current_mA = ina219.getCurrent_mA();
  loadvoltage = busvoltage + (shuntvoltage / 1000);

  Serial.print(counter);
  Serial.print(" ");
  Serial.print(busvoltage); 
  Serial.print(" ");
  Serial.print(shuntvoltage);
  Serial.print(" ");
  Serial.print(loadvoltage);
  Serial.print(" ");
  Serial.print(current_mA);
  
  Serial.println("");
  
//  Serial.print("Bus Voltage:   "); Serial.print(busvoltage); Serial.println(" V");
//  Serial.print("Shunt Voltage: "); Serial.print(shuntvoltage); Serial.println(" mV");
//  Serial.print("Load Voltage:  "); Serial.print(loadvoltage); Serial.println(" V");
//  Serial.print("Current:       "); Serial.print(current_mA); Serial.println(" mA");
//  Serial.println("");

  delay(1000);
}
