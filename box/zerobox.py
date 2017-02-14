import os
import sys
import subprocess
import time
import shutil
import datetime
import math
import numpy as np

import gi
gi.require_version('GExiv2', '0.10')
from gi.repository import GExiv2

RAW_DIR = "/Users/volzotan/zerobox"
FILE_EXTENSION = ".arw"

WAIT_EXPOSURE_COMP  = 0
WAIT_AUTOFOCUS      = 1

BRIGHTNESS_THRESHOLD = 10

EXIF_DATE_FORMAT    = '%Y:%m:%d %H:%M:%S'

# returns (path, filename)
def acquire_filename(path):
    filename = None

    for i in range(0, 9999):
        name = i
        name = str(name).zfill(4)
        testname = name + FILE_EXTENSION
        if not os.path.exists(os.path.join(path, testname)):
            filename = testname
            break

    return (path, filename)


# returns full filename of image, without path
def take_image(full_name):

    # TODO: overwrite image?

    ret_val = subprocess.call(["gphoto2" ,"--capture-image-and-download"])

    if ret_val > 0:
        raise RuntimeError("taking image failed (gphoto2 value: {})".format(ret_val))

    camera_file = "capt0000.arw"

    shutil.copyfile(camera_file, full_name)
    os.remove(camera_file)
    print("image saved to: {}".format(filename))

    return filename


def shutdown():
    print("shutdown!")
    sys.exit(0)


def check_prerequisites():
    # output folder present?
    # check disk space

    if not os.path.exists(RAW_DIR):
        print("RAW DIR missing. create...")
        os.makedirs(RAW_DIR)

    return True


def _intensity(shutter, aperture, iso):

    # limits in this calculations:
    # min shutter is 1/4000th second
    # min aperture is 22
    # min iso is 100

    shutter_repr    = math.log(shutter, 2) + 13 # offset = 13 to accomodate shutter values down to 1/4000th second
    iso_repr        = math.log(iso/100, 2) + 1  # offset = 1, iso 100 -> 1, not 0

    if aperture is not None:
        aperture_repr = np.interp(math.log(aperture, 2), [0, 4.5], [10, 1])
    else:
        aperture_repr = 1

    return shutter_repr + aperture_repr + iso_repr


def calculate_brightness(full_name):

    metadata = GExiv2.Metadata()
    metadata.open_path(full_name)

    shutter = metadata.get_exposure_time()
    shutter = float(shutter[0]) / float(shutter[1])
    iso     = int(metadata.get_tag_string("Exif.Photo.ISOSpeedRatings"))

    try: 
        time = datetime.datetime.strptime(metadata.get_tag_string("Exif.Photo.DateTimeOriginal"), EXIF_DATE_FORMAT)
    except Exception as e:
        time = datetime.datetime.strptime(metadata.get_tag_string("Exif.Image.DateTime"), EXIF_DATE_FORMAT)

    aperture = metadata.get_focal_length()
    if aperture < 0:
        # no aperture tag set, probably an lens adapter was used. assume fixed aperture.
        aperture = 8.0

    return _intensity(shutter, aperture, iso)


def convert_raw_to_jpeg(rawfile_path, rawfile_name, jpeg_path):
    # well, actually we just extract the thumbnail JPEG of the RAW
    # dcraw does not support export as JPEG and output as TIFF
    # and conversion to JPEG is unnecessary work

    rawfile_full_name   = os.path.join(rawfile_path, rawfile_name)
    thumb               = rawfile_name[:-4] + ".thumb" + ".jpg"
    thumb_full_name     = os.path.join(rawfile_path, thumb)
    jpeg_full_name      = os.path.join(jpeg_path, rawfile_name[:-4] + ".jpg")

    subprocess.call(["dcraw", "-e", format(rawfile_full_name)])     
    os.rename(thumb_full_name, jpeg_full_name)

    return jpeg_full_name


def adjust_exposure(correction_value):
 
    # gphoto2 --set-config-value /main/capturesettings/exposurecompensation=-5

    output = subprocess.check_output(["gphoto2" ,"--get-config", "/main/capturesettings/exposurecompensation"])
    output = output.decode().split("\n")
    for out in output:
        if "Current:" in out:
            current = int(out[9:])
            if current == correction_value:
                print("exposure adjustment correct")
                return

    ret_val = subprocess.call(["gphoto2" ,"--set-config-value", "/main/capturesettings/exposurecompensation="+str(correction_value)])

    if ret_val > 0:
        raise RuntimeError("adjusting exposure failed (gphoto2 value: {})".format(ret_val))

    time.sleep(WAIT_EXPOSURE_COMP)


def autofocus():

    # gphoto2 --set-config-value /main/actions/autofocus=0

    subprocess.call(["gphoto2" ,"--set-config-value", "/main/actions/autofocus="+str(0)])
    time.sleep(WAIT_AUTOFOCUS)
    subprocess.call(["gphoto2" ,"--set-config-value", "/main/actions/autofocus="+str(1)])
    time.sleep(WAIT_AUTOFOCUS*2)
    subprocess.call(["gphoto2" ,"--set-config-value", "/main/actions/autofocus="+str(0)])
    time.sleep(WAIT_AUTOFOCUS)


# ---------- ---------- ---------- ---------- ---------- ---------- #

if (__name__ == "__main__"):

    print("init.", sep="")
    if not check_prerequisites():
        shutdown()

    (path, filename) = acquire_filename(RAW_DIR)
    full_name = None

    try:
        if filename is None:
            raise RuntimeError("no filename could be acquired [{}]".format(path))

        full_name = os.path.join(path, filename)

        adjust_exposure(+1)
        take_image(full_name)
        #full_name = os.path.join(path, "0000.arw")
        #filename = "0000.arw"
    except RuntimeError as e:
        print(e)
        shutdown()

    # check exposure
    jpeg_full_name = convert_raw_to_jpeg(path, filename, "")
    brightness = calculate_brightness(jpeg_full_name)
    print(brightness)

    if brightness > BRIGHTNESS_THRESHOLD:
        adjust_exposure(-5)
        take_image(full_name+"_2")
        adjust_exposure(+1)

    print("success")
    shutdown()
