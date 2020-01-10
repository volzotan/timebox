import logging
import os
import sys
import subprocess
import datetime
import time
import math
from threading import Lock
import shutil

import exifread

# import numpy as np
# import gphoto2 as gp

# --- --- --- --- --- --- --- --- --- ---

CONFIG = {

    "BASE_DIR"                  : None, # only used when path is relative (ie. starts without /)
    "IMAGE_DIR_PRIMARY"         : "/media/usb/RAW",
    "IMAGE_DIR_SECONDARY"       : "RAW",
    "TEMP_DIR"                  : "tmp",
    "FILE_EXTENSION"            : ".arw",
    "MIN_FREE_SPACE"            : 300, # MB

    # "SERIAL_PORT"               : "/dev/ttyAMA0",
    # "SERIAL_BAUDRATE"           : 9600,
    # "SERIAL_TIMEOUT"            : 1, # in sec

    "COMMANDLINE_MODE"          : True,

    "AUTOFOCUS_ENABLED"         : True,
    "AUTOFOCUS_DURATION"        : 2,

    "SECONDEXPOSURE_ENABLED"    : True,
    "SECONDEXPOSURE_THRESHOLD"  : 10,
    "EXPOSURE_1"                : +1,
    "EXPOSURE_2"                : -5,

}

EXIF_DATE_FORMAT                = '%Y:%m:%d %H:%M:%S'
DEBUG                           = True

# default aperture which is assumed for brightness calculation if a manual lens is used 
# (important for calculating if the exposure threshold for a 2nd shot has been reached)
DEFAULT_APERTURE                = 8.0

# --- --- --- --- --- --- --- --- --- ---

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

# --- --- --- --- --- --- --- --- --- ---

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
        pass

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


