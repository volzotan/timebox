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

LOG_FILENAME_DEBUG        = "debug.log"
LOG_FILENAME_INFO         = "info.log"
LOG_FILENAME_TEMP         = "temp.log"
LOG_LEVEL_CONSOLE         = logging.DEBUG   

AUTOSTART_FILE            = "AUTOSTART.CMD"

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

    output = subprocess.check_output(["uname", "-a"])

    if "Darwin" in output:
        PLATFORM = "OSX"
    elif "raspberrypi" in output:
        PLATFORM = "PI"
    elif "Linux" in output:
        PLATFORM = "LINUX"
    else:
        PLATFORM = "UNKNOWN"

    log.debug("platform: {}".format(PLATFORM))


def _expand_path(base_dir, input_path):
    if not (input_path.startswith("/") or input_path.startswith("~")):
        return os.path.join(base_dir, input_path)

    return input_path


def _check_dir(path):
    if os.path.exists(OUTPUT_DIR_RAW):
        if os.path.isdir(OUTPUT_DIR_RAW):
            pass # OK
        else:
            log.error("output dir \"{}\" is actually a file. abort.".format(OUTPUT_DIR_RAW))
            exit()
    else:
        log.warn("output dir \"{}\" is missing. create directory...".format(OUTPUT_DIR_RAW))
        os.makedirs(OUTPUT_DIR_RAW)


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


def acquire_filename(path):
    name = datetime.datetime.now().strftime("%Y-%m-%d--%H-%M-%S")
    name_plus_extension = name + FILE_EXTENSION

    full_name = os.path.join(path, name_plus_extension)

    if os.path.exists(full_name):
        full_name = None
        for i in range(0, 999):
            new_full_name = os.path.join(path, name + "_" + i + FILE_EXTENSION)
            if not os.path.exists(new_full_name):
                full_name = new_full_name
                break;

    return full_name

# returns full path to image, including name
def take_image(path):

    filename = acquire_filename(path)
    if filename is None:
        log.error("no filename could be acquired [{}]".format(path))
        return

    try: 
        gp.check_result(gp.use_python_logging())
        context = gp.gp_context_new()
        camera = gp.check_result(gp.gp_camera_new())
        gp.check_result(gp.gp_camera_init(camera, context))
        print('Capturing image')
        file_path = gp.check_result(gp.gp_camera_capture(
            camera, gp.GP_CAPTURE_IMAGE, context))
        print('Camera file path: {0}/{1}'.format(file_path.folder, file_path.name))
        target = os.path.join(path, filename)
        print('Copying image to', target)
        camera_file = gp.check_result(gp.gp_camera_file_get(
                camera, file_path.folder, file_path.name,
                gp.GP_FILE_TYPE_NORMAL, context))
        gp.check_result(gp.gp_file_save(camera_file, target))
        gp.check_result(gp.gp_camera_exit(camera, context))

        return target
    except Exception as e:
        log.error(e)


def convert_raw_to_jpeg(rawfile_full_name, jpeg_path):
    # well, actually we just extract the thumbnail JPEG of the RAW
    # dcraw does not support export as JPEG and output as TIFF
    # and conversion to JPEG is unnecessary work

    subprocess.call(["dcraw", "-e", format(rawfile_path)])

    # TODO: output path

    # TODO: check for success: does the file exist?


def exit(code):
    GPIO.cleanup()
    log.info("program exited")
    sys.exit(code)


def read_temperature():
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

    # power on
    GPIO.output(CAMERA_ENABLE_PIN, GPIO.HIGH)
    time.sleep(10)

    img_path = take_image(OUTPUT_DIR_TEST)
    log.info("test image saved to {}".format(img_path))

    # power off
    time.sleep(2)
    GPIO.output(CAMERA_ENABLE_PIN, GPIO.LOW)


def run():
    log.debug("taking picture")

    # power on
    GPIO.output(CAMERA_ENABLE_PIN, GPIO.HIGH)
    time.sleep(10)

    full_name = acquire_filename(OUTPUT_DIR_RAW)
    take_image(full_name)
    try:
        convert_raw_to_jpeg(rawfile_path, OUTPUT_DIR_JPEG)
    except Exception as e:
        log.e("jpeg conversion failed: " + str(e))

    # power off
    time.sleep(2)
    GPIO.output(CAMERA_ENABLE_PIN, GPIO.LOW)



# TODO:
#
# Aus irgendeinem grunde funktioniert das erzeugen fehlender directories noch nicht und das logging in dieser methode ebenfalls nicht
#


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

    if not os.path.exists(AUTOSTART_FILE):
        log.info("autostart file not found. sleep.")
        while True:
            time.sleep(3)
    else:
        log.info("autostart file found")

    exit(0)

    schedule.every(10).seconds.do(run)

    while True:
        schedule.run_pending()
        time.sleep(1)

    exit(0)
