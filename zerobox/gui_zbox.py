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

import logging as log

from PIL import ImageFont, Image
import PIL.ImageOps  

from zeroboxScheduler import Scheduler
from devices import UsbDirectController, RTC

COLOR0 = "black"
COLOR1 = "white"

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

own_mtime = getmtime(__file__)

PLATFORM_UNKNOWN    = 0
PLATFORM_PI         = 1
PLATFORM_OSX        = 2

device = None
pyg = None
platform = PLATFORM_UNKNOWN

keyEvents = []

def button_callback(button):
    if not pyg:
        if button == BTN_L:
            keyEvents.append("l")
        if button == BTN_R:
            keyEvents.append("r")
        if button == BTN_U:
            keyEvents.append("u")
        if button == BTN_D:
            keyEvents.append("d")
        if button == BTN_C:
            keyEvents.append("c")
        if button == BTN_1:
            keyEvents.append("1")
        if button == BTN_2:
            keyEvents.append("2")
        if button == BTN_3:
            keyEvents.append("3")


if os.uname().nodename == "raspberrypi":
    platform = PLATFORM_PI
else:
    platform = PLATFORM_OSX


if platform == PLATFORM_PI:
    device = sh1106(spi(), rotate=2)

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

    GPIO.add_event_detect(BTN_1, GPIO.RISING, callback=button_callback)
    GPIO.add_event_detect(BTN_2, GPIO.RISING, callback=button_callback)
    GPIO.add_event_detect(BTN_3, GPIO.RISING, callback=button_callback)
    GPIO.add_event_detect(BTN_L, GPIO.RISING, callback=button_callback)
    GPIO.add_event_detect(BTN_R, GPIO.RISING, callback=button_callback)
    GPIO.add_event_detect(BTN_U, GPIO.RISING, callback=button_callback)
    GPIO.add_event_detect(BTN_D, GPIO.RISING, callback=button_callback)
    GPIO.add_event_detect(BTN_C, GPIO.RISING, callback=button_callback)

else:
    device = pygame(width=128, height=64, mode="1", transform="scale2x", scale=2)
    pyg = device._pygame # grabs the actual pygame object in the device instance 

# device = capture(width=128, height=64, mode="1")

# font = ImageFont.truetype("slkscr.ttf", 8)
# font2 = ImageFont.truetype("slkscr.ttf", 16)

font = ImageFont.truetype("ves-3x5.ttf", 5)
FONT_CHARACTER_WIDTH = 3

# font = ImageFont.truetype("ves-4x5.ttf", 5)
# FONT_CHARACTER_WIDTH = 4

# state

state               = STATE_INIT #STATE_MENU # STATE_RUNNING
isInvalid           = True

menu_selected       = 0

selectedConfigItem  = None
configItemValue     = None
configItemPos       = 0 # Pointer to change digits of a configItems value

time_start          = None
time_end            = None

images_taken        = None


def checkAndRestartOnFileChange():
    if getmtime(__file__) != own_mtime:
        print("file changed. restart...")
        cleanup()
        time.sleep(0.5)
        os.execv(sys.executable, ['python3'] + sys.argv)


def cleanup():
    device.cleanup()


def invalidate():
    isInvalid = True


def validate():
    isInvalid = False
    # pass


def _apertureToStr(value):
    e = 0.1

    aperture_values = [ "1.0", "1.2", "1.4", "2", 
                        "2.8", "4", "5.6", "8", 
                        "11", "16", "22", "32"]

    for a in aperture_values:
        if abs(value - float(a)) < e:
            return "F{}".format(a)

    return "F{0:.1f}".format(value)


def _timeToStr(value, short=False):
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


def _configToList(c):
    clist = []
    for key, value in c.items():
        if "type" not in value:
            continue
        value["name"] = key
        clist.append(value)

    return clist


def _zeropad(value, length):
    value = str(value)
    if len(value) < length:
        value = "0" * (length-len(value)) + value

    return value


def _changeConfigItem(item, value, pos, op):
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


