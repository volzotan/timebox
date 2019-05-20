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
    timer_dload = None # time.monotonic() # dummy load on by default

    i2c = busio.I2C(board.SCL, board.SDA)
    ina219 = adafruit_ina219.INA219(i2c)

    # current consumption ring buffer 
    ina_current_time = [None] * 100
    ina_current_value = [None] * 100
    ina_current_index = 0

    pixel = neopixel.NeoPixel(PIN_LED, 1, brightness=0.1, auto_write=True)

    button = DigitalInOut(PIN_BUTTON)
    button.direction = Direction.INPUT
    button.pull = Pull.UP

    mosfet = DigitalInOut(PIN_USB_EN)
    mosfet.direction = Direction.OUTPUT
    mosfet.value = False

    dummy_load = DigitalInOut(PIN_DLOAD)
    dummy_load.direction = Direction.OUTPUT

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
                self.dummy_load.value = False
                self.timer_dload = self.timer_dload - self.TIMER_DLOAD_DUR + self.TIMER_DLOAD_INT
            else:
                # print(">")
                self.dummy_load.value = True
                self.timer_dload = self.timer_dload + self.TIMER_DLOAD_DUR


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

                if self.input_buffer == "ping":
                    print("K")

                elif self.input_buffer == "on":
                    self.mosfet.value = True
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

                elif self.input_buffer == "status":
                    print("K ", sep="")

                    print("Bus Voltage:   {} V".format(self.ina219.bus_voltage))
                    print("Shunt Voltage: {} mV".format(self.ina219.shunt_voltage / 1000))
                    print("Load Voltage:  {} V".format(self.ina219.bus_voltage + self.ina219.shunt_voltage))
                    print("Current:       {} mA".format(self.ina219.current))

                elif self.input_buffer == "status v":
                    print("K ", sep="")
                    print(self.ina_current_value)

                else:
                    print("E unknown command")

                self.input_buffer = ""


    def loop(self):

        while True:
            self.communicate()
            self.event()
            self.read_current()
            time.sleep(0.010)


if __name__ == "__main__":

    c = UsbController()
    c.loop()

