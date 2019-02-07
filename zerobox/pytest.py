from datetime import datetime
import logging
import os
import sys
import time
from datetime import datetime

# from multiprocessing.pool import ThreadPool

import gphoto2 as gp
 

EXIT_CODE_UNKNOWN                   = -1
EXIT_CODE_NO_CAMERAS_FOUND          = -2

EXTENSION                           = ".ARW"

class Camera(object):

    def __init__(self, port):
        self.port = port
        self.camera = None

    @staticmethod
    def _get_config_value(config, name):

        error, conf_result = gp.gp_widget_get_child_by_name(config, name)
        gp.check_result(error)

        error, result = gp.gp_widget_get_value(conf_result)
        gp.check_result(error)

        return result


    @staticmethod
    def _set_config_value(camera, config, name, value):

        error, window = gp.gp_widget_get_child_by_name(config, name)
        gp.check_result(error)

        error = gp.gp_widget_set_value(window, value)
        gp.check_result(error)

        error = gp.gp_camera_set_config(camera, config)
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


    def init_camera(self):

        error, camera = gp.gp_camera_new()
        gp.check_result(error)

        if self.port is not None:

            error = gp.gp_camera_set_port_info(camera, self.port)
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

        self.camera = camera


    def list_config(self):

        if self.camera is None:
            raise Exception("camera not initialized")

        error, config = gp.gp_camera_get_config(self.camera)
        gp.check_result(error)

        error, config_list = gp.gp_camera_list_config(self.camera, context)
        gp.check_result(error)

        for item in config_list:
            try:
                print("{0:25s} | {1}".format(item[0], _get_config_value(config, str(item[0]))))

            except gp.GPhoto2Error as e:
                print(e)

            # error, config = gp.gp_camera_get_config(camera, context)
            # gp.check_result(error)


    def get_exposure_status(self):

        if self.camera is None:
            raise Exception("camera not initialized")

        status = {}

        error, config = gp.gp_camera_get_config(self.camera)
        gp.check_result(error)

        error, config_list = gp.gp_camera_list_config(self.camera, context)
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


    def set_exposure_compensation(self, compensation):

        if self.camera is None:
            raise Exception("camera not initialized")

        error, config = gp.gp_camera_get_config(self.camera)
        gp.check_result(error)

        self._set_config_value(self.camera, config, "exposurecompensation", str(compensation))


    def set_autofocus(self, enabled):

        if self.camera is None:
            raise Exception("camera not initialized")

        value = "Manual"
        if enabled:
            value = "Automatic"

        error, config = gp.gp_camera_get_config(self.camera)
        gp.check_result(error)

        _set_config_value(self.camera, config, "focusmode", value)


    def run_autofocus(self, active):

        if self.camera is None:
            raise Exception("camera not initialized")

        value = 0
        if active:
            value = 1

        error, config = gp.gp_camera_get_config(camera)
        gp.check_result(error)

        _set_config_value(camera, config, "autofocus", value)


    def capture_and_download(self, filename):

        if self.camera is None:
            raise Exception("camera not initialized")

        error, file_path = gp.gp_camera_capture(self.camera, gp.GP_CAPTURE_IMAGE)
        gp.check_result(error)

        # print('Camera file path: {0}/{1}'.format(file_path.folder, file_path.name))

        error, camera_file = gp.gp_camera_file_get(self.camera, file_path.folder, file_path.name, gp.GP_FILE_TYPE_NORMAL)
        gp.check_result(error)

        error = gp.gp_file_save(camera_file, filename)
        gp.check_result(error)


    def run_capture(self, context, port, filename):
        error = None
        camera = None

        print("start run_capture for device at port {}".format(port.get_path()))

        try:
            camera = init_camera(port=port)
            capture_and_download(camera, filename)
        except Exception as e:
            print("error")
            error = e
        finally:
            if camera is not None:
                gp.check_result(gp.gp_camera_exit(camera))
            else:
                print("camera None, closing not possible")

        return error


    def close(self):

        if self.camera is None:
            raise Exception("camera not initialized")

        gp.check_result(gp.gp_camera_exit(self.camera))



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

    file_folder = []
    for i in range(0, len(cameras)):
        name = "camera_{}".format(i)
        try:
            os.makedirs(name)
        except Exception as e:
            pass

        file_folder.append(name)

    for i in range(0, len(cameras)):
        port = Camera._lookup_port(port_info_list, cameras[i][1])
        filename = os.path.join(file_folder[i], "test" + EXTENSION)

        cam1 = Camera(port)
        cam1.init_camera()
        cam1.set_exposure_compensation(+1)
        cam1.close()


    # pool = ThreadPool(processes=1)

    # file_folder = []
    # for i in range(0, len(cameras)):
    #     name = "camera_{}".format(i)
    #     try:
    #         os.makedirs(name)
    #     except Exception as e:
    #         pass

    #     file_folder.append(name)

    # capture_results = []
    # capture_timer = []

    # for i in range(0, len(cameras)):
    #     cam = cameras[i]
    #     arguments = (context, _lookup_port(port_info_list, cam[1]), os.path.join(file_folder[i], "test" + EXTENSION))
    #     # print(run_capture(*arguments))
    #     capture_result = pool.apply_async(run_capture, arguments)
        
    #     capture_results.append(capture_result)
    #     capture_timer.append(datetime.now())

    # for result, t in zip(capture_results, capture_timer):
    #     print(result.get())
    #     print("took {0:.2f}ms".format((datetime.now() - t).microseconds / 1000))










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
