/* Commandlist
 *  
 *  B  ---  Battery
 *  -1.00 -1.00 8.00 80%
 *  cell1 cell2 direct percentage
 *  
 *  
 *  S  ---  Shutdown  // maybe add delay time?  S 10 for example?
 *  R  ---  Reboot    // maybe add delay time?  S 10 for example?
 *  T  ---  Time
 *  C  ---  Camera On
 *  E  ---  Print EEPROM
 *  
 *  [...]
 */



void serialEvent() {
  
  while (Serial.available()) {
    char inChar = (char) Serial.read();
    processCommand(inChar, ser0);
  }

  while (Serial1.available()) {
    char inChar = (char) Serial1.read();
    processCommand(inChar, ser1);
  }
}

void processCommand(char inChar, CommunicationInterface ser) {
    // Buffer size exceeded
    if (strlen(ser.inputBuffer) > 99) {
      errorSerial(ERRORCODE_MESSAGE_TOO_LONG, ser);
      return;
    }
  
    if (inChar == '\n') {
      int spacePos = strchr(ser.inputBuffer, ' ')-ser.inputBuffer;

      // sanity checks

      // empty
      if (strlen(ser.inputBuffer) < 1) {
        errorSerial(ERRORCODE_MESSAGE_EMPTY, ser);
        return;
      }

      // space on wrong pos / cmd longer than one char
      if (spacePos > 0 && spacePos != 1) {
        errorSerial(ERRORCODE_INVALID_MESSAGE, ser);
        return;
      }

      // double space
      if (spacePos > 0 && spacePos != lastIndexOf(ser.inputBuffer, ' ')) {
        errorSerial(ERRORCODE_INVALID_MESSAGE, ser);
        return;
      }

      // everything ok:

      ser.serialCommand = ser.inputBuffer[0];  
      ser.port->println(ser.serialCommand);
      
      if (spacePos > 0) {        
        sscanf(ser.inputBuffer, "%*s %d", &ser.serialParam);
        ser.port->print("-->");
        ser.port->println(ser.serialParam);
      }
      
      executeCommand(ser);
      resetSerial(ser);
    } else {
      int len = strlen(ser.inputBuffer);
      
      ser.inputBuffer[len] = inChar; 
      ser.inputBuffer[len+1] = '\0';  
    }  
}

void executeCommand(CommunicationInterface ser) {
  switch(ser.serialCommand) {
    
    case 'B': // Battery Health
      ser.port->print("K ");
      ser.port->print(getLiPoVoltage(BATT_CELL_1)); 
      ser.port->print(" ");
      ser.port->print(getLiPoVoltage(BATT_CELL_2));
      ser.port->print(" ");
      ser.port->print(getLiPoVoltage(BATT_DIRECT));
      ser.port->print(" ");
      ser.port->println(getLiPoVoltage(BATT_PERCENTAGE_DIRECT));
      break;
      
    case 'S': // Shutdown 
      if (ser.serialParam > 0) {
        zeroShutdownTimer = millis();
        zeroShutdownTimer += ser.serialParam * 1000; 
      } else {
        switchZeroOn(false);  
        zeroShutdownTimer = -1;
      }
      
      okSerial(ser);
      break;
      
    case 'T': // Time 
      errorSerial(ERRORCODE_NOT_AVAILABLE, ser);
      break;    

    case 'C': // Camera On 
      if (ser.serialParam == 0) {
        switchCameraOn(false);
        okSerial(ser);
      } else if (ser.serialParam == 1) {
        switchCameraOn(true);
        okSerial(ser);
      } else {
        errorSerial(ERRORCODE_INVALID_PARAM, ser);
      }
      break; 

    case 'E': // Print EEPROM
      eeprom_print(ser, 0, 512);
      break; 
      
    default:
      errorSerial(ERRORCODE_UNKNOWN_CMD, ser);
  }  

  // method returns and serial is reset
}

void resetSerial(CommunicationInterface ser) {
  ser.inputBuffer[0] = '\0';
  
  ser.serialCommand = 0;
  ser.serialParam = -1;
}

void errorSerial(int errcode, CommunicationInterface ser) {
  resetSerial(ser);
  ser.port->print("E ");
  ser.port->println(errcode);
}

void okSerial(CommunicationInterface ser) {
  ser.port->print("K");
}
