import time
import board
import pwmio
from digitalio import DigitalInOut, Direction

from adafruit_motor import servo

SERVO_ANGLE_M   = 30
SERVO_ANGLE_A   = 155

INTERVAL_M      = 60
INTERVAL_A      = 180

trigger_focus = DigitalInOut(board.GP14)
trigger_shutter = DigitalInOut(board.GP15)
trigger_focus.direction = Direction.OUTPUT
trigger_shutter.direction = Direction.OUTPUT

trigger_focus.value = True
trigger_shutter.value = True

pwm = pwmio.PWMOut(board.A2, duty_cycle=0, frequency=50)
blocker_servo = servo.Servo(pwm)

# ---

def trigger():

    trigger_focus.value = False
    time.sleep(1.0)
    trigger_shutter.value = False
    time.sleep(1.0)
    trigger_shutter.value = True
    trigger_focus.value = True
    time.sleep(1.0)


print("> init")

while True:

    blocker_servo.angle = SERVO_ANGLE_M  # M1
    time.sleep(3.0)                      #   3
    trigger()                            #   6
    time.sleep(3.0)                      #   9
    print("capture M1")

    blocker_servo.angle = SERVO_ANGLE_A  # A1
    time.sleep(6.0)                      #  15
    trigger()                            #  18
    print("capture A1")
    time.sleep(30)                       #  48       

    blocker_servo.angle = SERVO_ANGLE_M
    time.sleep(INTERVAL_M-48)            #  60

    trigger()                            # M2
    print("capture M2")
    time.sleep(INTERVAL_M-3.0)           # 120

    trigger()                            # M3
    print("capture M3")
    time.sleep(INTERVAL_M-3.0)           # 180