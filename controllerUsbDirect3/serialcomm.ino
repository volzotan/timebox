/* Commandlist
 *
 *  K  ---  Knock
 *
 *  B  ---  Battery
 *    8.00    80
 *    voltage percentage
 *  
 *  Z  ---  Turn Zero On
 *  S  ---  Shutdown [delay in seconds]
 *  R  ---  Reboot    // maybe add delay time?  S 10 for example?
 *  L  ---  Remaining Lifetime/Uptime
 *
 *  T  ---  Temperature
 *
 *  U  ---  Get Uptime
 *
 *  C  ---  Camera On

 *  E  ---  Print EEPROM
 *  K  ---  Kill/reset EEPROM data
 *  
 *  Q  ---  Read Value
 *  W  ---  Write Value
 *  
 *  [...]
 */

void serialEvent() {
    while (SerialUSB.available()) {
        char inChar = (char) SerialUSB.read();
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
    // #ifdef DEBUG
    //     SerialUSB.print("=> ");
    //     SerialUSB.println(serialCommand);
    // #endif
    
    switch(serialCommand) {

        case 'K': // Ping / Knock
            okSerial();
        break;

        case 'B': // Battery Health
            SerialUSB.print("K ");
            SerialUSB.print(getLiPoVoltage(BATT_DIRECT));
            SerialUSB.print(" ");
            SerialUSB.println(getLiPoVoltage(BATT_PERCENTAGE_DIRECT));
        break;

        // case 'Z': // Zero On 
        // if (serialParam == 0) {
        //     switchZeroOn(false);
        //     okSerial();
        // } else if (serialParam == 1) {
        //     switchZeroOn(true);
        //     okSerial();
        // } else {
        //     errorSerial(ERRORCODE_INVALID_PARAM);
        // }
        // break; 
        
        // case 'S': // Shutdown 
        //     if (ser.serialParam > 0) {
        //         if (state != STATE_ZERO_RUNNING) {
        //             errorSerial(ERRORCODE_INVALID_PARAM, ser);
        //             break;
        //         }
        //         zeroShutdownTimer = millis() + ser.serialParam * 1000; 
        //     } else {
        //         if (state == STATE_ZERO_RUNNING) {
        //             state = STATE_ZERO_STOP;    
        //         } else {
        //             switchZeroOn(false);    
        //             zeroShutdownTimer = -1;
        //         }
        //     }
        //     okSerial(ser);
        //     break;
        
        case 'U': // Time 
            //errorSerial(ERRORCODE_NOT_AVAILABLE, ser);
            SerialUSB.print("K ");
            SerialUSB.println(millis());
        break;        

        case 'C': // Camera On 
        if (serialParam == 0) {
            switchCameraOn(false);
            okSerial();
        } else if (serialParam == 1) {
            switchCameraOn(true);
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
    SerialUSB.print("E ");
    SerialUSB.println(errcode);
}

void okSerial() {
    SerialUSB.println("K");
}
