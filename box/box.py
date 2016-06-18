#!/bin/python

import gphoto2 as gp
import logging
import os

LOG_FILENAME_DEBUG        = "debug.log"
LOG_FILENAME_INFO         = "info.log"
LOG_LEVEL_CONSOLE         = logging.DEBUG   

OUTPUT_DIR_RAW            = "raws"

log = None    

def initLog():
    global log

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

    log.info("selftest finished")


def take_image(filename):
    # context = gp.Context()
    # camera = gp.Camera()
    # camera.init(context)
    # camera.exit(context)

    gp.check_result(gp.use_python_logging())
    context = gp.gp_context_new()
    camera = gp.check_result(gp.gp_camera_new())
    gp.check_result(gp.gp_camera_init(camera, context))
    print('Capturing image')
    file_path = gp.check_result(gp.gp_camera_capture(
        camera, gp.GP_CAPTURE_IMAGE, context))
    print('Camera file path: {0}/{1}'.format(file_path.folder, file_path.name))
    target = os.path.join(OUTPUT_DIR_RAW, filename)
    print('Copying image to', target)
    camera_file = gp.check_result(gp.gp_camera_file_get(
            camera, file_path.folder, file_path.name,
            gp.GP_FILE_TYPE_NORMAL, context))
    gp.check_result(gp.gp_file_save(camera_file, target))
    subprocess.call(['xdg-open', target])
    gp.check_result(gp.gp_camera_exit(camera, context))


if __name__ == "__main__":
    initLog()
    log.info(" --- timebox start ------------------------------------------------------")
    selftest()
    take_image("foo_42.arw")
