from luma.core.interface.serial import i2c, spi
from luma.core.render import canvas
from luma.oled.device import sh1106

# from luma.emulator.device import pygame, capture

import time
from PIL import ImageFont, Image
import PIL.ImageOps  

import datetime

# serial = spi()
# device = sh1106(serial)

COLOR0 = "black"
COLOR1 = "white"

# device = pygame(width=128, height=64, mode="1", scale=1)
device = sh1106(spi())
# device = capture(width=128, height=64, mode="1")

font = ImageFont.truetype("slkscr.ttf", 8)
font2 = ImageFont.truetype("slkscr.ttf", 16)

def _aperture_to_str(value):
    e = 0.1

    aperture_values = [ "1.0", "1.2", "1.4", "2", 
                        "2.8", "4", "5.6", "8", 
                        "11", "16", "22", "32"]

    for a in aperture_values:
        if abs(value - float(a)) < e:
            return "F{}".format(a)

    return "F{0:.1f}".format(value)


def drawRunScreen(canvas, data):

    # CAM SELECTOR

    if data["cam_0"]["active"]:
        draw.rectangle([(1, 1), (1+29, 1+7)], fill=COLOR1)
        draw.text((1, -1), "CAM 1", font=font, fill=COLOR0)
    else:
        draw.rectangle([(1, 1), (1+29, 1+7)], fill=COLOR0)
        draw.text((1, -1), "CAM 1", font=font, fill=COLOR1)

    if data["cam_1"]["active"]:
        draw.rectangle([(1, 8), (1+29, 8+7)], fill=COLOR1)
        draw.text((1, -1+8), "CAM 2", font=font, fill=COLOR0)
    else:
        draw.rectangle([(1, 8), (1+29, 8+7)], fill=COLOR0)
        draw.text((1, -1+8), "CAM 2", font=font, fill=COLOR1)

    draw.rectangle([(0, 17), (127, 17)], outline=None, fill=COLOR1)
    draw.rectangle([(32, 0), (32, 17)], outline=None, fill=COLOR1)

    draw.text((35,  -1), "1/1250", font=font, fill=COLOR1)
    draw.text((71,  -1), _aperture_to_str(data["cam_0"]["aperture"]), font=font, fill=COLOR1)
    draw.text((95,  -1), str(data["cam_0"]["iso"]), font=font, fill=COLOR1)
    draw.text((116, -1), "+8", font=font, fill=COLOR1)

    draw.text((35,   7), "1/1250", font=font, fill=COLOR1)
    draw.text((71,   7), _aperture_to_str(data["cam_1"]["aperture"]), font=font, fill=COLOR1)
    draw.text((95,   7), "300", font=font, fill=COLOR1)
    draw.text((116,  7), "+8", font=font, fill=COLOR1)

    # 2ND EX

    draw.text((1, 18), "2.EX", font=font, fill=COLOR1)
    draw.rectangle([(39, 20), (39+5, 20+5)], outline=None, fill=COLOR1)
    draw.text((1, 18+8), "T:", font=font, fill=COLOR1)
    draw.text((25, 18+8), "10.5", font=font, fill=COLOR1)
    draw.text((1, 18+16), "101", font=font, fill=COLOR1)
    draw.text((20, 18+16), "/", font=font, fill=COLOR1)
    draw.text((29, 18+16), "156", font=font, fill=COLOR1)

    draw.rectangle([(47, 18), (47, 45)], outline=None, fill=COLOR1)
    draw.rectangle([(0, 45), (127, 45)], outline=None, fill=COLOR1)

    # INTERVAL

    draw.text((45+5, 18), "INTVAL", font=font, fill=COLOR1)

    draw.text((127-10-26, 18), "00", font=font, fill=COLOR1)
    draw.text((127-10-15, 18), ":", font=font, fill=COLOR1)
    draw.text((127-10-13, 18), "00", font=font, fill=COLOR1)
    draw.text((127-10-2,  18), ":", font=font, fill=COLOR1)
    draw.text((127-10,    18), "00", font=font, fill=COLOR1)

    draw.text((45+5, 26), "90SEC", font=font, fill=COLOR1)

    draw.text((127-10-26, 26), "00", font=font, fill=COLOR1)
    draw.text((127-10-15, 26), ":", font=font, fill=COLOR1)
    draw.text((127-10-13, 26), "00", font=font, fill=COLOR1)
    draw.text((127-10-2,  26), ":", font=font, fill=COLOR1)
    draw.text((127-10,    26), "00", font=font, fill=COLOR1)

    draw.text((45+5, 34), "FR.SPC", font=font, fill=COLOR1)
    draw.text((90, 34), "{0:2.2f}GB".format(12.345), font=font, fill=COLOR1)


    # draw.rectangle([(64, 0), (127, 8)], fill=COLOR0)
    # draw.text((90, -1), "{0:2.2f}GB".format(12.345), font=font, fill=COLOR1)

    # draw.rectangle([(0, 10), (127, 10)], fill=COLOR1)
    # draw.rectangle([(38, 0), (38, 10)], fill=COLOR1)
    # draw.rectangle([(38+38, 0), (38, 10)], fill=COLOR1)

    # PROGRESS BAR

    draw.text((1, 60-8-2), "{0:3d}/{1:3d}".format(156, 209), font=font, fill=COLOR1)
    draw.text((106, 60-8-2), "{0:2d}%".format(43), font=font, fill=COLOR1)
    draw.text((55, 60-8-2), "00:37", font=font, fill=COLOR1)
    draw.rectangle([(0, 60), (127, 63)], fill=COLOR1)
    draw.rectangle([(1, 61), (127-1-70, 63-1)], fill=COLOR0)

    # ERROR BAR
    # draw.line([(0, 55), (128, 55)], fill=COLOR1)
    # draw.text((1, 55), "ERROR FOO", font=font, fill=COLOR1)


