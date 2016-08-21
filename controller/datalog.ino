int initLogger() {
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

  return 0;
}

void loggerWrite(char* msg) {
  File fd = SD.open(LOGGER_FILENAME, FILE_WRITE);

  fd.write(msg);
  
  fd.close();
}
