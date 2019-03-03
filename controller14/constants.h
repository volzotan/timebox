// ----------- PINS -----------

#ifdef CONTROLLER11
  
  #define PIN_BATT_DIRECT                   10 // PB6
  
  #define PIN_ZERO_EN                       A4 // PF1
  #define PIN_CAMERA_EN                      4 // PD4
  
  #define PIN_BUTTON                        A3 // PD5 // needs modified caterina bootloader // TODO: wrong arduino pin
  
  #define PIN_CAM1                           6 // PD7
  #define PIN_CAM2                           8 // PB4
  
  #define PIN_LED                            5 // PC6
   
  #define PIN_EXT1                        MISO // PB3
  #define PIN_EXT2                        MOSI // PB2
  #define PIN_EXT3                         SCK // PB1
  
#endif

#ifdef CONTROLLER14

  #define PIN_DUMMY_LOAD                  A5 // PF0
  
  #define PIN_ZERO_EN                     A4 // PF1
  #define PIN_CAMERA1_EN                   4 // PD4
  #define PIN_CAMERA2_EN                  12 // PD6
  
  #define PIN_SHUTTER1                     8 // PB4
  #define PIN_SHUTTER2                     6 // PD7
  
  #define PIN_LED                         11 // PB7
   
  #define PIN_EXT1                      MISO // PB3
  #define PIN_EXT2                      MOSI // PB2
  #define PIN_EXT3                       SCK // PB1
  
#endif

// ----------- OPTIONS -----------

#define LIPO_CELL_MIN                    3.7
#define LIPO_CELL_MAX                    4.2

// defaults

#define DEFAULT_WATCHDOG_TIME          10000 // 10s
#define DEFAULT_DUMMY_LOAD_ENABLED         0

// ----------- MISC -----------

#define VERSION                         14.0

#define VDBASEVOLTAGE                    5.1
#define VDRESISTOR1                       20
#define VDRESISTOR2                       20

#define BATT_ALL                           0
#define BATT_CELL_1                        1
#define BATT_CELL_2                        2 
#define BATT_DIRECT                       -1 
#define BATT_PERCENTAGE_CELL              -3
#define BATT_PERCENTAGE_DIRECT            -4

// ----------- ERROR CODES -----------

#define ERRORCODE_INVALID_MESSAGE        100
#define ERRORCODE_MESSAGE_EMPTY          101
#define ERRORCODE_MESSAGE_TOO_LONG       102
#define ERRORCODE_UNKNOWN_CMD            103
#define ERRORCODE_INVALID_PARAM          104
#define ERRORCODE_NOT_AVAILABLE          110

// ----------- EEPROM POSITIONS -----------

#define EEPROM_IN_USAGE                    3
#define EEPROM_WATCHDOG_TIME              10
#define EEPROM_DUMMY_LOAD_ENABLED         20

