import os
import math
import exifread
import cv2

import traceback
import logging
import subprocess
import shutil

DEFAULT_APERTURE = 8.0

# Dark --- image  --- Bright
# MIN                    MAX

# min results in very dark 
# image, max in bright image

SHUTTER_SPEED_MIN   = 1/4000 #2
SHUTTER_SPEED_MAX   = 10
APERTURE_MIN        = 22
APERTURE_MAX        = 5.6
ISO_MIN             = 100
ISO_MAX             = 400

SHUTTER_SPEED_VALUES = [
    30,
    25,
    20,
    15,
    13,
    10,
    8,
    6,
    5,
    4,
    32/10,
    25/10,
    2,
    16/10,
    13/10,
    1,
    8/10,
    6/10,
    5/10,
    4/10,
    1/3,
    1/4,
    1/5,
    1/6,
    1/8,
    1/10,
    1/13,
    1/15,
    1/20,
    1/25,
    1/30,
    1/40,
    1/50,
    1/60,
    1/80,
    1/100,
    1/125,
    1/160,
    1/200,
    1/250,
    1/320,
    1/400,
    1/500,
    1/640,
    1/800,
    1/1000,
    1/1250,
    1/1600,
    1/2000,
    1/2500,
    1/3200,
    1/4000,
    1/5000,
    1/6400,
    1/8000,
    1/10000,
    1/12500,
    1/16000,
    1/20000,
    1/25000,
    1/32000,
]


class CameraConnector(object):

    MODE_MANUAL             = "M"
    MODE_APERTURE_PRIORITY  = "A"
    MODE_AUTOMATIC          = "P"
    MODE_UNKNOWN            = "?"

    STATE_INITIALIZED       = 0
    STATE_CONNECTED         = 1
    STATE_BUSY              = 2
    STATE_CLOSED            = 3
    STATE_ERROR             = 4
    STATE_UNKNOWN           = 5

    def __init__(self, port, 
        image_base_directory_primary, 
        image_base_directory_secondary):

        self.port = port
        
        self.log = logging.getLogger()
        self.log.setLevel(logging.DEBUG)

        self.image_base_directory_primary = image_base_directory_primary
        self.image_directory_primary = None

        self.image_base_directory_secondary = image_base_directory_secondary
        self.image_directory_secondary = None

        self.exposure_mode = None
        self.serialnumber = None

        self.state = self.STATE_INITIALIZED

    def open():
        pass

    def close():
        pass

    def _create_image_directory(self):
        # create image (sub-)directory

        if self.image_base_directory_primary is not None:
            self.image_directory_primary = os.path.join(
                self.image_base_directory_primary, 
                "cam_" + self.serialnumber)

            try:
                os.makedirs(self.image_directory_primary)
            except FileExistsError as e:
                pass
            except PermissionError as e:
                pass

        self.image_directory_secondary = os.path.join(
            self.image_base_directory_secondary, 
            "cam_" + self.serialnumber)

        try:
            os.makedirs(self.image_directory_secondary)
        except FileExistsError as e:
            pass        
        except PermissionError as e:
                pass

    def get_state(self):
        return self.state

    def get_image_directory(self, min_free_space):

        # if primary not available or memory lower than switching threshold, return secondary

        if self.image_directory_primary is None:
            self.log.warning("fallback to secondary image dir: primary is None")
            return self.image_directory_secondary

        if not os.path.exists(self.image_directory_primary):
            self.log.warning("fallback to secondary image dir: primary dir not available")
            return self.image_directory_secondary

        if not os.path.ismount(self.image_directory_primary):
            self.log.warning("fallback to secondary image dir: primary dir not correctly mounted")
            return self.image_directory_secondary

        free_space_primary_mb = shutil.disk_usage(self.image_directory_primary).free / (1024 * 1024)
        if free_space_primary_mb < min_free_space:
            self.log.warning("fallback to secondary image dir: free space below threshold: {:.2f}MB".format(free_space_primary_mb))
            return self.image_directory_secondary

        return self.image_directory_primary

    def set_autofocus(self, enabled):
        pass

    def run_autofocus(self, active):
        pass

    def set_exposure_compensation(self, compensation):
        pass

    def set_exposure_manual(self, shutter, aperture, iso):
        pass

    def get_exposure_status(self):
        pass

    def capture_and_download(self, filename):
        pass

    def _get_serialnumber(self):
        pass

    def _get_battery(self):
        pass

    def _get_config_value(self, config, name):
        pass

    def _set_config_value(self, config, name, value):
        pass

    def list_config(self):
        pass


