/* Commandlist
 *
 *  K  ---  Knock
 *
 *  B  ---  Battery
 *    8.00    80
 *    voltage percentage
 *  
 *  S  ---  Shutdown                        (S / S 1000)
 *  U  ---  Get Uptime
 *  T  ---  Temperature
 *  Z  ---  Turn Zero On/Off                (Z 0 / Z 1)

 *  E  ---  Print EEPROM
 *  K  ---  Kill/reset EEPROM data
 *  
 *  Q  ---  Read Value
 *  W  ---  Write Value

 *  [...]
 */

void serialEvent() {
    while (SERIAL.available()) {
        char inChar = (char) SERIAL.read();
        processCommand(inChar);
    }
}

void processCommand(char inChar) {

    // Buffer size exceeded
    if (strlen(inputBuffer) > 99) {
        errorSerial(ERRORCODE_MESSAGE_TOO_LONG);
        return;
    }
    
    if (inChar == '\n' || inChar == '\r') {

        int spacePos = strchr(inputBuffer, ' ')-inputBuffer;

        // sanity checks

        // empty
        if (strlen(inputBuffer) < 1) {
            errorSerial(ERRORCODE_MESSAGE_EMPTY);
            return;
        }

        // space on wrong pos / cmd longer than one char
        if (spacePos > 0 && spacePos != 1) {
            errorSerial(ERRORCODE_INVALID_MESSAGE);
            return;
        }

        // double space
        if (spacePos > 0 && spacePos != lastIndexOf(inputBuffer, ' ')) {
            errorSerial(ERRORCODE_INVALID_MESSAGE);
            return;
        }

        // everything ok:

        serialCommand = inputBuffer[0];    
        // ser.port->println(ser.serialCommand);
        
        if (spacePos > 0) {                
            sscanf(inputBuffer, "%*s %d", &serialParam);
        }
        
        executeCommand();
        resetSerial();
    } else {
        int len = strlen(inputBuffer);
        
        inputBuffer[len] = inChar; 
        inputBuffer[len+1] = '\0';    
    }    
}

void executeCommand() {
    #ifdef DEBUG
        SerialUSB.print("=> ");
        SerialUSB.println(serialCommand);
    #endif
    
    switch(serialCommand) {

        case 'K': // Ping / Knock
            okSerial();
        break;

        case 'B': // Battery Health
            SERIAL.print("K ");
            SERIAL.print(getBatteryVoltage());
            SERIAL.print(" ");
            SERIAL.println(getBatteryPercentage());
        break;
            
        case 'S': // Shutdown 
            if (serialParam > 0) {
                if (state != STATE_TRIGGER_WAIT) {
                    errorSerial(ERRORCODE_INVALID_PARAM);
                    break;
                }
                postTriggerWaitDelayed = millis() + serialParam; 
                DEBUG_PRINT("postTriggerWaitDelayed set");
            } else {
                switchZeroOn(false);    
                postTriggerWaitDelayed = -1;
            }
            okSerial();
            break;
        
        case 'U': // Uptime 
            //errorSerial(ERRORCODE_NOT_AVAILABLE, ser);
            SERIAL.print("K ");
            SERIAL.println(millis());
        break;   

        case 'T': // Temperature
            tempsensor.wake();

            SERIAL.print("K ");
            SERIAL.print(tempsensor.readTempC(), 4);
            SERIAL.println();

            tempsensor.shutdown_wake(1);
        break;     

        case 'Z': // Zero On 
            if (serialParam == 0) {
                switchZeroOn(false);
                okSerial();
            } else if (serialParam == 1) {
                switchZeroOn(true);
                okSerial();
            } else {
                errorSerial(ERRORCODE_INVALID_PARAM);
            }
        break; 
        
        default:
            errorSerial(ERRORCODE_UNKNOWN_CMD);
    }    

    // method returns and serial is reset
}

void resetSerial() {
    inputBuffer[0] = '\0';
    serialCommand = 0;
    serialParam = -1;
}

void errorSerial(int errcode) {
    resetSerial();
    SERIAL.print("E ");
    SERIAL.println(errcode);
}

void okSerial() {
    SERIAL.println("K");
}
