#!/usr/bin/env python3

from time import sleep
from datetime import datetime, timedelta
import os
import sys
import argparse
import subprocess
import logging

import exifread
# from picamera import PiCamera

try:
    from picamera import PiCamera
except ModuleNotFoundError as e:
    print("no picamera! import failed")

from devices import TimeboxController

MIN_SHUTTER_SPEED       = 16 
SHUTDOWN_ON_COMPLETE    = True 

INTERVAL                = 60 # in sec
MAX_ITERATIONS          = 3000

OUTPUT_DIR              = "captures"
OUTPUT_FILENAME         = "cap"

SERIAL_PORT             = "/dev/ttyAMA0"

""" INFO:

The maximum resolution of the V2 camera may require additional GPU memory when operating at low framerates (<1fps). 
Increase gpu_mem in /boot/config.txt if you encounter “out of resources” errors when attempting long-exposure captures with a V2 module.

The maximum exposure time is currently 6 seconds on the V1 camera module, and 10 seconds on the V2 camera module. 
Remember that exposure time is limited by framerate, so you need to set an extremely slow framerate before setting shutter_speed.

-- from: https://picamera.readthedocs.io/en/release-1.13/fov.html#hardware-limits

PiCamera creates problems when used with python 3.8.1

-- from: https://github.com/waveform80/picamera/issues/604

To use the Raspberry Pi Camera the extended GPU firmware is required.
Raspbian: start_x=1 in config.txt needs to be set
Buildroot: Hardware Handling -> Firmware -> Extended (but no start_x=1)

PiCamera needs at least 128mb of GPU memory. In config.txt:
gpu_mem_256=128

"""

def read_exif_data(filename):

    f = open(filename, 'rb')
    metadata = exifread.process_file(f)

    # for tag in metadata.keys():
    #     if tag not in ('JPEGThumbnail', 'TIFFThumbnail', 'Filename', 'EXIF MakerNote'):
    #         print("Key: {}, value {}".format(tag, metadata[tag]))

    exposure_time = metadata["EXIF ExposureTime"].values[0]
    exposure_time = float(exposure_time.num) / float(exposure_time.den)

    aperture = metadata["EXIF FNumber"].values[0]

    iso = float(metadata["EXIF ISOSpeedRatings"].values[0])

    print("Exif exposure time: {}".format(exposure_time))
    print("Exif aperture     : {}".format(aperture))
    print("Exif ISO          : {}".format(iso))


def print_exposure_settings(camera):

    STATETMENT = "{:25s}: {}"

    print(STATETMENT.format("Shutter speed (0=auto)", camera.shutter_speed))
    print(STATETMENT.format("ISO", camera.iso))
    print(STATETMENT.format("Analog gain", camera.analog_gain))
    print(STATETMENT.format("Digital gain", camera.digital_gain))
    print(STATETMENT.format("Exp speed", camera.exposure_speed))
    print(STATETMENT.format("Exp mode", camera.exposure_mode))
    print(STATETMENT.format("Exp compensation", camera.exposure_compensation))
    print(STATETMENT.format("Framerate", camera.framerate))
    print(STATETMENT.format("brightness", camera.brightness))
    print(STATETMENT.format("Awb mode", camera.awb_mode))
    print(STATETMENT.format("Drc strength", camera.drc_strength))
    print(STATETMENT.format("Brightness meter mode", camera.meter_mode))
    print(STATETMENT.format("Resolution", camera.resolution))

    print("--- --- ---")


def log_capture_info(camera, filename):

    STATETMENT = "{:15s}: {}"

    log.info(STATETMENT.format("filename", filename))
    log.info(STATETMENT.format("shutter speed", camera.shutter_speed))
    log.info(STATETMENT.format("iso", camera.iso))


def get_filename():

    for i in range(0, 100000):
        file_candidate = os.path.join(OUTPUT_DIR, "{}_{}.jpg".format(OUTPUT_FILENAME, i))
        if not os.path.exists(file_candidate):
            return file_candidate

    raise Exception("no filenames left!")


def global_except_hook(exctype, value, traceback):
    
    log = logging.getLogger()

    log.error("global error: {} | {}".format(exctype, value))
    print(traceback)
        
    # sys.__excepthook__(exctype, value, traceback)


