// ----------- PINS -----------

// to be able to use digital pin 8 as A6 the variants.h
// and other files need to be edited to enable analog readings
// on additional SAMD21 pins. (see README.mk)
#define PIN_BATT_DIRECT                   A6 // PA06

#define PIN_CAMERA_EN                      9 // PA07
#define PIN_BUTTON                        11 // PA16
#define PIN_LED                           13 // PA17
// #define PIN_ZERO_EN

// ----------- OPTIONS -----------

#define LIPO_CELL_MIN                    3.5
#define LIPO_CELL_MAX                    4.2

// ----------- MISC -----------

#define VERSION                         11.0

#define VDBASEVOLTAGE                    3.3
#define VDRESISTOR1                      100
#define VDRESISTOR2                     44.7

// ----------- ERROR CODES -----------

#define ERRORCODE_INVALID_MESSAGE        100
#define ERRORCODE_MESSAGE_EMPTY          101
#define ERRORCODE_MESSAGE_TOO_LONG       102
#define ERRORCODE_UNKNOWN_CMD            103
#define ERRORCODE_INVALID_PARAM          104
#define ERRORCODE_NOT_AVAILABLE          110