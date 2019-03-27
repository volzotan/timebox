import sys
import time
import supervisor

import board
from digitalio import DigitalInOut, Direction, Pull

import busio
import adafruit_ina219

import neopixel

PIN_BUTTON      = board.D11 # PA16
PIN_USB_EN      = board.D7  # PA21
PIN_LED         = board.D13 # PA17 
PIN_DLOAD       = board.D10 # PA18

# see for pinout:
# https://circuitpython.readthedocs.io/en/3.x/ports/atmel-samd/README.html#pinout

input_buffer = ""

# i2c = busio.I2C(board.SCL, board.SDA)
# ina219 = adafruit_ina219.INA219(i2c)

RED = (255, 0, 0)
YELLOW = (255, 150, 0)
GREEN = (0, 255, 0)
BLUE = (0, 0, 255)
CLEAR = (0, 0, 0)
pixel = neopixel.NeoPixel(PIN_LED, 1, brightness=0.3, auto_write=True)

def communicate():
    global input_buffer

    if supervisor.runtime.serial_bytes_available:
        c = sys.stdin.read(1)

        if c != "\n":
            input_buffer += c

            if len(input_buffer) > 100:
                input_buffer = ""
                print("E buffer length exceeded")
        else:

            if input_buffer == "ping":
                print("K")

            elif input_buffer == "on":
                # TODO
                print("K")

            elif input_buffer == "off":
                # TODO
                print("K")

            elif input_buffer == "status":
                print("K ", sep="")
                print(0)

            else:
                print("E unknown command")

            input_buffer = ""


if __name__ == "__main__":

    # init pins

    button = DigitalInOut(PIN_BUTTON)
    button.direction = Direction.INPUT
    button.pull = Pull.UP

    mosfet = DigitalInOut(PIN_USB_EN)
    mosfet.direction = Direction.OUTPUT
    # mosfet.pull = Pull.DOWN

    dummy_load = DigitalInOut(PIN_DLOAD)
    dummy_load.direction = Direction.OUTPUT

    # LED status

    pixel.fill(GREEN)
    time.sleep(1.0)
    pixel.fill(CLEAR)

    # print("Bus Voltage:   {} V".format(ina219.bus_voltage))
    # print("Shunt Voltage: {} mV".format(ina219.shunt_voltage / 1000))
    # print("Load Voltage:  {} V".format(ina219.bus_voltage + ina219.shunt_voltage))
    # print("Current:       {} mA".format(ina219.current))

    while True:
        communicate()
        time.sleep(0.1)