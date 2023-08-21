from fractions import Fraction
import os
import sys
import time
import shutil
import subprocess
import math
import datetime
import logging

import numpy as np
import cv2

from simple_pid import PID
# from matplotlib import pyplot as plt

TMP_DIR                     = "tmp"
STORAGE_DIR                 = "storage"
DIR_NORMAL                  = os.path.join(STORAGE_DIR, "normal")
DIR_LOW                     = os.path.join(STORAGE_DIR, "low")

DYNAMIC_RANGE               = 5 # EV
FILE_EXTENSION              = ".arw"
MIN_FREE_SPACE              = 300 # MB

INTERVAL_DURATION_LOW       = 60
INTERVAL_DURATION_NORMAL    = INTERVAL_DURATION_LOW*1

APERTURE_NORMAL             = None # "5.6"
APERTURE_LOW                = None # "16.0"

PID_VALUES                  = [0.120, 0.02, 0.0]

# ---

normal_capture_settings     = None
all_shutterspeeds           = None

captures_low                = []
captures_normal             = []

# ---

logging.basicConfig(
    stream=sys.stdout, 
    format="%(asctime)s | %(name)s | %(levelname)s | %(message)s",
    level=logging.DEBUG
    )

log = logging.getLogger()
log.setLevel(logging.DEBUG)

def init():

    for directory in [DIR_NORMAL, DIR_LOW, TMP_DIR]:
        if directory is not None and directory != "":
            try:
                os.makedirs(directory)
            except FileExistsError as e:
                pass
            except PermissionError as e:
                pass


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

        if arguments[1] != "capture-image-and-download":
            p = subprocess.run(arguments, check=True, capture_output=True)
            output = p.stdout.decode("UTF-8")
            output = output.split("\n")
            return output
        else:
            p = subprocess.run(arguments, check=True, capture_output=False)

    except Exception as e:
        raise e


def _get_config_value(name):
    output = _gphoto("get-config", name)
    data = output[3]

    if data.startswith("Current: "):
        data = data[len("Current: "):]
    else:
        raise Exception("unknown reponse")

    return data


def _set_config_value(name, value):
    _gphoto("set-config-value", "{}={}".format(name, value))


def _acquire_filename(path, prefix=""):
    filename = None

    for i in range(0, 9999):
        name = i
        name = str(name).zfill(4)
        testname = prefix + name + FILE_EXTENSION
        if not os.path.exists(os.path.join(path, testname)):
            filename = testname
            break

    log.debug("acquired filename: {}".format(filename))

    return (path, filename)


def capture_and_download(directory):

    filename = _acquire_filename(directory)

    try:
        _gphoto(["capture-image-and-download", "force-overwrite"])
        if not os.path.exists("capt0000.arw"):
            raise Exception("captured RAW file missing")
        shutil.move("capt0000.arw", os.path.join(*filename))
        log.debug("camera save done: {}".format(filename[1]))
    except Exception as e:
        raise e

    return filename


def convert_raw_to_jpeg(rawfile_path, rawfile_name, jpeg_path):
    # well, actually we just extract the thumbnail JPEG of the RAW
    # dcraw does not support export as JPEG and output as TIFF
    # and conversion to JPEG is unnecessary work

    # TODO: overwrite/remove jpeg image?

    rawfile_full_name   = os.path.join(rawfile_path, rawfile_name)
    thumb               = rawfile_name[:-4] + ".thumb" + ".jpg"
    thumb_full_name     = os.path.join(rawfile_path, thumb)
    jpeg_full_name      = os.path.join(jpeg_path, rawfile_name[:-4] + ".jpg")

    subprocess.run(["dcraw", "-e", format(rawfile_full_name)])     
    os.rename(thumb_full_name, jpeg_full_name)

    return jpeg_full_name


def convert_raw_to_ppm(full_filename_raw):
    subprocess.run(["dcraw", "-w", full_filename_raw])
    full_filename_converted = os.path.splitext(full_filename_raw)[0] + ".ppm"
    return full_filename_converted


