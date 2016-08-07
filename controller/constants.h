// PINS

#define PIN_CELL_1                A0
#define PIN_CELL_2                A1

#define PIN_DISPLAY_EN             9
#define PIN_CAMERA_EN             10
#define PIN_SENSORS_EN            11
#define PIN_PUSHBUTTON            12
#define PIN_PHOTOCELL             A3
#define PIN_POTENTIOMETER         A2

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

                                          
#define STATE_SLEEP                        5
#define STATE_SENSOR_READ                  6
#define STATE_CAMERA_RUNNING               7
