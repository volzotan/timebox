from datetime import datetime
import logging
import sys
import time

import gphoto2 as gp
 

def _get_config_value(config, name):

    error, conf_result = gp.gp_widget_get_child_by_name(config, name)
    gp.check_result(error)

    error, result = gp.gp_widget_get_value(conf_result)
    gp.check_result(error)

    return result


def _set_config_value(config, name, value):

    error, window = gp.gp_widget_get_child_by_name(config, name)
    gp.check_result(error)

    error = gp.gp_widget_set_value(window, value)
    gp.check_result(error)

    error = gp.gp_camera_set_config(camera, config)
    gp.check_result(error)


# use Python logging
logging.basicConfig(format='%(levelname)s: %(name)s: %(message)s', level=logging.WARNING)
gp.check_result(gp.use_python_logging())

context = gp.gp_context_new()

if hasattr(gp, 'gp_camera_autodetect'):
    # gphoto2 version 2.5+
    print("using autodetect")
    cameras = gp.check_result(gp.gp_camera_autodetect())
else:
    port_info_list = gp.check_result(gp.gp_port_info_list_new())
    gp.check_result(gp.gp_port_info_list_load(port_info_list))
    abilities_list = gp.check_result(gp.gp_abilities_list_new())
    gp.check_result(gp.gp_abilities_list_load(abilities_list))
    cameras = gp.check_result(gp.gp_abilities_list_detect(
        abilities_list, port_info_list))

if (len(cameras) == 0):
    print("no cameras found")
else:
    n = 0
    for name, value in cameras:
        print('camera number', n)
        print('===============')
        print(name)
        print(value)
        print
        n += 1

    error, camera = gp.gp_camera_new()
    gp.check_result(error)

    error = gp.gp_camera_init(camera, context)  
    gp.check_result(error)


    print("************* Summary")
    error, text = gp.gp_camera_get_summary(camera, context)
    gp.check_result(error)
    print(text.text)

    print("=============")

    print("************* List Config")

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

    print("=============")

    # print("************* Capture")

    print("************* Exposure Compensation")

    error, config = gp.gp_camera_get_config(camera)
    gp.check_result(error)

    _set_config_value(config, "exposurecompensation", "+1")

    print("=============")

    gp.check_result(gp.gp_camera_exit(camera))
