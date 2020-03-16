#!/usr/bin/env python3

from time import sleep
from datetime import datetime, timedelta
from fractions import Fraction
import math
import os
import sys
import shutil
import argparse
import subprocess
import traceback
import logging

import exifread
import picamera

from devices import TimeboxController

from PIL import Image

# ---

SECOND_EXPOSURE_SHUTTER_SPEED   = 9
SECOND_EXPOSURE_ISO             = 25
THIRD_EXPOSURE_SHUTTER_SPEED    = SECOND_EXPOSURE_SHUTTER_SPEED*(2**7)
FOURTH_EXPOSURE_SHUTTER_SPEED   = SECOND_EXPOSURE_SHUTTER_SPEED*(2**11)
EXPOSURE_COMPENSATION           = 2 # 6 = +1 stop

SHUTDOWN_ON_COMPLETE            = True 

IMAGE_FORMAT                    = "jpeg" # JPG format # ~ 4.5 mb | 14 mb (incl. bayer)
# IMAGE_FORMAT                    = "rgb" # 24-bit RGB format # ~ 23 mb
# IMAGE_FORMAT                    = "yuv" # YUV420 format
# IMAGE_FORMAT                    = "png" # PNG format # ~ 9 mb
WRITE_RAW                       = True

OUTPUT_DIR_1                    = "captures_1"
OUTPUT_DIR_2                    = "captures_2"
OUTPUT_DIR_3                    = "captures_3"
OUTPUT_DIR_4                    = "captures_4"
OUTPUT_FILENAME                 = "cap"

SERIAL_PORT                     = "/dev/ttyAMA0"

MIN_FREE_SPACE                  = 300

# ND_FILTER                       = 10 # stops

# EV values, ND-filter-value corrected
REDUCE_INTERVAL_EV_THRESHOLD    = 3
INCREASE_INTERVAL_EV_THRESHOLD  = 8 # 10

# PERSISTENT MODE
INTERVAL                        = 60 # in sec
MAX_ITERATIONS                  = 3000

"""                      
┌┬┐┬─┐┌─┐┌─┐┬ ┬┌─┐┌─┐┌┬┐
 │ ├┬┘├─┤└─┐├─┤│  ├─┤│││
 ┴ ┴└─┴ ┴└─┘┴ ┴└─┘┴ ┴┴ ┴

INFO:

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

PiCamera needs at least 256mb of GPU memory. In config.txt:
gpu_mem_512=256

"""

def read_exif_data(filename):

    with open(filename, 'rb') as f:
        metadata = exifread.process_file(f)

        # for tag in metadata.keys():
        #     if tag not in ('JPEGThumbnail', 'TIFFThumbnail', 'Filename', 'EXIF MakerNote'):
        #         print("Key: {}, value {}".format(tag, metadata[tag]))

                    # shutter speed in seconds (e.g. 0.5)

        shutter_speed_val = metadata["EXIF ExposureTime"].values[0]
        if shutter_speed_val.num == 0 or shutter_speed_val.den == 0:
            shutter_speed = 0
        else:
            shutter_speed = float(shutter_speed_val.num) / float(shutter_speed_val.den)

        # ISO (e.g. 100)

        iso = float(metadata["EXIF ISOSpeedRatings"].values[0])

        # Aperture (e.g. 5.6)

        aperture_val = metadata["EXIF FNumber"].values[0]

        if aperture_val.num == 0 or aperture_val.den == 0:
            aperture = 8 # default value (shouldnt happen with picam)
            log.error("aperture missing! EV value calculation will be wrong")
        else:
            aperture = aperture_val.num / aperture_val.den

        log = logging.getLogger()

        log.info("Exif exposure time      : {}".format(shutter_speed))
        log.info("Exif aperture           : {}".format(aperture))
        log.info("Exif ISO                : {}".format(iso))

        ev = math.log(aperture / shutter_speed, 2) - math.log(iso/100, 2)

        return ev


