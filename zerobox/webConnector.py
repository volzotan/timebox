from datetime import datetime
import json
import logging
import yaml

import requests
from requests.auth import HTTPBasicAuth


class ServpatConnector(object):

    SERVER_ADDRESS = "http://zoltep.de"
    DATEFORMAT_INPUT = "%Y-%m-%d %H:%M:%S.%f"

    last_update = None

    def __init__(self, interval=5*60*1000):
        self.interval = interval

        self.log = logging.getLogger()
        self.log.setLevel(logging.DEBUG)

        self.auth = None
        with open("webConnectorAuth.yaml", 'r') as f:
            try:
                content = yaml.safe_load(f)
                self.auth = HTTPBasicAuth(content["auth"]["username"], content["auth"]["password"])
            except yaml.YAMLError as e:
                self.log.error("reading auth yaml file failed: {}".format(e))

    def sync_status(self, data):
        
        payload = data

        payload["deviceId"] = "123"
        payload["deviceName"] = "pythonTestClient"
        payload["timestamp"] = datetime.now().strftime(self.DATEFORMAT_INPUT) #[:-3]
        payload["numberImagesTaken"] = 100
        payload["numberImagesSaved"] = 50
        payload["freeSpaceInternal"] = 990.0
        payload["freeSpaceExternal"] = 1000.0
        payload["batteryInternal"] = 99.0
        payload["batteryExternal"] = -1
        payload["stateCharging"] = 0

        try:
            r = requests.post(self.SERVER_ADDRESS + "/status", auth=self.auth, json=payload)
            r.raise_for_status()
        except Exception as e:
            self.log.error("syncing status failed with code {}: {}".format(r.status_code, e))


# if __name__ == "__main__":

#     foo = ServpatConnector()
#     print(foo.auth)
#     # foo.sync_status("")