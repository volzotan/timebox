from luma.core.interface.serial import i2c, spi
from luma.emulator.device import pygame, capture

from luma.core.render import canvas
from luma.oled.device import sh1106

import time
import os
from PIL import ImageFont, Image
import PIL.ImageOps  
import yaml

import datetime
import sys
from os.path import getmtime

own_mtime = getmtime(__file__)

COLOR0 = "black"
COLOR1 = "white"

BTN_1 = 16
BTN_2 = 20
BTN_3 = 21
BTN_L = 5
BTN_R = 26
BTN_U = 6
BTN_D = 19
BTN_C = 13

device = None
pyg = None

if os.uname().nodename == "raspberrypi":
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

STATE_INIT          = 0
STATE_LOGO          = 1
STATE_MENU          = 2
STATE_CONFIG_ITEM   = 3
STATE_DIALOG        = 4
STATE_RUNNING       = 5
STATE_RUNNING_MENU  = 6
STATE_IDLE          = 100


# state

state               = STATE_INIT
isInvalid           = True

menu_selected       = 0

selectedConfigItem  = None
configItemValue     = None
configItemPos       = 0 # Pointer to change digits of a configItems value


menu_fix = [
    # "[short overview menu]",
    # "settings",
    "start",
    "shutdown"
]

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
    pass


def _apertureToStr(value):
    e = 0.1

    aperture_values = [ "1.0", "1.2", "1.4", "2", 
                        "2.8", "4", "5.6", "8", 
                        "11", "16", "22", "32"]

    for a in aperture_values:
        if abs(value - float(a)) < e:
            return "F{}".format(a)

    return "F{0:.1f}".format(value)


def _configToList(c):
    clist = []
    for key, value in c.items():
        value["name"] = key
        clist.append(value)

    return clist


def _changeConfigItem(item, value, pos, op):
    if item["type"] == "int":
        if op > 0:
            if not "max" in item or value + 1 <= item["max"]:
                value += 1
        else:
            if not "min" in item or value - 1 >= item["min"]:
                value -= 1

    elif item["type"] == "boolean":
        value = not value

    elif item["type"] == "float":
        if op > 0:
            if not "max" in item or value + .01 <= item["max"]:
                value += .01
            if not "min" in item or value - .01 <= item["min"]:
                value -= .01

    elif item["type"] == "time":
        pass

    return value


