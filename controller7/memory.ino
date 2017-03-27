void writeEEPROM(unsigned int eeaddress, byte data) {
  EEPROM.write(eeaddress, data);
}

byte readEEPROM(unsigned int eeaddress) {
  return EEPROM.read(eeaddress);
}

void eeprom_writeByteValue(boolean var, int pos) {
  writeEEPROM(pos, var);
}

void eeprom_write2ByteValue(int var, int startpos, int endpos) {
  int bitmask = 255;
  int i = 0;
  int j = 0;

  i = var >> 8;
  j = var & bitmask;
  writeEEPROM(startpos, i);
  writeEEPROM(endpos, j);
}

boolean eeprom_readByteValue(int pos) {
  boolean value = readEEPROM(pos);
  return value;
}

unsigned int eeprom_read2ByteValue(int startpos, int endpos) {
  int i = 0;
  int j = 0;
  int value;

  i = readEEPROM(startpos); 
  j = readEEPROM(endpos);
  value = (i << 8) + j;

  return value;
}

void eeprom_saveto() {
  eeprom_write2ByteValue(optInterval, EEPROM_INTERVAL, EEPROM_INTERVAL+1);
  eeprom_write2ByteValue(optIterations, EEPROM_ITERATIONS, EEPROM_ITERATIONS+1);
}

void eeprom_reset() {
  eeprom_write2ByteValue(INTERVAL_DEFAULT_VAL, EEPROM_INTERVAL, EEPROM_INTERVAL+1);
  eeprom_write2ByteValue(ITERATIONS_DEFAULT_VAL, EEPROM_ITERATIONS, EEPROM_ITERATIONS+1);
}

int initFromEEPROM() {
  optInterval = eeprom_read2ByteValue(EEPROM_INTERVAL, EEPROM_INTERVAL+1);
  optIterations = eeprom_read2ByteValue(EEPROM_ITERATIONS, EEPROM_ITERATIONS+1);
}

void eeprom_clear() {
  for (int i = 0; i < 512; i++) {
    writeEEPROM(i, 255);
  }
}

void eeprom_print(unsigned int start, unsigned int end) { // debug
  int ext_read = 0;

  for (unsigned int i=start; i<end; i++) {
    ext_read = readEEPROM(i);

    if (i < 100) {
      Serial.print(" "); 
      if (i < 10) Serial.print(" "); 
    } 
    Serial.print(i);
    Serial.print(" "); 
    Serial.print(ext_read, BIN);
    Serial.print(" "); 
    Serial.print(ext_read, HEX);  
    Serial.print(" "); 
    Serial.print(ext_read, DEC); 
    Serial.println();
  }
}

