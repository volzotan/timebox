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

LOG_FILENAME_DEBUG        = "debug.log"
LOG_FILENAME_INFO         = "info.log"
LOG_FILENAME_TEMP         = "temp.log"
LOG_LEVEL_CONSOLE         = logging.DEBUG   

OUTPUT_DIR_RAW            = "RAWS"
OUTPUT_DIR_JPEG           = "JPEGS"
OUTPUT_DIR_TEST           = "TEST"

FILE_EXTENSION            = ".arw"

log = None    
logTemp = None

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


def convert_raw_to_jpeg(rawfile_path):
    # well, actually we just extract the thumbnail JPEG of the RAW
    # dcraw does not support export as JPEG and output as TIFF
    # and conversion to JPEG is unnecessary work

    subprocess.call(["dcraw", "-e", format(rawfile_path)])

    # TODO: check for success: does the file exist?


def test():
    img_path = take_image(OUTPUT_DIR_TEST)
    log.info("test image saved to {}".format(img_path))

def read_temperature():
    logTemp.info("foo")
    return 130

def foo():
    log.info("foo")



# TODO:
#
# Aus irgendeinem grunde funktioniert das erzeugen fehlender directories noch nicht und das logging in dieser methode ebenfalls nicht
#


if __name__ == "__main__":
    initLog()
    log.info(" --- timebox start ------------------------------------------------------")
    selftest()
    #take_image("foo_42.arw")

    if len(sys.argv) > 1 and sys.argv[1] == "test":
        log.info("TEST")
        test()
        log.info("Temperature: {}".format(read_temperature()))
        sys.exit(0)

    foo()
    sys.exit(0)

    schedule.every(10).seconds.do(foo)

    while True:
        schedule.run_pending()
        time.sleep(1)

    log.info("program exited")
