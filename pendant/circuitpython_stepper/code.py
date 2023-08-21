import board
from digitalio import DigitalInOut, Direction
from adafruit_motor import stepper

import time

pin1 = DigitalInOut(board.GP0)
pin2 = DigitalInOut(board.GP1)
pin3 = DigitalInOut(board.GP2)
pin4 = DigitalInOut(board.GP3)

pin1.direction = Direction.OUTPUT
pin2.direction = Direction.OUTPUT
pin3.direction = Direction.OUTPUT
pin4.direction = Direction.OUTPUT

motor1 = stepper.StepperMotor(pin1, pin2, pin3, pin4, microsteps=None)

for i in range(150*2):
    motor1.onestep(direction=stepper.FORWARD, style=stepper.DOUBLE)
    # motor1.onestep(direction=stepper.BACKWARD, style=stepper.DOUBLE)
    time.sleep(.02)

motor1.release()