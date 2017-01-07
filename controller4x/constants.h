// ----------- PINS -----------

#define PIN_CELL_1                         8 // PB4
#define PIN_CELL_2                         6 // PD7
#define PIN_BATT_DIRECT                    9 // PB5

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

#define PRE_TRIGGER_WAIT                  12
#define POST_TRIGGER_WAIT                 40

#define LIPO_CELL_MIN                    3.7
#define LIPO_CELL_MAX                    4.2

#define INTERVAL_DEFAULT_VAL               1
#define ITERATIONS_DEFAULT_VAL           100

// ----------- MISC -----------

#define VERSION                          0.2

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
#define BATT_PERCENTAGE                   -2

// ----------- BUTTONS -----------

#define BTN_UP             PIN_PUSHBUTTON_UP
#define BTN_DOWN         PIN_PUSHBUTTON_DOWN
#define BTN_LEFT         PIN_PUSHBUTTON_LEFT
#define BTN_RIGHT       PIN_PUSHBUTTON_RIGHT
#define BTN_CENTER     PIN_PUSHBUTTON_CENTER

// ----------- MENU -----------

#define STATE_MENU_INIT                    9

#define STATE_MENU_DETAILS                10
#define STATE_MENU_DETAILS_DRAW           11

#define STATE_MENU_CAMERA_ON              20
#define STATE_MENU_CAMERA_ON_DRAW         21
#define STATE_MENU_CAMERA_ON_SELECTED     22

#define STATE_MENU_CAMERA_OFF             30
#define STATE_MENU_CAMERA_OFF_DRAW        31
#define STATE_MENU_CAMERA_OFF_SELECTED    32

#define STATE_MENU_TAKE_PICTURE           40
#define STATE_MENU_TAKE_PICTURE_DRAW      41
#define STATE_MENU_TAKE_PICTURE_SELECTED  42

#define STATE_MENU_INTERVAL               50
#define STATE_MENU_INTERVAL_DRAW          51
#define STATE_MENU_INTERVAL_SELECTED      52

#define STATE_MENU_ITERATIONS             60
#define STATE_MENU_ITERATIONS_DRAW        61
#define STATE_MENU_ITERATIONS_SELECTED    62

#define STATE_MENU_START                  70
#define STATE_MENU_START_DRAW             71
#define STATE_MENU_START_SELECTED         72

#define STATE_MENU_SLEEP                  80
#define STATE_MENU_SLEEP_DRAW             81
#define STATE_MENU_SLEEP_SELECTED         82

#define STATE_INIT                         4
#define STATE_SLEEP                        5
#define STATE_SENSOR_READ                  6
#define STATE_CAMERA_RUNNING               7
#define STATE_STOP                         8
