import serial

SERIAL_DEVICE = "/dev/cu.usbmodem62140401"
SERIAL_BAUDRATE = 115200
SERIAL_TIMEOUT = 1.0

ser = serial.Serial(SERIAL_DEVICE, SERIAL_BAUDRATE, timeout=SERIAL_TIMEOUT)

OUTPUT = "\r voltage: {:7.2f} | current: {:7.4f} | power: {:7.2f}   "

while True:

    response = ser.readline()

    if response is None:
        continue

    response = response.decode("utf-8") 
    values = response.split(" ")

    if len(values) == 4:
        print(OUTPUT.format(float(values[1]), float(values[2]), float(values[3])), end=" ")