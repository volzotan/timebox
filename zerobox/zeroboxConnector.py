#!/usr/bin/env python3

from zerobox import Zerobox
from zeroboxScheduler import Scheduler
from devices import Controller, YKushXSController
from webConnector import ServpatConnector

import rpyc
from rpyc.utils.server import Server, ThreadedServer, ThreadPoolServer
from rpyc.utils.classic import obtain

import logging
import traceback

from datetime import datetime, timedelta
import time
import os
import subprocess
import sys
import yaml
import psutil

import multiprocessing
from multiprocessing.pool import ThreadPool
from multiprocessing.pool import Pool

from threading import Thread

CONFIG_FILE_DEFAULT = "config_default.yaml"
CONFIG_FILE_USER    = "config.yaml"

def _trigger(zerobox, portname):
    return zerobox.trigger_camera(portname)

class ZeroboxConnector(rpyc.Service):

    STATE_IDLE      = 1
    STATE_RUNNING   = 2

    def __init__(self):
        print("init")

        self.scheduler = Scheduler()

        self.controller = []
        self.controller = self.exposed_detect_controller()

        self.pool = ThreadPool(processes=1)
        self.capture_results = []
        self.capture_timer = []

        self.config = {}
        self.temperature_data = []
        self.battery_data = None
        self.network_status = None

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

        # init logging, create logger
        self.init_log()

        self.zerobox = Zerobox(new_config=self._prepare_zerobox_config())

        self.exposed_print_config()

        self.log.info("found {} Controller".format(len(self.controller)))
        for c in self.controller:
            self.log.info(c)

        # Pi Zero Maintenance stuff
        # Turn off HDMI to save power
        try:
            subprocess.call("/usr/bin/tvservice -o", shell=True)
        except Exception as e:
            pass

        self.scheduler.add_job("sync", 5*60*1000, delay=1000)
        self.scheduler.add_job("maintenance", 5*60*1000, delay=2000)

    def init_log(self):

        if not os.path.exists(self.config["log"]["basedir"]):
            print("LOG DIR missing. create...")
            os.makedirs(self.config["log"]["basedir"])

        log_filename_debug = os.path.join(self.config["log"]["basedir"], self.config["log"]["filename_debug"])
        log_filename_info = os.path.join(self.config["log"]["basedir"], self.config["log"]["filename_info"])

        # create logger
        self.log = logging.getLogger()
        self.log.setLevel(logging.DEBUG)

        # remove prior logging handlers
        try:
            self.log.handlers.pop()
        except Exception as e:
            pass

        # create formatter
        formatter = logging.Formatter(self.config["log"]["format"])

        # console handler and set level to debug
        consoleHandler = logging.StreamHandler()
        consoleHandler.setLevel(self.config["log"]["level"])
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


    # def exposed_usb_switch_on(self, power_on):
    #     if power_on:
    #         f = open(USB_CHIP, "w")
    #         f.write("1")
    #         f.close()
    #         log.debug("usb enabled")
    #     else:
    #         f = open(USB_CHIP, "w")
    #         f.write("0")
    #         f.close()
    #         log.debug("usb disabled")

    #     time.sleep(1)


    def exposed_ping(self):
        return None


    def exposed_trigger(self):

        self.log.debug("trigger")

        self.capture_results = []
        self.capture_timer = []
        arguments = []

        cameraconnectors = self.zerobox.get_connectors()
        if len(cameraconnectors.items()) == 0:
            raise NoConnectedCameraException("trigger failed.")

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

    def _get_max_trigger_age(self):
        if len(self.capture_results) == 0:
            return None

        result_ages = []

        for result, t in zip(self.capture_results, self.capture_timer):
            diff = (datetime.now() - t).total_seconds()
            result_ages.append(diff)

        return max(result_ages)

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
            except Exception as e:
                self.log.error("Error during triggering: {}".format(e))
                raise e
            
        return results


    def exposed_disconnect_all_cameras(self):
        self.zerobox.disconnect_all_cameras(clean=True)


    def exposed_shutdown(self, delay=2.0):
        self.log.info("STARTING SHUTDOWN!")

        self.log.info("shutdown procedure: turning off all controller")
        for c in self.controller:
            try:
                c.turn_on(False)
            except Exception as e:
                self.log.error("turning off controller {} failed: {}".format(c, e))

                    
        self.log.info("shutdown procedure: stopping GUI service")
        subprocess.run(["sudo", "systemctl", "stop", "zerobox_gui"])

        time.sleep(delay)

        self.log.info("shutdown procedure: shutdown OS")
        subprocess.run(["sudo", "shutdown", "now"])


    # -------


    def exposed_loop(self):

        self.log.debug("loop")

        jobs = self.scheduler.run_schedule()

        if "sync" in jobs:
            self.log.debug(">>> job running: SYNC")
            self.log.debug("    {}".format(self.scheduler.print_next_job()))

            try:
                self.exposed_sync_status()
            except Exception as e:
                self.log.warning("sync failed: {}".format(e))

        if "maintenance" in jobs:
            self.log.debug(">>> job running: MAINTENANCE")
            self.log.debug("    {}".format(self.scheduler.print_next_job()))

            # TODO: check batteries and shutdown if too low
            # ...

            try:

                status = self.exposed_get_status()
                battery_controller = status["battery"]
                battery_cameras = self.zerobox.get_battery()

                shutdown = False

                if battery_controller is not None and battery_controller < self.config["min_battery"]["value"]:
                    self.log.info("SHUTDOWN LOW BATTERY! (battery_controller {} < {})"
                        .format(battery_controller, self.config["min_battery"]["value"]))

                    shutdown = True

                for battery_camera in battery_cameras:
                    if battery_camera[0] < self.config["min_battery"]["value"]:
                        self.log.info("SHUTDOWN LOW BATTERY! (battery_camera {} < {})"
                            .format(battery_camera[0], self.config["min_battery"]["value"]))

                        shutdown = True

                if shutdown:

                    self.exposed_shutdown()

            except Exception as e:
                self.log.error("maintenance failed: {}".format(e))
                if self.session is not None:
                    self.session["errors"].append(e)


        if self.state == self.STATE_IDLE:
            pass

        elif self.state == self.STATE_RUNNING:

            if "camera_on" in jobs:
                self.log.debug(">>> job running: CAMERA ON")
                self.log.debug("    {}".format(self.scheduler.print_next_job()))
                for c in self.controller:
                    # turn everything on except the data connections
                    if c.is_data_connection:
                        continue

                    try:
                        c.turn_on(True)
                    except Exception as e:
                        self.log.error("controller turn on failed: {}".format(e))
                        self.session["errors"].append(e)

            if "usb_on" in jobs:
                self.log.debug(">>> job running: USB ON")
                self.log.debug("    {}".format(self.scheduler.print_next_job()))
                for c in self.controller:
                    try:
                        c.turn_on(True)
                    except Exception as e:
                        self.log.error("controller turn on failed: {}".format(e))
                        self.session["errors"].append(e)

            if "trigger" in jobs:
                self.log.debug(">>> job running: TRIGGER")
                self.log.debug("    {}".format(self.scheduler.print_next_job()))
                if not self._is_trigger_active():
                    if self.session["intervalcamera"]:
                        self.exposed_detect_cameras()
                        self.exposed_connect_to_all()

                        # TODO: add small delay here?
                    try:
                        self.exposed_trigger()
                    except NoConnectedCameraException as nocamexc:
                        self.log.error("trigger failed: {}".format("no camera connected"))
                        self.session["errors"].append(nocamexc)
                    except Exception as e:
                        self.log.error("trigger failed: {}".format(e))
                        self.session["errors"].append(e)
                else:
                    self.log.warning("previous trigger still active! ignoring trigger event")
                    self.session["errors"].append(Exception("prev trigger active"))

            if "camera_off" in jobs:
                self.log.debug(">>> job running: CAMERA OFF")
                self.log.debug("    {}".format(self.scheduler.print_next_job()))

                if not self._is_trigger_active():
                    for c in self.controller:
                        try:
                            c.turn_on(False)
                        except Exception as e:
                            self.log.error("controller turn off failed: {}".format(e))
                            self.session["errors"].append(e)
                else:
                    trigger_age = self._get_max_trigger_age()
                    if trigger_age < 100:
                        self.log.warning("previous trigger still active! unable to turn off camera")
                    else:
                        self.log.error("previous trigger active for {:.2f}! force camera off".format(trigger_age))
                        for c in self.controller:
                            try:
                                c.turn_on(False)
                            except Exception as e:
                                self.log.error("controller turn off failed: {}".format(e))
                                self.session["errors"].append(e)

            # check finished triggers

            try:
                results = self.exposed_check_trigger_result()

                if len(results) > 0 and None not in results:
                    self.session["images"].append(results)
                    self.capture_results = []
                    self.capture_timer = []

                    # camera off?
                    # TODO: ignores post_wait
                    if self.session["intervalcamera"]:
                        if not self._is_trigger_active():
                            
                            self.log.debug("executing post trigger camera shutdown")

                            # TODO: zerobox needs to forget the camera
                            self.zerobox.disconnect_all_cameras(clean=True)

                            for c in self.controller:
                                c.turn_on(False)
                        else:
                            self.log.warning("previous trigger still active! unable to turn off camera")

                    # session done?
                    if len(self.session["images"]) >= self.session["iterations"]:
                        self.log.info("image count equals iterations. ending session.")
                        self.exposed_stop()

            except Exception as e:
                self.log.error("error occured during triggering. reset everything...")
                self.session["errors"].append(e)
                self.capture_results = []
                self.capture_timer = []
                if self.session["intervalcamera"]: 
                    self.zerobox.disconnect_all_cameras(clean=True)
                    for c in self.controller:
                        try:
                            c.turn_on(False)
                        except Exception as e:
                            self.log.error("controller turn off failed: {}".format(e))
                            self.session["errors"].append(e)

        else:
            self.log.warning("illegal state: {}".format(self.state))

    def _prepare_zerobox_config(self):

        zeroboxConfig = {}

        zeroboxConfig["IMAGE_DIR_PRIMARY"] = self.config["image_dir_primary"]["path"]
        zeroboxConfig["IMAGE_DIR_SECONDARY"] = self.config["image_dir_secondary"]["path"]

        zeroboxConfig["AUTOFOCUS_ENABLED"] = self.config["autofocus"]["value"]
        zeroboxConfig["SECONDEXPOSURE_ENABLED"] = self.config["secondexposure"]["value"]
        if self.config["se_use_threshold"]["value"]:
            zeroboxConfig["SECONDEXPOSURE_THRESHOLD"] = self.config["se_threshold"]["value"]
        else:
            zeroboxConfig["SECONDEXPOSURE_THRESHOLD"] = None
        zeroboxConfig["EXPOSURE_1"] = self.config["se_expcompensation_1"]["value"]
        zeroboxConfig["EXPOSURE_2"] = self.config["se_expcompensation_2"]["value"]

        return zeroboxConfig

    def exposed_load_config(self, connector_config):
        self.config = {**self.config, **obtain(connector_config)}
        self.zerobox.load_config(self._prepare_zerobox_config())

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

        self.exposed_load_config({})
        self.exposed_detect_controller()

        if not self.session["intervalcamera"]:
            self.exposed_detect_cameras()
            self.exposed_connect_to_all()

        # turn off all devices for a clean start
        if self.session["intervalcamera"]:
            self.zerobox.disconnect_all_cameras(clean=True)
            for c in self.controller:
                try:
                    c.turn_on(False)
                except Exception as e:
                    self.log.error("controller turn off failed: {}".format(e))
                    self.session["errors"].append(e)

        interval = self.session["interval"]*1000
        delay = 500
        if not self.session["intervalcamera"]:
            self.scheduler.add_job("trigger", interval, delay = delay)
        else:
            self.scheduler.add_job("camera_on", interval,
                                   delay = delay)
            self.scheduler.add_job("usb_on", interval,
                                   delay = delay+float(self.session["ic_pre_wait"])*1000-4000)
            self.scheduler.add_job("trigger", interval,
                                   delay = delay+float(self.session["ic_pre_wait"])*1000)
            # max time the camera may be alive. should already be shut down after
            # the trigger event returned, but just as a safeguard
            self.scheduler.add_job("camera_off", interval,
                                   delay = delay+(30.0+float(self.session["ic_pre_wait"]))*1000)

        self.state = self.STATE_RUNNING

        FORMAT = "  {:<24}: {}"

        self.log.info("start session")
        self.log.info(FORMAT.format("interval", interval))
        self.log.info(FORMAT.format("cameras", len(self.zerobox.get_cameras())))
        self.log.info(FORMAT.format("controller", len(self.controller)))

    def exposed_stop(self):

        self.log.info("session stop")

        if self.scheduler.is_job_scheduled("camera_on"):
            self.scheduler.remove_job("camera_on")

        if self.scheduler.is_job_scheduled("trigger"):
            self.scheduler.remove_job("trigger")

        if self.scheduler.is_job_scheduled("camera_off"):
            self.scheduler.remove_job("camera_off")

        if self.scheduler.is_job_scheduled("sync"):
            self.scheduler.remove_job("sync")

        self.session["end"] = datetime.now()
        self.state = self.STATE_IDLE

    def exposed_turn_on_everything(self, turn_on):
        self.exposed_detect_controller()
        for c in self.controller:
            try:
                c.turn_on(turn_on)
            except Exception as e:
                self.log.error("controller turn on/off failed: {}".format(e))
                self.session["errors"].append(e)

    def exposed_connect(self, _portname):
        portname = obtain(_portname)
        cameras = self.zerobox.get_cameras()

        if portname not in cameras:
            raise Exception("no camera detected on port {}".format(portname))

        self.zerobox.connect_camera(cameras[portname])

    def exposed_connect_to_all(self):

        # TODO
        subprocess.call("killall PTPCamera", shell=True)

        cameras = self.zerobox.get_cameras()

        for portname in cameras.keys():
            self.exposed_connect(portname)

    def exposed_get_session(self):
        return self.session

    def exposed_get_status(self, force=False):

        data = {}
        data["connector_state"] = self.state
        data["zerobox_status"] = self.zerobox.get_status(force_connection=force)

        if force:
            self.temperature_data = []
            try: 
                temp_str = str(subprocess.check_output(["vcgencmd", "measure_temp"]))
                temp = float(temp_str[temp_str.index("=")+1:temp_str.index("'")])
                self.temperature_data.append([temp, "cpu"])
            except Exception as e:
                pass
            for c in self.controller:
                try:
                    temp = c.get_temperature()
                    if temp is not None:    
                        self.temperature_data.append([temp, "controller"])
                except Exception as e:
                    self.log.warn("controller get temp data failed: {}".format(e))
        data["temperature"] = self.temperature_data

        if force:
            self.battery_data = None
            for c in self.controller:
                try:
                    perc = c.get_battery_status()
                    if perc is not None:
                        self.battery_data = perc
                except Exception as e:
                    self.log.warn("controller get battery data failed: {}".format(e))
        data["battery"] = self.battery_data

        if force:
            self.exposed_log_process_memory()

        if force:
            self.network_status = None
            network_data = {}

            try: 
                ssid = subprocess.check_output(["iwgetid", "-r"])
                if ssid is not None:
                    network_data["ssid"] = ssid.decode("utf-8")[:-1]
                    network_data["interface"] = "wlan0"
                    self.network_status = network_data
            except Exception as e:
                self.log.debug(e)
        data["network_status"] = self.network_status

        return data

    def exposed_set_network_status(self, interfacename, enable):
        mode = "down"

        if enable:
            mode = "up"

        try: 
            ssid = subprocess.check_output(["sudo", "ifconfig", interfacename, mode])
        except Exception as e:
            self.log.debug(e)

    def exposed_get_next_invocation(self):
        return self.scheduler.get_next_invocation("trigger")

    def exposed_detect_cameras(self):
        return self.zerobox.detect_cameras()

    def exposed_get_cameras(self):
        return self.zerobox.get_cameras()

    def exposed_detect_controller(self):
        self.controller = Controller.find_all()
        return self.controller

    def exposed_get_controller(self):
        return self.controller

    def exposed_get_total_space(self):
        return self.zerobox.get_total_space()

    def exposed_get_free_space(self):
        return self.zerobox.get_free_space()

    def exposed_get_images_in_memory(self):
        return self.zerobox.get_images_in_memory()

    def exposed_get_process_memory(self):
        return psutil.virtual_memory()._asdict()["percent"]

    def exposed_log_process_memory(self):
        self.log.debug("MEMORY: {}".format(self.exposed_get_process_memory()))

    def _get_pi_serial(self):
        cpuserial = "0000000000000000"
        try:
            f = open('/proc/cpuinfo','r')
            for line in f:
                if line[0:6]=='Serial':
                    cpuserial = line[10:26]
            f.close()
        except Exception as e:
            self.log.error("reading serial number failed: {}".format(e))

        return cpuserial

    def exposed_sync_status(self):

        if self.exposed_get_network_status() is None:
            self.log.info("cancel sync status. no network connection")
            raise Exception("no network connection")

        status = self.exposed_get_status()

        payload = {}

        payload["deviceId"] = self._get_pi_serial()
        payload["deviceName"] = "zerobox"

        payload["imagesTaken"] = -1
        if self.session is not None:
            payload["imagesTaken"] = len(self.session["images"])
        payload["imagesInMemory"] = len(self.exposed_get_images_in_memory())

        if self.exposed_get_free_space()[0] is not None:
            payload["freeSpaceInternal"] = self.exposed_get_free_space()[0] / (1024*1024)
        else:
            payload["freeSpaceInternal"] = -1

        if self.exposed_get_free_space()[1] is not None:
            payload["freeSpaceExternal"] = self.exposed_get_free_space()[1] / (1024*1024)
        else:
            payload["freeSpaceExternal"] = -1

        payload["batteryInternal"] = -1
        if status["battery"] is not None:
            payload["batteryInternal"] = status["battery"]
        payload["batteryExternal"] = -1

        payload["temperatureDevice"] = -1
        payload["temperatureBattery"] = -1

        servpatConnector = ServpatConnector()
        servpatConnector.sync_status(payload)


