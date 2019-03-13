import board
import digitalio

import sys
import time
import supervisor


input_buffer = ""


def init_pins():
    pass

def communicate():
    global input_buffer

    if(supervisor.runtime.serial_bytes_available):
        c = sys.stdin.read(1)

        if c != "\n":
            input_buffer += c

            if len(input_buffer) > 100:
                input_buffer = ""
                print("E buffer length exceeded")
        else:

            if input_buffer == "ping":
                print("K")
            if input_buffer == "on":
                # TODO
                print("K")
            elif input_buffer == "off":
                # TODO
                print("K")
            else:
                print("E unknown command")

            input_buffer = ""


if __name__ == "__main__":

    init_pins()

    while True:
        communicate()
        time.sleep(0.1)