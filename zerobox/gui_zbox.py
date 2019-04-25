#!/usr/bin/env python3

import time
import psutil

from luma.core.interface.serial import i2c, spi
from luma.emulator.device import pygame, capture

from luma.core.render import canvas
from luma.oled.device import sh1106

import os
from os.path import getmtime
import subprocess
import datetime
import sys
import yaml
import rpyc

import logging

from PIL import ImageFont, Image
import PIL.ImageOps  

from zeroboxScheduler import Scheduler
from devices import UsbDirectController, RTC
from zerobox import CameraConnector

COLOR0 = "black"
COLOR1 = "white"

CONFIG_FILE_DEFAULT = "config_default.yaml"
CONFIG_FILE_USER = "config.yaml"

BTN_1 = 21
BTN_2 = 20
BTN_3 = 16
BTN_L = 5
BTN_R = 26
BTN_U = 6
BTN_D = 19
BTN_C = 13

STATE_INIT          = 0
STATE_LOGO          = 1
STATE_MENU          = 2
STATE_CONFIG        = 3
STATE_CONFIG_ITEM   = 4
STATE_DIALOG        = 5
STATE_PRE_RUN       = 6
STATE_START_RUNNING = 7
STATE_RUNNING       = 8
STATE_RUNNING_MENU  = 9
STATE_IDLE          = 10
STATE_SHUTDOWN      = 11

PLATFORM_UNKNOWN    = 0
PLATFORM_PI         = 1
PLATFORM_OSX        = 2

