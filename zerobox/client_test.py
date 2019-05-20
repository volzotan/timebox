import rpyc
from rpyc.utils.classic import obtain
import time

c = rpyc.connect("localhost", 18861, config={
    "allow_public_attrs": True,
    "allow_pickle": True
})

try:
    c.root.disconnect_all_cameras() # TODO not the best way
    c.root.start()

    config = obtain(c.root.get_config())
    config["secondexposure"]["value"] = True
    config["se_use_threshold"]["value"] = False
    config["interval"]["value"] = 13 # 30
    config["iterations"]["value"] = 2

    # config["intervalcamera"]["value"] = True

    c.root.load_config(config)

    time.sleep(70)

except Exception as e:
    print(e)
finally:
    c.root.stop()
    c.root.stop()
    print(c.root.get_session())