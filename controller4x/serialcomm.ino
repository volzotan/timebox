//void serialEvent() {
//
//  String inputString = "";
//  boolean stringComplete = false;
//  
//  while (Serial1.available()) {
//    // get the new byte:
//    char inChar = (char) Serial1.read();
//    // add it to the inputString:
////    inputString += inChar;
////    // if the incoming character is a newline, set a flag
////    // so the main loop can do something about it:
////    if (inChar == '\n') {
////      stringComplete = true;
////    }
//
//    Serial.print(inChar);
//  }
//}

void serialEvent() {
  
  while (Serial.available()) {
    
    char inChar = (char) Serial.read();

    if (inChar == '\n') {
      int spacePos = serialInputString.indexOf(" ");

      // empty
      if (serialInputString.length() < 1) {
        errorSerial(ERRORCODE_MESSAGE_EMPTY);
      }

      // space on wrong pos
      if (spacePos > 0 && spacePos != 1) {
        errorSerial(ERRORCODE_INVALID_MESSAGE);
      }

      // cmd longer than one char
      if (spacePos < 0 && serialInputString.length() > 1) {
        errorSerial(ERRORCODE_MESSAGE_TOO_LONG);
      }

      // double space
      if (spacePos != serialInputString.lastIndexOf(" ")) {
        errorSerial(ERRORCODE_INVALID_MESSAGE);
      }

      serialCommand = serialInputString[0];  
      Serial.println(serialCommand);
      
      if (spacePos > 0) {        
        serialParam = serialInputString.substring(spacePos+1).toInt();

        Serial.println(serialParam);
      }
      
      executeCommand();
      resetSerial();
    } else {
      serialInputString += inChar;  
    }
  }
}

void executeCommand() {
  switch(serialCommand) {
    case 'P': 
      break;    
    default:
      errorSerial(ERRORCODE_UNKNOWN_CMD);
  }  
  
}

void resetSerial() {
  serialInputString = "";
  
  serialCommand = 0;
  serialParam = 0;
}

void errorSerial(int errcode) {
  resetSerial();
  
  Serial.print("E ");
  Serial.println(errcode);
}
