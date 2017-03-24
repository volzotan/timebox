// ----------- PINS -----------

#define PIN_CELL_1                         8 // PB4
#define PIN_CELL_2                         6 // PD7
#define PIN_BATT_DIRECT                   A9 // PB5

#define PIN_DISPLAY_RST                    4 // PD4
#define PIN_DISPLAY_EN                    12 // PD6
#define PIN_ZERO_EN                       11 // PB7
#define PIN_CAMERA_EN                     A0 // PF7

#define PIN_PUSHBUTTON_UP                 A3 // PF4 
#define PIN_PUSHBUTTON_DOWN               A1 // PF6
#define PIN_PUSHBUTTON_LEFT               A4 // PF1
#define PIN_PUSHBUTTON_RIGHT              A2 // PF5
#define PIN_PUSHBUTTON_CENTER             A5 // PF0

#define PIN_CAMERA_FOCUS                  10 // PB6
#define PIN_CAMERA_SHUTTER                 5 // PC6

// ----------- OPTIONS -----------

#define BALANCER_NOT_CONNECTED          true

#define USE_TEMP_SENSOR                false

#define LIPO_CELL_MIN                    3.7
#define LIPO_CELL_MAX                    4.2

#define INTERVAL_DEFAULT_VAL               1
#define ITERATIONS_DEFAULT_VAL           100

// ----------- MISC -----------

#define VERSION                          4.0

// display offset for 2nd row
#define SECONDROW                         18 

#define VDBASEVOLTAGE                    5.0
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

// ----------- BUTTONS -----------

#define BTN_UP             PIN_PUSHBUTTON_UP
#define BTN_DOWN         PIN_PUSHBUTTON_DOWN
#define BTN_LEFT         PIN_PUSHBUTTON_LEFT
#define BTN_RIGHT       PIN_PUSHBUTTON_RIGHT
#define BTN_CENTER     PIN_PUSHBUTTON_CENTER

// ----------- MENU -----------

#define STATE_INIT                         4
#define STATE_IDLE                         3
#define STATE_SLEEP                        5
#define STATE_ZERO                         6
#define STATE_STOP                         8
