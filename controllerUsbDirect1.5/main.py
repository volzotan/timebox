import sys
import time
import supervisor

import board
from digitalio import DigitalInOut, Direction, Pull
from pulseio import PWMOut

import busio
import adafruit_mcp9808

import neopixel

PIN_BUTTON      = board.D11 # PA16
PIN_USB_EN      = board.D7  # PA21
PIN_LED         = board.D13 # PA17 
PIN_DLOAD       = board.D10 # PA18

# see for pinout:
# https://circuitpython.readthedocs.io/en/3.x/ports/atmel-samd/README.html#pinout

RED = (255, 0, 0)
YELLOW = (255, 150, 0)
GREEN = (0, 255, 0)
BLUE = (0, 0, 255)
WHITE = (255, 255, 255)
CLEAR = (0, 0, 0)


class UsbController(object):

    TIMER_DLOAD_INT = 1.000
    TIMER_DLOAD_DUR = 0.010

    input_buffer = ""

    # timer
    timer_dload = None #time.monotonic() # dummy load on by default # None

    # i2c = busio.I2C(board.SCL, board.SDA)
    # ina219 = adafruit_ina219.INA219(i2c)

    # current consumption ring buffer 
    # ina_current_time = [None] * 100
    # ina_current_value = [None] * 100
    # ina_current_index = 0

    i2c = busio.I2C(board.SCL, board.SDA)
    temp_sensor = adafruit_mcp9808.MCP9808(i2c)

    pixel = neopixel.NeoPixel(PIN_LED, 1, auto_write=True) # , brightness=0.1)

    button = DigitalInOut(PIN_BUTTON)
    button.direction = Direction.INPUT
    button.pull = Pull.UP

    mosfet = DigitalInOut(PIN_USB_EN)
    mosfet.direction = Direction.OUTPUT
    mosfet.value = False

    dummy_load = DigitalInOut(PIN_DLOAD)
    dummy_load.direction = Direction.OUTPUT
    dummy_load_pixel = False
    dummy_load_paused = None

    def __init__(self):     

        # print("INIT")

        # LED status
        self.pixel.fill(GREEN)
        self.pixel.show()
        time.sleep(1.0)
        self.pixel.fill(CLEAR)


    def event(self):

        now = time.monotonic()

        if self.timer_dload is not None and now - self.timer_dload > 0:
            if self.dummy_load.value:
                # print("< {}".format(now - self.timer_dload))
                if self.dummy_load_pixel:
                    self.pixel.fill(CLEAR)
                    self.pixel.show()
                else:
                    self.dummy_load.value = False

                self.timer_dload = self.timer_dload - self.TIMER_DLOAD_DUR + self.TIMER_DLOAD_INT
            else:

                if not self.mosfet.value:
                    # print(">")
                    if self.dummy_load_pixel:
                        self.pixel.fill(WHITE)
                        self.pixel.show()
                    else:
                        self.dummy_load.value = True
                    self.timer_dload = self.timer_dload + self.TIMER_DLOAD_DUR
                    if now - self.timer_dload > 0:
                        self.timer_dload = now + self.TIMER_DLOAD_DUR


    def read_current(self):

        last_index = self.ina_current_index-1%100
        now = time.monotonic()

        if self.ina_current_time[last_index] is not None:
            if now - self.ina_current_time[last_index] < 0.500:
                return
        
        self.ina_current_time[self.ina_current_index] = now
        self.ina_current_value[self.ina_current_index] = self.ina219.current
        self.ina_current_index = (self.ina_current_index + 1) % 100
                           

    def communicate(self):

        if supervisor.runtime.serial_bytes_available:
            c = sys.stdin.read(1)

            if c != "\n":
                self.input_buffer += c

                if len(self.input_buffer) > 100:
                    self.input_buffer = ""
                    print("E buffer length exceeded")
            else:

                if self.input_buffer == "knock":
                    print("K")

                elif self.input_buffer == "on":
                    self.mosfet.value = True
                    time.sleep(0.1)
                    self.pixel.fill(WHITE)
                    self.pixel.show()
                    print("K")

                elif self.input_buffer == "off":
                    self.mosfet.value = False
                    self.pixel.fill(CLEAR)
                    self.pixel.show()
                    print("K")

                elif self.input_buffer == "dummyload on":
                    self.timer_dload = time.monotonic()
                    print("K")

                elif self.input_buffer == "dummyload off":
                    self.timer_dload = None
                    self.dummy_load.value = False
                    print("K")

                elif self.input_buffer == "led on":
                    self.pixel.fill(YELLOW)
                    self.pixel.show()
                    print("K")

                elif self.input_buffer == "led off":
                    self.pixel.fill(CLEAR)
                    self.pixel.show()
                    print("K")

                elif self.input_buffer == "temp":
                    print("K ", sep="")
                    print(self.temp_sensor.temperature)

                elif self.input_buffer == "status":
                    print("K null")

                # elif self.input_buffer == "status v":
                #     print("K ", sep="")
                #     print(self.ina_current_value)

                else:
                    print("E unknown command")

                self.input_buffer = ""


    def loop(self):

        while True:
            self.communicate()
            self.event()
            # self.read_current()
            time.sleep(0.010)


if __name__ == "__main__":

    c = UsbController()
    c.loop()

