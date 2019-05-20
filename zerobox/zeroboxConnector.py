#!/usr/bin/env python3

from zerobox import Zerobox
from zeroboxScheduler import Scheduler
from devices import UsbController

import rpyc
from rpyc.utils.server import ThreadedServer
from rpyc.utils.classic import obtain

import logging
import traceback


from datetime import datetime, timedelta
import time
import os
import subprocess
import sys
import yaml

import multiprocessing
from multiprocessing.pool import ThreadPool
from multiprocessing.pool import Pool

from threading import Thread


CONFIG_FILE_DEFAULT = "config_default.yaml"
CONFIG_FILE_USER    = "config.yaml"

# USB_CHIP            = "/sys/devices/platform/soc/3f980000.usb/buspower"
USB_CHIP            = "/sys/devices/platform/soc/20980000.usb/buspower"



def _trigger(zerobox, portname):
    return zerobox.trigger_camera(portname)

class ZeroboxConnector(rpyc.Service):

    STATE_IDLE      = 1
    STATE_RUNNING   = 2

    def __init__(self):
        print("init")

        self.zerobox = Zerobox()
        self.scheduler = Scheduler()
        self.usbController = []

        self.usbController = self.exposed_detect_usb_controller()
        for controller in self.usbController:
            print(controller)

        self.pool = ThreadPool(processes=1)
        self.capture_results = []
        self.capture_timer = []

        self.config = {}

        self.state = self.STATE_IDLE

        self.session = {}

        # load config

        with open(CONFIG_FILE_DEFAULT, "r") as stream:
            try:
                self.config = {**self.config,**yaml.load(stream)}
            except yaml.YAMLError as exc:
                print(exc)
        try:
            with open(CONFIG_FILE_USER, "r") as stream:
                self.config = {**self.config,**yaml.load(stream)}
        except FileNotFoundError as e:
            print("no config file found")

        # init logging
        # create logger
        self.log = logging.getLogger()
        self.log.setLevel(logging.DEBUG)

        # create formatter
        formatter = logging.Formatter(self.config["log"]["format"])

        # console handler and set level to debug
        # consoleHandler = logging.StreamHandler()
        # consoleHandler.setLevel(self.config["log"]["level"])
        # consoleHandler.setFormatter(formatter)
        # self.log.addHandler(consoleHandler)

        # fileHandlerDebug = logging.FileHandler(os.path.join(".", "gui.log"), mode="a",
        #                                        encoding="UTF-8")  # TODO: do not use current dir for logging
        # fileHandlerDebug.setLevel(logging.DEBUG)
        # fileHandlerDebug.setFormatter(formatter)
        # self.log.addHandler(fileHandlerDebug)

        # Pi Zero Maintenance stuff

        # Turn off HDMI to save power
        subprocess.call("/usr/bin/tvservice -o", shell=True)

        # print config

        self.exposed_print_config()


    def close(self):
        if self.pool is not None:
            self.pool.close()
            self.pool.terminate()

        if self.zerobox is not None:
            self.zerobox.close()

    def exposed_print_config(self):

        FORMAT          = "  {:<26}: {}"
        FORMAT_CHILD    = "    {:<24}: {}"

        self.log.debug(" ")
        self.log.debug("CONFIGURATION CONNECTOR:")

        for key, value in self.config.items():
            c = self.config[key]
            if "type" in c:
                if "parent" in c:
                    self.log.debug(FORMAT_CHILD.format(key, c["value"]))
                else:
                    self.log.debug(FORMAT.format(key, c["value"]))
            else:
                self.log.debug(FORMAT.format(key, c))

        self.log.debug(" ")

        if self.zerobox is not None:
            self.zerobox.print_config()


    def on_connect(self, conn):
        print("on_connect")


    def on_disconnect(self, conn):
        print("on_disconnect")


    def exposed_usb_switch_on(self, power_on):
        if power_on:
            f = open(USB_CHIP, "w")
            f.write("1")
            f.close()
            log.debug("usb enabled")
        else:
            f = open(USB_CHIP, "w")
            f.write("0")
            f.close()
            log.debug("usb disabled")

        time.sleep(1)


    def exposed_ping(self):
        return None


    def exposed_trigger(self):

        self.log.debug("trigger")

        self.capture_results = []
        self.capture_timer = []
        arguments = []

        cameraconnectors = self.zerobox.get_connectors()
        if len(cameraconnectors.items()) == 0:
            raise Exception("no connected camera found. trigger failed.")

        for portname, cameraconnector in cameraconnectors.items():
            arguments.append((self.zerobox, portname))

        for arg in arguments:
            self.capture_timer.append(datetime.now())
            capture_result = self.pool.apply_async(_trigger, arg)
            self.capture_results.append(capture_result)

        # for portname, cameraconnector in self.zerobox.get_connectors().items():
        #     self.zerobox.trigger_camera(portname)


    def _is_trigger_active(self):
        if len(self.capture_results) > 0:
            return True
        else:
            return False

    def exposed_check_trigger_result(self):

        results = []
        
        for result, t in zip(self.capture_results, self.capture_timer):
            try:
                r = result.get(timeout=0.1) #s
                results.append(r)
                diff = (datetime.now() - t)
                self.log.info("trigger took {0:.2f}s".format(diff.total_seconds()))
            except multiprocessing.context.TimeoutError as e:
                results.append(None)

        return results


    def exposed_disconnect_all_cameras(self):
        self.zerobox.disconnect_all_cameras()


    # -------


    def exposed_loop(self):
        jobs = self.scheduler.run_schedule()

        if self.state == self.STATE_IDLE:
            pass

        elif self.state == self.STATE_RUNNING:

            if "camera_on" in jobs:
                for controller in self.usbDirectController:
                    controller.turn_on(True)

            if "camera_off" in jobs:
                if not self._is_trigger_active():
                    for controller in self.usbDirectController:
                        controller.turn_on(False)
                    else:
                        self.log.warning("previous trigger still active! unable to turn off camera")

            if "trigger" in jobs:
                if not self._is_trigger_active():
                    if not self.session["intervalcamera"]:
                        self.exposed_connect_to_all()

                    try:
                        self.exposed_trigger()
                    except Exception as e:
                        self.log.error("trigger failed: ", e)
                        self.session["errors"].append(e)
                else:
                    self.log.warning("previous trigger still active! ignoring trigger event")
                    self.session["errors"].append(Exception("prev trigger active"))

            # check finished triggers

            results = self.exposed_check_trigger_result()

            if len(results) > 0 and None not in results:
                self.session["images"].append(results)
                self.capture_results = []
                self.capture_timer = []

                # camera off?
                # TODO: ignores post_wait
                if not self.session["intervalcamera"]:
                    if not self._is_trigger_active():
                        for controller in self.usbDirectController:
                            controller.turn_on(False)
                        else:
                            self.log.warning("previous trigger still active! unable to turn off camera")

                # session done?
                if len(self.session["images"]) >= self.session["iterations"]:
                    self.log.info("image count equals iterations. ending session.")
                    self.exposed_stop()

        else:
            self.log.warning("illegal state: {}".format(self.state))

    def _load_zerobox_config(self):

        zeroboxConfig = {}
        zeroboxConfig["AUTOFOCUS_ENABLED"] = self.config["autofocus"]["value"]
        zeroboxConfig["SECONDEXPOSURE_ENABLED"] = self.config["secondexposure"]["value"]
        if self.config["se_use_threshold"]["value"]:
            zeroboxConfig["SECONDEXPOSURE_THRESHOLD"] = self.config["se_threshold"]["value"]
        else:
            zeroboxConfig["SECONDEXPOSURE_THRESHOLD"] = None
        zeroboxConfig["EXPOSURE_1"] = self.config["se_expcompensation_1"]["value"]
        zeroboxConfig["EXPOSURE_2"] = self.config["se_expcompensation_2"]["value"]

        self.zerobox.load_config(zeroboxConfig)

    def exposed_load_config(self, connector_config):
        self.config = {**self.config, **obtain(connector_config)}
        self._load_zerobox_config()

    def exposed_get_config(self):
        return self.config

    def exposed_start(self):

        self.session = {}
        self.session["start"]   = datetime.now()
        self.session["end"]     = self.session["start"] + timedelta(seconds=(self.config["interval"]["value"] * self.config["iterations"]["value"]))
        self.session["next_invocation"] = None
        self.session["images"]  = []
        self.session["errors"]  = []

        for key in self.config.keys():
            if "type" in self.config[key]:
                self.session[key] = self.config[key]["value"]

        self._load_zerobox_config()
        self.exposed_detect_usb_controller()
        self.exposed_detect_cameras()

        if self.session["intervalcamera"]:
            self.exposed_connect_to_all()

        interval = self.session["interval"]*1000
        delay = 500
        if self.session["intervalcamera"]:
            self.scheduler.add_job("trigger", interval, delay = delay)
        else:
            self.scheduler.add_job("camera_on", interval,
                                   delay = delay)
            self.scheduler.add_job("trigger", interval,
                                   delay = delay+float(self.session["pc_pre_wait"])*1000)
            # max time the camera may be alive. should already be shut down after
            # the trigger event returned, but just as a safeguard
            self.scheduler.add_job("camera_off", interval,
                                   delay = (delay+30.0+float(self.session["pc_pre_wait"]))*1000)

        self.state = self.STATE_RUNNING

        FORMAT = "  {:<24}: {}"

        self.log.info("start session")
        self.log.info(FORMAT.format("interval", interval))
        self.log.info(FORMAT.format("cameras", len(self.zerobox.get_cameras())))
        self.log.info(FORMAT.format("usbDirectController", len(self.usbDirectController)))

    def exposed_stop(self):

        self.log.info("session stop")

        if self.scheduler.is_job_scheduled("camera_on"):
            self.scheduler.remove_job("camera_on")

        if self.scheduler.is_job_scheduled("trigger"):
            self.scheduler.remove_job("trigger")

        if self.scheduler.is_job_scheduled("camera_off"):
            self.scheduler.remove_job("camera_off")

        self.session["end"] = datetime.now()
        self.state = self.STATE_IDLE

    def exposed_connect(self, _portname):
        portname = obtain(_portname)
        cameras = self.zerobox.get_cameras()

        if portname not in cameras:
            raise Exception("no camera detected on port {}".format(portname))

        self.zerobox.connect_camera(cameras[portname])

    def exposed_connect_to_all(self):
        cameras = self.zerobox.get_cameras()

        for portname in cameras.keys():
            self.exposed_connect(portname)

    def exposed_get_session(self):
        return self.session

    def exposed_get_status(self, force=False):
        data = {}
        data["connector_state"] = self.state
        data["zerobox_status"] = self.zerobox.get_status(force_connection=force)
        return data

    def exposed_get_next_invocation(self):
        return self.scheduler.get_next_invocation("trigger")

    def exposed_detect_cameras(self):
        return self.zerobox.detect_cameras()

    def exposed_get_cameras(self):
        return self.zerobox.get_cameras()

    def exposed_detect_usb_controller(self):
        self.usbController = UsbController.find_all()
        return self.usbController

    def exposed_get_usb_controller(self):
        return self.usbController

    def exposed_get_total_space(self):
        return self.zerobox.get_total_space()

    def exposed_get_free_space(self):
        return self.zerobox.get_free_space()

    def exposed_get_images_in_memory(self):
        return self.zerobox.get_images_in_memory()