def draw_dialog(canvas, msg, options):

    draw.rectangle([(0, 0), (127, 64)], outline=None, fill=COLOR1)
    draw.rectangle([(1, 1), (127-1, 64-2)], outline=None, fill=COLOR0)

    draw.text((10, 10), msg, font=font, fill=COLOR1)
    draw.text((10, 30), options[0], font=font, fill=COLOR1)
    draw.text((70, 30), options[1], font=font, fill=COLOR1)


def draw_logo(canvas, data):
    draw.rectangle([(0, 0), (127, 64)], outline=None, fill=COLOR1)
    draw.bitmap((0,0), data["logo"])

    draw.text((10, 36), "DEVICE", font=font, fill=COLOR1)
    draw.text((60, 36), data["devicename"], font=font, fill=COLOR1)
    draw.text((10, 44), "VERSION", font=font, fill=COLOR1)
    draw.text((60, 44), data["version"], font=font, fill=COLOR1)
    draw.text((10, 52), "FREE SPC", font=font, fill=COLOR1)
    draw.rectangle([(60, 55), (122, 59)], outline=None, fill=COLOR1)
    draw.rectangle([(61, 56), (int(61+60*data["free_space"]), 58)], outline=None, fill=COLOR0)

    draw.rectangle([(56, 38), (56, 59)], outline=None, fill=COLOR1)


data = {}
data["cam_0"]                           = {}
data["cam_1"]                           = {}

data["cam_0"]["active"]                 = True
data["cam_0"]["shutter"]                = "1.0"
data["cam_0"]["aperture"]               = 11
data["cam_0"]["iso"]                    = 300
data["cam_0"]["exposurecompensation"]   = 1

data["cam_1"]["active"]                 = False
data["cam_1"]["shutter"]                = "1/300"
data["cam_1"]["aperture"]               = 5.6
data["cam_1"]["iso"]                    = 300
data["cam_1"]["exposurecompensation"]   = 1

data = {}
logo = Image.open("logo.png")
logo = PIL.ImageOps.invert(logo)
logo = logo.convert("1")
data["logo"] = logo
data["devicename"] = "undefined"
now = datetime.datetime.now()
data["version"] = now.strftime("%d.%m.%y")
data["free_space"] = 0.45

state = 0

while True:
    with canvas(device) as draw:
        # draw.rectangle(device.bounding_box, outline=COLOR1, fill=COLOR0)

        # drawRunScreen(canvas, data)
        draw_logo(canvas, data)

        if state == 0:
            draw_logo(canvas, data)
            state = 1
        elif state == 1:
            draw_dialog(canvas, "abort capture?", ["no", "yes"])
        else:
            pass
            
    time.sleep(1)