def getKeyEvents():
    
    global keyEvents

    keys = []

    if pyg:
        events = pyg.event.get()
        for event in events:
            if event.type == pyg.KEYDOWN:
                if event.key == pyg.K_LEFT:
                    keys.append("l")
                if event.key == pyg.K_RIGHT:
                    keys.append("r")
                if event.key == pyg.K_UP:
                    keys.append("u")
                if event.key == pyg.K_DOWN:
                    keys.append("d")
                if event.key == pyg.K_RETURN:
                    keys.append("c")
                if event.key == pyg.K_q:
                    keys.append("1")
                if event.key == pyg.K_a:
                    keys.append("2")
                if event.key == pyg.K_y:
                    keys.append("3")

    keys = keyEvents + keys
    keyEvents = []
    return keys


def rect(c, coords, invert=False):
    fill = COLOR1
    if invert:
        fill = COLOR0

    draw.rectangle(coords, outline=None, fill=fill)


def text(c, coords, t, invert=False, rightalign=False):
    s = str(t)

    fill = COLOR1
    if invert:
        fill = COLOR0

    if rightalign:
        coords[0] -= len(s) * FONT_CHARACTER_WIDTH + len(s) - 1
        if coords[0] < 0:
            coords[0] = 0

    c.text(coords, s.upper(), font=font, fill=fill)


