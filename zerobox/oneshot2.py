from zerobox import Zerobox
# from devices import Controller

import logging
import traceback

from datetime import datetime, timedelta
import time
import os
import subprocess
import sys
import yaml
import math
import shutil

import exifread
import numpy as np

CONFIG_FILE_DEFAULT = "config_default.yaml"
CONFIG_FILE_USER    = "config.yaml"

class Oneshot():

    def __init__(self):
        print("init")

        self.config = {}

        with open(CONFIG_FILE_DEFAULT, "r") as stream:
            try:
                self.config = {**self.config,**yaml.safe_load(stream)}
            except yaml.YAMLError as exc:
                print(exc)
        try:
            with open(CONFIG_FILE_USER, "r") as stream:
                self.config = {**self.config,**yaml.safe_load(stream)}
        except FileNotFoundError as e:
            print("no config file found")

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
        self.log = logging.getLogger("ZEROBOX")
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

    def _prepare_zerobox_config(self):

        zeroboxConfig = {}

        zeroboxConfig["IMAGE_DIR_PRIMARY"] = self.config["image_dir_primary"]["path"]
        zeroboxConfig["IMAGE_DIR_SECONDARY"] = self.config["image_dir_secondary"]["path"]

        if not zeroboxConfig["IMAGE_DIR_PRIMARY"] is None:
            if zeroboxConfig["IMAGE_DIR_PRIMARY"].startswith("/"):
                if not os.path.ismount(zeroboxConfig["IMAGE_DIR_PRIMARY"]):
                    self.log.warning("PRIMARY IMAGE DIR not mounted: {}".format(zeroboxConfig["IMAGE_DIR_PRIMARY"]))
                    zeroboxConfig["IMAGE_DIR_PRIMARY"] = None

        zeroboxConfig["AUTOFOCUS_ENABLED"] = self.config["autofocus"]["value"]
        zeroboxConfig["SECONDEXPOSURE_ENABLED"] = self.config["secondexposure"]["value"]
        if self.config["se_use_threshold"]["value"]:
            zeroboxConfig["SECONDEXPOSURE_THRESHOLD"] = self.config["se_threshold"]["value"]
        else:
            zeroboxConfig["SECONDEXPOSURE_THRESHOLD"] = None
        zeroboxConfig["EXPOSURE_1"] = self.config["se_expcompensation_1"]["value"]
        zeroboxConfig["EXPOSURE_2"] = self.config["se_expcompensation_2"]["value"]

        return zeroboxConfig

    def run(self):

        self.zerobox = Zerobox(new_config=self._prepare_zerobox_config())

        cameras = self.zerobox.detect_cameras()
        for portname in cameras.keys():
            self.zerobox.connect_camera(cameras[portname], quiet=True)
            self.zerobox.trigger_camera(portname)

    def close(self):
        pass


if __name__ == "__main__":

    start = datetime.now()
    print("start: {}".format(start))
    oneshot = Oneshot()
    
    oneshot.config["autofocus"]["value"] = False

    try:
        oneshot.run()
    except Exception as e:
        print(e)
    finally:
        oneshot.close()
    
    print("total runtime: {:.3f} sec".format((datetime.now()-start).total_seconds()))
