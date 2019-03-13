from zerobox import Zerobox
import rpyc

class ZeroboxConnector(rpyc.Service):

    def __init__(self):
        print("init")
        self.zerobox = Zerobox()


    def on_connect(self, conn):
        print("on_connect")


    def on_disconnect(self, conn):
        print("on_disconnect")


    def exposed_ping(self):
        return None


    def exposed_detect(self):
        ports = self.zerobox.detect_cameras()
        return ports


    def exposed_disconnect_cameras(self):
        self.zerobox.disconnect_all_cameras()


    def exposed_get_status(self):
        # data = {}
        status = self.zerobox.get_status()
        # data = {**data, **status}
        # return data
        return status


    def exposed_connect(self):
        cameras = self.zerobox.get_cameras()
        if len(cameras) > 0:
            for portname, camera in cameras.items():
                self.zerobox.connect_camera(camera)


    def exposed_trigger(self):
        for portname, camera in self.zerobox.get_connectors():
            self.zerobox.trigger_camera(portname)



if __name__ == "__main__":
    from rpyc.utils.server import ThreadedServer
    # allow_public_attrs is necessary to access data in passed dicts
    t = ThreadedServer(ZeroboxConnector(), port=18861, protocol_config={'allow_public_attrs': True})
    t.start()