def draw_running(draw, config, data):

    # CAM SELECTOR

    # end = 9
    end = 18

    cam0 = None
    cam1 = None

    if len(data["cameras"].items()) > 0:
        cam0 = list(data["cameras"].values())[0]
    if len(data["cameras"].items()) > 1:
        cam1 =  list(data["cameras"].values())[1]

    if cam0 is not None:
        if cam0["active"]:
            draw.rectangle([(1, 1), (1+21, 1+6)], fill=COLOR1)
            text(draw, [2, 2], "CAM 1", invert=True)
        else:
            draw.rectangle([(1, 1), (1+21, 1+6)], fill=COLOR0)
            text(draw, [2, 2], "CAM 1")

    if cam1 is not None:
        if cam1["active"]:
            draw.rectangle([(1, 9), (1+21, 8+7)], fill=COLOR1)
            text(draw, [2, 2+8], "CAM 2", invert=True)
        else:
            draw.rectangle([(1, 8), (1+21, 8+7)], fill=COLOR0)
            text(draw, [2, 2+8], "CAM 2")

        end = 17

    draw.rectangle([(0, end), (127, end)], outline=None, fill=COLOR1)
    draw.rectangle([(24, 0), (24, end)], outline=None, fill=COLOR1)

    if cam0:
        if "error" in cam0 and cam0["error"] is not None:
            text(draw, [27,  2], cam0["error"])
        else:
            if "shutterspeed" in cam0:
                text(draw, [35,  2], cam0["shutterspeed"])
            if "aperture" in cam0:
                text(draw, [71,  2], _apertureToStr(cam0["aperture"]))
            if "iso" in cam0:
                text(draw, [95,  2], str(cam0["iso"]))
            if "expcompensation" in cam0:
                text(draw, [127, 2], "+8", rightalign=True)

    if cam1:
        text(draw, [35,   10], "1/1250")
        text(draw, [71,   10], _apertureToStr(cam1["aperture"]))
        text(draw, [95,   10], "300")
        text(draw, [127,  10], "+8", rightalign=True)

    # ERROR MESSAGE

    # if data["message"] is not None:
    #     text(draw, [27,  2], data["message"])

    # 2ND EXPOSURE

    start = end + 1

    if config["secondexposure"]["value"]:
        # text(draw, [1, start+2], "2.EXP")
        # draw.rectangle([(40, start+1), (40+5, start+1+5)], outline=None, fill=COLOR1)
        # text(draw, [1, start+9], "T:")
        # text(draw, [25, start+9], "10.5")
        # text(draw, [1, start+16], "101")
        # text(draw, [20, start+16], "/")
        # text(draw, [29, start+16], "156")

        text(draw, [1, start+2], "T:")
        text(draw, [30, start+2], "{0:.1f}".format(config["se_threshold"]["value"]))
        text(draw, [1, start+9], "LAST:")
        last_image_brightness = "?"
        if data["last_image_brightness"] is not None:
            "{0:.1f}".format(data["last_image_brightness"])
        text(draw, [30, start+9], last_image_brightness)
        text(draw, [1, start+16], "101")
        text(draw, [20, start+16], "/")
        text(draw, [30, start+16], "156")
    else: 
        text(draw, [5, start+9], "2.EXP OFF")

    draw.rectangle([(47, start), (47, start+23)], outline=None, fill=COLOR1)
    draw.rectangle([(0, start+23), (127, start+23)], outline=None, fill=COLOR1)

    # INTERVAL

    text(draw, [45+5, start+2], "INTVAL")
    text(draw, [45+5, start+9], str(config["interval"]["value"]))

    time_done = (datetime.datetime.now() - time_start).seconds
    time_remaining = (time_end - datetime.datetime.now()).seconds

    text(draw, [127,  start+2], _timeToStr(time_done, short=True), rightalign=True)
    text(draw, [127,  start+9], _timeToStr(time_remaining, short=True), rightalign=True)

    text(draw, [45+5, start+16], "FR.SPC")
    text(draw, [127,  start+16], "{0:2.2f}GB".format(12.345), rightalign=True)


    # draw.rectangle([(64, 0), (127, 8)], fill=COLOR0)
    # text(draw, [90, -1], "{0:2.2f}GB".format(12.345))

    # draw.rectangle([(0, 10), (127, 10)], fill=COLOR1)
    # draw.rectangle([(38, 0), (38, 10)], fill=COLOR1)
    # draw.rectangle([(38+38, 0), (38, 10)], fill=COLOR1)

    # PROGRESS BAR

    progress = time_done / (time_done + time_remaining)

    text(draw, [1, 60-8], "{0:3d}/{1:3d}".format(data["images_taken"], config["iterations"]["value"]))
    text(draw, [127, 60-8], "{0:2d}%".format(int(progress*100)), rightalign=True)
    if "next_invocation" in data and data["next_invocation"] is not None:
        text(draw, [55, 60-8], _timeToStr((data["next_invocation"]-datetime.datetime.now()).seconds, short=True))
    draw.rectangle([(0, 60), (127, 63)], fill=COLOR1)
    draw.rectangle([(1, 61), (1+(127-2)*progress, 63-1)], fill=COLOR0)

    # ERROR BAR
    # draw.line([(0, 55), (128, 55)], fill=COLOR1)
    # text(draw, [1, 55], "ERROR FOO")


def draw_dialog(draw, msg, options):

    draw.rectangle([(0, 0), (127, 64)], outline=None, fill=COLOR1)
    draw.rectangle([(1, 1), (127-1, 64-2)], outline=None, fill=COLOR0)

    text(draw, [10, 10], msg)
    text(draw, [10, 30], options[0])
    text(draw, [70, 30], options[1])


def draw_logo(draw, data):
    draw.rectangle([(0, 0), (127, 64)], outline=None, fill=COLOR1)
    draw.bitmap((0,0), data["logo"])

    text(draw, [10, 36], "DEVICE")
    text(draw, [60, 36], data["devicename"])
    text(draw, [10, 44], "VERSION")
    text(draw, [60, 44], data["version"])
    text(draw, [10, 52], "MEMORY")

    if data["free_space"] is not None and data["total_space"] is not None:
        ratio = 1 - (data["free_space"] / data["total_space"])
        draw.rectangle([(60, 52), (116, 56)], outline=None, fill=COLOR1)
        draw.rectangle([(61, 53), (int(61+54*ratio), 55)], outline=None, fill=COLOR0)

    draw.rectangle([(56, 38), (56, 59)], outline=None, fill=COLOR1)


