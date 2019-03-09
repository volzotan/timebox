import logging
import os
import sys
import subprocess
import datetime
import math
import numpy as np

import gphoto2 as gp

import gi
gi.require_version('GExiv2', '0.10')
from gi.repository import GExiv2

# --- --- --- --- --- --- --- --- --- ---

# DEBUG               = True

# LOG_BASE_DIR        = "./"
# LOG_FILENAME_DEBUG  = "debug.log"
# LOG_FILENAME_INFO   = "info.log"
# # LOG_LEVEL_CONSOLE   = logging.DEBUG 

# RAW_DIR             = None # platform dependent
# FILE_EXTENSION      = ".arw"

# SERIAL_PORT         = "/dev/ttyAMA0"
# SERIAL_BAUDRATE     = 9600
# SERIAL_TIMEOUT      = 1 # in sec

# REPEAT_MODE         = False
# REPEAT_INTERVAL     = 20
# REPERAT_ITERATIONS  = 120

# AUTOFOCUS_ENABLED   = False
# DOUBLEEXPOSURE_ENABLED = True
# WAIT_EXPOSURE_COMP  = 0
# WAIT_AUTOFOCUS      = 1

# EXPOSURE_THRESHOLD  = 20 # 10
# FREE_DISK_THRESHOLD = 100 * 1024 * 1024

# EXPOSURE_LOW        = -5
# EXPOSURE_NORMAL     = +1

# EXIF_DATE_FORMAT    = '%Y:%m:%d %H:%M:%S'

# --- --- --- --- --- --- --- --- --- ---

CONFIG = {
    "LOG_BASE_DIR"              : "./",
    "LOG_FILENAME_DEBUG"        : "debug.log",
    "LOG_FILENAME_INFO"         : "info.log",
    "LOG_LEVEL_CONSOLE"         : logging.DEBUG,

    "BASE_DIR"                  : None,
    "TEMP_DIR"                  : "tmp",
    "IMAGE_DIR"                 : "RAW",
    "FILE_EXTENSION"            : ".arw",

    "AUTOFOCUS_ENABLED"         : False,
    "AUTOFOCUS_DURATION"        : 2,

    "DOUBLEEXPOSURE_ENABLED"    : True,
    "DOUBLEEXPOSURE_THRESHOLD"  : 20, # 10
    "EXPOSURE_1"                : +1,
    "EXPOSURE_2"                : -5,

}

EXIF_DATE_FORMAT                = '%Y:%m:%d %H:%M:%S'

# --- --- --- --- --- --- --- --- --- ---