class Ztimer():

    def __init__(self, interval):
        self.interval = interval

    def run(self):

        zeroboxConnector = None

        try:
            print("start")
            time.sleep(1.0)
            print("go")
            zeroboxConnector = rpyc.connect("localhost", 18861)
        except ConnectionRefusedError as e:
            print("zeroboxConnector not available. retry...")
            for i in range(10):
                time.sleep(0.2)
                try:
                    zeroboxConnector = rpyc.connect("localhost", 18861)
                    break
                except ConnectionRefusedError as e:
                    pass

            if zeroboxConnector is None:
                print("zeroboxConnector not available. failed.")
                sys.exit(-1)

        try:
            while True:
                zeroboxConnector.root.loop()
                time.sleep(self.interval)
        except KeyboardInterrupt as e:
            print("Keyboard Interrupt. Exiting...")
        except Exception as e:
            print("Unknown Exception: {}".format(e))


if __name__ == "__main__":

    timer = Ztimer(0.5)
    timer_thread = Thread(target = timer.run)
    timer_thread.start()

    try:
        # allow_public_attrs is necessary to access data in passed dicts
        # allow_pickle is required for obtain() to avoid netref proxy objects
        t = ThreadedServer(ZeroboxConnector(), port=18861, protocol_config={
            "allow_public_attrs": True,
            "allow_pickle": True
        })
        t.start()
    except Exception as e:
        print(e)
        traceback.print_exc()