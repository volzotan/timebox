import logging

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

class CameraConnector(object):

    def __init__(self, port):
        self.port = port


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


    def close(self):
        gp.check_result(gp.gp_camera_exit(self.camera))


    def set_autofocus(self, enabled):

        value = "Manual"
        if enabled:
            value = "Automatic"

        error, config = gp.gp_camera_get_config(self.camera)
        gp.check_result(error)

        self._set_config_value(config, "focusmode", value)


    @staticmethod
    def _get_config_value(config, name):

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


    @staticmethod
    def _lookup_port(port_list, port_address):
        for port in port_list:
            if port.get_path() == port_address:
                return port

        return None


class Zerobox(object):

    def __init__(self):
        pass

    def close(self):
        pass

    def get_free_space():
        return 0 # TODO

    def detect_cameras(self):

        # use Python logging
        logging.basicConfig(format='%(levelname)s: %(name)s: %(message)s', level=logging.WARNING)
        gp.check_result(gp.use_python_logging())

        self.context = gp.gp_context_new()

        error, self.port_info_list = gp.gp_port_info_list_new()
        gp.check_result(error)

        error = gp.gp_port_info_list_load(self.port_info_list)
        gp.check_result(error)

        error, abilities_list = gp.gp_abilities_list_new()
        gp.check_result(error)

        error = gp.gp_abilities_list_load(abilities_list)
        gp.check_result(error)

        error, self.cameras = gp.gp_abilities_list_detect(abilities_list, self.port_info_list)
        gp.check_result(error)

        if len(self.cameras) == 0:
            return []

        if len(self.cameras) == 1:
            print("1 camera connected")
        else:
            print("{} cameras connected".format(len(self.cameras)))

        for name, addr in self.cameras:
            print("{} | {}".format(name, addr))


    def create_directories(self):
        file_folder = []
        for i in range(0, len(self.cameras)):
            name = "camera_{}".format(i)
            try:
                os.makedirs(name)
            except Exception as e:
                pass

            file_folder.append(name)


    def connect_camera(self, camera):
        pass

    def trigger_camera(self, camera):
        port = CameraConnector._lookup_port(self.port_info_list, camera)
        conn = CameraConnector(port)
        conn.init()
        conn.set_autofocus(False)
        conn.close()

        # arguments.append((conn, os.path.join(file_folder[i], "test" + EXTENSION)))

        
        
