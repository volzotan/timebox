import os
import sys
import traceback
import subprocess
import time
import shutil
import datetime
import math
import logging
import numpy as np
import serial

import gi
gi.require_version('GExiv2', '0.10')
from gi.repository import GExiv2

# --- --- --- --- --- --- --- --- --- ---
"""

Camera set to   USB Connection  : PC Remote Control
                USB-LUN-Setting : Multi 


"""
# --- --- --- --- --- --- --- --- --- ---

DEBUG               = True

LOG_BASE_DIR        = "./"
LOG_FILENAME_DEBUG  = "debug.log"
LOG_FILENAME_INFO   = "info.log"
LOG_LEVEL_CONSOLE   = logging.DEBUG 

RAW_DIR             = None # platform dependent
FILE_EXTENSION      = ".arw"

SERIAL_PORT         = "/dev/ttyAMA0"
SERIAL_BAUDRATE     = 9600
SERIAL_TIMEOUT      = 1 # in sec

REPEAT_MODE         = False
REPEAT_INTERVAL     = 20
REPERAT_ITERATIONS  = 120

AUTOFOCUS_ENABLED   = False
DOUBLEEXPOSURE_ENABLED = True
WAIT_EXPOSURE_COMP  = 0
WAIT_AUTOFOCUS      = 1

EXPOSURE_THRESHOLD  = 10
FREE_DISK_THRESHOLD = 100 * 1024 * 1024

EXPOSURE_LOW        = -5
EXPOSURE_NORMAL     = +1

EXIF_DATE_FORMAT    = '%Y:%m:%d %H:%M:%S'

# --- --- --- --- --- --- --- --- --- ---

PLATFORM            = None
log                 = None

def initLog():
    global log
    global LOG_FILENAME_DEBUG
    global LOG_FILENAME_INFO

    if not os.path.exists(LOG_BASE_DIR):
        print("LOG DIR missing. create...")
        os.makedirs(LOG_BASE_DIR)

    LOG_FILENAME_DEBUG = os.path.join(LOG_BASE_DIR, LOG_FILENAME_DEBUG)
    LOG_FILENAME_INFO = os.path.join(LOG_BASE_DIR, LOG_FILENAME_INFO)

    # create logger
    log = logging.getLogger()
    log.setLevel(logging.DEBUG)

    # create formatter
    formatter = logging.Formatter('%(asctime)s | %(levelname)-7s | %(message)s')

    # console handler and set level to debug
    consoleHandler = logging.StreamHandler()
    consoleHandler.setLevel(LOG_LEVEL_CONSOLE)
    consoleHandler.setFormatter(formatter)
    log.addHandler(consoleHandler)

    fileHandlerDebug = logging.FileHandler(LOG_FILENAME_DEBUG, mode="a", encoding="UTF-8")
    fileHandlerDebug.setLevel(logging.DEBUG)
    fileHandlerDebug.setFormatter(formatter)
    log.addHandler(fileHandlerDebug)

    fileHandlerInfo = logging.FileHandler(LOG_FILENAME_INFO, mode="a", encoding="UTF-8")
    fileHandlerInfo.setLevel(logging.INFO)
    fileHandlerInfo.setFormatter(formatter)
    log.addHandler(fileHandlerInfo)


def determine_environment():
    global RAW_DIR
    global LOG_BASE_DIR
    global PLATFORM

    """
    TODO: maybe check "cat /etc/debian_version" ?
    """

    output = subprocess.check_output(["uname", "-a"]).lower()

    if "darwin" in output:
        PLATFORM = "OSX"
        LOG_BASE_DIR = "./"
        RAW_DIR = "/Users/volzotan/zerobox"
    elif "raspberrypi" in output:
        PLATFORM = "PI"
        LOG_BASE_DIR = "/home/pi/zerobox"
        RAW_DIR = "/home/pi/RAW"    
    elif "linux" in output:
        PLATFORM = "LINUX"
        RAW_DIR = "/home/pi/RAW"
    else:
        PLATFORM = "UNKNOWN"