def draw_menu(draw, config, data, selected_index):

    selectedSettings = False
    selectedStart = False
    selectedShutdown = False

    if selected_index == 0:
        selectedSettings = True
    elif selected_index == 1:
        selectedStart = True
    elif selected_index == 2:
        selectedShutdown = True

    text(draw, [ 2,  8], "ITERATIONS :")
    text(draw, [ 2, 14], "INTERVAL   :")
    text(draw, [ 2, 20], "RUNTIME    :")
    text(draw, [ 2, 26], "2ND EXP    :")
    text(draw, [ 2, 32], "TEMP       :")
    text(draw, [ 2, 38], "IMG IN MEM :")
    # text(draw, [ 2, 38], "FREE SPACE :")

    text(draw, [54, 8], config["iterations"]["value"])
    text(draw, [54, 14], _timeToStr(config["interval"]["value"]))
    text(draw, [54, 20], _timeToStr(config["interval"]["value"] * config["iterations"]["value"], short=True))
    text_se = str(config["secondexposure"]["value"])
    if config["secondexposure"]["value"] and config["se_use_threshold"]["value"]:
        text_se += " - T:" + "{0:.1f}".format(config["se_threshold"]["value"])
    text(draw, [54, 26], text_se)

    temp_str = "---"
    if data["temperature"] is not None:
        temp_str = "{0:.2f} C".format(data["temperature"])
    if data["temperature_cpu"] is not None:
        temp_str = "{0:.2f} C (CPU)".format(data["temperature_cpu"])
    if data["temperature"] is not None and data["temperature_cpu"] is not None:
        temp_str =  "{0:.2f} | {1:.2f} CPU".format(data["temperature"], data["temperature_cpu"])
    text(draw, [54, 32], temp_str)
    
    images_in_memory = "?"
    if data["images_in_memory"] is not None:
        images_in_memory = str(data["images_in_memory"])
    text(draw, [54, 38], images_in_memory) # max: 99999

    currentTime = datetime.datetime.now()
    rect(draw, [(127-20, 0), (127, 6)])
    text(draw, [127-19, 1], currentTime.strftime("%H:%M"), invert=True)

    rect(draw, [(0, 0), (127-22, 6)])
    text(draw, [2, 1], data["message"], invert=True)

    free_space = "?"
    if data["free_space"] is not None:
        free_space = "{0:.2f}".format(data["free_space"]/1024.0**3)
    text(draw, [126, 38], free_space, rightalign=True)

    if data["free_space"] is not None and data["total_space"] is not None:
        ratio = data["free_space"] / data["total_space"]
        rect(draw, [(75, 38), (100, 42)])
        if ratio < 0.99:
            rect(draw, [(75+1+23*ratio, 38+1), (100-1, 42-1)], invert=True)

    rect(draw, [(0, 45+2), (42-2, 63)], invert=not selectedSettings)
    rect(draw, [(42+2, 45+2), (127-42-2, 63)], invert=not selectedStart)
    rect(draw, [(127-40, 45+2), (127, 63)], invert=not selectedShutdown)

    rect(draw, [(0, 45), (127, 45)])
    rect(draw, [(42, 45), (42, 63)])
    rect(draw, [(127-42, 45), (127-42, 63)])

    text(draw, [ 4, 53], "SETTINGS", invert=selectedSettings)
    text(draw, [55, 53], "START", invert=selectedStart)
    text(draw, [92, 53], "SHUTDOWN", invert=selectedShutdown)


def draw_config(draw, menu, selected_index):
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
            rect(draw, [(0, 7*i), (127, 7+7*i)], invert=not selected)
            text(draw, [2, 1+7*i], viewmenu[i]["name"], invert=selected)

            if viewmenu[i]["type"] == "float":
                text(draw, [127, 1+7*i], "{0:.2f}".format(viewmenu[i]["value"]), invert=selected, rightalign=True)
            else:
                text(draw, [127, 1+7*i], viewmenu[i]["value"], invert=selected, rightalign=True)

        elif viewmenu[i] == "-": # separator
            rect(draw, [(0, 1+7*i), (127, 7+7*i)], invert=not selected)
            rect(draw, [(0+1, 1+7*i+3), (127-1, 1+7*i+3)], invert=selected)

        else: # command
            rect(draw, [(0, 1+7*i), (127, 7+7*i)], invert=not selected)
            text(draw, [2, 2+7*i], viewmenu[i], invert=selected)


