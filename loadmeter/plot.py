import serial
import time
import sys

import matplotlib.pyplot as plt
import matplotlib.animation as animation
import numpy as np

PORT = "/dev/tty.usbmodem1411"

counter         = []
busvoltage      = []
shuntvoltage    = []
loadvoltage     = []
current         = []

def update(arg):
    # raw = ser.readline()
    # payload = raw.split(" ")
    # print payload

    # counter.append(int(payload[0]))
    # busvoltage.append(float(payload[1]))
    # shuntvoltage.append(float(payload[2]))
    # loadvoltage.append(float(payload[3]))
    # current.append(float(payload[4]))

    counter.append(0.05)
    busvoltage.append(0.03)

    line.set_xdata(counter)
    line.set_ydata(busvoltage)
    return line,

if len(sys.argv) > 1 and sys.argv[1] == "--noreset":
    pass
else:
    ser = serial.Serial()
    ser.port = PORT

    # reset leonardo 
    ser.baudrate=1200 # set the reset baudrate
    ser.open()
    ser.close()
    time.sleep(9.0) # sleep. reset time is 8s

# init serial port
# ser = serial.Serial(PORT, 9600)

fig, ax = plt.subplots()
line, = ax.plot([], [])
#ax.set_ylim(0, 1)

ani = animation.FuncAnimation(fig, update, interval=500)
plt.show(block=True)

# try:
#     while True:
#        raw = ser.readline()
#        payload = raw.split(" ")
#        print payload
#        update_line(hl, int(payload[0]))
# except KeyboardInterrupt as e:
#     if ser is not None:
#         ser.close()
