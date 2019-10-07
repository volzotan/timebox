/* Commandlist
 *
 *  K  ---  Knock
 *
 *  B  ---  Battery
 *    8.00    80
 *    voltage percentage
 *  
 *  U  ---  Get Uptime
 *  T  ---  Temperature
 *  C  ---  Camera On/Off                   (C 0 / C 1)
 *  X  ---  Auxilliary USB Device 1 On/Off  (X 0 / X 1)
 *  Y  ---  Auxilliary USB Device 2 On/Off  (Y 0 / Y 1)
 *  Z  ---  Turn Zero On/Off                (Z 0 / Z 1)

 *  E  ---  Print EEPROM
 *  K  ---  Kill/reset EEPROM data
 *  
 *  Q  ---  Read Value
 *  W  ---  Write Value

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
            SerialUSB.print(getBatteryVoltage());
            SerialUSB.print(" ");
            SerialUSB.println(getBatteryPercentage());
        break;
            
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
        
        case 'U': // Uptime 
            //errorSerial(ERRORCODE_NOT_AVAILABLE, ser);
            SerialUSB.print("K ");
            SerialUSB.println(millis());
        break;   

        case 'T': // Temperature
            tempsensor.wake();

            SerialUSB.print("K ");
            SerialUSB.print(tempsensor.readTempC(), 4);
            SerialUSB.println();

            tempsensor.shutdown_wake(1);
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

        case 'X': // Auxilliary USB Device 1 On/Off 
            if (serialParam == 0) {
                switchUsbDeviceOn(0, false);
                okSerial();
            } else if (serialParam == 1) {
                switchUsbDeviceOn(0, true);
                okSerial();
            } else {
                errorSerial(ERRORCODE_INVALID_PARAM);
            }
        break; 

        case 'X': // Auxilliary USB Device 2 On/Off 
            if (serialParam == 0) {
                switchUsbDeviceOn(1, false);
                okSerial();
            } else if (serialParam == 1) {
                switchUsbDeviceOn(1, true);
                okSerial();
            } else {
                errorSerial(ERRORCODE_INVALID_PARAM);
            }
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
    SerialUSB.print("E ");
    SerialUSB.println(errcode);
}

void okSerial() {
    SerialUSB.println("K");
}