def draw_configItem(draw, item, value, pos):

    text(draw, [2, 2], item["name"])
    rect(draw, [(0, 8), (100, 8)])
    rect(draw, [(100, 0), (100, 64)])

    text(draw, [127,  1], "BACK >", rightalign=True)
    text(draw, [127, 50], "OK >", rightalign=True)

    if item["type"] == "int":
        valueStr = str(value)
        text(draw, [70, 30], valueStr, rightalign=True)
        text(draw, [70, 38], "^" + " "*(len(valueStr)-pos-1), rightalign=True)
    elif item["type"] == "boolean":
        text(draw, [50, 30], str(value))
    elif item["type"] == "float":
        valueStr = "{0:.2f}".format(value)
        text(draw, [70, 30], valueStr, rightalign=True)
        if value < 0:
            pos += 1
        text(draw, [70, 38], "^" + " "*(len(valueStr)-pos-1), rightalign=True)
    elif item["type"] == "time":
   
        text(draw, [34, 20], "{} SEC".format(value))
        rect(draw, [(34, 29), (65, 29)])

        text(draw, [34, 34], _zeropad(int(value/3600), 2))      # hours
        text(draw, [42, 34], ":")
        text(draw, [46, 34], _zeropad(int(value/60)%60, 2))     # minutes
        text(draw, [54, 34], ":")
        text(draw, [58, 34], _zeropad(value%60, 2))             # seconds

        text(draw, [34, 42], " " * pos + "^")

        # text(draw, [50, 30], value%100)
    else:
        print("unknown config item type: {}".format(item[type]))


def draw_running_menu(draw, menu, selected):
    for i in range(len(menu)):
        if i == selected:
            draw.rectangle([(0, 1+7*i), (127, 7+7*i)], outline=None, fill=COLOR1)
            text(draw, [2, 2+7*i], menu[i], invert=True)
        else:
            text(draw, [2, 2+7*i], menu[i])


def draw_info(draw, msg):
    maxLength = int((127-6)/(FONT_CHARACTER_WIDTH+1))
    offset = 3 # for vertical alignment

    rect(draw, [(0, 0), (127, 63)])
    rect(draw, [(1, 1), (127-1, 63-1)], invert=True)

    numOfLines = int(len(msg)/maxLength)
    offset = 3 + ((63 - 2) - (numOfLines+1)*6)/2

    if len(msg) > maxLength:
        for i in range(0, numOfLines):
            text(draw, [3, offset+i*6], msg[int(maxLength*i) : int(maxLength*(i+1))])
            text(draw, [3, offset+numOfLines*6], msg[int(maxLength*(numOfLines)):]) # draw remaining line of text
    else:
        text(draw, [3, offset], msg)


