from zerobox import Zerobox
import rpyc

import logging as log
from datetime import datetime

from multiprocessing.pool import ThreadPool
from multiprocessing.pool import Pool
import multiprocessing


def _trigger(zerobox, portname):
    return zerobox.trigger_camera(portname)


class ZeroboxConnector(rpyc.Service):

    def __init__(self):
        print("init")

        self.zerobox = Zerobox()

        self.pool = ThreadPool(processes=1)
        self.capture_results = []
        self.capture_timer = []


    def close(self):
        if self.pool is not None:
            self.pool.close()
            self.pool.terminate()


    def on_connect(self, conn):
        print("on_connect")


    def on_disconnect(self, conn):
        print("on_disconnect")


    def exposed_ping(self):
        return None


    def exposed_get_total_space(self):
        return self.zerobox.get_total_space()


    def exposed_get_free_space(self):
        return self.zerobox.get_free_space()


    def exposed_get_images_in_memory(self):
        return self.zerobox.get_images_in_memory()


    def exposed_load_config(self, config):
        config_copy = {}
        for key in config:
            config_copy[key] = config[key]
        return self.zerobox.load_config(config_copy)


    def exposed_detect_cameras(self):
        return self.zerobox.detect_cameras()


    def exposed_get_cameras(self):
        return self.zerobox.get_cameras()


    def exposed_get_status(self, force=False):
        # data = {}
        status = self.zerobox.get_status(force_connection=force)
        # data = {**data, **status}
        # return data
        return status


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
                print("timeout")
                results.append(None)

        return results


    def exposed_disconnect_all_cameras(self):
        self.zerobox.disconnect_all_cameras()



if __name__ == "__main__":
    from rpyc.utils.server import ThreadedServer
    # allow_public_attrs is necessary to access data in passed dicts
    t = ThreadedServer(ZeroboxConnector(), port=18861, protocol_config={'allow_public_attrs': True})
    t.start()

    # c = ZeroboxConnector()
    # c.zerobox.connectors = {"narf": "barf"}
    # c.exposed_trigger()
    # c.exposed_check_trigger_result()