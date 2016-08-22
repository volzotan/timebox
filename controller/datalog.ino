int initLogger() {
  sensorsOn(true);
  
  if (!SD.begin(PIN_CARD_SS)) {
    Serial.println("initialization failed!");
    return 1;
  }

  if (SD.exists(LOGGER_FILENAME)) {
    Serial.println("Log found.");
  } else {
    Serial.println("Log not found. Creating.");
    File fd = SD.open(LOGGER_FILENAME, FILE_WRITE);
    fd.close();
    delay(100);
  }

  sensorsOn(false);

  return 0;
}

void loggerWrite(char* msg) {
  sensorsOn(true);
  
  File fd = SD.open(LOGGER_FILENAME, FILE_WRITE);
  fd.write(msg);
  fd.close();
  
  sensorsOn(false);
}
