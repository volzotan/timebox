// ----------- PINS -----------

#define PIN_BATT_DIRECT                   10 // PB6

#define PIN_ZERO_EN                       30
#define PIN_CAMERA_EN                      5 // PC6

#define PIN_BUTTON                        A4 // PF1 

#define PIN_CAM1                           8 // PB4
#define PIN_CAM2                           6 // PD7
#define PIN_CAM3                          12 // PD6
#define PIN_CAM4                           4 // PD4

#define PIN_LED                            7 // PE6
 
#define PIN_EXT1                        MISO // PB3
#define PIN_EXT2                        MOSI // PB2
#define PIN_EXT3                        SCK // PB1

// #define PIN_DISPLAY_RST                    4 // PD4
// #define PIN_DISPLAY_EN                    12 // PD6

// ----------- OPTIONS -----------

#define LIPO_CELL_MIN                    3.7
#define LIPO_CELL_MAX                    4.2

#define INTERVAL_DEFAULT_VAL               1
#define ITERATIONS_DEFAULT_VAL           100

// ----------- MISC -----------

#define VERSION                         10.0

// display offset for 2nd row
#define SECONDROW                         18 

#define VDBASEVOLTAGE                    5.1
#define VDRESISTOR1                       10
#define VDRESISTOR2                       10

// eeprom positions
#define EEPROM_INTERVAL                   10
#define EEPROM_ITERATIONS                 20  

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

// ----------- MENU -----------

#define STATE_INIT                         4
#define STATE_IDLE                         3
#define STATE_SLEEP                        5
#define STATE_ZERO                         6
#define STATE_STOP                         8