class NoConnectedCameraException(Exception):
    pass


class Ztimer():

    def __init__(self, interval):
        self.interval = interval
        
        self.log = logging.getLogger()
        self.log.setLevel(logging.DEBUG)

    def run(self):

        zeroboxConnector = None

        try:
            self.log.debug("start")
            time.sleep(1.0)
            self.log.debug("go")
            zeroboxConnector = rpyc.connect("localhost", 18861, config={
                "allow_public_attrs": True,
                "allow_pickle": True
            })
        except ConnectionRefusedError as e:
            self.log.debug("zeroboxConnector not available. retry...")
            for i in range(10):
                time.sleep(1.0)
                try:
                    zeroboxConnector = rpyc.connect("localhost", 18861, config={
                        "allow_public_attrs": True,
                        "allow_pickle": True
                    })
                    break
                except ConnectionRefusedError as e:
                    self.log.debug("connection refused. retry...")

            if zeroboxConnector is None:
                self.log.error("zeroboxConnector not available. failed.")
                sys.exit(-1)

        while True:
            try:
                zeroboxConnector.root.loop()
                time.sleep(self.interval)
            except KeyboardInterrupt as e:
                self.log.info("Keyboard Interrupt. Exiting...")
                sys.exit(0)
            except EOFError as e:
                self.log.info("ZeroboxConnector Server closed. Exiting...")
                sys.exit(0)
            except Exception as e:
                self.log.error("Unknown Exception: {}".format(e))
                traceback.print_exc()
                
                # ignore and continue


if __name__ == "__main__":

    timer = Ztimer(0.5)
    timer_thread = Thread(target = timer.run)
    timer_thread.start()

    try:
        # allow_public_attrs is necessary to access data in passed dicts
        # allow_pickle is required for obtain() to avoid netref proxy objects

        # t = Server(ZeroboxConnector(), 
        #     port=18861, 
        #     protocol_config={
        #         "allow_public_attrs": True,
        #         "allow_pickle": True
        # })

        t = ThreadedServer(ZeroboxConnector(), 
            port=18861, 
            protocol_config={
                "allow_public_attrs": True,
                "allow_pickle": True
        })

        # t = ThreadPoolServer(ZeroboxConnector(), 
        #     port=18861, 
        #     nbThreads=1,
        #     requestBatchSize=1,
        #     protocol_config={
        #         "allow_public_attrs": True,
        #         "allow_pickle": True
        # })

        t.start()
    except Exception as e:
        print(e)
        traceback.print_exc()