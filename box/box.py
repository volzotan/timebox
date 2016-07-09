#!/bin/python
# -*- coding: utf-8 -*-

import gphoto2 as gp
import schedule 

import logging
import os
import subprocess
import time
import sys
import datetime

PLATFORM                  = None

LOG_BASE_DIR              = "/var/log/timebox/"
LOG_FILENAME_DEBUG        = LOG_BASE_DIR + "debug.log"
LOG_FILENAME_INFO         = LOG_BASE_DIR + "info.log"
LOG_FILENAME_TEMP         = LOG_BASE_DIR + "temp.log"
LOG_LEVEL_CONSOLE         = logging.DEBUG   

LOOK_FOR_AUTOSTART_FILE   = False
AUTOSTART_FILE            = "AUTOSTART"

OUTPUT_DIR_RAW            = "RAWS"
OUTPUT_DIR_JPEG           = "JPEGS"
OUTPUT_DIR_TEST           = "TEST"

FILE_EXTENSION            = ".arw"

CAMERA_ENABLE_PIN         = 11

log = None    
logTemp = None

"""
Naming Conventions
path      : foo/bar
name      : image.img
full_name : foo/bar/image.img

"""

def initLog():
    global log
    global logTemp

    # create logger
    log = logging.getLogger()
    log.setLevel(logging.DEBUG)

    # create formatter
    formatter = logging.Formatter('%(asctime)s | %(name)s [%(levelname)s] %(message)s')

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

    logTemp = logging.getLogger("Temp")
    fileHandlerTemp = logging.FileHandler(LOG_FILENAME_TEMP, mode="a", encoding="UTF-8")
    fileHandlerTemp.setLevel(logging.DEBUG)
    fileHandlerTemp.setFormatter(logging.Formatter('%(asctime)s | %(message)s'))
    logTemp.addHandler(fileHandlerTemp)


def exit(code = 0):
    log.info("exiting")
    system.exit(code)


def determine_environment():
    global PLATFORM

    """
    TODO: maybe check "cat /etc/debian_version" ?
    """

    output = subprocess.check_output(["uname", "-a"]).lower()

    if "darwin" in output:
        PLATFORM = "OSX"
    elif "raspberrypi" in output:
        PLATFORM = "PI"
    elif "linux" in output:
        PLATFORM = "LINUX"
    else:
        PLATFORM = "UNKNOWN"

    log.debug("platform: {}".format(PLATFORM))


def _expand_path(base_dir, input_path):
    if not (input_path.startswith("/") or input_path.startswith("~")):
        return os.path.join(base_dir, input_path)

    return input_path


def _check_dir(path):
    if os.path.exists(path):
        if os.path.isdir(path):
            pass # OK
        else:
            log.error("output dir \"{}\" is actually a file. abort.".format(path))
            exit()
    else:
        log.warn("output dir \"{}\" is missing. create directory...".format(path))
        os.makedirs(path)


def selftest():
    global AUTOSTART_FILE
    global OUTPUT_DIR_RAW
    global OUTPUT_DIR_JPEG
    global OUTPUT_DIR_TEST

    # expand directories
    base_dir = os.path.dirname(os.path.realpath(__file__))

    AUTOSTART_FILE = _expand_path(base_dir, AUTOSTART_FILE)
    OUTPUT_DIR_RAW = _expand_path(base_dir, OUTPUT_DIR_RAW)
    OUTPUT_DIR_JPEG = _expand_path(base_dir, OUTPUT_DIR_JPEG)
    OUTPUT_DIR_TEST = _expand_path(base_dir, OUTPUT_DIR_TEST)

    # check if output directories are present
    _check_dir(OUTPUT_DIR_RAW)
    _check_dir(OUTPUT_DIR_JPEG)
    _check_dir(OUTPUT_DIR_TEST)

    log.info("selftest finished")


# returns (path, filename)
def acquire_filename(path):
    name = datetime.datetime.now().strftime("%Y-%m-%d--%H-%M-%S")
    filename = name + FILE_EXTENSION

    if os.path.exists(os.path.join(path, filename)):
        filename = None
        for i in range(0, 999):
            testname = name + "_" + i + FILE_EXTENSION
            if not os.path.exists(os.path.join(path, testname)):
                filename = testname
                break;

    return (path, filename)


# returns full filename of image, without path
def take_image(path):

    (path, filename) = acquire_filename(path)
    if filename is None:
        log.error("no filename could be acquired [{}]".format(path))
        return
    full_name = os.path.join(path, filename)

    try: 
        gp.check_result(gp.use_python_logging(mapping={
            gp.GP_LOG_ERROR   : logging.ERROR,
            gp.GP_LOG_VERBOSE : logging.INFO,
            gp.GP_LOG_DEBUG   : logging.DEBUG - 3,
            gp.GP_LOG_DATA    : logging.DEBUG - 6}))
        context = gp.gp_context_new()
        camera = gp.check_result(gp.gp_camera_new())
        gp.check_result(gp.gp_camera_init(camera, context))
        print('Capturing image')
        file_path = gp.check_result(gp.gp_camera_capture(
            camera, gp.GP_CAPTURE_IMAGE, context))
        print('Camera file path: {0}/{1}'.format(file_path.folder, file_path.name))
        print('Copying image to', full_name)
        camera_file = gp.check_result(gp.gp_camera_file_get(
                camera, file_path.folder, file_path.name,
                gp.GP_FILE_TYPE_NORMAL, context))
        gp.check_result(gp.gp_file_save(camera_file, full_name))
        gp.check_result(gp.gp_camera_exit(camera, context))

        return filename
    except Exception as e:
        log.error(e)
        raise RuntimeError("camera failed")


