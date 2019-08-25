// ----------- PINS -----------

#define PIN_BATT_DIRECT                   10 // PB6

#define PIN_ZERO_EN                       A4 // PF1
#define PIN_CAMERA_EN                      4 // PD4

#define PIN_BUTTON                        A3 // PD5 // needs modified caterina bootloader // TODO: wrong arduino pin

#define PIN_CAM_SHUTTER                    6 // PD7
#define PIN_CAM_FOCUS                      8 // PB4

#define PIN_LED                            5 // PC6
 
#define PIN_EXT1                        MISO // PB3
#define PIN_EXT2                        MOSI // PB2
#define PIN_EXT3                         SCK // PB1

// ----------- OPTIONS -----------

#define LIPO_CELL_MIN                    3.1
#define LIPO_CELL_MAX                    4.2

#define INTERVAL                        2*60
#define ITERATIONS                      1000

#define PRE_TRIGGER_WAIT                  12

#define TRIGGER_DURATION                   1
// 1s for 3EV 3 image bracketing mode:
// if first and second image exposure time 
// combined is less than 1s (= daytime), 
// then 3 images are taken if longer only 
// one or two

#define POST_TRIGGER_WAIT                 37             

// ----------- MISC -----------

#define VERSION                         11.0

#define VDBASEVOLTAGE                    5.1
#define VDRESISTOR1                       10
#define VDRESISTOR2                       10

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
