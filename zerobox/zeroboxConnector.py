from zerobox import Zerobox
import rpyc

class ZeroboxConnector(rpyc.Service):

    def __init__(self):
        print("init")
        self.state = {}
        self.zerobox = Zerobox()

    def on_connect(self, conn):
        print("on_connect")

    def on_disconnect(self, conn):
        print("on_disconnect")

    def exposed_init(self):
        ports = self.zerobox.detect_cameras()

    def exposed_ping(self):
        return None

    def exposed_get_state(self):
        data["cam_0"]                           = {}
        data["cam_1"]                           = {}

        data["cam_0"]["port"]                   = "foo"
        data["cam_0"]["active"]                 = True
        data["cam_0"]["shutter"]                = "1.0"
        data["cam_0"]["aperture"]               = 11
        data["cam_0"]["iso"]                    = 300
        data["cam_0"]["exposurecompensation"]   = 1

        data["cam_1"]["active"]                 = True
        data["cam_1"]["shutter"]                = "1/300"
        data["cam_1"]["aperture"]               = 5.6
        data["cam_1"]["iso"]                    = 300
        data["cam_1"]["exposurecompensation"]   = 1

        return data

    def exposed_run(self):
        self.zerobox.connect_camera(self.zerobox.cameras[0])
        self.zerobox.trigger_camera(self.zerobox.cameras[0])


if __name__ == "__main__":
    from rpyc.utils.server import ThreadedServer
    t = ThreadedServer(ZeroboxConnector(), port=18861)
    t.start()