def sendCommand(cmd):
    response = ""
    ser = None

    try:
        ser = serial.Serial(SERIAL_PORT, SERIAL_BAUDRATE, timeout=SERIAL_TIMEOUT)
        response = ser.read(100) # TODO: add parsing

        if response is None or len(response) == 0:
            raise Exception("empty response")
    except Exception as e:
        log.error("comm failed: {}".format(e))
        raise e
    finally:
        if ser is not None:
            ser.close()

    return response


def get_uptime():
    if PLATFORM == "PI":
        output = subprocess.check_output(["cat", "/proc/uptime"]).split(" ")
        return output[0]
    else:
        return str("---")


# returns (path, filename)
def acquire_filename(path):
    filename = None

    for i in range(0, 9999):
        name = i
        name = str(name).zfill(4)
        testname = name + FILE_EXTENSION
        if not os.path.exists(os.path.join(path, testname)):
            filename = testname
            break

    log.debug("acquired filename: {}".format(filename))

    return (path, filename)


def take_image(full_name):

    # be careful: if capt0000.arw is already existing, gphoto2 is offering an interactive overwrite dialog and
    # the capture-image-and-download command will never return
    output = subprocess.check_output(["gphoto2" ,"--capture-image-and-download"], stderr=subprocess.STDOUT)

    if "ERROR" in output:
        raise RuntimeError("taking image failed (gphoto2 value: {})".format(ret_val))

    camera_file = "capt0000.arw"
    shutil.copyfile(camera_file, full_name)
    os.remove(camera_file)

    log.debug("image saved to: {}".format(full_name))


def check_prerequisites():

    # working directory?
    log.debug("working dir: {}".format(os.getcwd()))
    if PLATFORM == "PI":
        os.chdir("/home/pi/zerobox")
        log.debug("new working dir: {}".format(os.getcwd()))

    # output folder present?
    if not os.path.exists(RAW_DIR):
        log.info("RAW DIR missing. create...")
        os.makedirs(RAW_DIR)

    stat = os.statvfs(RAW_DIR)
    free_bytes = stat.f_frsize * stat.f_bavail

    # check disk space
    if free_bytes < FREE_DISK_THRESHOLD:
        log.error("disk full")
        return False

    return True


def _intensity(shutter, aperture, iso):

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


def calculate_brightness(full_name):

    metadata = GExiv2.Metadata()
    metadata.open_path(full_name)

    exposure_time = metadata.get_exposure_time()
    shutter = float(exposure_time.den) / float(exposure_time.nom)
    # shutter = float(shutter[0]) / float(shutter[1])
    iso     = int(metadata.get_tag_string("Exif.Photo.ISOSpeedRatings"))

    try: 
        time = datetime.datetime.strptime(metadata.get_tag_string("Exif.Photo.DateTimeOriginal"), EXIF_DATE_FORMAT)
    except Exception as e:
        time = datetime.datetime.strptime(metadata.get_tag_string("Exif.Image.DateTime"), EXIF_DATE_FORMAT)

    aperture = metadata.get_focal_length()
    if aperture <= 0:
        # no aperture tag set, probably an lens adapter was used. assume fixed aperture.
        aperture = 8.0

    return _intensity(shutter, aperture, iso)


def convert_raw_to_jpeg(rawfile_path, rawfile_name, jpeg_path):
    # well, actually we just extract the thumbnail JPEG of the RAW
    # dcraw does not support export as JPEG and output as TIFF
    # and conversion to JPEG is unnecessary work

    # TODO: overwrite/remove jpeg image?

    rawfile_full_name   = os.path.join(rawfile_path, rawfile_name)
    thumb               = rawfile_name[:-4] + ".thumb" + ".jpg"
    thumb_full_name     = os.path.join(rawfile_path, thumb)
    jpeg_full_name      = os.path.join(jpeg_path, rawfile_name[:-4] + ".jpg")

    subprocess.call(["dcraw", "-e", format(rawfile_full_name)])     
    os.rename(thumb_full_name, jpeg_full_name)

    return jpeg_full_name