class CameraConnector(object):

    def __init__(self, port, image_base_directory):
        self.port = port

        self.image_base_directory = image_base_directory
        self.image_directory = None

        self.status = {}


    def open(self):
        self.context = gp.gp_context_new()

        error, camera = gp.gp_camera_new()
        gp.check_result(error)

        if self.port is not None:
            error = gp.gp_camera_set_port_info(camera, self.port)
            gp.check_result(error)

        error = gp.gp_camera_init(camera, self.context)  
        gp.check_result(error)

        self.camera = camera

        # create image (sub-)directory
        self.image_directory = os.path.join(self.image_base_directory, "cam_" + self.get_serialnumber())
        try:
            os.makedirs(self.image_directory)
        except FileExistsError as e:
            pass


    def close(self):
        gp.check_result(gp.gp_camera_exit(self.camera))


    def set_autofocus(self, enabled):

        value = "Manual"
        if enabled:
            value = "Automatic"

        error, config = gp.gp_camera_get_config(self.camera)
        gp.check_result(error)

        self._set_config_value(config, "focusmode", value)


    def run_autofocus(self, active):

        value = 0
        if active:
            value = 1

        error, config = gp.gp_camera_get_config(self.camera)
        gp.check_result(error)

        self._set_config_value(self.camera, config, "autofocus", value)


    def set_exposure_compensation(self, compensation):

        error, config = gp.gp_camera_get_config(self.camera)
        gp.check_result(error)

        self._set_config_value(config, "exposurecompensation", str(compensation))


    def get_exposure_status(self):

        status = {}

        error, config = gp.gp_camera_get_config(self.camera)
        gp.check_result(error)

        # error, config_list = gp.gp_camera_list_config(self.camera, self.context)
        # gp.check_result(error)

        status["autofocus"]             = self._get_config_value(config, "autofocus")
        status["focusmode"]             = self._get_config_value(config, "focusmode")
        status["expprogram"]            = self._get_config_value(config, "expprogram")
        status["exposuremetermode"]     = self._get_config_value(config, "exposuremetermode")
        status["exposurecompensation"]  = self._get_config_value(config, "exposurecompensation")
        status["shutterspeed"]          = self._get_config_value(config, "shutterspeed")
        status["aperture"]              = self._get_config_value(config, "f-number")
        status["iso"]                   = self._get_config_value(config, "iso")

        return status


    def get_serialnumber(self):
        error, config = gp.gp_camera_get_config(self.camera)
        gp.check_result(error)

        return self._get_config_value(config, "serialnumber")


    def get_image_directory(self):
        return self.image_directory


    def capture_and_download(self, filename):
        
        error, file_path = gp.gp_camera_capture(self.camera, gp.GP_CAPTURE_IMAGE)
        gp.check_result(error)

        # print('Camera file path: {0}/{1}'.format(file_path.folder, file_path.name))

        error, camera_file = gp.gp_camera_file_get(self.camera, file_path.folder, file_path.name, gp.GP_FILE_TYPE_NORMAL)
        gp.check_result(error)

        error = gp.gp_file_save(camera_file, os.path.join(*filename))
        gp.check_result(error)


    def _get_config_value(self, config, name):

        error, conf_result = gp.gp_widget_get_child_by_name(config, name)
        gp.check_result(error)

        error, result = gp.gp_widget_get_value(conf_result)
        gp.check_result(error)

        return result


    def _set_config_value(self, config, name, value):

        error, window = gp.gp_widget_get_child_by_name(config, name)
        gp.check_result(error)

        error = gp.gp_widget_set_value(window, value)
        gp.check_result(error)

        error = gp.gp_camera_set_config(self.camera, config)
        gp.check_result(error)


    def list_config(self):

        error, config = gp.gp_camera_get_config(self, camera)
        gp.check_result(error)

        error, config_list = gp.gp_camera_list_config(self, camera, context)
        gp.check_result(error)

        for item in config_list:
            try:
                print("{0:25s} | {1}".format(item[0], _get_config_value(config, str(item[0]))))

            except gp.GPhoto2Error as e:
                print(e)

            # error, config = gp.gp_camera_get_config(camera, context)
            # gp.check_result(error)


    @staticmethod
    def _print_abilities(abilities):      
        print('model:', abilities.model)
        print('status:', abilities.status)
        print('port:', abilities.port)
        print('speed:', abilities.speed)
        print('operations:', abilities.operations)
        print('file_operations:', abilities.file_operations)
        print('folder_operations:', abilities.folder_operations)
        print('usb_vendor:', abilities.usb_vendor)
        print('usb_product:', abilities.usb_product)
        print('usb_class:', abilities.usb_class)
        print('usb_subclass:', abilities.usb_subclass)
        print('usb_protocol:', abilities.usb_protocol)
        print('library:', abilities.library)
        print('id:', abilities.id)
        print('device_type:', abilities.device_type)


