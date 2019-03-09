import logging
import os
import sys

import gphoto2 as gp

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

    "IMAGE_BASE_DIR"            : None,
    "FILE_EXTENSION"            : ".arw",

    "AUTOFOCUS_ENABLED"         : False,
    "AUTOFOCUS_DURATION"        : 2,

    "DOUBLEEXPOSURE_ENABLED"    : False,
    "EXPOSURE_1"                : +1,
    "EXPOSURE_2"                : -5,

}

# --- --- --- --- --- --- --- --- --- ---

class CameraConnector(object):

    def __init__(self, port, image_base_directory):
        self.port = port
        self.image_base_directory = image_base_directory
        self.image_directory = None


    def init(self):
        self.context = gp.gp_context_new()

        error, camera = gp.gp_camera_new()
        gp.check_result(error)

        if self.port is not None:
            error = gp.gp_camera_set_port_info(camera, self.port)
            gp.check_result(error)

        error = gp.gp_camera_init(camera, self.context)  
        gp.check_result(error)

        self.camera = camera

        # create image directory
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

        self._set_config_value(self.camera, config, "exposurecompensation", str(compensation))


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
        self.cameras = {}
        self.connectors = {}
        self.config = CONFIG

        if os.uname().nodename == "raspberrypi":
            self.config["IMAGE_BASE_DIR"] = "/home/pi/zerobox/"
        else:
            self.config["IMAGE_BASE_DIR"] = "./"

        self.init_log()


    def close(self):
        for portname, connector in self.connectors.items():
            connector.close()


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
            print("{} | {}".format(camera[0], camera[1]))
            self.cameras[camera[1]] = camera 


    def connect_camera(self, camera):
        port = self._lookup_port(self.port_info_list, camera)
        conn = CameraConnector(port, self.config["IMAGE_BASE_DIR"])
        conn.init()
        self.connectors[portname] = conn


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
            conn.set_exposure_compensation(self.config["EXPOSURE_2"])
            conn.capture_and_download(filename + "_2")

        # arguments.append((conn, os.path.join(file_folder[i], "test" + EXTENSION)))


    def get_status(self):
        data = {}

        for portname, connector in self.connectors.items():
            s = connector.get_exposure_status()

            data[portname] = s

        return data


if __name__ == "__main__":
    z = Zerobox()
    z.print_config()
    z.detect_cameras()

    for portname, camera in z.cameras.items():
        z.connect_camera(camera)
        z.trigger_camera(portname)

    print(z.get_status())
    z.close()

        
        
