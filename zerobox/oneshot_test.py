# from zerobox import Zerobox
# from devices import Controller

import logging
import traceback

from datetime import datetime, timedelta
import time
import os
import subprocess
import sys
import math
import shutil

import exifread
import numpy as np

USE_EXPOSURE_THRESHOLD  = True
EXPOSURE_THRESHOLD      = 10.5 

EXPOSURE_1 = 1
EXPOSURE_2 = -5

FILE_EXTENSION = ".arw"

def _gphoto(cmd, *args): #, **kwargs):
    try:
        arguments = ["gphoto2"]

        if type(cmd) is list:
            for c in cmd:
                arguments.append("--{}".format(c))
        else:
            arguments.append("--{}".format(cmd))

        for arg in args:
            arguments.append(arg)

        print(arguments)

        output = subprocess.check_output(arguments)
        output = output.decode("UTF-8")
        output = output.split("\n")
        return output
    except Exception as e:
        raise e

class Oneshot():

    def __init__(self):
        print("init")
        self.init_log()

        # Pi Zero Maintenance stuff
        # Turn off HDMI to save power
        # try:
        #     subprocess.call("/usr/bin/tvservice -o", shell=True)
        # except Exception as e:
        #     pass


    def init_log(self):
        log_filename_debug = "debug.log"
        log_filename_info = "info.log"

        # create logger
        self.log = logging.getLogger()
        self.log.setLevel(logging.DEBUG)

        # remove prior logging handlers
        try:
            self.log.handlers.pop()
        except Exception as e:
            pass

        # create formatter
        formatter = logging.Formatter("%(asctime)s | %(levelname)-7s | %(message)s")

        # console handler and set level to debug
        consoleHandler = logging.StreamHandler()
        consoleHandler.setLevel(logging.DEBUG)
        consoleHandler.setFormatter(formatter)
        self.log.addHandler(consoleHandler)

        fileHandlerDebug = logging.FileHandler(log_filename_debug, mode="a", encoding="UTF-8")
        fileHandlerDebug.setLevel(logging.DEBUG)
        fileHandlerDebug.setFormatter(formatter)
        self.log.addHandler(fileHandlerDebug)

        fileHandlerInfo = logging.FileHandler(log_filename_info, mode="a", encoding="UTF-8")
        fileHandlerInfo.setLevel(logging.INFO)
        fileHandlerInfo.setFormatter(formatter)
        self.log.addHandler(fileHandlerInfo)

    def _acquire_filename(self, path):
        filename = None

        for i in range(0, 9999):
            name = i
            name = str(name).zfill(4)
            testname = name + FILE_EXTENSION
            if not os.path.exists(os.path.join(path, testname)):
                filename = testname
                break

        self.log.debug("acquired filename: {}".format(filename))

        return (path, filename)

    def _set_config_value(self, name, value):
        _gphoto("set-config-value", "{}={}".format(name, value))

    def set_exposure_compensation(self, compensation):
        self._set_config_value("/main/capturesettings/exposurecompensation", compensation)

    def capture_and_download(self, filename):
        try:
            _gphoto(["capture-image-and-download", "force-overwrite"])
            if not os.path.exists("capt0000.arw"):
                raise Exception("captured RAW file missing")
            shutil.move("capt0000.arw", os.path.join(*filename))
            self.log.debug("camera save done: {}".format(filename[1]))
        except Exception as e:
            raise e

    def _calculate_brightness(self, full_name):

        with open(full_name, "rb") as image_file:
            metadata = exifread.process_file(image_file)

        exposure_time = metadata["EXIF ExposureTime"].values[0]
        if exposure_time.num == 0 or exposure_time.den == 0:
            shutter = 0
        else:
            shutter = float(exposure_time.num) / float(exposure_time.den)

        iso = float(metadata["EXIF ISOSpeedRatings"].values[0])

        aperture = metadata["EXIF FNumber"].values[0]
        
        if aperture.num == 0 or aperture.den == 0:
            aperture = 0
        else:
            aperture = aperture.num / aperture.den

        if aperture <= 0:
            # no aperture tag set, probably an lens adapter was used. assume fixed aperture.
            aperture = 8.0

        # print("brightness:: shutter: {} | aperture: {} | iso: {}".format(shutter, aperture, iso))

        return self._intensity(shutter, aperture, iso)

    def _intensity(self, shutter, aperture, iso):

        # limits in this calculations:
        # min shutter is 1/4000th second
        # min aperture is 22
        # min iso is 100

        shutter_repr    = math.log(shutter, 2) + 13 # offset = 13 to accomodate shutter values down to 1/4000th second
        iso_repr        = math.log(iso/100, 2) + 1  # offset = 1, iso 100 -> 1, not 0

        if aperture is not None:
            aperture_repr = np.interp(math.log(aperture, 2), [0, 4.5], [10, 1])
        else:
            aperture_repr = 1

        return shutter_repr + aperture_repr + iso_repr

    def run(self):

        filename = self._acquire_filename(".")
        self.capture_and_download(filename)

        trigger_second_exposure = True

        if USE_EXPOSURE_THRESHOLD:
            image_full_name = os.path.join(filename[0], filename[1])
            exposure = self._calculate_brightness(image_full_name)
            self.log.info("exposure: {:.3f}".format(exposure))

            if exposure > EXPOSURE_THRESHOLD:
                trigger_second_exposure = False

        if trigger_second_exposure:
            self.set_exposure_compensation(EXPOSURE_2)
            filename2 = (filename[0], filename[1] + "_2")
            self.capture_and_download(filename2)
            self.set_exposure_compensation(EXPOSURE_1)

    def close(self):
        pass


if __name__ == "__main__":

    start = datetime.now()
    print("start: {}".format(start))
    oneshot = Oneshot()
    
    try:
        oneshot.run()
    except Exception as e:
        print(e)
    finally:
        oneshot.close()
    
    print("total runtime: {:.3f} sec".format((datetime.now()-start).total_seconds()))
