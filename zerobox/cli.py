#!/usr/bin/env python3

import argparse
import sys
import subprocess

import rpyc
from rpyc.utils.classic import obtain

from zeroboxConnector import ZeroboxConnector

DATA_STRING = "{label:<40} : {data:>40}"
DATA_STRING2 = "  {label:<38} : {data:>40}"

parser = argparse.ArgumentParser(prog="zcli", description="zerobox command line application")

parser.add_argument("action",
                    choices=[
                        "start", 
                        "stop", 
                        "off", 
                        "info", 
                        "log",
                        "enable_service",
                        "restart_service",
                        "disable_service"
                    ],
                    help="what to do...")

args = parser.parse_args()

def _systemctl_service(keyword):
    output = subprocess.check_output(["sudo", "systemctl", keyword, "zerobox"])
    output = output.decode("utf-8")
    print(output)
    output = subprocess.check_output(["sudo", "systemctl", keyword, "zerobox_gui"])
    output = output.decode("utf-8")
    print(output)

def _connect():
    c = rpyc.connect("localhost", 18861, config={
        "allow_public_attrs": True,
        "allow_pickle": True
    })

    return c.root

if args.action == "start":
    try:
        conn = _connect()
        status = conn.get_status(force=True)

        if  status["connector_state"] == ZeroboxConnector.STATE_RUNNING:
            print("session already running. abort.")
            sys.exit(2)

        if not status["connector_state"] == ZeroboxConnector.STATE_IDLE:
            print("zeroboxConnector not idle. abort.")
            sys.exit(2)

        conn.start()
        print("session started")
    except Exception as e:
        raise e

elif args.action == "stop":
    try:
        conn = _connect()
        status = conn.get_status(force=True)
        if not status["connector_state"] == ZeroboxConnector.STATE_RUNNING:
            print("no active session to stop. abort.")
            sys.exit(3)

        session = conn.get_session()
        print("session captured {}/{} images".format(len(session["images"]), session["iterations"]))
        print("session duration: {}".format("TODO"))

        conn.stop()

        print("session stopped")
    except Exception as e:
        raise e

elif args.action == "off":
    try:
        conn = _connect()
        status = conn.get_status(force=True)
        if not status["connector_state"] == ZeroboxConnector.STATE_IDLE:
            print("not idle. abort.")
            sys.exit(3)

        conn.turn_off_everything()

        print("all controllers turned off.")
    except Exception as e:
        raise e

elif args.action == "log":
    try:
        print("")
        output = subprocess.check_output(["tail", "/var/log/syslog"])
        output = output.decode("utf-8")
        print(output)
    except Exception as e:
        raise e

elif args.action == "enable_service":
    try:
        print("")
        _systemctl_service("enable")
    except Exception as e:
        raise e

elif args.action == "restart_service":
    try:
        print("")
        _systemctl_service("restart")
    except Exception as e:
        raise e

elif args.action == "disable_service":
    try:
        print("")
        _systemctl_service("stop")
        _systemctl_service("disable")
    except Exception as e:
        raise e

elif args.action == "info":
    try:
        conn = _connect()
        status = conn.get_status(force=True)
        temperatures = status["temperature"]
        battery = status["battery"]
        network = conn.get_network_status(force=True)

        total_space = conn.get_total_space() / (1024*1024)
        free_space = conn.get_free_space() / (1024*1024)
        images_in_memory = conn.get_images_in_memory()

        print("")
        print("ZEROBOX CONNECTOR available")
        print("-" * 83)

        msg = "[unknown]" 
        if status["connector_state"] == ZeroboxConnector.STATE_IDLE:
            msg = "idle"
        elif status["connector_state"] == ZeroboxConnector.STATE_RUNNING:
            msg = "running"
        print(DATA_STRING.format(label="status", data=msg))

        if temperatures is not None and len(temperatures) > 0:
            for temp in temperatures:
                print(DATA_STRING.format(label="temperature", data="{}°C ({})".format(temp[0], temp[1])))
        else:
            print(DATA_STRING.format(label="temperature", data="[not available]"))

        msg = "[not available]" 
        if battery is not None:
            msg = "{:.2f}%".format(battery)
        print(DATA_STRING.format(label="battery", data=msg))

        msg = "[not available]" 
        if network is not None:
            msg = network["ssid"]
        print(DATA_STRING.format(label="network", data=msg))            

        print(DATA_STRING.format(label="free space", data="{:.2f} / {:.2f} ({:.1f}%) [{}]".format(free_space, total_space, (free_space/total_space)*100, len(images_in_memory))))        

        if status["connector_state"] == ZeroboxConnector.STATE_RUNNING:
            print("-" * 83)
            print(DATA_STRING.format(label="session", data="active for 1h 23min 45s"))   
            session = conn.get_session()
            for key in session.keys():
                if key == "errors" or key == "images":
                    print(DATA_STRING2.format(label=key, data=len(session[key])))  
                    continue

                print(DATA_STRING2.format(label=key, data=str(session[key])))  

        print("")

    except Exception as e:
        raise e

else:
    print("unexpected value for the action argument: {}".format(args.action))
    sys.exit(1)