def getKeyEvents():

    keys = []

    if not pyg:
        if not GPIO.input(BTN_L):
            keys.append("l")
        if not GPIO.input(BTN_R):
            keys.append("r")
        if not GPIO.input(BTN_U):
            keys.append("u")
        if not GPIO.input(BTN_D):
            keys.append("d")
        if not GPIO.input(BTN_C):
            keys.append("c")
        if not GPIO.input(BTN_1):
            keys.append("1")
        if not GPIO.input(BTN_2):
            keys.append("2")
        if not GPIO.input(BTN_3):
            keys.append("3")
    else:
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

    if data["cam_0"]:
        if data["cam_0"]["active"]:
            draw.rectangle([(1, 1), (1+21, 1+6)], fill=COLOR1)
            text(draw, [2, 2], "CAM 1", invert=True)
        else:
            draw.rectangle([(1, 1), (1+21, 1+6)], fill=COLOR0)
            text(draw, [2, 2], "CAM 1")

    if data["cam_1"]:
        if data["cam_1"]["active"]:
            draw.rectangle([(1, 9), (1+21, 8+7)], fill=COLOR1)
            text(draw, [2, 2+8], "CAM 2", invert=True)
        else:
            draw.rectangle([(1, 8), (1+21, 8+7)], fill=COLOR0)
            text(draw, [2, 2+8], "CAM 2")

        end = 17

    draw.rectangle([(0, end), (127, end)], outline=None, fill=COLOR1)
    draw.rectangle([(24, 0), (24, end)], outline=None, fill=COLOR1)

    if data["cam_0"]:
        text(draw, [35,  2], "1/1250")
        text(draw, [71,  2], _aperture_to_str(data["cam_0"]["aperture"]))
        text(draw, [95,  2], str(data["cam_0"]["iso"]))
        text(draw, [127, 2], "+8", rightalign=True)

    if data["cam_1"]:
        text(draw, [35,   10], "1/1250")
        text(draw, [71,   10], _aperture_to_str(data["cam_1"]["aperture"]))
        text(draw, [95,   10], "300")
        text(draw, [127,  10], "+8", rightalign=True)

    # 2ND EXPOSURE

    start = end + 1

    if config["secondexposure"]["value"]:
        text(draw, [1, start+2], "2.EXP")
        draw.rectangle([(40, start+1), (40+5, start+1+5)], outline=None, fill=COLOR1)
        text(draw, [1, start+9], "T:")
        text(draw, [25, start+9], "10.5")
        text(draw, [1, start+16], "101")
        text(draw, [20, start+16], "/")
        text(draw, [29, start+16], "156")
    else: 
        text(draw, [5, start+9], "2.EXP OFF")

    draw.rectangle([(47, start), (47, start+23)], outline=None, fill=COLOR1)
    draw.rectangle([(0, start+23), (127, start+23)], outline=None, fill=COLOR1)

    # INTERVAL

    text(draw, [45+5, start+2], "INTVAL")
    text(draw, [127,  start+2], "00:00:00", rightalign=True)

    text(draw, [45+5, start+9], "90SEC")
    text(draw, [127,  start+9], "00:00:00", rightalign=True)

    text(draw, [45+5, start+16], "FR.SPC")
    text(draw, [127,  start+16], "{0:2.2f}GB".format(12.345), rightalign=True)


    # draw.rectangle([(64, 0), (127, 8)], fill=COLOR0)
    # text(draw, [90, -1], "{0:2.2f}GB".format(12.345))

    # draw.rectangle([(0, 10), (127, 10)], fill=COLOR1)
    # draw.rectangle([(38, 0), (38, 10)], fill=COLOR1)
    # draw.rectangle([(38+38, 0), (38, 10)], fill=COLOR1)

    # PROGRESS BAR

    text(draw, [1, 60-8], "{0:3d}/{1:3d}".format(156, 209))
    text(draw, [127, 60-8], "{0:2d}%".format(43), rightalign=True)
    text(draw, [55, 60-8], "00:37")
    draw.rectangle([(0, 60), (127, 63)], fill=COLOR1)
    draw.rectangle([(1, 61), (127-1-70, 63-1)], fill=COLOR0)

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
    text(draw, [10, 52], "FREE SPC")
    draw.rectangle([(60, 55), (122, 59)], outline=None, fill=COLOR1)
    draw.rectangle([(61, 56), (int(61+60*data["free_space"]), 58)], outline=None, fill=COLOR0)

    draw.rectangle([(56, 38), (56, 59)], outline=None, fill=COLOR1)


def draw_menu(draw, menu, selected_index):
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
            rect(draw, [(0, 1+7*i), (127, 7+7*i)], invert=not selected)
            text(draw, [2, 2+7*i], viewmenu[i]["name"], invert=selected)
            text(draw, [127, 2+7*i], viewmenu[i]["value"], invert=selected, rightalign=True)

        elif viewmenu[i] == "-": # separator
            rect(draw, [(0, 1+7*i), (127, 7+7*i)], invert=not selected)
            rect(draw, [(0+1, 1+7*i+3), (127-1, 1+7*i+3)], invert=selected)

        else: # command
            rect(draw, [(0, 1+7*i), (127, 7+7*i)], invert=not selected)
            text(draw, [2, 2+7*i], viewmenu[i], invert=selected)


def draw_configItem(draw, item):

    text(draw, [2, 2], item["name"])
    rect(draw, [(0, 8), (100, 8)])
    rect(draw, [(100, 0), (100, 64)])

    text(draw, [127, 20], "BACK >", rightalign=True)
    text(draw, [127, 50], "OK >", rightalign=True)

    if item["type"] == "int":
        text(draw, [50, 30], str(configItemValue))
    elif item["type"] == "boolean":
        pass
    elif item["type"] == "float":
        text(draw, [50, 30], "{0:.2f}".format(configItemValue))
    elif item["type"] == "time":
        pass
    else:
        print("unknown config item type: {}".format(item[type]))


