import time
import board
import pwmio
import busio
from digitalio import DigitalInOut, Direction
import math

from adafruit_motor import servo
import displayio
import terminalio
from adafruit_display_text import label
from adafruit_display_shapes.rect import Rect
import adafruit_displayio_ssd1306

PIN_FOCUS       = board.GP6
PIN_SHUTTER     = board.GP7
PIN_SERVO       = board.GP22

SERVO_ANGLE_M   = 30
SERVO_ANGLE_A   = 155

INTERVAL_M      = 45

SLEEP_DURATION  = 0.5
DISPLAY_SIZE    = [128, 32]

mode            = "?"
num_cycles      = 0
time_start      = None
cycle_start     = None

# ---

trigger_focus = DigitalInOut(PIN_FOCUS)
trigger_shutter = DigitalInOut(PIN_SHUTTER)
trigger_focus.direction = Direction.OUTPUT
trigger_shutter.direction = Direction.OUTPUT

trigger_focus.value = False
trigger_shutter.value = False

pwm = pwmio.PWMOut(PIN_SERVO, duty_cycle=0, frequency=50)
blocker_servo = servo.Servo(pwm)

# DISPLAY

displayio.release_displays()
i2c = busio.I2C(board.GP5, board.GP4)
display_bus = displayio.I2CDisplay(i2c, device_address=0x3C)
display = adafruit_displayio_ssd1306.SSD1306(display_bus, 
    width=DISPLAY_SIZE[0], height=DISPLAY_SIZE[1])

splash = displayio.Group()
display.show(splash)

palette = displayio.Palette(1)
palette[0] = 0x000000

color_bitmap = displayio.Bitmap(DISPLAY_SIZE[0], DISPLAY_SIZE[1], 1)
bg_sprite = displayio.TileGrid(color_bitmap, pixel_shader=palette, x=0, y=0)
splash.append(bg_sprite)

splash.append(label.Label(
    terminalio.FONT, text="CYCLES:", color=0xFFFFFF, x=25, y=4
))

splash.append(label.Label(
    terminalio.FONT, text="ELAPSED:", color=0xFFFFFF, x=25, y=16
))

splash.append(Rect(19, 0, 1, 20, fill=0xFFFFFF))

num_cycles_label        = label.Label(terminalio.FONT, text="?", color=0xFFFFFF, x=76, y=4)
time_elapsed_label      = label.Label(terminalio.FONT, text="?", color=0xFFFFFF, x=76, y=16)
time_till_trigger_label = label.Label(terminalio.FONT, text="?", color=0xFFFFFF, x=DISPLAY_SIZE[0]-18, y=DISPLAY_SIZE[1]-4)
mode_label              = label.Label(terminalio.FONT, text="?", color=0xFFFFFF, x=3, y=10)

splash.append(num_cycles_label)
splash.append(time_elapsed_label)
splash.append(time_till_trigger_label)
splash.append(mode_label)

r1 = Rect(0, DISPLAY_SIZE[1]-8, 34, 8, fill=0xFFFFFF)
r2 = Rect(36, DISPLAY_SIZE[1]-8, 34, 8, fill=0xFFFFFF)
r3 = Rect(72, DISPLAY_SIZE[1]-8, 34, 8, fill=0xFFFFFF)
r4 = Rect(1, DISPLAY_SIZE[1]-7, DISPLAY_SIZE[0]-24, 6, fill=0x000000) # must be last element added to group splash

splash.append(r1)
splash.append(r2)
splash.append(r3)
splash.append(r4)

print("> init")

# ---

def trigger():

    trigger_focus.value = True
    sleep(1.0)
    trigger_shutter.value = True
    sleep(1.0)
    trigger_shutter.value = False
    trigger_focus.value = False
    sleep(1.0)

    print("trigger")


def _time_string(t):
    s = int(t % 60)
    m = t // 60
    h = t // 3600

    return "{:02}:{:02}:{:02}".format(h, m, s)


def display():

    time_till_trigger = int(cycle_start + INTERVAL_M*3 - time.monotonic())

    num_cycles_label.text = str(num_cycles)
    time_till_trigger_label.text = "{}".format(time_till_trigger)
    mode_label.text = mode
    time_elapsed_label.text = _time_string((time.monotonic() - time_start))

    progress = int((DISPLAY_SIZE[0]-24) * (time.monotonic()-cycle_start)/(INTERVAL_M*3))
    if progress > 0:
        splash.pop()
        splash.append(Rect(1, DISPLAY_SIZE[1]-7, progress, 6, fill=0x000000))


def sleep_till(t):
    while True:
        diff = (t-time.monotonic())

        if diff < 0:
            print("warning: negative sleep time!")
            return
        if diff < SLEEP_DURATION:
            time.sleep(diff)
            return
        else:
            time.sleep(SLEEP_DURATION)
            display()


def sleep(s):
    sleep_till(time.monotonic()+s)


time_start = time.monotonic()
cycle_start = time_start

while True:

    cycle_start = time.monotonic()
    num_cycles += 1

    blocker_servo.angle = SERVO_ANGLE_M  # M1
    mode = "M1"
    sleep(2)                             #   2
    trigger()                            #   5  -- 2
    sleep(2)                             #   7

    blocker_servo.angle = SERVO_ANGLE_A  # A1
    mode = "A1"
    sleep(2)                             #   9
    trigger()                            #  12  -- 9
    sleep_till(cycle_start+INTERVAL_M)   #  45       

    blocker_servo.angle = SERVO_ANGLE_M
    mode = "M2"
    sleep(2)          
    trigger()                            # M2   -- 2 + 45
    sleep_till(cycle_start+INTERVAL_M*2)             

    mode = "M3"
    sleep(2)
    trigger()                            # M3   -- 2 + 45 + 45
    sleep_till(cycle_start+INTERVAL_M*3) # 135