def check_camera():
    try:
        output = subprocess.check_output(["gphoto2" ,"--summary"], stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as cpe:
        log.info("first connect camera check FAIL")
        log.error(cpe)
        time.sleep(10)

        try:
            output = subprocess.check_output(["gphoto2" ,"--summary"], stderr=subprocess.STDOUT)
            log.debug("second connect SUCCESS")
        except subprocess.CalledProcessError as cpe:
            log.error("second connect FAIL")
        
            log.error(cpe)
            log.error(cpe.output)
            exit(error=True)
        except Exception as e:
            raise e
    except Exception as e:
        raise e
    else:
        log.debug("first connect successful")


def adjust_exposure(correction_value):
 
    # gphoto2 --set-config-value /main/capturesettings/exposurecompensation=-5

    output = subprocess.check_output(["gphoto2" ,"--get-config", "/main/capturesettings/exposurecompensation"], stderr=subprocess.STDOUT)
    output = output.decode().split("\n")
    for out in output:
        if "Current:" in out:
            current = float(out[9:])
            if current == float(correction_value):
                return

    ret_val = subprocess.call(["gphoto2" ,"--set-config-value", "/main/capturesettings/exposurecompensation="+str(correction_value)])

    if ret_val > 0:
        log.warn("adjusting exposure failed (gphoto2 value: {})".format(ret_val))
        return

    time.sleep(WAIT_EXPOSURE_COMP)


def _exec(cmd):

    ret_val = subprocess.call(cmd)
    if not ret_val == 0:
        log.info("command failed")
        return False

    return True


def autofocus():

    # gphoto2 --set-config-value /main/actions/autofocus=0

    if not _exec(["gphoto2" ,"--set-config-value", "/main/capturesettings/focusmode=Automatic"]): 
        return
    time.sleep(WAIT_AUTOFOCUS)

    if not _exec(["gphoto2" ,"--set-config-value", "/main/actions/autofocus="+str(0)]):
        return
    time.sleep(WAIT_AUTOFOCUS)

    if not _exec(["gphoto2" ,"--set-config-value", "/main/actions/autofocus="+str(1)]):
        return
    time.sleep(WAIT_AUTOFOCUS*2)

    if not _exec(["gphoto2" ,"--set-config-value", "/main/actions/autofocus="+str(0)]):
        return
    time.sleep(WAIT_AUTOFOCUS)

    if not _exec(["gphoto2" ,"--set-config-value", "/main/capturesettings/focusmode=Manual"]): 
        return
    time.sleep(WAIT_AUTOFOCUS)

def print_config():

    FORMAT = "  {:<24}: {}"

    log.debug(" ")
    log.debug("CONFIGURATION:")

    log.debug(FORMAT.format("DEBUG", DEBUG))

    log.debug(FORMAT.format("RAW_DIR", RAW_DIR))
    log.debug(FORMAT.format("FILE_EXTENSION", FILE_EXTENSION))

    log.debug(FORMAT.format("SERIAL_PORT", SERIAL_PORT))
    log.debug(FORMAT.format("SERIAL_BAUDRATE", SERIAL_BAUDRATE))
    log.debug(FORMAT.format("SERIAL_TIMEOUT", SERIAL_TIMEOUT))

    log.debug(FORMAT.format("REPEAT_MODE", REPEAT_MODE))
    log.debug(FORMAT.format("REPEAT_INTERVAL", REPEAT_INTERVAL))
    log.debug(FORMAT.format("REPERAT_ITERATIONS", REPERAT_ITERATIONS))

    log.debug(FORMAT.format("AUTOFOCUS_ENABLED", AUTOFOCUS_ENABLED))
    log.debug(FORMAT.format("DOUBLEEXPOSURE_ENABLED", DOUBLEEXPOSURE_ENABLED))
    log.debug(FORMAT.format("WAIT_EXPOSURE_COMP", WAIT_EXPOSURE_COMP))
    log.debug(FORMAT.format("WAIT_AUTOFOCUS", WAIT_AUTOFOCUS))

    log.debug(FORMAT.format("EXPOSURE_THRESHOLD", EXPOSURE_THRESHOLD))
    log.debug(FORMAT.format("FREE_DISK_THRESHOLD", FREE_DISK_THRESHOLD))

    log.debug(FORMAT.format("EXPOSURE_LOW", EXPOSURE_LOW))
    log.debug(FORMAT.format("EXPOSURE_NORMAL", EXPOSURE_NORMAL))

    log.debug(FORMAT.format("PLATFORM", PLATFORM))

    log.debug(" ")


def exit(error=False):
    log.info("uptime: {}".format(get_uptime()))

    if error:
        log.info("shutdown!")
        if not DEBUG and PLATFORM == "PI":
            time.sleep(1)
            #subprocess.call(["echo", "S 5", ">>", "/dev/tty.ACM0"]) 
            sendCommand("S 5")
            subprocess.call(["sudo", "shutdown", "now"]) 
        else:
            log.info("[shutdown cancelled]")
        log.debug("--- --- --- --- --- --- --- --- --- ---")
        sys.exit(1)
    else:
        log.info("success")
        if not REPEAT_MODE and not DEBUG and PLATFORM == "PI":
            time.sleep(1)
            #subprocess.call(["echo", "S 5", ">>", "/dev/tty.ACM0"]) 
            sendCommand("S 5")
            subprocess.call(["sudo", "shutdown", "now"])
        else:
            log.info("[shutdown cancelled]")
        log.debug("--- --- --- --- --- --- --- --- --- ---")
        sys.exit(0)

# ---------- ---------- ---------- ---------- ---------- ---------- #

def prepare():
    print("prepare.") #, sep="")

    determine_environment() # set directory variables and change working directory

    initLog()

    if os.path.exists("NO_AUTOSTART"):
        log.info("no autostart")
        sys.exit(0)    

    log.info("prepare")
    if not check_prerequisites():
        exit(error=True)

    print_config()


def run():

    log.debug("init")

    try:
        log.info(sendCommand("B"))
    except Exception as e:
        log.warn("requesting battery status failed: {}".format(e))

    (path, filename) = acquire_filename(RAW_DIR)
    full_name = None

    try:
        if filename is None:
            raise RuntimeError("no filename could be acquired [{}]".format(path))

        full_name = os.path.join(path, filename)

        # knock knock
        check_camera()

        adjust_exposure(EXPOSURE_NORMAL)        # no abort on error
        if (AUTOFOCUS_ENABLED):
            autofocus()                         # no abort on error
        take_image(full_name)       
    except subprocess.CalledProcessError as cpe:
        log.error(cpe)
        log.error(cpe.output)
        exit(error=True)
    except Exception as e:
        log.error(traceback.format_exc())
        exit(error=True)

    # check exposure
    if (DOUBLEEXPOSURE_ENABLED):
        jpeg_full_name = convert_raw_to_jpeg(path, filename, path)
        exposure = calculate_brightness(jpeg_full_name)
        log.info("exposure: {}".format(exposure))

        if exposure < EXPOSURE_THRESHOLD:
            try:
                adjust_exposure(EXPOSURE_LOW)
                full_name_2 = os.path.join(path, "x_" + filename)
                take_image(full_name_2)
                adjust_exposure(EXPOSURE_NORMAL)
            except RuntimeError as e:
                log.error(traceback.format_exc())
                exit(error=True)

        os.remove(jpeg_full_name)

    if not REPEAT_MODE:
        exit()


if (__name__ == "__main__"):
    try:
        prepare()

        if not REPEAT_MODE:
            run()
        else:
            for i in range(0, REPERAT_ITERATIONS):
                log.info("repeat mode iteration: {}".format(i))
                run()
                time.sleep(REPEAT_INTERVAL)
            exit()
    except Exception as e:
        print(e)
        print(traceback.format_exc())
        log.error(traceback.format_exc())
        exit(error=True)