class CameraConnectorSwig(CameraConnector):

    def __init__(self, port, 
        image_base_directory_primary, 
        image_base_directory_secondary):

        super().__init__(port, image_base_directory_primary, image_base_directory_secondary)

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
        self.serialnumber = self._get_serialnumber()

        self._create_image_directory()

        self.state = self.STATE_CONNECTED


    def close(self):
        gp.check_result(gp.gp_camera_exit(self.camera))
        self.camera = None

        self.state = self.STATE_CLOSED

    # def check(self):
        
    #     # is init?
    #     if self.camera is None:
    #         raise Exception("Connection not opened")

    #     try:
    #         error, summmary = gp.gp_camera_summary(self.camera)
    #         gp.check_result(error)
    #     except gp.GPhoto2Error as ge:
    #         # connector is initialized, but camera can not be controlled
    #         print(e) # TODO: use logging

    #         self.close()

    #         try:
    #             self.open()
    #         except Exception as e:
    #             print("reopening failed: {}".format(e))

    #             raise Exception("closed and reopening failed")


    def set_autofocus(self, enabled):
        try:
            value = "Manual"
            if enabled:
                value = "Automatic"

            error, config = gp.gp_camera_get_config(self.camera)
            gp.check_result(error)

            self._set_config_value(config, "focusmode", value)
        except Exception as e:
            raise e
        finally:
            pass

    def run_autofocus(self, active):
        try:
            self.state = self.STATE_BUSY

            value = 0
            if active:
                value = 1

            error, config = gp.gp_camera_get_config(self.camera)
            gp.check_result(error)

            self._set_config_value(config, "autofocus", value)
        except Exception as e:
            raise e
        finally:
            self.state = self.STATE_CONNECTED


    def set_exposure_compensation(self, compensation):

        error, config = gp.gp_camera_get_config(self.camera)
        gp.check_result(error)

        self._set_config_value(config, "exposurecompensation", str(compensation))


    def set_exposure_manual(self, shutter, aperture, iso):

        # set mode to manual

        # set shutter speed 

        # set aperture

        # set iso

        pass


    def get_exposure_status(self):

        status = {}

        error, config = gp.gp_camera_get_config(self.camera)
        gp.check_result(error)

        # error, config_list = gp.gp_camera_list_config(self.camera, self.context)
        # gp.check_result(error)

        status["state"]                 = self.state

        status["focusmode"]             = self._get_config_value(config, "focusmode")
        status["autofocus"]             = self._get_config_value(config, "autofocus")
        status["expprogram"]            = self._get_config_value(config, "expprogram")
        status["exposuremetermode"]     = self._get_config_value(config, "exposuremetermode")
        status["exposurecompensation"]  = self._get_config_value(config, "exposurecompensation")
        status["shutterspeed"]          = self._get_config_value(config, "shutterspeed")
        status["aperture"]              = self._get_config_value(config, "f-number")
        status["iso"]                   = self._get_config_value(config, "iso")
        # TODO: get battery

        return status


    def capture_and_download(self, filename):

        self.state = self.STATE_BUSY
        
        try:
            error, file_path = gp.gp_camera_capture(self.camera, gp.GP_CAPTURE_IMAGE)
            gp.check_result(error)

            self.log.debug("camera capture done. file path: {0}/{1}".format(file_path.folder, file_path.name))

            error, camera_file = gp.gp_camera_file_get(self.camera, file_path.folder, file_path.name, gp.GP_FILE_TYPE_NORMAL)
            gp.check_result(error)

            self.log.debug("camera file get done")

            time.sleep(0.1)

            # file save will throw a "You need to specify a folder starting with /store_xxxxxxxxx/"-error
            # if there is not enough disk space to transfer the file

            error = gp.gp_file_save(camera_file, os.path.join(*filename))
            gp.check_result(error)

            self.log.debug("camera save done: {}".format(filename[1]))
        except Exception as e:
            raise e
        finally:
            self.state = self.STATE_CONNECTED


    def _get_serialnumber(self):
        error, config = gp.gp_camera_get_config(self.camera)
        gp.check_result(error)

        return self._get_config_value(config, "serialnumber")


    def _get_battery(self):
        error, config = gp.gp_camera_get_config(self.camera)
        gp.check_result(error)

        return self._get_config_value(config, "batterylevel")


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

        error, config = gp.gp_camera_get_config(self, self.camera)
        gp.check_result(error)

        error, config_list = gp.gp_camera_list_config(self, self.camera, self.context)
        gp.check_result(error)

        for item in config_list:
            try:
                print("{0:25s} | {1}".format(item[0], self._get_config_value(config, str(item[0]))))

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

    def __init__(self, new_config={}, logger=None):
        self.config             = CONFIG

        self.lock               = Lock()

        self.status             = {}
        self.status["cameras"]  = {} # info about connected cameras

        self.cameras            = {} # detected cameras
        self.connectors         = {} # connected cameras

        # expand directories

        if self.config["BASE_DIR"] is None:
            if os.uname().nodename == "raspberrypi":
                self.config["BASE_DIR"] = "/home/pi/zerobox/"        
            else:
                self.config["BASE_DIR"] = "./"

        if self.config["IMAGE_DIR_PRIMARY"] is None:
            self.config["IMAGE_DIR_PRIMARY"] = None # self.config["BASE_DIR"]
        elif not self.config["IMAGE_DIR_PRIMARY"].startswith("/"):
            self.config["IMAGE_DIR_PRIMARY"] = os.path.join(self.config["BASE_DIR"], self.config["IMAGE_DIR_PRIMARY"])

        if self.config["IMAGE_DIR_SECONDARY"] is None:
            self.config["IMAGE_DIR_SECONDARY"] = self.config["BASE_DIR"]
        elif not self.config["IMAGE_DIR_SECONDARY"].startswith("/"):
            self.config["IMAGE_DIR_SECONDARY"] = os.path.join(self.config["BASE_DIR"], self.config["IMAGE_DIR_SECONDARY"])

        if self.config["IMAGE_DIR_PRIMARY"] == self.config["IMAGE_DIR_SECONDARY"]:
            self.log.warning("image dir primary and secondary is identical")
            self.config["IMAGE_DIR_SECONDARY"] = None

        if self.config["TEMP_DIR"] is None:
            self.config["TEMP_DIR"] = self.config["BASE_DIR"]
        elif not self.config["TEMP_DIR"].startswith("/"):
            self.config["TEMP_DIR"] = os.path.join(self.config["BASE_DIR"], self.config["TEMP_DIR"])

        self.load_config(new_config)

        if not logger is None:
            self.log = logger.getChild("zerobox")
        else:
            self.log = logging.getLogger("zerobox")

        # create directories
        if not self.config["IMAGE_DIR_PRIMARY"] is None:
            self._create_dir(self.config["IMAGE_DIR_PRIMARY"])
        if not self.config["IMAGE_DIR_SECONDARY"] is None:
            self._create_dir(self.config["IMAGE_DIR_SECONDARY"])
        if not self.config["TEMP_DIR"] is None:
            self._create_dir(self.config["TEMP_DIR"])


    def __repr__(self):
        # return "Zerobox (cameras: {})".format(len(self.connectors.items()))
        pass


    def _create_dir(self, path):
        try:
            os.makedirs(path)
        except FileExistsError as e:
            pass
        except PermissionError as e:
            self.log.warning("creating directory {} failed. no permission.".format(path))


    def disconnect_camera(self, portname):
        self.connectors[portname].close()


    def disconnect_all_cameras(self, clean=False):
        for portname, connector in self.connectors.items():
            connector.close()

        if clean:
            self.connectors = {}


    def get_cameras(self):
        return self.cameras


    def get_connectors(self):
        return self.connectors


    def load_config(self, config):
        # self.config = {**self.config, **config}

        # no simple merging of config dicts since 
        # we want to know if we're accidentally adding
        # a second and not overwriting a default config item

        for key, value in config.items():
            if key not in self.config:
                raise Exception("no config key to overwrite: {}".format(key))

            self.config[key] = config[key]

        # important: loading config doesn't create new directories if those have changed

    def print_config(self):

        FORMAT = "  {:<26}: {}"

        self.log.debug(" ")
        self.log.debug("CONFIGURATION ZEROBOX:")

        for key, value in self.config.items():
            self.log.debug(FORMAT.format(key, self.config[key]))

        self.log.debug(" ")


    def get_total_space(self):
        total_space = []

        try:        
            if self.config["IMAGE_DIR_PRIMARY"] is None:
                total_space.append(None)
            else:
                total_space.append(shutil.disk_usage(self.config["IMAGE_DIR_PRIMARY"]).total)
        except FileNotFoundError as e:
            total_space.append(None)
        
        try:       
            if self.config["IMAGE_DIR_SECONDARY"] is None:
                total_space.append(None)
            else:
                total_space.append(shutil.disk_usage(self.config["IMAGE_DIR_SECONDARY"]).total)
        except FileNotFoundError as e:
            total_space.append(None)

        return total_space


    def get_free_space(self):
        free_space = []

        try:        
            if self.config["IMAGE_DIR_PRIMARY"] is None:
                free_space.append(None)
            else:
                free_space.append(shutil.disk_usage(self.config["IMAGE_DIR_PRIMARY"]).free)
        except FileNotFoundError as e:
            free_space.append(None)
            

        try:        
            if self.config["IMAGE_DIR_SECONDARY"] is None:
                free_space.append(None)
            else:
                free_space.append(shutil.disk_usage(self.config["IMAGE_DIR_SECONDARY"]).free)
        except FileNotFoundError as e:
            free_space.append(None)

        return free_space


    def get_images_in_memory(self):
        files = []

        if not self.config["IMAGE_DIR_PRIMARY"] is None:
            for dirpath, dirnames, filenames in os.walk(self.config["IMAGE_DIR_PRIMARY"]):
                files = files + filenames

        if not self.config["IMAGE_DIR_SECONDARY"] is None:
            for dirpath, dirnames, filenames in os.walk(self.config["IMAGE_DIR_SECONDARY"]):
                files = files + filenames

        return files


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

        with open(full_name, "rb") as image_file:
            metadata = exifread.process_file(image_file)

        exposure_time = metadata["EXIF ExposureTime"].values[0]
        if exposure_time.num == 0 or exposure_time.den == 0:
            shutter = 0
        else:
            shutter = float(exposure_time.num) / float(exposure_time.den)

        iso = float(metadata["EXIF ISOSpeedRatings"].values[0])

        # try: 
        #     time = datetime.datetime.strptime(metadata["EXIF DateTimeOriginal"].values, EXIF_DATE_FORMAT)
        # except Exception as e:
        #     time = datetime.datetime.strptime(metadata["Image DateTime"].values, EXIF_DATE_FORMAT)

        aperture = metadata["EXIF FNumber"].values[0]
        
        if aperture.num == 0 or aperture.den == 0:
            aperture = 0
        else:
            aperture = aperture.num / aperture.den

        if aperture <= 0:
            # no aperture tag set, probably an lens adapter was used. assume fixed aperture.
            aperture = DEFAULT_APERTURE

        self.log.debug("brightness:: shutter: {} | aperture: {} | iso: {}".format(shutter, aperture, iso))

        return self._intensity(shutter, aperture, iso)


    def _intensity(self, shutter, aperture, iso):

        # limits in this calculations:
        # min shutter is 1/4000th second
        # min aperture is 22
        # min iso is 100

        shutter_repr    = math.log(shutter, 2) + 13 # offset = 13 to accomodate shutter values down to 1/4000th second
        iso_repr        = math.log(iso/100, 2) + 1  # offset = 1, iso 100 -> 1, not 0

        if aperture is not None:
            # scale:
            # [0, 4.5] --> [10, 1]

            val = math.log(aperture, 2)
            val = val / 4.5
            val = 10 - (10-1) * val
            aperture_repr = val

            # aperture_repr = np.interp(math.log(aperture, 2), [0, 4.5], [10, 1])
        else:
            aperture_repr = 1

        return shutter_repr + aperture_repr + iso_repr

    def _cli_auto_detect(self):
        output = _gphoto("auto-detect")

        cameras = []
        for i in range(2, len(output)):
            if len(output[i]) > 0:
                data = output[i].split(" ")
                data = [x for x in data if len(x) > 0] # remove multiple whitespaces

                name = ""
                for word in data[0:-1]: 
                    name = name + word + " "
                name = name[:-1] # remove trailing space

                cameras.append([name, data[-1]])

        return cameras

    def _detect_cameras(self):

        # use Python logging
        # logging.basicConfig(format='%(levelname)s: %(name)s: %(message)s', level=logging.WARNING)
        # gp.check_result(gp.use_python_logging())

        if self.config["COMMANDLINE_MODE"]:
            cameras = self._cli_auto_detect()
        else:
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

        return cameras


    def detect_cameras(self):

        cameras = self._detect_cameras()

        if len(cameras) == 0:
            self.log.debug("no cameras detected")
            return {}

        if len(cameras) == 1:
            self.log.debug("1 camera detected")
        else:
            self.log.debug("{} cameras detected".format(len(cameras)))

        # if a camera is disconnected and connected again, it may be the
        # same camera but is listed at a different portname 

        # option 1: connect to camera and get serialnumber
        # option 2: throw away all previously known cameras

        self.cameras = {}
        self.status["cameras"] = {}

        for camera in cameras:
            camera_obj = camera[0]
            portname = camera[1]
            print("{} | {}".format(camera_obj, portname))

            self.cameras[portname] = camera 
            if portname not in self.status["cameras"]:
                self.status["cameras"][portname] = {}
                self.status["cameras"][portname]["state"] = None
                self.status["cameras"][portname]["last_image_brightness"] = None
            self.status["cameras"][portname]["port"] = portname

        return self.cameras


    def connect_camera(self, camera, quiet=False):

        conn = None

        if self.config["COMMANDLINE_MODE"]:
            conn = CameraConnectorCli(None, self.config["IMAGE_DIR_PRIMARY"], self.config["IMAGE_DIR_SECONDARY"])
        else:
            port = self._lookup_port(self.port_info_list, camera)
            conn = CameraConnectorSwig(port, self.config["IMAGE_DIR_PRIMARY"], self.config["IMAGE_DIR_SECONDARY"])

        portname = camera[1]
        if portname not in self.status["cameras"]:
            self.status["cameras"][portname] = {}

        try:
            conn.open()
        except Exception as e:
            self.log.error("Could not connect camera: {}".format(e))
            self.status["cameras"][portname]["error"] = "unknown error"
            self.status["cameras"][portname]["state"] = None
            raise Exception("Could not open camera connection. Unknown exception.", e)

        self.connectors[portname] = conn

        self.status["cameras"][portname]["error"] = None

        exposure_status = {}

        if not quiet:
            if conn.get_state() != CameraConnector.STATE_BUSY:
                exposure_status = conn.get_exposure_status()

        self.status["cameras"][portname] = {**self.status["cameras"][portname], **exposure_status}


    def focus_camera(self, portname):
        conn = self.connectors[portname]

        if conn.get_state() == CameraConnector.STATE_BUSY:
            raise Exception("Camera busy")

        conn.set_autofocus(True)
        conn.run_autofocus(True)
        time.sleep(self.config["AUTOFOCUS_DURATION"])
        conn.run_autofocus(False)
        conn.set_autofocus(False)


    def trigger_camera(self, portname):

        self.log.debug("TRIGGER")

        lock_acquired = False
        try:

            self.lock.acquire()

            conn = self.connectors[portname]

            if conn.get_state() == CameraConnector.STATE_BUSY:
                raise Exception("Camera busy")

            if self.config["AUTOFOCUS_ENABLED"]:
                self.focus_camera(portname)

            filename = self._acquire_filename(conn.get_image_directory(self.config["MIN_FREE_SPACE"]))
            filename2 = None

            self.log.debug("acquired filename: {} {}".format(*filename))

            if not self.config["SECONDEXPOSURE_ENABLED"]:
                conn.capture_and_download(filename)
            else:
                conn.set_exposure_compensation(self.config["EXPOSURE_1"])
                conn.capture_and_download(filename)

                trigger_second_exposure = True
                if self.config["SECONDEXPOSURE_THRESHOLD"] is not None:
                    # jpeg_full_name = self._convert_raw_to_jpeg(filename[0], filename[1], self.config["TEMP_DIR"])
                    image_full_name = os.path.join(filename[0], filename[1])
                    exposure = self._calculate_brightness(image_full_name)
                    self.log.info("exposure: {:.3f}".format(exposure))

                    if exposure > self.config["SECONDEXPOSURE_THRESHOLD"]:
                        trigger_second_exposure = False

                    self.status["cameras"][portname]["last_image_brightness"] = exposure

                if trigger_second_exposure:
                    self.log.info("2nd exposure triggered")
                    conn.set_exposure_compensation(self.config["EXPOSURE_2"])
                    filename2 = (filename[0], filename[1] + "_2")
                    conn.capture_and_download(filename2)
                    conn.set_exposure_compensation(self.config["EXPOSURE_1"])

            taken_images = [filename]
            if filename2 is not None:
                taken_images.append(filename2)
        except Exception as e:
            self.log.error("triggering failed: {} : {}".format(type(e), e))
            raise e
        finally:
            self.lock.release()

        return taken_images


    def get_battery(self):
        battery_data = []

        for portname in self.status["cameras"].keys():
            status_data = self.status["cameras"][portname]
            
            if "battery" in status_data:
                battery_data.append([status_data["battery"], "camera"])

        return battery_data


    """ 
    does not use cached info in self.status but directly retrieves battery data from
    connected cameras. Returns empty dict in case of error.
    """
    def get_battery_direct(self):
        battery_data = {}

        lock_acquired = self.lock.acquire(timeout=1.0)
        if lock_acquired:
            for portname, connector in self.connectors.items():
                try:
                    battery_data[portname] = connector._get_battery()
                except Exception as e:
                    self.log.error("Exception while retrieving battery data: {}".format(e))
        else:
            self.log.warning("get_battery lock not acquired")

        return battery_data


    def get_status(self, force_connection=False):
        data = {**self.status}

        lock_acquired = False
        if force_connection:
            try:

                self.log.debug("GET_STATUS")

                lock_acquired = self.lock.acquire(timeout=1.0)

                if lock_acquired:
                    for portname, connector in self.connectors.items():

                        if connector.get_state() == CameraConnector.STATE_BUSY:
                            self.log.warning("camera {} busy. getting status aborted".format(portname))
                            data["cameras"][portname]["state"] = connector.get_state()
                            continue
                        else:
                            self.log.debug(connector.get_state())

                        try:
                            s = connector.get_exposure_status()
                            old = data["cameras"][portname]
                            data["cameras"][portname] = {**old, **s}
                            data["cameras"][portname]["error"] = None
                        # except gp.GPhoto2Error as e:
                        except Exception as e:
                            self.log.error("getting exposure status failed: {}".format(e))

                            detected_cameras = self._detect_cameras()
                            detected_portnames = [x[1] for x in detected_cameras]

                            if portname in detected_portnames:
                                self.log.error("camera {} not responding".format(portname))
                                data["cameras"][portname]["error"] = "not responding"
                            else:
                                self.log.error("camera {} disconnected".format(portname))
                                data["cameras"][portname]["error"] = "disconnected"

                                try:
                                    connector.close()
                                except Exception as e:
                                    pass

                                try:
                                    connector.open()
                                except Exception as e:
                                    self.log.warning("reconnect failed: {}".format(e))
                else:
                    self.log.warning("get_status lock not acquired")
                    # so no data gets updated but old data will be returned

            except Exception as e:
                self.log.error("getting exposure status failed: {}".format(e))
                raise e
            finally:
                if lock_acquired:
                    self.lock.release()

        return data


if __name__ == "__main__":
    z = Zerobox()
    # print(z.get_status())
    # print("free space on {}: {}".format(z.config["IMAGE_DIR"], z.get_free_space()/1024.0**3))
    # z.print_config()
    # z.detect_cameras()

    # for portname, camera in z.cameras.items():
    #     z.connect_camera(camera)
    #     z.trigger_camera(portname)

    # print(z.get_status()

    # print(z.get_images_in_memory())

    # z.close()

    z.detect_cameras()
    for cam in z.get_cameras():
        z.connect_camera(cam)
        z.trigger_camera(cam[1])

    print(z.get_status())



        
        