def trigger():

    camera = PiCamera() # starts hidden preview for 3A automatically
    camera.resolution = (2592, 1944)
    # camera.resolution = (3280, 2464)
    camera.framerate = 1

    sleep(2)

    filename = get_filename()
    camera.capture(filename)
    log_capture_info(camera, filename)

    # read_exif_data(filename)
    # print_exposure_settings(camera)

    camera.iso = 100
    camera.exposure_mode = "off"
    # camera.exposure_speed = MIN_SHUTTER_SPEED
    camera.shutter_speed = MIN_SHUTTER_SPEED

    sleep(0.5)

    # print_exposure_settings(camera)
    filename = get_filename()
    camera.capture(filename)
    log_capture_info(camera, filename)

    # read_exif_data(filename)

    camera.close()


def run():

    if args["persistent_mode"]:
        log.info("PERSISTENT MODE")
        for i in range(0, MAX_ITERATIONS):
            log.info("iteration: {}/{}".format(i, MAX_ITERATIONS))
            next_trigger = datetime.now() + timedelta(seconds=INTERVAL)
            
            trigger()
            
            remaining_time = next_trigger-datetime.now()
            log.debug("sleep time till trigger: {}".format(remaining_time.total_seconds()))
            sleep(remaining_time.total_seconds())
    else:
        trigger()

        log.debug("total runtime: {:.3f} sec".format((datetime.now()-start).total_seconds()))


if __name__ == "__main__":

    start = datetime.now()

    # ---------------------------------------------------------------------------------------

    log_filename = "trashcam.log"

    # create logger
    log = logging.getLogger() #"oneshot")
    log.setLevel(logging.DEBUG)

    # subloggers
    exifread_logger = logging.getLogger("exifread").setLevel(logging.INFO)
    devices_logger = logging.getLogger("devices").setLevel(logging.INFO)

    # create formatter
    formatter = logging.Formatter("%(asctime)s | %(name)-7s | %(levelname)-7s | %(message)s")
    # formatter = logging.Formatter("%(asctime)s | %(levelname)-7s | %(message)s")

    # console handler and set level to debug
    consoleHandler = logging.StreamHandler()
    consoleHandler.setLevel(logging.DEBUG)
    consoleHandler.setFormatter(formatter)
    log.addHandler(consoleHandler)

    fileHandlerDebug = logging.FileHandler(log_filename, mode="a", encoding="UTF-8")
    fileHandlerDebug.setLevel(logging.DEBUG)
    fileHandlerDebug.setFormatter(formatter)
    log.addHandler(fileHandlerDebug)

    sys.excepthook = global_except_hook

    # ---------------------------------------------------------------------------------------

    # TODO: wifi off
    try:
        subprocess.call(["ifdown", "wlan0"])
    except Exception as e:
        log.info("disabling wifi error: {}".format(e))

    # TODO: tvservice off
    try:
        subprocess.call(["tvservice", "-o"])    
    except Exception as e:
        log.info("disabling tvservice error: {}".format(e))

    # ---------------------------------------------------------------------------------------

    log.info("-------------")
    log.info("trashcam init")

    ap = argparse.ArgumentParser()
    ap.add_argument("-p", "--persistent-mode", type=bool, default=False, help="")
    args = vars(ap.parse_args())

    try: 
        os.makedirs(OUTPUT_DIR)
        log.debug("created dir: {}".format(OUTPUT_DIR))
    except FileExistsError as e:
        pass

    try:
        run()
    except Exception as e:
        log.error("error: {}".format(e))

    # ---------------------------------------------------------------------------------------

    if SHUTDOWN_ON_COMPLETE:

        controller = TimeboxController.find_by_portname(SERIAL_PORT)

        if controller is not None:
            try:
                log.debug("controller found: {}".format(controller))

                log.info("battery: {}".format(controller.get_battery_status()))
                log.info("temperature: {}".format(controller.get_temperature()))

                controller.shutdown(delay=11000)

                log.debug("shutdown command sent")
                log.info("POWEROFF")
                
                log.debug("logging shutdown")
                logging.shutdown()

                subprocess.call(["sync"])

                time.sleep(0.5)
                subprocess.call(["poweroff"])
            except Exception as e:
                log.error("poweroff failed: {}".format(e))
        else:
            log.error("poweroff failed: {}".format("no controller found"))

    log.debug("logging shutdown")
    logging.shutdown()

