from zerobox import Zerobox
from zeroboxScheduler import Scheduler
from devices import UsbDirectController

import rpyc
from rpyc.utils.server import ThreadedServer

import logging as log
from datetime import datetime, timedelta
import time
import sys
import yaml

import multiprocessing
from multiprocessing.pool import ThreadPool
from multiprocessing.pool import Pool

from threading import Thread


CONFIG_FILE_DEFAULT = "config_default.yaml"
CONFIG_FILE_USER = "config.yaml"


def _trigger(zerobox, portname):
    return zerobox.trigger_camera(portname)

class ZeroboxConnector(rpyc.Service):

    STATE_IDLE      = 1
    STATE_RUNNING   = 2

    def __init__(self):
        print("init")

        self.zerobox = Zerobox()
        self.scheduler = Scheduler()
        self.usbDirectController = []

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


    def close(self):
        if self.pool is not None:
            self.pool.close()
            self.pool.terminate()

        if self.zerobox is not None:
            self.zerobox.close()


    def on_connect(self, conn):
        print("on_connect")


    def on_disconnect(self, conn):
        print("on_disconnect")


    def exposed_ping(self):
        return None


    def exposed_detect_cameras(self):
        return self.zerobox.detect_cameras()


    def exposed_connect(self, portname):
        cameras = self.zerobox.get_cameras()

        if portname not in cameras:
            raise Exception("no camera detected on port {}".format(portname))
        
        self.zerobox.connect_camera(cameras[portname])


    def exposed_trigger(self):

        self.capture_results = []
        self.capture_timer = []
        arguments = []

        for portname, cameraconnector in self.zerobox.get_connectors().items():
            arguments.append((self.zerobox, portname))

        for arg in arguments:
            self.capture_timer.append(datetime.now())
            capture_result = self.pool.apply_async(_trigger, arg)
            self.capture_results.append(capture_result)

        # for portname, cameraconnector in self.zerobox.get_connectors().items():
        #     self.zerobox.trigger_camera(portname)


    def exposed_check_trigger_result(self):

        results = []
        
        for result, t in zip(self.capture_results, self.capture_timer):
            try:    
                # r = result.get() # get blocks
                r = result.get(timeout=0.1) #s
                results.append(r)
                print("took {0:.2f}ms".format((datetime.now() - t).microseconds / 1000))
            except multiprocessing.context.TimeoutError as e:
                #log.warn("timeout while waiting for result")
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
                for controller in self.usbController:
                    controller.turn_on(True)

            if "camera_off" in jobs:
                for controller in self.usbController:
                    controller.turn_on(False)

            if "trigger" in jobs:
                self.exposed_trigger()

            results = self.exposed_check_trigger_result()

            if len(results) > 0 and None not in results:
                print(results)

                # TODO
                # if done?

        else:
            log.warning("illegal state: {}".format(self.state))

    def exposed_load_config(self, connector_config):
        config_copy = {}
        for key in connector_config:
            config_copy[key] = connector_config[key]

        self.config = {**self.config, **config_copy}

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

    # def exposed_load_zerobox_config(self, config):
    #     config_copy = {}
    #     for key in config:
    #         config_copy[key] = config[key]
    #     return self.zerobox.load_config(config_copy)

    def findUsbController(self):
        pass

    def exposed_start(self):

        self.session = {}
        self.session["start"]   = datetime.now()
        self.session["end"]     = self.session["start"] + timedelta(seconds=(self.config["interval"]["value"] * self.config["iterations"]["value"]))
        self.session["images"]  = []

        for key in self.config.keys():
            if "type" in self.config[key]:
                self.session[key] = self.config[key]["value"]

        interval = self.session["interval"]*1000
        delay = 500
        if self.session["persistentcamera"]:
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

    def exposed_stop(self):
        if self.scheduler.is_job_scheduled("camera_on"):
            self.scheduler.remove_job("camera_on")

        if self.scheduler.is_job_scheduled("trigger"):
            self.scheduler.remove_job("trigger")

        if self.scheduler.is_job_scheduled("camera_off"):
            self.scheduler.remove_job("camera_off")

        self.session["end"] = datetime.now()

    def exposed_get_session(self):
        return self.session

    def exposed_get_status(self, force=False):
        data = {}
        data["state"] = self.state
        data["zerobox_status"] = self.zerobox.get_status(force_connection=force)
        return data

    def exposed_get_cameras(self):
        return self.zerobox.get_cameras()

    def exposed_get_usb_controller(self):
        self.usbDirectController = UsbDirectController.find_all()
        return self.usbDirectController

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

    timer = Ztimer(0.1)
    timer_thread = Thread(target = timer.run)
    timer_thread.start()

    try:
        # allow_public_attrs is necessary to access data in passed dicts
        t = ThreadedServer(ZeroboxConnector(), port=18861, protocol_config={
            "allow_public_attrs": True,
            "allow_pickle": True
        })
        t.start()
    except Exception as e:
        print(e)

    # c = ZeroboxConnector()
    # c.zerobox.connectors = {"narf": "barf"}
    # c.exposed_trigger()
    # c.exposed_check_trigger_result()