def convert_raw_to_jpeg(rawfile_path, rawfile_name, jpeg_path):
    # well, actually we just extract the thumbnail JPEG of the RAW
    # dcraw does not support export as JPEG and output as TIFF
    # and conversion to JPEG is unnecessary work

    rawfile_full_name   = os.path.join(rawfile_path, rawfile_name)
    thumb               = rawfile_name[:-4] + ".thumb" + ".jpg"
    thumb_full_name     = os.path.join(rawfile_path, thumb)
    jpeg_full_name      = os.path.join(jpeg_path, rawfile_name[:-4] + ".jpg")

    subprocess.call(["dcraw", "-e", format(rawfile_full_name)])     
    os.rename(thumb_full_name, jpeg_full_name)


def exit(code):
    if PLATFORM == "PI":
        GPIO.cleanup()
    log.info("program exited")
    sys.exit(code)


def camera_switch_on(power_on):
    if PLATFORM != "PI":
        log.warn("camera could not be switched, no GPIO pins on this platform")
        return

    if power_on:
        GPIO.output(CAMERA_ENABLE_PIN, GPIO.HIGH)
        time.sleep(10)
    else:
        time.sleep(2)
        GPIO.output(CAMERA_ENABLE_PIN, GPIO.LOW)


def read_temperature():
    if not os.path.exists('/sys/devices/w1_bus_master1/w1_master_slaves'):
        log.error("no temperature sensor found")
        log.info("temp job will be cancelled")
        return schedule.CancelJob

    # 1-Wire Slave-List read
    file = open('/sys/devices/w1_bus_master1/w1_master_slaves')
    w1_slaves = file.readlines()
    file.close()

    line = w1_slaves[0]
    # extract 1-wire Slave
    w1_slave = line.split("\n")[0]
    # 1-wire Slave file read
    file = open('/sys/bus/w1/devices/' + str(w1_slave) + '/w1_slave')
    filecontent = file.read()
    file.close()

    # read and convert
    stringvalue = filecontent.split("\n")[1].split(" ")[9]
    temperature = float(stringvalue[2:]) / 1000

    logTemp.info(temperature)

    return temperature


def test():
    log.info("Temperature: {}".format(read_temperature()))

    camera_switch_on(True)

    filename = take_image(OUTPUT_DIR_TEST)
    log.info("test image saved to {}".format(os.path.join(OUTPUT_DIR_TEST, filename)))
    convert_raw_to_jpeg(OUTPUT_DIR_TEST, filename, OUTPUT_DIR_TEST)

    camera_switch_on(False)


def run():
    log.debug("taking picture")

    camera_switch_on(True)

    try:
        filename = take_image(OUTPUT_DIR_RAW)
        convert_raw_to_jpeg(OUTPUT_DIR_RAW, filename, OUTPUT_DIR_JPEG)
    except RuntimeError as re:
        # gphoto raised an error
        log.warn("run failed")
    except Exception as e:
        log.e("jpeg conversion failed: " + str(e))
    finally:
        camera_switch_on(False)

# ---------------------------------------------------------------------------------------

if __name__ == "__main__":
    initLog()

    log.info(" --- timebox start ------------------------------------------------------")

    determine_environment()

    if PLATFORM == "PI":
        import RPi.GPIO as GPIO
        GPIO.setmode(GPIO.BOARD)
        GPIO.setup(CAMERA_ENABLE_PIN, GPIO.OUT)  # Pin 11 (GPIO 17) 

    selftest()

    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        if cmd == "test":
            log.info("command: TEST")
            test()
        if cmd == "shutdown":
            log.info("command: SHUTDOWN")
            GPIO.output(CAMERA_ENABLE_PIN, GPIO.LOW)
        if cmd == "temp":
            log.info("command: TEMP")
            print read_temperature()

        exit(0)


    #convert_raw_to_jpeg(OUTPUT_DIR_RAW, "test.ARW", OUTPUT_DIR_TEST)
    #exit(0)

    if LOOK_FOR_AUTOSTART_FILE:
        if not os.path.exists(AUTOSTART_FILE):
            log.info("autostart file not found. sleep.")
            while True:
                try:
                    time.sleep(3)
                except KeyboardInterrupt as e:
                    log.info("manual exit while sleeping")
                    exit(0)
        else:
            log.info("autostart file found")

    schedule.every(10).seconds.do(run)
    schedule.every().minute.do(read_temperature)

    while True:
        schedule.run_pending()
        try:
            time.sleep(1)
        except KeyboardInterrupt as e:
            log.info("manual exit in between jobs")
            exit(0)

    exit(0)