class CameraConnectorCli(CameraConnector):

        # gphoto2 --auto-detect
        # gphoto2 --capture-image-and-download --port=usb:029,009
        # gphoto2 --list-cameras
        # gphoto2 --list-config

        # gphoto2 --get-config /main/capturesettings/focusmode
        # gphoto2 --get-config /main/capturesettings/exposurecompensation
        # gphoto2 --set-config-value /main/capturesettings/exposurecompensation=-5
        # gphoto2 --set-config-value /main/capturesettings/focusmode=Manual
        # gphoto2 --set-config-value /main/capturesettings/focusmode=0
        # gphoto2 --get-config /main/capturesettings/shutterspeed
        # gphoto2 --get-config /main/capturesettings/f-number
        # gphoto2 --set-config-value /main/actions/autofocus=0
        # gphoto2 --set-config-value /main/actions/autofocus=1

    def __init__(self, port, 
        image_base_directory_primary, 
        image_base_directory_secondary):

        super().__init__(port, image_base_directory_primary, image_base_directory_secondary)

    def open(self):

        self.serialnumber = self._get_serialnumber()
        self._create_image_directory()

        self.state = self.STATE_CONNECTED

    def close(self):
        self.state = self.STATE_CLOSED

    def set_autofocus(self, enabled):
        mode = "Manual"
        if enabled:
            mode = "Automatic" # TODO: right word?

        try:
            self.state = self.STATE_BUSY
            _gphoto("set-config-value", "/main/capturesettings/focusmode={}".format(mode))
        except Exception as e:
            raise e
        finally:
            self.state = self.STATE_CONNECTED

    def run_autofocus(self, active):
        mode = 0
        if active:
            mode = 1

        try:
            self.state = self.STATE_BUSY
            _gphoto("set-config-value", "/main/actions/autofocus={}".format(mode))
        except Exception as e:
            raise e
        finally:
            self.state = self.STATE_CONNECTED

    def set_exposure_compensation(self, compensation):
        try:
            self.state = self.STATE_BUSY
            self._set_config_value("/main/capturesettings/exposurecompensation", compensation)
        except Exception as e:
            raise e
        finally:
            self.state = self.STATE_CONNECTED

    def set_exposure_manual(self, shutter, aperture, iso):
        try:
            self.state = self.STATE_BUSY

            self._set_config_value("/main/capturesettings/shutterspeed", shutter)
            # TODO: set aperture
            # TODO: set iso

        except Exception as e:
            raise e
        finally:
            self.state = self.STATE_CONNECTED

    def get_exposure_status(self):
        status = {}

        # output = _gphoto("list-all-config")

        try:
            self.state = self.STATE_BUSY

            status["state"]                 = self.state

            status["focusmode"]             = self._get_config_value("focusmode")
            status["autofocus"]             = self._get_config_value("autofocus")
            status["expprogram"]            = self._get_config_value("/main/capturesettings/expprogram")
            status["exposuremetermode"]     = self._get_config_value("/main/capturesettings/exposuremetermode")
            status["exposurecompensation"]  = self._get_config_value("/main/capturesettings/exposurecompensation")
            status["shutterspeed"]          = self._get_config_value("/main/capturesettings/shutterspeed")
            status["aperture"]              = self._get_config_value("/main/capturesettings/f-number")
            status["iso"]                   = self._get_config_value("/main/imgsettings/iso")
            status["battery"]               = self._get_config_value("/main/status/batterylevel")
        except Exception as e:
            raise e
        finally:
            self.state = self.STATE_CONNECTED

        return status

    def capture_and_download(self, filename):
        try:
            self.state = self.STATE_BUSY
            _gphoto(["capture-image-and-download", "force-overwrite"])
            if not os.path.exists("capt0000.arw"):
                raise Exception("captured RAW file missing")
            shutil.move("capt0000.arw", os.path.join(*filename))
            self.log.debug("camera save done: {}".format(filename[1]))
        except Exception as e:
            raise e
        finally:
            self.state = self.STATE_CONNECTED

    def _get_serialnumber(self):

        data = ""
        try:
            self.state = self.STATE_BUSY
            data = self._get_config_value("/main/status/serialnumber")
        except Exception as e:
            raise e
        finally:
            self.state = self.STATE_CONNECTED

        return str(data)

    def _get_battery(self):
        data = ""
        
        try:
            self.state = self.STATE_BUSY
            data = self._get_config_value("/main/status/batterylevel")
        except Exception as e:
            raise e
        finally:
            self.state = self.STATE_CONNECTED

        return str(data)

    def _get_config_value(self, name):
        output = _gphoto("get-config", name)
        data = output[3]

        if data.startswith("Current: "):
            data = data[len("Current: "):]
        else:
            raise Exception("unknown reponse")

        return data

    def _set_config_value(self, name, value):
        _gphoto("set-config-value", "{}={}".format(name, value))


def _gphoto(cmd, *args): #, **kwargs):
    try:
        arguments = ["gphoto2"]

        if type(cmd) is list:
            for c in cmd:
                arguments.append("--{}".format(c))
        else:
            arguments.append("--{}".format(cmd))

        for arg in args:
            arguments.append(arg)

        print(arguments)

        output = subprocess.check_output(arguments)
        output = output.decode("UTF-8")
        output = output.split("\n")
        return output
    except Exception as e:
        raise e

