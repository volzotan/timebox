from datetime import datetime
import logging
import sys
import time

import gphoto2 as gp
 
EXIT_CODE_NO_CAMERAS_FOUND          = -1

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


def set_exposure_compensation(camera, compensation):

    error, config = gp.gp_camera_get_config(camera)
    gp.check_result(error)

    _set_config_value(camera, config, "exposurecompensation", str(compensation))


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

# print("PORTS:")
# for item in port_info_list:
#     print(item.get_name())
#     print(item.get_path())
#     print(item.get_type())
#     print("-----")

# print("ABILITIES:")
# for item in abilities_list:
#     print(item)
#     print("-----")

# print("CAMERAS")
# for item in cameras:
#     print(item[0])
#     print(item[1])

camera = init_camera(port=_lookup_port(port_info_list, cameras[0][1]))
set_exposure_compensation(camera, "-1")

# error, abilities = gp.gp_camera_get_abilities(camera)
# gp.check_result(error)
# _print_abilities(abilities)

gp.check_result(gp.gp_camera_exit(camera))