def get_settings():
    shutterspeed    = _get_config_value("/main/capturesettings/shutterspeed")
    aperture        = _get_config_value("/main/capturesettings/f-number")
    iso             = _get_config_value("/main/imgsettings/iso")
    
    log.debug("get settings: {} | {} | {}".format(shutterspeed, aperture, iso))

    if shutterspeed == "Bulb":
        log.warning("camera reports shutterspeed to be Bulb. Retry...")
        shutterspeed  = _get_config_value("/main/capturesettings/shutterspeed")
        if shutterspeed == "Bulb":
            log.warning("camera reports shutterspeed to be Bulb.")
            shutterspeed = None

    aperture = aperture
    iso = iso

    return shutterspeed, aperture, iso


def get_all_shutterspeeds():
    output = _gphoto("get-config=/main/capturesettings/shutterspeed")
    choices = output[4:-2]

    available_shutterspeeds = []
    for choice in choices:
        val = choice.split(" ")[2]

        if val == "Bulb":
            continue

        available_shutterspeeds.append(val)

    return available_shutterspeeds


def set_settings(shutterspeed, aperture, iso):
    if shutterspeed is not None:
        _set_config_value("/main/capturesettings/shutterspeed", shutterspeed)
    if aperture is not None:
        _set_config_value("/main/capturesettings/f-number", aperture)
    if iso is not None:
        _set_config_value("/main/imgsettings/iso", iso)

    log.debug("apply settings: {} | {} | {}".format(shutterspeed, aperture, iso))


def calculate_image_brightness(full_filename):
    img = cv2.imread(full_filename, cv2.IMREAD_GRAYSCALE)
    normalized_avg = np.mean(img)/256
    error = normalized_avg - 0.5

    return normalized_avg, error


"""
1/100 +1EV   =   1/200
1/100 -2EV   =   1/25
1     +1EV   =   0.5
"""
def match_shutterspeed(ev_adjustment, old_shutterspeed, available_shutterspeeds):
    old = float(Fraction(old_shutterspeed))
    new = old / 2**(-ev_adjustment)

    available_shutterspeeds_float = np.array([float(Fraction(x)) for x in available_shutterspeeds])
    diff = np.abs(available_shutterspeeds_float - new)

    return available_shutterspeeds[diff.argmin()]


def settings_to_ev(shutter, aperture, iso):

    if type(shutter) is str:
        shutter = float(Fraction(shutter))
    if type(shutter) is Fraction:
        shutter = float(shutter)

    if type(aperture) is str:
        aperture = float(Fraction(aperture))
    if type(aperture) is Fraction:
        aperture = float(aperture)

    if type(iso) is str:
        iso = float(iso)

    ev = 2*math.log(aperture, 2) - math.log(shutter, 2) - math.log(iso/100, 2)
    return ev


def normalized_brightness_to_ev(normalized_brightness):
    return normalized_brightness * DYNAMIC_RANGE


