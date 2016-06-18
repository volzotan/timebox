#!/bin/python

#import gphoto2 as gp
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



if __name__ == "__main__":
    initLog()
    log.info(" --- timebox start ------------------------------------------------------")
    selftest()

   # selftest

# context = gp.Context()
# camera = gp.Camera()
# camera.init(context)
# camera.exit(context)