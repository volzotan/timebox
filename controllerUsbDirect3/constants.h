// ----------- PINS -----------

#define PIN_BATT_DIRECT                    8 // PA06
#define PIN_CAMERA_EN                      9 // PA07
#define PIN_BUTTON                        11 // PA16
#define PIN_LED                           13 // PA17
// #define PIN_ZERO_EN

// ----------- OPTIONS -----------

#define LIPO_CELL_MIN                    3.6
#define LIPO_CELL_MAX                    4.2

// ----------- MISC -----------

#define VERSION                         11.0

#define VDBASEVOLTAGE                    3.3
#define VDRESISTOR1                       10
#define VDRESISTOR2                      6.2

#define BATT_VD_RAW                        0
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