# ---------------------------------------------------------------------------

def _compute_ev(shutter_speed, aperture, iso):

    return math.log(aperture / shutter_speed, 2) - math.log(iso/100, 2)


def _compute_new_settings(shutter_speed, aperture, iso, ev_diff):

    # shutter_new = shutter_speed * (1/(2**diff))

    shutter_speed_new   = shutter_speed * (2**ev_diff)
    aperture_new        = aperture
    iso_new             = iso

    diff_shutter = 0
    diff_aperture = 0

    # if shutter_speed_new < SHUTTER_SPEED_MIN:
    #     diff_shutter = math.log(SHUTTER_SPEED_MIN-shutter_speed_new, 2) - 1

    #     print("overflow ev shutter: {}".format(diff_shutter))

    #     shutter_speed_new = SHUTTER_SPEED_MIN

    # elif shutter_speed_new > SHUTTER_SPEED_MAX:
    #     diff_shutter = math.log(shutter_speed_new-SHUTTER_SPEED_MAX, 2) - 1

    #     print("underflow ev shutter: {}".format(diff_shutter))

    #     diff_shutter = SHUTTER_SPEED_MAX

    # if diff_shutter != 0:
    #     aperture_new = aperture * (2 ** - (diff_shutter))

    # if aperture_new > APERTURE_MIN:
    #     diff_aperture = math.log(aperture_new-APERTURE_MAX, 2) - 1
    # elif aperture_new < APERTURE_MAX:
    #     pass


    print("shutter  current: {:6.2f} | shutter  new: {:6.2f}".format(shutter_speed, shutter_speed_new))
    print("aperture current: {:6.2f} | aperture new: {:6.2f}".format(aperture, aperture_new))
    print("iso      current: {:6.2f} | shutter  new: {:6.2f}".format(iso, iso_new))
    print("ev new          : {:5.2f}".format(_compute_ev(shutter_speed_new, aperture_new, iso_new)))

    return (shutter_speed_new, aperture_new, iso_new)


def compute_ae(full_name):

    with open(full_name, "rb") as image_file:
        metadata = exifread.process_file(image_file)

        # shutter speed in seconds (e.g. 0.5)

        shutter_speed_val = metadata["EXIF ExposureTime"].values[0]
        if shutter_speed_val.num == 0 or shutter_speed_val.den == 0:
            shutter_speed = 0
        else:
            shutter_speed = float(shutter_speed_val.num) / float(shutter_speed_val.den)

        # ISO (e.g. 100)

        iso = float(metadata["EXIF ISOSpeedRatings"].values[0])

        # Aperture (e.g. 5.6)

        aperture_val = metadata["EXIF FNumber"].values[0]

        if aperture_val.num == 0 or aperture_val.den == 0:
            aperture = 0
        else:
            aperture = aperture_val.num / aperture_val.den

        if aperture <= 0:
            # no aperture tag set, probably an lens adapter was used. assume fixed aperture.
            aperture = DEFAULT_APERTURE

        ev = _compute_ev(shutter_speed, aperture, iso)

        # print("brightness:: shutter: {:10} | aperture: {:3} | iso: {:4.0f} | EV: {:5.3f}".format(shutter_speed, aperture, iso, ev))
        # print("{} | ev: {:2.3f}".format(image[1], ev))
        
        # img = cv2.imread(full_name, cv2.IMREAD_ANYCOLOR)
        # gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

        # just load/convert the image to grayscale, opencv will already use the YUV model
        # and apply YUV color channel coefficients, so no additional luminance calculation
        # necessary

        img = cv2.imread(full_name, cv2.IMREAD_GRAYSCALE)

        # crop

        h, w = img.shape
        cropsize = 900
        img_cropped = img[int(h/2-cropsize/2):int(h/2+cropsize/2), int(w/2-cropsize/2):int(w/2+cropsize/2)]

        mean = img_cropped.mean()

        # print("mean: {:6.3f} | {:5.2f}%".format(mean, mean/2.56))

        ev_opt = ev + math.log(mean, 2) - math.log(128)
        diff = ev-ev_opt
        print("ev measured: {:5.2f} | ev correct: {:5.2f} | diff: {:5.2f}".format(ev, ev_opt, diff))

        return _compute_new_settings(shutter_speed, aperture, iso, diff)

conn = CameraConnectorCli(None, "captures_1", "captures_2")

try:
    for i in range(0, 10):
        filename1 =["captures_1", "{:03}.arw".format(i)]
        filename1_thumb =["captures_1", "{:03}.thumb.jpg".format(i)]
        conn.capture_and_download(filename1)
        subprocess.run(["dcraw", "-e", os.path.join(*filename1)])

        shutter, aperture, iso = compute_ae(os.path.join(*filename1_thumb))

        conn.set_exposure_manual(shutter, aperture, iso)
except Exception as e:
    traceback.print_exc()

finally:
    if conn is not None:
        conn.close()
