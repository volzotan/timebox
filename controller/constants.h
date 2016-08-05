// PINS

#define PIN_DISPLAY_EN             9
#define PIN_THERM_EN
#define PIN_CAMERA_EN
#define PIN_PHOTOCELL_EN          A3
#define PIN_PHOTOCELL             A2
#define PIN_POTENTIOMETER         A4
#define PIN_PUSHBUTTON             7

#define PIN_CAMERA_HIGHSIDE        3
#define PIN_CAMERA_FOCUS           4
#define PIN_CAMERA_SHUTTER         5

// OPTIONS

#define USE_DISPLAY             true
#define USE_PHOTOCELL          false

#define PRE_TRIGGER_WAIT           5
#define POST_TRIGGER_WAIT         40

// MISC

#define VERSION                  0.1

// ----------- MENU ----------------

#define STATE_MENU_DETAILS                10
#define STATE_MENU_DETAILS_DRAW           11

#define STATE_MENU_CAMERA_ON              20
#define STATE_MENU_CAMERA_ON_DRAW         21

#define STATE_MENU_CAMERA_OFF             30
#define STATE_MENU_CAMERA_OFF_DRAW        31

#define STATE_MENU_INTERVAL               40
#define STATE_MENU_INTERVAL_DRAW          41
#define STATE_MENU_INTERVAL_SELECTED      42

#define STATE_MENU_ITERATIONS             50
#define STATE_MENU_ITERATIONS_DRAW        51
#define STATE_MENU_ITERATIONS_SELECTED    52

#define STATE_MENU_START                  60
#define STATE_MENU_START_DRAW             61

                                          
#define STATE_SLEEP                        1
#define STATE_SENSOR_READ                  2
#define STATE_CAMERA_RUNNING               3
