import rpyc
from rpyc.utils.classic import obtain
import time

c = rpyc.connect("localhost", 18861)

try:
    c.root.start()

    config = obtain(c.root.get_config())
    config["se_use_threshold"]["value"] = False
    c.root.load_config(config)

    time.sleep(2)

except Exception as e:
    print(e)
finally:
    c.root.stop()