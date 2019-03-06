from datetime import datetime
import logging
import os
import sys
import time
from datetime import datetime

# from multiprocessing.pool import ThreadPool
from multiprocessing.pool import Pool

import gphoto2 as gp
 
EXIT_CODE_UNKNOWN                   = -1
EXIT_CODE_NO_CAMERAS_FOUND          = -2

EXTENSION                           = ".ARW"

class CameraConnection(object):

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


def _get_config_value(config, name):

    error, conf_result = gp.gp_widget_get_child_by_name(config, name)
    gp.check_result(error)

    error, result = gp.gp_widget_get_value(conf_result)
    gp.check_result(error)

    return result


def _set_config_value(camera, config, name, value):

    error, window = gp.gp_widget_get_child_by_name(config, name)
    gp.check_result(error)

    error = gp.gp_widget_set_value(window, value)
    gp.check_result(error)

    error = gp.gp_camera_set_config(camera, config)
    gp.check_result(error)


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


def _lookup_port(port_list, port_address):
    for port in port_list:
        if port.get_path() == port_address:
            return port

    return None


def init_camera(port=None):

    error, camera = gp.gp_camera_new()
    gp.check_result(error)

    if port is not None:

        error = gp.gp_camera_set_port_info(camera, port)
        gp.check_result(error)

        # error, port_info = gp.gp_camera_get_port_info(camera)
        # gp.check_result(error)
        # print(*port_info.__class__.__dict__, sep="\n")
        # print(port_info.get_name())
        # print(port_info.get_path())
        # print(port_info.get_type())

        # error = gp.gp_port_info_list_load(camera)
        # gp.check_result(error)

        # print(port_list)

        # for info in port_list:
        #     print(info)

        # error = gp.gp_camera_set_port_info(camera, port)
        # gp.check_result(error)

    error = gp.gp_camera_init(camera, context)  
    gp.check_result(error)

    return camera


def list_config(camera):

    error, config = gp.gp_camera_get_config(camera)
    gp.check_result(error)

    error, config_list = gp.gp_camera_list_config(camera, context)
    gp.check_result(error)

    for item in config_list:
        try:
            print("{0:25s} | {1}".format(item[0], _get_config_value(config, str(item[0]))))

        except gp.GPhoto2Error as e:
            print(e)

        # error, config = gp.gp_camera_get_config(camera, context)
        # gp.check_result(error)

def get_exposure_status(camera):

    status = {}

    error, config = gp.gp_camera_get_config(camera)
    gp.check_result(error)

    error, config_list = gp.gp_camera_list_config(camera, context)
    gp.check_result(error)

    status["autofocus"]             = _get_config_value(config, "autofocus")
    status["focusmode"]             = _get_config_value(config, "focusmode")
    status["expprogram"]            = _get_config_value(config, "expprogram")
    status["exposuremetermode"]     = _get_config_value(config, "exposuremetermode")
    status["exposurecompensation"]  = _get_config_value(config, "exposurecompensation")
    status["shutterspeed"]          = _get_config_value(config, "shutterspeed")
    status["f-number"]              = _get_config_value(config, "f-number")
    status["iso"]                   = _get_config_value(config, "iso")

    return status


def set_exposure_compensation(camera, compensation):

    error, config = gp.gp_camera_get_config(camera)
    gp.check_result(error)

    _set_config_value(camera, config, "exposurecompensation", str(compensation))


def set_autofocus(camera, enabled):

    value = "Manual"
    if enabled:
        value = "Automatic"

    error, config = gp.gp_camera_get_config(camera)
    gp.check_result(error)

    _set_config_value(camera, config, "focusmode", value)


def run_autofocus(camera, active):

    value = 0
    if active:
        value = 1

    error, config = gp.gp_camera_get_config(camera)
    gp.check_result(error)

    _set_config_value(camera, config, "autofocus", value)


def capture_and_download(camera, filename):
    
    error, file_path = gp.gp_camera_capture(camera, gp.GP_CAPTURE_IMAGE)
    gp.check_result(error)

    # print('Camera file path: {0}/{1}'.format(file_path.folder, file_path.name))

    error, camera_file = gp.gp_camera_file_get(camera, file_path.folder, file_path.name, gp.GP_FILE_TYPE_NORMAL)
    gp.check_result(error)

    error = gp.gp_file_save(camera_file, filename)
    gp.check_result(error)


def trigger(conn, filename):
    try:
        capture_and_download(conn.camera, filename)
    except Exception as e:
        print("error")
        error = e
    finally:
        conn.close()


if __name__ == "__main__":

    # inital checks
    if not EXTENSION.startswith("."):
        EXTENSION = "." + EXTENSION

    # use Python logging
    logging.basicConfig(format='%(levelname)s: %(name)s: %(message)s', level=logging.WARNING)
    gp.check_result(gp.use_python_logging())

    context = gp.gp_context_new()

    error, port_info_list = gp.gp_port_info_list_new()
    gp.check_result(error)

    error = gp.gp_port_info_list_load(port_info_list)
    gp.check_result(error)

    error, abilities_list = gp.gp_abilities_list_new()
    gp.check_result(error)

    error = gp.gp_abilities_list_load(abilities_list)
    gp.check_result(error)

    error, cameras = gp.gp_abilities_list_detect(abilities_list, port_info_list)
    gp.check_result(error)

    if len(cameras) == 0:
        print("no cameras found. exit.")
        sys.exit(EXIT_CODE_NO_CAMERAS_FOUND)

    if len(cameras) == 1:
        print("1 camera connected")
    else:
        print("{} cameras connected".format(len(cameras)))

    for name, addr in cameras:
        print("{} | {}".format(name, addr))

    pool = ThreadPool(processes=2)

    file_folder = []
    for i in range(0, len(cameras)):
        name = "camera_{}".format(i)
        try:
            os.makedirs(name)
        except Exception as e:
            pass

        file_folder.append(name)

    capture_results = []
    capture_timer = []
    arguments = []

    for i in range(0, len(cameras)):
        cam_object = cameras[i]

        conn = CameraConnection(_lookup_port(port_info_list, cam_object[1]))
        conn.init()

        set_autofocus(conn.camera, False)

        arguments.append((conn, os.path.join(file_folder[i], "test" + EXTENSION)))

        # arguments = (None, _lookup_port(port_info_list, cam_object[1]), os.path.join(file_folder[i], "test" + EXTENSION))
        # print(run_capture(*arguments))

    for arg in arguments:

        capture_timer.append(datetime.now())

        capture_result = pool.apply_async(trigger, arg)
        
        capture_results.append(capture_result)



    for result, t in zip(capture_results, capture_timer):
        print(result.get()) # get blocks
        print("took {0:.2f}ms".format((datetime.now() - t).microseconds / 1000))

    pool.close()
    pool.terminate()


    # camera = init_camera(port=_lookup_port(port_info_list, cameras[0][1]))
    # set_exposure_compensation(camera, "-1")

    # set_autofocus(camera, True)
    # run_autofocus(camera, True)
    # time.sleep(2)
    # run_autofocus(camera, False)
    # set_autofocus(camera, False)

    # # list_config(camera)
    # # print(get_exposure_status(camera))

    # # error, abilities = gp.gp_camera_get_abilities(camera)
    # # gp.check_result(error)
    # # _print_abilities(abilities)

    # # capture_and_download(camera, "foo.arw")

    # gp.check_result(gp.gp_camera_exit(camera))