if __name__ == "__main__":

    # Load Config

    config = None
    with open("config.yaml", "r") as stream:
        try:
            config = yaml.load(stream)
        except yaml.YAMLError as exc:
            print(exc)

    # Logging

    logging_level = log.DEBUG
    if config["log"]["level"] == "DEBUG":
        logging_level = log.DEBUG
    elif config["log"]["level"] == "INFO":
        logging_level = log.INFO
    elif config["log"]["level"] == "WARNING":
        logging_level = log.WARNING
    elif config["log"]["level"] == "ERROR":
        logging_level = log.ERROR
    elif config["log"]["level"] == "CRITICAL":
        logging_level = log.CRITICAL
    else:
        print("invalid log level in config: {}".format(config["log"]["level"]))

    log.basicConfig(format=config["log"]["format"], level=logging_level)

    # Find a zeroboxConnector

    zeroboxConnector = None

    try:
        zeroboxConnector = rpyc.connect("localhost", 18861)
    except ConnectionRefusedError as e:
        log.error("zeroboxConnector not available")
        sys.exit(-1)

    # Find cameras

    cameras = []
    if zeroboxConnector is not None:
        cameras = zeroboxConnector.root.detect_cameras()
        log.info("found {} camera(s)".format(len(cameras)))

    # Find UsbDirectController

    usbController = UsbDirectController.find_all()
    log.info("found {} usbController".format(len(usbController)))

    # setup the Scheduler

    scheduler = Scheduler()
    scheduler.add_job("update_status", 500)
    scheduler.add_job("force_update_status", 2000)

    clock = None
    try:
        clock = RTC()
        log.info("clock found")
    except Exception as e:
        log.warn("no clock found")

    data                            = {}
    data["cameras"]                 = {}
    data["message"]                 = "..."
    data["total_space"]             = None
    data["free_space"]              = None
    data["last_image_brightness"]   = None

    if zeroboxConnector is not None:
        data["total_space"] = zeroboxConnector.root.get_total_space()
        data["free_space"] = zeroboxConnector.root.get_free_space()


    # data["cam_0"]                           = {}
    # data["cam_1"]                           = {}

    # data["cam_0"]["active"]                 = True
    # data["cam_0"]["shutter"]                = "1.0"
    # data["cam_0"]["aperture"]               = 11
    # data["cam_0"]["iso"]                    = 300
    # data["cam_0"]["exposurecompensation"]   = 1

    # data["cam_1"]["active"]                 = True
    # data["cam_1"]["shutter"]                = "1/300"
    # data["cam_1"]["aperture"]               = 5.6
    # data["cam_1"]["iso"]                    = 300
    # data["cam_1"]["exposurecompensation"]   = 1

    while True:

        triggered_jobs = scheduler.run_schedule()
        # for job in triggered_jobs:
        #     print(job)

        if "update_status" in triggered_jobs:
            invalidate()


        if state == STATE_INIT:
            print("init")
            invalidate()
            state = STATE_LOGO


        elif state == STATE_LOGO:
            if isInvalid:

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
                if zeroboxConnector is not None:
                    screen["total_space"] = data["total_space"]
                    screen["free_space"] = data["free_space"]

                with canvas(device) as draw:
                    draw_logo(draw, screen)

                validate()

            k = getKeyEvents()
            if "3" in k:
                state = STATE_MENU


        elif state == STATE_MENU:

            if "force_update_status" in triggered_jobs:
                if zeroboxConnector is not None:
                    cameras = zeroboxConnector.root.detect_cameras()
                    data["message"] = "cam: {} | controller: {}".format(len(cameras), len(usbController)) 

            if isInvalid:

                menu = {}

                menu["message"] = data["message"]

                menu["temperature"] = None
                menu["temperature_cpu"] = None
                if clock is not None:
                    menu["temperature"] = clock.read_temperature()
                if platform == PLATFORM_PI:
                    temp_str = str(subprocess.check_output(["vcgencmd", "measure_temp"]))
                    menu["temperature_cpu"] = float(temp_str[temp_str.index("=")+1:temp_str.index("'")])

                menu["total_space"] = data["total_space"]
                menu["free_space"] = data["free_space"]

                menu["images_in_memory"] = None
                if zeroboxConnector is not None:
                    menu["images_in_memory"] = len(zeroboxConnector.root.get_images_in_memory())

                with canvas(device) as draw:
                    draw_menu(draw, config, menu, menu_selected)
                validate()

                # device.hide()
                # device.show()

            k = getKeyEvents()
            if "l" in k:
                menu_selected = (menu_selected - 1) % 3
                invalidate()
            if "r" in k:
                menu_selected = (menu_selected + 1) % 3
                invalidate()
            if "3" in k:
                if menu_selected == 0:
                    state = STATE_CONFIG
                elif menu_selected == 1:
                    state = STATE_PRE_RUN
                elif menu_selected == 2:
                    state = STATE_SHUTDOWN
                else:
                    raise Exception("illegal menu selected state: {}".format(menu_selected))

                menu_selected = 0
                invalidate()


        elif state == STATE_CONFIG:
            # draw_dialog(draw, "abort capture?", ["no", "yes"])

            # menu = menu_fix + ["-"] + _configToList(config)
            menu = _configToList(config)
            menu.append("-")
            menu.append("camera on")
            menu.append("camera off")

            if isInvalid:
                with canvas(device) as draw:
                    draw_config(draw, menu, menu_selected)
                validate()

            k = getKeyEvents()
            if "u" in k:
                menu_selected = (menu_selected - 1) % len(menu)
                invalidate()
            if "d" in k:
                menu_selected = (menu_selected + 1) % len(menu)
                invalidate()
            if "3" in k:
                length_configitems = len(_configToList(config))
                if menu_selected < length_configitems:
                    selectedConfigItem = config[_configToList(config)[menu_selected]["name"]]
                    configItemValue = selectedConfigItem["value"]
                    configItemPos = 0
                    state = STATE_CONFIG_ITEM
                    invalidate()
                else:
                    option = menu_selected - length_configitems
                    if option == 0:
                        pass # separator
                    elif option == 1:
                        # camera on
                        for c in usbController:
                            c.turn_on(True)
                    elif option == 2:
                        # camera off
                        for c in usbController:
                            c.turn_on(False)
                    else:
                        raise Exception("illegal menu option: {}".format(option))
            if "1" in k:
                state = STATE_MENU
                menu_selected = 0
                invalidate()


        elif state == STATE_CONFIG_ITEM:
            if isInvalid:
                with canvas(device) as draw:
                    draw_configItem(draw, selectedConfigItem, configItemValue, configItemPos)
                validate()

            item = selectedConfigItem

            k = getKeyEvents()
            if "u" in k:
                configItemValue = _changeConfigItem(selectedConfigItem, configItemValue, configItemPos, 1)
                invalidate()
            if "d" in k:
                configItemValue = _changeConfigItem(selectedConfigItem, configItemValue, configItemPos, -1)
                invalidate()
            if "l" in k:
                if configItemPos > 0:
                    configItemPos -= 1
                    if item["type"] == "float":
                        if configItemPos == len(str(int(abs(configItemValue)))):
                            configItemPos -= 1
                elif item["type"] == "time":
                    if configItemPos > 0:
                        configItemPos -= 1
                        if configItemPos == 2 or configItemPos == 5:
                           configItemPos -= 1 
            if "r" in k:
                if item["type"] == "int":
                    print(configItemPos)
                    if configItemPos < len(str(int(abs(configItemValue))))-1:
                        configItemPos += 1
                if item["type"] == "float":
                    print("{0:.2f}".format(abs(configItemValue)))
                    if configItemPos < len("{0:.2f}".format(abs(configItemValue)))-1:
                        configItemPos += 1
                        if configItemPos == len(str(int(abs(configItemValue)))):
                            configItemPos += 1
                elif item["type"] == "time":
                    if configItemPos < 10:
                        configItemPos += 1
                        if configItemPos == 2 or configItemPos == 5:
                           configItemPos += 1 
            if "1" in k:
                selectedConfigItem = None
                configItemValue = None
                state = STATE_CONFIG
                invalidate()
            if "3" in k:
                selectedConfigItem["value"] = configItemValue
                selectedConfigItem = None
                configItemValue = None
                state = STATE_CONFIG
                invalidate()


        elif state == STATE_PRE_RUN:
            # if isInvalid:
            #     with canvas(device) as draw:
            #         draw_info(draw, "start")
            #     validate()

            zeroboxConnector = rpyc.connect("localhost", 18861)
            zeroboxConnector.root.load_config({})
            cameras = zeroboxConnector.root.detect_cameras()

            for portname, camera in cameras.items():
                try:
                    zeroboxConnector.root.connect(portname)
                except Exception as e:
                    print(e)

                    # TODO: go to exception state
                    # if portname not in data["cameras"]:
                    #     data["cameras"][portname] = {}

                    # data["cameras"][portname]["message"] = "conn error"

            time_start = datetime.datetime.now()
            time_end   = time_start + datetime.timedelta(seconds=(config["interval"]["value"] * config["iterations"]["value"]))

            images_taken = 0

            scheduler.add_job("trigger", config["interval"]["value"]*1000)

            state = STATE_START_RUNNING


        elif state == STATE_START_RUNNING:
            state = STATE_RUNNING


        elif state == STATE_RUNNING:
            if "update_status" in triggered_jobs or "force_update_status" in triggered_jobs:

                if zeroboxConnector is not None:
                    force = False
                    if "force_update_status" in triggered_jobs:
                        force = True
                    status = zeroboxConnector.root.get_status(force=force)
                    if len(status) > 0:
                        data = {**data, **dict(status)}
                        data["message"] = None
                else:
                    data["message"] = "connector not found"

                data["next_invocation"] = scheduler.get_next_invocation("trigger")

                invalidate()

            if "trigger" in triggered_jobs:
                if zeroboxConnector is not None:
                    try:
                        zeroboxConnector.root.trigger()
                        images_taken += 1
                    except Exception as e:
                        data["message"] = "exception"
                        print(e)
                else:
                    data["message"] = "connector not found" 

                if images_taken == config["iterations"]["value"]:
                    # we're done ...

                    scheduler.remove_job("trigger")
                    zeroboxConnector.root.disconnect_all_cameras()
                    for controller in usbController:
                        controller.turn_on(False)

                    data["message"] = "success. took {} images in {}".format(images_taken, _timeToStr((time_end-time_start).seconds, short=True))

                    time_start = None
                    time_end = None
                    images_taken = 0

                    state = STATE_IDLE

                invalidate()

            if invalidate:
                with canvas(device) as draw:
                    data["images_taken"] = images_taken
                    draw_running(draw, config, data)
                validate()
            
            k = getKeyEvents()
            if "1" in k or "2" in k or "3" in k:
                state = STATE_RUNNING_MENU
                invalidate()


        elif state == STATE_RUNNING_MENU:

            menu = ["back", "stop"]

            if isInvalid:
                with canvas(device) as draw:
                    draw_running_menu(draw, menu, menu_selected)
                validate()

            k = getKeyEvents()
            if "u" in k:
                menu_selected = (menu_selected - 1) % len(menu)
                invalidate()
            if "d" in k:
                menu_selected = (menu_selected + 1) % len(menu)
                invalidate()
            if "1" in k:
                menu_selected = 0
                state = STATE_RUNNING
                invalidate()
            if "3" in k:
                if menu_selected == 0:
                    menu_selected = 0
                    state = STATE_RUNNING

                elif menu_selected == 1:
                    scheduler.remove_job("trigger")
                    zeroboxConnector.root.disconnect_all_cameras()
                    for controller in usbController:
                        controller.turn_on(False)

                    report = "Abort. Took {} images in {}".format(images_taken, _timeToStr((time_end-time_start).seconds, short=True))
                    data["message"] = report

                    time_start = None
                    time_end = None
                    images_taken = 0

                    state = STATE_IDLE
                    # display report
                    # took 123 photos in 1h23min 

                else:
                    raise Exception("illegal menu selected state: {}".format(menu_selected))

                invalidate()


        elif state == STATE_IDLE:

            with canvas(device) as draw:
                draw_info(draw, data["message"])

            k = getKeyEvents()
            if "3" in k:
                data["message"] = None
                state = STATE_MENU
                invalidate()


        elif state == STATE_SHUTDOWN:
            with canvas(device) as draw:
                draw_info(draw, "shutdown ...")
            time.sleep(1.0)
            subprocess.run(["sudo", "shutdown", "now"])


        else:
            raise Exception("illegal state: {}".format(state))

                
        time.sleep(0.1)

        checkAndRestartOnFileChange()
