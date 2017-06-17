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
      int spacePos = strchr(ser.inputBuffer, " ")-ser.inputBuffer;
      ser.port->println(spacePos);

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
      if (spacePos > 0 && spacePos != ser.serialInputString.lastIndexOf(" ")) { // TODO: String wrong
        errorSerial(ERRORCODE_INVALID_MESSAGE, ser);
        return;
      }

      ser.serialCommand = ser.inputBuffer[0];  
      ser.port->println(ser.serialCommand);
      
      if (spacePos > 0) {        
        ser.serialParam = ser.serialInputString.substring(spacePos+1).toInt();
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
      ser.port->print(getLiPoVoltage(BATT_CELL_1)); 
      ser.port->print(" ");
      ser.port->print(getLiPoVoltage(BATT_CELL_2));
      ser.port->print(" ");
      ser.port->print(getLiPoVoltage(BATT_DIRECT));
      ser.port->print(" ");
      ser.port->println(getLiPoVoltage(BATT_PERCENTAGE_DIRECT));
      break;
    case 'S': // Shutdown 
      // TODO
      ser.port->println("K"); 
      break;
    case 'T': // Time 
      errorSerial(ERRORCODE_NOT_AVAILABLE, ser); // TODO
      break;    
    default:
      errorSerial(ERRORCODE_UNKNOWN_CMD, ser);
  }  
  
}

void resetSerial(CommunicationInterface ser) {
  ser.inputBuffer[0] = '\0';
  
  ser.serialCommand = 0;
  ser.serialParam = 0;
}

void errorSerial(int errcode, CommunicationInterface ser) {
  resetSerial(ser);
  
  ser.port->print("E ");
  ser.port->println(errcode);
}