def print_exposure_settings(camera):

    STATETMENT = "{:25s}: {}"

    print(STATETMENT.format("Shutter speed (0=auto)", camera.shutter_speed))
    print(STATETMENT.format("ISO", camera.iso))
    print(STATETMENT.format("Analog gain", camera.analog_gain))
    print(STATETMENT.format("Digital gain", camera.digital_gain))
    print(STATETMENT.format("Exp speed", camera.exposure_speed))
    print(STATETMENT.format("Exp mode", camera.exposure_mode))
    print(STATETMENT.format("Exp compensation", camera.exposure_compensation))
    print(STATETMENT.format("Meter mode", camera.meter_mode))
    print(STATETMENT.format("Framerate", camera.framerate))
    print(STATETMENT.format("brightness", camera.brightness))
    print(STATETMENT.format("Awb mode", camera.awb_mode))
    print(STATETMENT.format("Drc strength", camera.drc_strength))
    print(STATETMENT.format("Brightness meter mode", camera.meter_mode))
    print(STATETMENT.format("Resolution", camera.resolution))

    print("--- --- ---")


def log_capture_info(camera, filename):

    log.info("{:24s}: {}".format("filename", filename))

    log.info("{:24s}: {}".format("shutter speed", camera.shutter_speed)) # microseconds
    log.info("{:24s}: {:.10}".format("exposure speed", camera.exposure_speed/(1000*1000)))

    log.info("{:24s}: {}".format("iso", camera.iso))
    log.info("{:24s}: {:4.2f}".format("analog gain", float(camera.analog_gain)))
    log.info("{:24s}: {:4.2f}".format("digital gain", float(camera.digital_gain)))


def calculate_brightness(filename):

    with Image.open(filename) as image:
        greyscale_image = image.convert('L')
        histogram = greyscale_image.histogram()
        pixels = sum(histogram)
        brightness = scale = len(histogram)

        for index in range(0, scale):
            ratio = histogram[index] / pixels
            brightness += ratio * (-scale + index)

        return 1 if brightness == 255 else brightness / scale


def get_filename(extension): # returns(path, filename.ext)

    if extension == "jpeg":
        extension = "jpg"

    for i in range(0, 100000):
        filename = "{}_{:06d}.{}".format(OUTPUT_FILENAME, i, extension)
        if not os.path.exists(os.path.join(OUTPUT_DIR_1, filename)):
            return (OUTPUT_DIR_1, filename)

    raise Exception("no filenames left!")


