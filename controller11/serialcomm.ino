/* Commandlist
 *  
 *  B  ---  Battery
 *  -1.00 -1.00 8.00 80
 *  cell1 cell2 direct percentage
 *  
 *  O  ---  Turn Zero On
 *  S  ---  Shutdown [delay in seconds]
 *  R  ---  Reboot    // maybe add delay time?  S 10 for example?
 *  L  ---  Remaining Lifetime/Uptime
 *  T  ---  Time
 *  U  ---  Get Uptime
 *  C  ---  Camera On
 *  E  ---  Print EEPROM
 *  K  ---  Kill/reset EEPROM data
 *  
 *  M  ---  Retrieve Zero Configuration Set // TODO
 *  
 *  Q  ---  Read Value
 *  W  ---  Write Value
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
    Serial.write(inChar);
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
      // ser.port->println(ser.serialCommand);
      
      if (spacePos > 0) {        
        sscanf(ser.inputBuffer, "%*s %d", &ser.serialParam);
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
  #ifdef DEBUG
    ser0.port -> print("=> ");
    ser0.port -> println(ser.serialCommand);
  #endif
  
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

    case 'O': // Turn Zero On 
      // TODO
      switchZeroOn(true);
      okSerial(ser);
      break;
      
    case 'S': // Shutdown 
      if (ser.serialParam > 0) {
        if (state != STATE_ZERO_RUNNING) {
          errorSerial(ERRORCODE_INVALID_PARAM, ser);
          break;
        }
        zeroShutdownTimer = millis() + ser.serialParam * 1000; 
      } else {
        if (state == STATE_ZERO_RUNNING) {
          state = STATE_ZERO_STOP;  
        } else {
          switchZeroOn(false);  
          zeroShutdownTimer = -1;
        }
      }
      okSerial(ser);
      break;

    case 'L': // Remaining Lifetime
      ser.port->print("K ");
      if (zeroShutdownTimer > 0) {
        ser.port->println(zeroShutdownTimer-millis());
      } else {
        ser.port->println(-1);
      }
      break;
     
    case 'T': // Time 
      //errorSerial(ERRORCODE_NOT_AVAILABLE, ser);
      ser.port->print("K ");
      ser.port->println(millis());
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
      if (ser.serialParam > 0 && ser.serialParam <= 512) {
        eeprom_print(ser, 0, ser.serialParam);
      } else {
        eeprom_print(ser, 0, 512);
      }
      // okSerial?
      break; 
      
    case 'K': // Kill EEPROM data
      eeprom_reset();
      okSerial(ser);
      break; 

    case 'Q': // Read value
      int* ptr;
      ptr = mapVariable(ser.serialParam);
      if (ptr == NULL) {
        errorSerial(ERRORCODE_INVALID_PARAM, ser);
        break;
      }
      
      ser.port->print("K ");
      ser.port->println(*ptr);
      break;

    case 'W': // Write value
      if (ser.serialParam2 < 0) {
        errorSerial(ERRORCODE_INVALID_PARAM, ser);
        break;
      }
      
      int* ptr_var;
      ptr_var = mapVariable(ser.serialParam);
      if (ptr_var == NULL) {
        errorSerial(ERRORCODE_INVALID_PARAM, ser);
        break;
      }

      *ptr_var = ser.serialParam2;
      
      okSerial(ser);
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
  ser.port->println("K");
}
