#!/usr/bin/env python3

from zerobox import Zerobox
from devices import TimeboxController

import logging
from datetime import datetime, timedelta
import os
import yaml
import math
import subprocess

from PIL import ImageFont
from luma.core.error import DeviceNotFoundError
from luma.core.interface.serial import i2c
from luma.core.render import canvas
from luma.oled.device import ssd1306

SHUTDOWN_IF_DONE    = True

CONFIG_FILE_DEFAULT = "config_default.yaml"
CONFIG_FILE_USER    = "config.yaml"

DISPLAY_COLOR0      = "black"
DISPLAY_COLOR1      = "white"

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

        # print('oneshot', file=open('/dev/kmsg', 'w'))

        self.init_log()

        self.log.info("------------")
        self.log.info("oneshot init")

        self.device = None
        self.display_message = []
        self.font = ImageFont.truetype("ves-3x5.ttf", 5)
        try:
            subprocess.call("modprobe i2c-bcm2835", shell=True)
            subprocess.call("modprobe i2c-dev", shell=True)
            self.device = ssd1306(i2c(), rotate=2)
            self.device.contrast(100)
        except DeviceNotFoundError as e:
            self.log.error("display not found: {}".format(e))

        self.print_display("init")

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
        self.log = logging.getLogger() #"oneshot")
        self.log.setLevel(logging.DEBUG)

        # root logger (used in devices with logging.debug(...))
        # root_logger = logging.getLogger()
        # root_logger.setLevel(logging.INFO)

        # subloggers
        exifread_logger = logging.getLogger("exifread")
        exifread_logger.setLevel(logging.INFO)

        # remove prior logging handlers
        # try:
        #     self.log.handlers.pop()
        # except Exception as e:
        #     pass

        # create formatter
        # formatter = logging.Formatter("%(asctime)s | %(name)-7s | %(levelname)-7s | %(message)s")
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

    def print_display(self, text):
        self.display_message.append(text)
        if not self.device is None:
            with canvas(self.device) as draw:

                display_message_subset = self.display_message[-8:]

                draw.rectangle([0, 0, 128-1, 64-1], outline=None, fill=DISPLAY_COLOR1)
                draw.rectangle([1, 1, 128-2, 64-2], outline=None, fill=DISPLAY_COLOR0)

                for i in range(0, len(display_message_subset)):
                    draw.text([3, 3 + i*6], display_message_subset[i].upper(), font=self.font, fill=DISPLAY_COLOR1)

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

        self.print_display("start")
        self.zerobox = Zerobox(new_config=self._prepare_zerobox_config(), logger=self.log)

        images_taken = []

        cameras = self.zerobox.detect_cameras()
        self.print_display("found cameras: {}".format(len(cameras.keys())))
        for portname in cameras.keys():
            self.zerobox.connect_camera(cameras[portname], quiet=True)
            self.print_display("camera connected")
            images = self.zerobox.trigger_camera(portname)
            images_taken += images

        msg = "done. images taken: {}".format(len(images_taken))
        self.print_display(msg)
        self.log.info(msg)

    def close(self):
        if not self.device is None:
            self.device.cleanup()
            self.device = None

    # def flush_log(self):
    #     handlers = self.log.handlers[:]
    #     for handler in handlers:
    #         handler.flush()

    #     subprocess.call(["sync"])

    def close_log(self):
        # handlers = self.log.handlers[:]
        # for handler in handlers:
        #     handler.close()
        #     self.log.removeHandler(handler)
        
        self.log.debug("logging shutdown")
        logging.shutdown()


if __name__ == "__main__":

    start = datetime.now()
    print("start: {}".format(start))
    oneshot = Oneshot()
    
    oneshot.config["autofocus"]["value"] = False

    try:
        oneshot.run()
    except Exception as e:
        print(e)
        oneshot.log.error(e)
    finally:
        oneshot.print_display("closing...")
        oneshot.close()

    oneshot.log.debug("total runtime: {:.3f} sec".format((datetime.now()-start).total_seconds()))

    if SHUTDOWN_IF_DONE:

        controller = TimeboxController.find_all()
        oneshot.log.debug("controller found: {}".format(len(controller)))

        if len(controller) > 0:
            try:

                oneshot.log.info("battery: {}".format(controller[0].get_battery_status()))
                oneshot.log.info("temperature: {}".format(controller[0].get_temperature()))

                controller[0].turn_usb_on(False)
                controller[0].turn_camera_on(False)
                controller[0].shutdown(delay=11000)

                oneshot.log.info("shutdown command sent")
                oneshot.close_log()

                # write the last log statements to disk
                # and prepare the filesystem for shutdown
                subprocess.call(["sync"])
                # subprocess.call(["swapoff", "-a"])
                # subprocess.call(["umount -a -r"])

                time.sleep(0.5)
                subprocess.call(["poweroff"])
            except Exception as e:
                oneshot.log.error("poweroff failed: {}".format(e))
        else:
            oneshot.log.error("poweroff failed: {}".format("no controller found"))

    oneshot.close_log()