class Zerobox(object):

    def __init__(self):
        self.config = CONFIG

        self.status = {}

        self.cameras = {}
        self.connectors = {}

        # expand directories

        if os.uname().nodename == "raspberrypi":
            self.config["BASE_DIR"] = "/home/pi/zerobox/"        
        else:
            self.config["BASE_DIR"] = "./"

        if self.config["IMAGE_DIR"] is None:
            self.config["IMAGE_DIR"] = self.config["BASE_DIR"]
        elif not self.config["IMAGE_DIR"].startswith("/"):
            self.config["IMAGE_DIR"] = os.path.join(self.config["BASE_DIR"], self.config["IMAGE_DIR"])

        if self.config["TEMP_DIR"] is None:
            self.config["TEMP_DIR"] = self.config["BASE_DIR"]
        elif not self.config["TEMP_DIR"].startswith("/"):
            self.config["TEMP_DIR"] = os.path.join(self.config["BASE_DIR"], self.config["TEMP_DIR"])

        # create directories
        try:
            os.makedirs(self.config["IMAGE_DIR"])
            os.makedirs(self.config["TEMP_DIR"])
        except FileExistsError as e:
            pass

        self.init_log()


    def close(self):
        for portname, connector in self.connectors.items():
            connector.close()

            if portname not in self.status:
                self.status[portname] = {}
            self.status[portname]["port"] = portname
            self.status[portname]["active"] = False 


    def disconnect_camera(self, portname):
        self.connectors[portname].close()
        self.status[portname]["active"] = False 


    def load_config(self, config):
        self.config = {**self.config, **config}


    def init_log(self):
        if not os.path.exists(self.config["LOG_BASE_DIR"]):
            print("LOG DIR missing. create...")
            os.makedirs(self.config["LOG_BASE_DIR"])

        log_filename_debug = os.path.join(self.config["LOG_BASE_DIR"], self.config["LOG_FILENAME_DEBUG"])
        log_filename_info = os.path.join(self.config["LOG_BASE_DIR"], self.config["LOG_FILENAME_INFO"])

        # create logger
        self.log = logging.getLogger()
        self.log.setLevel(logging.DEBUG)

        # create formatter
        formatter = logging.Formatter('%(asctime)s | %(levelname)-7s | %(message)s')

        # console handler and set level to debug
        consoleHandler = logging.StreamHandler()
        consoleHandler.setLevel(self.config["LOG_LEVEL_CONSOLE"])
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


    def print_config(self):

        FORMAT = "  {:<24}: {}"

        self.log.debug(" ")
        self.log.debug("CONFIGURATION:")

        for key, value in self.config.items():
            self.log.debug(FORMAT.format(key, self.config[key]))

        self.log.debug(" ")


    def get_free_space(self):
        return 0 # TODO


    def _lookup_port(self, port_list, port_address):
        for port in port_list:
            if port.get_path() == port_address:
                return port

        return None


    def _acquire_filename(self, path):
        filename = None

        for i in range(0, 9999):
            name = i
            name = str(name).zfill(4)
            testname = name + self.config["FILE_EXTENSION"]
            if not os.path.exists(os.path.join(path, testname)):
                filename = testname
                break

        self.log.debug("acquired filename: {}".format(filename))

        return (path, filename)


    def _convert_raw_to_jpeg(self, rawfile_path, rawfile_name, jpeg_path):
        # well, actually we just extract the thumbnail JPEG of the RAW
        # dcraw does not support export as JPEG and output as TIFF
        # and conversion to JPEG is unnecessary work

        # TODO: overwrite/remove jpeg image?

        rawfile_full_name   = os.path.join(rawfile_path, rawfile_name)
        thumb               = rawfile_name[:-4] + ".thumb" + ".jpg"
        thumb_full_name     = os.path.join(rawfile_path, thumb)
        jpeg_full_name      = os.path.join(jpeg_path, rawfile_name[:-4] + ".jpg")

        subprocess.call(["dcraw", "-e", format(rawfile_full_name)])     
        os.rename(thumb_full_name, jpeg_full_name)

        return jpeg_full_name


    def _calculate_brightness(self, full_name):

        metadata = GExiv2.Metadata()
        metadata.open_path(full_name)

        exposure_time = metadata.get_exposure_time()
        shutter = None
        # some versions of GExiv2 return Fractions of different types
        try: 
            shutter = float(exposure_time.den) / float(exposure_time.nom)
        except AttributeError as e:
            try: 
                shutter = float(exposure_time)
            except Exception as e:
                raise e

        iso = int(metadata.get_tag_string("Exif.Photo.ISOSpeedRatings"))

        try: 
            time = datetime.datetime.strptime(metadata.get_tag_string("Exif.Photo.DateTimeOriginal"), EXIF_DATE_FORMAT)
        except Exception as e:
            time = datetime.datetime.strptime(metadata.get_tag_string("Exif.Image.DateTime"), EXIF_DATE_FORMAT)

        aperture = metadata.get_focal_length()
        if aperture <= 0:
            # no aperture tag set, probably an lens adapter was used. assume fixed aperture.
            aperture = 8.0

        return self._intensity(shutter, aperture, iso)


    def _intensity(self, shutter, aperture, iso):

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


    def detect_cameras(self):

        # use Python logging
        # logging.basicConfig(format='%(levelname)s: %(name)s: %(message)s', level=logging.WARNING)
        # gp.check_result(gp.use_python_logging())

        self.context = gp.gp_context_new()

        error, self.port_info_list = gp.gp_port_info_list_new()
        gp.check_result(error)

        error = gp.gp_port_info_list_load(self.port_info_list)
        gp.check_result(error)

        error, abilities_list = gp.gp_abilities_list_new()
        gp.check_result(error)

        error = gp.gp_abilities_list_load(abilities_list)
        gp.check_result(error)

        error, cameras = gp.gp_abilities_list_detect(abilities_list, self.port_info_list)
        gp.check_result(error)

        if len(cameras) == 0:
            return []

        if len(cameras) == 1:
            print("1 camera connected")
        else:
            print("{} cameras connected".format(len(cameras)))

        for camera in cameras:
            portname = camera[1]
            print("{} | {}".format(camera[0], portname))
            self.cameras[camera[1]] = camera 
            if portname not in self.status:
                self.status[portname] = {}
            self.status[portname]["port"] = portname
            self.status[portname]["active"] = False 


    def connect_camera(self, camera):
        port = self._lookup_port(self.port_info_list, camera)
        conn = CameraConnector(port, self.config["IMAGE_DIR"])
        conn.open()
        self.connectors[portname] = conn

        if portname not in self.status:
            self.status[portname] = {}
        self.status[portname]["active"] = True
        self.status[portname] = {**self.status[portname], **conn.get_exposure_status()}


    def focus_camera(self, portname):
        conn = self.connectors[portname]
        conn.set_autofocus(True)
        conn.run_autofocus(True)
        time.sleep(self.config["AUTOFOCUS_DURATION"])
        conn.run_autofocus(False)
        conn.set_autofocus(False)


    def trigger_camera(self, portname):
        conn = self.connectors[portname]

        if self.config["AUTOFOCUS_ENABLED"]:
            self.focus_camera

        filename = self._acquire_filename(conn.get_image_directory())

        if not self.config["DOUBLEEXPOSURE_ENABLED"]:
            conn.capture_and_download(filename)
        else:
            conn.set_exposure_compensation(self.config["EXPOSURE_1"])
            conn.capture_and_download(filename)

            trigger_second_exposure = True
            if self.config["DOUBLEEXPOSURE_THRESHOLD"] is not None:
                jpeg_full_name = self._convert_raw_to_jpeg(filename[0], filename[1], self.config["TEMP_DIR"])
                exposure = self._calculate_brightness(jpeg_full_name)
                self.log.info("exposure: {}".format(exposure))

                if exposure > self.config["DOUBLEEXPOSURE_THRESHOLD"]:
                    trigger_second_exposure = False

            if trigger_second_exposure:
                conn.set_exposure_compensation(self.config["EXPOSURE_2"])
                filename2 = (filename[0], filename[1] + "_2")
                conn.capture_and_download(filename2)


    def get_status(self, force_connection=False):
        data = {**self.status}

        if force_connection:
            for portname, connector in self.connectors.items():
                s = connector.get_exposure_status()
                data[portname] = s

        return data


if __name__ == "__main__":
    z = Zerobox()
    print(z.get_status())
    z.print_config()
    z.detect_cameras()

    for portname, camera in z.cameras.items():
        z.connect_camera(camera)
        z.trigger_camera(portname)

    print(z.get_status())
    z.close()

        
        
