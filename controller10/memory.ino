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
  writeEEPROM(EEPROM_IN_USAGE, 1);
  
  eeprom_write2ByteValue(programMode,               EEPROM_PROGRAM_MODE,        EEPROM_PROGRAM_MODE+1);
  eeprom_write2ByteValue(optInterval,               EEPROM_INTERVAL,            EEPROM_INTERVAL+1);
  eeprom_write2ByteValue(optIterations,             EEPROM_ITERATIONS,          EEPROM_ITERATIONS+1);
  eeprom_write2ByteValue(directBootWait,            EEPROM_DIRECT_BOOT_WAIT,    EEPROM_DIRECT_BOOT_WAIT+1);
  eeprom_write2ByteValue(directUptime,              EEPROM_DIRECT_UPTIME,       EEPROM_DIRECT_UPTIME+1);
  eeprom_write2ByteValue(zeroBootWait,              EEPROM_ZERO_BOOT_WAIT,      EEPROM_ZERO_BOOT_WAIT+1);
  eeprom_write2ByteValue(zeroUptime,                EEPROM_ZERO_UPTIME,         EEPROM_ZERO_UPTIME+1);
}

void eeprom_reset() {
  writeEEPROM(EEPROM_IN_USAGE, 1);

  eeprom_write2ByteValue(DEFAULT_PROGRAM_MODE,      EEPROM_PROGRAM_MODE,        EEPROM_PROGRAM_MODE+1);
  eeprom_write2ByteValue(DEFAULT_INTERVAL,          EEPROM_INTERVAL,            EEPROM_INTERVAL+1);
  eeprom_write2ByteValue(DEFAULT_ITERATIONS,        EEPROM_ITERATIONS,          EEPROM_ITERATIONS+1);
  eeprom_write2ByteValue(DEFAULT_DIRECT_BOOT_WAIT,  EEPROM_DIRECT_BOOT_WAIT,    EEPROM_DIRECT_BOOT_WAIT+1);
  eeprom_write2ByteValue(DEFAULT_DIRECT_UPTIME,     EEPROM_DIRECT_UPTIME,       EEPROM_DIRECT_UPTIME+1);
  eeprom_write2ByteValue(DEFAULT_ZERO_BOOT_WAIT,    EEPROM_ZERO_BOOT_WAIT,      EEPROM_ZERO_BOOT_WAIT+1);
  eeprom_write2ByteValue(DEFAULT_ZERO_UPTIME,       EEPROM_ZERO_UPTIME,         EEPROM_ZERO_UPTIME+1);
}

int initFromEEPROM() {
  if (readEEPROM(EEPROM_IN_USAGE) <= 0) {
    return 1;  
  }
  
  programMode           = eeprom_read2ByteValue(    EEPROM_PROGRAM_MODE,        EEPROM_PROGRAM_MODE+1);
  optInterval           = eeprom_read2ByteValue(    EEPROM_INTERVAL,            EEPROM_INTERVAL+1);
  optIterations         = eeprom_read2ByteValue(    EEPROM_ITERATIONS,          EEPROM_ITERATIONS+1);
  directBootWait        = eeprom_read2ByteValue(    EEPROM_DIRECT_BOOT_WAIT,    EEPROM_DIRECT_BOOT_WAIT+1);
  directUptime          = eeprom_read2ByteValue(    EEPROM_DIRECT_UPTIME,       EEPROM_DIRECT_UPTIME+1);
  zeroBootWait          = eeprom_read2ByteValue(    EEPROM_ZERO_BOOT_WAIT,      EEPROM_ZERO_BOOT_WAIT+1);
  zeroUptime            = eeprom_read2ByteValue(    EEPROM_ZERO_UPTIME,         EEPROM_ZERO_UPTIME+1);

  return 0;
}

void initPrint(CommunicationInterface ser) {
  ser.port->print("    ");
  ser.port->print("programMode");
  ser.port->print(": ");
  ser.port->println(programMode);
  
  ser.port->print("    ");
  ser.port->print("optInterval");
  ser.port->print(": ");
  ser.port->println(optInterval);
  
  ser.port->print("    ");
  ser.port->print("optIterations");
  ser.port->print(": ");
  ser.port->println(optIterations);
  
  ser.port->print("    ");
  ser.port->print("directBootWait");
  ser.port->print(": ");
  ser.port->println(directBootWait);
  
  ser.port->print("    ");
  ser.port->print("directUptime");
  ser.port->print(": ");
  ser.port->println(directUptime);
  
  ser.port->print("    ");
  ser.port->print("zeroBootWait");
  ser.port->print(": ");
  ser.port->println(zeroBootWait);
  
  ser.port->print("    ");
  ser.port->print("zeroUptime");
  ser.port->print(": ");
  ser.port->println(zeroUptime);  
}

void eeprom_clear() {
  for (int i = 0; i < 512; i++) {
    writeEEPROM(i, 255);
  }
}

void eeprom_print(CommunicationInterface ser, unsigned int start, unsigned int end) { // debug
  int ext_read = 0;

  for (unsigned int i=start; i<end; i++) {
    ext_read = readEEPROM(i);

    if (i < 100) {
      ser.port->print(" "); 
      if (i < 10) ser.port->print(" "); 
    } 
    ser.port->print(i);
    ser.port->print(" "); 
    ser.port->print(ext_read, BIN);
    ser.port->print(" "); 
    ser.port->print(ext_read, HEX);  
    ser.port->print(" "); 
    ser.port->print(ext_read, DEC); 
    ser.port->println();
  }
}