def trigger_normal():

    global normal_capture_settings

    log.info("trigger normal")  
    timer_start = datetime.datetime.now()  

    scheduled_time = None
    if len(captures_normal) == 0:
        scheduled_time = datetime.datetime.now()
    else:
        scheduled_time = captures_normal[-1]["scheduled_time"] + datetime.timedelta(seconds=INTERVAL_DURATION_NORMAL)
    
    log.debug("schedule delay: {:5.2f}s".format((datetime.datetime.now()-scheduled_time).total_seconds()))

    # get capture settings
    current_shutterspeed, current_aperture, current_iso = normal_capture_settings
    current_ev = settings_to_ev(current_shutterspeed, current_aperture, current_iso)

    # capture image
    set_settings(*normal_capture_settings)
    filename_raw = capture_and_download(DIR_NORMAL)

    captures_normal.append({
        "scheduled_time": scheduled_time,
        "time": datetime.datetime.now(),
        "filename": filename_raw,
        "settings": [current_shutterspeed, current_aperture, current_iso]
    })

    # calculate normalized image brightness
    filename_jpg = convert_raw_to_jpeg(*filename_raw, TMP_DIR)
    current_brightness, error = calculate_image_brightness(filename_jpg)
    os.remove(filename_jpg)

    # pid --> absolute target value in normalized brightness
    control = pid(current_brightness)
    brightness_adjustment = control-current_brightness
    ev_adjustment = normalized_brightness_to_ev(brightness_adjustment)

    # find closest shutter speed 
    new_shutterspeed = match_shutterspeed(ev_adjustment, current_shutterspeed, all_shutterspeeds)

    log.info("capture: {} / EV: {:5.2f} / brightness: {:5.3f} | error EV: {:5.2f} | error: {:5.2f} | pid: {:5.2f} | brightness adjustment: {:5.2f} | EV adjustment: {:5.2f} | shutterspeed - old: {} - new: {}".format(
        filename_raw[1],
        current_ev, 
        current_brightness,
        normalized_brightness_to_ev(error),
        error,
        control,
        brightness_adjustment,
        ev_adjustment,
        current_shutterspeed, 
        new_shutterspeed
    ))

    # set new capture settings
    normal_capture_settings = (new_shutterspeed, current_aperture, current_iso)

    log.info("trigger_normal: {:5.2f}s".format((datetime.datetime.now()-timer_start).total_seconds()))


def trigger_low():

    log.info("trigger low")
    timer_start = datetime.datetime.now()
    
    scheduled_time = None
    if len(captures_low) == 0:
        scheduled_time = datetime.datetime.now()
    else:
        scheduled_time = captures_low[-1]["scheduled_time"] + datetime.timedelta(seconds=INTERVAL_DURATION_LOW)

    log.debug("schedule delay: {:5.2f}s".format((datetime.datetime.now()-scheduled_time).total_seconds()))

    set_settings(all_shutterspeeds[-1], APERTURE_LOW, None)

    filename_raw = None
    try:
        filename_raw = capture_and_download(DIR_LOW)
    except Exception as e:
        log.error("capture_and_download failed: {}".format(e))

    captures_low.append({
        "scheduled_time": scheduled_time,
        "time": datetime.datetime.now(),
        "filename": filename_raw,
    })

    if filename_raw is not None:
        log.info("capture: {}".format(filename_raw[1]))

    log.info("trigger_low: {:5.2f}s".format((datetime.datetime.now()-timer_start).total_seconds()))


def check_trigger(captures, interval):
    if len(captures) == 0:
        return True

    now = datetime.datetime.now()

    if (now-captures[-1]["scheduled_time"]).total_seconds() > interval:
        return True
    else:
        return False


if __name__ == "__main__":

    init()

    log.info("----------------------------------------")
    log.info("init")
    log.info("  DYNAMIC_RANGE:              {}".format(DYNAMIC_RANGE))
    log.info("  INTERVAL_DURATION_LOW:      {}".format(INTERVAL_DURATION_LOW))
    log.info("  INTERVAL_DURATION_NORMAL:   {}".format(INTERVAL_DURATION_NORMAL))
    log.info("  APERTURE_NORMAL:            {}".format(APERTURE_NORMAL))
    log.info("  APERTURE_LOW:               {}".format(APERTURE_LOW))
    log.info("  PID_VALUES:                 {:5.3f} {:5.3f} {:5.3f}".format(*PID_VALUES))
    log.info("")


    pid = PID(*PID_VALUES, setpoint=0.5)
    all_shutterspeeds = get_all_shutterspeeds()
    normal_capture_settings = get_settings()

    if APERTURE_NORMAL is not None:
        normal_capture_settings[1] = APERTURE_NORMAL

    log.info("initial normal capture settings: {} | {} | {}".format(*normal_capture_settings))

    while True:

        if check_trigger(captures_low, INTERVAL_DURATION_LOW):
            trigger_low()

            if check_trigger(captures_normal, INTERVAL_DURATION_NORMAL):
                trigger_normal()

        # trigger_normal()

        time.sleep(0.5)