def run_subprocess(cmd):

    # combine STDERR and STDOUT to STDOUT
    subp = subprocess.run(cmd.split(" "), stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    output = subp.stdout.decode("utf-8")

    if output[-1] == "\n":
        output = output[:-1]

    return output


def global_except_hook(exctype, value, tb):
    
    log = logging.getLogger()

    log.error("global error: {} | {}".format(exctype, value))

    logging.shutdown()

    subprocess.call(["sync"])
    sleep(1.0)

    print("sync called. traceback:")
    traceback.print_tb(tb)

    exit()

    # sys.__excepthook__(exctype, value, traceback)


def trigger():

    image_info = []

    # starts hidden preview for 3A automatically
    camera = picamera.PiCamera() 
    
    camera.meter_mode = "spot"
    camera.exposure_compensation = EXPOSURE_COMPENSATION

    try:
        camera.resolution = (3280, 2464) # V2 8MP
        camera.framerate = Fraction(1, 1)

    except picamera.exc.PiCameraValueError as e:
        log.warning("fallback to V1 camera resolution")

        camera.resolution = (2592, 1944) # V1 5MP
        camera.framerate = Fraction(1, 1)

    except Exception as e:
        log.error("setting camera resolution failed (unknown reasons): {}".format(e))

    # give the 3A algorithms some time for warmup
    sleep(1)

    log.debug("------ exposure 1 ------")

    filename = get_filename(IMAGE_FORMAT)
    full_filename = os.path.join(*filename)

    camera.capture(full_filename, format=IMAGE_FORMAT, bayer=WRITE_RAW)
    
    # log_capture_info(camera, full_filename)
    # print_exposure_settings(camera)
    
    log_capture_info(camera, full_filename)
    first_exposure_ev = read_exif_data(full_filename)
    image_info.append([full_filename, first_exposure_ev])

    log.info("brightness              : {:.2f} EV".format(first_exposure_ev))
    # if ND_FILTER is not None:
    #     log.info("brightness (incl ND): {:.2f} EV".format(first_exposure_ev+ND_FILTER))
    # print_exposure_settings(camera)

    log.debug("------ exposure 2 ------")

    # increase framerate, otherwise capture will block even on short exposures 
    # for several seconds (for some reason too fast rates (> 16fps) will result 
    # in 0-value-images)
    camera.framerate = Fraction(10, 1)
    camera.exposure_compensation = 0

    # before actually disabling exposure mode (and thus disabling automatic gain control)
    # set ISO to a low value. AGC will reduce analog and digital gain and afterwards we 
    # can set the exposure mode to off. If that's not done the first (quite dark) exposure
    # through the filter will nudge the AGC to increase the gain and our (mostly black) 2nd
    # and 3rd exposures will be extremly noisy (and thus will result in jpegs with high 
    # filesizes)
    camera.iso = SECOND_EXPOSURE_ISO
    sleep(1)
    camera.exposure_mode = "off"
    camera.shutter_speed = SECOND_EXPOSURE_SHUTTER_SPEED

    sleep(0.5)

    full_filename_2 = os.path.join(OUTPUT_DIR_2, filename[1]) #[:-4] + "_2" + ".jpg")
    camera.capture(full_filename_2, format=IMAGE_FORMAT)
    log_capture_info(camera, full_filename_2)

    image_info.append([full_filename_2, None])

    # read_exif_data(full_filename_2)
    # print_exposure_settings(camera)

    log.debug("------ exposure 3 ------")

    camera.shutter_speed = THIRD_EXPOSURE_SHUTTER_SPEED

    sleep(0.1)

    full_filename_3 = os.path.join(OUTPUT_DIR_3, filename[1])
    camera.capture(full_filename_3, format=IMAGE_FORMAT)
    log_capture_info(camera, full_filename_3)

    image_info.append([full_filename_3, None])

    log.debug("------ exposure 4 ------")

    camera.shutter_speed = FOURTH_EXPOSURE_SHUTTER_SPEED

    sleep(0.1)

    full_filename_4 = os.path.join(OUTPUT_DIR_4, filename[1])
    camera.capture(full_filename_4, format=IMAGE_FORMAT)
    log_capture_info(camera, full_filename_4)

    image_info.append([full_filename_4, None])

    camera.close()

    return image_info


if __name__ == "__main__":

    # we need to use timestamp milliseconds because we may change system time later
    start = datetime.now().timestamp()

    # ---------------------------------------------------------------------------------------

    log_filename = "log_trashcam.log"

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

    # log.info(subprocess.check_output(["cat", "/proc/uptime"]))

    # ---------------------------------------------------------------------------------------

    # # TODO: wifi off
    # try:
    #     subprocess.call(["ifdown", "wlan0"])
    # except Exception as e:
    #     log.info("disabling wifi error: {}".format(e))

    # # TODO: tvservice off
    # try:
    #     subprocess.call(["tvservice", "-o"])    
    # except Exception as e:
    #     log.info("disabling tvservice error: {}".format(e))

    # ---------------------------------------------------------------------------------------

    log.info("")
    log.info("--------------------------")
    log.info(" ┌┬┐┬─┐┌─┐┌─┐┬ ┬┌─┐┌─┐┌┬┐ ")
    log.info("  │ ├┬┘├─┤└─┐├─┤│  ├─┤│││ ")
    log.info("  ┴ ┴└─┴ ┴└─┘┴ ┴└─┘┴ ┴┴ ┴ ")
    log.info("--------------------------")

    ap = argparse.ArgumentParser()
    ap.add_argument("-p", "--persistent-mode", type=bool, default=False, help="")
    ap.add_argument("-s", "--stream-mode", type=bool, default=False, help="")
    args = vars(ap.parse_args())

    # log.info("ND FILTER       : {} stops".format(ND_FILTER))
    log.info("PERSISTENT MODE : {}".format(args["persistent_mode"]))
    log.info("STREAM MODE     : {}".format(args["stream_mode"]))

    log.info("--------------------------")

    log.info("system status [start]: {}".format(run_subprocess("vcgencmd get_throttled")))

    try: 
        os.makedirs(OUTPUT_DIR_1)
        log.debug("created dir: {}".format(OUTPUT_DIR_1))
    except FileExistsError as e:
        pass

    try: 
        os.makedirs(OUTPUT_DIR_2)
        log.debug("created dir: {}".format(OUTPUT_DIR_2))
    except FileExistsError as e:
        pass

    try: 
        os.makedirs(OUTPUT_DIR_3)
        log.debug("created dir: {}".format(OUTPUT_DIR_3))
    except FileExistsError as e:
        pass

    try: 
        os.makedirs(OUTPUT_DIR_4)
        log.debug("created dir: {}".format(OUTPUT_DIR_4))
    except FileExistsError as e:
        pass

    image_info = None
    
    try:
        controller = TimeboxController.find_by_portname(SERIAL_PORT)
        
        if controller is not None:

            log.debug("controller found: {}".format(controller))

            millis = int(controller.get_uptime()) # 1008343
            secs = int(millis/1000)

            subprocess.run(["date", "-s", "@{}".format(secs)], check=True)

            seconds = float(millis) / 1000.0
            minutes = seconds / 60.0
            hours   = minutes / 60.0
            days    = hours / 24.0

            msg = "{:.0f} sec".format(seconds % 60)
            if minutes > 1:
                msg = "{:.0f} min, ".format(minutes % 60) + msg
            if hours > 1:
                msg = "{:.0f} h, ".format(hours % 24) + msg
            if days > 1:
                msg = "{:.0f} d, ".format(days) + msg

            log.info("running for: " + msg)

            start += millis/1000.0

            d = datetime.fromtimestamp(secs)
            log.debug("setting system time to {}".format(d.strftime('%Y-%m-%d %H:%M:%S')))
        else:
            log.warning("setting system time failed, no controller found")
    except Exception as e:
        log.error("setting system time failed: {}".format(e))

    try:

        free_space_mb = shutil.disk_usage(OUTPUT_DIR_1).free / (1024 * 1024)
        if free_space_mb < MIN_FREE_SPACE:
            log.error("NO SPACE LEFT ON DEVICE (directory: {}, free space: {:.2f}, min free space: {:.2f}".format(OUTPUT_DIR_1, free_space_mb, MIN_FREE_SPACE))
            raise Exception("no space left on device")
        else:
            log.debug("free space in {}: {:.2f}mb".format(OUTPUT_DIR_1, free_space_mb))

        if args["stream_mode"]:
            preview = StreamPreview()
            preview.run()

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
            image_info = trigger()

        log.info("--------------------------")

        diff = datetime.now().timestamp() - start
        log.debug("total runtime           : {:.3f} sec".format(diff))

    except Exception as e:
        log.error("error: [{}] {}".format(type(e), e))

    # ---------------------------------------------------------------------------------------

    temp = None
    try: 
        temp_str = str(subprocess.check_output(["vcgencmd", "measure_temp"]))
        temp = float(temp_str[temp_str.index("=")+1:temp_str.index("'")])
    except Exception as e:
        log.warn("reading pi temperature failed: {}".format(e))
    log.info("temperature [pi]        : {:.2f}".format(temp))

    # get EV of last (primary) image and reduce if brighter than threshold
    # 
    # option A: use EXIF data to compute EV
    #  problem: if a ND1000 filter is used, only very bright scenes do increase
    #           the shutter speed above minimum (and thus change the computed EV)
    #
    # option B: calculate brightness (or non-zero pixels) of capture_2 or _3
    #  problem: requires 2-3s per image! (total time with option B from powerup
    #           to request-for-shutdown is 37s)
    #
    # option C: get the brightest pixel in capture_2
    #           if > than threshold, sun must be present
    #  problem: works well for increase interval, but how to know when to reduce?
    #           slow (seems to take about 8s??)

    brightness_1 = None
    brightness_2 = None

    try:
        if image_info is not None and len(image_info) > 0:

            # option A:

            # brightness = image_info[0][1]

            # if ND_FILTER is not None:
            #     brightness += ND_FILTER

            # # take images slower

            # if brightness <= REDUCE_INTERVAL_EV_THRESHOLD:
            #     log.debug("request interval reduction (EV: {:.2f} < {})".format(
            #         brightness, REDUCE_INTERVAL_EV_THRESHOLD))
            #     controller.reduce_interval()

            # # take images faster

            # if brightness > INCREASE_INTERVAL_EV_THRESHOLD:
            #     log.debug("request interval increase (EV: {:.2f} > {})".format(
            #         brightness, INCREASE_INTERVAL_EV_THRESHOLD))
            #     controller.increase_interval()

            # option B:

            # filename_capture_1 = image_info[0][0]
            # brightness_1 = calculate_brightness(filename_capture_1)
            # log.info("brightness of capture_1: {:7.5f}".format(brightness_1))

            filename_capture_2 = image_info[1][0]
            brightness_2 = calculate_brightness(filename_capture_2)
            log.info("brightness of capture_2 : {:7.5f}".format(brightness_2))

            # option C:

            # filename_capture_2 = image_info[1][0]
            # image = Image.open(filename_capture_2)
            # min_value, max_value = image.getextrema()

            # if max_value is not None and max_value >= 100:

            #     # take images faster

            #     log.debug("request interval increase (max value: {:.2f} > {})".format(
            #         max_value, 100))
            #     controller.increase_interval()

            # pass

    except Exception as e:
        log.error("increasing/reducing interval failed: {}".format(e))

    log.info("system status [end]: {}".format(run_subprocess("vcgencmd get_throttled")))

    if SHUTDOWN_ON_COMPLETE:

        if controller is not None:
            try:

                log.info("battery                 : {}".format(controller.get_battery_status()))
                # log.info("temperature [controller]: {}".format(controller.get_temperature()))

                # if brightness_1 < 0.05:

                #     # take images slower

                #     log.debug("request interval reduction (brightness: {:.5f} < {})".format(
                #         brightness_1, 0.05))
                #     controller.reduce_interval()

                if brightness_2 is not None and brightness_2 >= 0.0001:

                    # take images faster

                    log.debug("request interval increase (brightness: {:.5f} > {})".format(
                        brightness_2, 0.0001))
                    controller.increase_interval()

                controller.shutdown(delay=15000)

                log.debug("shutdown command sent")
                log.info("POWEROFF")
                
                log.debug("logging shutdown")
                logging.shutdown()

                subprocess.call(["sync"])
                sleep(0.5)

                subprocess.call(["poweroff"])
                exit()
            except Exception as e:
                log.error("poweroff failed: {}".format(e))
        else:
            log.error("poweroff failed: {}".format("no controller found"))

    log.debug("logging shutdown")
    logging.shutdown()

    start = datetime.now()
    subprocess.call(["sync"])
    diff = (datetime.now() - start).total_seconds()
    print("sync done. took: {:.3f} sec".format(diff))

    sleep(1.0)

