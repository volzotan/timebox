// ----------- PINS -----------

#define PIN_BATT_DIRECT                   A1 // PB08
#define PIN_BUTTON                        11 // PA16
#define PIN_ZERO_EN                        9 // PA07
#define PIN_ZERO_FAULT                    A4 // PA05
#define PIN_SERVO                          6 // PA20

// ----------- OPTIONS -----------

#define LIPO_CELL_MIN                    3.1
#define LIPO_CELL_MAX                    4.2

// ----------- MISC -----------

#define VERSION                         11.0

#define VDBASEVOLTAGE                    3.3
#define VDRESISTOR1                      100
#define VDRESISTOR2                       62

// ----------- ERROR CODES -----------

#define ERRORCODE_INVALID_MESSAGE        100
#define ERRORCODE_MESSAGE_EMPTY          101
#define ERRORCODE_MESSAGE_TOO_LONG       102
#define ERRORCODE_UNKNOWN_CMD            103
#define ERRORCODE_INVALID_PARAM          104
#define ERRORCODE_NOT_AVAILABLE          110


// ----------- ERROR CODES -----------

#define STATE_LOOP                       11
#define STATE_IDLE                       12
#define STATE_TRIGGER_START              13
#define STATE_TRIGGER_WAIT               14