// ----------- PINS -----------

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

// ----------- OPTIONS -----------

#define LIPO_CELL_MIN                    3.1
#define LIPO_CELL_MAX                    4.2

// defaults

// #define DEFAULT_PROGRAM_MODE       MODE_ZERO

// #define DEFAULT_INTERVAL                2*60
// #define DEFAULT_ITERATIONS               100

// actual running time = boot_wait + uptime

// #define DEFAULT_DIRECT_BOOT_WAIT           8
// #define DEFAULT_DIRECT_UPTIME             35
// #define DEFAULT_ZERO_BOOT_WAIT            10
// #define DEFAULT_ZERO_UPTIME               50

// #define DEFAULT_ZERO_BRIGHTNESS_THRESHOLD 100
// #define DEFAULT_ZERO_EXPOSURE_LOW         -5
// #define DEFAULT_ZERO_EXPOSURE_NORMAL      +1

// ----------- MISC -----------

#define VERSION                         11.0

#define VDBASEVOLTAGE                    5.1
#define VDRESISTOR1                       10
#define VDRESISTOR2                      6.2

#define BATT_VD_RAW                        0
#define BATT_CELL_1                        1
#define BATT_CELL_2                        2 
#define BATT_DIRECT                       -1 
#define BATT_PERCENTAGE_CELL              -3
#define BATT_PERCENTAGE_DIRECT            -4

// #define MODE_DIRECT                      'd'
// #define MODE_ZERO                        'z'

// ----------- ERROR CODES -----------

#define ERRORCODE_INVALID_MESSAGE        100
#define ERRORCODE_MESSAGE_EMPTY          101
#define ERRORCODE_MESSAGE_TOO_LONG       102
#define ERRORCODE_UNKNOWN_CMD            103
#define ERRORCODE_INVALID_PARAM          104
#define ERRORCODE_NOT_AVAILABLE          110

// ----------- MENU -----------

// #define STATE_INIT                        10
// #define STATE_IDLE                        20
// #define STATE_SLEEP                       30

// #define STATE_DIRECT_ON                   40
// #define STATE_DIRECT_SHUTTER              41
// #define STATE_DIRECT_OFF                  42

// #define STATE_ZERO_START                  50
// #define STATE_ZERO_BOOTED                 51
// #define STATE_ZERO_RUNNING                52
// #define STATE_ZERO_STOP                   53

// #define STATE_STOP                        60

// ----------- EEPROM POSITIONS -----------

// #define EEPROM_IN_USAGE                    3
// #define EEPROM_INTERVAL                   10
// #define EEPROM_ITERATIONS                 20  
// #define EEPROM_DIRECT_BOOT_WAIT           30  
// #define EEPROM_DIRECT_UPTIME              40  
// #define EEPROM_ZERO_BOOT_WAIT             50  
// #define EEPROM_ZERO_UPTIME                60 
// #define EEPROM_ZERO_BRIGHTNESS_THRESHOLD  70 
// #define EEPROM_ZERO_EXPOSURE_LOW          80
// #define EEPROM_ZERO_EXPOSURE_NORMAL       90
// #define EEPROM_PROGRAM_MODE              100 
