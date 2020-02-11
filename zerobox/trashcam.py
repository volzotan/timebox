#!/usr/bin/env python3

from time import sleep
from datetime import datetime, timedelta
import os
import subprocess
import logging

from picamera import PiCamera
import exifread

from devices import TimeboxController

MIN_SHUTTER_SPEED       = 16 
SHUTDOWN_ON_COMPLETE    = False 

OUTPUT_DIR              = "captures"
OUTPUT_FILENAME         = "cap"

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


def get_filename():

    for i in range(0, 100000):
        file_candidate = os.path.join(OUTPUT_DIR, "{}_{}.jpg".format(OUTPUT_FILENAME, i))
        if not os.path.exists(file_candidate):
            return file_candidate

    raise Exception("no filenames left!")

if __name__ == "__main__":

    # TODO: wifi off
    # TODO: tvservice off

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

    log.info("trashcam init")

    # ---------------------------------------------------------------------------------------

    try: 
        os.makedirs(OUTPUT_DIR)
        print("created dir: {}".format(OUTPUT_DIR))
    except FileExistsError as e:
        pass

    # ---------------------------------------------------------------------------------------

    camera = PiCamera() # starts hidden preview for 3A automatically
    camera.resolution = (2592, 1944)
    # camera.resolution = (3280, 2464)
    camera.framerate = 1

    sleep(1)

    filename = get_filename()
    camera.capture(filename)
    read_exif_data(filename)
    print_exposure_settings(camera)

    camera.iso = 100
    camera.exposure_mode = "off"
    # camera.exposure_speed = MIN_SHUTTER_SPEED
    camera.shutter_speed = MIN_SHUTTER_SPEED

    sleep(1)

    print_exposure_settings(camera)
    filename = get_filename()
    camera.capture(filename)
    read_exif_data(filename)

    camera.close()

    log.debug("total runtime: {:.3f} sec".format((datetime.now()-start).total_seconds()))

    if SHUTDOWN_ON_COMPLETE:

        controller = TimeboxController.find_all()
        # TODO: don't try to find, use /dev/serial0



        log.debug("controller found: {}".format(len(controller)))

        if len(controller) > 0:
            try:

                log.info("battery: {}".format(controller[0].get_battery_status()))
                log.info("temperature: {}".format(controller[0].get_temperature()))

                controller[0].shutdown(delay=11000)

                log.debug("shutdown command sent")
                log.info("POWEROFF")
                
                log.debug("logging shutdown")
                logging.shutdown()

                # write the last log statements to disk
                # and prepare the filesystem for shutdown
                subprocess.call(["sync"])
                # subprocess.call(["swapoff", "-a"])
                # subprocess.call(["umount -a -r"])

                time.sleep(0.5)
                subprocess.call(["poweroff"])
            except Exception as e:
                log.error("poweroff failed: {}".format(e))
        else:
            log.error("poweroff failed: {}".format("no controller found"))

    log.debug("logging shutdown")
    logging.shutdown()

