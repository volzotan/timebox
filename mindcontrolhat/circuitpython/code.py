import time
import board
import pwmio
import busio
from digitalio import DigitalInOut, Direction

from adafruit_motor import servo

import displayio
import terminalio
from adafruit_display_text import label
import adafruit_displayio_ssd1306

PIN_FOCUS       = board.GP6
PIN_SHUTTER     = board.GP7
PIN_SERVO       = board.GP22

SERVO_ANGLE_M   = 30
SERVO_ANGLE_A   = 155

INTERVAL_M      = 45

DISPLAY_SIZE    = [128, 32]

mode            = "?"
num_trigger     = 0
time_start      = None

trigger_focus = DigitalInOut(PIN_FOCUS)
trigger_shutter = DigitalInOut(PIN_SHUTTER)
trigger_focus.direction = Direction.OUTPUT
trigger_shutter.direction = Direction.OUTPUT

trigger_focus.value = False
trigger_shutter.value = False

pwm = pwmio.PWMOut(PIN_SERVO, duty_cycle=0, frequency=50)
blocker_servo = servo.Servo(pwm)

displayio.release_displays()
i2c = busio.I2C(board.GP5, board.GP4)
display_bus = displayio.I2CDisplay(i2c, device_address=0x3C)
display = adafruit_displayio_ssd1306.SSD1306(display_bus, 
    width=DISPLAY_SIZE[0], height=DISPLAY_SIZE[1])

# Make the display context
splash = displayio.Group()
display.show(splash)

color_bitmap = displayio.Bitmap(DISPLAY_SIZE[0], DISPLAY_SIZE[1], 1)
color_palette = displayio.Palette(1)
color_palette[0] = 0x000000 

print("> init")

# ---

def trigger():

    trigger_focus.value = True
    time.sleep(1.0)
    trigger_shutter.value = True
    time.sleep(1.0)
    trigger_shutter.value = False
    trigger_focus.value = False
    time.sleep(1.0)

    print("trigger")


def _time_string(t):
    s = t % 60
    m = t // 60
    h = t // 3600

    return "{:02}:{:02}:{}".format(h, m, s)


def display(time_till_trigger):
    
    bg_sprite = displayio.TileGrid(color_bitmap, pixel_shader=color_palette, x=0, y=0)
    splash.append(bg_sprite)

    palette_white = displayio.Palette(1)
    palette_white[0] = 0xFFFFFF
    palette_black = displayio.Palette(1)
    palette_black[0] = 0x000000

    outer_bitmap = displayio.Bitmap(DISPLAY_SIZE[0]-20, 8, 1)
    outer_sprite = displayio.TileGrid(
        outer_bitmap, pixel_shader=palette_white, x=0, y=DISPLAY_SIZE[1]-8
    )
    splash.append(outer_sprite)

    inner_bitmap = displayio.Bitmap(DISPLAY_SIZE[0]-20-2-10, 6, 1)
    inner_sprite = displayio.TileGrid(
        inner_bitmap, pixel_shader=palette_black, x=1, y=DISPLAY_SIZE[1]-7
    )
    splash.append(inner_sprite)

    splash.append(label.Label(
        terminalio.FONT, text="{}".format(time_till_trigger), 
        color=0xFFFFFF, 
        x=DISPLAY_SIZE[0]-16, y=DISPLAY_SIZE[1]-4
    ))

    mode_bitmap = displayio.Bitmap(20, 20, 1)
    mode_sprite = displayio.TileGrid(
        mode_bitmap, pixel_shader=palette_white, x=0, y=0
    )
    splash.append(mode_sprite)

    splash.append(label.Label(
        terminalio.FONT, text=mode, color=0x000000, x=5, y=10
    ))

    splash.append(label.Label(
        terminalio.FONT, text="TRIGGER: {}".format(num_trigger), color=0xFFFFFF, x=25, y=4
    ))

    time_elapsed = (time.monotonic() - time_start)//1000

    splash.append(label.Label(
        terminalio.FONT, text="ELAPSED: {}".format(_time_string(time_elapsed)), color=0xFFFFFF, x=25, y=16
    ))


def sleep(s):
    for i in range(0, s):
        time.sleep(1)
        display(10)        


time_start = time.monotonic()

while True:

    blocker_servo.angle = SERVO_ANGLE_M  # M1
    mode = "M1"
    sleep(2)                             #   2
    trigger()                            #   5  -- 2
    num_trigger += 1
    sleep(2)                             #   7
    print("capture M1")

    blocker_servo.angle = SERVO_ANGLE_A  # A1
    sleep(2)                             #   9
    trigger()                            #  12  -- 9
    num_trigger += 1
    print("capture A1")
    sleep(30)                            #  42       

    blocker_servo.angle = SERVO_ANGLE_M
    time.sleep(INTERVAL_M-42+2)          #  47

    trigger()                            # M2   -- 2 + 45
    print("capture M2")                  #  50
    time.sleep(INTERVAL_M-3)             #  92

    trigger()                            # M3   -- 2 + 45 + 45
    print("capture M3")                  #  95
    time.sleep(INTERVAL_M-3-2)           # 135