def draw_running_menu(draw, menu, selected):
    for i in range(len(menu)):
        if i == selected:
            draw.rectangle([(0, 1+7*i), (127, 7+7*i)], outline=None, fill=COLOR1)
            text(draw, [2, 2+7*i], menu[i], invert=True)
        else:
            text(draw, [2, 2+7*i], menu[i])


if __name__ == "__main__":

    config = None
    with open("config.yaml", "r") as stream:
        try:
            config = yaml.load(stream)
        except yaml.YAMLError as exc:
            print(exc)

    data = {}
    data["cam_0"]                           = {}
    data["cam_1"]                           = {}

    data["cam_0"]["active"]                 = True
    data["cam_0"]["shutter"]                = "1.0"
    data["cam_0"]["aperture"]               = 11
    data["cam_0"]["iso"]                    = 300
    data["cam_0"]["exposurecompensation"]   = 1

    data["cam_1"]["active"]                 = True
    data["cam_1"]["shutter"]                = "1/300"
    data["cam_1"]["aperture"]               = 5.6
    data["cam_1"]["iso"]                    = 300
    data["cam_1"]["exposurecompensation"]   = 1

    logo = Image.open("logo.png")
    logo = PIL.ImageOps.invert(logo)
    logo = logo.convert("1")
    data["logo"] = logo
    data["devicename"] = "undefined"
    now = datetime.datetime.now()
    data["version"] = now.strftime("%d.%m.%y")
    data["free_space"] = 0.45

    while True:

        # k = getKeyEvents()
        # if len(k) > 0:
        #     print(*k)


        if state == STATE_INIT:
            print("init")
            state += 2 # TODO

        elif state == STATE_LOGO:
            if isInvalid:
                with canvas(device) as draw:
                    draw_logo(draw, data)
            state = STATE_MENU
            time.sleep(1.0)


        elif state == STATE_MENU:
            # draw_dialog(draw, "abort capture?", ["no", "yes"])

            menu = menu_fix + ["-"] + _configToList(config)

            if isInvalid:
                with canvas(device) as draw:
                    draw_menu(draw, menu, menu_selected)
                validate()

            k = getKeyEvents()

            # if len(k) > 0:
            #     print(*k)

            if "u" in k:
                menu_selected = (menu_selected - 1) % len(menu)
                invalidate()
            if "d" in k:
                menu_selected = (menu_selected + 1) % len(menu)
                invalidate()
            if "c" in k:
                selectedConfigItem = config[_configToList(config)[menu_selected-len(menu_fix)-1]["name"]]
                configItemValue = selectedConfigItem["value"]
                state = STATE_CONFIG_ITEM
                invalidate()


        elif state == STATE_CONFIG_ITEM:
            if isInvalid:
                with canvas(device) as draw:
                    draw_configItem(draw, selectedConfigItem)
                validate()

            item = selectedConfigItem

            k = getKeyEvents()
            if "u" in k:
                configItemValue = _changeConfigItem(selectedConfigItem, configItemValue, configItemPos, 1)
                invalidate()
            if "d" in k:
                configItemValue = _changeConfigItem(selectedConfigItem, configItemValue, configItemPos, -1)
                invalidate()
            if "1" in k:
                selectedConfigItem = None
                configItemValue = None
                state = STATE_MENU
                invalidate()
            if "3" in k:
                selectedConfigItem["value"] = configItemValue
                selectedConfigItem = None
                configItemValue = None
                state = STATE_MENU
                invalidate()


        elif state == STATE_RUNNING:
            if invalidate:
                with canvas(device) as draw:
                    draw_running(draw, config, data)
                validate()
            #state = STATE_IDLE


        elif state == STATE_RUNNING_MENU:

            menu = ["back", "pause", "stop"]

            if isInvalid:
                with canvas(device) as draw:
                    draw_running_menu(draw, menu, menu_selected)
                validate()

            k = getKeyEvents()
            if len(k) > 0:
                print(*k)
            if "u" in k:
                menu_selected = (menu_selected - 1) % len(menu)
                invalidate()
            if "d" in k:
                menu_selected = (menu_selected + 1) % len(menu)
                invalidate()

        else:
            pass
                
        #time.sleep(0.1)

        checkAndRestartOnFileChange()