class Gui():

    def __init__(self):
        
        self.own_mtime = getmtime(__file__)

        self.keyEvents = []

        self.device = None
        self.pyg = None
        self.platform = PLATFORM_UNKNOWN

        if os.uname().nodename == "raspberrypi":
            self.platform = PLATFORM_PI
        else:
            self.platform = PLATFORM_OSX

        if self.platform == PLATFORM_PI:
            self.device = sh1106(spi(), rotate=2)

            import RPi.GPIO as GPIO

            GPIO.setmode(GPIO.BCM)

            GPIO.setup(BTN_1, GPIO.IN, pull_up_down=GPIO.PUD_UP)
            GPIO.setup(BTN_2, GPIO.IN, pull_up_down=GPIO.PUD_UP)
            GPIO.setup(BTN_3, GPIO.IN, pull_up_down=GPIO.PUD_UP)
            GPIO.setup(BTN_L, GPIO.IN, pull_up_down=GPIO.PUD_UP)
            GPIO.setup(BTN_R, GPIO.IN, pull_up_down=GPIO.PUD_UP)
            GPIO.setup(BTN_U, GPIO.IN, pull_up_down=GPIO.PUD_UP)
            GPIO.setup(BTN_D, GPIO.IN, pull_up_down=GPIO.PUD_UP)
            GPIO.setup(BTN_C, GPIO.IN, pull_up_down=GPIO.PUD_UP)

            time.sleep(0.3)

            GPIO.add_event_detect(BTN_1, GPIO.RISING, callback=self.button_callback)
            GPIO.add_event_detect(BTN_2, GPIO.RISING, callback=self.button_callback)
            GPIO.add_event_detect(BTN_3, GPIO.RISING, callback=self.button_callback)
            GPIO.add_event_detect(BTN_L, GPIO.RISING, callback=self.button_callback)
            GPIO.add_event_detect(BTN_R, GPIO.RISING, callback=self.button_callback)
            GPIO.add_event_detect(BTN_U, GPIO.RISING, callback=self.button_callback)
            GPIO.add_event_detect(BTN_D, GPIO.RISING, callback=self.button_callback)
            GPIO.add_event_detect(BTN_C, GPIO.RISING, callback=self.button_callback)

        else:
            self.device = pygame(width=128, height=64, mode="1", transform="scale2x", scale=2)
            self.pyg = self.device._pygame # grabs the actual pygame object in the device instance

        # device = capture(width=128, height=64, mode="1")

        # font = ImageFont.truetype("slkscr.ttf", 8)
        # font2 = ImageFont.truetype("slkscr.ttf", 16)

        self.font = ImageFont.truetype("ves-3x5.ttf", 5)
        self.FONT_CHARACTER_WIDTH = 3

        # font = ImageFont.truetype("ves-4x5.ttf", 5)
        # FONT_CHARACTER_WIDTH = 4

        # state

        self.state               = STATE_INIT #STATE_MENU # STATE_RUNNING
        self.isInvalid           = True

        self.menu_selected       = 0

        self.selectedConfigItem  = None
        self.configItemValue     = None
        self.configItemPos       = 0 # Pointer to change digits of a configItems value

        self.time_start          = None
        self.time_end            = None

        self.images_taken        = None

        # ----

        self.config = {}

        self.zeroboxConnector = None
        self.cameras = []
        self.usbController = None
        self.clock = None


    def _init_log(self):

        # create logger
        self.log = logging.getLogger()
        self.log.setLevel(logging.DEBUG)

        # create formatter
        formatter = logging.Formatter(self.config["log"]["format"])

        # console handler and set level to debug
        consoleHandler = logging.StreamHandler()
        consoleHandler.setLevel(self.config["log"]["level"])
        consoleHandler.setFormatter(formatter)
        self.log.addHandler(consoleHandler)

        fileHandlerDebug = logging.FileHandler(os.path.join(".", "gui.log"), mode="a", encoding="UTF-8") # TODO: do not use current dir for logging
        fileHandlerDebug.setLevel(logging.DEBUG)
        fileHandlerDebug.setFormatter(formatter)
        self.log.addHandler(fileHandlerDebug)


    def init(self):

        # Load Config

        with open(CONFIG_FILE_DEFAULT, "r") as stream:
            try:
                self.config = {**self.config,**yaml.load(stream)}
            except yaml.YAMLError as exc:
                print(exc)
        try:
            with open(CONFIG_FILE_USER, "r") as stream:
                self.config = {**self.config,**yaml.load(stream)}
        except FileNotFoundError as e:
            print("no config file found")

        # Logging

        self._init_log()

        # Find a zeroboxConnector

        try:
            self.zeroboxConnector = rpyc.connect("localhost", 18861)
        except ConnectionRefusedError as e:
            self.log.error("zeroboxConnector not available")
            sys.exit(-1)

        # Find cameras

        if self.zeroboxConnector is not None:
            self.cameras = self.zeroboxConnector.root.detect_cameras()
            self.log.info("found {} camera(s)".format(len(self.cameras)))

        # Find UsbDirectController

        self.usbController = UsbDirectController.find_all()
        self.log.info("found {} usbController".format(len(self.usbController)))

        # setup the Scheduler

        self.scheduler = Scheduler()
        self.scheduler.add_job("update_status", 500)
        self.scheduler.add_job("force_update_status", 2000)

        self.clock = None
        try:
            self.clock = RTC()
            self.log.info("clock found")
        except Exception as e:
            self.log.warn("no clock found")

        self.data                            = {}
        self.data["cameras"]                 = {}
        self.data["message"]                 = "..."
        self.data["total_space"]             = None
        self.data["free_space"]              = None
        self.data["last_image_brightness"]   = None

        if self.zeroboxConnector is not None:
            self.data["total_space"] = self.zeroboxConnector.root.get_total_space()
            self.data["free_space"] = self.zeroboxConnector.root.get_free_space()


    def button_callback(self, button):
        if not self.pyg:
            if button == BTN_L:
                self.keyEvents.append("l")
            if button == BTN_R:
                self.keyEvents.append("r")
            if button == BTN_U:
                self.keyEvents.append("u")
            if button == BTN_D:
                self.keyEvents.append("d")
            if button == BTN_C:
                self.keyEvents.append("c")
            if button == BTN_1:
                self.keyEvents.append("1")
            if button == BTN_2:
                self.keyEvents.append("2")
            if button == BTN_3:
                self.keyEvents.append("3")


    def checkAndRestartOnFileChange(self):
        if getmtime(__file__) != self.own_mtime:
            print("file changed. restart...")
            self.cleanup()
            time.sleep(0.5)
            os.execv(sys.executable, ['python3'] + sys.argv)


    def cleanup(self):
        self.device.cleanup()


    def invalidate(self):
        self.isInvalid = True


    def validate(self):
        self.isInvalid = False


    def _apertureToStr(self, value):
        e = 0.1

        aperture_values = [ "1.0", "1.2", "1.4", "2", 
                            "2.8", "4", "5.6", "8", 
                            "11", "16", "22", "32"]

        for a in aperture_values:
            if abs(value - float(a)) < e:
                return "F{}".format(a)

        return "F{0:.1f}".format(value)


    def _timeToStr(self, value, short=False):
        val = ""
        hours = int(value/3600)
        minutes = int(value/60)%60
        seconds = value%60

        if short:
            return "{0:02d}:{1:02d}:{2:02d}".format(hours, minutes, seconds)
        else:
            if hours > 0:
                val += "{}H ".format(hours)
            if minutes > 0:
                val += "{}MIN ".format(hours)

            val += "{}S".format(seconds)
            return val


    def _configToList(self, c):
        clist = []
        for key, value in c.items():
            if "type" not in value:
                continue
            value["name"] = key
            clist.append(value)

        return clist


    def _write_config_to_file(self, c):
        with open(CONFIG_FILE_USER, "w") as outfile:
            yaml.dump(c, outfile, default_flow_style=False)


    def _zeropad(self, value, length):
        value = str(value)
        if len(value) < length:
            value = "0" * (length-len(value)) + value

        return value


    def _changeConfigItem(self, item, value, pos, op):
        if item["type"] == "int":
            dec = len(str(int(abs(value))))
            if op > 0:
                new_value = value + (10 ** (dec-pos-1))
                if not "max" in item or new_value <= item["max"]:
                    value = new_value
            else:
                new_value = value - (10 ** (dec-pos-1))
                if not "min" in item or new_value >= item["min"]:
                    value = new_value

        elif item["type"] == "boolean":
            value = not value

        elif item["type"] == "float":
            inc = 1
            dec = len(str(int(abs(value))))
            subdec = len(str(abs(value))[dec:])
            if pos >= dec:
                inc = 10**(-(pos-dec))
            else: 
                inc = 10**(dec-pos-1)

            print(inc) 

            if op > 0:
                new = value + inc
                if not "max" in item or new <= item["max"]:
                    value = new
            else:
                new = value - inc
                if not "min" in item or new >= item["min"]:
                    value = new

        elif item["type"] == "time":
            inc = 0
            if pos == 0:
                inc += 3600 * 10
            elif pos == 1:
                inc += 3600 * 1
            elif pos == 3:
                inc += 60 * 10
            elif pos == 4:
                inc += 60 * 1
            elif pos == 6:
                inc += 10
            elif pos == 7:
                inc += 1
            else:
                raise Exception("illegal pos: {}".format(pos))

            if op > 0:
                value += inc
            else:
                value -= inc

            if "min" in item and value < item["min"]:
                value = item["min"]

            if "max" in item and value > item["max"]:
                value = item["max"]

        return value


    def _process_trigger_results(self, results):

        if len(results) > 0:
            self.images_taken += 1

            # switch off all cameras after capture
            if self.config["persistentcamera"]["value"]:
                for controller in self.usbController:
                    controller.turn_on(False)

            for result in results:
                print(result)


    def getKeyEvents(self):

        keys = []

        if self.pyg:
            events = self.pyg.event.get()
            for event in events:
                if event.type == self.pyg.KEYDOWN:
                    if event.key == self.pyg.K_LEFT:
                        keys.append("l")
                    if event.key == self.pyg.K_RIGHT:
                        keys.append("r")
                    if event.key == self.pyg.K_UP:
                        keys.append("u")
                    if event.key == self.pyg.K_DOWN:
                        keys.append("d")
                    if event.key == self.pyg.K_RETURN:
                        keys.append("c")
                    if event.key == self.pyg.K_q:
                        keys.append("1")
                    if event.key == self.pyg.K_a:
                        keys.append("2")
                    if event.key == self.pyg.K_y:
                        keys.append("3")

        keys = self.keyEvents + keys
        self.keyEvents = []
        return keys


    def rect(self, c, coords, invert=False):
        fill = COLOR1
        if invert:
            fill = COLOR0

        c.rectangle(coords, outline=None, fill=fill)


    def text(self, c, coords, t, invert=False, rightalign=False):
        s = str(t)

        fill = COLOR1
        if invert:
            fill = COLOR0

        if rightalign:
            coords[0] -= len(s) * self.FONT_CHARACTER_WIDTH + len(s) - 1
            if coords[0] < 0:
                coords[0] = 0

        c.text(coords, s.upper(), font=self.font, fill=fill)


    def draw_running(self, draw):

        # CAM SELECTOR

        # end = 9
        end = 18

        cam0 = None
        cam1 = None

        if len(self.data["cameras"].items()) > 0:
            cam0 = list(self.data["cameras"].values())[0]
        if len(self.data["cameras"].items()) > 1:
            cam1 =  list(self.data["cameras"].values())[1]

        if cam0 is not None:
            if cam0["state"] == CameraConnector.STATE_CONNECTED:
                draw.rectangle([(0, 1), (0, 1+6)], fill=COLOR1)
                self.text(draw, [2, 2], "CAM 1")
            elif cam0["state"] == CameraConnector.STATE_BUSY:
                draw.rectangle([(1, 1), (1+21, 1+6)], fill=COLOR1)
                self.text(draw, [2, 2], "CAM 1", invert=True)
            else:
                draw.rectangle([(1, 1), (1+21, 1+6)], fill=COLOR0)
                self.text(draw, [2, 2], "CAM 1")

        if cam1 is not None:
            if cam1["state"] == CameraConnector.STATE_BUSY:
                draw.rectangle([(1, 9), (1+21, 8+7)], fill=COLOR1)
                self.text(draw, [2, 2+8], "CAM 2", invert=True)
            else:
                draw.rectangle([(1, 8), (1+21, 8+7)], fill=COLOR0)
                self.text(draw, [2, 2+8], "CAM 2")

            end = 17

        draw.rectangle([(0, end), (127, end)], outline=None, fill=COLOR1)
        draw.rectangle([(24, 0), (24, end)], outline=None, fill=COLOR1)

        if cam0:
            if "error" in cam0 and cam0["error"] is not None:
                self.text(draw, [27,  2], cam0["error"])
            else:
                if "shutterspeed" in cam0:
                    self.text(draw, [35,  2], cam0["shutterspeed"])
                if "aperture" in cam0:
                    self.text(draw, [71,  2], self._apertureToStr(cam0["aperture"]))
                if "iso" in cam0:
                    self.text(draw, [95,  2], str(cam0["iso"]))
                if "expcompensation" in cam0:
                    self.text(draw, [127, 2], "+8", rightalign=True)

        if cam1:
            self.text(draw, [35,   10], "1/1250")
            self.text(draw, [71,   10], self._apertureToStr(cam1["aperture"]))
            self.text(draw, [95,   10], "300")
            self.text(draw, [127,  10], "+8", rightalign=True)

        # ERROR MESSAGE

        # if data["message"] is not None:
        #     self.text(draw, [27,  2], data["message"])

        # 2ND EXPOSURE

        start = end + 1

        if self.config["secondexposure"]["value"]:
            # self.text(draw, [1, start+2], "2.EXP")
            # draw.rectangle([(40, start+1), (40+5, start+1+5)], outline=None, fill=COLOR1)
            # self.text(draw, [1, start+9], "T:")
            # self.text(draw, [25, start+9], "10.5")
            # self.text(draw, [1, start+16], "101")
            # self.text(draw, [20, start+16], "/")
            # self.text(draw, [29, start+16], "156")

            self.text(draw, [1, start+2], "T:")
            self.text(draw, [30, start+2], "{0:.1f}".format(self.config["se_threshold"]["value"]))
            self.text(draw, [1, start+9], "LAST:")
            last_image_brightness = "?"
            if cam0 is not None and cam0["last_image_brightness"] is not None:
                last_image_brightness = "{0:.1f}".format(float(cam0["last_image_brightness"]))
            self.text(draw, [30, start+9], last_image_brightness)
            self.text(draw, [1, start+16], "101")
            self.text(draw, [20, start+16], "/")
            self.text(draw, [30, start+16], "156")
        else: 
            self.text(draw, [5, start+9], "2.EXP OFF")

        draw.rectangle([(47, start), (47, start+23)], outline=None, fill=COLOR1)
        draw.rectangle([(0, start+23), (127, start+23)], outline=None, fill=COLOR1)

        # INTERVAL

        self.text(draw, [45+5, start+2], "INTVAL")
        self.text(draw, [45+5, start+9], str(self.config["interval"]["value"]))

        time_done = (datetime.datetime.now() - self.time_start).seconds
        time_remaining = (self.time_end - datetime.datetime.now()).seconds

        self.text(draw, [127,  start+2], self._timeToStr(time_done, short=True), rightalign=True)
        self.text(draw, [127,  start+9], self._timeToStr(time_remaining, short=True), rightalign=True)

        self.text(draw, [45+5, start+16], "FR.SPC")
        self.text(draw, [127,  start+16], "{0:2.2f}GB".format(12.345), rightalign=True)


        # draw.rectangle([(64, 0), (127, 8)], fill=COLOR0)
        # self.text(draw, [90, -1], "{0:2.2f}GB".format(12.345))

        # draw.rectangle([(0, 10), (127, 10)], fill=COLOR1)
        # draw.rectangle([(38, 0), (38, 10)], fill=COLOR1)
        # draw.rectangle([(38+38, 0), (38, 10)], fill=COLOR1)

        # PROGRESS BAR

        progress = time_done / (time_done + time_remaining)

        self.text(draw, [1, 60-8], "{0:3d}/{1:3d}".format(self.images_taken, self.config["iterations"]["value"]))
        self.text(draw, [127, 60-8], "{0:2d}%".format(int(progress*100)), rightalign=True)
        if "next_invocation" in self.data and self.data["next_invocation"] is not None:
            self.text(draw, [55, 60-8], self._timeToStr((self.data["next_invocation"]-datetime.datetime.now()).seconds, short=True))
        draw.rectangle([(0, 60), (127, 63)], fill=COLOR1)
        draw.rectangle([(1, 61), (1+(127-2)*progress, 63-1)], fill=COLOR0)

        # ERROR BAR
        # draw.line([(0, 55), (128, 55)], fill=COLOR1)
        # self.text(draw, [1, 55], "ERROR FOO")


    def draw_dialog(self, draw, msg, options):

        draw.rectangle([(0, 0), (127, 64)], outline=None, fill=COLOR1)
        draw.rectangle([(1, 1), (127-1, 64-2)], outline=None, fill=COLOR0)

        self.text(draw, [10, 10], msg)
        self.text(draw, [10, 30], options[0])
        self.text(draw, [70, 30], options[1])


    def draw_logo(self, draw, info):
        draw.rectangle([(0, 0), (127, 64)], outline=None, fill=COLOR1)
        draw.bitmap((0,0), info["logo"])

        self.text(draw, [10, 36], "DEVICE")
        self.text(draw, [60, 36], info["devicename"])
        self.text(draw, [10, 44], "VERSION")
        self.text(draw, [60, 44], info["version"])
        self.text(draw, [10, 52], "MEMORY")

        if info["free_space"] is not None and info["total_space"] is not None:
            ratio = 1 - (info["free_space"] / info["total_space"])
            draw.rectangle([(60, 52), (116, 56)], outline=None, fill=COLOR1)
            draw.rectangle([(61, 53), (int(61+54*ratio), 55)], outline=None, fill=COLOR0)

        draw.rectangle([(56, 38), (56, 59)], outline=None, fill=COLOR1)


    def draw_menu(self, draw, info):

        selectedSettings = False
        selectedStart = False
        selectedShutdown = False

        if self.menu_selected == 0:
            selectedSettings = True
        elif self.menu_selected == 1:
            selectedStart = True
        elif self.menu_selected == 2:
            selectedShutdown = True

        self.text(draw, [ 2,  8], "ITERATIONS :")
        self.text(draw, [ 2, 14], "INTERVAL   :")
        self.text(draw, [ 2, 20], "RUNTIME    :")
        self.text(draw, [ 2, 26], "2ND EXP    :")
        self.text(draw, [ 2, 32], "TEMP       :")
        self.text(draw, [ 2, 38], "IMG IN MEM :")
        # self.text(draw, [ 2, 38], "FREE SPACE :")

        self.text(draw, [54, 8], self.config["iterations"]["value"])
        self.text(draw, [54, 14], self._timeToStr(self.config["interval"]["value"]))
        self.text(draw, [54, 20], self._timeToStr(self.config["interval"]["value"] * self.config["iterations"]["value"], short=True))
        text_se = str(self.config["secondexposure"]["value"])
        if self.config["secondexposure"]["value"] and self.config["se_use_threshold"]["value"]:
            text_se += " - T:" + "{0:.1f}".format(self.config["se_threshold"]["value"])
        self.text(draw, [54, 26], text_se)

        temp_str = "---"
        if info["temperature"] is not None:
            temp_str = "{0:.2f} C".format(info["temperature"])
        if info["temperature_cpu"] is not None:
            temp_str = "{0:.2f} C (CPU)".format(info["temperature_cpu"])
        if info["temperature"] is not None and info["temperature_cpu"] is not None:
            temp_str =  "{0:.2f} | {1:.2f} CPU".format(info["temperature"], info["temperature_cpu"])
        self.text(draw, [54, 32], temp_str)
        
        images_in_memory = "?"
        if info["images_in_memory"] is not None:
            images_in_memory = str(info["images_in_memory"])
        self.text(draw, [54, 38], images_in_memory) # max: 99999

        currentTime = datetime.datetime.now()
        self.rect(draw, [(127-20, 0), (127, 6)])
        self.text(draw, [127-19, 1], currentTime.strftime("%H:%M"), invert=True)

        self.rect(draw, [(0, 0), (127-22, 6)])
        self.text(draw, [2, 1], info["message"], invert=True)

        free_space = "?"
        if info["free_space"] is not None:
            free_space = "{0:.2f}".format(info["free_space"]/1024.0**3)
        self.text(draw, [126, 38], free_space, rightalign=True)

        if info["free_space"] is not None and info["total_space"] is not None:
            ratio = info["free_space"] / info["total_space"]
            self.rect(draw, [(75, 38), (100, 42)])
            if ratio < 0.99:
                self.rect(draw, [(75+1+23*ratio, 38+1), (100-1, 42-1)], invert=True)

        self.rect(draw, [(0, 45+2), (42-2, 63)], invert=not selectedSettings)
        self.rect(draw, [(42+2, 45+2), (127-42-2, 63)], invert=not selectedStart)
        self.rect(draw, [(127-40, 45+2), (127, 63)], invert=not selectedShutdown)

        self.rect(draw, [(0, 45), (127, 45)])
        self.rect(draw, [(42, 45), (42, 63)])
        self.rect(draw, [(127-42, 45), (127-42, 63)])

        self.text(draw, [ 4, 53], "SETTINGS", invert=selectedSettings)
        self.text(draw, [55, 53], "START", invert=selectedStart)
        self.text(draw, [92, 53], "SHUTDOWN", invert=selectedShutdown)


    def draw_config(self, draw, menu, selected_index):
        viewmenu = menu
        viewindex = selected_index

        if len(menu) > 8:
            if selected_index > 8:
                viewmenu = menu[selected_index-8:selected_index+1]
                viewindex = 8
            else:
                pass

        for i in range(len(viewmenu)):
            selected = False
            if i == viewindex:
                selected = True

            if isinstance(viewmenu[i], dict): # it's a config item!
                self.rect(draw, [(0, 7*i), (127, 7+7*i)], invert=not selected)
                self.text(draw, [2, 1+7*i], viewmenu[i]["name"], invert=selected)

                if viewmenu[i]["type"] == "float":
                    self.text(draw, [127, 1+7*i], "{0:.2f}".format(viewmenu[i]["value"]), invert=selected, rightalign=True)
                else:
                    self.text(draw, [127, 1+7*i], viewmenu[i]["value"], invert=selected, rightalign=True)

            elif viewmenu[i] == "-": # separator
                self.rect(draw, [(0, 1+7*i), (127, 7+7*i)], invert=not selected)
                self.rect(draw, [(0+1, 1+7*i+3), (127-1, 1+7*i+3)], invert=selected)

            else: # command
                self.rect(draw, [(0, 1+7*i), (127, 7+7*i)], invert=not selected)
                self.text(draw, [2, 2+7*i], viewmenu[i], invert=selected)


    def draw_configItem(self, draw, item, value, pos):

        self.text(draw, [2, 2], item["name"])
        self.rect(draw, [(0, 8), (100, 8)])
        self.rect(draw, [(100, 0), (100, 64)])

        self.text(draw, [127,  1], "BACK >", rightalign=True)
        self.text(draw, [127, 50], "OK >", rightalign=True)

        if item["type"] == "int":
            valueStr = str(value)
            self.text(draw, [70, 30], valueStr, rightalign=True)
            self.text(draw, [70, 38], "^" + " "*(len(valueStr)-pos-1), rightalign=True)
        elif item["type"] == "boolean":
            self.text(draw, [50, 30], str(value))
        elif item["type"] == "float":
            valueStr = "{0:.2f}".format(value)
            self.text(draw, [70, 30], valueStr, rightalign=True)
            if value < 0:
                pos += 1
            self.text(draw, [70, 38], "^" + " "*(len(valueStr)-pos-1), rightalign=True)
        elif item["type"] == "time":
       
            self.text(draw, [34, 20], "{} SEC".format(value))
            self.rect(draw, [(34, 29), (65, 29)])

            self.text(draw, [34, 34], self._zeropad(int(value/3600), 2))      # hours
            self.text(draw, [42, 34], ":")
            self.text(draw, [46, 34], self._zeropad(int(value/60)%60, 2))     # minutes
            self.text(draw, [54, 34], ":")
            self.text(draw, [58, 34], self._zeropad(value%60, 2))             # seconds

            self.text(draw, [34, 42], " " * pos + "^")

            # self.text(draw, [50, 30], value%100)
        else:
            print("unknown config item type: {}".format(item[type]))


    def draw_running_menu(self, draw, menu, selected):
        for i in range(len(menu)):
            if i == selected:
                draw.rectangle([(0, 1+7*i), (127, 7+7*i)], outline=None, fill=COLOR1)
                self.text(draw, [2, 2+7*i], menu[i], invert=True)
            else:
                self.text(draw, [2, 2+7*i], menu[i])


    def draw_info(self, draw, msg):
        maxLength = int((127-6)/(self.FONT_CHARACTER_WIDTH+1))
        offset = 3 # for vertical alignment

        self.rect(draw, [(0, 0), (127, 63)])
        self.rect(draw, [(1, 1), (127-1, 63-1)], invert=True)

        numOfLines = int(len(msg)/maxLength)
        offset = 3 + ((63 - 2) - (numOfLines+1)*6)/2

        if len(msg) > maxLength:
            for i in range(0, numOfLines):
                self.text(draw, [3, offset+i*6], msg[int(maxLength*i) : int(maxLength*(i+1))])
                self.text(draw, [3, offset+numOfLines*6], msg[int(maxLength*(numOfLines)):]) # draw remaining line of text
        else:
            self.text(draw, [3, offset], msg)


    def process_jobs(self, jobs):

        if "update_status" in jobs or "force_update_status" in jobs:

            if self.zeroboxConnector is not None:
                force = False
                if "force_update_status" in jobs:
                    force = True
                    # if None in zeroboxConnector.root.check_trigger_result():
                    #     # probably the camera is capturing right now. Do not try to get the status
                    #     force = False

                status = self.zeroboxConnector.root.get_status(force=force)
                if len(status) > 0:
                    self.data = {**self.data, **dict(status)}
                    # self.data["message"] = None


                prev_trigger_results = self.zeroboxConnector.root.check_trigger_result()
                if None in prev_trigger_results:
                    # previous trigger has not finished yet
                    pass
                else:
                    self._process_trigger_results(prev_trigger_results)

            else:
                self.data["message"] = "connector not found"

            self.data["next_invocation"] = self.scheduler.get_next_invocation("trigger")

            self.invalidate()

        if "camera_on" in jobs:
            pass

        if "trigger" in jobs:
            if self.zeroboxConnector is not None:
                try:
                    prev_trigger_results = self.zeroboxConnector.root.check_trigger_result()
                    if None in prev_trigger_results:
                        # previous trigger has not finished yet
                        log.warn("previous image hasn't finished yet. Skipping trigger")
                    else:
                        self._process_trigger_results(prev_trigger_results)

                        if self.config["persistentcamera"]["value"]:
                            for controller in self.usbController:
                                controller.turn_on(True)
                            self.zeroboxConnector.root.trigger()
                        else:
                            self.zeroboxConnector.root.trigger()

                except Exception as e:
                    self.data["message"] = "exception"
                    print(e)
            else:
                self.data["message"] = "connector not found"

            if self.images_taken == self.config["iterations"]["value"]:
                # we're done ...

                self.scheduler.remove_job("trigger")
                self.zeroboxConnector.root.disconnect_all_cameras()
                for controller in self.usbController:
                    controller.turn_on(False)

                self.data["message"] = "success. took {} images in {}".format(self.images_taken, self._timeToStr((self.time_end-self.time_start).seconds, short=True))

                self.time_start = None
                self.time_end = None
                self.images_taken = 0

                self.state = STATE_IDLE

            self.invalidate()


    def loop(self):

        triggered_jobs = self.scheduler.run_schedule()
        self.process_jobs(triggered_jobs)
        # for job in triggered_jobs:
        #     print(job)

        if "update_status" in triggered_jobs:
            self.invalidate()


        if self.state == STATE_INIT:
            print("init")
            self.invalidate()
            self.state = STATE_LOGO


        elif self.state == STATE_LOGO:
            if self.isInvalid:

                screen = {}
                logo = Image.open("logo.png")
                logo = PIL.ImageOps.invert(logo)
                logo = logo.convert("1")
                screen["logo"] = logo
                screen["devicename"] = "undefined"
                now = datetime.datetime.now()
                screen["version"] = now.strftime("%d.%m.%y")

                screen["total_space"] = None
                screen["free_space"] = None
                if self.zeroboxConnector is not None:
                    screen["total_space"] = self.data["total_space"]
                    screen["free_space"] = self.data["free_space"]

                with canvas(self.device) as draw:
                    self.draw_logo(draw, screen)

                self.validate()

            k = self.getKeyEvents()
            if "3" in k:
                self.state = STATE_MENU


        elif self.state == STATE_MENU:

            if "force_update_status" in triggered_jobs:
                if self.zeroboxConnector is not None:
                    self.cameras = self.zeroboxConnector.root.detect_cameras()
                    self.data["message"] = "cam: {} | controller: {}".format(len(self.cameras), len(self.usbController))

            if self.isInvalid:

                menu = {}

                menu["message"] = self.data["message"]

                menu["temperature"] = None
                menu["temperature_cpu"] = None
                if self.clock is not None:
                    menu["temperature"] = self.clock.read_temperature()
                if self.platform == PLATFORM_PI:
                    temp_str = str(subprocess.check_output(["vcgencmd", "measure_temp"]))
                    menu["temperature_cpu"] = float(temp_str[temp_str.index("=")+1:temp_str.index("'")])

                menu["total_space"] = self.data["total_space"]
                menu["free_space"] = self.data["free_space"]

                menu["images_in_memory"] = None
                if self.zeroboxConnector is not None:
                    menu["images_in_memory"] = len(self.zeroboxConnector.root.get_images_in_memory())

                with canvas(self.device) as draw:
                    self.draw_menu(draw, menu)
                self.validate()

                # device.hide()
                # device.show()

            k = self.getKeyEvents()
            if "l" in k:
                self.menu_selected = (self.menu_selected - 1) % 3
                self.invalidate()
            if "r" in k:
                self.menu_selected = (self.menu_selected + 1) % 3
                self.invalidate()
            if "3" in k:
                if self.menu_selected == 0:
                    self.state = STATE_CONFIG
                elif self.menu_selected == 1:
                    self.state = STATE_PRE_RUN
                elif self.menu_selected == 2:
                    self.state = STATE_SHUTDOWN
                else:
                    raise Exception("illegal menu selected state: {}".format(self.menu_selected))

                self.menu_selected = 0
                self.invalidate()


        elif self.state == STATE_CONFIG:
            # draw_dialog(draw, "abort capture?", ["no", "yes"])

            # menu = menu_fix + ["-"] + _configToList(config)
            menu = self._configToList(self.config)
            menu.append("-")
            menu.append("camera on")
            menu.append("camera off")
            menu.append("reset to default config")

            if self.isInvalid:
                with canvas(self.device) as draw:
                    self.draw_config(draw, menu, self.menu_selected)
                self.validate()

            k = self.getKeyEvents()
            if "u" in k:
                self.menu_selected = (self.menu_selected - 1) % len(menu)
                self.invalidate()
            if "d" in k:
                self.menu_selected = (self.menu_selected + 1) % len(menu)
                self.invalidate()
            if "3" in k:
                length_configitems = len(self._configToList(self.config))
                if self.menu_selected < length_configitems:
                    self.selectedConfigItem = self.config[self._configToList(self.config)[self.menu_selected]["name"]]
                    self.configItemValue = self.selectedConfigItem["value"]
                    self.configItemPos = 0
                    self.state = STATE_CONFIG_ITEM
                    self.invalidate()
                else:
                    option = self.menu_selected - length_configitems
                    if option == 0:
                        pass # separator
                    elif option == 1:
                        # camera on
                        for c in self.usbController:
                            c.turn_on(True)
                    elif option == 2:
                        # camera off
                        for c in self.usbController:
                            c.turn_on(False)
                    elif option == 3:
                        # reset to default config
                        with open(CONFIG_FILE_DEFAULT, "r") as stream:
                            try:
                                self.config = yaml.load(stream)
                            except yaml.YAMLError as exc:
                                print(exc)
                        self._write_config_to_file(self.config)
                    else:
                        raise Exception("illegal menu option: {}".format(option))
            if "1" in k:
                self.state = STATE_MENU
                self.menu_selected = 0
                self.invalidate()


        elif self.state == STATE_CONFIG_ITEM:
            if self.isInvalid:
                with canvas(self.device) as draw:
                    self.draw_configItem(draw, self.selectedConfigItem, self.configItemValue, self.configItemPos)
                self.validate()

            item = self.selectedConfigItem

            k = self.getKeyEvents()
            if "u" in k:
                self.configItemValue = self._changeConfigItem(self.selectedConfigItem, self.configItemValue, self.configItemPos, 1)
                self.invalidate()
            if "d" in k:
                self.configItemValue = self._changeConfigItem(self.selectedConfigItem, self.configItemValue, self.configItemPos, -1)
                self.invalidate()
            if "l" in k:
                if self.configItemPos > 0:
                    self.configItemPos -= 1
                    if item["type"] == "float":
                        if self.configItemPos == len(str(int(abs(self.configItemValue)))):
                            self.configItemPos -= 1
                elif item["type"] == "time":
                    if self.configItemPos > 0:
                        self.configItemPos -= 1
                        if self.configItemPos == 2 or self.configItemPos == 5:
                           self.configItemPos -= 1
            if "r" in k:
                if item["type"] == "int":
                    print(self.configItemPos)
                    if self.configItemPos < len(str(int(abs(self.configItemValue))))-1:
                        self.configItemPos += 1
                if item["type"] == "float":
                    print("{0:.2f}".format(abs(self.configItemValue)))
                    if self.configItemPos < len("{0:.2f}".format(abs(self.configItemValue)))-1:
                        self.configItemPos += 1
                        if self.configItemPos == len(str(int(abs(self.configItemValue)))):
                            self.configItemPos += 1
                elif item["type"] == "time":
                    if self.configItemPos < 10:
                        self.configItemPos += 1
                        if self.configItemPos == 2 or self.configItemPos == 5:
                           self.configItemPos += 1
            if "1" in k:
                self.selectedConfigItem = None
                self.configItemValue = None
                self.state = STATE_CONFIG
                self.invalidate()
            if "3" in k:
                self.selectedConfigItem["value"] = self.configItemValue
                self.selectedConfigItem = None
                self.configItemValue = None
                self.state = STATE_CONFIG
                self.invalidate()

                self._write_config_to_file(self.config)


        elif self.state == STATE_PRE_RUN:
            # if isInvalid:
            #     with canvas(device) as draw:
            #         draw_info(draw, "start")
            #     validate()

            self.zeroboxConnector = rpyc.connect("localhost", 18861)
            self.zeroboxConnector.root.load_config({})

            zeroboxConfig = {}

            zeroboxConfig["AUTOFOCUS_ENABLED"] = self.config["autofocus"]["value"]
            zeroboxConfig["SECONDEXPOSURE_ENABLED"] = self.config["secondexposure"]["value"]
            if self.config["se_use_threshold"]["value"]:
                zeroboxConfig["SECONDEXPOSURE_THRESHOLD"] = self.config["se_threshold"]["value"]
            else:
                zeroboxConfig["SECONDEXPOSURE_THRESHOLD"] = None
            zeroboxConfig["EXPOSURE_1"] = self.config["se_expcompensation_1"]["value"]
            zeroboxConfig["EXPOSURE_2"] = self.config["se_expcompensation_2"]["value"]

            self.zeroboxConnector.root.load_config(zeroboxConfig)

            self.cameras = self.zeroboxConnector.root.detect_cameras()

            for portname, camera in self.cameras.items():
                try:
                    self.zeroboxConnector.root.connect(portname)
                except Exception as e:
                    print(e)

                    # TODO: go to exception state
                    # if portname not in data["cameras"]:
                    #     data["cameras"][portname] = {}

                    # data["cameras"][portname]["message"] = "conn error"

            self.time_start = datetime.datetime.now()
            self.time_end   = self.time_start + datetime.timedelta(seconds=(self.config["interval"]["value"] * self.config["iterations"]["value"]))

            self.images_taken = 0

            interval = self.config["interval"]["value"]*1000
            if self.config["persistentcamera"]["value"]:
                self.scheduler.add_job("trigger", interval)
            else:
                self.scheduler.add_job("camera_on", interval)
                self.scheduler.add_job("trigger", interval, delay=float(self.config["pc_pre_wait"]["value"])*1000)
                # max time the camera may be alive. shut already be shut down after
                # the trigger event returned, but just as a safeguard
                self.scheduler.add_job("camera_off", interval, delay=(30.0+float(self.config["pc_pre_wait"]["value"]))*1000)

            self.state = STATE_START_RUNNING


        elif self.state == STATE_START_RUNNING:

            # TODO: check for connected cameras and other prerequisites

            self.state = STATE_RUNNING


        elif self.state == STATE_RUNNING:
            if self.invalidate:
                with canvas(self.device) as draw:
                    self.draw_running(draw)
                self.validate()
            
            k = self.getKeyEvents()
            if "1" in k or "2" in k or "3" in k:
                self.state = STATE_RUNNING_MENU
                self.invalidate()


        elif self.state == STATE_RUNNING_MENU:

            menu = ["back", "stop"]

            if self.isInvalid:
                with canvas(self.device) as draw:
                    self.draw_running_menu(draw, menu, self.menu_selected)
                self.validate()

            k = self.getKeyEvents()
            if "u" in k:
                self.menu_selected = (self.menu_selected - 1) % len(menu)
                self.invalidate()
            if "d" in k:
                self.menu_selected = (self.menu_selected + 1) % len(menu)
                self.invalidate()
            if "1" in k:
                self.menu_selected = 0
                self.state = STATE_RUNNING
                self.invalidate()
            if "3" in k:
                if self.menu_selected == 0:
                    self.menu_selected = 0
                    self.state = STATE_RUNNING

                elif self.menu_selected == 1:
                    self.scheduler.remove_job("trigger")
                    self.zeroboxConnector.root.disconnect_all_cameras()
                    for controller in self.usbController:
                        controller.turn_on(False)

                    report = "Abort. Took {} images in {}".format(self.images_taken, self._timeToStr((self.time_end-self.time_start).seconds, short=True))
                    self.data["message"] = report

                    self.time_start = None
                    self.time_end = None
                    self.images_taken = 0

                    self.state = STATE_IDLE
                    # display report
                    # took 123 photos in 1h23min 

                else:
                    raise Exception("illegal menu selected state: {}".format(menu_selected))

                self.invalidate()


        elif self.state == STATE_IDLE:

            with canvas(self.device) as draw:
                self.draw_info(draw, self.data["message"])

            k = self.getKeyEvents()
            if "3" in k:
                self.data["message"] = None
                self.state = STATE_MENU
                self.invalidate()


        elif self.state == STATE_SHUTDOWN:

            with canvas(self.device) as draw:
                self.draw_info(draw, "shutdown ...")
            time.sleep(1.0)
            subprocess.run(["sudo", "shutdown", "now"])


        else:
            raise Exception("illegal state: {}".format(self.state))

        self.checkAndRestartOnFileChange()


if __name__ == "__main__":
    g = Gui()
    g.init()
    while True:
        g.loop()
        time.sleep(0.1)
