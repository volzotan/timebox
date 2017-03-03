void serialEvent() {

  String inputString = "";
  boolean stringComplete = false;
  
  while (Serial1.available()) {
    // get the new byte:
    char inChar = (char) Serial1.read();
    // add it to the inputString:
//    inputString += inChar;
//    // if the incoming character is a newline, set a flag
//    // so the main loop can do something about it:
//    if (inChar == '\n') {
//      stringComplete = true;
//    }

    Serial.print(inChar);
  }
}

void executeCommand(char cmd, int value) {
  switch(cmd) {
    case 'P': 
      break;    
  }  
  
}
